import Base
import ../sudoku/candidates.bend as C
import ./rating-cache.bend as R

def equal(a: List<&2, U32>, b: List<&2, U32>) -> Bool:
  match a b:
    case Nil{} Nil{}:
      True{}
    case h <> tail j <> rest:
      U32.is_eq(h, j) && equal(tail, rest)
    case _ _:
      False{}

def cases(n: Nat, +mask: U32) -> Bool:
  match n:
    case 0n:
      True{}
    case 1n+k:
      equal(C.mask_digits(mask), C.digits_go(9n, 1, mask)) && cases(k, (mask + 1 : U32))

def main() -> IO(Unit):
  do IO<Unit>:
    R.emit(cases(8192n, 0), "set-bit digit iterator equals unchanged9-digit scanner for8192 masks")
    R.emit(equal(C.mask_digits(4294967295), C.digits_go(9n, 1, 4294967295)), "set-bit digit iterator ignores bit0 and all upperbits")
