#!/usr/bin/env python3
"""Build and validate the direct adaptive/legacy transition oracle.

Standalone: source ./toolchain-env.sh, then BEND="$BEND" python3 qa/adaptive_trace.py
Aggregate gates already holding /tmp/bend-cloud-cpu.lock pass --lock-held.
The inherited 6,060-record golden driver is separate and is never rewritten.
"""
import argparse
import contextlib
import fcntl
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import time
if __package__:
    from .checks import require
else:
    from checks import require

ROOT = Path(__file__).resolve().parents[1]
EXPECTED_NAMES = {
    'easy', 'empty', 'complete', 'contradiction', 'hard', 'hard-ai-escargot',
    'hard-seed-42', 'hard-seed-20261003',
    'hard-ai-escargot-seed-42', 'hard-ai-escargot-seed-20261003',
}
REQUIRED_COMPLETE = {'easy', 'empty', 'complete', 'contradiction'}
LINE = re.compile(
    r'PASS (?P<fixture>\S+) limit=(?P<limit>[12]) '
    r'(?P<outcome>completed|capped-incomplete) '
    r'steps=(?P<steps>\d+) comparisons=(?P<comparisons>\d+) '
    r'forward=(?P<forward>\d+) backward=(?P<backward>\d+) '
    r'active_forward=(?P<active_forward>\d+) '
    r'(?:phase=(?P<phase>[01]) depth=(?P<depth>\d+) )?found=(?P<found>\d+)'
)


def fingerprint():
    files = [ROOT / 'qa/adaptive-trace.bend', ROOT / 'qa/adaptive_trace.py',
             ROOT / 'toolchain.lock.json', *sorted((ROOT / 'sudoku').glob('*.bend'))]
    return {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest()
            for p in files}


def call(command, output, env, timeout):
    started = time.perf_counter()
    result = subprocess.run(command, cwd=ROOT, env=env, capture_output=True,
                            text=True, timeout=timeout)
    elapsed = time.perf_counter() - started
    output.write_text(result.stdout + result.stderr)
    if result.returncode:
        raise RuntimeError(f'{command[0]} failed ({result.returncode}):\n'
                           f'{result.stdout}{result.stderr}')
    return result, elapsed


def transformed(grid, seed):
    state = seed

    def shuffled(items):
        nonlocal state
        values = list(items)
        for i in range(len(values) - 1, 0, -1):
            state = (1664525 * state + 1013904223) & 0xffffffff
            j = state % (i + 1)
            values[i], values[j] = values[j], values[i]
        return values

    digits = [0] + shuffled(range(1, 10))
    rows = [3 * band + row for band in shuffled(range(3))
            for row in shuffled(range(3))]
    columns = [3 * stack + column for stack in shuffled(range(3))
               for column in shuffled(range(3))]
    result = ''.join(str(digits[int(grid[9 * row + column])])
                     for row in rows for column in columns)
    return result, digits, rows, columns


def fixture_manifest():
    source = (ROOT / 'qa/adaptive-trace.bend').read_text()
    matches = re.findall(r'fixture\(budget, "([^"]+)", "([0-9]{81})"\)', source)
    fixtures = dict(matches)
    require(len(matches) == len(fixtures) == 10, 'Expected ten distinct oracle fixtures')
    require(set(fixtures) == EXPECTED_NAMES, 'Unexpected oracle fixture names')
    records = []
    for name, grid in matches:
        record = {'name': name, 'grid': grid}
        if '-seed-' in name:
            base, seed_text = name.rsplit('-seed-', 1)
            seed = int(seed_text)
            expected, digits, rows, columns = transformed(fixtures[base], seed)
            require(expected == grid, f'non-reproducible transformed fixture: {name}')
            record.update(base=base, seed=seed, digit_map=digits,
                          source_rows=rows, source_columns=columns)
        records.append(record)
    return {
        'transformation_method': 'LCG state=(1664525*state+1013904223) modulo 2^32; '
        'descending Fisher-Yates j=state modulo (i+1); digit shuffle, band shuffle, '
        'per-band row shuffle, stack shuffle, per-stack column shuffle in that order. '
        'Maps use zero-based source rows/columns.',
        'fixtures': records,
    }


def parse_output(output, budget):
    records = []
    for line in output.splitlines():
        match = LINE.fullmatch(line)
        require(match, f'unrecognized oracle output: {line!r}')
        row = {key: int(value) if value is not None and key not in ('fixture', 'outcome')
               else value for key, value in match.groupdict().items()}
        require(row['steps'] == row['forward'] + row['backward'], row)
        require(row['comparisons'] == row['steps'] + 1, row)
        require(0 <= row['active_forward'] <= row['forward'], row)
        require(0 <= row['found'] <= row['limit'], row)
        if row['outcome'] == 'capped-incomplete':
            require(row['steps'] == budget, row)
            require(row['fixture'] not in REQUIRED_COMPLETE, row)
        else:
            require(row['steps'] <= budget and row['phase'] is None, row)
            expected_found = 0 if row['fixture'] == 'contradiction' else (
                row['limit'] if row['fixture'] == 'empty' else 1)
            require(row['found'] == expected_found, row)
        records.append({key: value for key, value in row.items() if value is not None})
    require(len(records) == 20, 'Expected twenty oracle records')
    require({(r['fixture'], r['limit']) for r in records} == {
        (name, limit) for name in EXPECTED_NAMES for limit in (1, 2)},
        'Missing oracle fixture and limit combinations')
    require(sum(r['backward'] for r in records) > 1000, 'Insufficient backward steps')
    require(sum(r['active_forward'] for r in records) > 1000, 'Insufficient active forward steps')
    return records


@contextlib.contextmanager
def cpu_lock(already_held):
    if already_held:
        yield
    else:
        with open('/tmp/bend-cloud-cpu.lock', 'a') as lock:
            fcntl.flock(lock, fcntl.LOCK_EX)
            yield


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--budget', type=int, default=200000)
    parser.add_argument('--output', type=Path, default=ROOT / '.omo/evidence/adaptive-trace')
    parser.add_argument('--lock-held', action='store_true',
                        help='caller already holds the shared exclusive CPU lock')
    args = parser.parse_args()
    require(100 <= args.budget <= 10000000, 'budget must be between 100 and 10,000,000')
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    env = dict(os.environ, BEND_NO_TELEMETRY='1')
    bend = env.get('BEND', 'bend')
    binary = ROOT / 'bin/qa-adaptive-trace'
    with cpu_lock(args.lock_held):
        before = fingerprint()
        (output / 'source-hashes-before.json').write_text(json.dumps(before, indent=2) + '\n')
        manifest = fixture_manifest()
        (output / 'fixtures.json').write_text(json.dumps(manifest, indent=2) + '\n')
        checked, check_seconds = call([bend, 'qa/adaptive-trace.bend', '--check-only'],
                                      output / 'check.log', env, 180)
        built, build_seconds = call([bend, 'qa/adaptive-trace.bend', '-o', str(binary)],
                                    output / 'build.log', env, 180)
        actual, run_seconds = call([str(binary), '+RTS', '--threads', '1', '-RTS', str(args.budget)],
                                   output / 'run.log', env, 180)
        after = fingerprint()
        (output / 'source-hashes-after.json').write_text(json.dumps(after, indent=2) + '\n')
        require(before == after, 'sources changed during the oracle build/run')
        require(actual.stderr == '', actual.stderr)
        records = parse_output(actual.stdout, args.budget)
    summary = {
        'status': 'PASS',
        'test': 'direct adaptive versus scalar-selected legacy transition oracle',
        'budget_per_trace': args.budget,
        'trace_count': len(records),
        'completed_traces': sum(r['outcome'] == 'completed' for r in records),
        'capped_incomplete_traces': [r for r in records if r['outcome'] == 'capped-incomplete'],
        'totals': {key: sum(r[key] for r in records) for key in
                   ('steps', 'comparisons', 'forward', 'backward', 'active_forward')},
        'observed_fields': ['phase', 'depth', 'found', 'logical board cells 0..80',
                            'active frame words with only adaptive guess marker bit21 removed',
                            'legacy frame old-value fields equal zero'],
        'adaptive_path': 'F.selection, F.selected, F.backtrack; snapshots remain untouched '
                         'in the live state; cloned working views use F.finish; SnapshotDone '
                         'views are not decoded again',
        'legacy_path': 'S.selected with C.scalar_start(Array.get(board,108)); S.backtrack '
                       'independently restores every placement',
        'counting': 'steps counts actual transitions; comparisons includes the initial '
                    'state and the endpoint after each transition; terminal traces stop '
                    'immediately rather than padding completed states',
        'limitations': ['Finite named fixtures, not an exhaustive proof.',
                        'Snapshot stack contents are not separately inspected; their '
                        'restore behavior is checked by logical board/frame equality '
                        'after every backtracking transition.',
                        'Inherited 6060 golden observations are complementary and '
                        'are not included in these totals.'],
        'source_hashes': before,
        'source_hashes_unchanged': True,
        'output_sha256': hashlib.sha256(actual.stdout.encode()).hexdigest(),
        'timings_seconds': {'check': check_seconds, 'build': build_seconds, 'run': run_seconds},
        'traces': records,
        **manifest,
    }
    (output / 'summary.json').write_text(json.dumps(summary, indent=2) + '\n')
    print(actual.stdout, end='')
    print(json.dumps({key: summary[key] for key in ('status', 'trace_count',
        'completed_traces', 'capped_incomplete_traces', 'totals')}, indent=2))
    print(f'Direct adaptive trace evidence: {output}')


if __name__ == '__main__':
    main()
