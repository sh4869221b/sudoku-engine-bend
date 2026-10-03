import Base
import ../sudoku/queuedcandidates.bend as Q
import ./peer-reference.bend as Ref
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

def emit(ok: Bool) -> IO(Unit):
  match ok:
    case True{}:
      IO.print("PASS bitmap index:2916 placements,all81 positions,all9 digits,forced/guess modes,two seeds,all128 words versus frozen20-peer reference")
    case False{}:
      IO.die(Unit, 1, "FAIL bitmap index")

def main() -> IO(Unit):
  emit(digits(9n, 1, False{}, 1) && digits(9n, 1, True{}, 1) && digits(9n, 1, False{}, 2654435769) && digits(9n, 1, True{}, 2654435769))
