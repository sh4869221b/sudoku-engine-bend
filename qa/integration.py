#!/usr/bin/env python3
"""Independent black-box Sudoku invariants. Standard Python only."""
import subprocess, pathlib, tempfile, json, time
ROOT=pathlib.Path(__file__).resolve().parents[1]
BIN=ROOT/'bin/bend-sudoku'
checks=[]
def run(*args, code=0):
 p=subprocess.run([str(BIN),'--threads','1',*args],capture_output=True,text=True,timeout=120)
 assert p.returncode==code,(args,p.returncode,p.stdout,p.stderr)
 return p.stdout.strip(),p.stderr

def count(s,cap=2):
 b=list(map(int,s)); rows=[0]*9; cols=[0]*9; boxes=[0]*9
 for i,v in enumerate(b):
  if v:
   r,c=divmod(i,9); k=r//3*3+c//3; bit=1<<v
   if (rows[r]|cols[c]|boxes[k])&bit:return 0
   rows[r]|=bit;cols[c]|=bit;boxes[k]|=bit
 def dfs(limit):
  best=-1; mask=0; size=10
  for i,v in enumerate(b):
   if not v:
    r,c=divmod(i,9);k=r//3*3+c//3;m=1022&~(rows[r]|cols[c]|boxes[k]);n=m.bit_count()
    if not n:return 0
    if n<size:best,mask,size=i,m,n
  if best<0:return 1
  r,c=divmod(best,9);k=r//3*3+c//3;total=0
  while mask and total<limit:
   bit=mask&-mask;mask-=bit;b[best]=bit.bit_length()-1
   rows[r]|=bit;cols[c]|=bit;boxes[k]|=bit
   total+=dfs(limit-total)
   rows[r]^=bit;cols[c]^=bit;boxes[k]^=bit;b[best]=0
  return total
 return dfs(cap)

def valid(s):
 assert len(s)==81 and set(s)<=set('0123456789'),repr(s)
 assert count(s)==1,('not unique',s)

def minimal(s,sym):
 for i,c in enumerate(s):
  if c=='0' or (sym and i>40):continue
  b=list(s);b[i]='0'
  if sym:b[80-i]='0'
  assert count(''.join(b))==2,('not minimal',i,s)

start=time.monotonic()
for seed in (0,1,42):
 for sym in (False,True):
  args=['generate','--seed',str(seed),'--count','2','--clues','32']+(['--symmetry'] if sym else [])
  out,err=run(*args);again,_=run(*args);assert out==again
  lines=out.splitlines();assert len(lines)==2
  for s in lines:
   valid(s);n=sum(c!='0' for c in s);assert n>=32
   if n!=32:assert 'TargetUnmet' in err
   if sym:assert all((s[i]=='0')==(s[80-i]=='0') for i in range(81))
   solution,_=run('solve',s);assert len(solution)==81 and '0' not in solution;valid(solution)
   assert all(a=='0' or a==b for a,b in zip(s,solution))
   assert run('count',s)[0]=='1';assert run('check',s)[0]=='valid'
  checks.append({'seed':seed,'symmetry':sym,'puzzles':2})
for sym in (False,True):
 s,_=run('generate','--seed','42','--minimal',*(['--symmetry'] if sym else []))
 valid(s);minimal(s,sym);checks.append({'minimal':True,'pair_minimal':sym})
assert run('count','0'*81)[0]=='2'
assert run('solve','0'*80,code=2)[0]==''
assert run('solve','11'+'0'*79,code=2)[0]==''
run('generate','--clues','32','--difficulty','easy',code=1)
run('generate','--minimal','--clues','32',code=1)
print(json.dumps({'status':'PASS','checks':checks,'seconds':round(time.monotonic()-start,3)},indent=2))
