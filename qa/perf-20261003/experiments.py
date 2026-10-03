#!/usr/bin/env python3
"""Ten independently reproducible structural optimizations; preserve rejected patches."""
import pathlib,subprocess,os,json,hashlib,re,shutil,time
ROOT=pathlib.Path(__file__).resolve().parents[2]; os.chdir(ROOT)
OUT=ROOT/'qa/perf-20261003/results';OUT.mkdir(exist_ok=True)
BASE=ROOT.parent/'baseline';CORP=ROOT.parent/'corpora'
FILES=['sudoku/board.bend','sudoku/candidates.bend','sudoku/search.bend','sudoku/validate.bend','sudoku/parser.bend']
initial={p:pathlib.Path(p).read_text() for p in FILES}
def replace_def(s,name,new):
 pat=r'^def '+re.escape(name)+r'\(.*?(?=^def |^type |\Z)'
 assert re.search(pat,s,re.M|re.S),name
 return re.sub(pat,new.strip()+'\n\n',s,count=1,flags=re.M|re.S)
def order_defs(text):
 # Bend requires callees to be filled before use; stable topological insertion.
 pattern=r'^def (\w+)\(.*?(?=^def |^type |\Z)'
 matches=list(re.finditer(pattern,text,re.M|re.S))
 byname={m[1]:m[0] for m in matches};ordered=[];visiting=set();seen=set()
 def visit(name):
  if name in seen:return
  if name in visiting:raise RuntimeError('mutual recursion '+name)
  visiting.add(name)
  for other in byname:
   if other!=name and re.search(r'(?<![\w.])'+re.escape(other)+r'\s*\(',byname[name].split('\n',1)[1]):visit(other)
  visiting.remove(name);seen.add(name);ordered.append(name)
 for name in byname:visit(name)
 if ordered==list(byname):return text
 # Keep imports and types in their original order before functions.
 remainder=re.sub(pattern,'',text,flags=re.M|re.S)
 return remainder+''.join(byname[name] for name in ordered)
def variant(n,src):
 s=dict(src);b=s['sudoku/board.bend'];c=s['sudoku/candidates.bend']
 if n==1:
  c=replace_def(c,'cache','''def cache(b: Array<U32>) -> Array<U32>:
  refresh_start(cache_cells(81n, 0, clear_units(27n, 81, b)), 0)

def clear_units(n: Nat, +pos: U32, b: Array<U32>) -> Array<U32>:
  match n:
    case 0n:
      b
    case 1n+k:
      clear_units(k, (pos + 1 : U32), Array.set(U32, b, pos, 0))

def cache_or(+pos: U32, bit: U32, b: Array<U32>) -> Array<U32>:
  cache_or_done(pos, bit, Array.get(U32, b, pos))

def cache_or_done(pos: U32, bit: U32, r: Array<U32> & U32) -> Array<U32>:
  (next, used) = r
  Array.set(U32, next, pos, U32.or(used, bit))

def cache_cells(n: Nat, +pos: U32, b: Array<U32>) -> Array<U32>:
  match n:
    case 0n:
      b
    case 1n+k:
      cache_cells(k, (pos + 1 : U32), cache_cell_done(pos, Array.get(U32, b, pos)))

def cache_cell_done(+pos: U32, r: Array<U32> & U32) -> Array<U32>:
      (next, d) = r
      +bit = B.bit(d)
      cache_or((99 + B.box_of(pos) : U32), bit, cache_or((90 + pos % 9 : U32), bit, cache_or((81 + pos / 9 : U32), bit, next)))''')
 if n==2:
  b=replace_def(b,'bit','def bit(+d: U32) -> U32:\n  match d:\n'+''.join(f'    case {i}:\n      {1<<i}\n' for i in range(10))+'    case _:\n      U32.shln(1, U32.to_nat(d))')
 if n==3:
  x=s['sudoku/search.bend'];x=x.replace('+digit = C.mask_count((bit - 1 : U32))','+digit = bit_digit(bit)')
  x+='\ndef bit_digit(+bit: U32) -> U32:\n  match bit:\n'+''.join(f'    case {1<<i}:\n      {i}\n' for i in range(1,10))+'    case _:\n      C.mask_count((bit - 1 : U32))\n'
  s['sudoku/search.bend']=x
 if n==4:
  b=replace_def(b,'unit_pos','''def unit_pos(+unit: U32, +j: U32) -> U32:
  unit_row((unit < 9 : U32), unit, j)

def unit_row(row: Bool, +unit: U32, +j: U32) -> U32:
  match row:
    case True{}:
      (unit * 9 + j : U32)
    case False{}:
      unit_col((unit < 18 : U32), unit, j)

def unit_col(col: Bool, +unit: U32, +j: U32) -> U32:
  match col:
    case True{}:
      (j * 9 + unit - 9 : U32)
    case False{}:
      (((unit - 18) / 3) * 27 + ((unit - 18) % 3) * 3 + (j / 3) * 9 + j % 3 : U32)''')
 if n==5:
  x=s['sudoku/validate.bend']
  x=x.replace('go(k, (unit + 1 : U32), next_reason(unit, prior, unit_go(9n, unit, 0, Array.get(U32, b, B.unit_pos(unit, 0)), 0, True{})))','''match prior:
        case SNil{}:
          go(k, (unit + 1 : U32), next_reason(unit, "", unit_go(9n, unit, 0, Array.get(U32, b, B.unit_pos(unit, 0)), 0, True{})))
        case SCon{h, tail}:
          (b, SCon{h, tail})''')
  s['sudoku/validate.bend']=x
 if n==6:
  x=s['sudoku/parser.bend']
  x=x.replace("+valid = ((d >= 48 : U32) && (d <= 57 : U32)) || Char.is_eq(h, '.')", "+digit = (d - 48 : U32)\n          +numeric = (digit <= 9 : U32)\n          +valid = numeric || Char.is_eq(h, '.')")
  x=x.replace('+v = Bool.pick(U32, (d >= 48 : U32) && (d <= 57 : U32), (d - 48 : U32), 0)', '+v = Bool.pick(U32, numeric, digit, 0)')
  s['sudoku/parser.bend']=x
 if n==7:
  b=replace_def(b,'show','''def show(b: Array<U32>) -> String:
  show_reverse(81n, 80, (b, ""))

def show_reverse_cell(acc: String, r: Array<U32> & U32) -> Array<U32> & String:
  (next, +d) = r
  (next, show_digit((d <= 9 : U32), d, acc))

def show_reverse(+n: Nat, +pos: U32, r: Array<U32> & String) -> String:
  match n:
    case 0n:
      Pair.snd(Array<U32>, String, r)
    case 1n+k:
      (b, acc) = r
      show_reverse(k, (pos - 1 : U32), show_reverse_cell(acc, Array.get(U32, b, pos)))''')
 if n==8:
  c=c.replace('''    case 1n+k:
      (b, d) = r
      used_go(k, unit''','''    case 1n:
      (b, d) = r
      (b, U32.or(used, B.bit(d)))
    case 2n+k:
      (b, d) = r
      used_go(1n+k, unit''',1)
 if n==9:
  c=c.replace('+n = mask_count(mask)','+n = fast_count(mask)',1)
  c+='''\ndef fast_count(+mask: U32) -> U32:
  fast_count_if(U32.is_eq(U32.and(mask, (mask - 1 : U32)), 0), mask)

def fast_count_if(single: Bool, +mask: U32) -> U32:
  match single:
    case True{}:
      Bool.pick(U32, U32.is_eq(mask, 0), 0, 1)
    case False{}:
      mask_count(mask)
'''
 if n==10:
  c=replace_def(c,'update_done','''def update_done(pos: U32, +old: U32, value: U32, r: Array<U32> & U32) -> Array<U32>:
  match old:
    case 0:
      (b, used) = r
      Array.set(U32, b, pos, U32.or(U32.and(used, 4294967294), B.bit(value)))
    case +digit:
      (b, used) = r
      Array.set(U32, b, pos, U32.or(U32.and(used, U32.not(B.bit(digit))), B.bit(value)))''')
 s['sudoku/board.bend']=b;s['sudoku/candidates.bend']=c;return {p:order_defs(t) for p,t in s.items()}
NAMES=['single-pass occupancy initialization','bounded digit bit lookup','least-bit digit decoding','branch-specific unit indexing','validation stop after first error','single unsigned parser range check','reverse board rendering accumulator','remove redundant unit read','singleton candidate count fast path','specialized blank occupancy update']
def run(args,log,env=None):
 with pathlib.Path(log).open('w') as f:r=subprocess.run(args,stdout=f,stderr=subprocess.STDOUT,env=env)
 return r.returncode
# Obtain locked environment exactly as build.sh does.
env=dict(os.environ)
exports=subprocess.check_output(['python3','qa/toolchain.py','env'],text=True)
import shlex
for line in exports.splitlines():
 k,v=line[len('export '):].split('=',1);env[k]=shlex.split(v)[0]
def quick(binary,out):
 records=[]
 for name in ['verification.txt','hard-100.txt','rate-300.txt']:
  for mode in ['solve','check','count','rate']:
   args=['--threads','1','--','batch',str(CORP/name),mode]
   pair=[subprocess.run([str(x),*args],capture_output=True,timeout=180) for x in [BASE,binary]]
   assert all((r.returncode,r.stdout,r.stderr)==(pair[0].returncode,pair[0].stdout,pair[0].stderr) for r in pair), (name,mode)
   records.append({'corpus':name,'mode':mode,'sha256':hashlib.sha256(pair[1].stdout).hexdigest(),'exit':pair[1].returncode})
 for seed in [0,42,4294967295]:
  args=['--threads','1','--','generate','--seed',str(seed),'--count','3','--clues','32']
  pair=[subprocess.run([str(x),*args],capture_output=True,timeout=180) for x in [BASE,binary]]
  assert (pair[0].returncode,pair[0].stdout,pair[0].stderr)==(pair[1].returncode,pair[1].stdout,pair[1].stderr)
  records.append({'seed':seed,'sha256':hashlib.sha256(pair[1].stdout).hexdigest()})
 out.write_text(json.dumps({'status':'PASS','records':records},indent=2)+'\n')
import sys
accepted=dict(initial);records=json.loads((OUT/'ledger.json').read_text()) if len(sys.argv)>1 else []
for n in ([int(x) for x in sys.argv[1:]] if len(sys.argv)>1 else range(1,11)):
 records=[r for r in records if r['number']!=n]
 print('START',n,NAMES[n-1],flush=True);folder=OUT/f'{n:02}';folder.mkdir(exist_ok=True)
 src=variant(n,accepted)
 for p,t in src.items():pathlib.Path(p).write_text(t)
 (folder/'change.patch').write_bytes(subprocess.check_output(['git','diff','--',*FILES]))
 r={'number':n,'idea':NAMES[n-1],'accepted':False}
 if run(['./build.sh'],folder/'build.log'):
  r['status']='BUILD FAILED';records.append(r);print(r,flush=True)
  for p,t in accepted.items():pathlib.Path(p).write_text(t)
  (OUT/'ledger.json').write_text(json.dumps(records,indent=2)+'\n');continue
 shutil.copy2('bin/bend-sudoku',folder/'binary')
 try:
  quick(folder/'binary',folder/'correctness.json')
  if run(['python3','qa/empty_search_state.py'],folder/'fuel.log',env):raise RuntimeError('fuel golden failed')
  shutil.copy2('.omo/evidence/empty-search-state.json',folder/'fuel.json')
  code=run(['python3','qa/perf-20261001/measure.py','--base',str(BASE),'--candidate',str(folder/'binary'),'--cases','qa/perf-20261003/screen-cases.json','--corpora',str(CORP),'--out',str(folder/'screen.json'),'--reps','9'],folder/'screen.log')
  if code:raise RuntimeError('screen failed')
  rows=json.loads((folder/'screen.json').read_text())['summary'];r['screen_speedup']=sum(x['baseline']['wall_ms']['median'] for x in rows)/sum(x['candidate']['wall_ms']['median'] for x in rows);r['cases']={x['case']:x['speedup'] for x in rows};r['status']='TESTED'
  if r['screen_speedup']>=1.03 and max(r['cases'].values())>=1.05:
   r['status']='AWAITING CONFIRMATION'
  print(json.dumps(r),flush=True)
 except Exception as e:r['status']='CORRECTNESS FAILED';r['error']=repr(e);print(r,flush=True)
 records.append(r)
 for p,t in accepted.items():pathlib.Path(p).write_text(t)
 (OUT/'ledger.json').write_text(json.dumps(records,indent=2)+'\n')
print('DONE TEN SCREENS',flush=True)
