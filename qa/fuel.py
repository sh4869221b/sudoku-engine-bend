#!/usr/bin/env python3
import pathlib,subprocess,json
from checks import require
ROOT=pathlib.Path(__file__).resolve().parents[1];logs=[]
for mode in ('solve','count','rate','generate'):
 p=subprocess.run([str(ROOT/'bin/qa-fuel'),'+RTS','--threads','1','-RTS',mode],capture_output=True,text=True,timeout=30)
 require(p.returncode==4, (mode,p.returncode,p.stdout,p.stderr))
 require(len(p.stdout.splitlines())==(1 if mode=='generate' else 0), (mode,p.stdout))
 require('fuel' in p.stderr, (mode,p.stderr))
 if mode=='generate':
  require(len(p.stdout.strip())==81 and 'unreachable' not in p.stdout, p.stdout)
 logs.append({'mode':mode,'code':p.returncode,'stdout':p.stdout,'stderr':p.stderr})
(ROOT/'.omo/evidence/fuel-cli.json').write_text(json.dumps(logs,indent=2));print('PASS production handlers fuel exit4 and generation valid-prefix')
