import Base
import ../sudoku/prng.bend as R

def check(+x: U32) -> Bool:
  U32.is_eq(U32.shrn(x, 5n), (x / 32 : U32)) && U32.is_eq(U32.and(x, 31), (x % 32 : U32))

def consecutive(n: Nat, +x: U32) -> Bool:
  match n:
    case 0n:
      True{}
    case 1n+k:
      check(x) && consecutive(k, (x + 1 : U32))

def random(n: Nat, +seed: U32) -> Bool:
  match n:
    case 0n:
      True{}
    case 1n+k:
      check(seed) && random(k, R.next(seed))

def emit(ok: Bool) -> IO(Unit):
  match ok:
    case True{}:
      IO.print("PASS bitmap arithmetic:4096 low,4096 upper,4096 sign-boundary values and65536 full-width random values versus original unsigned /32,%32")
    case False{}:
      IO.die(Unit, 1, "FAIL bitmap arithmetic")

def main() -> IO(Unit):
  emit(consecutive(4096n, 0) && consecutive(4096n, 4294963200) && consecutive(4096n, 2147481600) && random(65536n, 2654435769))
