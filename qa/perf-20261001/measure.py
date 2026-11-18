#!/usr/bin/env python3
"""Serial randomized paired end-to-end CLI samples with child-specific usage."""
import sys
from pathlib import Path as _Path
sys.path.insert(0, str(_Path(__file__).resolve().parents[1]))
from runtime_args import native_command
from checks import require

import argparse, gzip, hashlib, json, os, pathlib, platform, random, re, statistics, subprocess, tempfile, time
p=argparse.ArgumentParser();p.add_argument('--base',required=True);p.add_argument('--candidate',required=True);p.add_argument('--cases',required=True);p.add_argument('--corpora',default='.');p.add_argument('--out',required=True);p.add_argument('--reps',type=int,default=9);a=p.parse_args()
cases=json.loads(pathlib.Path(a.cases).read_text().replace('@CORPORA@',str(pathlib.Path(a.corpora).resolve()))); bins={'baseline':str(pathlib.Path(a.base).resolve()),'candidate':str(pathlib.Path(a.candidate).resolve())};raw=[];rng=random.Random(20261001);expected={}
out=pathlib.Path(a.out);out.parent.mkdir(parents=True,exist_ok=True)
def run(binary,args,threads):
 with tempfile.TemporaryFile() as stdout,tempfile.TemporaryFile() as stderr:
  started=time.perf_counter_ns(); child=subprocess.Popen(native_command(binary, threads, args),stdout=stdout,stderr=stderr,env=dict(os.environ,BEND_NO_TELEMETRY='1'))
  _,status,usage=os.wait4(child.pid,0);child.returncode=os.waitstatus_to_exitcode(status);wall=(time.perf_counter_ns()-started)/1e6
  stdout.seek(0);stderr.seek(0);so=stdout.read();se=stderr.read()
  normalized=re.sub(rb'total_ms=\d+ per_ms=\S+',b'total_ms=<time> per_ms=<time>',so) if args[0]=='bench' else so
  internal=re.search(rb'total_ms=(\d+)',so) if args[0]=='bench' else None
  return dict(wall_ms=wall,user_ms=usage.ru_utime*1000,system_ms=usage.ru_stime*1000,max_rss_kib=usage.ru_maxrss,exit=child.returncode,stdout_sha256=hashlib.sha256(so).hexdigest(),stdout_normalized_sha256=hashlib.sha256(normalized).hexdigest(),stderr_sha256=hashlib.sha256(se).hexdigest(),stdout_bytes=len(so),stderr_bytes=len(se),internal_ms=int(internal[1]) if internal else None)
for case in cases:
 for rep in range(a.reps+2):
  order=list(bins);rng.shuffle(order)
  for label in order:
   r=run(bins[label],case['args'],case.get('threads',1));r.update(case=case['name'],threads=case.get('threads',1),engine=label,rep=rep,warmup=rep<2)
   sig=tuple(r[k] for k in ['exit','stdout_normalized_sha256','stderr_sha256']);key=case['name']
   if key in expected:
    require(expected[key]==sig, ('paired output mismatch', case,r,expected[key]))
   else:expected[key]=sig
   raw.append(r)
 with gzip.open(str(out)+'.raw.json.gz','wt') as f:json.dump(raw,f)
 print('DONE',case['name'],flush=True)
summary=[]
for c in cases:
 row={'case':c['name'],'threads':c.get('threads',1)}
 for engine in bins:
  rs=[r for r in raw if r['case']==c['name'] and r['engine']==engine and not r['warmup']];stats={}
  for k in ['wall_ms','user_ms','system_ms','max_rss_kib']:
   xs=[r[k] for r in rs];q=statistics.quantiles(xs,n=4);stats[k]={'median':statistics.median(xs),'p25':q[0],'p75':q[2],'min':min(xs),'max':max(xs)}
  row[engine]=stats
 row['speedup']=row['baseline']['wall_ms']['median']/row['candidate']['wall_ms']['median'];summary.append(row)
meta={'legacy_runtime_binary':os.environ.get('BEND_LEGACY_BINARY'),'BENDRTS':os.environ.get('BENDRTS'),'platform':platform.platform(),'cpu':next(x.split(':',1)[1].strip() for x in pathlib.Path('/proc/cpuinfo').read_text().splitlines() if x.startswith('model name')),'affinity':sorted(os.sched_getaffinity(0)),'cpus':os.cpu_count(),'warmups':2,'repetitions':a.reps,'order':'seed20261001 randomized per repetition; serial processes','binaries':{k:{'path':v,'sha256':hashlib.sha256(pathlib.Path(v).read_bytes()).hexdigest()} for k,v in bins.items()},'cases':cases,'clock':'perf_counter_ns; wait4 child user/system CPU and peak RSS; fresh process including parsing/output; bench internal recorded separately'}
out.write_text(json.dumps({'metadata':meta,'summary':summary},indent=2)+'\n');print(json.dumps(summary,indent=2))
