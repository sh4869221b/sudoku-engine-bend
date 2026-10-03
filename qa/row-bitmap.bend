import Base
import ../sudoku/candidates.bend as C
import ./row-reference-candidates.bend as Ref
import ../sudoku/parser.bend as P
import ./row-reference-parser.bend as RP
import ../sudoku/queuedcandidates.bend as Q
import ../sudoku/board.bend as B
import ../sudoku/prng.bend as R

# Only the newly assigned row high bits differ from the frozen52 reference.
def word(+pos: U32, +x: U32) -> U32:
  Bool.pick(U32, (pos >= 81 : U32) && (pos < 90 : U32), U32.and(x, 1023), x)

def equal_words(n: Nat, +pos: U32, a: Array<U32> & U32, b: Array<U32> & U32) -> Bool:
  match n a b:
    case 0n _ _:
      True{}
    case 1n+k Tuple{aa, x} Tuple{bb, y}:
      U32.is_eq(word(pos, x), word(pos, y)) && equal_words(k, (pos + 1 : U32), Array.get(U32, aa, (pos + 1 : U32)), Array.get(U32, bb, (pos + 1 : U32)))

# Independently rebuild all empty-column bits from the logical81 cells.
def empties(n: Nat, +pos: U32, +col: U32, mask: U32, r: Array<U32> & U32) -> Array<U32> & U32:
  match n:
    case 0n:
      (Pair.fst(Array<U32>, U32, r), mask)
    case 1n+k:
      (b, digit) = r
      empties(k, (pos + 1 : U32), (col + 1 : U32), U32.or(mask, Bool.pick(U32, U32.is_eq(digit, 0), B.bit(col), 0)), Array.get(U32, b, (pos + 1 : U32)))

def row_checked(expected: U32, ok: Bool, r: Array<U32> & U32) -> Array<U32> & Bool:
  (b, +actual) = r
  (b, ok && U32.is_eq(U32.and(U32.shrn(actual, 10n), 511), expected) && U32.is_eq(U32.shrn(actual, 19n), 0))

def row_expected(+row: U32, ok: Bool, r: Array<U32> & U32) -> Array<U32> & Bool:
  (b, expected) = r
  row_checked(expected, ok, Array.get(U32, b, (81 + row : U32)))

def representation(n: Nat, +row: U32, r: Array<U32> & Bool) -> Bool:
  match n:
    case 0n:
      Pair.snd(Array<U32>, Bool, r)
    case 1n+k:
      (b, ok) = r
      representation(k, (row + 1 : U32), row_expected(row, ok, empties(9n, (row * 9 : U32), 0, 0, Array.get(U32, b, (row * 9 : U32)))))

def same(a: C.Choice, b: Ref.Choice) -> Bool:
  match a b:
    case C.Choice{pa, ma, sa} Ref.Choice{pb, mb, sb}:
      U32.is_eq(pa, pb) && U32.is_eq(ma, mb) && U32.is_eq(sa, sb)

def arrays(reference: Array<U32>, pair: Array<U32> & Array<U32>) -> Bool:
  (candidate, checked) = pair
  representation(9n, 0, (checked, True{})) && equal_words(128n, 0, Array.get(U32, candidate, 0), Array.get(U32, reference, 0))

def choices(a: Array<U32> & C.Choice, b: Array<U32> & Ref.Choice) -> Bool:
  (aa, x) = a
  (bb, y) = b
  same(x, y) && arrays(bb, Array.clone(U32, aa))

def boards(candidate: Array<U32>, reference: Array<U32>) -> Bool:
  choices(C.cached_select(candidate), Ref.cached_select(reference))

def active(candidate: Array<U32>, reference: Array<U32>) -> Bool:
  equal_words(128n, 0, Array.get(U32, Q.encode(candidate), 0), Array.get(U32, Q.encode(reference), 0))

def all(a: Array<U32> & Array<U32>, b: Array<U32> & Array<U32>) -> Bool:
  (candidate, encoded) = a
  (reference, encoded_ref) = b
  boards(candidate, reference) && active(encoded, encoded_ref)

def cached(pair: Array<U32> & Array<U32>) -> Bool:
  (candidate, reference) = pair
  all(Array.clone(U32, C.cache(candidate)), Array.clone(U32, Ref.cache(reference)))

def prepared(a: P.Parsed, b: RP.Parsed) -> Bool:
  match a b:
    case P.ParseError{x} RP.ParseError{y}:
      String.eq(x, y)
    case P.ParsedBoard{candidate} RP.ParsedBoard{reference}:
      all(Array.clone(U32, candidate), Array.clone(U32, reference))
    case _ _:
      False{}

def prepare(+text: String) -> Bool:
  prepared(P.prepare81(text), RP.prepare81(text))

def solved_digit(+pos: U32) -> U32:
  +row = (pos / 9 : U32)
  (1 + ((row * 3 + row / 3 + pos % 9) % 9) : U32)

def value(mode: U32, pos: U32, +seed: U32, density: U32) -> U32:
  match mode:
    case 0:
      Bool.pick(U32, (U32.and(seed, 15) < density : U32), solved_digit(pos), 0)
    case 1:
      (seed % 10 : U32)
    case 2:
      Bool.pick(U32, U32.is_eq(U32.and(seed, 3), 0), 0, seed)
    case _:
      (seed % 34 : U32)

def board(n: Nat, +pos: U32, +mode: U32, +seed: U32, +density: U32, b: Array<U32>) -> Array<U32>:
  match n:
    case 0n:
      b
    case 1n+k:
      board(k, (pos + 1 : U32), mode, R.next(seed), density, Array.set(U32, b, pos, value(mode, pos, seed, density)))

def cache_cases(n: Nat, +mode: U32, +seed: U32) -> Bool:
  match n:
    case 0n:
      True{}
    case 1n+k:
      cached(Array.clone(U32, board(81n, 0, mode, seed, U32.and(U32.shrn(seed, 8n), 15), B.empty()))) && cache_cases(k, mode, R.next(seed))

def prepare_cases(n: Nat, +seed: U32) -> Bool:
  match n:
    case 0n:
      True{}
    case 1n+k:
      prepare(B.show(board(81n, 0, 0, seed, U32.and(U32.shrn(seed, 8n), 15), B.empty()))) && prepare_cases(k, R.next(seed))

def swapped(a: Array<U32> & U32, b: Array<U32> & U32) -> Bool:
  (candidate, old) = a
  (reference, prior) = b
  U32.is_eq(old, prior) && all(Array.clone(U32, candidate), Array.clone(U32, reference))

def swap_case(+pos: U32, +digit: U32, pair: Array<U32> & Array<U32>) -> Bool:
  (candidate, reference) = pair
  swapped(C.swap(C.cache(candidate), pos, digit), Ref.swap(Ref.cache(reference), pos, digit))

def swap_positions(n: Nat, +pos: U32, +digit: U32, +seed: U32) -> Bool:
  match n:
    case 0n:
      True{}
    case 1n+k:
      swap_case(pos, digit, Array.clone(U32, board(81n, 0, U32.and(seed, 3), seed, 9, B.empty()))) && swap_positions(k, (pos + 1 : U32), digit, R.next(seed))

def swap_digits(n: Nat, +digit: U32, +seed: U32) -> Bool:
  match n:
    case 0n:
      True{}
    case 1n+k:
      swap_positions(81n, 0, digit, seed) && swap_digits(k, (digit + 1 : U32), R.next(seed))

def emit(ok: Bool) -> IO(Unit):
  match ok:
    case True{}:
      IO.print("PASS packed row empties:4096 cached valid/arbitrary/wide boards,1024 prepared boards,891 all-position swaps;independent81-cell bitmap rebuild,low occupancy/start/padding,exact MRV,activation masks versus frozen52")
    case False{}:
      IO.die(Unit, 1, "FAIL packed row empties")

def main() -> IO(Unit):
  emit(cache_cases(1024n, 0, 1) && cache_cases(1024n, 1, 19088743) && cache_cases(1024n, 2, 4294967295) && cache_cases(1024n, 3, 2654435769) && prepare_cases(1024n, 42) && swap_digits(10n, 0, 12345) && swap_positions(81n, 0, 31, 76543) && prepare("123456789456789123789123456234567891567891234891234567345678912678912345912345678") && prepare("000000000000000000000000000000000000000000000000000000000000000000000000000000000") && prepare("bad"))
