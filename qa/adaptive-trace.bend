import Base
import ../sudoku/adaptivesearch.bend as F
import ../sudoku/search.bend as S
import ../sudoku/candidates.bend as C
import ../sudoku/parser.bend as P
import ../sudoku/validate.bend as V

# Test-only lockstep transition oracle. Live adaptive snapshots are only moved,
# never decoded or rebuilt. All inspection operates on cloned board/frame views.
# The reference restores every placement via S.backtrack and uses scalar MRV.
type View is Type:
  Working{phase: U32, depth: U32, found: U32, active: Bool, board: Array<U32>, frames: Array<U32>}
  Terminal{found: U32, board: Array<U32>}
  Fuel{}

type Issue is Data:
  Okay{}
  Wrong{field: String, index: U32, actual: U32, expected: U32}

type Compared is Data:
  Same{phase: U32, active: Bool, depth: U32, found: U32}
  Different{field: String, index: U32, actual: U32, expected: U32}

type Counts is Data:
  Counts{steps: U32, forward: U32, backward: U32, active_forward: U32}

type Trace is Type:
  Running{adaptive: F.State, legacy: S.SearchState, counts: Counts}
  Completed{counts: Counts, found: U32}
  Capped{counts: Counts, phase: U32, depth: U32, found: U32}
  Failed{counts: Counts, field: String, index: U32, actual: U32, expected: U32}

# Separate constructors avoid duplicating affine arrays in Bool.pick arguments.
def f_state(phase: U32, board: Array<U32>, frames: Array<U32>, depth: U32, found: U32, snapshots: List<&1, Array<U32>>, active: Bool) -> F.State:
  match phase:
    case 0:
      F.Searching{board, frames, depth, found, snapshots, active}
    case _:
      F.Backtracking{board, frames, depth, found, snapshots, active}

def f_frame_views(+phase: U32, +depth: U32, +found: U32, snapshots: List<&1, Array<U32>>, +active: Bool, board: Array<U32>, view: Array<U32>, pair: Array<U32> & Array<U32>) -> F.State & View:
  (frames, stack) = pair
  (f_state(phase, board, frames, depth, found, snapshots, active), Working{phase, depth, found, active, F.finish(active, view), stack})

def f_board_views(phase: U32, frames: Array<U32>, depth: U32, found: U32, snapshots: List<&1, Array<U32>>, active: Bool, pair: Array<U32> & Array<U32>) -> F.State & View:
  (board, view) = pair
  f_frame_views(phase, depth, found, snapshots, active, board, view, Array.clone(U32, frames))

def f_done(+found: U32, pair: Array<U32> & Array<U32>) -> F.State & View:
  (board, view) = pair
  # SnapshotDone is already decoded by production F.record/F.backtrack.
  (F.SnapshotDone{found, board}, Terminal{found, view})

def f_view(state: F.State) -> F.State & View:
  match state:
    case F.Searching{board, frames, depth, found, snapshots, active}:
      f_board_views(0, frames, depth, found, snapshots, active, Array.clone(U32, board))
    case F.Backtracking{board, frames, depth, found, snapshots, active}:
      f_board_views(1, frames, depth, found, snapshots, active, Array.clone(U32, board))
    case F.SnapshotDone{found, answer}:
      f_done(found, Array.clone(U32, answer))
    case F.SnapshotFuel{}:
      (F.SnapshotFuel{}, Fuel{})

def s_state(phase: U32, board: Array<U32>, frames: Array<U32>, depth: U32, found: U32) -> S.SearchState:
  match phase:
    case 0:
      S.Searching{board, frames, depth, found}
    case _:
      S.Backtracking{board, frames, depth, found}

def s_frame_views(+phase: U32, +depth: U32, +found: U32, board: Array<U32>, view: Array<U32>, pair: Array<U32> & Array<U32>) -> S.SearchState & View:
  (frames, stack) = pair
  (s_state(phase, board, frames, depth, found), Working{phase, depth, found, False{}, view, stack})

def s_board_views(phase: U32, frames: Array<U32>, depth: U32, found: U32, pair: Array<U32> & Array<U32>) -> S.SearchState & View:
  (board, view) = pair
  s_frame_views(phase, depth, found, board, view, Array.clone(U32, frames))

def s_done(+found: U32, pair: Array<U32> & Array<U32>) -> S.SearchState & View:
  (board, view) = pair
  (S.SearchDone{found, board}, Terminal{found, view})

def s_view(state: S.SearchState) -> S.SearchState & View:
  match state:
    case S.Searching{board, frames, depth, found}:
      s_board_views(0, frames, depth, found, Array.clone(U32, board))
    case S.Backtracking{board, frames, depth, found}:
      s_board_views(1, frames, depth, found, Array.clone(U32, board))
    case S.SearchDone{found, answer}:
      s_done(found, Array.clone(U32, answer))
    case S.SearchFuel{}:
      (S.SearchFuel{}, Fuel{})

def equal_value(equal: Bool, field: String, index: U32, actual: U32, expected: U32) -> Issue:
  match equal:
    case True{}:
      Okay{}
    case False{}:
      Wrong{field, index, actual, expected}

def scalar(field: String, index: U32, +actual: U32, +expected: U32, prior: Issue) -> Issue:
  match prior:
    case Okay{}:
      equal_value(U32.is_eq(actual, expected), field, index, actual, expected)
    case Wrong{field, index, actual, expected}:
      Wrong{field, index, actual, expected}

def words(mode: U32, +index: U32, actual: Array<U32> & U32, expected: Array<U32> & U32, prior: Issue) -> Array<U32> & Array<U32> & Issue:
  match mode:
    case 0:
      (a, x) = actual
      (b, y) = expected
      (a, (b, scalar("cell", index, x, y, prior)))
    case _:
      (a, x) = actual
      (b, +y) = expected
      # Remove ONLY the adaptive guess marker (bit21); every other bit agrees.
      # Legacy old-value bits must be zero because only empty cells are placed.
      (a, (b, scalar("frame", index, U32.and(x, 4292870143), y, scalar("legacy-old", index, U32.and(U32.shrn(y, 7n), 15), 0, prior))))

def arrays(n: Nat, +index: U32, +mode: U32, pair: Array<U32> & Array<U32> & Issue) -> Issue:
  match n:
    case 0n:
      (a, (b, issue)) = pair
      issue
    case 1n+k:
      (a, (b, issue)) = pair
      arrays(k, (index + 1 : U32), mode, words(mode, index, Array.get(U32, a, index), Array.get(U32, b, index), issue))

def finish_compare(phase: U32, active: Bool, depth: U32, found: U32, issue: Issue) -> Compared:
  match issue:
    case Okay{}:
      Same{phase, active, depth, found}
    case Wrong{field, index, actual, expected}:
      Different{field, index, actual, expected}

def live_arrays(+phase: U32, active: Bool, +depth: U32, found: U32, af: Array<U32>, sf: Array<U32>, issue: Issue) -> Compared:
  match issue:
    case Okay{}:
      finish_compare(phase, active, depth, found, arrays(U32.to_nat(depth), 0, 1, (af, (sf, Okay{}))))
    case Wrong{field, index, actual, expected}:
      Different{field, index, actual, expected}

def view_phase(view: View) -> U32:
  match view:
    case Working{phase, depth, found, active, board, frames}:
      phase
    case Terminal{found, board}:
      2
    case Fuel{}:
      3

def compare(actual: View, expected: View) -> Compared:
  match actual expected:
    case Working{+phase, +depth, +found, active, a, af} Working{sp, sd, sn, unused, s, sf}:
      live_arrays(phase, active, depth, found, af, sf, arrays(81n, 0, 0, (a, (s, scalar("found", 0, found, sn, scalar("depth", 0, depth, sd, scalar("phase", 0, phase, sp, Okay{})))))))
    case Terminal{+found, a} Terminal{sf, s}:
      finish_compare(2, False{}, 0, found, arrays(81n, 0, 0, (a, (s, scalar("found", 0, found, sf, Okay{})))))
    case Fuel{} Fuel{}:
      Different{"unexpected-fuel", 0, 1, 0}
    case a s:
      Different{"phase", 0, view_phase(a), view_phase(s)}

def f_step(+limit: U32, state: F.State) -> F.State:
  match state:
    case F.Searching{board, frames, depth, found, snapshots, +active}:
      F.selected(limit, frames, depth, found, snapshots, active, F.selection(active, board))
    case F.Backtracking{board, frames, +depth, found, snapshots, active}:
      F.backtrack(U32.is_eq(depth, 0), frames, depth, found, snapshots, active, board)
    case F.SnapshotDone{found, answer}:
      F.SnapshotDone{found, answer}
    case F.SnapshotFuel{}:
      F.SnapshotFuel{}

def s_step(+limit: U32, state: S.SearchState) -> S.SearchState:
  match state:
    case S.Searching{board, frames, depth, found}:
      S.selected(limit, frames, depth, found, C.scalar_start(Array.get(U32, board, 108)))
    case S.Backtracking{board, frames, +depth, found}:
      S.backtrack(U32.is_eq(depth, 0), frames, depth, found, board)
    case S.SearchDone{found, answer}:
      S.SearchDone{found, answer}
    case S.SearchFuel{}:
      S.SearchFuel{}

def increment(+phase: U32, active: Bool, counts: Counts) -> Counts:
  match counts:
    case Counts{steps, forward, backward, active_forward}:
      Counts{(steps + 1 : U32), (forward + Bool.pick(U32, U32.is_eq(phase, 0), 1, 0) : U32), (backward + Bool.pick(U32, U32.is_eq(phase, 1), 1, 0) : U32), (active_forward + Bool.pick(U32, U32.is_eq(phase, 0) && active, 1, 0) : U32)}

def resolved(advance: Bool, +limit: U32, counts: Counts, adaptive: F.State, legacy: S.SearchState, compared: Compared) -> Trace:
  match advance compared:
    case _ Different{field, index, actual, expected}:
      Failed{counts, field, index, actual, expected}
    case _ Same{2, active, depth, found}:
      Completed{counts, found}
    case False{} Same{phase, active, depth, found}:
      Capped{counts, phase, depth, found}
    case True{} Same{phase, active, depth, found}:
      Running{f_step(limit, adaptive), s_step(limit, legacy), increment(phase, active, counts)}

def audit(advance: Bool, limit: U32, counts: Counts, actual: F.State & View, expected: S.SearchState & View) -> Trace:
  (adaptive, av) = actual
  (legacy, sv) = expected
  resolved(advance, limit, counts, adaptive, legacy, compare(av, sv))

# A dynamic Nat budget keeps compilation bounded. Terminal states leave the loop
# immediately, with no padded repeated terminal observations.
def trace(n: Nat, +limit: U32, state: Trace) -> Trace:
  match n state:
    case _ Completed{counts, found}:
      Completed{counts, found}
    case _ Capped{counts, phase, depth, found}:
      Capped{counts, phase, depth, found}
    case _ Failed{counts, field, index, actual, expected}:
      Failed{counts, field, index, actual, expected}
    case 0n Running{adaptive, legacy, counts}:
      audit(False{}, limit, counts, f_view(adaptive), s_view(legacy))
    case 1n+k Running{adaptive, legacy, counts}:
      trace(k, limit, audit(True{}, limit, counts, f_view(adaptive), s_view(legacy)))

def counts_text(counts: Counts) -> String:
  match counts:
    case Counts{+steps, forward, backward, active_forward}:
      "steps=" ++ U32.show(steps) ++ " comparisons=" ++ U32.show((steps + 1 : U32)) ++ " forward=" ++ U32.show(forward) ++ " backward=" ++ U32.show(backward) ++ " active_forward=" ++ U32.show(active_forward)

def emit(name: String, limit: U32, state: Trace) -> IO(Unit):
  match state:
    case Completed{counts, found}:
      IO.print("PASS " ++ name ++ " limit=" ++ U32.show(limit) ++ " completed " ++ counts_text(counts) ++ " found=" ++ U32.show(found))
    case Capped{counts, phase, depth, found}:
      IO.print("PASS " ++ name ++ " limit=" ++ U32.show(limit) ++ " capped-incomplete " ++ counts_text(counts) ++ " phase=" ++ U32.show(phase) ++ " depth=" ++ U32.show(depth) ++ " found=" ++ U32.show(found))
    case Failed{counts, field, index, actual, expected}:
      IO.die(Unit, 1, "FAIL " ++ name ++ " limit=" ++ U32.show(limit) ++ " " ++ counts_text(counts) ++ " field=" ++ field ++ " index=" ++ U32.show(index) ++ " actual=" ++ U32.show(actual) ++ " expected=" ++ U32.show(expected))
    case Running{adaptive, legacy, counts}:
      IO.die(Unit, 1, "FAIL unexpected running trace")

def start(+budget: U32, +name: String, +limit: U32, pair: Array<U32> & Array<U32>) -> IO(Unit):
  (adaptive, legacy) = pair
  emit(name, limit, trace(U32.to_nat(budget), limit, Running{F.Searching{C.cache(adaptive), [0 : U32*128n], 0, 0, Nil{}, False{}}, S.Searching{C.cache(legacy), [0 : U32*128n], 0, 0}, Counts{0, 0, 0, 0}}))

def validated(ok: Bool, budget: U32, name: String, limit: U32, board: Array<U32>) -> IO(Unit):
  match ok:
    case True{}:
      start(budget, name, limit, Array.clone(U32, board))
    case False{}:
      IO.die(Unit, 1, "FAIL fixture is not locally valid: " ++ name)

def valid_board(budget: U32, name: String, limit: U32, pair: Array<U32> & String) -> IO(Unit):
  (board, reason) = pair
  validated(String.is_empty(reason), budget, name, limit, board)

def parsed(budget: U32, name: String, limit: U32, result: P.Parsed) -> IO(Unit):
  match result:
    case P.ParsedBoard{board}:
      valid_board(budget, name, limit, V.validate(board))
    case P.ParseError{reason}:
      IO.die(Unit, 1, "FAIL fixture parse: " ++ name ++ " " ++ reason)

def fixture(+budget: U32, +name: String, +board: String) -> IO(Unit):
  do IO<Unit>:
    parsed(budget, name, 1, P.parse81(board))
    parsed(budget, name, 2, P.parse81(board))

def suite(+budget: U32) -> IO(Unit):
  do IO<Unit>:
    fixture(budget, "easy", "530070000600195000098000060800060003400803001700020006060000280000419005000080079")
    fixture(budget, "empty", "000000000000000000000000000000000000000000000000000000000000000000000000000000000")
    fixture(budget, "complete", "534678912672195348198342567859761423426853791713924856961537284287419635345286179")
    fixture(budget, "contradiction", "123400089456789123080023056204007091060801234891234560345078012000912340019305678")
    fixture(budget, "hard", "800000000003600000070090200050007000000045700000100030001000068008500010090000400")
    fixture(budget, "hard-ai-escargot", "100007090030020008009600500005300900010080002600004000300000010040000007007000300")

    fixture(budget, "hard-seed-42", "080000300400900000906000040002400070000050000010003000000200060000008105090005800")
    fixture(budget, "hard-seed-20261003", "020009000600050100500670000010000008000008091000030500080004020300000700006000000")
    fixture(budget, "hard-ai-escargot-seed-42", "600010000030009020005800007010002090400080200007300005000004030000030800000600004")
    fixture(budget, "hard-ai-escargot-seed-20261003", "800003000090800000003050000100002300050400060007000009200001700030600040005020008")

# Required runtime budget prevents compile-time expansion of a large Nat trace.
def number(s: String, +value: U32) -> U32:
  match s:
    case SNil{}:
      value
    case SCon{h, tail}:
      number(tail, (value * 10 + Char.to_u32(h) - 48 : U32))

def args(xs: List<String>) -> IO(Unit):
  match xs:
    case program <> budget <> Nil{}:
      suite(number(budget, 0))
    case _:
      IO.die(Unit, 1, "usage: qa-adaptive-trace STEP_BUDGET")

def main() -> IO(Unit):
  do IO<Unit>:
    xs : List<String> <- IO.args()
    args(xs)
