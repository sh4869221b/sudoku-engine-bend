#!/usr/bin/env python3
"""Paired-bootstrap per-case median wall-time ratios for fixed hard-count lanes."""
import argparse,gzip,json,random,statistics,pathlib
p=argparse.ArgumentParser();p.add_argument('measurement');p.add_argument('--out',required=True);a=p.parse_args()
path=pathlib.Path(a.measurement);data=json.loads(path.read_text());raw=json.loads(gzip.open(str(path)+'.raw.json.gz','rt').read())
result={'measurement':str(path),'statistic':'median baseline wall_ms / median candidate wall_ms','resampling':'paired by rep;warmups excluded;percentile bootstrap','bootstrap_samples':5000,'seed':20261003,'cases':[]}
for name in ['batch_hard-100_count_t1','batch_hard-100_count_t8','batch_hard-100_count_t16']:
 pairs={}
 for r in raw:
  if r['case']==name and not r['warmup']:pairs.setdefault(r['rep'],{})[r['engine']]=r['wall_ms']
 items=list(pairs.values());assert items and all(set(x)=={'baseline','candidate'} for x in items)
 rng=random.Random(20261003);ratios=[]
 for _ in range(5000):
  sample=rng.choices(items,k=len(items));ratios.append(statistics.median(x['baseline'] for x in sample)/statistics.median(x['candidate'] for x in sample))
 ratios.sort();base=statistics.median(x['baseline'] for x in items);candidate=statistics.median(x['candidate'] for x in items)
 result['cases'].append({'case':name,'paired_repetitions':len(items),'baseline_median_ms':base,'candidate_median_ms':candidate,'speedup':base/candidate,'paired_bootstrap_95_ci':[ratios[125],ratios[4874]]})
pathlib.Path(a.out).write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result,indent=2))
