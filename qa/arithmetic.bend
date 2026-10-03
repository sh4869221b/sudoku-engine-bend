import Base
import ../sudoku/arithmetic.bend as M
import ../sudoku/generator.bend as G

def check(+x: U32) -> Bool:
  U32.is_eq(M.div3(x), (x / 3 : U32)) && U32.is_eq(M.rem3(x), (x % 3 : U32)) && U32.is_eq(M.div9(x), (x / 9 : U32)) && U32.is_eq(M.rem9(x), (x % 9 : U32)) && U32.is_eq(M.div27(x), (x / 27 : U32)) && U32.is_eq(M.rem27(x), (x % 27 : U32))

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
      check(seed) && random(k, G.next(seed))

def values(xs: List<&2, U32>) -> Bool:
  match xs:
    case Nil{}:
      True{}
    case x <> tail:
      check(x) && values(tail)

def emit(ok: Bool) -> IO(Unit):
  match ok:
    case True{}:
      IO.print("PASS Nat/U32 div/rem3/9/27:4096consecutive,65536full-width random and high boundaries")
    case False{}:
      IO.die(Unit, 1, "FAIL constant division conversion")

def main() -> IO(Unit):
  emit(consecutive(4096n, 0) && random(65536n, 1) && values([2147483647,2147483648,2147483649,4294967279,4294967280,4294967294,4294967295]))
