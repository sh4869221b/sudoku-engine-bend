#!/usr/bin/env python3
"""Fixed-suite aggregate and paired bootstrap uncertainty from saved raw data."""
import argparse,gzip,json,random,statistics,pathlib
p=argparse.ArgumentParser();p.add_argument('measurement');p.add_argument('--out');a=p.parse_args()
path=pathlib.Path(a.measurement);data=json.loads(path.read_text());rows=data['summary'];raw=json.loads(gzip.open(str(path)+'.raw.json.gz','rt').read());rng=random.Random(20261003)
cases={r['case']:{} for r in rows}
for r in raw:
 if not r['warmup']:cases[r['case']].setdefault(r['rep'],{})[r['engine']]=r['wall_ms']
base=sum(r['baseline']['wall_ms']['median'] for r in rows);candidate=sum(r['candidate']['wall_ms']['median'] for r in rows)
ratios=[]
for _ in range(5000):
 b=c=0
 for reps in cases.values():
  items=list(reps.values());sample=rng.choices(items,k=len(items));b+=statistics.median(x['baseline'] for x in sample);c+=statistics.median(x['candidate'] for x in sample)
 ratios.append(b/c)
ratios.sort();out={'cases':len(rows),'baseline_sum_median_ms':base,'candidate_sum_median_ms':candidate,'primary_speedup':base/candidate,'paired_bootstrap_95_ci':[ratios[125],ratios[4874]],'bootstrap_samples':5000,'seed':20261003}
print(json.dumps(out,indent=2))
if a.out:pathlib.Path(a.out).write_text(json.dumps(out,indent=2)+'\n')
