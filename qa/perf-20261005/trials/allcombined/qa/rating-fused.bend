import Base
import ../sudoku/ratingindex.bend as I
import ../sudoku/arrayrating.bend as A
import ../sudoku/difficulty.bend as D
import ./rating-cache.bend as R
import ./rating-array.bend as Q

def same_words(xs: List<&1, U32>, ys: List<&1, U32>) -> Bool:
  match xs ys:
    case Nil{} Nil{}:
      True{}
    case +x <> xt +y <> yt:
      U32.is_eq(x, y) && same_words(xt, yt)
    case _ _:
      False{}

def compared(+same: Bool, after: Array<U32>, action: D.Action, old: Array<U32> & D.Action) -> Bool:
  (reference, expected) = old
  same && R.equal_action(expected, action) && same_words(Array.to_list(~U32, reference), Array.to_list(~U32, after))

def combined(old: Array<U32> & Bool, next: Array<U32> & Bool & D.Action) -> Bool:
  (cache, bad) = old
  (after, (missing, action)) = next
  compared(R.equal_bool(bad, missing), after, action, I.hidden(243n, 0, (cache, D.NoAction{})))

def compare(pair: Array<U32> & Array<U32>) -> Bool:
  (old, next) = pair
  combined(I.missing(243n, 0, Array.get(U32, old, 0), False{}), I.missing_hidden(243n, 0, (next, (False{}, D.NoAction{}))))

def words(n: Nat, +word: U32) -> Bool:
  match n:
    case 0n:
      True{}
    case 1n+k:
      compare(Array.clone(U32, Array.set(U32, [1024 : U32*256n], (word % 243 : U32), word))) && words(k, (word + 1 : U32))

def entries(n: Nat, +pos: U32) -> Bool:
  match n:
    case 0n:
      True{}
    case 1n+k:
      compare(Array.clone(U32, Array.set(U32, Array.set(U32, Array.set(U32, [1024 : U32*256n], 0, 1), pos, 256), 242, 0))) && entries(k, (pos + 1 : U32))

def bad_result(state: A.ArrayState) -> Bool:
  match state:
    case A.ArrayFinished{D.Rated{2, 3, 7, 11}}:
      True{}
    case _:
      False{}

def missing_wins() -> Bool:
  bad_result(A.scanned(3, 7, 11, Array.set(U32, Array.set(U32, [1024 : U32*256n], 0, 1), 242, 0), ([96 : U32*128n], (False{}, (False{}, (81, 0))))))

def main() -> IO(Unit):
  do IO<Unit>:
    R.emit(words(2048n, 0), "fused scan all 11-bit support words against separate scans and all 256 retained entries")
    R.emit(entries(243n, 0), "fused first hidden order with later missing support at every index")
    R.emit(missing_wins(), "missing support globally outranks an earlier hidden single")
    Q.main()
