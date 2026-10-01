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

ROOT = pathlib.Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--skip-benchmark', action='store_true',
                    help='Run all correctness/proof/lane gates; omit timing measurement')
args = parser.parse_args()
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
env['BEND_SKIP_BENCHMARK'] = '1' if args.skip_benchmark else '0'
print(f'Verification results: {run}', flush=True)
with (run / 'verify.log').open('w') as log:
    process = subprocess.Popen(['sh', 'qa/verify_gates.sh'], cwd=work, env=env,
                               stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    for line in process.stdout:
        print(line, end='', flush=True)
        log.write(line)
        log.flush()
    code = process.wait()
manifest = json.loads((pathlib.Path(env['BEND_TOOLCHAIN_DIR']) / 'installed.json').read_text())
summary = {'status': 'PASS' if code == 0 else 'FAIL', 'exit_code': code,
           'benchmark': 'NOT RUN (explicit --skip-benchmark)' if args.skip_benchmark else 'included',
           'toolchain': manifest, 'work': str(work), 'log': str(run / 'verify.log')}
(run / 'summary.json').write_text(json.dumps(summary, indent=2) + '\n')
print(f'Verification {summary["status"]}: {run}', flush=True)
sys.exit(code)
