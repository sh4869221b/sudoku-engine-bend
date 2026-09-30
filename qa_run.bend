import Base
import ./sudoku/board.bend as B
import ./sudoku/parser.bend as P
import ./sudoku/validate.bend as V
import ./sudoku/candidates.bend as C
import ./sudoku/solver.bend as S
import ./sudoku/counter.bend as K
import ./sudoku/generator.bend as G
import ./sudoku/difficulty.bend as D
import ./sudoku/types.bend as T
import ./sudoku/commands.bend as Cmd
import ./sudoku/batch.bend as Batch
import ./sudoku/properties.bend as Props

def easy() -> String:
  "530070000600195000098000060800060003400803001700020006060000280000419005000080079"

def solved() -> String:
  "534678912672195348198342567859761423426853791713924856961537284287419635345286179"

def zero() -> String:
  "000000000000000000000000000000000000000000000000000000000000000000000000000000000"

def parse_board(result: P.Parsed) -> Array<U32>:
  match result:
    case P.ParsedBoard{b}:
      b
    case P.ParseError{reason}:
      B.empty()

def board(s: String) -> Array<U32>:
  parse_board(P.parse81(s))

def response(code: U32, +expected: String, reply: Cmd.Reply) -> Bool:
  match reply:
    case Cmd.Reply{actual, out, err}:
      U32.is_eq(code, actual) && String.eq(expected, out)

def is_fuel(result: T.SolveResult) -> Bool:
  match result:
    case T.OutOfFuel{}:
      True{}
    case _:
      False{}

def is_digfuel(result: G.DigResult) -> Bool:
  match result:
    case G.DigFuel{}:
      True{}
    case _:
      False{}

def rate_is(status: U32, tech: U32, steps: U32, score: U32, result: D.RateResult) -> Bool:
  match result:
    case D.Rated{a, b, c, d}:
      U32.is_eq(status, a) && U32.is_eq(tech, b) && U32.is_eq(steps, c) && U32.is_eq(score, d)

def all_cells() -> List<&2, D.Cell>:
  List.replicate(D.Cell, 81n, D.Open{1022})

def row_without(n: Nat, +i: U32, +bits: U32, xs: List<&2, D.Cell>) -> List<&2, D.Cell>:
  match n:
    case 0n:
      xs
    case 1n+k:
      row_without(k, (i + 1 : U32), bits, List.set(&2, D.Cell, xs, U32.to_nat(i), D.Open{U32.and(1022, U32.not(bits))}))

def action_is(tech: U32, action: D.Action) -> Bool:
  U32.is_eq(tech, D.technique(action))

def pair_cells() -> List<&2, D.Cell>:
  List.set(&2, D.Cell, List.set(&2, D.Cell, all_cells(), 0n, D.Open{6}), 1n, D.Open{6})

def unit_peer_count(n: Nat, +p: U32, +i: U32) -> U32:
  match n:
    case 0n:
      0
    case 1n+k:
      (Bool.pick(U32, B.peers(p, i), 1, 0) + unit_peer_count(k, p, (i + 1 : U32)) : U32)

def peer_property(n: Nat, +p: U32) -> Bool:
  match n:
    case 0n:
      True{}
    case 1n+k:
      U32.is_eq(unit_peer_count(81n, p, 0), 20) && peer_property(k, (p + 1 : U32))

def seeds_valid(n: Nat, +seed: U32) -> Bool:
  match n:
    case 0n:
      True{}
    case 1n+k:
      response(0, "valid", Cmd.eval(2, False{}, 1n, 1n, B.show(G.complete(seed)))) && seeds_valid(k, (seed + 1 : U32))

def batch_eq(+mode: U32) -> Bool:
  +jobs = {[Batch.Job{1, solved()}, Batch.Job{3, easy()}, Batch.Job{4, "bad"}] : List<&2, Batch.Job>}
  String.eq(Batch.run(mode, Batch.build(jobs)), Batch.sequential(jobs, mode))

def emit(ok: Bool, name: String) -> IO(Unit):
  match ok:
    case True{}:
      IO.print("PASS " ++ name)
    case False{}:
      IO.die(Unit, 1, "FAIL " ++ name)

def main() -> IO(Unit):
  do IO<Unit>:
    emit(Props.mirror_all(81n, 0), "mirror all81")
    emit(Props.set_get_all(128n, 0), "set/get128 four values")
    emit(peer_property(81n, 0), "20 peers all81")
    emit(Props.parsed_candidates(P.parse81(easy())), "actual candidates bounded easy81")
    emit(Props.parsed_candidates(P.parse81(zero())), "actual candidates bounded empty81")
    emit(response(0, solved(), Cmd.eval(1, False{}, T.solve_fuel(), T.rate_fuel(), easy())), "solve preserves known easy solution")
    emit(response(0, "1", Cmd.eval(3, False{}, T.solve_fuel(), T.rate_fuel(), easy())), "unique count")
    emit(response(0, "2", Cmd.eval(3, False{}, T.solve_fuel(), T.rate_fuel(), zero())), "empty multiple count")
    emit(response(2, "", Cmd.eval(1, False{}, 1n, 1n, "bad")), "invalid parse exit2")
    emit(is_fuel(S.solve(0n, board(easy()))), "solve fuel0")
    emit(String.eq(K.show(K.count2(0n, board(easy()))), "fuel"), "count fuel0")
    emit(is_digfuel(G.generate(0n, 42, 32, False{})), "dig fuel0")
    emit(rate_is(3, 0, 0, 0, D.rate(0n, board(easy()))), "rate fuel0")
    emit(rate_is(0, 0, 0, 0, D.rate(729n, board(solved()))), "rate complete")
    emit(rate_is(1, 0, 0, 0, D.rate(729n, board(zero()))), "rate requires guess")
    emit(rate_is(0, 1, 51, 51, D.rate(729n, board(easy()))), "rate51 singles independently counted blanks")
    emit(String.eq(D.label(0, 24), "Easy"), "score24")
    emit(String.eq(D.label(0, 25), "Medium"), "score25")
    emit(String.eq(D.label(0, 59), "Medium"), "score59")
    emit(String.eq(D.label(0, 60), "Hard"), "score60")
    emit(String.eq(D.label(2, 0), "-"), "contradiction has no label")
    emit(action_is(1, D.ladder(List.set(&2, D.Cell, all_cells(), 0n, D.Open{2}))), "naked single real placement")
    emit(action_is(2, D.ladder(row_without(8n, 1, 2, all_cells()))), "hidden single row digit1")
    emit(action_is(3, D.ladder(row_without(6n, 3, 2, all_cells()))), "locked candidates pointing/claiming")
    emit(action_is(4, D.ladder(pair_cells())), "naked pair actual elimination")
    emit(action_is(0, D.pair_go(243n, 0, List.set(&2, D.Cell, all_cells(), 0n, D.Open{6}), D.NoAction{})), "one two-mask cell is not a pair")
    emit(D.missing_go(243n, 0, row_without(9n, 0, 2, all_cells())), "unit digit with no placement contradiction")
    emit(D.zero_cell(List.set(&2, D.Cell, all_cells(), 0n, D.Open{0})), "zero candidate contradiction")
    emit(seeds_valid(100n, 0), "100 complete seeded transformations valid")
    emit(batch_eq(1), "batch solve equals sequential3")
    emit(batch_eq(2), "batch check equals sequential3")
    emit(batch_eq(3), "batch count equals sequential3")
    emit(batch_eq(4), "batch rate equals sequential3")
    emit(String.eq(K.show(K.count_add(T.CountZero{}, T.CountZero{})), "0"), "count table Zero+Zero")
    emit(String.eq(K.show(K.count_add(T.CountZero{}, T.CountOne{})), "1"), "count table Zero+One")
    emit(String.eq(K.show(K.count_add(T.CountZero{}, T.CountMany{})), "2"), "count table Zero+Many")
    emit(String.eq(K.show(K.count_add(T.CountZero{}, T.CountFuel{})), "fuel"), "count table Zero+Fuel")
    emit(String.eq(K.show(K.count_add(T.CountOne{}, T.CountZero{})), "1"), "count table One+Zero")
    emit(String.eq(K.show(K.count_add(T.CountOne{}, T.CountOne{})), "2"), "count table One+One")
    emit(String.eq(K.show(K.count_add(T.CountOne{}, T.CountMany{})), "2"), "count table One+Many")
    emit(String.eq(K.show(K.count_add(T.CountOne{}, T.CountFuel{})), "fuel"), "count table One+Fuel")
    emit(String.eq(K.show(K.count_add(T.CountMany{}, T.CountZero{})), "2"), "count table Many+Zero")
    emit(String.eq(K.show(K.count_add(T.CountMany{}, T.CountOne{})), "2"), "count table Many+One")
    emit(String.eq(K.show(K.count_add(T.CountMany{}, T.CountMany{})), "2"), "count table Many+Many")
    emit(String.eq(K.show(K.count_add(T.CountMany{}, T.CountFuel{})), "2"), "count table Many+Fuel")
    emit(String.eq(K.show(K.count_add(T.CountFuel{}, T.CountZero{})), "fuel"), "count table Fuel+Zero")
    emit(String.eq(K.show(K.count_add(T.CountFuel{}, T.CountOne{})), "fuel"), "count table Fuel+One")
    emit(String.eq(K.show(K.count_add(T.CountFuel{}, T.CountMany{})), "2"), "count table Fuel+Many")
    emit(String.eq(K.show(K.count_add(T.CountFuel{}, T.CountFuel{})), "fuel"), "count table Fuel+Fuel")
    IO.print("RESULT: all assertions passed")
