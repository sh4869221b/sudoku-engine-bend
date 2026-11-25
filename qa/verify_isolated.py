#!/usr/bin/env python3
"""Run the existing gates in a fresh copy without replacing historical results."""
import argparse
import datetime
import json
import os
import pathlib
import shutil
import subprocess
import sys
import tempfile
import time

ROOT = pathlib.Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--skip-benchmark', action='store_true',
                    help='Run all correctness/proof/lane gates; omit timing measurement')
parser.add_argument('--low-memory', action='store_true',
                    help='Release Bend before Clang/kernel; keep every gate and timeout')
parser.add_argument('--group', choices=('all', 'proof', 'core', 'arithmetic', 'rating', 'mutation', 'engine'),
                    default='all', help='Run an independent CI group in an isolated source copy')
args = parser.parse_args()
if args.group != 'all' and not args.skip_benchmark:
    parser.error('--group requires --skip-benchmark')
results = ROOT / '.verification'
results.mkdir(exist_ok=True)
stamp = datetime.datetime.now(datetime.timezone.utc).strftime('%Y%m%dT%H%M%SZ-')
run = pathlib.Path(tempfile.mkdtemp(prefix=stamp, dir=results))
work = run / 'work'
work.mkdir()
for name in ('sudoku', 'qa', 'fixtures'):
    shutil.copytree(ROOT / name, work / name, ignore=shutil.ignore_patterns('__pycache__'))
for path in ROOT.iterdir():
    if path.is_file():
        shutil.copy2(path, work / path.name)
(work / '.omo/evidence').mkdir(parents=True)
env = dict(os.environ)
# An absolute installation path survives the isolated source-tree copy.
env['BEND_TOOLCHAIN_DIR'] = str(pathlib.Path(env['BEND_TOOLCHAIN_DIR']).resolve())
env['BEND_LOW_MEMORY'] = '1' if args.low_memory else '0'
# GC scheduling hint complements process separation; this is NOT a memory cap.
if args.low_memory:
    env.setdefault('BUN_JSC_forceRAMSize', '67108864')
env['BEND_SKIP_BENCHMARK'] = '1' if args.skip_benchmark else '0'
started = time.monotonic()
mode = 'low-memory' if args.low_memory else 'default'
print(f'Verification mode: {mode}', flush=True)
print(f'Verification group: {args.group}', flush=True)
command = ['sh', 'qa/verify_gates.sh']
if args.group != 'all':
    command.append(args.group)
print(f'Verification results: {run}', flush=True)
with (run / 'verify.log').open('w') as log:
    process = subprocess.Popen(command, cwd=work, env=env,
                               stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    for line in process.stdout:
        print(line, end='', flush=True)
        log.write(line)
        log.flush()
    code = process.wait()
manifest = json.loads((pathlib.Path(env['BEND_TOOLCHAIN_DIR']) / 'installed.json').read_text())
benchmark_file = work / '.omo/evidence/benchmark.json'
benchmark = ('NOT RUN (explicit --skip-benchmark)' if args.skip_benchmark
             else 'NOT RUN (verification stopped before benchmark completed)')
if not args.skip_benchmark and benchmark_file.exists():
    benchmark = json.loads(benchmark_file.read_text()).get('status', 'UNKNOWN')
summary = {'status': 'PASS' if code == 0 else 'FAIL', 'exit_code': code,
           'execution_mode': mode, 'group': args.group,
           'wall_seconds': round(time.monotonic() - started, 3),
           'compiler_gc_hint_bytes': env.get('BUN_JSC_forceRAMSize'),
           'benchmark': benchmark,
           'toolchain': manifest, 'work': str(work), 'log': str(run / 'verify.log')}
(run / 'summary.json').write_text(json.dumps(summary, indent=2) + '\n')
print(f'Verification {summary["status"]}: {run}', flush=True)
sys.exit(code)
