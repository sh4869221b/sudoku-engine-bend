#!/usr/bin/env python3
"""Frozen-baseline physical-line/packed-input compatibility fuzz."""
import sys
from pathlib import Path as _Path
sys.path.insert(0, str(_Path(__file__).resolve().parents[1]))
from runtime_args import native_command

import argparse,gzip,hashlib,json,pathlib,random,subprocess,tempfile
p=argparse.ArgumentParser();p.add_argument('--base',required=True);p.add_argument('--candidate',required=True);p.add_argument('--out',required=True);a=p.parse_args();rng=random.Random(20261003);records=[]
def run(binary,args,threads):
 r=subprocess.run(native_command(binary, threads, args),capture_output=True,timeout=120)
 return (r.returncode,r.stdout,r.stderr)
def check(args,threads):
 lhs=run(a.base,args,threads);rhs=run(a.candidate,args,threads)
 assert lhs==rhs,(args,threads,lhs,rhs)
 records.append(dict(args=args,threads=threads,exit=rhs[0],stdout=rhs[1].decode(errors='replace'),stderr=rhs[2].decode(errors='replace')))
sol=b'534678912672195348198342567859761423426853791713924856961537284287419635345286179'
lines=[b'',b'\r',b'\r\r',b'#',b'#comment',b' #',sol,b'.'*81,b'x'+b'0'*80,b'0'*80,b'0'*82,b'\0'+b'0'*80,b'\xff'+b'0'*80,'０'.encode()+b'0'*80,'\ufeff#'.encode(),sol+b'\r',sol+b'\r\r']
for n in range(131):
 for ending in [b'',b'\r',b'\r\r',b'\t',b' ']:lines.append(b'0'*n+ending)
for n in range(256):
 row=bytes(rng.choice(b'0123456789.x #\t\r\0') for _ in range(rng.randrange(131)))
 lines.append(row)
with tempfile.TemporaryDirectory() as td:
 file=pathlib.Path(td)/'lines.txt'
 for ending in [b'',b'\n',b'\r\n']:
  shuffled=lines[:];rng.shuffle(shuffled);data=b'\n'.join(shuffled)+ending;file.write_bytes(data)
  for threads in [1,8,16]:
   for mode in ['solve','check','count','rate']:check(['batch',str(file),mode],threads)
   check(['bench',str(file)],threads)
 for data in [b'',b'\n'*100,b'\r\n'*100,b'#comment\n'*100,b'x'*100000,sol+b'\n'+sol+b'\r\n',b'\r'*1000+b'\n'+sol]:
  file.write_bytes(data)
  for threads in [1,8,16]:
   for mode in ['solve','check','count','rate']:check(['batch',str(file),mode],threads)
# BENCH valid timings have varying output and are covered by the main1931 comparator.
out=pathlib.Path(a.out);out.parent.mkdir(parents=True,exist_ok=True)
with gzip.open(str(out)+'.raw.json.gz','wt') as f:json.dump(records,f)
out.write_text(json.dumps(dict(status='PASS',comparisons=len(records),random_and_edge_lines=len(lines),scope='exact physical LF/CRLF/EOF, indices, skip rules, length/character/unit error precedence, threads1/8/16, NUL/invalid byte/Unicode',base_sha256=hashlib.sha256(pathlib.Path(a.base).read_bytes()).hexdigest(),candidate_sha256=hashlib.sha256(pathlib.Path(a.candidate).read_bytes()).hexdigest()),indent=2)+'\n');print(out.read_text())
