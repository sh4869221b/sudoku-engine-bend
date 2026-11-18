#!/usr/bin/env python3
"""Old/new output regression for the 2.0.35 CPU scheduler at odd thread counts."""
import sys
from pathlib import Path as _Path
sys.path.insert(0, str(_Path(__file__).resolve().parents[1]))
from runtime_args import native_command
from checks import require

import argparse
import hashlib
import json
import pathlib
import re
import subprocess
import tempfile

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--base', type=pathlib.Path, required=True)
p.add_argument('--candidate', type=pathlib.Path, required=True)
p.add_argument('--corpora', type=pathlib.Path, required=True)
p.add_argument('--out', type=pathlib.Path, required=True)
a = p.parse_args()
lines = (a.corpora / 'mixed-1000.txt').read_bytes().splitlines()
require(len(lines) >= 257, 'Scheduling comparison requires at least 257 corpus rows')
records = []
with tempfile.TemporaryDirectory() as td:
    batch = pathlib.Path(td) / 'mixed.txt'
    for size in (127, 128, 129, 255, 256, 257):
        batch.write_bytes(b'\n'.join(lines[:size]) + b'\n')
        for threads in (3, 5):
            for command in ('solve', 'check', 'count', 'rate', 'bench'):
                args = ['bench', str(batch)] if command == 'bench' else ['batch', str(batch), command]
                results = []
                for binary in (a.base, a.candidate):
                    r = subprocess.run(native_command(binary, threads, args),
                                       capture_output=True, timeout=120)
                    stdout = re.sub(rb'total_ms=\d+ per_ms=\S+', b'total_ms=<time> per_ms=<time>', r.stdout) if command == 'bench' else r.stdout
                    results.append((r.returncode, stdout, r.stderr))
                require(results[0] == results[1], ('scheduler comparison mismatch', size, threads, command, results))
                require(results[1][0] == 0, (size, threads, command, results[1]))
                records.append({'size': size, 'threads': threads, 'command': command,
                                'stdout_normalized_sha256': hashlib.sha256(results[1][1]).hexdigest()})
out = {'status': 'PASS', 'comparisons': len(records), 'records': records,
       'binaries': {label: hashlib.sha256(path.read_bytes()).hexdigest()
                    for label, path in [('base', a.base), ('candidate', a.candidate)]}}
a.out.write_text(json.dumps(out, indent=2) + '\n')
print(json.dumps({'status': 'PASS', 'comparisons': len(records)}))
