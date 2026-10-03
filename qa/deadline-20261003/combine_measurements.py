#!/usr/bin/env python3
"""Pool every paired observation from predeclared independent final blocks."""
import argparse,gzip,json,pathlib,statistics
p=argparse.ArgumentParser();p.add_argument('inputs',nargs='+');p.add_argument('--out',required=True);a=p.parse_args();datasets=[json.loads(pathlib.Path(x).read_text()) for x in a.inputs];raw=[]
for block,(path,d) in enumerate(zip(a.inputs,datasets)):
 assert d['metadata']['cases']==datasets[0]['metadata']['cases']
 assert {k:v['sha256'] for k,v in d['metadata']['binaries'].items()}=={k:v['sha256'] for k,v in datasets[0]['metadata']['binaries'].items()}
 for r in json.loads(gzip.open(path+'.raw.json.gz','rt').read()):
  r.update(block=block,block_rep=r['rep'],rep=block*10000+r['rep']);raw.append(r)
summary=[]
for case in datasets[0]['metadata']['cases']:
 row={'case':case['name'],'threads':case.get('threads',1)}
 for engine in ['baseline','candidate']:
  rs=[r for r in raw if r['case']==case['name'] and r['engine']==engine and not r['warmup']];stats={}
  for key in ['wall_ms','user_ms','system_ms','max_rss_kib']:
   xs=[r[key] for r in rs];q=statistics.quantiles(xs,n=4);stats[key]={'median':statistics.median(xs),'p25':q[0],'p75':q[2],'min':min(xs),'max':max(xs)}
  row[engine]=stats
 row['speedup']=row['baseline']['wall_ms']['median']/row['candidate']['wall_ms']['median'];summary.append(row)
meta=dict(datasets[0]['metadata']);meta.update(repetitions=sum(x['metadata']['repetitions'] for x in datasets),blocks=a.inputs,aggregation='Pool all non-warmup observations within fixed case; sum the35 case wall medians; paired bootstrap across all42 paired observations/case. Every block retained.')
out=pathlib.Path(a.out);out.write_text(json.dumps({'metadata':meta,'summary':summary},indent=2)+'\n')
with gzip.open(str(out)+'.raw.json.gz','wt') as f:json.dump(raw,f)
