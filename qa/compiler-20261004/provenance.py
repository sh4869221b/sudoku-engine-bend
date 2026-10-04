#!/usr/bin/env python3
"""Freeze comparison inputs and preserve evidence on success or failure."""
import argparse
import datetime
import hashlib
import json
import os
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
CORPUS_LINES = {
    'easy-10000.txt': 10000,
    'mixed-1000.txt': 1000,
    'rate-300.txt': 300,
    'hard-100.txt': 100,
    'verification.txt': 56,
}
PIPELINE = (
    'build.sh', 'verify.sh', 'toolchain-env.sh', 'toolchain.lock.json',
    'qa/verify_gates.sh', 'qa/perf-20261001/cases.json',
    'qa/perf-20261001/corpus-manifest.json',
    'qa/perf-20261001/differential.py', 'qa/perf-20261001/measure.py',
    'qa/perf-20261001/measure_memory.c', 'qa/perf-20261003/analyze.py',
    'qa/deadline-20261003/file_differential.py',
    'qa/deadline-20261003/combine_measurements.py',
    'qa/cloud-20261003/randomized_correctness.py',
    'qa/cloud-20261003/results/randomized-accepted54.json.cases.json',
    'qa/cloud-20261003/memory.py', 'qa/cloud-20261003/paired_case_ci.py',
    'qa/compiler-20261004/compare.sh', 'qa/compiler-20261004/scheduling.py',
    'qa/compiler-20261004/provenance.py',
)


def stamp():
    return datetime.datetime.now(datetime.timezone.utc).isoformat()


def digest(path):
    h = hashlib.sha256()
    with path.open('rb') as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b''):
            h.update(chunk)
    return h.hexdigest()


def require(condition, message):
    if not condition:
        raise ValueError(message)


def snapshot(inputs):
    corpora = pathlib.Path(inputs['corpora'])
    manifest_path = ROOT / 'qa/perf-20261001/corpus-manifest.json'
    manifest = json.loads(manifest_path.read_text())
    entries = manifest['files']
    require(len(entries) == 5 and {x['file'] for x in entries} == set(CORPUS_LINES),
            'The frozen corpus manifest must contain exactly the five expected files')
    corpus_files = {}
    for entry in entries:
        path = corpora / entry['file']
        data = path.read_bytes()
        info = {'sha256': hashlib.sha256(data).hexdigest(), 'bytes': len(data),
                'physical_lines': data.count(b'\n') + int(bool(data) and not data.endswith(b'\n'))}
        require(info['sha256'] == entry['sha256'], f'Corpus hash changed: {path}')
        require(info['bytes'] == entry['bytes'], f'Corpus byte count changed: {path}')
        require(info['physical_lines'] == CORPUS_LINES[entry['file']],
                f'Corpus line count changed: {path}')
        corpus_files[entry['file']] = info
    cases_path = ROOT / 'qa/perf-20261001/cases.json'
    cases = json.loads(cases_path.read_text())
    require(len(cases) == 35 and len({x['name'] for x in cases}) == 35,
            'Expected exactly 35 unique fixed measurement cases')
    for case in cases:
        for arg in case['args']:
            if '@CORPORA@' in arg:
                require(pathlib.Path(arg.replace('@CORPORA@', str(corpora))).is_file(),
                        f'Missing measurement input: {arg}')
    production = sorted(ROOT.glob('*.bend')) + sorted((ROOT / 'sudoku').rglob('*.bend'))
    require(all((ROOT / name) in production for name in ('main.bend', 'LAWS.bend', 'PROOF.bend')),
            'Required production/proof sources are missing')
    validation = {ROOT / name for name in PIPELINE}
    validation.update((ROOT / 'qa').glob('*.py'))
    validation.update((ROOT / 'qa').glob('*.bend'))
    validation.update(path for path in (ROOT / 'fixtures').rglob('*') if path.is_file())
    binaries = {}
    for label in ('base', 'candidate'):
        path = pathlib.Path(inputs[label])
        require(path.is_file() and os.access(path, os.X_OK), f'Not an executable file: {path}')
        binaries[label] = {'path': str(path), 'sha256': digest(path), 'bytes': path.stat().st_size}
    return {
        'binaries': binaries,
        'corpus_manifest_sha256': digest(manifest_path), 'corpus_files': corpus_files,
        'fixed_cases': {'count': len(cases), 'sha256': digest(cases_path)},
        'production_proof_sha256': {str(path.relative_to(ROOT)): digest(path) for path in production},
        'validation_input_sha256': {str(path.relative_to(ROOT)): digest(path) for path in sorted(validation)},
    }


def save(path, state):
    temporary = path.with_name(path.name + '.partial')
    temporary.write_text(json.dumps(state, indent=2) + '\n')
    temporary.replace(path)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('stage', choices=('preflight', 'postflight'))
    parser.add_argument('--base', type=pathlib.Path)
    parser.add_argument('--candidate', type=pathlib.Path)
    parser.add_argument('--corpora', type=pathlib.Path)
    parser.add_argument('--out', type=pathlib.Path, required=True)
    parser.add_argument('--exit-code', type=int, default=0)
    args = parser.parse_args()
    out = args.out.resolve()
    if args.stage == 'preflight':
        require(all((args.base, args.candidate, args.corpora)), 'Preflight requires both binaries and corpora')
        require(out.parent.is_dir() and not any(out.parent.iterdir()), 'Output directory must still be empty')
        inputs = {name: str(getattr(args, name).resolve()) for name in ('base', 'candidate', 'corpora')}
        state = {'status': 'RUNNING', 'started_utc': stamp(), 'inputs': inputs,
                 'scope': 'Input stability only; full new-compiler verification and same-source build provenance are separate prerequisites.'}
        save(out, state)
        try:
            state['before'] = snapshot(inputs)
        except Exception as exc:
            state.update(status='FAIL', finished_utc=stamp(), error=str(exc))
            save(out, state)
            raise
        save(out, state)
        print('PASS comparison input preflight', flush=True)
        return 0
    state = json.loads(out.read_text())
    require(state['status'] == 'RUNNING', 'Provenance is not an unfinished comparison')
    errors = []
    try:
        state['after'] = snapshot(state['inputs'])
        if state['after'] != state['before']:
            errors.append('Comparison inputs changed between preflight and postflight')
    except Exception as exc:
        errors.append(str(exc))
    if args.exit_code:
        errors.append(f'Comparison command failed with exit {args.exit_code}; retain all existing artifacts')
    state.update(status='FAIL' if errors else 'PASS', finished_utc=stamp(),
                 comparison_exit_code=args.exit_code, errors=errors)
    save(out, state)
    print(f'{state["status"]} comparison input postflight', flush=True)
    return 1 if errors else 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, ValueError, KeyError, TypeError) as exc:
        print(f'Provenance error: {exc}', file=sys.stderr)
        sys.exit(1)
