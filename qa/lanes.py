#!/usr/bin/env python3
import subprocess,pathlib,os,json,tempfile
ROOT=pathlib.Path(__file__).resolve().parents[1];BEND=os.environ.get('BEND','bend');S='534678912672195348198342567859761423426853791713924856961537284287419635345286179';checks=[]
with tempfile.TemporaryDirectory() as td:
 p=pathlib.Path(td)/'one.txt';p.write_text(S+'\n')
 cases=[(['solve',S],S),(['check',S],'valid'),(['count',S],'1'),(['generate','--seed','42','--clues','81'],None),(['rate',S],'Difficulty: Easy\nMax technique: None\nSteps: 0\nScore: 0'),(['batch',str(p),'count'],'1 count:1'),(['bench',str(p)],None)]
 for lane,prefix in [('bend',[BEND,str(ROOT/'main.bend'),'--']),('js',['node',str(ROOT/'bin/bend-sudoku.js')]),('native',[str(ROOT/'bin/bend-sudoku'),'--threads','1'])]:
  for args,expected in cases:
   if lane=='js' and args[0] in ('batch','bench'):
    checks.append({'lane':lane,'command':args[0],'status':'not-run','reason':'Bun ffi unavailable; Node does not support Bend File effects'});continue
   r=subprocess.run(prefix+args,capture_output=True,text=True,timeout=60,env=dict(os.environ,BEND_NO_TELEMETRY='1'));assert r.returncode==0,(lane,args,r.stdout,r.stderr)
   # The checker emits its verdict before the program on some compiler versions.
   lines=r.stdout.splitlines();out='\n'.join(x for x in lines if x not in ('ALL PROOFS CHECK','Use --verdict for mathematical validity.'))
   if expected is not None:assert out.strip()==expected,(lane,args,out,expected)
   checks.append({'lane':lane,'command':args[0],'exit':r.returncode,'stdout':r.stdout,'stderr':r.stderr})
(ROOT/'.omo/evidence/lanes.json').write_text(json.dumps({'status':'PASS','checks':checks},indent=2));print('PASS all7 native/Bend and5 Node-compatible commands; JS file IO requires Bun (not installed)')
