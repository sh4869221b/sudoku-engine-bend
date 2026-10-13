#!/usr/bin/env python3
"""Serialized Bend 2.0.36 upgrade smoke checks; run after full verification.

Uses only the Python standard library. The required --out is a new JSON file;
both successful and failed runs retain their report and adjacent work directory.
All acceptance checks remain active with -O or PYTHONOPTIMIZE.
"""
import argparse
import datetime
import hashlib
import json
import os
import pathlib
import re
import signal
import subprocess
import sys
import tempfile
import time


HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parents[1]
SOURCE_COMMIT = 'ae1101ca7d15364f9274fa6b1367d175884a7da7'
VERDICT = 'ALL PROOFS CHECK\n'
BUILD_TIMEOUT = 60
PROOF_CASES = (('valid proof.bend', 'valid'), ('false proof.bend', 'false'),
               ('unsafe_kind.bend', 'unsafe-kind'), ('dependent_pair.bend', 'valid'))
EXPECTED_CASES = {
    *(f'{name}: {lane} verdict' for name, _ in PROOF_CASES for lane in ('ordinary', 'low-memory')),
    *(f'tiny native {action}: {lane}' for action in ('build', 'run') for lane in ('ordinary', 'low-memory')),
    'byte-identical ordinary and low-memory native binaries',
    'existing adapter native output remains protected',
}


class CheckFailure(RuntimeError):
    """An explicit acceptance failure, including under optimized Python."""


def require(condition, message):
    if not condition:
        raise CheckFailure(message)


def sha256(path):
    digest = hashlib.sha256()
    with path.open('rb') as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(chunk)
    return digest.hexdigest()


def utc_now():
    return datetime.datetime.now(datetime.timezone.utc).isoformat()


def stop_process(process):
    # Kill the whole new process group: integrated Bend may have spawned Clang.
    # A timed-out compiler must not continue alongside the next verification.
    try:
        if os.name == 'posix':
            os.killpg(process.pid, signal.SIGKILL)
        else:
            process.kill()
    except ProcessLookupError:
        pass


class Recorder:
    def __init__(self, result, checkpoint):
        self.result = result
        self.checkpoint = checkpoint

    def run(self, case, command, env, work, timeout=BUILD_TIMEOUT):
        record = {'case': case, 'command': [str(x) for x in command],
                  'timeout_seconds': timeout, 'status': 'RUNNING'}
        self.result['cases'].append(record)
        self.checkpoint()
        start = time.monotonic()
        process = None
        try:
            process = subprocess.Popen(record['command'], cwd=work, env=env,
                                       stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                                       text=True, encoding='utf-8', errors='replace',
                                       start_new_session=(os.name == 'posix'))
            try:
                stdout, stderr = process.communicate(timeout=timeout)
            except subprocess.TimeoutExpired:
                stop_process(process)
                stdout, stderr = process.communicate()
                record.update(exit_code=process.returncode, stdout=stdout, stderr=stderr,
                              timed_out=True)
                raise CheckFailure(f'{case}: timed out after {timeout} seconds')
            record.update(exit_code=process.returncode, stdout=stdout, stderr=stderr,
                          timed_out=False, status='AWAITING_CHECK')
        except BaseException as exc:
            if process is not None and not record.get('timed_out'):
                stop_process(process)
                stdout, stderr = process.communicate()
                record.update(exit_code=process.returncode, stdout=stdout, stderr=stderr)
            record.update(status='FAIL', error=f'{type(exc).__name__}: {exc}')
            raise
        finally:
            record['wall_seconds'] = round(time.monotonic() - start, 6)
            self.checkpoint()
        return record

    def accept(self, record, check):
        try:
            check()
        except BaseException as exc:
            record.update(status='FAIL', error=f'{type(exc).__name__}: {exc}')
            raise
        else:
            record['status'] = 'PASS'
        finally:
            self.checkpoint()


def check_proof(record, expected):
    out, err = record['stdout'], record['stderr']
    if expected == 'valid':
        require(record['exit_code'] == 0, 'Valid proof failed')
        require(out == VERDICT and err == '', 'Unexpected successful proof verdict')
        return
    require(record['exit_code'] == 1, 'Rejection must be a normal compiler failure, not a crash')
    diagnostic = out + '\n' + err
    require('ALL PROOFS CHECK' not in diagnostic, 'Rejected proof printed a success verdict')
    require('SOME PROOFS FAIL' in diagnostic, 'Missing proof failure diagnostic')
    if expected == 'false':
        require(re.search(r'(?m)^- expected\s*:\s*0\s*$', diagnostic) is not None
                and re.search(r'(?m)^- observed\s*:\s*1\s*$', diagnostic) is not None,
                'False equality did not fail for the expected 0/1 mismatch')
        require('Location: wrong' in diagnostic, 'False equality failed at an unexpected location')
    elif expected == 'unsafe-kind':
        require('Error: 4 defs rely on unsafe or foreign code:' in diagnostic,
                'Missing datatype-kind unsafe dependency diagnostic')
        names = set(re.findall(r'(?m)^- (D|use|Zero|P)\s*$', diagnostic))
        require(names == {'D', 'use', 'Zero', 'P'}, 'Unsafe datatype-kind dependency list differs')
    else:
        raise CheckFailure(f'Unknown proof expectation: {expected}')


def check_build(record, binary):
    require(record['exit_code'] == 0, 'Native compilation failed')
    require(record['stdout'] == '' and record['stderr'] == '', 'Unexpected native build diagnostics')
    require(binary.is_file() and os.access(binary, os.X_OK), 'No fresh executable was produced')


def check_native_run(record):
    require(record['exit_code'] == 0, 'Tiny native program failed')
    require(record['stdout'] == '42\n' and record['stderr'] == '', 'Tiny native output differs')


def run_checks(result, checkpoint):
    require(sys.platform == 'linux', 'The locked toolchain and low-memory adapter require Linux')
    sys.path.insert(0, str(ROOT / 'qa'))
    import toolchain

    require(toolchain.LOCK['bend']['version'] == '2.0.36'
            and toolchain.LOCK['bend']['source_commit'] == SOURCE_COMMIT,
            'This upgrade harness requires the reviewed Bend 2.0.36 source/version pair')
    version = toolchain.selected()
    env = toolchain.environment(version)
    env.update(BUN_JSC_forceRAMSize='67108864', BEND_LOW_MEMORY='0')
    result['toolchain'] = {'bend': dict(toolchain.LOCK['bend']), 'lean_version': version,
                           'clang_version': toolchain.LOCK['clang']['version'],
                           'installed': json.loads((toolchain.TOOLS / 'installed.json').read_text())}
    result['compiler_gc_hint_bytes'] = env['BUN_JSC_forceRAMSize']
    result['compiler_gc_hint_is_memory_limit'] = False
    work = pathlib.Path(result['work'])
    fixtures = work / 'proof fixtures'
    fixtures.mkdir()
    texts = {
        'valid proof.bend': 'import Base\ndef same() -> {0 == 0 : U32}:\n  {==}\n',
        'false proof.bend': 'import Base\ndef wrong() -> {0 == 1 : U32}:\n  {==}\n',
        'native source.bend': 'import Base\ndef main() -> U32:\n  42\n',
    }
    for name, content in texts.items():
        with (fixtures / name).open('x', encoding='utf-8') as stream:
            stream.write(content)
    for name in ('unsafe_kind.bend', 'dependent_pair.bend'):
        with (fixtures / name).open('xb') as stream:
            stream.write((HERE / 'fixtures' / name).read_bytes())
    with (fixtures / 'UPSTREAM-LICENSE').open('xb') as stream:
        stream.write((HERE / 'UPSTREAM-LICENSE').read_bytes())
    result['fixtures'] = {path.name: sha256(path) for path in sorted(fixtures.iterdir())}
    checkpoint()
    recorder = Recorder(result, checkpoint)
    compilers = [('ordinary', [env['BEND']], env),
                 ('low-memory', [sys.executable, str(ROOT / 'qa/low_memory.py')],
                  dict(env, BEND_LOW_MEMORY='1'))]
    for name, expected in PROOF_CASES:
        for lane, compiler, lane_env in compilers:
            record = recorder.run(f'{name}: {lane} verdict',
                                  [*compiler, fixtures / name, '--verdict'], lane_env, work)
            record['expected'] = expected
            recorder.accept(record, lambda: check_proof(record, expected))

    binaries, hashes = {}, {}
    for lane, compiler, lane_env in compilers:
        directory = work / (lane + ' native')
        directory.mkdir()
        binary = directory / 'tiny native'
        require(not os.path.lexists(binary), 'Refusing to overwrite a native output')
        record = recorder.run(f'tiny native build: {lane}',
                              [*compiler, fixtures / 'native source.bend', '-o', binary], lane_env, work)
        recorder.accept(record, lambda: check_build(record, binary))
        run = recorder.run(f'tiny native run: {lane}', [binary], lane_env, work, timeout=10)
        recorder.accept(run, lambda: check_native_run(run))
        binaries[lane], hashes[lane] = binary, sha256(binary)
    result['native_sha256'] = hashes
    comparison = {'case': 'byte-identical ordinary and low-memory native binaries',
                  'status': 'AWAITING_CHECK', 'sha256': hashes}
    result['cases'].append(comparison)
    recorder.accept(comparison, lambda: require(hashes['ordinary'] == hashes['low-memory'],
                                                'Native binary hashes differ'))

    # Deliberately repeat only the adapter build; ordinary Bend may overwrite outputs.
    lane, compiler, lane_env = compilers[1]
    binary = binaries[lane]
    before = binary.read_bytes()
    record = recorder.run('existing adapter native output remains protected',
                          [*compiler, fixtures / 'native source.bend', '-o', binary], lane_env, work)

    def check_protected():
        require(record['exit_code'] == 1, 'Existing-output refusal did not exit normally with failure')
        require('Refusing to overwrite existing native output:' in record['stderr'],
                'Existing-output refusal has the wrong diagnostic')
        require(binary.read_bytes() == before, 'Existing native output was modified')
    recorder.accept(record, check_protected)


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', required=True, type=pathlib.Path,
                        help='New result JSON path; existing files, directories and symlinks are refused')
    args = parser.parse_args(argv)
    out = pathlib.Path(os.path.abspath(args.out))
    try:
        # Exclusive creation also refuses dangling symlinks and closes the check/create race.
        stream = out.open('x', encoding='utf-8')
    except OSError as exc:
        parser.error(f'Cannot create fresh result file {out}: {exc}')
    result = {'schema_version': 1, 'status': 'RUNNING', 'started_at_utc': utc_now(),
              'source_commit': SOURCE_COMMIT, 'python_optimization': sys.flags.optimize,
              'cases': []}

    def checkpoint():
        stream.seek(0)
        json.dump(result, stream, indent=2, ensure_ascii=False)
        stream.write('\n')
        stream.truncate()
        stream.flush()
        os.fsync(stream.fileno())

    exit_code = 1
    with stream:
        try:
            checkpoint()
            result['work'] = tempfile.mkdtemp(prefix=out.stem + '-work-', dir=out.parent)
            checkpoint()
            run_checks(result, checkpoint)
            require(len(result['cases']) == len(EXPECTED_CASES)
                    and {case['case'] for case in result['cases']} == EXPECTED_CASES
                    and all(case['status'] == 'PASS' for case in result['cases']),
                    'Not every required check completed successfully')
            result['status'] = 'PASS'
            exit_code = 0
        except BaseException as exc:
            result.update(status='FAIL', error=f'{type(exc).__name__}: {exc}')
        finally:
            result['finished_at_utc'] = utc_now()
            checkpoint()
    print(f"{result['status']}: {out}")
    if 'work' in result:
        print(f"Retained work: {result['work']}")
    if 'error' in result:
        print(result['error'], file=sys.stderr)
    return exit_code


if __name__ == '__main__':
    raise SystemExit(main())
