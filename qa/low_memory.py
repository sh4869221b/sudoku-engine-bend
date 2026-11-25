#!/usr/bin/env python3
"""Project-only sequential compiler adapter for verify.sh --low-memory.

Pinned upstream semantics: bend2/main.ts and safe.ts at the source_commit in
our lockfile. This deliberately supports only the project's Linux CPU build
calls, not the complete Bend CLI. Other ordinary calls execute Bend unchanged.
"""
import ctypes
import os
import signal
import pathlib
import re
import shutil
import subprocess
import sys
import tempfile
import time

if __package__:
    from . import toolchain
else:
    sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
    import toolchain

# Re-review upstream CLI/kernel semantics before supporting another release.
# 2.0.40 forces GC before Clang, but retains its
# process and checked book. Separate processes still bound peak overlap.
# In 2.0.40, explicit BENDTT still bypasses the automatic kernel build's
# Lean 4.34.0 check. The selected kernel must be rebuilt from this release.
SUPPORTED_SOURCE = '624dd9f4607cd29b0871a9b96d413bfb11e92f52'
LIBC = ctypes.CDLL(None, use_errno=True)  # Load before fork, not in preexec_fn.


def die_with_parent(parent_pid):
    # Linux-only adapter: Python timeout kills this wrapper with SIGKILL.
    # Do not leave the currently running Bend/Clang/kernel behind. Install
    # before exec, then close the race where the parent died before prctl.
    if LIBC.prctl(1, signal.SIGKILL, 0, 0, 0) != 0:  # PR_SET_PDEATHSIG
        raise OSError(ctypes.get_errno(), 'PR_SET_PDEATHSIG failed')
    if os.getppid() != parent_pid:
        os.kill(os.getpid(), signal.SIGKILL)


def run(command, env, *, quiet=False):
    # Always relay failures, including captured export/kernel diagnostics.
    parent_pid = os.getpid()
    result = subprocess.run([str(x) for x in command], env=env, capture_output=quiet,
                            preexec_fn=lambda: die_with_parent(parent_pid))
    if quiet and result.returncode:
        sys.stdout.buffer.write(result.stdout)
        sys.stderr.buffer.write(result.stderr)
    if result.returncode:
        raise SystemExit(result.returncode if result.returncode > 0 else 128 - result.returncode)
    return result


def run_phase(label, command, env, *, quiet=False):
    if env.get('BEND_PHASE_TIMINGS') != '1':
        return run(command, env, quiet=quiet)
    started = time.monotonic()
    print(f'[bend phase] START {label}', file=sys.stderr, flush=True)
    try:
        return run(command, env, quiet=quiet)
    finally:
        print(f'[bend phase] END {label}: {time.monotonic() - started:.2f}s',
              file=sys.stderr, flush=True)


def require_fresh_output(output):
    # Stronger than upstream's input/directory guard. In isolated verification
    # every native output is fresh; refusing ALL existing paths also protects
    # imported inputs, foreign files, hardlinks and dangling symlinks.
    if os.path.lexists(output):
        raise RuntimeError(f'Refusing to overwrite existing native output: {output}')
    if not output.parent.is_dir():
        raise RuntimeError(f'Native output directory does not exist: {output.parent}')


def snapshot_proof(source, destination):
    """Freeze the local import closure before either elaboration pass.

    Accept only Base and relative .bend imports contained in the entry's
    directory. Unsupported packages/absolute imports fail closed. Copy bytes,
    never symlink, so precheck and export cannot observe different sources.
    """
    if source.absolute() != source.resolve():
        raise RuntimeError('Symlink proof entrypoints are unsupported in low-memory mode')
    root = source.parent.resolve()
    pending = [source.resolve()]
    seen = set()
    while pending:
        path = pending.pop()
        if path in seen:
            continue
        if not path.is_relative_to(root):
            raise RuntimeError(f'Proof import escapes snapshot root: {path}')
        seen.add(path)
        data = path.read_bytes()
        target = destination / path.relative_to(root)
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(data)
        for line in data.decode('utf-8-sig').splitlines():
            # JavaScript trim/\s also treats BOM as whitespace; Python does not.
            line = line.replace('\ufeff', ' ').strip()
            if not re.match(r'import(?:\s|$)', line):
                continue
            match = re.fullmatch(r'import\s+(\S+)(?:\s+as\s+[A-Za-z_][A-Za-z0-9_]*)?\s*(?:#.*)?', line)
            if not match:
                raise RuntimeError(f'Unsupported proof import: {line}')
            name = match[1]
            if name == 'Base':
                continue
            if not name.startswith(('./', '../')) or not name.endswith('.bend'):
                raise RuntimeError(f'Unsupported proof import: {name}')
            pending.append((path.parent / name).resolve())
    # Preserve upstream's special PROOF.bend/LAWS.bend import requirement.
    laws = root / 'LAWS.bend'
    if source.name == 'PROOF.bend' and laws.exists() and laws.resolve() not in seen:
        raise RuntimeError('PROOF.bend must import ./LAWS.bend')
    return destination / source.name


def proof_verdict(source, env):
    with tempfile.TemporaryDirectory(prefix='bend-low-memory-proof-') as td:
        tmp = pathlib.Path(td)
        frozen = snapshot_proof(source, tmp / 'source')
        # This rejects unsafe and foreign promises, which export alone does not.
        checked = run_phase('proof precheck', [env['BEND'], frozen, '--check-only'], env, quiet=True)
        # Do not print the precheck's success line as a kernel verdict.
        if checked.stdout.strip() != b'ALL PROOFS CHECK\nUse --verdict for mathematical validity.' or checked.stderr:
            sys.stdout.buffer.write(checked.stdout)
            sys.stderr.buffer.write(checked.stderr)
            raise RuntimeError('Unexpected proof precheck output')
        proof = tmp / 'in.bendtt'
        exported = run_phase('BendTT export', [env['BEND'], frozen, '-o', proof], env, quiet=True)
        if exported.stdout or exported.stderr:
            sys.stdout.buffer.write(exported.stdout)
            sys.stderr.buffer.write(exported.stderr)
            raise RuntimeError('Refusing proof export with scope diagnostics')
        if not proof.is_file() or not proof.stat().st_size:
            raise RuntimeError('Proof export produced no fresh artifact')
        kernel = run_phase('BendTT kernel', [env['BENDTT'], proof], dict(env, LEAN_STACK_SIZE_KB='4194304'), quiet=True)
        if kernel.stdout.strip() != b'ALL PROOFS CHECK' or kernel.stderr:
            sys.stdout.buffer.write(kernel.stdout)
            sys.stderr.buffer.write(kernel.stderr)
            raise RuntimeError('Unexpected proof kernel verdict')
        sys.stdout.buffer.write(kernel.stdout)


def native_build(source, output, env):
    require_fresh_output(output)
    # Keep the basename used by upstream; Clang can record it in the binary.
    with tempfile.TemporaryDirectory(prefix='bend-low-memory-native-') as td:
        tmp = pathlib.Path(td)
        c_file = tmp / (output.name + '.c')
        run_phase('C emission', [env['BEND'], source, '-o', c_file], env)
        c = c_file.read_text()
        if sys.platform != 'linux' or not re.search(r'^#define BANGS\s+0$', c, re.M) or '#include <X11/' in c or '#include <alsa/' in c:
            raise RuntimeError('Low-memory mode supports only Linux CPU builds without X11/ALSA')
        binary = tmp / 'compiled'
        run_phase('Clang', [env['CC'], '-std=c11', '-O3', c_file, '-lpthread', '-lm', '-o', binary], env)
        if not binary.is_file() or not os.access(binary, os.X_OK):
            raise RuntimeError('Clang produced no fresh executable')
        # Exclusive creation prevents overwriting a path created during build.
        # Copy only after successful compilation; remove partial copy on error.
        stream = output.open('xb')
        try:
            with stream:
                with binary.open('rb') as src:
                    shutil.copyfileobj(src, stream)
                stream.flush()
                os.fchmod(stream.fileno(), binary.stat().st_mode & 0o777)
        except BaseException:
            output.unlink(missing_ok=True)
            raise


def main(args=None):
    args = sys.argv[1:] if args is None else args
    if sys.platform != 'linux':
        raise RuntimeError('Low-memory mode requires Linux')
    # Never trust ambient BEND/CC/BENDTT, including direct adapter invocation.
    if toolchain.LOCK['bend']['source_commit'] != SUPPORTED_SOURCE or toolchain.LOCK['bend']['version'] != '2.0.40':
        raise RuntimeError('Low-memory adapter requires the reviewed Bend 2.0.40 source pin')
    env = toolchain.environment(toolchain.selected())
    if len(args) == 2 and args[1] == '--verdict':
        proof_verdict(pathlib.Path(args[0]).absolute(), env)
    elif len(args) == 3 and args[1] == '-o' and not re.search(r'\.(?:mjs|c?js|c|bendtt)$', args[2]):
        native_build(pathlib.Path(args[0]).absolute(), pathlib.Path(os.path.abspath(args[2])), env)
    else:
        # Unsupported output/verdict permutations must not silently lose the
        # low-memory guarantee; check-only, JS/C export and run lanes remain real Bend.
        if '--verdict' in args or ('-o' in args and not (len(args) == 3 and args[1] == '-o'
                and re.search(r'\.(?:mjs|c?js|c|bendtt)$', args[2]))):
            raise RuntimeError('Unsupported low-memory compiler arguments')
        os.execve(env['BEND'], [env['BEND'], *args], env)


if __name__ == '__main__':
    try:
        main()
    except (OSError, ValueError, RuntimeError, subprocess.SubprocessError) as exc:
        print(f'Low-memory compiler error: {exc}', file=sys.stderr)
        sys.exit(1)
