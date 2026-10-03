import Base
import ../sudoku/board.bend as B
import ../sudoku/batch.bend as Batch
import ../sudoku/commands.bend as C
import ../sudoku/types.bend as T
import ../sudoku/generator.bend as G

def shown(+tail: String, pair: Array<U32> & Array<U32>) -> Bool:
  (a, b) = pair
  String.eq(B.show(a) ++ tail, B.show_tail(b, tail))

def fill(n: Nat, +pos: U32, +seed: U32, b: Array<U32>) -> Array<U32>:
  match n:
    case 0n:
      b
    case 1n+k:
      fill(k, (pos + 1 : U32), G.next(seed), Array.set(U32, b, pos, seed))

def boards(n: Nat, +seed: U32) -> Bool:
  match n:
    case 0n:
      True{}
    case 1n+k:
      shown("\n#suffix", Array.clone(U32, fill(81n, 0, seed, B.empty()))) && shown("", Array.clone(U32, G.complete(seed))) && boards(k, G.next(seed))

def text(+puzzle: String, +tail: String) -> Bool:
  String.eq(C.only_out(C.eval(1, True{}, T.solve_fuel(), T.rate_fuel(), puzzle)) ++ tail, C.batch_solve_tail(puzzle, tail))

def job(+mode: U32, +index: U32, +puzzle: String) -> Bool:
  String.eq(U32.show(index) ++ " " ++ C.only_out(C.eval(mode, True{}, T.solve_fuel(), T.rate_fuel(), puzzle)) ++ "\n", Batch.job_line(mode, Batch.Job{index, puzzle}))

def jobs(+puzzle: String) -> Bool:
  job(1, 0, puzzle) && job(1, 4294967295, puzzle) && job(2, 1, puzzle) && job(3, 16, puzzle) && job(4, 10000, puzzle)

def generated(r: G.DigResult) -> Bool:
  match r:
    case G.DigDone{b, clues}:
      text(B.show(b), "\n")
    case _:
      False{}

def puzzles(n: Nat, +seed: U32) -> Bool:
  match n:
    case 0n:
      True{}
    case 1n+k:
      generated(G.generate(T.digging_fuel(), seed, 36, False{})) && puzzles(k, G.next(seed))

def emit(ok: Bool) -> IO(Unit):
  match ok:
    case True{}:
      IO.print("PASS suffix board rendering1024wide/generated arrays;100generated batch solves/edges;all4mode/index limits/fuel/unsolved formatting")
    case False{}:
      IO.die(Unit, 1, "FAIL suffix output")

def main() -> IO(Unit):
  emit(boards(512n, 4294967295) && puzzles(100n, 0) && text("", "x") && text("x", "") && text(".................................................................................", "tail") && text("110000000000000000000000000000000000000000000000000000000000000000000000000000000", "\n") && jobs("530070000600195000098000060800060003400803001700020006060000280000419005000080079") && jobs("bad") && String.eq(C.solved_tail(T.OutOfFuel{}, "\n"), "error:fuel\n") && String.eq(C.solved_tail(T.Unsolved{}, "\n"), "unsolved\n"))
