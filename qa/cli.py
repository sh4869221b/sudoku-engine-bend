#!/usr/bin/env python3
"""Deterministic stdout/stderr/exit contracts and fixture gates; standard library only."""
import json,pathlib,subprocess,tempfile,re,os
ROOT=pathlib.Path(__file__).resolve().parents[1]; BIN=ROOT/'bin/bend-sudoku';results=[]
SOL='534678912672195348198342567859761423426853791713924856961537284287419635345286179'
EASY='530070000600195000098000060800060003400803001700020006060000280000419005000080079'
HARD='800000000003600000070090200050007000000045700000100030001000068008500010090000400'
ZERO='0'*81
CONTRA='123456780'+'000000009'+'0'*63
UNSOL=EASY[:2]+'1'+EASY[3:]
def run(*args,code=0,out=None,threads=1):
 p=subprocess.run([str(BIN),'--threads',str(threads),*args],capture_output=True,text=True,timeout=120)
 assert p.returncode==code,(args,p.returncode,p.stdout,p.stderr)
 if out is not None:assert p.stdout.rstrip('\n')==out,(args,p.stdout,out)
 results.append({'args':list(args),'code':p.returncode,'stdout':p.stdout,'stderr':p.stderr,'threads':threads})
 return p

# Fixtures are committed review inputs; never regenerate them during verification.
run(code=1);run('nonsense',code=1);run('nonsense','bad',code=1);run('solve',code=1);run('solve',EASY,EASY,code=1)
for puzzle in ['',ZERO[:-1],ZERO+'0','x'+ZERO[1:],'０'+ZERO[1:],ZERO[:40]+' '+ZERO[41:],ZERO+'\n']:
 for mode in ('solve','check','count','rate'):run(mode,puzzle,code=2)
for puzzle in ('11'+'0'*79,'1'+'0'*8+'1'+'0'*71,'1'+'0'*9+'1'+'0'*70):
 for mode in ('solve','check','count','rate'):run(mode,puzzle,code=2)
run('solve',EASY,out=SOL);run('solve',EASY.replace('0','.'),out=SOL);run('solve',UNSOL,code=3,out='unsolved')
run('solve',HARD);run('count',HARD,out='1');run('count',UNSOL,out='0');run('count',ZERO,out='2')
run('rate',SOL,out='Difficulty: Easy\nMax technique: None\nSteps: 0\nScore: 0')
run('rate',ZERO,out='Difficulty: Hard\nMax technique: None\nSteps: 0\nScore: 0')
p=run('rate',CONTRA,code=3,out='');assert 'contradiction' in p.stderr
for args in (['--count','0'],['--count','-1'],['--seed',''],['--seed','4294967296'],['--seed','abc'],['--clues','82'],['--clues','-1'],['--difficulty','invalid'],['--seed'],['--foo'],['--symmetry','--symmetry'],['--clues','32','--clues','32'],['--seed','1','--seed','1'],['--clues','81','--minimal'],['--minimal','--clues','81'],['--difficulty','easy','--minimal'],['--minimal','--difficulty','hard'],['--difficulty','easy','--clues','32'],['--clues','32','--difficulty','easy']):run('generate',*args,code=1)
for clues in (0,1,17,32,80,81):
 p=run('generate','--seed','42','--count','2','--clues',str(clues),'--symmetry')
 ls=p.stdout.splitlines();assert len(ls)==2
 for idx,line in enumerate(ls,1):
  assert re.fullmatch('[0-9]{81}',line);n=sum(c!='0' for c in line);assert n>=clues
  if n!=clues:assert f'index={idx} seed={41+idx} target={clues} reached={n}' in p.stderr
  run('count',line,out='1')
for label,n in [('easy',36),('medium',32),('hard',28)]:
 p=run('generate','--seed','42','--difficulty',label);assert sum(c!='0' for c in p.stdout.strip())>=n
with tempfile.TemporaryDirectory() as td:
 path=pathlib.Path(td)/'input.txt'
 for size in (0,1,3,5,100):
  lines=[EASY if i%2 else SOL for i in range(size)]
  path.write_text('\n'.join(lines)+ ('\n' if lines else ''))
  for mode in ('solve','check','count','rate'):
   outputs=[run('batch',str(path),mode,threads=t).stdout for t in (1,8,16)];assert len(set(outputs))==1
   records=outputs[0].splitlines();assert len(records)==size
   for i,record in enumerate(records,1):assert record.startswith(str(i)+' ')
 path.write_text('# comment\n\n'+SOL+'\nbad\n'+EASY+'\n')
 for mode in ('solve','check','count','rate'):
  lines=run('batch',str(path),mode).stdout.splitlines();assert len(lines)==3
  assert [x.split(' ')[0] for x in lines]==['3','4','5'];assert lines[1]=='4 error:length'
 path.write_text('# comment\n\n');run('batch',str(path),'solve',out='')
 path.write_text('bad\ninvalid\n');run('batch',str(path),'count',out='1 error:length\n2 error:length')
 path.write_bytes((SOL+'\r\n'+EASY+'\r\n').encode());run('batch',str(path),'count',out='1 count:1\n2 count:1')
 p=run('generate','--seed','42','--count','5','--clues','1');path.write_text(p.stdout)
 lines=run('batch',str(path),'count').stdout.splitlines();assert lines==[f'{i} count:1' for i in range(1,6)]
 path.write_text(SOL+'\n');p=run('bench',str(path));assert re.fullmatch(r'N=1 mode=cpu threads=runtime total_ms=\d+ per_ms=[0-9.e+-]+\n',p.stdout)
 run('bench',str(path),'--generate','10',code=1)
 path.write_text('bad\n');run('bench',str(path),code=2)
 path.write_text('');run('bench',str(path),code=2)
 run('bench','--generate','3',code=1);run('bench','--generate','abc',code=1)
 run('bench','--generate','10');run('bench','--generate','100')
run('batch','/missing/input','solve',code=1);run('bench','/missing/input',code=1);run('batch','/missing/input','nope',code=1)
# Each source fixture's command-specific output is checked, never auto-updated on mismatch.
for exp in sorted((ROOT/'fixtures').rglob('*.expected')):
 slug,command,_=exp.name.rsplit('.',2);puzzle=(exp.parent/(slug+'.txt')).read_text().strip();expected=exp.read_text().strip()
 code=2 if command=='check' and expected=='invalid' else 3 if command=='solve' and expected=='unsolved' else 0
 actual=run(command,puzzle,code=code).stdout.strip()
 if command=='check' and expected=='invalid':assert actual.startswith('invalid ')
 elif command=='rate':assert actual.splitlines()[0]=='Difficulty: '+expected
 else:assert actual==expected,(exp,actual,expected)
out=ROOT/'.omo/evidence/cli-results.json';out.write_text(json.dumps({'status':'PASS','cases':len(results),'results':results},indent=2))
print(json.dumps({'status':'PASS','cases':len(results),'evidence':str(out.relative_to(ROOT))}))
