#!/usr/bin/env python3
"""Harness regressions using mocks and Python only; never starts a compiler."""
import contextlib
import hashlib
import importlib.util
import io
import json
import os
import pathlib
import subprocess
import sys
import tempfile
import unittest
import types
from unittest import mock


HERE = pathlib.Path(__file__).resolve().parent
SPEC = importlib.util.spec_from_file_location('compiler_20261013_v2037_check_real', HERE / 'check_real.py')
CHECK = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(CHECK)


class HarnessTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix='upgrade harness tests ')
        self.addCleanup(self.temporary.cleanup)
        self.root = pathlib.Path(self.temporary.name)
        self.out = self.root / 'result.json'

    def invoke(self, action):
        with mock.patch.object(CHECK, 'run_checks', side_effect=action), \
                contextlib.redirect_stdout(io.StringIO()), contextlib.redirect_stderr(io.StringIO()):
            code = CHECK.main(['--out', str(self.out)])
        return code, json.loads(self.out.read_text())

    def test_existing_outputs_and_dangling_symlinks_are_refused(self):
        valuable = self.root / 'valuable'
        valuable.write_text('keep me')
        for name, create in (
                ('file', lambda p: p.write_text('keep me')),
                ('directory', lambda p: p.mkdir()),
                ('symlink', lambda p: p.symlink_to(valuable)),
                ('dangling', lambda p: p.symlink_to(self.root / 'absent'))):
            out = self.root / name
            create(out)
            with self.subTest(name=name), mock.patch.object(CHECK, 'run_checks') as run, \
                    contextlib.redirect_stderr(io.StringIO()):
                with self.assertRaises(SystemExit) as caught:
                    CHECK.main(['--out', str(out)])
                self.assertEqual(caught.exception.code, 2)
                run.assert_not_called()
                self.assertTrue(os.path.lexists(out))
                if name == 'file':
                    self.assertEqual(out.read_text(), 'keep me')
            self.assertEqual(valuable.read_text(), 'keep me')

    def test_required_out_is_checked_before_any_work(self):
        with mock.patch.object(CHECK, 'run_checks') as run, contextlib.redirect_stderr(io.StringIO()):
            with self.assertRaises(SystemExit) as caught:
                CHECK.main([])
        self.assertEqual(caught.exception.code, 2)
        run.assert_not_called()

    def test_failure_retains_report_and_work_directory(self):
        def fail(result, checkpoint):
            work = pathlib.Path(result['work'])
            (work / 'failed output').write_text('partial diagnostics')
            CHECK.require(False, 'injected failure')
        code, result = self.invoke(fail)
        self.assertEqual(code, 1)
        self.assertEqual(result['status'], 'FAIL')
        self.assertIn('injected failure', result['error'])
        self.assertEqual((pathlib.Path(result['work']) / 'failed output').read_text(), 'partial diagnostics')

    def test_incomplete_checks_cannot_report_pass(self):
        def incomplete(result, checkpoint):
            result['cases'].append({'case': next(iter(CHECK.EXPECTED_CASES)), 'status': 'PASS'})
        code, result = self.invoke(incomplete)
        self.assertEqual((code, result['status']), (1, 'FAIL'))
        self.assertIn('Not every required check', result['error'])

    def test_every_expected_check_is_required_for_pass(self):
        def passed(result, checkpoint):
            result['cases'].extend({'case': name, 'status': 'PASS'} for name in CHECK.EXPECTED_CASES)
        code, result = self.invoke(passed)
        self.assertEqual((code, result['status']), (0, 'PASS'))
        self.assertEqual(len(result['cases']), 14)

    def test_optimized_python_still_records_a_failed_acceptance_check(self):
        # A Python-only subprocess tests the real -O behavior, with no toolchain import.
        script = (
            'import importlib.util,sys; '
            f's=importlib.util.spec_from_file_location("smoke", {str(HERE / "check_real.py")!r}); '
            'm=importlib.util.module_from_spec(s); s.loader.exec_module(m); '
            'm.run_checks=lambda result, checkpoint: m.require(False, "optimized rejection"); '
            'sys.exit(m.main(sys.argv[1:]))'
        )
        done = subprocess.run([sys.executable, '-O', '-c', script, '--out', str(self.out)],
                              env=dict(os.environ, PYTHONOPTIMIZE='1'), capture_output=True,
                              text=True, timeout=10)
        self.assertEqual(done.returncode, 1, done.stderr)
        result = json.loads(self.out.read_text())
        self.assertEqual((result['status'], result['python_optimization']), ('FAIL', 1))
        self.assertIn('optimized rejection', result['error'])
        self.assertTrue(pathlib.Path(result['work']).is_dir())

    def test_timeout_is_recorded_and_process_group_is_stopped_once(self):
        result = {'cases': []}
        process = mock.Mock(returncode=-9)
        process.communicate.side_effect = [subprocess.TimeoutExpired(['fake'], 60), ('partial', 'diagnostic')]
        checkpoint = mock.Mock()
        with mock.patch.object(CHECK.subprocess, 'Popen', return_value=process) as start, \
                mock.patch.object(CHECK, 'stop_process') as stop:
            with self.assertRaisesRegex(CHECK.CheckFailure, 'timed out after 60'):
                CHECK.Recorder(result, checkpoint).run('fake', ['not a compiler'], {}, self.root)
        stop.assert_called_once_with(process)
        self.assertEqual(start.call_args.kwargs['start_new_session'], os.name == 'posix')
        record = result['cases'][0]
        self.assertEqual(record['status'], 'FAIL')
        self.assertTrue(record['timed_out'])
        self.assertEqual((record['stdout'], record['stderr']), ('partial', 'diagnostic'))
        self.assertGreaterEqual(checkpoint.call_count, 2)

    def test_proof_checks_reject_crashes_unrelated_errors_and_success_noise(self):
        false_error = 'SOME PROOFS FAIL\nError:\n- expected : 0\n- observed : 1\nLocation: wrong\n'
        good = {'exit_code': 1, 'stdout': '', 'stderr': false_error}
        CHECK.check_proof(good, 'false')
        bad = [dict(good, exit_code=-9), dict(good, exit_code=0),
               dict(good, stderr='SOME PROOFS FAIL\nmissing compiler'),
               dict(good, stdout=CHECK.VERDICT),
               dict(good, stderr=false_error.replace('Location: wrong', 'Location: other'))]
        for record in bad:
            with self.subTest(record=record), self.assertRaises(CHECK.CheckFailure):
                CHECK.check_proof(record, 'false')
        CHECK.check_proof({'exit_code': 0, 'stdout': CHECK.VERDICT, 'stderr': ''}, 'valid')
        with self.assertRaises(CHECK.CheckFailure):
            CHECK.check_proof({'exit_code': 0, 'stdout': CHECK.VERDICT, 'stderr': 'warning'}, 'valid')

    def test_unsafe_kind_requires_expected_dependency_diagnostic(self):
        error = 'SOME PROOFS FAIL\nError: 4 defs rely on unsafe or foreign code:\n- D\n- use\n- Zero\n- P\n'
        record = {'exit_code': 1, 'stdout': '', 'stderr': error}
        CHECK.check_proof(record, 'unsafe-kind')
        for altered in (error.replace('- Zero\n', ''), error.replace('4 defs', '1 def'), 'syntax error'):
            with self.subTest(altered=altered), self.assertRaises(CHECK.CheckFailure):
                CHECK.check_proof(dict(record, stderr=altered), 'unsafe-kind')

    def test_reviewed_version_and_source_pair_reaches_toolchain_selection(self):
        fake = types.SimpleNamespace(
            LOCK={'bend': {'version': '2.0.37',
                           'source_commit': '4ff8545f19b09b7d2b8ca2303668100eac8efd66'}},
            selected=mock.Mock(side_effect=CHECK.CheckFailure('selection reached')))
        with mock.patch.dict(sys.modules, {'toolchain': fake}), \
                mock.patch.object(sys, 'platform', 'linux'):
            with self.assertRaisesRegex(CHECK.CheckFailure, 'selection reached'):
                CHECK.run_checks({}, mock.Mock())
        fake.selected.assert_called_once_with()

    def test_old_future_and_mismatched_toolchain_pins_fail_before_selection(self):
        reviewed = '4ff8545f19b09b7d2b8ca2303668100eac8efd66'
        old = 'ae1101ca7d15364f9274fa6b1367d175884a7da7'
        for version, source in (('2.0.36', old), ('2.0.36', reviewed),
                                ('2.0.37', old), ('2.0.37', 'unknown'),
                                ('2.0.38', reviewed), ('2.0.38', 'unknown')):
            fake = types.SimpleNamespace(
                LOCK={'bend': {'version': version, 'source_commit': source}},
                selected=mock.Mock())
            with self.subTest(version=version, source=source), \
                    mock.patch.dict(sys.modules, {'toolchain': fake}), \
                    mock.patch.object(sys, 'platform', 'linux'):
                with self.assertRaisesRegex(CHECK.CheckFailure, 'reviewed Bend 2.0.37'):
                    CHECK.run_checks({}, mock.Mock())
            fake.selected.assert_not_called()

    def test_upstream_fixture_bodies_match_exact_git_blobs(self):
        expected = {'dependent_pair.bend': 'd1c10872b4b938fa6b6570f6b5cd1f738bedddb4',
                    'unsafe_kind.bend': '2a5462e4b50026e7e70e10a180916b2ed9815fa5'}
        for name, sha in expected.items():
            with self.subTest(name=name):
                body = (HERE / 'fixtures' / name).read_bytes().split(b'\n', 3)[3]
                actual = hashlib.sha1(b'blob ' + str(len(body)).encode('ascii') + b'\0' + body).hexdigest()
                self.assertEqual(actual, sha)


if __name__ == '__main__':
    unittest.main()
