import Base
import ../sudoku/queuedcandidates.bend as Q
import ./refresh-reference.bend as Ref
import ../sudoku/candidates.bend as C
import ../sudoku/board.bend as B
import ../sudoku/prng.bend as R

def equal_words(n: Nat, +pos: U32, a: Array<U32> & U32, b: Array<U32> & U32) -> Bool:
  match n a b:
    case 0n _ _:
      True{}
    case 1n+k Tuple{aa, x} Tuple{bb, y}:
      U32.is_eq(x, y) && equal_words(k, (pos + 1 : U32), Array.get(U32, aa, (pos + 1 : U32)), Array.get(U32, bb, (pos + 1 : U32)))

def flag(urgent: Bool, +pos: U32, b: Array<U32>) -> Array<U32>:
  match urgent:
    case True{}:
      Q.flag(b, pos, True{})
    case False{}:
      b

def domains(n: Nat, +pos: U32, +seed: U32, b: Array<U32>) -> Array<U32>:
  match n:
    case 0n:
      Q.refresh_needed(True{}, b, 0)
    case 1n+k:
      +word = Bool.pick(U32, U32.is_ne(U32.and(seed, 1024), 0), U32.shln((1 + seed % 9 : U32), 10n), U32.and(seed, 1022))
      domains(k, (pos + 1 : U32), R.next(seed), flag((word < 1024 : U32) && U32.is_eq(U32.and(word, (word - 1 : U32)), 0), pos, Array.set(U32, b, pos, word)))

def compared(+guess: Bool, +pos: U32, +digit: U32, pair: Array<U32> & Array<U32>) -> Bool:
  (candidate, reference) = pair
  equal_words(128n, 0, Array.get(U32, Q.place(guess, pos, digit, candidate), 0), Array.get(U32, Ref.place(guess, pos, digit, reference), 0))

def placements(n: Nat, +pos: U32, +digit: U32, +guess: Bool, +seed: U32) -> Bool:
  match n:
    case 0n:
      True{}
    case 1n+k:
      compared(guess, pos, digit, Array.clone(U32, domains(81n, 0, seed, B.empty()))) && placements(k, (pos + 1 : U32), digit, guess, R.next(seed))

def digits(n: Nat, +digit: U32, +guess: Bool, +seed: U32) -> Bool:
  match n:
    case 0n:
      True{}
    case 1n+k:
      placements(81n, 0, digit, guess, seed) && digits(k, (digit + 1 : U32), guess, R.next(seed))

# Frozen swap composition uses the unchanged general prefix-refresh helper.
def old_swapped(+pos: U32, +value: U32, r: Array<U32> & U32) -> Array<U32> & U32:
  (b, +old) = r
  changed = C.update_unit((99 + B.box_of(pos) : U32), old, value, C.update_unit((90 + (pos % 9) : U32), old, value, C.update_row(pos, old, value, b)))
  (C.start_after_set(U32.is_eq(value, 0), pos, Array.get(U32, changed, 108)), old)

def swap_results(a: Array<U32> & U32, b: Array<U32> & U32) -> Bool:
  (aa, x) = a
  (bb, y) = b
  U32.is_eq(x, y) && equal_words(128n, 0, Array.get(U32, aa, 0), Array.get(U32, bb, 0))

def compared_swap(+pos: U32, +digit: U32, pair: Array<U32> & Array<U32>) -> Bool:
  (candidate, old) = pair
  swap_results(C.swap(candidate, pos, digit), old_swapped(pos, digit, Array.swap(U32, old, pos, digit)))

def cached_random(n: Nat, +pos: U32, +seed: U32, b: Array<U32>) -> Array<U32>:
  match n:
    case 0n:
      C.cache(b)
    case 1n+k:
      cached_random(k, (pos + 1 : U32), R.next(seed), Array.set(U32, b, pos, (seed % 10 : U32)))

def swaps(n: Nat, +pos: U32, +digit: U32, +seed: U32) -> Bool:
  match n:
    case 0n:
      True{}
    case 1n+k:
      compared_swap(pos, digit, Array.clone(U32, Array.set(U32, cached_random(81n, 0, seed, B.empty()), 108, pos))) &&
      compared_swap(pos, digit, Array.clone(U32, Array.set(U32, cached_random(81n, 0, seed, B.empty()), 108, 81))) &&
      swaps(k, (pos + 1 : U32), digit, R.next(seed))

def swap_digits(n: Nat, +digit: U32) -> Bool:
  match n:
    case 0n:
      True{}
    case 1n+k:
      swaps(81n, 0, digit, 2654435769) && swap_digits(k, (digit + 1 : U32))

# Force prefix metadata to selected position, exercising the optimized path
# even when a random domain contains an earlier open cell.
def forced_prefix(n: Nat, +pos: U32, +digit: U32, +seed: U32) -> Bool:
  match n:
    case 0n:
      True{}
    case 1n+k:
      compared(False{}, pos, digit, Array.clone(U32, Array.set(U32, domains(81n, 0, seed, B.empty()), 108, pos))) &&
      compared(True{}, pos, digit, Array.clone(U32, Array.set(U32, domains(81n, 0, seed, B.empty()), 108, 81))) &&
      forced_prefix(k, (pos + 1 : U32), digit, R.next(seed))

def wide_digits(n: Nat, +digit: U32) -> Bool:
  match n:
    case 0n:
      True{}
    case 1n+k:
      forced_prefix(81n, 0, digit, 1) && wide_digits(k, (digit + 1 : U32))

# Direct helper callers need not have installed value in the logical cell.
# Keep that general tuple contract separate from the actual Array.swap path.
def direct_swapped() -> Bool:
  swap_results(C.swapped(0, 1, (C.cache(B.empty()), 0)), old_swapped(0, 1, (C.cache(B.empty()), 0)))

def emit(ok: Bool) -> IO(Unit):
  match ok:
    case True{}:
      IO.print("PASS known placement refresh:all128 words;2916 valid active placements versus frozen baseline;5346 zero/wide active placements;1620 cached swaps;all81 positions;forced/guess modes;prefix at selected/81;digits0..32")
    case False{}:
      IO.die(Unit, 1, "FAIL known placement refresh")

def main() -> IO(Unit):
  emit(direct_swapped() && digits(9n, 1, False{}, 1) && digits(9n, 1, True{}, 1) && digits(9n, 1, False{}, 2654435769) && digits(9n, 1, True{}, 2654435769) && wide_digits(33n, 0) && swap_digits(10n, 0))
