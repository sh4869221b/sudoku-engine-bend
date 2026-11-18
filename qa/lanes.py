#!/usr/bin/env python3
"""Check CLI contracts across native, Bend and Node execution."""
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile

if __package__:
    from .checks import bench_timing, require
else:
    sys.path.insert(0, str(Path(__file__).resolve().parent))
    from checks import bench_timing, require

ROOT = Path(__file__).resolve().parents[1]
BEND = os.environ.get('BEND', 'bend')
SOLVED = '534678912672195348198342567859761423426853791713924856961537284287419635345286179'
LARGE_N = 10_000
CHECKER_VERDICTS = ('ALL PROOFS CHECK', 'Use --verdict for mathematical validity.')


def run_case(checks, lane, prefix, args, expected=None, *, bench_n=None, code=0, stderr=''):
    result = subprocess.run(prefix + args, capture_output=True, text=True,
                            timeout=60, env=dict(os.environ, BEND_NO_TELEMETRY='1'))
    require(result.returncode == code,
            (lane, args, 'unexpected exit code', result.returncode, result.stdout, result.stderr))
    require(result.stderr == stderr, (lane, args, 'unexpected stderr', result.stderr, stderr))
    # The Bend checker can emit a verdict before running the program.
    stdout = result.stdout
    if lane == 'bend':
        stdout = ''.join(line for line in stdout.splitlines(keepends=True)
                         if line.removesuffix('\n') not in CHECKER_VERDICTS)
    if expected is not None:
        out = stdout.removesuffix('\n')
        require(out == expected, (lane, args, 'unexpected stdout', out[:200], expected[:200]))
    if bench_n is not None:
        bench_timing(stdout, result.stderr, expected_n=bench_n)
    checks.append({'lane': lane, 'command': args[0], 'exit': result.returncode,
                   'stdout': result.stdout, 'stderr': result.stderr})


def main():
    checks = []
    lanes = {
        'bend': [BEND, str(ROOT / 'main.bend'), '--'],
        'js': ['node', str(ROOT / 'bin/bend-sudoku.js')],
        'native': [str(ROOT / 'bin/bend-sudoku'), '+RTS', '--threads', '1', '-RTS'],
    }
    with tempfile.TemporaryDirectory() as td:
        one = Path(td) / 'one.txt'
        one.write_text(SOLVED + '\n')
        cases = [
            (['solve', SOLVED], SOLVED), (['check', SOLVED], 'valid'),
            (['count', SOLVED], '1'), (['generate', '--seed', '42', '--clues', '81'], None),
            (['rate', SOLVED], 'Difficulty: Easy\nMax technique: None\nSteps: 0\nScore: 0'),
            (['batch', str(one), 'count'], '1 count:1'),
        ]
        for lane, prefix in lanes.items():
            for args, expected in cases:
                run_case(checks, lane, prefix, args, expected)
            run_case(checks, lane, prefix, ['bench', str(one)], bench_n=1)

        large = Path(td) / 'large.txt'
        large.write_text('# comment\r\n\r\n' + (SOLVED + '\r\n') * (LARGE_N - 1) + SOLVED)
        counts = '\n'.join(f'{index} count:1' for index in range(3, LARGE_N + 3))
        for lane in ('native', 'js'):
            prefix = lanes[lane]
            run_case(checks, lane, prefix, ['batch', str(large), 'count'], counts)
            run_case(checks, lane, prefix, ['bench', str(large)], bench_n=LARGE_N)
            run_case(checks, lane, prefix, ['bench', '--generate', str(LARGE_N)], bench_n=LARGE_N)

        count_probe = {
            'native': [str(ROOT / 'bin/qa-bench-count'), '+RTS', '--threads', '1', '-RTS'],
            'js': ['node', str(ROOT / 'bin/qa-bench-count.js')],
        }
        for lane, prefix in count_probe.items():
            run_case(checks, lane, prefix, ['bench-count'], '', code=4,
                     stderr='benchmark failed: solved=1 failed=0 expected=10000\n')

    (ROOT / '.omo/evidence/lanes.json').write_text(
        json.dumps({'status': 'PASS', 'checks': checks}, indent=2))
    print('PASS all 7 commands in native, Bend and Node lanes,'
          ' including 10,000-job native and Node regressions')


if __name__ == '__main__':
    main()
