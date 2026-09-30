import Base
import ./search.bend as S
import ./types.bend as T

def finish(state: S.SearchState) -> T.SolveResult:
  match state:
    case S.SearchDone{0, answer}:
      T.Unsolved{}
    case S.SearchDone{n, answer}:
      T.Solved{answer}
    case _:
      T.OutOfFuel{}

def solve(fuel: Nat, board: Array<U32>) -> T.SolveResult:
  finish(S.run(fuel, 1, board))
