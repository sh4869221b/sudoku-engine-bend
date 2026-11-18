#!/usr/bin/env python3
"""Independent Python candidate-set reference for the documented technique order."""
import json,pathlib,subprocess
from checks import require
ROOT=pathlib.Path(__file__).resolve().parents[1]
UNITS=[[r*9+c for c in range(9)] for r in range(9)]+[[r*9+c for r in range(9)] for c in range(9)]+[[(br*3+r)*9+bc*3+c for r in range(3) for c in range(3)] for br in range(3) for bc in range(3)]
PEERS=[set().union(*(set(u) for u in UNITS if p in u))-{p} for p in range(81)]
def reference(s):
 b=list(map(int,s)); cs=[set() if v else set(range(1,10))-{b[q] for q in PEERS[p]} for p,v in enumerate(b)];trace=[]
 def support(u,d):return [p for p in u if d in cs[p]]
 for _ in range(1000):
  if any(not b[p] and not cs[p] for p in range(81)) or any(d not in [b[p] for p in u] and not support(u,d) for u in UNITS for d in range(1,10)): status='contradiction';break
  if all(b):status='ok';break
  action=None
  for p in range(81):
   if len(cs[p])==1:action=(1,[p],cs[p].copy());break
  if not action:
   for u in UNITS:
    for d in range(1,10):
     ps=support(u,d)
     if len(ps)==1 and d not in [b[p] for p in u]:action=(2,ps,{d});break
    if action:break
  if not action:
   for ui,u in enumerate(UNITS):
    for d in range(1,10):
     ps=support(u,d)
     if not ps:continue
     p=ps[0];r,c=divmod(p,9)
     for ti in (r,9+c,18+r//3*3+c//3):
      target=UNITS[ti]
      if ti!=ui and set(ps)<=set(target):
       remove=[q for q in target if q not in u and d in cs[q]]
       if remove:action=(3,remove,{d});break
     if action:break
    if action:break
  if not action:
   for u in UNITS:
    for p in u:
     bits=cs[p]
     if len(bits)==2 and sum(cs[q]==bits for q in u)==2:
      remove=[q for q in u if cs[q]!=bits and cs[q]&bits]
      if remove:action=(4,remove,bits.copy());break
    if action:break
  if not action:status='guess';break
  tech,ps,bits=action;trace.append(tech)
  if tech<3:
   p=ps[0];d=next(iter(bits));b[p]=d;cs[p]=set()
   for q in PEERS[p]:cs[q].discard(d)
  else:
   for q in ps:cs[q]-=bits
 else:status='fuel'
 score=sum({1:1,2:2,3:5,4:10}[t] for t in trace)
 return dict(status=status,tech=max(trace,default=0),steps=len(trace),score=score,trace=trace)
def run(*args):
 p=subprocess.run([str(ROOT/'bin/bend-sudoku'),'+RTS','--threads','1','-RTS',*args],text=True,capture_output=True,timeout=90)
 require(p.returncode==0, (args,p.returncode,p.stderr))
 return p.stdout.strip()
if __name__=='__main__':
 fixtures=[];covered=set()
 for seed in range(100):
  s=run('generate','--seed',str(seed),'--minimal'); ref=reference(s)
  lines=run('rate',s).splitlines();got={a.strip():b.strip() for a,b in (line.split(':',1) for line in lines)}
  names=['None','NakedSingle','HiddenSingle','LockedCandidates','NakedPair']
  require(int(got['Steps'])==ref['steps'] and int(got['Score'])==ref['score'] and got['Max technique']==names[ref['tech']], (seed,ref,got))
  if set(ref['trace'])-covered:
   fixtures.append(dict(seed=seed,puzzle=s,expected=ref));covered.update(ref['trace'])
  if covered=={1,2,3,4}:break
 require(covered=={1,2,3,4}, covered)
 dest=ROOT/'qa/fixtures/technique';dest.mkdir(parents=True,exist_ok=True)
 (dest/'reference.json').write_text(json.dumps(fixtures,indent=2)+'\n')
 print(json.dumps({'status':'PASS','seeds_checked':seed+1,'covered_techniques':sorted(covered),'fixtures':len(fixtures)},indent=2))
