import Base
import ../sudoku/queuedcandidates.bend as Q
import ../sudoku/adaptivesearch.bend as F
import ../sudoku/candidates.bend as C
import ../sudoku/parser.bend as P
import ../sudoku/board.bend as B
import ../sudoku/generator.bend as G

# Compare active masks, every urgency flag and the exact selected position/mask.
# The reference recomputes occupancy from a separately decoded logical board.
def flag_checked(+pos: U32, +word: U32, reference: Array<U32>, +ok: Bool, r: Array<U32> & U32) -> Array<U32> & Array<U32> & Bool:
  (encoded, +flags) = r
  +urgent = (word < 1024 : U32) && U32.is_eq(U32.and(word, (word - 1 : U32)), 0)
  +actual = U32.is_ne(U32.and(flags, U32.shln(1, U32.to_nat((pos % 32 : U32)))), 0)
  (encoded, (reference, ok && U32.is_eq(Bool.pick(U32, urgent, 1, 0), Bool.pick(U32, actual, 1, 0))))

def mask_checked(+pos: U32, +word: U32, encoded: Array<U32>, +ok: Bool, r: Array<U32> & U32) -> Array<U32> & Array<U32> & Bool:
  (reference, expected) = r
  flag_checked(pos, word, reference, ok && ((word >= 1024 : U32) || U32.is_eq(word, expected)), Array.get(U32, encoded, (109 + (pos / 32) : U32)))

def cell_checked(+pos: U32, reference: Array<U32>, ok: Bool, r: Array<U32> & U32) -> Array<U32> & Array<U32> & Bool:
  (encoded, word) = r
  mask_checked(pos, word, encoded, ok, C.cached_at(reference, pos))

def cells(n: Nat, +pos: U32, r: Array<U32> & Array<U32> & Bool) -> Bool:
  match n:
    case 0n:
      (encoded, (reference, ok)) = r
      ok
    case 1n+k:
      (encoded, (reference, ok)) = r
      cells(k, (pos + 1 : U32), cell_checked(pos, reference, ok, Array.get(U32, encoded, pos)))

def same(a: C.Choice, b: C.Choice) -> Bool:
  match a b:
    case C.Choice{pa, ma, sa} C.Choice{pb, mb, sb}:
      U32.is_eq(pa, pb) && U32.is_eq(ma, mb) && U32.is_eq(sa, sb)

def choices(r: Array<U32> & C.Choice, t: Array<U32> & C.Choice) -> Bool:
  (encoded, a) = r
  (reference, b) = t
  same(a, b)

def check_masks(pair: Array<U32> & Array<U32>) -> Bool:
  (encoded, raw) = pair
  cells(81n, 0, (encoded, (C.cache(Q.decode(81n, 0, raw)), True{})))

def check_choice(pair: Array<U32> & Array<U32>) -> Bool:
  (encoded, raw) = pair
  choices(Q.select(encoded), C.cached_select(C.cache(Q.decode(81n, 0, raw))))

def check_pair(pair: Array<U32> & Array<U32>) -> Bool:
  (encoded, again) = pair
  check_masks(Array.clone(U32, encoded)) && check_choice(Array.clone(U32, again))

def checked(active: Bool, pair: Array<U32> & Array<U32>) -> Array<U32> & Bool:
  match active pair:
    case False{} Tuple{board, spare}:
      (board, True{})
    case True{} Tuple{board, spare}:
      (board, check_pair(Array.clone(U32, spare)))

def forward(+limit: U32, frames: Array<U32>, depth: U32, found: U32, snapshots: List<&1, Array<U32>>, +active: Bool, r: Array<U32> & Bool) -> F.State & Bool:
  (board, ok) = r
  (F.selected(limit, frames, depth, found, snapshots, active, F.selection(active, board)), ok)

def step(+limit: U32, state: F.State) -> F.State & Bool:
  match state:
    case F.Searching{board, frames, depth, found, snapshots, +active}:
      forward(limit, frames, depth, found, snapshots, active, checked(active, Array.clone(U32, board)))
    case F.Backtracking{board, frames, +depth, found, snapshots, active}:
      (F.backtrack(U32.is_eq(depth, 0), frames, depth, found, snapshots, active, board), True{})
    case F.SnapshotDone{found, answer}:
      (F.SnapshotDone{found, answer}, True{})
    case F.SnapshotFuel{}:
      (F.SnapshotFuel{}, False{})

def trace(n: Nat, +limit: U32, r: F.State & Bool) -> Bool:
  match n:
    case 0n:
      Pair.snd(F.State, Bool, r)
    case 1n+k:
      (state, ok) = r
      ok && trace(k, limit, step(limit, state))

def parsed(p: P.Parsed, +limit: U32) -> Bool:
  match p:
    case P.ParseError{reason}:
      False{}
    case P.ParsedBoard{b}:
      trace(6000n, limit, (F.Searching{C.cache(b), [0 : U32*128n], 0, 0, Nil{}, False{}}, True{}))

def bits(n: Nat, +i: U32) -> Bool:
  match n:
    case 0n:
      True{}
    case 1n+k:
      U32.is_eq(Q.trailing(U32.shrn((U32.shln(1, U32.to_nat(i)) * 125613361 : U32), 27n)), i) && bits(k, (i + 1 : U32))

def reference_cell(+pos: U32, prior: C.Choice, r: Array<U32> & U32) -> Array<U32> & C.Choice:
  match prior:
    case C.Choice{+p, +m, +size}:
      (b, +word) = r
      +count = Bool.pick(U32, (word >= 1024 : U32), 10, C.pop(10n, word, 0))
      +better = (count < size : U32)
      (b, C.Choice{Bool.pick(U32, better, pos, p), Bool.pick(U32, better, word, m), Bool.pick(U32, better, count, size)})

def reference_scan(n: Nat, +pos: U32, r: Array<U32> & C.Choice) -> Array<U32> & C.Choice:
  match n r:
    case _ Tuple{b, C.Choice{p, m, 0}}:
      (b, C.Choice{p, m, 0})
    case _ Tuple{b, C.Choice{p, m, 1}}:
      (b, C.Choice{p, m, 1})
    case 0n Tuple{b, C.Choice{p, m, size}}:
      (b, C.Choice{p, m, size})
    case 1n+k Tuple{b, prior}:
      reference_scan(k, (pos + 1 : U32), reference_cell(pos, prior, Array.get(U32, b, pos)))

def domain_flag(urgent: Bool, +pos: U32, b: Array<U32>) -> Array<U32>:
  match urgent:
    case False{}:
      b
    case True{}:
      Q.flag(b, pos, True{})

def domains(n: Nat, +pos: U32, +seed: U32, b: Array<U32>) -> Array<U32>:
  match n:
    case 0n:
      b
    case 1n+k:
      +word = Bool.pick(U32, U32.is_ne(U32.and(seed, 1024), 0), 1024, U32.and(seed, 1022))
      domains(k, (pos + 1 : U32), G.next(seed), domain_flag((word < 1024 : U32) && U32.is_eq(U32.and(word, (word - 1 : U32)), 0), pos, Array.set(U32, b, pos, word)))

def domain_compared(pair: Array<U32> & Array<U32>) -> Bool:
  (a, b) = pair
  choices(Q.select(a), reference_scan(81n, 0, (b, C.Choice{81, 0, 10})))

def random_domains(n: Nat, +seed: U32) -> Bool:
  match n:
    case 0n:
      True{}
    case 1n+k:
      domain_compared(Array.clone(U32, domains(81n, 0, seed, B.empty()))) && random_domains(k, G.next(seed))

def emit(ok: Bool) -> IO(Unit):
  match ok:
    case True{}:
      IO.print("PASS adaptive candidate masks,81 urgency bits,exact MRV choices during24000 trace steps (active forward states checked);1024arbitrary domain tie cases;32 trailing-bit indices")
    case False{}:
      IO.die(Unit, 1, "FAIL adaptive candidate invariant")

def main() -> IO(Unit):
  emit(bits(32n, 0) && random_domains(1024n, 1) && parsed(P.parse81("530070000600195000098000060800060003400803001700020006060000280000419005000080079"), 2) && parsed(P.parse81("100007090030020008009600500005300900010080002600004000300000010040000007007000300"), 2) && parsed(P.parse81("000000000000000000000000000000000000000000000000000000000000000000000000000000000"), 2) && parsed(P.parse81("123456780000000009000000000000000000000000000000000000000000000000000000000000000"), 2))
