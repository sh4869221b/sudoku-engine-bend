#!/usr/bin/env python3
"""Exact frozen-baseline CLI compatibility and independent solved-grid checks."""
import sys
from pathlib import Path as _Path
sys.path.insert(0, str(_Path(__file__).resolve().parents[1]))
from runtime_args import native_command
from checks import normalized_bench, require

import argparse,gzip,hashlib,importlib.util,json,pathlib,random,subprocess,tempfile
p=argparse.ArgumentParser();p.add_argument('--base',required=True);p.add_argument('--candidate',required=True);p.add_argument('--repo',required=True);p.add_argument('--corpora',required=True);p.add_argument('--out',required=True);a=p.parse_args();records=[]
base=pathlib.Path(a.base).resolve();candidate=pathlib.Path(a.candidate).resolve();repo=pathlib.Path(a.repo).resolve();corpora=pathlib.Path(a.corpora).resolve()
spec=importlib.util.spec_from_file_location('rating_reference',repo/'qa/rate_reference.py');ref=importlib.util.module_from_spec(spec);spec.loader.exec_module(ref)
def run(binary,args,threads=1):
 r=subprocess.run(native_command(binary, threads, args),capture_output=True,timeout=120)
 return r.returncode,r.stdout,r.stderr
def check(args,threads=1):
 results=[run(b,args,threads) for b in [base,candidate]]
 def norm(r):
  # This upgrade intentionally changes exactly one help sentence for Bend's
  # new runtime ABI. All other bytes and exit codes remain exact comparisons.
  old=b'Runtime flags --threads N precede --; use -- before application arguments if needed.'
  new=b'Runtime flags use +RTS --threads N -RTS before application arguments.'
  code,stdout,stderr=r
  if args and args[0]=='bench' and code==0:
   expected_n=int(args[2]) if len(args)==3 and args[1]=='--generate' else None
   stdout,_=normalized_bench(stdout,stderr,expected_n=expected_n)
  return code,stdout.replace(old,new),stderr.replace(old,new)
 require(norm(results[0])==norm(results[1]), ('CLI differential mismatch', args, threads, results))
 r=results[1];records.append({'args':args,'threads':threads,'exit':r[0],'stdout':r[1].decode(errors='replace'),'stderr':r[2].decode(errors='replace')});return r
def valid_solution(puzzle,solution):
 require(len(solution)==81 and set(solution)<=set('123456789'), solution)
 require(all(x in '0.' or x==y for x,y in zip(puzzle,solution)), ('solution changed clues', puzzle, solution))
 for unit in ref.UNITS:
  require({solution[i] for i in unit}==set('123456789'), ('invalid solution unit', unit, solution))
puzzles=[]
for file in ['verification.txt','rate-300.txt','hard-100.txt']:
 for line in (corpora/file).read_text().splitlines():
  if len(line)==81 and set(line)<=set('0123456789.') and line not in puzzles:puzzles.append(line)
for s in puzzles:
 for command in ['check','solve','count','rate']:
  code,out,err=check([command,s])
  if command=='solve' and code==0:valid_solution(s,out.decode().strip())
  if command=='rate' and code==0:
   expected=ref.reference(s.replace('.','0'))
   got=dict(line.split(': ',1) for line in out.decode().strip().splitlines())
   require(int(got['Steps'])==expected['steps'] and int(got['Score'])==expected['score'] and got['Max technique']==['None','NakedSingle','HiddenSingle','LockedCandidates','NakedPair'][expected['tech']], (s,got,expected))
for seed in [0,1,7,42,4294967294,4294967295]:
 for opts in [['--count','3','--clues','36'],['--count','2','--clues','32','--symmetry'],['--minimal'],['--minimal','--symmetry'],['--clues','0'],['--clues','81']]:
  code,out,err=check(['generate','--seed',str(seed),*opts])
  require(code==0, ('generation failed', seed, opts, code, err))
  for s in out.decode().splitlines():
   solved=check(['solve',s])
   require(solved[0]==0, ('generated puzzle could not be solved', s, solved))
   valid_solution(s,solved[1].decode().strip())
   require(check(['count',s])[1]==b'1\n', ('generated puzzle must have one solution', s))
for cmd in ['solve','count','check','rate']:
 for s in ['', '0'*80,'0'*82,'x'+'0'*80,'０'+'0'*80,'0'*40+' '+'0'*40,'1'*81]:check([cmd,s])
with tempfile.TemporaryDirectory() as td:
 file=pathlib.Path(td)/'lines.txt';sol='534678912672195348198342567859761423426853791713924856961537284287419635345286179'
 samples=[b'',b'\n',b'\r\n',b'# comment\n',b'# comment\r\n\n',sol.encode(),(sol+'\r\n\n#skip\n'+sol+'\n').encode(),(' '+sol+'\n'+sol+'\r\r\n').encode(),b'\x00\n'+sol.encode()+b'\n',b'\xff\n',b'x'*(16*1024*1024+1)]
 for data in samples:
  file.write_bytes(data)
  for threads in [1,8,16]:
   for cmd in ['solve','check','count','rate']:check(['batch',str(file),cmd],threads)
  check(['bench',str(file)])
 for threads in [1,8,16]:
  for name in ['verification.txt','rate-300.txt','mixed-1000.txt']:
   for cmd in ['solve','check','count','rate']:check(['batch',str(corpora/name),cmd],threads)
 for n in [0,1,7,8,9,15,16,17,31,32,33,127,128,129]:
  file.write_text((sol+'\n')*n)
  for threads in [1,8,16]:
   for cmd in ['solve','check','count','rate']:check(['batch',str(file),cmd],threads)
  check(['bench',str(file)])
for args in [[],['bogus'],['solve'],['generate','--seed','4294967296'],['generate','--clues','32','--minimal'],['batch'],['bench','--generate','3']]:check(args)
for n in [1,10,100]:check(['bench','--generate',str(n)])
out=pathlib.Path(a.out);out.parent.mkdir(parents=True,exist_ok=True)
with gzip.open(str(out)+'.raw.json.gz','wt') as f:json.dump(records,f)
out.write_text(json.dumps({'status':'PASS','comparisons':len(records),'distinct_puzzles':len(puzzles),'scope':'all7 CLI commands, exact stdout/stderr/exit except bench timing and the reviewed runtime-help sentence, seeds/boundaries, threads1/8/16 ordered batch, independent solved-grid validation and rating oracle','base_sha256':hashlib.sha256(base.read_bytes()).hexdigest(),'candidate_sha256':hashlib.sha256(candidate.read_bytes()).hexdigest()},indent=2)+'\n');print(out.read_text())
