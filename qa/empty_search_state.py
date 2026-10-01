#!/usr/bin/env python3
"""Exact native search-state/fuel differential against an explicit Bend baseline.

Usage: BEND=bend python3 qa/empty_search_state.py [PATH_TO_BEND_BASELINE]
With no argument, check against the committed golden observation hash. Supplying
an explicit baseline additionally compiles the same driver against that source
and requires exact byte equality. The golden is never rewritten by this script.
No timing claims are made.
"""
import difflib
import gzip
import hashlib
import json
import os
import pathlib
import subprocess
import sys
import tempfile

root = pathlib.Path(__file__).resolve().parents[1]
baseline = pathlib.Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else None
golden = json.loads((root / 'qa/empty-search-state-golden.json').read_text())
source = (root / 'qa/empty-search-state.bend').read_text()
bend = os.environ.get('BEND', 'bend')
env = dict(os.environ, BEND_NO_TELEMETRY='1')
evidence = root / '.omo/evidence'
evidence.mkdir(parents=True, exist_ok=True)
outputs = {}
with tempfile.TemporaryDirectory(prefix='empty-state-', dir=root / 'qa') as td:
    work = pathlib.Path(td)
    targets = ([('baseline', baseline)] if baseline else []) + [('candidate', root)]
    for name, directory in targets:
        relative = os.path.relpath(directory / 'sudoku', work)
        driver = work / f'{name}.bend'
        driver.write_text(source.replace('../sudoku/', relative + '/'))
        binary = work / name
        built = subprocess.run([bend, str(driver), '-o', str(binary)], env=env,
                               capture_output=True, text=True, timeout=180)
        if built.returncode:
            raise RuntimeError(f'{name} build failed\n{built.stdout}\n{built.stderr}')
        actual = subprocess.run([str(binary), '--threads', '1'], env=env,
                                capture_output=True, text=True, timeout=180)
        if actual.returncode:
            raise RuntimeError(f'{name} execution failed\n{actual.stderr}')
        assert actual.stderr == '', (name, actual.stderr)
        outputs[name] = actual.stdout
        (evidence / f'empty-search-state-{name}.txt.gz').write_bytes(
            gzip.compress(actual.stdout.encode(), mtime=0))
        print(f'{name}: {len(actual.stdout.splitlines())} state/fuel observations', flush=True)
if baseline and outputs['baseline'] != outputs['candidate']:
    print(''.join(difflib.unified_diff(outputs['baseline'].splitlines(True),
                                     outputs['candidate'].splitlines(True),
                                     fromfile='baseline', tofile='candidate')))
    raise SystemExit('FAIL exact native search-state differential')
actual_hash = hashlib.sha256(outputs['candidate'].encode()).hexdigest()
if actual_hash != golden['sha256']:
    raise SystemExit(f"FAIL golden search-state hash: {actual_hash} != {golden['sha256']}")
lines = outputs['candidate'].splitlines()
assert len(lines) == golden['observations'], 'golden observation count mismatch'
summary = {
    'status': 'PASS',
    'observations': len(lines),
    'sha256': actual_hash,
    'golden_baseline_commit': golden['baseline_commit'],
    'verification': 'baseline byte equality and golden hash' if baseline else 'committed baseline golden hash',
    'baseline': str(baseline) if baseline else None,
    'candidate': str(root),
    'limits': [1, 2],
    'all_fuel_0_through_300': ['easy', 'empty', 'contradiction', 'complete', 'hard'],
    'hard_additional_fuels': [500, 1000, 2000, 5000, 10000, 20000, 50000, 100000, 199999, 200000],
    'observed_fields': ['state tag', 'depth', 'found', 'board cells 0..80', 'active frame words'],
    'production_runs': sum(' run ' in line for line in lines),
    'direct_transition_states': sum(' trace ' in line for line in lines),
    'searching_states': sum(' searching ' in line for line in lines),
    'backtracking_states': sum(' backtracking ' in line for line in lines),
    'completed_states': sum(' done ' in line for line in lines),
    'fuel_exhaustion_states': sum(line.endswith(' fuel') for line in lines),
}
(evidence / 'empty-search-state.json').write_text(json.dumps(summary, indent=2) + '\n')
print(json.dumps(summary, indent=2))
