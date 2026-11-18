"""Same-host alternating native CLI comparison; Python standard library only."""
import pathlib,subprocess,time,json,statistics,os,hashlib,platform
import sys

if __package__:
    from .checks import bench_timing, require
    from .runtime_args import native_command
else:
    sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
    from checks import bench_timing, require
    from runtime_args import native_command
REPO=pathlib.Path(__file__).resolve().parents[1]
R=pathlib.Path(os.environ.get('COMPARE_OUTPUT',str(REPO/'.omo/evidence/optimization-run')))
R.mkdir(parents=True,exist_ok=True)
BINS={'bend':os.environ.get('BEND_SUDOKU',str(REPO/'bin/bend-sudoku')),'go':os.environ['GO_SUDOKU']}
corpus=json.loads((REPO/'qa/compare-go-corpus.json').read_text())
# Existing published input fixtures only; no original implementation is read.
(R/'corpus.json').write_text(json.dumps(corpus,indent=2))
ENV=dict(os.environ,BEND_NO_TELEMETRY='1',GOTOOLCHAIN='local')
raw=[]
def run(engine,args,threads):
 env=dict(ENV,GOMAXPROCS=str(threads));command=native_command(BINS[engine],threads,args) if engine=='bend' else [BINS[engine],'--threads',str(threads),'--',*args];t=time.perf_counter_ns();p=subprocess.run(command,env=env,capture_output=True,text=True,timeout=120)
 return {'wall_ms':(time.perf_counter_ns()-t)/1e6,'code':p.returncode,'stdout':p.stdout,'stderr':p.stderr}
def measure(name,args,threads=1,reps=11,bench_n=None):
 expected={}
 for rep in range(reps+2):
  for engine in (['bend','go'] if rep%2==0 else ['go','bend']):
   r=run(engine,args,threads);r.update(case=name,engine=engine,threads=threads,rep=rep,warmup=rep<2)
   if args[0]=='bench':
    require(r['code']==0, r)
    _,r['kernel_ms']=bench_timing(r['stdout'],r['stderr'],expected_n=bench_n,
                                 threads=threads if engine=='go' else None)
   else:
    if engine in expected:require(r['code']==expected[engine]['code'] and r['stdout']==expected[engine]['stdout'] and r['stderr']==expected[engine]['stderr'], r)
    expected[engine]=r
   raw.append(r)
 if args[0]!='bench':require(all(expected['bend'][k]==expected['go'][k] for k in ['code','stdout','stderr']), (name,expected))
 (R/'raw.json').write_text(json.dumps(raw,indent=2));print('DONE',name,threads,flush=True)
for label in ['new_easy','original_medium','original_hard','new_unsolvable','new_multi_solution','new_complete']:
 for cmd in ['solve','count','rate']:measure(cmd+'_'+label,[cmd,corpus[label]])
for seed in [0,7,42]:
 for target in [36,28]:measure('generate_seed%d_clues%d'%(seed,target),['generate','--seed',str(seed),'--count','1','--clues',str(target)])
measure('generate_100_clues36',['generate','--seed','1','--count','100','--clues','36'])
# Same pre-materialized generated corpus in both languages. Generation excluded
# from bench's internal timer, but included in separate generation measurements.
p=run('go',['generate','--seed','1','--count','100','--clues','36'],1);require(p['code']==0, "p['code']==0")
base=p['stdout'].splitlines();batch=R/'batch-10000.txt';batch.write_text('\n'.join(base*100)+'\n')
mix=R/'batch-mixed-1000.txt';mixbase=[corpus[x] for x in ['new_easy','original_medium','original_hard','new_complete']];mix.write_text('\n'.join(mixbase*250)+'\n')
for threads in [1,8,16]:
 for name,path,n in [('easy10000',batch,10000),('mixed1000',mix,1000)]:
  measure('bench_'+name,['bench',str(path)],threads,reps=7,bench_n=n)
  measure('batch_solve_'+name,['batch',str(path),'solve'],threads,reps=7)
summary=[]
for case,threads in dict.fromkeys((r['case'],r['threads']) for r in raw):
 row={'case':case,'threads':threads}
 for engine in BINS:
  rs=[r for r in raw if r['case']==case and r['threads']==threads and r['engine']==engine and not r['warmup']]
  times=[r['wall_ms'] for r in rs];q=statistics.quantiles(times,n=4);row[engine]={'n':len(times),'median_ms':statistics.median(times),'p25_ms':q[0],'p75_ms':q[2],'min_ms':min(times),'max_ms':max(times),'exit_codes':sorted(set(r['code'] for r in rs))}
  ks=[r['kernel_ms'] for r in rs if r.get('kernel_ms') is not None]
  if ks:row[engine]['internal_raw_ms']=ks;row[engine]['internal_median_ms']=statistics.median(ks)
 row['bend_over_go']=row['bend']['median_ms']/row['go']['median_ms'];summary.append(row)
meta={'date_utc':time.strftime('%Y-%m-%dT%H:%M:%SZ',time.gmtime()),'source_base_commit':'42d465a8d089e5d4662d892bc14da183cafef7ba','optimized_source_sha256':{str(p.relative_to(REPO)):hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted((REPO).rglob('*.bend'))},'go':'go1.27.1 linux/amd64','bend':json.loads((REPO/'toolchain.lock.json').read_text())['bend']['version'],'clang':json.loads((REPO/'toolchain.lock.json').read_text())['clang']['version'],'toolchain_metadata_source':'project lock; supplied binary hashes recorded separately','cpu':next(x.split(':',1)[1].strip() for x in pathlib.Path('/proc/cpuinfo').read_text().splitlines() if x.startswith('model name')),'platform':platform.platform(),'cpus':os.cpu_count(),'affinity':sorted(os.sched_getaffinity(0)),'warmups':2,'ordering':'alternating Bend/Go per repetition','scope':'native fresh process wall time including startup/read/parse/work/write/capture; internal bench includes solve+solution validation and parallel reduction, excludes preparation','gc':'default Go GC; no tuning','corpus_sha256':{p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in [batch,mix]},'binaries_sha256':{k:hashlib.sha256(pathlib.Path(v).read_bytes()).hexdigest() for k,v in BINS.items()}}
(R/'summary.json').write_text(json.dumps({'metadata':meta,'results':summary},indent=2));print(json.dumps(summary,indent=2))
