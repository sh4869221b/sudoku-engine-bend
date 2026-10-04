#!/usr/bin/env python3
"""Optional real-toolchain safety smoke tests, serialized after full verification."""
import argparse,hashlib,json,os,pathlib,subprocess,tempfile,sys
root=pathlib.Path(__file__).resolve().parents[2]
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--out', type=pathlib.Path, required=True, help='New result JSON path (must not exist)')
args=parser.parse_args()
if not __debug__:
 parser.error('Run without -O or PYTHONOPTIMIZE; acceptance assertions are required')
if args.out.exists():
 parser.error('Output already exists')
sys.path.insert(0,str(root/'qa'))
import toolchain
env=toolchain.environment(toolchain.selected());env['BUN_JSC_forceRAMSize']='67108864'
adapter=str(root/'qa/low_memory.py');records=[]
with tempfile.TemporaryDirectory(prefix='real low memory fixtures ') as td:
 p=pathlib.Path(td)
 valid=p/'valid proof.bend';valid.write_text('import Base\ndef same() -> {0 == 0 : U32}:\n  {==}\n')
 unsafe=p/'unsafe proof.bend';unsafe.write_text('import Base\n@unsafe\ndef main() -> U32:\n  0\n')
 wrong=p/'wrong proof.bend';wrong.write_text('import Base\ndef wrong() -> {0 == 1 : U32}:\n  {==}\n')
 for path,should_pass in ((valid,True),(unsafe,False),(wrong,False)):
  r=subprocess.run([adapter,str(path),'--verdict'],env=env,capture_output=True,text=True,timeout=60)
  assert (r.returncode==0)==should_pass,(path,r.returncode,r.stdout,r.stderr)
  if should_pass:assert r.stdout=='ALL PROOFS CHECK\n' and not r.stderr,(r.stdout,r.stderr)
  else:assert 'ALL PROOFS CHECK' not in r.stdout,(r.stdout,r.stderr)
  if path==unsafe:assert 'unsafe or foreign' in r.stderr,r.stderr
  records.append({'case':path.name,'exit_code':r.returncode,'stdout':r.stdout,'stderr':r.stderr.replace(td,'<fixture>')})
 (p/'LAWS.bend').write_text('import Base\n')
 (p/'PROOF.bend').symlink_to(valid.name)
 r=subprocess.run([adapter,str(p/'PROOF.bend'),'--verdict'],env=env,capture_output=True,text=True,timeout=60)
 assert r.returncode!=0 and 'Symlink proof entrypoints' in r.stderr,(r.stdout,r.stderr)
 records.append({'case':'PROOF symlink without imported laws','exit_code':r.returncode})
 source=p/'native source.bend';source.write_text('import Base\ndef main() -> U32:\n  42\n')
 hashes={}
 for label,compiler in [('default',env['BEND']),('low-memory',adapter)]:
  d=p/label;d.mkdir();out=d/'tiny'
  r=subprocess.run([compiler,str(source),'-o',str(out)],env=env,capture_output=True,text=True,timeout=60)
  assert r.returncode==0,(label,r.stdout,r.stderr)
  run=subprocess.run([str(out)],capture_output=True,text=True,timeout=10)
  assert run.returncode==0 and run.stdout.strip()=='42',(label,run.stdout,run.stderr)
  hashes[label]=hashlib.sha256(out.read_bytes()).hexdigest()
 assert hashes['default']==hashes['low-memory'],hashes
 records.append({'case':'same native output and byte-identical binary with source/output paths containing spaces','sha256':hashes})
 # An existing output is refused and its bytes survive unchanged.
 out=p/'low-memory/tiny';before=out.read_bytes()
 r=subprocess.run([adapter,str(source),'-o',str(out)],env=env,capture_output=True,text=True,timeout=60)
 assert r.returncode!=0 and out.read_bytes()==before,(r.returncode,r.stderr)
 records.append({'case':'existing native output protected','exit_code':r.returncode})
result={'status':'PASS','cases':records}
with args.out.open('x') as f:f.write(json.dumps(result,indent=2)+'\n')
print(json.dumps(result,indent=2))
