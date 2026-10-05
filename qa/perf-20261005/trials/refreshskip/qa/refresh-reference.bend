import Base
import ../sudoku/queuedcandidates.bend as Q
import ../sudoku/board.bend as B
import ../sudoku/arithmetic.bend as M

def place(+guess: Bool, +pos: U32, +digit: U32, b: Array<U32>) -> Array<U32>:
  +bit = B.bit(digit)
  +row = M.div9(pos)
  +col = M.rem9(pos)
  +base = (M.div3(row) * 27 + M.div3(col) * 3 : U32)
  Q.refresh(pos, Array.get(U32, Q.box_four(base, M.rem3((row + 1 : U32)), M.rem3((row + 2 : U32)), M.rem3((col + 1 : U32)), M.rem3((col + 2 : U32)), bit, Q.column_line(9n, 0, col, pos, bit, Q.row_line(9n, 0, (row * 9 : U32), pos, bit, Array.set(U32, Q.clear_forced(guess, b, pos), pos, U32.shln(digit, 10n))))), 108))
