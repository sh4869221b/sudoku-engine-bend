import Base
import ../sudoku/orderstat.bend as F
import ../sudoku/generator.bend as G

def equal(xs: List<&2, U32>, ys: List<&2, U32>) -> Bool:
  match xs ys:
    case Nil{} Nil{}:
      True{}
    case x <> xt y <> yt:
      U32.is_eq(x, y) && equal(xt, yt)
    case _ _:
      False{}

def size(+n: Nat, +seed: U32) -> Bool:
  equal(F.shuffle(n, G.normalize(seed)), G.shuffle(seed, G.range(n, 0)))

def lengths(n: Nat, +length: Nat, +seed: U32) -> Bool:
  match n:
    case 0n:
      True{}
    case 1n+k:
      size(length, seed) && lengths(k, 1n+length, seed)

def seeds(n: Nat, +seed: U32) -> Bool:
  match n:
    case 0n:
      True{}
    case 1n+k:
      size(81n, seed) && size(41n, seed) && seeds(k, G.next(seed))

def emit(ok: Bool) -> IO(Unit):
  match ok:
    case True{}:
      IO.print("PASS Fenwick ordinal shuffle equals unchanged list shuffle; lengths0..81,1000seeds and UInt upper boundaries")
    case False{}:
      IO.die(Unit, 1, "FAIL Fenwick shuffle order")

def main() -> IO(Unit):
  emit(lengths(82n, 0n, 0) && lengths(82n, 0n, 4294967295) && seeds(1000n, 1) && size(81n, 0) && size(81n, 4294967294) && size(41n, 4294967295))
