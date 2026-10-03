import Base
import ../sudoku/ratingindex.bend as I
import ../sudoku/difficulty.bend as D
import ../sudoku/board.bend as B
import ../sudoku/parser.bend as P
import ./rating-cache.bend as R

def expected(n: Nat, +unit: U32, +j: U32, +digit: U32, +xs: List<&2, D.Cell>, bits: U32) -> U32:
  match n:
    case 0n:
      bits
    case 1n+k:
      +cell = D.cell(xs, B.unit_pos(unit, j))
      +extra = Bool.pick(U32, D.is_fixed(cell, digit), 1024, Bool.pick(U32, U32.is_ne(U32.and(D.mask(cell), B.bit(digit)), 0), B.bit(j), 0))
      expected(k, unit, (j + 1 : U32), digit, xs, U32.or(bits, extra))

def entries(n: Nat, +index: U32, +xs: List<&2, D.Cell>, r: Array<U32> & U32, ok: Bool) -> Bool:
  match n:
    case 0n:
      ok
    case 1n+k:
      (cache, word) = r
      entries(k, (index + 1 : U32), xs, Array.get(U32, cache, (index + 1 : U32)), ok && U32.is_eq(word, expected(9n, (index / 9 : U32), 0, (1 + index % 9 : U32), xs, 0)))

def verify_pair(xs: List<&2, D.Cell>, pair: Array<U32> & Array<U32>) -> Array<U32> & Bool:
  (test, live) = pair
  (live, entries(243n, 0, xs, Array.get(U32, test, 0), True{}))

type TraceState is Type:
  IndexActive{cells: List<&2, D.Cell>, cache: Array<U32>, ok: Bool}
  IndexDone{ok: Bool}

def checked(xs: List<&2, D.Cell>, ok: Bool, r: Array<U32> & Bool) -> TraceState:
  (cache, matched) = r
  IndexActive{xs, cache, ok && matched}

def applied(+xs: List<&2, D.Cell>, ok: Bool, cache: Array<U32>, action: D.Action) -> TraceState:
  +next = D.apply(xs, action)
  checked(next, ok, verify_pair(next, Array.clone(U32, I.sync(xs, next, 0, cache))))

def step_agreement(+xs: List<&2, D.Cell>, +ok: Bool, +same: Bool, cache: Array<U32>, action: D.Action) -> TraceState:
  match action:
    case D.NoAction{}:
      IndexDone{ok && same}
    case D.Place{p, d, tech}:
      applied(xs, ok && same, cache, D.Place{p, d, tech})
    case D.Remove{ps, bits, tech}:
      applied(xs, ok && same, cache, D.Remove{ps, bits, tech})

def step_action(+xs: List<&2, D.Cell>, ok: Bool, r: Array<U32> & D.Action) -> TraceState:
  (cache, +action) = r
  step_agreement(xs, ok, R.equal_action(D.ladder(xs), action), cache, action)

def trace(fuel: Nat, state: TraceState) -> Bool:
  match fuel state:
    case _ IndexDone{ok}:
      ok
    case 0n IndexActive{xs, cache, ok}:
      ok
    case 1n+k IndexActive{+xs, cache, ok}:
      trace(k, step_action(xs, ok, I.after_naked(xs, cache, I.naked(xs, 0, D.NoAction{}))))

def trace_parsed(parsed: P.Parsed) -> Bool:
  match parsed:
    case P.ParseError{reason}:
      False{}
    case P.ParsedBoard{b}:
      +xs = D.initialize_cached(D.from_values(List.take(&1, U32, Array.to_list(~U32, b), 81n)))
      trace(100n, checked(xs, True{}, verify_pair(xs, Array.clone(U32, I.build(xs, 0, [0 : U32*256n])))))

def compare(+fuel: Nat, pair: Array<U32> & Array<U32>) -> Bool:
  (a, b) = pair
  R.equal_result(R.reference(fuel, a), I.rate(fuel, b))

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

def main() -> IO(Unit):
  do IO<Unit>:
    R.emit(trace_parsed(P.parse81("000005601008100070000400000000900000005002700800000540000020103590000000080740090")), "indexed hidden-single action order and every support entry after actions")
    R.emit(trace_parsed(P.parse81("008740006004200003060903700401050089000000000090400000000000900000000500025008040")), "indexed locked/pair action order and every support entry after actions")
    R.emit(fuels(64n, 0n, "000005601008100070000400000000900000005002700800000540000020103590000000080740090"), "indexed hidden trace fuel0..63 versus unmodified list oracle")
    R.emit(fuels(24n, 0n, "008740006004200003060903700401050089000000000090400000000000900000000500025008040"), "indexed locked/pair trace fuel0..23 versus unmodified list oracle")
    R.emit(fuels(4n, 0n, "000000000000000000000000000000000000000000000000000000000000000000000000000000000"), "indexed empty-board guess/fuel boundary")
