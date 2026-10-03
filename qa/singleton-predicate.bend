import Base
import ../sudoku/prng.bend as R
import ../sudoku/candidates.bend as C
import ../sudoku/queuedcandidates.bend as Q

def equivalent(+x: U32) -> Bool:
  +actual = Q.zero_or_single(x)
  +old = U32.is_eq(U32.and(x, (x - 1 : U32)), 0)
  U32.is_eq(Bool.pick(U32, actual, 1, 0), Bool.pick(U32, old, 1, 0))

# The slow independent32-bit loop additionally guards against sharing the
# candidate predicate's arithmetic identity with the reference.
def counted(+x: U32) -> Bool:
  +actual = Q.zero_or_single(x)
  +counted = (C.pop(32n, x, 0) <= 1 : U32)
  U32.is_eq(Bool.pick(U32, actual, 1, 0), Bool.pick(U32, counted, 1, 0))

def consecutive(n: Nat, +x: U32) -> Bool:
  match n:
    case 0n:
      True{}
    case 1n+k:
      equivalent(x) && counted(x) && consecutive(k, (x + 1 : U32))

def random(n: Nat, +seed: U32) -> Bool:
  match n:
    case 0n:
      True{}
    case 1n+k:
      equivalent(seed) && counted(seed) && random(k, R.next(seed))

def power_edges(n: Nat, +digit: U32) -> Bool:
  match n:
    case 0n:
      True{}
    case 1n+k:
      +bit = U32.shln(1, U32.to_nat(digit))
      equivalent(bit) && counted(bit) && equivalent((bit - 1 : U32)) && counted((bit - 1 : U32)) && equivalent((bit + 1 : U32)) && counted((bit + 1 : U32)) && power_edges(k, (digit + 1 : U32))

def emit(ok: Bool) -> IO(Unit):
  match ok:
    case True{}:
      IO.print("PASS singleton predicate:all1024 low masks,4096 upper values,all32 power boundaries and65536 full-width random values versus old identity and independent32-bit count")
    case False{}:
      IO.die(Unit, 1, "FAIL singleton predicate")

def main() -> IO(Unit):
  emit(consecutive(1024n, 0) && consecutive(4096n, 4294963200) && power_edges(32n, 0) && random(65536n, 2654435769))
