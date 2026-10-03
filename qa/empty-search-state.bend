import Base
import ../sudoku/board.bend as B
import ../sudoku/candidates.bend as C
import ../sudoku/parser.bend as P
import ../sudoku/search.bend as S

# This driver intentionally prints only logical board cells, never cache padding.
# Active frame words are included to detect alternative-order or stack drift.
def parsed(result: P.Parsed) -> Array<U32>:
  match result:
    case P.ParsedBoard{b}:
      b
    case P.ParseError{reason}:
      B.empty()

def frames_go(n: Nat, +i: U32, r: Array<U32> & U32) -> String:
  match n:
    case 0n:
      ""
    case 1n+k:
      (frames, word) = r
      U32.show(word) ++ "," ++ frames_go(k, (i + 1 : U32), Array.get(U32, frames, (i + 1 : U32)))

def frames_text(depth: U32, frames: Array<U32>) -> String:
  frames_go(U32.to_nat(depth), 0, Array.get(U32, frames, 0))

def working_state(backtracking: Bool, board: Array<U32>, frames: Array<U32>, depth: U32, found: U32) -> S.SearchState:
  match backtracking:
    case True{}:
      S.Backtracking{board, frames, depth, found}
    case False{}:
      S.Searching{board, frames, depth, found}

def inspect_frames(backtracking: Bool, tag: String, board: Array<U32>, view: Array<U32>, +depth: U32, +found: U32, r: Array<U32> & Array<U32>) -> S.SearchState & String:
  (frames, stack) = r
  (working_state(backtracking, board, frames, depth, found), tag ++ " " ++ U32.show(depth) ++ " " ++ U32.show(found) ++ " " ++ B.show(view) ++ " " ++ frames_text(depth, stack))

def inspect_board(backtracking: Bool, tag: String, frames: Array<U32>, depth: U32, found: U32, r: Array<U32> & Array<U32>) -> S.SearchState & String:
  (board, view) = r
  inspect_frames(backtracking, tag, board, view, depth, found, Array.clone(U32, frames))

def inspect_done(+found: U32, r: Array<U32> & Array<U32>) -> S.SearchState & String:
  (answer, view) = r
  (S.SearchDone{found, answer}, "done " ++ U32.show(found) ++ " " ++ B.show(view))

def inspect(state: S.SearchState) -> S.SearchState & String:
  match state:
    case S.Searching{board, frames, depth, found}:
      inspect_board(False{}, "searching", frames, depth, found, Array.clone(U32, board))
    case S.Backtracking{board, frames, depth, found}:
      inspect_board(True{}, "backtracking", frames, depth, found, Array.clone(U32, board))
    case S.SearchDone{found, answer}:
      inspect_done(found, Array.clone(U32, answer))
    case S.SearchFuel{}:
      (S.SearchFuel{}, "fuel")

# These retained legacy S.selected/S.backtrack transitions expose reference
# states at fuel boundaries. Production now uses adaptive F through S.run;
# run_samples below checks production terminal/fuel outcomes separately.
def advance(n: Nat, +limit: U32, state: S.SearchState) -> S.SearchState:
  match n state:
    case 0n state:
      state
    case _ S.SearchDone{found, answer}:
      S.SearchDone{found, answer}
    case _ S.SearchFuel{}:
      S.SearchFuel{}
    case 1n+k S.Searching{board, frames, depth, found}:
      advance(k, limit, S.selected(limit, frames, depth, found, C.cached_select(board)))
    case 1n+k S.Backtracking{board, frames, +depth, found}:
      advance(k, limit, S.backtrack(U32.is_eq(depth, 0), frames, depth, found, board))

def emit_state(prefix: String, r: S.SearchState & String) -> IO(S.SearchState):
  (state, text) = r
  do IO<S.SearchState>:
    IO.print(prefix ++ text)
    return state

def trace_samples(samples: List<&2, U32>, previous: U32, +name: String, +limit: U32, state: S.SearchState) -> IO(Unit):
  match samples:
    case Nil{}:
      IO.pure(Unit, Unit{})
    case +fuel <> rest:
      do IO<Unit>:
        state : S.SearchState <- emit_state(name ++ " trace " ++ U32.show(limit) ++ " " ++ U32.show(fuel) ++ " ", inspect(advance(U32.to_nat((fuel - previous : U32)), limit, state)))
        trace_samples(rest, fuel, name, limit, state)

def outcome(state: S.SearchState) -> String:
  Pair.snd(S.SearchState, String, inspect(state))

def run_samples(samples: List<&2, U32>, +name: String, +limit: U32, +board: String) -> IO(Unit):
  match samples:
    case Nil{}:
      IO.pure(Unit, Unit{})
    case +fuel <> rest:
      do IO<Unit>:
        IO.print(name ++ " run " ++ U32.show(limit) ++ " " ++ U32.show(fuel) ++ " " ++ outcome(S.run(U32.to_nat(fuel), limit, parsed(P.parse81(board)))))
        run_samples(rest, name, limit, board)

def range(n: Nat, +i: U32) -> List<&2, U32>:
  match n:
    case 0n:
      Nil{}
    case 1n+k:
      i <> range(k, (i + 1 : U32))

def fixture(+samples: List<&2, U32>, +name: String, +board: String) -> IO(Unit):
  do IO<Unit>:
    run_samples(samples, name, 1, board)
    run_samples(samples, name, 2, board)
    trace_samples(samples, 0, name, 1, S.Searching{C.cache(parsed(P.parse81(board))), [0 : U32*128n], 0, 0})
    trace_samples(samples, 0, name, 2, S.Searching{C.cache(parsed(P.parse81(board))), [0 : U32*128n], 0, 0})

def main() -> IO(Unit):
  do IO<Unit>:
    fixture(range(301n, 0), "easy", "530070000600195000098000060800060003400803001700020006060000280000419005000080079")
    fixture(range(301n, 0), "empty", "000000000000000000000000000000000000000000000000000000000000000000000000000000000")
    fixture(range(301n, 0), "contradiction", "123400089456789123080023056204007091060801234891234560345078012000912340019305678")
    fixture(range(301n, 0), "complete", "534678912672195348198342567859761423426853791713924856961537284287419635345286179")
    fixture(List.append(&2, U32, range(301n, 0), [500, 1000, 2000, 5000, 10000, 20000, 50000, 100000, 199999, 200000]), "hard", "800000000003600000070090200050007000000045700000100030001000068008500010090000400")
