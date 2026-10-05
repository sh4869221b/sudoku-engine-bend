import Base
import ../sudoku/queuedcandidates.bend as Q
import ../sudoku/candidates.bend as C
import ../sudoku/board.bend as B
import ../sudoku/prng.bend as R

# Frozen full encoder: clear flags, then use the unchanged public helpers.
def reference(b: Array<U32>) -> Array<U32>:
  Q.encode_go(81n, 0, Array.set(U32, Array.set(U32, Array.set(U32, b, 109, 0), 110, 0), 111, 0))

def equal_words(n: Nat, +pos: U32, a: Array<U32> & U32, b: Array<U32> & U32) -> Bool:
  match n a b:
    case 0n _ _:
      True{}
    case 1n Tuple{aa, x} Tuple{bb, y}:
      U32.is_eq(x, y)
    case 1n+k Tuple{aa, x} Tuple{bb, y}:
      U32.is_eq(x, y) && equal_words(k, (pos + 1 : U32), Array.get(U32, aa, (pos + 1 : U32)), Array.get(U32, bb, (pos + 1 : U32)))

def compared(pair: Array<U32> & Array<U32>) -> Bool:
  (candidate, old) = pair
  equal_words(128n, 0, Array.get(U32, Q.encode(candidate), 0), Array.get(U32, reference(old), 0))

def stale(b: Array<U32>) -> Array<U32>:
  Array.set(U32, Array.set(U32, Array.set(U32, Array.set(U32, b, 109, 4294967295), 110, 2863311530), 111, 1431655765), 127, 305419896)

def check(b: Array<U32>) -> Bool:
  compared(Array.clone(U32, stale(b)))

def solved_digit(+pos: U32) -> U32:
  +row = (pos / 9 : U32)
  (1 + ((row * 3 + row / 3 + pos % 9) % 9) : U32)

def value(mode: U32, pos: U32, +seed: U32, density: U32) -> U32:
  match mode:
    case 0:
      Bool.pick(U32, (U32.and(seed, 15) < density : U32), solved_digit(pos), 0)
    case 1:
      (seed % 10 : U32)
    case _:
      Bool.pick(U32, U32.is_eq(U32.and(seed, 3), 0), 0, seed)

def board(n: Nat, +pos: U32, +mode: U32, +seed: U32, +density: U32, b: Array<U32>) -> Array<U32>:
  match n:
    case 0n:
      b
    case 1n+k:
      board(k, (pos + 1 : U32), mode, R.next(seed), density, Array.set(U32, b, pos, value(mode, pos, seed, density)))

def random_cases(n: Nat, +mode: U32, +seed: U32) -> Bool:
  match n:
    case 0n:
      True{}
    case 1n+k:
      check(C.cache(board(81n, 0, mode, seed, U32.and(U32.shrn(seed, 8n), 15), B.empty()))) && random_cases(k, mode, R.next(seed))

def complete() -> Array<U32>:
  board(81n, 0, 0, 1, 16, B.empty())

def blank_at(+pos: U32) -> Array<U32>:
  C.cache(Array.set(U32, complete(), pos, 0))

def flags_equal(expected: U32, r: Array<U32> & U32) -> Bool:
  (b, word) = r
  U32.is_eq(word, expected)

def urgent_boundary(+pos: U32) -> Bool:
  check(blank_at(pos)) && flags_equal(U32.shln(1, U32.to_nat(U32.and(pos, 31))), Array.get(U32, Q.encode(stale(blank_at(pos))), (109 + U32.shrn(pos, 5n) : U32)))

# All blank candidates zero checks every urgency bit, including upper unused
# bits in word111. Cached occupancy may be arbitrary; encoder does not repair it.
def zero_units(n: Nat, +slot: U32, b: Array<U32>) -> Array<U32>:
  match n:
    case 0n:
      b
    case 1n+k:
      zero_units(k, (slot + 1 : U32), Array.set(U32, b, slot, 1022))

def zero_board() -> Array<U32>:
  zero_units(27n, 81, C.cache(B.empty()))

def zero_flags() -> Bool:
  check(zero_board()) &&
  flags_equal(4294967295, Array.get(U32, Q.encode(stale(zero_board())), 109)) &&
  flags_equal(4294967295, Array.get(U32, Q.encode(stale(zero_board())), 110)) &&
  flags_equal(131071, Array.get(U32, Q.encode(stale(zero_board())), 111))

def emit(ok: Bool) -> IO(Unit):
  match ok:
    case True{}:
      IO.print("PASS encode flags: all128 words versus frozen encoder;256 valid partial,256 arbitrary digit,128 wide cached boards;stale flags;urgent boundaries31/32/63/64/80;complete/empty/all-zero candidates")
    case False{}:
      IO.die(Unit, 1, "FAIL encode flags")

def main() -> IO(Unit):
  emit(check(C.cache(complete())) && check(C.cache(B.empty())) && zero_flags() && urgent_boundary(31) && urgent_boundary(32) && urgent_boundary(63) && urgent_boundary(64) && urgent_boundary(80) && random_cases(256n, 0, 1) && random_cases(256n, 1, 19088743) && random_cases(128n, 2, 2654435769))
