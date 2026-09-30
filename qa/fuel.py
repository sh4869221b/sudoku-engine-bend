#!/usr/bin/env python3
import pathlib,subprocess,json
ROOT=pathlib.Path(__file__).resolve().parents[1];logs=[]
for mode in ('solve','count','rate','generate'):
 p=subprocess.run([str(ROOT/'bin/qa-fuel'),'--threads','1',mode],capture_output=True,text=True,timeout=30)
 assert p.returncode==4,(mode,p.returncode,p.stdout,p.stderr)
 assert len(p.stdout.splitlines())==(1 if mode=='generate' else 0)
 assert 'fuel' in p.stderr
 if mode=='generate':assert len(p.stdout.strip())==81 and 'unreachable' not in p.stdout
 logs.append({'mode':mode,'code':p.returncode,'stdout':p.stdout,'stderr':p.stderr})
(ROOT/'.omo/evidence/fuel-cli.json').write_text(json.dumps(logs,indent=2));print('PASS production handlers fuel exit4 and generation valid-prefix')
