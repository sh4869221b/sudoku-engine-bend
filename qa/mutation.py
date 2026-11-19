#!/usr/bin/env python3
import pathlib,tempfile,subprocess,os,json
import sys

if __package__:
    from .checks import require
else:
    sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
    from checks import require
ROOT=pathlib.Path(__file__).resolve().parents[1];BEND=os.environ.get('BEND','bend');logs=[]
with tempfile.TemporaryDirectory() as td:
 p=pathlib.Path(td)
 for f in ROOT.rglob('*.bend'):
  out=p/f.relative_to(ROOT);out.parent.mkdir(parents=True,exist_ok=True);out.write_text(f.read_text())
 cf=p/'sudoku/counter.bend';original=cf.read_text();cf.write_text(original.replace('finish(S.run(fuel, 2, board))','T.CountOne{}').replace('finish(S.run_prepared(fuel, 2, board))','T.CountOne{}'))
 build=subprocess.run([BEND,str(p/'qa/run.bend'),'-o',str(p/'mutant')],capture_output=True,text=True,timeout=60);require(build.returncode==0, build.stderr+build.stdout)
 check=subprocess.run([str(p/'mutant'),'+RTS','--threads','1','-RTS'],capture_output=True,text=True,timeout=30);require(check.returncode!=0 and 'empty multiple count' in check.stderr, (check.stdout,check.stderr))
 logs.append({'mutation':'count2 always CountOne','detected':True,'exit':check.returncode,'stdout':check.stdout,'stderr':check.stderr});cf.write_text(original)
 lf=p/'LAWS.bend';laws=lf.read_text()
 correct='B.mirror(B.mirror(position)) == position'
 require(laws.count(correct)==1, 'mirror mutation target must be unique')
 lf.write_text(laws.replace(correct, 'B.mirror(B.mirror(position)) == B.mirror(position)'))
 proof=subprocess.run([BEND,str(p/'PROOF.bend'),'--check-only'],capture_output=True,text=True,timeout=60);require(proof.returncode!=0 and 'SOME PROOFS FAIL' in proof.stdout+proof.stderr and 'L.mirror_involute' in proof.stdout+proof.stderr, (proof.stdout,proof.stderr))
 logs.append({'mutation':'false law mirror(mirror(p))=mirror(p)','detected':True,'exit':proof.returncode,'output':proof.stdout+proof.stderr})
(ROOT/'.omo/evidence/mutation.json').write_text(json.dumps(logs,indent=2));print('PASS counter and universal mirror-law mutants detected; original source unchanged')
