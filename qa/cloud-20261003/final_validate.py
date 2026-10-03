#!/usr/bin/env python3
"""Frozen final validation and predeclared primary/secondary paired measurements."""
import argparse, datetime as dt, fcntl, hashlib, json, os, pathlib, re, shutil, signal, subprocess, time
ROOT=pathlib.Path(__file__).resolve().parents[2]
p=argparse.ArgumentParser()
p.add_argument('--base',type=pathlib.Path,required=True)
p.add_argument('--reference52',type=pathlib.Path,required=True)
p.add_argument('--corpora',type=pathlib.Path,required=True)
p.add_argument('--out',type=pathlib.Path,required=True)
p.add_argument('--not-before-utc')
p.add_argument('--baseline-sha')
p.add_argument('--reference52-sha')
a=p.parse_args()
if a.not_before_utc:
 target=dt.datetime.fromisoformat(a.not_before_utc.replace('Z','+00:00'))
 if dt.datetime.now(dt.timezone.utc)<target:raise SystemExit('Final validation window has not started')
base=a.base.resolve(); ref=a.reference52.resolve(); corp=a.corpora.resolve(); out=a.out.resolve()
for f in (base,ref):assert f.is_file(),f
if out.exists() and any(out.iterdir()):raise SystemExit('Output directory is not empty; preserve the earlier run and use a new prefix')
out.mkdir(parents=True,exist_ok=True)
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
if a.baseline_sha:assert sha(base)==a.baseline_sha,'Original baseline binary changed'
if a.reference52_sha:assert sha(ref)==a.reference52_sha,'Reference52 binary changed'
def stamp():return dt.datetime.now(dt.timezone.utc).isoformat()
def fingerprints():
 paths=[ROOT/'main.bend',ROOT/'LAWS.bend',ROOT/'PROOF.bend',ROOT/'build.sh',ROOT/'toolchain-env.sh',ROOT/'toolchain.lock.json',ROOT/'qa/empty-search-state-golden.json',ROOT/'qa/perf-20261001/cases.json',*sorted((ROOT/'sudoku').glob('*.bend')), *sorted((ROOT/'qa').glob('*.py')), *sorted((ROOT/'qa').glob('*.bend')), *sorted((ROOT/'qa/cloud-20261003').glob('*.py')), ROOT/'qa/perf-20261001/measure.py', ROOT/'qa/perf-20261001/differential.py', ROOT/'qa/perf-20261003/analyze.py', ROOT/'qa/deadline-20261003/combine_measurements.py', ROOT/'qa/deadline-20261003/file_differential.py', ROOT/'verify.sh', ROOT/'qa/verify_gates.sh', ROOT/'qa/perf-20261001/measure_memory.c', ROOT/'qa/cloud-20261003/results/randomized-accepted54.json.cases.json']
 paths += sorted(ROOT.glob('*.bend')) + sorted(x for x in (ROOT/'fixtures').rglob('*') if x.is_file()) + [ROOT/'qa/compare-go-corpus.json']
 return {str(x.relative_to(ROOT)):sha(x) for x in paths}
source=fingerprints()
state={'status':'RUNNING','started_utc':stamp(),'baseline':{'path':str(base),'sha256':sha(base)},'reference52':{'path':str(ref),'sha256':sha(ref)},'source_hashes':source,'corpus_hashes':{x.name:sha(x) for x in sorted(corp.glob('*.txt'))},'stages':[],'primary_protocol':'Two independent fixed35-case blocks,21paired serial randomized observations plus2warmups percase andengine;retain both and pool42.5000 paired bootstrap.','secondary_protocol':'Existing hard100 count1/8/16cases only;300paired observations versus52,plus2warmups. Per-case uncertainty only;not a replacement for the35-case primary score.'}
state['checkout_commit']=subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip()
state['production_commit']=subprocess.check_output(['git','log','-1','--format=%H','--','main.bend','sudoku'],cwd=ROOT,text=True).strip()
def save():(out/'final-run.json').write_text(json.dumps(state,indent=2)+'\n')
def run(name,args,timeout=300):
 item={'stage':name,'started_utc':stamp(),'command':[str(x) for x in args]};state['stages'].append(item);save();print('START',name,flush=True);t=time.monotonic()
 with (out/(name+'.log')).open('w') as f:
  proc=subprocess.Popen([str(x) for x in args],cwd=ROOT,stdout=f,stderr=subprocess.STDOUT,start_new_session=True)
  try:
   code=proc.wait(timeout=timeout)
  except BaseException:
   try:os.killpg(proc.pid,signal.SIGTERM)
   except ProcessLookupError:pass
   try:proc.wait(timeout=5)
   except subprocess.TimeoutExpired:pass
   try:os.killpg(proc.pid,signal.SIGKILL)
   except ProcessLookupError:pass
   proc.wait()
   item.update(exit_code=proc.returncode,interrupted=True,finished_utc=stamp());save()
   raise
 item.update(exit_code=code,elapsed_seconds=round(time.monotonic()-t,3),finished_utc=stamp());save()
 if code:
  try:os.killpg(proc.pid,signal.SIGTERM)
  except ProcessLookupError:pass
  time.sleep(0.1)
  try:os.killpg(proc.pid,signal.SIGKILL)
  except ProcessLookupError:pass
  raise RuntimeError(f'{name} failed with exit{code}; see {out/(name+".log")}')
 print('PASS',name,flush=True)
lock=open('/tmp/bend-cloud-cpu.lock','a');print('Waiting for exclusive CPU lock',flush=True);fcntl.flock(lock,fcntl.LOCK_EX)
try:
 run('toolchain-check',['python3','qa/toolchain.py','check'],120)
 run('build',['./build.sh'],180)
 run('full-gates',['./verify.sh'],900)
 gate_log=(out/'full-gates.log').read_text();m=re.search(r'^Verification results: (.+)$',gate_log,re.M);assert m,'Missing isolated verification path'
 verification=pathlib.Path(m[1]); summary=json.loads((verification/'summary.json').read_text());assert summary['status']=='PASS' and summary['benchmark']=='included'
 shutil.copy2(verification/'summary.json',out/'verification-summary.json')
 shutil.copytree(verification/'work/.omo/evidence',out/'verification-evidence')
 for result_name in ['integration-result.json','rate-reference-result.json']:
  shutil.copy2(verification/'work/qa'/result_name,out/('verification-'+result_name))
 adaptive=json.loads((out/'verification-evidence/adaptive-trace/summary.json').read_text());assert adaptive['completed_traces']==20 and not adaptive['capped_incomplete_traces'],'Direct adaptive traces must all complete in final run'
 bench=json.loads((out/'verification-evidence/benchmark.json').read_text());assert all(x['status']=='success' for x in bench['records']) and len(bench['records'])==15
 golden=json.loads((out/'verification-evidence/empty-search-state.json').read_text());assert golden['production_runs']==3030 and golden['direct_transition_states']==3030
 candidate=ROOT.parent/('cloud-final-'+out.name+'-'+str(os.getpid()));shutil.copy2(verification/'work/bin/bend-sudoku',candidate);os.chmod(candidate,0o755)
 assert {k:sha(verification/'work'/k) for k in source}==source,'Isolated verification source differs from frozen checkout'
 state['candidate']={'path':str(candidate),'sha256':sha(candidate)};state['verification_directory']=str(verification);save()
 run('differential',['python3','qa/perf-20261001/differential.py','--base',base,'--candidate',candidate,'--repo',ROOT,'--corpora',corp,'--out',out/'differential.json'])
 run('file-differential',['python3','qa/deadline-20261003/file_differential.py','--base',base,'--candidate',candidate,'--out',out/'file-differential.json'])
 run('randomized',['python3','qa/cloud-20261003/randomized_correctness.py','--base',base,'--candidate',candidate,'--cases',ROOT/'qa/cloud-20261003/results/randomized-accepted54.json.cases.json','--out',out/'randomized.json','--lock-held'],300)
 run('memory',['python3','qa/cloud-20261003/memory.py','--base',base,'--candidate',candidate,'--corpora',corp,'--out',out/'memory.json'],180)
 assert fingerprints()==source,'Production/proof/frozen case source changed during correctness checks'
 cases=json.loads((ROOT/'qa/perf-20261001/cases.json').read_text());assert len(cases)==35
 hard=[x for x in cases if x['name'] in {'batch_hard-100_count_t1','batch_hard-100_count_t8','batch_hard-100_count_t16'}];assert len(hard)==3
 hardpath=out/'secondary-hardcount-cases.json';hardpath.write_text(json.dumps(hard,indent=2)+'\n')
 run('secondary-hardcount',['python3','qa/perf-20261001/measure.py','--base',ref,'--candidate',candidate,'--cases',hardpath,'--corpora',corp,'--out',out/'secondary-hardcount.json','--reps','300'],300)
 run('secondary-hardcount-ci',['python3','qa/cloud-20261003/paired_case_ci.py',out/'secondary-hardcount.json','--out',out/'secondary-hardcount-ci.json'],120)
 blocks=[]
 for block in (1,2):
  dest=out/f'primary-block{block}.json';blocks.append(dest)
  run(f'primary-block{block}',['python3','qa/perf-20261001/measure.py','--base',base,'--candidate',candidate,'--cases','qa/perf-20261001/cases.json','--corpora',corp,'--out',dest,'--reps','21'],300)
  run(f'primary-block{block}-aggregate',['python3','qa/perf-20261003/analyze.py',dest,'--out',out/f'primary-block{block}-aggregate.json'],120)
 run('primary-pool',['python3','qa/deadline-20261003/combine_measurements.py',*blocks,'--out',out/'primary-pooled.json'],120)
 run('primary-aggregate',['python3','qa/perf-20261003/analyze.py',out/'primary-pooled.json','--out',out/'primary-pooled-aggregate.json'],120)
 run('primary-hardcount-ci',['python3','qa/cloud-20261003/paired_case_ci.py',out/'primary-pooled.json','--out',out/'primary-hardcount-ci.json'],120)
 assert fingerprints()==source,'Source changed during final measurements'
 assert sha(base)==state['baseline']['sha256'] and sha(ref)==state['reference52']['sha256'] and sha(candidate)==state['candidate']['sha256']
 assert {x.name:sha(x) for x in sorted(corp.glob('*.txt'))}==state['corpus_hashes'],'Frozen corpus changed'
 state.update(status='PASS',finished_utc=stamp(),primary=json.loads((out/'primary-pooled-aggregate.json').read_text()),secondary_hardcount=json.loads((out/'secondary-hardcount-ci.json').read_text()));save();print(json.dumps({'status':'PASS','candidate':state['candidate'],'primary':state['primary']},indent=2),flush=True)
except BaseException as exc:
 state.update(status='FAIL',error=str(exc),finished_utc=stamp());save();raise
finally:
 fcntl.flock(lock,fcntl.LOCK_UN);lock.close()
