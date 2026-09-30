import Base
import ../sudoku/board.bend as B
import ../sudoku/candidates.bend as C
import ../sudoku/generator.bend as G
import ../sudoku/search.bend as S

def mask_counts(n: Nat, +m: U32) -> Bool:
  match n:
    case 0n:
      True{}
    case 1n+k:
      U32.is_eq(C.mask_count(m), C.pop(10n, m, 0)) && mask_counts(k, (m + 1 : U32))

def compared(expected: U32, r: Array<U32> & U32) -> Array<U32> & Bool:
  (b, actual) = r
  (b, U32.is_eq(expected, actual))

def compare_at(pos: U32, r: Array<U32> & U32) -> Array<U32> & Bool:
  (b, expected) = r
  compared(expected, C.cached_at(b, pos))

def combine(ok: Bool, r: Array<U32> & Bool) -> Array<U32> & Bool:
  (b, same) = r
  (b, ok && same)

def all_at(n: Nat, +pos: U32, r: Array<U32> & Bool) -> Bool:
  match n:
    case 0n:
      Pair.snd(Array<U32>, Bool, r)
    case 1n+k:
      (b, ok) = r
      all_at(k, (pos + 1 : U32), combine(ok, compare_at(pos, C.at(b, pos))))

def holes(n: Nat, +pos: U32, +offset: U32, b: Array<U32>) -> Array<U32>:
  match n:
    case 0n:
      b
    case 1n+k:
      holes(k, (pos + 3 : U32), offset, Array.set(U32, b, ((pos + offset) % 81 : U32), 0))

def cached_seeds(n: Nat, +seed: U32) -> Bool:
  match n:
    case 0n:
      True{}
    case 1n+k:
      all_at(81n, 0, (C.cache(holes(27n, 0, seed, G.complete(seed))), True{})) && cached_seeds(k, (seed + 1 : U32))

def emit(ok: Bool, text: String) -> IO(Unit):
  match ok:
    case True{}:
      IO.print("PASS " ++ text)
    case False{}:
      IO.die(Unit, 1, "FAIL " ++ text)

def main() -> IO(Unit):
  do IO<Unit>:
    emit(mask_counts(4096n, 0), "SWAR equals reference low10-bit popcount for4096masks")
    emit(U32.is_eq(C.mask_count(4294967295), 10), "popcount upperbits ignored")
    emit(cached_seeds(100n, 0), "cached/public candidates equal100seededboards x81cells")
