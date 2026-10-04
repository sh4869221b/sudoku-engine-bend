#!/usr/bin/env python3
"""Fast adapter regressions; no installed compiler or real builds required.

Run with ``python3 -m unittest discover -s qa -p 'test_low_memory.py' -v``.
Subprocesses are mocked at the process boundary. The isolation tests execute
the real runner against a tiny throwaway checkout and a fake gate process.
"""
import ast
import contextlib
import io
import json
import os
import pathlib
import runpy
import signal
import shlex
import shutil
import subprocess
import sys
import tempfile
import time
import unittest
from unittest import mock

QA = pathlib.Path(__file__).resolve().parent
sys.path.insert(0, str(QA))
import low_memory
import toolchain


PRECHECK = b'ALL PROOFS CHECK\nUse --verdict for mathematical validity.\n'
VERDICT = b'ALL PROOFS CHECK\n'
CPU_C = '#define BANGS 0\nint main(void) { return 0; }\n'


@contextlib.contextmanager
def capture_bytes():
    out, err = io.BytesIO(), io.BytesIO()
    with mock.patch.object(sys, 'stdout', mock.Mock(buffer=out)), \
            mock.patch.object(sys, 'stderr', mock.Mock(buffer=err)):
        yield out, err


class AdapterCase(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix='low memory tests ')
        self.addCleanup(self.tmp.cleanup)
        self.root = pathlib.Path(self.tmp.name)
        self.source = self.root / 'source file.bend'
        self.source.write_text('import Base\ndef main(): 0\n')
        self.output = self.root / 'native executable'
        self.env = {
            'BEND': str(self.root / 'locked tools' / 'bend'),
            'CC': str(self.root / 'locked tools' / 'clang'),
            'BENDTT': str(self.root / 'locked tools' / 'bendtt'),
            'BEND_LOW_MEMORY': '1',
        }

    def native_process(self, command, *, env, capture_output, preexec_fn):
        self.assertEqual(env, self.env)
        self.assertFalse(capture_output)
        self.assertTrue(callable(preexec_fn))
        if command[0] == self.env['BEND']:
            self.assertEqual(command[:3], [self.env['BEND'], str(self.source), '-o'])
            c_path = pathlib.Path(command[3])
            self.assertEqual(c_path.name, self.output.name + '.c')
            self.assertFalse(c_path.exists())
            c_path.write_text(CPU_C)
        else:
            self.assertEqual(command[0:3], [self.env['CC'], '-std=c11', '-O3'])
            self.assertTrue(pathlib.Path(command[3]).is_file())
            self.assertEqual(command[4:7], ['-lpthread', '-lm', '-o'])
            binary = pathlib.Path(command[7])
            self.assertFalse(binary.exists())
            binary.write_bytes(b'fresh executable bytes\x00')
            binary.chmod(0o751)
        return subprocess.CompletedProcess(command, 0)

    def proof_process(self, command, *, env, capture_output, preexec_fn):
        self.assertTrue(capture_output)
        self.assertTrue(callable(preexec_fn))
        if command[0] == self.env['BENDTT']:
            self.assertEqual(env, dict(self.env, LEAN_STACK_SIZE_KB='4194304'))
            self.assertEqual(len(command), 2)
            self.assertEqual(pathlib.Path(command[1]).read_bytes(), b'exported proof')
            return subprocess.CompletedProcess(command, 0, VERDICT, b'')
        self.assertEqual(env, self.env)
        frozen = pathlib.Path(command[1])
        self.assertNotEqual(frozen, self.source)
        self.assertEqual(frozen.read_bytes(), self.source.read_bytes())
        if command[2:] == ['--check-only']:
            return subprocess.CompletedProcess(command, 0, PRECHECK, b'')
        self.assertEqual(command[2], '-o')
        artifact = pathlib.Path(command[3])
        self.assertFalse(artifact.exists())
        artifact.write_bytes(b'exported proof')
        return subprocess.CompletedProcess(command, 0, b'', b'')


class NativeBuildTests(AdapterCase):
    def test_exact_argv_with_spaces_and_sequential_fresh_publication(self):
        with mock.patch.object(low_memory.subprocess, 'run', side_effect=self.native_process) as run:
            low_memory.native_build(self.source, self.output, self.env)
        self.assertEqual([call.args[0][0] for call in run.call_args_list],
                         [self.env['BEND'], self.env['CC']])
        self.assertEqual(self.output.read_bytes(), b'fresh executable bytes\x00')
        self.assertEqual(self.output.stat().st_mode & 0o777, 0o751)
        for call in run.call_args_list:
            self.assertFalse(pathlib.Path(call.args[0][-1]).exists())
            self.assertNotIn('shell', call.kwargs)

    def test_refuses_all_existing_output_types_without_starting_compiler(self):
        target = self.root / 'valuable input'
        target.write_bytes(b'keep me')
        makers = {
            'file': lambda p: p.write_bytes(b'old output'),
            'directory': lambda p: p.mkdir(),
            'symlink': lambda p: p.symlink_to(target),
            'dangling symlink': lambda p: p.symlink_to(self.root / 'missing'),
            'hardlink': lambda p: os.link(target, p),
        }
        for name, make in makers.items():
            with self.subTest(name=name):
                output = self.root / name
                make(output)
                with mock.patch.object(low_memory.subprocess, 'run') as run:
                    with self.assertRaisesRegex(RuntimeError, 'Refusing to overwrite'):
                        low_memory.native_build(self.source, output, self.env)
                    run.assert_not_called()
                self.assertTrue(os.path.lexists(output))
                self.assertEqual(target.read_bytes(), b'keep me')
        with self.assertRaisesRegex(RuntimeError, 'Refusing to overwrite'):
            low_memory.native_build(self.source, self.source, self.env)

    def test_missing_output_parent_fails_before_compile(self):
        with mock.patch.object(low_memory.subprocess, 'run') as run:
            with self.assertRaisesRegex(RuntimeError, 'directory does not exist'):
                low_memory.native_build(self.source, self.root / 'absent/out', self.env)
            run.assert_not_called()

    def test_output_created_during_compile_is_not_overwritten(self):
        def process(command, **kwargs):
            result = self.native_process(command, **kwargs)
            if command[0] == self.env['CC']:
                self.output.write_bytes(b'racing owner')
            return result
        with mock.patch.object(low_memory.subprocess, 'run', side_effect=process):
            with self.assertRaises(FileExistsError):
                low_memory.native_build(self.source, self.output, self.env)
        self.assertEqual(self.output.read_bytes(), b'racing owner')

    def test_compiler_and_clang_nonzero_or_signal_stop_pipeline(self):
        for failed_stage in (self.env['BEND'], self.env['CC']):
            for code in (2, 17, -9, -15):
                with self.subTest(stage=failed_stage, code=code):
                    def process(command, **kwargs):
                        if command[0] == failed_stage:
                            return subprocess.CompletedProcess(command, code)
                        return self.native_process(command, **kwargs)
                    with mock.patch.object(low_memory.subprocess, 'run', side_effect=process) as run:
                        with self.assertRaises(SystemExit) as raised:
                            low_memory.native_build(self.source, self.output, self.env)
                    self.assertEqual(raised.exception.code, code if code > 0 else 128 - code)
                    self.assertEqual(run.call_count, 1 if failed_stage == self.env['BEND'] else 2)
                    self.assertFalse(self.output.exists())

    def test_unsupported_native_runtime_fails_before_clang(self):
        for c in ('#define BANGS 1\n', 'int main(void) {}\n',
                  CPU_C + '#include <X11/Xlib.h>\n', CPU_C + '#include <alsa/asoundlib.h>\n'):
            with self.subTest(c=c):
                def process(command, **kwargs):
                    pathlib.Path(command[-1]).write_text(c)
                    return subprocess.CompletedProcess(command, 0)
                with mock.patch.object(low_memory.subprocess, 'run', side_effect=process) as run:
                    with self.assertRaisesRegex(RuntimeError, 'only Linux CPU'):
                        low_memory.native_build(self.source, self.output, self.env)
                self.assertEqual(run.call_count, 1)
                self.assertFalse(self.output.exists())

    def test_missing_c_or_missing_nonexecutable_binary_cannot_pass(self):
        for missing in ('c', 'binary', 'execute permission'):
            with self.subTest(missing=missing):
                def process(command, **kwargs):
                    if command[0] == self.env['BEND'] and missing != 'c':
                        return self.native_process(command, **kwargs)
                    if command[0] == self.env['CC'] and missing == 'execute permission':
                        pathlib.Path(command[-1]).write_bytes(b'not executable')
                    return subprocess.CompletedProcess(command, 0)
                with mock.patch.object(low_memory.subprocess, 'run', side_effect=process):
                    with self.assertRaises((FileNotFoundError, RuntimeError)):
                        low_memory.native_build(self.source, self.output, self.env)
                self.assertFalse(self.output.exists())

    def test_partial_output_removed_on_copy_failure(self):
        def interrupted_copy(src, destination):
            destination.write(b'partial')
            raise OSError('disk full')
        with mock.patch.object(low_memory.subprocess, 'run', side_effect=self.native_process), \
                mock.patch.object(low_memory.shutil, 'copyfileobj', side_effect=interrupted_copy):
            with self.assertRaisesRegex(OSError, 'disk full'):
                low_memory.native_build(self.source, self.output, self.env)
        self.assertFalse(self.output.exists())

    def test_partial_output_removed_on_flush_or_close_failure(self):
        original_open = pathlib.Path.open
        for failure in ('flush', 'close'):
            with self.subTest(failure=failure):
                class BrokenStream:
                    def __init__(self, stream):
                        self.stream = stream

                    def __enter__(self):
                        return self

                    def __exit__(self, *exc):
                        self.stream.close()
                        if failure == 'close':
                            raise OSError('close failure')

                    def write(self, data):
                        return self.stream.write(data)

                    def flush(self):
                        if failure == 'flush':
                            raise OSError('flush failure')
                        return self.stream.flush()

                    def fileno(self):
                        return self.stream.fileno()

                def open_file(path, *args, **kwargs):
                    stream = original_open(path, *args, **kwargs)
                    return BrokenStream(stream) if path == self.output and args == ('xb',) else stream

                with mock.patch.object(low_memory.subprocess, 'run', side_effect=self.native_process), \
                        mock.patch.object(pathlib.Path, 'open', open_file):
                    with self.assertRaisesRegex(OSError, failure + ' failure'):
                        low_memory.native_build(self.source, self.output, self.env)
                self.assertFalse(self.output.exists())


class ProcessLifecycleTests(AdapterCase):
    def test_run_installs_parent_death_hook_with_original_parent_pid(self):
        with mock.patch.object(low_memory.os, 'getpid', return_value=123456), \
                mock.patch.object(low_memory.subprocess, 'run',
                                  return_value=subprocess.CompletedProcess([], 0)) as process:
            low_memory.run([pathlib.Path('/locked tools/bend'), 'argument with spaces'], self.env)
        self.assertEqual(process.call_args.args[0], ['/locked tools/bend', 'argument with spaces'])
        with mock.patch.object(low_memory, 'die_with_parent') as die:
            process.call_args.kwargs['preexec_fn']()
            die.assert_called_once_with(123456)

    def test_parent_death_setup_and_race_guard(self):
        with mock.patch.object(low_memory.LIBC, 'prctl', return_value=0) as prctl, \
                mock.patch.object(low_memory.os, 'getppid', return_value=10), \
                mock.patch.object(low_memory.os, 'getpid', return_value=20), \
                mock.patch.object(low_memory.os, 'kill') as kill:
            low_memory.die_with_parent(10)
            prctl.assert_called_once_with(1, signal.SIGKILL, 0, 0, 0)
            kill.assert_not_called()
            low_memory.die_with_parent(11)
            kill.assert_called_once_with(20, signal.SIGKILL)
        with mock.patch.object(low_memory.LIBC, 'prctl', return_value=-1), \
                mock.patch.object(low_memory.ctypes, 'get_errno', return_value=1):
            with self.assertRaisesRegex(OSError, 'PR_SET_PDEATHSIG failed'):
                low_memory.die_with_parent(10)

    @unittest.skipUnless(sys.platform == 'linux', 'Linux parent-death signal contract')
    def test_real_timeout_kills_active_child_without_compilation(self):
        pidfile = self.root / 'child pid'
        child = ('import os, pathlib, time; '
                 f'pathlib.Path({str(pidfile)!r}).write_text(str(os.getpid())); time.sleep(30)')
        wrapper = ('import os, sys; '
                   f'sys.path.insert(0, {str(QA)!r}); import low_memory; '
                   f'low_memory.run([{sys.executable!r}, "-c", {child!r}], dict(os.environ))')
        # DEVNULL avoids the outer timeout waiting on inherited pipe handles if
        # this regression is broken. Only this harmless sleeping child is real.
        with self.assertRaises(subprocess.TimeoutExpired):
            subprocess.run([sys.executable, '-c', wrapper], timeout=1,
                           stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        self.assertTrue(pidfile.exists(), 'child must have started before timeout')
        pid = int(pidfile.read_text())
        proc = pathlib.Path('/proc') / str(pid)

        def clean_up_our_child():
            try:
                if str(pidfile).encode() in (proc / 'cmdline').read_bytes():
                    os.kill(pid, signal.SIGKILL)
            except (FileNotFoundError, ProcessLookupError):
                pass
        self.addCleanup(clean_up_our_child)
        deadline = time.monotonic() + 3
        while time.monotonic() < deadline:
            try:
                state = (proc / 'stat').read_text().rsplit(')', 1)[1].split()[0]
            except FileNotFoundError:
                return
            if state == 'Z':  # Dead; awaiting this container's PID 1 reaper.
                return
            time.sleep(0.01)
        self.fail('adapter timeout left its active child running')


class ProofTests(AdapterCase):
    def test_precheck_export_kernel_order_and_only_kernel_verdict_is_printed(self):
        with capture_bytes() as (out, err), \
                mock.patch.object(low_memory.subprocess, 'run', side_effect=self.proof_process) as run:
            low_memory.proof_verdict(self.source, self.env)
        calls = [call.args[0] for call in run.call_args_list]
        self.assertEqual([command[0] for command in calls],
                         [self.env['BEND'], self.env['BEND'], self.env['BENDTT']])
        self.assertEqual(calls[0][2:], ['--check-only'])
        self.assertEqual(calls[0][1], calls[1][1])
        self.assertEqual(calls[1][2], '-o')
        self.assertEqual(calls[1][3], calls[2][1])
        self.assertEqual(out.getvalue(), VERDICT)
        self.assertEqual(err.getvalue(), b'')
        self.assertFalse(pathlib.Path(calls[0][1]).exists())
        self.assertFalse(pathlib.Path(calls[2][1]).exists())

    def test_unsafe_precheck_export_and_kernel_failures_keep_diagnostics_and_status(self):
        for stage in (0, 1, 2):
            for code in (1, 23, -9, -15):
                with self.subTest(stage=stage, code=code):
                    count = 0
                    def process(command, **kwargs):
                        nonlocal count
                        current, count = count, count + 1
                        if current == stage:
                            return subprocess.CompletedProcess(command, code, b'unsafe promise\n', b'stage failed\n')
                        return self.proof_process(command, **kwargs)
                    with capture_bytes() as (out, err), \
                            mock.patch.object(low_memory.subprocess, 'run', side_effect=process):
                        with self.assertRaises(SystemExit) as raised:
                            low_memory.proof_verdict(self.source, self.env)
                    self.assertEqual(raised.exception.code, code if code > 0 else 128 - code)
                    self.assertEqual(count, stage + 1)
                    self.assertEqual(out.getvalue(), b'unsafe promise\n')
                    self.assertEqual(err.getvalue(), b'stage failed\n')

    def test_noncanonical_precheck_fails_before_export(self):
        for stdout, stderr in ((b'', b''), (VERDICT, b''),
                               (PRECHECK + b'unsafe accepted\n', b''), (PRECHECK, b'warning\n')):
            with self.subTest(stdout=stdout, stderr=stderr):
                with capture_bytes() as (out, err), \
                        mock.patch.object(low_memory.subprocess, 'run',
                                          return_value=subprocess.CompletedProcess([], 0, stdout, stderr)) as run:
                    with self.assertRaisesRegex(RuntimeError, 'precheck output'):
                        low_memory.proof_verdict(self.source, self.env)
                self.assertEqual(run.call_count, 1)
                self.assertEqual((out.getvalue(), err.getvalue()), (stdout, stderr))

    def test_export_scope_diagnostics_are_not_a_successful_verdict(self):
        for stdout, stderr in ((b'scope error\n', b''), (b'', b'scope warning\n')):
            with self.subTest(stdout=stdout, stderr=stderr):
                def process(command, **kwargs):
                    result = self.proof_process(command, **kwargs)
                    if '-o' in command:
                        result.stdout, result.stderr = stdout, stderr
                    return result
                with capture_bytes() as (out, err), \
                        mock.patch.object(low_memory.subprocess, 'run', side_effect=process) as run:
                    with self.assertRaisesRegex(RuntimeError, 'scope diagnostics'):
                        low_memory.proof_verdict(self.source, self.env)
                self.assertEqual(run.call_count, 2)
                self.assertEqual((out.getvalue(), err.getvalue()), (stdout, stderr))

    def test_missing_empty_or_directory_export_never_reaches_kernel(self):
        for artifact_type in ('missing', 'empty', 'directory'):
            with self.subTest(artifact_type=artifact_type):
                def process(command, **kwargs):
                    if '-o' not in command:
                        return self.proof_process(command, **kwargs)
                    artifact = pathlib.Path(command[-1])
                    if artifact_type == 'empty':
                        artifact.touch()
                    elif artifact_type == 'directory':
                        artifact.mkdir()
                    return subprocess.CompletedProcess(command, 0, b'', b'')
                with capture_bytes(), mock.patch.object(low_memory.subprocess, 'run', side_effect=process) as run:
                    with self.assertRaisesRegex(RuntimeError, 'no fresh artifact'):
                        low_memory.proof_verdict(self.source, self.env)
                self.assertEqual(run.call_count, 2)

    def test_malformed_or_noisy_kernel_verdict_is_rejected(self):
        for stdout, stderr in ((b'', b''), (b'SOME PROOFS CHECK\n', b''),
                               (VERDICT * 2, b''), (VERDICT + b'warning\n', b''),
                               (VERDICT, b'warning\n')):
            with self.subTest(stdout=stdout, stderr=stderr):
                def process(command, **kwargs):
                    result = self.proof_process(command, **kwargs)
                    if command[0] == self.env['BENDTT']:
                        result.stdout, result.stderr = stdout, stderr
                    return result
                with capture_bytes() as (out, err), \
                        mock.patch.object(low_memory.subprocess, 'run', side_effect=process):
                    with self.assertRaisesRegex(RuntimeError, 'kernel verdict'):
                        low_memory.proof_verdict(self.source, self.env)
                self.assertEqual((out.getvalue(), err.getvalue()), (stdout, stderr))

    def test_precheck_and_export_use_same_snapshot_after_original_changes(self):
        dependency = self.root / 'dependency.bend'
        dependency.write_text('def value(): 42\n')
        original = 'import Base\nimport ./dependency.bend as D\ndef main(): D.value()\n'
        self.source.write_text(original)
        frozen_paths = []
        def process(command, *, env, capture_output, preexec_fn):
            if command[0] == self.env['BENDTT']:
                return subprocess.CompletedProcess(command, 0, VERDICT, b'')
            frozen = pathlib.Path(command[1])
            frozen_paths.append(frozen)
            self.assertEqual(frozen.read_text(), original)
            self.assertEqual((frozen.parent / dependency.name).read_text(), 'def value(): 42\n')
            if command[-1] == '--check-only':
                self.source.write_text('unsafe changed source\n')
                dependency.write_text('unsafe changed dependency\n')
                return subprocess.CompletedProcess(command, 0, PRECHECK, b'')
            pathlib.Path(command[-1]).write_bytes(b'exported proof')
            return subprocess.CompletedProcess(command, 0, b'', b'')
        with capture_bytes(), mock.patch.object(low_memory.subprocess, 'run', side_effect=process):
            low_memory.proof_verdict(self.source, self.env)
        self.assertEqual(frozen_paths[0], frozen_paths[1])


class SnapshotTests(AdapterCase):
    def test_tab_unicode_and_bom_import_separators_are_not_skipped(self):
        dependency = self.root / 'local.bend'
        dependency.write_text('import Base\ndef value(): 1\n')
        for index, whitespace in enumerate(('\t', '\u00a0', '\u2003', '\ufeff')):
            with self.subTest(whitespace=repr(whitespace)):
                self.source.write_text('import Base\n\ufeffimport' + whitespace + './local.bend as L\n')
                destination = self.root / f'local-{index}'
                low_memory.snapshot_proof(self.source, destination)
                self.assertEqual((destination / 'local.bend').read_bytes(), dependency.read_bytes())
                for kind, name in (('package', 'OtherPackage'), ('absolute', str(dependency))):
                    self.source.write_text('import Base\n\ufeffimport' + whitespace + name + '\n')
                    with self.assertRaisesRegex(RuntimeError, 'Unsupported proof import'):
                        low_memory.snapshot_proof(self.source, self.root / f'{kind}-{index}')

    def test_symlink_entrypoints_and_parent_aliases_are_rejected(self):
        laws = self.root / 'LAWS.bend'
        laws.write_text('import Base\n')
        proof_alias = self.root / 'PROOF.bend'
        proof_alias.symlink_to(self.source)
        parent_alias = self.root / 'parent-alias'
        parent_alias.symlink_to(self.root, target_is_directory=True)
        for index, source in enumerate((proof_alias, parent_alias / self.source.name)):
            with self.subTest(source=source), mock.patch.object(low_memory.subprocess, 'run') as run:
                with self.assertRaisesRegex(RuntimeError, 'Symlink proof entrypoints'):
                    low_memory.proof_verdict(source, self.env)
                run.assert_not_called()

    def test_transitive_alias_imports_cycles_bom_and_exact_bytes(self):
        self.source.write_bytes(b'\xef\xbb\xbfimport Base\nimport ./nested/part.bend as P # comment\n')
        nested = self.root / 'nested'
        nested.mkdir()
        (nested / 'part.bend').write_bytes(b'import ../cycle.bend as C\r\ndef x(): 7\r\n')
        (self.root / 'cycle.bend').write_bytes(b'import ./nested/part.bend as P\n')
        destination = self.root / 'snapshot'
        result = low_memory.snapshot_proof(self.source, destination)
        self.assertEqual(result, destination / self.source.name)
        for path in (self.source, nested / 'part.bend', self.root / 'cycle.bend'):
            copy = destination / path.relative_to(self.root)
            self.assertEqual(copy.read_bytes(), path.read_bytes())
            self.assertFalse(copy.is_symlink())
            self.assertNotEqual(copy.stat().st_ino, path.stat().st_ino)

    def test_unsupported_and_escaping_imports_fail_closed(self):
        outside = self.root.parent / (self.root.name + '-outside.bend')
        outside.write_text('def secret(): 1\n')
        self.addCleanup(outside.unlink)
        alias = self.root / 'escape.bend'
        alias.symlink_to(outside)
        imports = ('OtherPackage', str(outside), '../' + outside.name, './escape.bend',
                   './file.txt', './x.bend unexpected', './x.bend as bad-name')
        for index, name in enumerate(imports):
            with self.subTest(name=name):
                self.source.write_text('import ' + name + '\n')
                with self.assertRaisesRegex(RuntimeError, 'Unsupported proof import|escapes snapshot root'):
                    low_memory.snapshot_proof(self.source, self.root / f'snapshot-{index}')

    def test_missing_import_fails_without_running_compiler(self):
        self.source.write_text('import ./absent.bend as A\n')
        with mock.patch.object(low_memory.subprocess, 'run') as run:
            with self.assertRaises(FileNotFoundError):
                low_memory.proof_verdict(self.source, self.env)
            run.assert_not_called()

    def test_proof_must_include_available_laws(self):
        proof = self.root / 'PROOF.bend'
        proof.write_text('import Base\n')
        (self.root / 'LAWS.bend').write_text('import Base\n')
        with self.assertRaisesRegex(RuntimeError, 'must import ./LAWS.bend'):
            low_memory.snapshot_proof(proof, self.root / 'snapshot')


class DispatchTests(AdapterCase):
    def test_native_and_verdict_dispatch_use_locked_environment(self):
        for args, operation in (([str(self.source), '-o', str(self.output)], 'native_build'),
                                ([str(self.source), '--verdict'], 'proof_verdict')):
            with self.subTest(operation=operation), \
                    mock.patch.object(toolchain, 'selected', return_value='locked') as selected, \
                    mock.patch.object(toolchain, 'environment', return_value=self.env) as environment, \
                    mock.patch.object(low_memory, operation) as action:
                low_memory.main(args)
                selected.assert_called_once_with()
                environment.assert_called_once_with('locked')
                expected = (self.source.resolve(), self.output.absolute(), self.env) if operation == 'native_build' else (self.source.resolve(), self.env)
                action.assert_called_once_with(*expected)

    def test_non_native_lanes_exec_real_bend_with_exact_arguments(self):
        cases = [[str(self.source), '--check-only'], ['version'],
                 [str(self.source), '--', 'solve', 'puzzle with spaces']]
        cases.extend([str(self.source), '-o', str(self.root / ('output file.' + suffix))]
                     for suffix in ('js', 'mjs', 'cjs', 'c', 'bendtt'))
        for args in cases:
            with self.subTest(args=args), \
                    mock.patch.object(toolchain, 'selected', return_value='locked'), \
                    mock.patch.object(toolchain, 'environment', return_value=self.env), \
                    mock.patch.object(low_memory.os, 'execve') as execute:
                low_memory.main(args)
                execute.assert_called_once_with(self.env['BEND'], [self.env['BEND'], *args], self.env)

    def test_unsupported_verdict_and_output_permutations_fail_closed(self):
        for args in (['--verdict', str(self.source)], [str(self.source), '--verdict', '--extra'],
                     [str(self.source), '-o'], [str(self.source), '-o', str(self.output), '--extra'],
                     ['-o', str(self.output), str(self.source)],
                     ['-o', str(self.output) + '.c', str(self.source)]):
            with self.subTest(args=args), \
                    mock.patch.object(toolchain, 'selected', return_value='locked'), \
                    mock.patch.object(toolchain, 'environment', return_value=self.env), \
                    mock.patch.object(low_memory.os, 'execve') as execute:
                with self.assertRaisesRegex(RuntimeError, 'Unsupported low-memory compiler arguments'):
                    low_memory.main(args)
                execute.assert_not_called()

    def test_native_and_proof_dispatch_preserve_lexical_symlink_entrypoint(self):
        alias = self.root / 'PROOF.bend'
        alias.symlink_to(self.source)
        for args, operation in (([str(alias), '-o', str(self.output)], 'native_build'),
                                ([str(alias), '--verdict'], 'proof_verdict')):
            with self.subTest(operation=operation), \
                    mock.patch.object(toolchain, 'selected', return_value='locked'), \
                    mock.patch.object(toolchain, 'environment', return_value=self.env), \
                    mock.patch.object(low_memory, operation) as action:
                low_memory.main(args)
                self.assertEqual(action.call_args.args[0], alias)
                self.assertNotEqual(action.call_args.args[0], alias.resolve())

    def test_future_source_or_version_pin_is_rejected_before_toolchain_selection(self):
        for replacement in ({'source_commit': 'unreviewed commit'}, {'version': '2.0.36'}):
            with self.subTest(replacement=replacement), \
                    mock.patch.dict(toolchain.LOCK['bend'], replacement), \
                    mock.patch.object(toolchain, 'selected') as selected, \
                    mock.patch.object(low_memory.os, 'execve') as execute:
                with self.assertRaisesRegex(RuntimeError, 'reviewed Bend 2.0.35 source pin'):
                    low_memory.main(['version'])
                selected.assert_not_called()
                execute.assert_not_called()

    def test_non_linux_dispatch_fails_before_toolchain_selection(self):
        with mock.patch.object(sys, 'platform', 'darwin'), \
                mock.patch.object(toolchain, 'selected') as selected:
            with self.assertRaisesRegex(RuntimeError, 'requires Linux'):
                low_memory.main(['version'])
            selected.assert_not_called()

    def test_toolchain_failure_prevents_any_dispatch(self):
        with mock.patch.object(toolchain, 'selected', side_effect=RuntimeError('Checksum mismatch')), \
                mock.patch.object(low_memory.os, 'execve') as execute:
            with self.assertRaisesRegex(RuntimeError, 'Checksum mismatch'):
                low_memory.main(['version'])
            execute.assert_not_called()

    def test_environment_ignores_ambient_tool_overrides_even_inside_adapter(self):
        with mock.patch.dict(os.environ, {'BEND': 'untrusted bend', 'CC': 'untrusted clang',
                                        'BENDTT': 'untrusted kernel', 'BEND_LOW_MEMORY': '1'}):
            env = toolchain.environment(toolchain.LOCK['lean']['default_version'])
        paths = toolchain.paths(toolchain.LOCK['lean']['default_version'])
        self.assertEqual(env['BEND'], str(paths['bend']))
        self.assertEqual(env['CC'], str(paths['clang']))
        self.assertEqual(env['BENDTT'], str(paths['kernel']))
        self.assertNotEqual(env['BEND'], str(QA / 'low_memory.py'))

    def test_only_explicit_mode_selects_adapter_and_nested_env_keeps_selection(self):
        version = toolchain.LOCK['lean']['default_version']
        for mode in (None, '0', 'false', '1'):
            with self.subTest(mode=mode), mock.patch.dict(os.environ, {}, clear=True):
                if mode is not None:
                    os.environ['BEND_LOW_MEMORY'] = mode
                for depth in range(3):
                    out = io.StringIO()
                    with mock.patch.object(toolchain, 'selected', return_value=version), \
                            mock.patch.object(sys, 'argv', ['toolchain.py', 'env']), \
                            contextlib.redirect_stdout(out):
                        toolchain.main()
                    exports = dict(shlex.split(line)[1].split('=', 1) for line in out.getvalue().splitlines())
                    expected = QA / 'low_memory.py' if mode == '1' else toolchain.paths(version)['bend']
                    self.assertEqual(exports['BEND'], str(expected), depth)
                    self.assertEqual(exports['CC'], str(toolchain.paths(version)['clang']))
                    os.environ.update(exports)


class IsolationTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix='isolated verification ')
        self.addCleanup(self.tmp.cleanup)
        self.root = pathlib.Path(self.tmp.name) / 'project with spaces'
        self.root.mkdir()
        for name in ('sudoku', 'qa', 'fixtures', 'bin', '.omo/evidence'):
            (self.root / name).mkdir(parents=True)
        self.runner = self.root / 'qa/verify_isolated.py'
        shutil.copy2(QA / 'verify_isolated.py', self.runner)
        (self.root / 'qa/integration-result.json').write_text('historical integration\n')
        (self.root / 'fixtures/known.txt').write_text('historical fixture\n')
        (self.root / '.omo/evidence/historical.json').write_text('historical evidence\n')
        (self.root / 'main.bend').write_text('source\n')
        (self.root / 'bin/stale').write_text('stale executable\n')
        self.tools = pathlib.Path(self.tmp.name) / 'locked tools'
        self.tools.mkdir()
        self.manifest = {'lean_version': 'test', 'files': {'bend': {'sha256': 'test hash'}}}
        (self.tools / 'installed.json').write_text(json.dumps(self.manifest))

    def run_isolated(self, args, *, exit_code=0, ambient=None, benchmark_written=True):
        env = {'BEND_TOOLCHAIN_DIR': str(self.tools), 'BEND_LOW_MEMORY': '1', **(ambient or {})}
        seen = {}
        def fake_gates(command, *, cwd, env, stdout, stderr, text):
            self.assertEqual(command, ['sh', 'qa/verify_gates.sh'])
            self.assertEqual((stdout, stderr, text), (subprocess.PIPE, subprocess.STDOUT, True))
            seen.update(work=pathlib.Path(cwd), env=dict(env))
            self.assertNotEqual(pathlib.Path(cwd), self.root)
            self.assertEqual((pathlib.Path(cwd) / 'main.bend').read_text(), 'source\n')
            self.assertFalse((pathlib.Path(cwd) / 'bin').exists())
            self.assertFalse((pathlib.Path(cwd) / '.omo/evidence/historical.json').exists())
            (pathlib.Path(cwd) / 'qa/integration-result.json').write_text('fresh integration\n')
            (pathlib.Path(cwd) / 'fixtures/known.txt').write_text('modified isolated fixture\n')
            if benchmark_written and env['BEND_SKIP_BENCHMARK'] != '1':
                (pathlib.Path(cwd) / '.omo/evidence/benchmark.json').write_text('{"status": "PASS"}\n')
            process = mock.Mock()
            process.stdout = io.StringIO('gate stdout\ngate stderr\n')
            process.wait.return_value = exit_code
            return process
        with mock.patch.dict(os.environ, env, clear=True), \
                mock.patch.object(sys, 'argv', [str(self.runner), *args]), \
                mock.patch.object(subprocess, 'Popen', side_effect=fake_gates), \
                contextlib.redirect_stdout(io.StringIO()):
            with self.assertRaises(SystemExit) as raised:
                runpy.run_path(str(self.runner), run_name='__main__')
        self.assertEqual(raised.exception.code, exit_code)
        work = seen['work']
        summary = json.loads((work.parent / 'summary.json').read_text())
        self.assertEqual(summary['toolchain'], self.manifest)
        self.assertGreaterEqual(summary['wall_seconds'], 0)
        self.assertEqual(summary['work'], str(work))
        self.assertEqual(pathlib.Path(summary['log']).read_text(), 'gate stdout\ngate stderr\n')
        self.assertEqual((self.root / 'qa/integration-result.json').read_text(), 'historical integration\n')
        self.assertEqual((self.root / 'fixtures/known.txt').read_text(), 'historical fixture\n')
        self.assertEqual((self.root / '.omo/evidence/historical.json').read_text(), 'historical evidence\n')
        return seen, summary

    def test_default_disables_ambient_low_memory_and_includes_benchmark(self):
        seen, summary = self.run_isolated([])
        self.assertEqual(seen['env']['BEND_LOW_MEMORY'], '0')
        self.assertEqual(seen['env']['BEND_SKIP_BENCHMARK'], '0')
        self.assertNotIn('BUN_JSC_forceRAMSize', seen['env'])
        self.assertEqual(summary['execution_mode'], 'default')
        self.assertEqual(summary['benchmark'], 'PASS')
        self.assertEqual(summary['status'], 'PASS')

    def test_low_memory_mode_propagates_to_all_gates_with_gc_hint(self):
        seen, summary = self.run_isolated(['--low-memory'])
        self.assertEqual(seen['env']['BEND_LOW_MEMORY'], '1')
        self.assertEqual(seen['env']['BUN_JSC_forceRAMSize'], '67108864')
        self.assertEqual(seen['env']['BEND_TOOLCHAIN_DIR'], str(self.tools.resolve()))
        self.assertEqual(summary['execution_mode'], 'low-memory')
        self.assertEqual(summary['compiler_gc_hint_bytes'], '67108864')
        self.assertEqual(summary['benchmark'], 'PASS')

    def test_failure_before_benchmark_is_explicitly_not_run(self):
        _, summary = self.run_isolated(['--low-memory'], exit_code=1, benchmark_written=False)
        self.assertEqual(summary['benchmark'], 'NOT RUN (verification stopped before benchmark completed)')
        self.assertEqual(summary['status'], 'FAIL')


    def test_explicit_gc_hint_skip_benchmark_failure_and_repeated_run_isolation(self):
        first, summary = self.run_isolated(['--low-memory', '--skip-benchmark'], exit_code=37,
                                           ambient={'BUN_JSC_forceRAMSize': '12345'})
        self.assertEqual(first['env']['BUN_JSC_forceRAMSize'], '12345')
        self.assertEqual(first['env']['BEND_SKIP_BENCHMARK'], '1')
        self.assertEqual(summary['benchmark'], 'NOT RUN (explicit --skip-benchmark)')
        self.assertEqual((summary['status'], summary['exit_code']), ('FAIL', 37))
        second, _ = self.run_isolated(['--low-memory'])
        self.assertNotEqual(first['work'], second['work'])
        self.assertEqual(json.loads((first['work'].parent / 'summary.json').read_text()), summary)


class GateContractTests(unittest.TestCase):
    def test_all_existing_gate_invocations_remain_unconditional(self):
        source = (QA / 'verify_gates.sh').read_text()
        before_benchmark = source.split('if [ "${BEND_SKIP_BENCHMARK:-0}" != 1 ]; then')[0]
        self.assertNotIn('BEND_LOW_MEMORY', source)
        self.assertNotIn('\nif ', before_benchmark)
        self.assertIn('"$BEND" PROOF.bend --verdict', before_benchmark)
        self.assertIn('"$BEND" qa/run.bend --check-only', before_benchmark)
        self.assertIn('./build.sh', before_benchmark)
        native_sources = ['qa_run.bend', *('qa/' + name + '.bend' for name in (
            'optimization', 'row-bitmap', 'queued-candidates', 'singleton-predicate',
            'bitmap-arithmetic', 'peer-equivalence', 'validation-reason', 'output-tail',
            'orderstat', 'arithmetic', 'rating-cache', 'rating-index', 'rating-array',
            'array-techniques', 'candidate-digits', 'bench-direct', 'fuel_cli'))]
        for name in native_sources:
            self.assertIn('"$BEND" ' + name + ' -o bin/', before_benchmark)
        for name in ('generate_count_table', 'adaptive_trace', 'empty_search_state',
                     'integration', 'rate_reference', 'cli', 'fuel', 'mutation', 'lanes'):
            self.assertIn('python3 qa/' + name + '.py', before_benchmark)
        self.assertIn('"$BEND" main.bend -o bin/bend-sudoku.js', before_benchmark)
        for name in ('adaptive_trace', 'empty_search_state', 'mutation', 'lanes'):
            self.assertIn('BEND="$BEND" python3 qa/' + name + '.py', before_benchmark)
        self.assertIn('python3 qa/benchmark.py', source)

    def test_existing_subprocess_timeouts_are_unchanged(self):
        expected = {'integration.py': [120], 'cli.py': [120], 'fuel.py': [30],
                    'mutation.py': [60, 30, 60], 'lanes.py': [60],
                    'empty_search_state.py': [180, 180], 'benchmark.py': [180, 180],
                    'rate_reference.py': [90]}
        for name, values in expected.items():
            with self.subTest(name=name):
                tree = ast.parse((QA / name).read_text())
                calls = sorted((node for node in ast.walk(tree) if isinstance(node, ast.Call)),
                               key=lambda node: (node.lineno, node.col_offset))
                actual = [keyword.value.value for node in calls for keyword in node.keywords
                          if keyword.arg == 'timeout' and isinstance(keyword.value, ast.Constant)]
                self.assertEqual(actual, values)
        adaptive = (QA / 'adaptive_trace.py').read_text()
        self.assertEqual(adaptive.count('env, 180)'), 3)


if __name__ == '__main__':
    unittest.main()
