import Base
import ../sudoku/board.bend as B
import ../sudoku/difficulty.bend as D
import ../sudoku/parser.bend as P
import ../sudoku/generator.bend as G

# Preserve the unmodified public list-state implementation as the oracle.
def reference(fuel: Nat, board: Array<U32>) -> D.RateResult:
  D.rate_loop(fuel, D.Rating{D.initialize_go(81n, 0, D.from_values(List.take(&1, U32, Array.to_list(~U32, board), 81n))), 0, 0, 0})

def equal_result(a: D.RateResult, b: D.RateResult) -> Bool:
  match a b:
    case D.Rated{s, t, n, v} D.Rated{s2, t2, n2, v2}:
      U32.is_eq(s, s2) && U32.is_eq(t, t2) && U32.is_eq(n, n2) && U32.is_eq(v, v2)

def compare_boards(+fuel: Nat, r: Array<U32> & Array<U32>) -> Bool:
  (a, b) = r
  equal_result(reference(fuel, a), D.rate(fuel, b))

def compare_parsed(fuel: Nat, parsed: P.Parsed) -> Bool:
  match parsed:
    case P.ParseError{reason}:
      False{}
    case P.ParsedBoard{b}:
      compare_boards(fuel, Array.clone(U32, b))

def fuels(n: Nat, +fuel: Nat, +s: String) -> Bool:
  match n:
    case 0n:
      True{}
    case 1n+k:
      compare_parsed(fuel, P.parse81(s)) && fuels(k, 1n+fuel, s)

def equal_bool(a: Bool, b: Bool) -> Bool:
  match a b:
    case True{} True{}:
      True{}
    case False{} False{}:
      True{}
    case _ _:
      False{}

def coverage_equal(+xs: List<&2, D.Cell>) -> Bool:
  equal_bool(D.missing_go(243n, 0, xs), D.coverage_missing(27n, 0, Array.get(U32, D.coverage_build(xs, 0, [0 : U32*32n]), 0), False{}))

def random_cells(n: Nat, +seed: U32) -> List<&2, D.Cell>:
  match n:
    case 0n:
      Nil{}
    case 1n+k:
      Bool.pick(D.Cell, U32.is_eq((seed % 5 : U32), 0), D.Fixed{(seed % 36 : U32)}, D.Open{U32.and(seed, 4095)}) <> random_cells(k, G.next(seed))

def coverage_seeds(n: Nat, +seed: U32) -> Bool:
  match n:
    case 0n:
      True{}
    case 1n+k:
      coverage_equal(random_cells(U32.to_nat((seed % 82 : U32)), G.normalize(seed))) && coverage_seeds(k, (seed + 1 : U32))

def equal_cell(a: D.Cell, b: D.Cell) -> Bool:
  match a b:
    case D.Fixed{x} D.Fixed{y}:
      U32.is_eq(x, y)
    case D.Open{x} D.Open{y}:
      U32.is_eq(x, y)
    case _ _:
      False{}

def equal_cells(xs: List<&2, D.Cell>, ys: List<&2, D.Cell>) -> Bool:
  match xs ys:
    case Nil{} Nil{}:
      True{}
    case x <> xt y <> yt:
      equal_cell(x, y) && equal_cells(xt, yt)
    case _ _:
      False{}

def initialization_seeds(n: Nat, +seed: U32) -> Bool:
  match n:
    case 0n:
      True{}
    case 1n+k:
      +xs = random_cells(U32.to_nat((seed % 82 : U32)), G.normalize(seed))
      equal_cells(D.initialize_go(81n, 0, xs), D.initialize_cached(xs)) && initialization_seeds(k, (seed + 1 : U32))

def equal_positions(xs: List<&2, U32>, ys: List<&2, U32>) -> Bool:
  match xs ys:
    case Nil{} Nil{}:
      True{}
    case x <> xt y <> yt:
      U32.is_eq(x, y) && equal_positions(xt, yt)
    case _ _:
      False{}

def equal_action(a: D.Action, b: D.Action) -> Bool:
  match a b:
    case D.NoAction{} D.NoAction{}:
      True{}
    case D.Place{p, d, t} D.Place{p2, d2, t2}:
      U32.is_eq(p, p2) && U32.is_eq(d, d2) && U32.is_eq(t, t2)
    case D.Remove{ps, m, t} D.Remove{ps2, m2, t2}:
      equal_positions(ps, ps2) && U32.is_eq(m, m2) && U32.is_eq(t, t2)
    case _ _:
      False{}

def trace_equal(n: Nat, state: D.State) -> Bool:
  match n state:
    case _ D.Finished{result}:
      True{}
    case 0n _:
      True{}
    case 1n+k D.Rating{+xs, tech, steps, score}:
      equal_action(D.ladder(xs), D.cached_ladder(xs)) && trace_equal(k, D.step_ready(D.zero_cell(xs) || D.missing_go(243n, 0, xs), D.full(xs), xs, tech, steps, score))

def trace_parsed(parsed: P.Parsed) -> Bool:
  match parsed:
    case P.ParseError{reason}:
      False{}
    case P.ParsedBoard{b}:
      trace_equal(100n, D.Rating{D.initialize_go(81n, 0, D.from_values(List.take(&1, U32, Array.to_list(~U32, b), 81n))), 0, 0, 0})

def ladder_seeds(n: Nat, +seed: U32) -> Bool:
  match n:
    case 0n:
      True{}
    case 1n+k:
      +xs = random_cells(U32.to_nat((seed % 82 : U32)), G.normalize(seed))
      equal_action(D.ladder(xs), D.cached_ladder(xs)) && ladder_seeds(k, (seed + 1 : U32))

def pair_cells(n: Nat, +p: U32, +bits: U32) -> List<&2, D.Cell>:
  match n:
    case 0n:
      Nil{}
    case 1n+k:
      D.Open{Bool.pick(U32, (p < 2 : U32), bits, 1022)} <> pair_cells(k, (p + 1 : U32), bits)

def pair_mask_case(bits: U32) -> Bool:
  +xs = pair_cells(81n, 0, bits)
  equal_action(D.ladder(xs), D.cached_ladder(xs))

def emit(ok: Bool, text: String) -> IO(Unit):
  match ok:
    case True{}:
      IO.print("PASS " ++ text)
    case False{}:
      IO.die(Unit, 1, "FAIL " ++ text)

def main() -> IO(Unit):
  do IO<Unit>:
    emit(trace_parsed(P.parse81("000005601008100070000400000000900000005002700800000540000020103590000000080740090")), "hidden-single action order matches reference")
    emit(trace_parsed(P.parse81("008740006004200003060903700401050089000000000090400000000000900000000500025008040")), "locked/pair action order matches reference")
    emit(pair_mask_case(6) && pair_mask_case(3) && pair_mask_case(1030), "pair ordering including bit0 and upper-bit malformed masks")
    emit(ladder_seeds(82n, 0), "ladder exact action order on82 malformed/partial states")
    emit(initialization_seeds(1000n, 0), "initialization matches public reference on1000 malformed/partial states")
    emit(coverage_seeds(1000n, 0), "coverage matches public missing_go on1000 malformed/partial cell states")
    emit(compare_boards(100n, Array.clone(U32, [0 : U32*1n])), "one-cell array rate semantics")
    emit(compare_boards(100n, Array.clone(U32, [10 : U32*32n])), "short invalid-digit array rate semantics")
    emit(fuels(64n, 0n, "000005601008100070000400000000900000005002700800000540000020103590000000080740090"), "hidden-single trace everyfuel0..63")
    emit(fuels(24n, 0n, "008740006004200003060903700401050089000000000090400000000000900000000500025008040"), "locked/pair trace everyfuel0..23")
    emit(fuels(4n, 0n, "000000000000000000000000000000000000000000000000000000000000000000000000000000000"), "empty-board guess/fuel boundary")
