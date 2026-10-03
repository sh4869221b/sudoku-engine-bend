#!/usr/bin/env python3
import datetime, hashlib, json, os, pathlib, re, shlex, subprocess, sys
base=pathlib.Path('/workspace/scratch/b81277eea609')
pub=base/'sudoku-bend-publish-main'
out=base/'bend-publication'
run=pub/'.verification/20261003T213650Z-fkr3seby'
work=run/'work'
tools=base/'sudoku-engine-bend-cloud/.toolchains'
log=out/'staged-verification.log'
report=out/'staged-verification.json'
expected='993a4b80761ac97e3d4b9269f767384e64bcd2ad442f23259f20bf59ccd06169'
engine_expected='9ed5b3446c426fd561586d35e4481c72f852a1cca66bd2d12e33f78358753a44'
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def now(): return datetime.datetime.now(datetime.timezone.utc).isoformat()
paths=sorted(set([*work.glob('*.bend'),work/'build.sh',work/'toolchain-env.sh',work/'toolchain.lock.json',*work.glob('sudoku/**/*.bend'),*[p for p in work.glob('qa/**/*') if p.is_file() and p.suffix in ('.bend','.py','.sh')]]))
source_hashes={str(p.relative_to(work)):sha(p) for p in paths}
for rel,h in source_hashes.items():
    assert sha(pub/rel)==h, 'Publication/source mismatch: '+rel
assert sha(work/'bin/bend-sudoku')==engine_expected
assert json.loads((run/'summary.json').read_text())['exit_code']==137
prior=base/'sudoku-engine-bend-cloud/.verification/20261003T183017Z-pecntfgy/work/bin/qa-run'
assert sha(prior)==expected
original=(work/'qa/verify_gates.sh').read_text()
needle='"$BEND" qa_run.bend -o bin/qa-run\n'
assert original.count(needle)==1
suffix=original.split(needle,1)[1]
assert suffix.startswith('./bin/qa-run --threads 1\n')
script=out/'staged-verification.sh'
cfile=out/'qa-run.c'
text='''#!/bin/sh
set -eu
cd WORK
export BEND_TOOLCHAIN_DIR=TOOLS
export BEND_SKIP_BENCHMARK=0
. ./toolchain-env.sh
export BEND_NO_TELEMETRY=1
set -x
date -u +STAGED_EMISSION_START=%Y-%m-%dT%H:%M:%SZ
"$BEND" qa_run.bend -o CFILE
date -u +STAGED_EMISSION_END=%Y-%m-%dT%H:%M:%SZ
python3 - CFILE <<'CHECK_C'
import pathlib,re,sys
c=pathlib.Path(sys.argv[1]).read_text()
assert re.search(r'^#define BANGS\\s+0$', c, re.M), 'Unexpected GPU path'
assert '#include <X11/' not in c and '#include <alsa/' not in c, 'Unexpected extra link library'
CHECK_C
"$CC" -std=c11 -O3 CFILE -lpthread -lm -o QABIN
date -u +STAGED_NATIVE_END=%Y-%m-%dT%H:%M:%SZ
printf '%s  %s\\n' EXPECTED QABIN | sha256sum -c -
'''
for k,v in [('WORK',str(work)),('TOOLS',str(tools)),('CFILE',str(cfile)),('QABIN',str(work/'bin/qa-run')),('EXPECTED',expected)]: text=text.replace(k,shlex.quote(v))
script.write_text(text+suffix+'\ndate -u +ALL_REMAINING_GATES_END=%Y-%m-%dT%H:%M:%SZ\n')
summary={'status':'RUNNING','started_utc':now(),'work':str(work),'log':str(log),'script':str(script),'source_tree':subprocess.check_output(['git','rev-parse','HEAD^{tree}'],cwd=pub,text=True).strip(),'source_hashes':source_hashes,'toolchain':json.loads((tools/'installed.json').read_text()),'standard_attempts':[{'run':str(pub/'.verification/20261003T213030Z-94yzf_b4'),'status':'FAIL','exit_code':137},{'run':str(run),'status':'FAIL','exit_code':137}],'reuse_completed_gates':['./build.sh (main check and native compilation)','BEND PROOF.bend --verdict','BEND qa/run.bend --check-only'],'workaround':'Only qa_run.bend native compilation is split into pinned Bend C emission and exact pinned Clang flags after Bend exits; then the byte-for-byte normal verify_gates.sh suffix runs. Source and toolchain are unchanged.','qa_expected_sha256':expected,'engine_sha256':engine_expected,'benchmark':'included; BEND_SKIP_BENCHMARK=0','remaining_gates_sha256':hashlib.sha256(suffix.encode()).hexdigest(),'script_sha256':sha(script)}
report.write_text(json.dumps(summary,indent=2)+'\n')
with log.open('w') as f:
    f.write('STAGED continuation of the second FAIL/137 run. Earlier standard failures remain failures.\n');f.flush()
    proc=subprocess.Popen(['flock','-x','/tmp/bend-cloud-cpu.lock','sh',str(script)],stdout=f,stderr=subprocess.STDOUT,start_new_session=True)
    try: code=proc.wait()
    except BaseException:
        import signal
        os.killpg(proc.pid,signal.SIGTERM)
        proc.wait()
        raise
summary['finished_utc']=now();summary['exit_code']=code
summary['source_changes']=[rel for rel,h in source_hashes.items() if sha(work/rel)!=h]
summary['qa_actual_sha256']=sha(work/'bin/qa-run') if (work/'bin/qa-run').exists() else None
summary['generated_c_sha256']=sha(cfile) if cfile.exists() else None
summary['publication_git_status']=subprocess.check_output(['git','status','--porcelain'],cwd=pub,text=True)
summary['status']='PASS (staged scheduling workaround)' if code==0 and not summary['source_changes'] and summary['qa_actual_sha256']==expected and not summary['publication_git_status'] else 'FAIL'
report.write_text(json.dumps(summary,indent=2)+'\n')
print(json.dumps({k:summary[k] for k in ('status','exit_code','finished_utc','qa_actual_sha256','source_changes','publication_git_status')},indent=2),flush=True)
sys.exit(0 if summary['status'].startswith('PASS') else code or 1)
