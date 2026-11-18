#!/usr/bin/env python3
"""Fixed-corpus native CPU scaling; warm-up + 3 measured repetitions per size/thread."""
import subprocess,pathlib,tempfile,hashlib,json,statistics,re,os,platform,time
from checks import require
ROOT=pathlib.Path(__file__).resolve().parents[1];BIN=ROOT/'bin/bend-sudoku';start=time.monotonic()
gen=subprocess.run([str(BIN),'+RTS','--threads','1','-RTS','generate','--seed','1','--count','10000','--clues','36'],capture_output=True,text=True,check=True,timeout=180)
lines=gen.stdout.splitlines()
require(len(lines)==10000 and all(re.fullmatch('[0-9]{81}',x) for x in lines),
        ('expected 10000 valid corpus rows', len(lines)))
records=[]
with tempfile.TemporaryDirectory() as td:
 files={}
 for n in (1,10,100,1000,10000):
  p=pathlib.Path(td)/f'{n}.txt';p.write_text('\n'.join(lines[:n])+'\n');files[n]=p
 for threads in (1,8,16):
  for n in (1,10,100,1000,10000):
   if n==10000 and records[-1].get('median_ms',0)>60000:
    records.append({'threads':threads,'N':n,'status':'skipped','reason':'N1000 median exceeded60000ms'});continue
   samples=[]
   for rep in range(4):
    p=subprocess.run([str(BIN),'+RTS','--threads',str(threads),'-RTS','bench',str(files[n])],capture_output=True,text=True,timeout=180)
    require(p.returncode==0, (threads,n,p.returncode,p.stderr))
    m=re.fullmatch(r'N=(\d+) mode=cpu threads=runtime total_ms=(\d+) per_ms=([0-9.e+-]+)\n',p.stdout)
    require(m and int(m[1])==n, (threads,n,p.stdout))
    if rep:samples.append(int(m[2]))
   records.append({'threads':threads,'N':n,'status':'success','raw_ms':samples,'median_ms':statistics.median(samples),'corpus_sha256':hashlib.sha256(files[n].read_bytes()).hexdigest()})
model='unavailable'
try:model=next(x.split(':',1)[1].strip() for x in pathlib.Path('/proc/cpuinfo').read_text().splitlines() if x.startswith('model name'))
except (OSError,StopIteration):pass
out={'status':'PASS','execution_mode':'low-memory' if os.environ.get('BEND_LOW_MEMORY')=='1' else 'default','compiler_gc_hint_bytes':os.environ.get('BUN_JSC_forceRAMSize'),'Bend':json.loads((ROOT/'toolchain.lock.json').read_text())['bend']['version'],'Clang':json.loads((ROOT/'toolchain.lock.json').read_text())['clang']['version'],'toolchain_metadata_source':'project lock; binary identity recorded separately where available','cpu':model,'machine':platform.machine(),'logical_cpus':os.cpu_count(),'solve_fuel':200000,'digging_fuel':20000,'corpus':{'seed_start':1,'count':10000,'clues':36,'symmetry':False,'minimal':False,'sha256':hashlib.sha256(gen.stdout.encode()).hexdigest(),'stderr':gen.stderr},'timed_scope':'batch solve plus result validation and original-clue preservation; corpus preparation and tree construction excluded','warmup':1,'repetitions':3,'records':records,'wall_seconds':round(time.monotonic()-start,3)}
(ROOT/'.omo/evidence/benchmark.json').write_text(json.dumps(out,indent=2));print(json.dumps({'status':'PASS','records':len(records),'wall_seconds':out['wall_seconds']}))
