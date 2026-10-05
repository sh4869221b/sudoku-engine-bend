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

# Frozen old placement expression, including the original index write order.
def reference(+pos: U32, +digit: U32, support: Array<U32>, r: Array<U32> & U32) -> Array<U32> & Array<U32>:
  (cells, word) = r
  +mask = U32.shrn(word, 4n)
  A.clear_unit(9n, (18 + B.box_of(pos) : U32), 0, B.bit(digit),
    A.clear_unit(9n, (9 + M.rem9(pos) : U32), 0, B.bit(digit),
      A.clear_unit(9n, M.div9(pos), 0, B.bit(digit),
        (Array.set(U32, cells, pos, digit), I.change_digit(pos, digit, False{}, True{}, I.change_digits(C.mask_digits(mask), pos, True{}, False{}, support))))))

def compare_pairs(a: Array<U32> & Array<U32>, b: Array<U32> & Array<U32>) -> Bool:
  (cells, support) = a
  (other, index) = b
  same(cells, other) && same(support, index)

def compare(+mask: U32, +pos: U32, +digit: U32) -> Bool:
  +seed = (mask * 1103515245 + 12345 : U32)
  compare_pairs(reference(pos, digit, [seed : U32*256n], Array.get(U32, Array.set(U32, [5 : U32*128n], pos, U32.shln(mask, 4n)), pos)), A.place(pos, digit, (Array.set(U32, [5 : U32*128n], pos, U32.shln(mask, 4n)), [seed : U32*256n])))

def cases(n: Nat, +mask: U32) -> Bool:
  match n:
    case 0n:
      True{}
    case 1n+k:
      compare(mask, (mask % 81 : U32), (1 + mask % 9 : U32)) && cases(k, (mask + 1 : U32))

def main() -> IO(Unit):
  do IO<Unit>:
    R.emit(cases(4096n, 0) && compare(268435455, 40, 9) && compare(6, 0, 9), "combined placement4096 masks arbitrary supports all128cells/256supports; forceddigit absent and bit0/upperbits")
    Q.main()
