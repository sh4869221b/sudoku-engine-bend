import Base
import ../sudoku/queuedcandidates.bend as Q
import ../sudoku/candidates.bend as C
import ../sudoku/board.bend as B
import ../sudoku/prng.bend as R

# Frozen recursion includes the terminal flag-word read and n=0 dispatch.
def reference(+n: Nat, +base: U32, r: Array<U32> & U32) -> Array<U32> & C.Choice:
  match n:
    case 0n:
      Q.start(Array.get(U32, Pair.fst(Array<U32>, U32, r), 108))
    case 1n+k:
      (b, bits) = r
      match bits:
        case 0:
          reference(k, (base + 32 : U32), Array.get(U32, b, (110 + U32.shrn(base, 5n) : U32)))
        case +word:
          +bit = U32.and(word, (0 - word : U32))
          +pos = (base + Q.trailing(U32.shrn((bit * 125613361 : U32), 27n)) : U32)
          Q.urgent(pos, Array.get(U32, b, pos))

def same(a: C.Choice, b: C.Choice) -> Bool:
  match a b:
    case C.Choice{pa, ma, sa} C.Choice{pb, mb, sb}:
      U32.is_eq(pa, pb) && U32.is_eq(ma, mb) && U32.is_eq(sa, sb)

def equal_words(n: Nat, +pos: U32, a: Array<U32> & U32, b: Array<U32> & U32) -> Bool:
  match n a b:
    case 0n _ _:
      True{}
    case 1n Tuple{aa, x} Tuple{bb, y}:
      U32.is_eq(x, y)
    case 1n+k Tuple{aa, x} Tuple{bb, y}:
      U32.is_eq(x, y) && equal_words(k, (pos + 1 : U32), Array.get(U32, aa, (pos + 1 : U32)), Array.get(U32, bb, (pos + 1 : U32)))

def results(a: Array<U32> & C.Choice, b: Array<U32> & C.Choice) -> Bool:
  (aa, x) = a
  (bb, y) = b
  same(x, y) && equal_words(128n, 0, Array.get(U32, aa, 0), Array.get(U32, bb, 0))

def compared(+n: Nat, +base: U32, +bits: U32, pair: Array<U32> & Array<U32>) -> Bool:
  (candidate, old) = pair
  results(Q.flags(n, base, (candidate, bits)), reference(n, base, (old, bits)))

def check(+n: Nat, +base: U32, +bits: U32, board: Array<U32>) -> Bool:
  compared(n, base, bits, Array.clone(U32, board))

def board(n: Nat, +pos: U32, +seed: U32, b: Array<U32>) -> Array<U32>:
  match n:
    case 0n:
      b
    case 1n+k:
      board(k, (pos + 1 : U32), R.next(seed), Array.set(U32, b, pos, U32.and(seed, 1022)))

def fixture(+first: U32, second: U32, +third: U32, +seed: U32, +start: U32) -> Array<U32>:
  Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, board(128n, 0, seed, B.empty()), 108, start), 109, first), 110, second), 111, third), 112, 4294967295)

def random_cases(n: Nat, +seed: U32) -> Bool:
  match n:
    case 0n:
      True{}
    case 1n+k:
      check(3n, 0, seed, fixture(seed, R.next(seed), U32.and(R.next(R.next(seed)), 131071), seed, (seed % 82 : U32))) &&
      check(3n, 0, 0, fixture(0, 0, 0, seed, (seed % 82 : U32))) &&
      check(1n, 64, 0, fixture(0, 0, 0, seed, (seed % 82 : U32))) &&
      check(0n, 64, seed, fixture(0, 0, 0, seed, (seed % 82 : U32))) && random_cases(k, R.next(seed))

def expected(+pos: U32, r: Array<U32> & C.Choice) -> Bool:
  (b, choice) = r
  match choice:
    case C.Choice{p, m, size}:
      U32.is_eq(pos, p)

def one(+pos: U32) -> Bool:
  +slot = U32.shrn(pos, 5n)
  +bit = U32.shln(1, U32.to_nat(U32.and(pos, 31)))
  +a = Bool.pick(U32, U32.is_eq(slot, 0), bit, 0)
  +b = Bool.pick(U32, U32.is_eq(slot, 1), bit, 0)
  +c = Bool.pick(U32, U32.is_eq(slot, 2), bit, 0)
  check(3n, 0, a, fixture(a, b, c, 1, 0)) &&
  expected(pos, Q.select(fixture(a, b, c, 1, 0)))

def all_positions(n: Nat, +pos: U32) -> Bool:
  match n:
    case 0n:
      True{}
    case 1n+k:
      one(pos) && all_positions(k, (pos + 1 : U32))

def order() -> Bool:
  expected(31, Q.select(fixture(2147483648, 1, 1, 1, 0))) &&
  expected(32, Q.select(fixture(0, 2147483649, 1, 1, 0))) &&
  expected(63, Q.select(fixture(0, 2147483648, 65537, 1, 0))) &&
  expected(64, Q.select(fixture(0, 0, 65537, 1, 0)))

def emit(ok: Bool) -> IO(Unit):
  match ok:
    case True{}:
      IO.print("PASS terminal flags:2048 frozen-recursion comparisons with all128 words;all81 urgent positions;31/32/63/64/80 boundaries;physical urgency order;arbitrary masks/start;nonzero ignored slot112;zero/one/three-word helper paths")
    case False{}:
      IO.die(Unit, 1, "FAIL terminal flags")

def main() -> IO(Unit):
  emit(random_cases(512n, 2654435769) && all_positions(81n, 0) && order())
