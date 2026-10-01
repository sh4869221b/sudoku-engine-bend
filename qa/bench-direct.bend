import Base
import ../sudoku/bench.bend as B
import ../sudoku/commands.bend as C
import ../sudoku/types.bend as T
import ../sudoku/generator.bend as G
import ../sudoku/board.bend as Board

def same(a: B.Stats, b: B.Stats) -> Bool:
  match a b:
    case B.Stats{sa, fa} B.Stats{sb, fb}:
      U32.is_eq(sa, sb) && U32.is_eq(fa, fb)

def compare(+s: String) -> Bool:
  same(B.direct_job(s), B.count_reply(s, C.eval(1, False{}, T.solve_fuel(), T.rate_fuel(), s)))

def generated(r: G.DigResult) -> Bool:
  match r:
    case G.DigDone{b, clues}:
      compare(Board.show(b))
    case _:
      False{}

def seeds(n: Nat, +seed: U32) -> Bool:
  match n:
    case 0n:
      True{}
    case 1n+k:
      generated(G.generate(T.digging_fuel(), seed, 36, False{})) && seeds(k, (seed + 1 : U32))

def result(ok: Bool) -> IO(Unit):
  match ok:
    case True{}:
      IO.print("PASS direct BENCH board validation equals string/reparse path; 100 generated boards and edge cases")
    case False{}:
      IO.die(Unit, 1, "FAIL direct BENCH board validation")

def main() -> IO(Unit):
  result(seeds(100n, 0) && compare("") && compare("x") && compare("000000000000000000000000000000000000000000000000000000000000000000000000000000000") && compare("110000000000000000000000000000000000000000000000000000000000000000000000000000000") && compare("123456780000000009000000000000000000000000000000000000000000000000000000000000000") && compare("534678912672195348198342567859761423426853791713924856961537284287419635345286179") && compare("................................................................................."))
