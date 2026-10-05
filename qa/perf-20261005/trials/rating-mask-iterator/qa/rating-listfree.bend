import Base
import ../sudoku/ratingindex.bend as I
import ../sudoku/arrayrating.bend as A
import ../sudoku/board.bend as B
import ../sudoku/candidates.bend as C
import ../sudoku/arithmetic.bend as M
import ./rating-cache.bend as R
import ./rating-array.bend as Q

def words(xs: List<&1, U32>, ys: List<&1, U32>) -> Bool:
  match xs ys:
    case Nil{} Nil{}:
      True{}
    case +x <> xt +y <> yt:
      U32.is_eq(x, y) && words(xt, yt)
    case _ _:
      False{}

def same(a: Array<U32>, b: Array<U32>) -> Bool:
  words(Array.to_list(~U32, a), Array.to_list(~U32, b))

def compare(+mask: U32, +erase: Bool, +fixed: Bool) -> Bool:
  +pos = (mask % 81 : U32)
  +seed = (mask * 1103515245 + 12345 : U32)
  same(I.change_digits(C.mask_digits(mask), pos, erase, fixed, [seed : U32*256n]), I.change_mask(mask, pos, erase, fixed, [seed : U32*256n]))

def cases(n: Nat, +mask: U32) -> Bool:
  match n:
    case 0n:
      True{}
    case 1n+k:
      compare(mask, False{}, False{}) && compare(mask, False{}, True{}) && compare(mask, True{}, False{}) && compare(mask, True{}, True{}) && cases(k, (mask + 1 : U32))

def main() -> IO(Unit):
  do IO<Unit>:
    R.emit(cases(4096n, 0) && compare(4294967295, True{}, False{}) && compare(2147483649, False{}, False{}), "listfree4096 masks allfour erase/fixed modes arbitrary supports all256 words; bit0/upperbit preservation")
    Q.main()
