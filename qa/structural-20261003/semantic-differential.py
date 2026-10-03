#!/usr/bin/env python3
"""Diagnostic only: allow alternative individual multiple solutions. Batch output comparison remains exact; this rejected-candidate diagnostic is not an acceptance gate."""
import argparse,gzip,hashlib,importlib.util,json,pathlib,random,re,subprocess,tempfile
p=argparse.ArgumentParser();p.add_argument('--base',required=True);p.add_argument('--candidate',required=True);p.add_argument('--repo',required=True);p.add_argument('--corpora',required=True);p.add_argument('--out',required=True);a=p.parse_args();records=[]
base=pathlib.Path(a.base).resolve();candidate=pathlib.Path(a.candidate).resolve();repo=pathlib.Path(a.repo).resolve();corpora=pathlib.Path(a.corpora).resolve()
spec=importlib.util.spec_from_file_location('rating_reference',repo/'qa/rate_reference.py');ref=importlib.util.module_from_spec(spec);spec.loader.exec_module(ref)
def run(binary,args,threads=1):
 r=subprocess.run([str(binary),'--threads',str(threads),'--',*args],capture_output=True,timeout=120)
 return r.returncode,r.stdout,r.stderr
def check(args,threads=1):
 results=[run(b,args,threads) for b in [base,candidate]]
 def norm(r):return (r[0],re.sub(rb'total_ms=\d+ per_ms=\S+',b'total_ms=<time> per_ms=<time>',r[1]),r[2]) if args and args[0]=='bench' else r
 if norm(results[0])!=norm(results[1]):
  assert args[0]=='solve' and results[0][0]==results[1][0]==0, (args,threads,results)
  assert run(base,['count',args[1]])[1]==b'2\n', (args,results)
  valid_solution(args[1],results[0][1].decode().strip());valid_solution(args[1],results[1][1].decode().strip())
 r=results[1];records.append({'args':args,'threads':threads,'exit':r[0],'stdout':r[1].decode(errors='replace'),'stderr':r[2].decode(errors='replace')});return r
def valid_solution(puzzle,solution):
 assert len(solution)==81 and set(solution)<=set('123456789'),solution
 assert all(x in '0.' or x==y for x,y in zip(puzzle,solution))
 for unit in ref.UNITS:assert {solution[i] for i in unit}==set('123456789')
puzzles=[]
for file in ['verification.txt','rate-300.txt','hard-100.txt']:
 for line in (corpora/file).read_text().splitlines():
  if len(line)==81 and set(line)<=set('0123456789.') and line not in puzzles:puzzles.append(line)
for s in puzzles:
 for command in ['check','solve','count','rate']:
  code,out,err=check([command,s])
  if command=='solve' and code==0:valid_solution(s,out.decode().strip())
  if command=='rate' and code==0:
   expected=ref.reference(s.replace('.','0'));got=dict(line.split(': ',1) for line in out.decode().strip().splitlines());assert int(got['Steps'])==expected['steps'] and int(got['Score'])==expected['score'] and got['Max technique']==['None','NakedSingle','HiddenSingle','LockedCandidates','NakedPair'][expected['tech']],(s,got,expected)
for seed in [0,1,7,42,4294967294,4294967295]:
 for opts in [['--count','3','--clues','36'],['--count','2','--clues','32','--symmetry'],['--minimal'],['--minimal','--symmetry'],['--clues','0'],['--clues','81']]:
  code,out,err=check(['generate','--seed',str(seed),*opts]);assert code==0
  for s in out.decode().splitlines():
   solved=check(['solve',s]);assert solved[0]==0;valid_solution(s,solved[1].decode().strip());assert check(['count',s])[1]==b'1\n'
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
out.write_text(json.dumps({'status':'PASS','comparisons':len(records),'distinct_puzzles':len(puzzles),'scope':'all7 CLI commands, exact stdout/stderr/exit except bench timing, seeds/boundaries, threads1/8/16 ordered batch, independent solved-grid validation and rating oracle','base_sha256':hashlib.sha256(base.read_bytes()).hexdigest(),'candidate_sha256':hashlib.sha256(candidate.read_bytes()).hexdigest()},indent=2)+'\n');print(out.read_text())
