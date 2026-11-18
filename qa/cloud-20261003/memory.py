#!/usr/bin/env python3
import sys
from pathlib import Path as _Path
sys.path.insert(0, str(_Path(__file__).resolve().parents[1]))
from runtime_args import native_command
from checks import bench_timing, require

import argparse,gzip,json,pathlib,random,statistics,subprocess,tempfile
p=argparse.ArgumentParser();p.add_argument('--base',required=True);p.add_argument('--candidate',required=True);p.add_argument('--corpora',required=True);p.add_argument('--out',required=True);a=p.parse_args();root=pathlib.Path(__file__).resolve().parents[1]/'perf-20261001';raw=[];rng=random.Random(20261001)
cases=json.loads((root/'cases.json').read_text().replace('@CORPORA@',str(pathlib.Path(a.corpora).resolve())));cases=[c for c in cases if c['name'] in ['batch_rate-300_rate_t1','batch_rate-300_rate_t8','bench_easy-10000_t1','generate100_clues36','batch_easy-10000_solve_t1','batch_easy-10000_solve_t8']]
with tempfile.TemporaryDirectory() as td:
 helper=pathlib.Path(td)/'measure-memory';metric=pathlib.Path(td)/'metric.json';subprocess.run(['gcc','-O2',str(root/'measure_memory.c'),'-o',str(helper)],check=True)
 for case in cases:
  for rep in range(9):
   engines=['baseline','candidate'];rng.shuffle(engines)
   for engine in engines:
    binary=pathlib.Path(a.base if engine=='baseline' else a.candidate).resolve()
    p=subprocess.run([str(helper),str(metric),*native_command(binary, case['threads'], case['args'])],capture_output=True,timeout=120)
    require(p.returncode==0, (case,engine,p.returncode,p.stderr))
    if case['args'][0]=='bench':
     bench_timing(p.stdout,p.stderr)
    r=json.loads(metric.read_text());r.update(case=case['name'],engine=engine,rep=rep,warmup=rep<2);raw.append(r)
summary=[]
for c in cases:
 row={'case':c['name']}
 for engine in ['baseline','candidate']:
  xs=[r['peak_rss_kib'] for r in raw if r['case']==c['name'] and r['engine']==engine and not r['warmup']];row[engine]={'median_kib':statistics.median(xs),'min_kib':min(xs),'max_kib':max(xs)}
 summary.append(row)
out=pathlib.Path(a.out);out.write_text(json.dumps({'method':'tiny C launcher fork/exec/wait4; avoids Python inherited pre-exec RSS; no affinity change; two warmups plus seven randomized serial samples','summary':summary},indent=2)+'\n')
with gzip.open(str(out)+'.raw.json.gz','wt') as f:json.dump(raw,f)
print(out.read_text())
