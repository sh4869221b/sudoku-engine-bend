import Base
import ../sudoku/arrayrating.bend as A
import ../sudoku/ratingindex.bend as I
import ../sudoku/difficulty.bend as D
import ../sudoku/board.bend as B
import ../sudoku/parser.bend as P
import ./rating-cache.bend as R
import ./rating-index.bend as Q

def compare(+fuel: Nat, pair: Array<U32> & Array<U32>) -> Bool:
  (a, b) = pair
  R.equal_result(R.reference(fuel, a), A.rate(fuel, b))

def compare_parsed(fuel: Nat, parsed: P.Parsed) -> Bool:
  match parsed:
    case P.ParseError{reason}:
      False{}
    case P.ParsedBoard{b}:
      compare(fuel, Array.clone(U32, b))

def fuels(n: Nat, +fuel: Nat, +s: String) -> Bool:
  match n:
    case 0n:
      True{}
    case 1n+k:
      compare_parsed(fuel, P.parse81(s)) && fuels(k, 1n+fuel, s)

type ArrayTrace is Type:
  TraceActive{cells: Array<U32>, support: Array<U32>, reference: List<&2, D.Cell>, ok: Bool}
  TraceDone{ok: Bool}

def checked_support(+next: List<&2, D.Cell>, cells: Array<U32>, ok: Bool, r: Array<U32> & Bool) -> ArrayTrace:
  (support, same) = r
  TraceActive{cells, support, next, ok && same}

def support_pair(+next: List<&2, D.Cell>, cells: Array<U32>, ok: Bool, r: Array<U32> & Array<U32>) -> ArrayTrace:
  (test, live) = r
  checked_support(next, cells, ok, (live, Q.entries(243n, 0, next, Array.get(U32, test, 0), True{})))

def cell_pair(+next: List<&2, D.Cell>, support: Array<U32>, ok: Bool, pair: Array<U32> & Array<U32>) -> ArrayTrace:
  (test, live) = pair
  support_pair(next, live, ok && R.equal_cells(next, A.to_cells(List.take(&1, U32, Array.to_list(~U32, test), 81n))), Array.clone(U32, support))

def reference_step(next: List<&2, D.Cell>, ok: Bool, pair: Array<U32> & Array<U32>) -> ArrayTrace:
  (cells, support) = pair
  cell_pair(next, support, ok, Array.clone(U32, cells))

def trace_action(+xs: List<&2, D.Cell>, ok: Bool, cells: Array<U32>, support: Array<U32>, +action: D.Action) -> ArrayTrace:
  match action:
    case D.NoAction{}:
      TraceDone{ok}
    case D.Place{+p, +d, +t}:
      reference_step(D.apply(xs, D.Place{p, d, t}), ok, A.apply(D.Place{p, d, t}, (cells, support)))
    case D.Remove{+ps, +bits, +t}:
      reference_step(D.apply(xs, D.Remove{ps, bits, t}), ok, A.apply(D.Remove{ps, bits, t}, (cells, support)))

def trace(fuel: Nat, state: ArrayTrace) -> Bool:
  match fuel state:
    case _ TraceDone{ok}:
      ok
    case 0n TraceActive{cells, support, xs, ok}:
      ok
    case 1n+k TraceActive{cells, support, +xs, ok}:
      trace(k, trace_action(xs, ok, cells, support, D.ladder(xs)))

def trace_parsed(parsed: P.Parsed) -> Bool:
  match parsed:
    case P.ParseError{reason}:
      False{}
    case P.ParsedBoard{b}:
      +xs = D.initialize_cached(D.from_values(List.take(&1, U32, Array.to_list(~U32, b), 81n)))
      trace(100n, reference_step(xs, True{}, (A.from_cells(xs, 0, [0 : U32*128n]), I.build(xs, 0, [0 : U32*256n]))))

def synthetic_fuels(n: Nat, +fuel: Nat, +xs: List<&2, D.Cell>) -> Bool:
  match n:
    case 0n:
      True{}
    case 1n+k:
      R.equal_result(D.rate_loop(fuel, D.Rating{xs, 0, 0, 0}), A.rate_cells(fuel, xs)) && synthetic_fuels(k, 1n+fuel, xs)

def main() -> IO(Unit):
  do IO<Unit>:
    R.emit(trace_parsed(P.parse81("530070000600195000098000060800060003400803001700020006060000280000419005000080079")), "array every NS edit cell and support index versus untouched reference")
    R.emit(trace_parsed(P.parse81("000005601008100070000400000000900000005002700800000540000020103590000000080740090")), "array every HS edit cell and support index versus untouched reference")
    R.emit(trace_parsed(P.parse81("008740006004200003060903700401050089000000000090400000000000900000000500025008040")), "array every LC/NP edit cell and support index versus untouched reference")
    R.emit(synthetic_fuels(24n, 0n, R.pair_cells(81n, 0, 6)), "array synthetic NP everyfuel0..23 versus untouched list state")
    R.emit(fuels(64n, 0n, "530070000600195000098000060800060003400803001700020006060000280000419005000080079"), "array NS-only everyfuel0..63 versus unmodified list oracle")
    R.emit(fuels(64n, 0n, "000005601008100070000400000000900000005002700800000540000020103590000000080740090"), "array HS everyfuel0..63 versus unmodified list oracle")
    R.emit(fuels(32n, 0n, "008740006004200003060903700401050089000000000090400000000000900000000500025008040"), "array LC/NP everyfuel0..31 versus unmodified list oracle")
    R.emit(fuels(4n, 0n, "000000000000000000000000000000000000000000000000000000000000000000000000000000000"), "array empty-board guess/fuel boundary")
    R.emit(fuels(4n, 0n, "534678912672195348198342567859761423426853791713924856961537284287419635345286179"), "array completed-board/fuel boundary")
