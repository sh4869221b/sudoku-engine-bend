import Base
import ./parser.bend as P
import ./board.bend as B
import ./validate.bend as V
import ./solver.bend as S
import ./counter.bend as K
import ./types.bend as T
import ./difficulty.bend as D
import ./arrayrating.bend as A

type Reply is Data:
  Reply{code: U32, out: String, err: String}

def mode(+name: String) -> U32:
  Bool.pick(U32, String.eq(name, "solve"), 1, Bool.pick(U32, String.eq(name, "check"), 2, Bool.pick(U32, String.eq(name, "count"), 3, Bool.pick(U32, String.eq(name, "rate"), 4, 0))))

def solved(batch: Bool, result: T.SolveResult) -> Reply:
  match result:
    case T.Solved{b}:
      Reply{0, Bool.pick(String, batch, "solved:", "") ++ B.show(b), ""}
    case T.Unsolved{}:
      Reply{3, "unsolved", ""}
    case T.OutOfFuel{}:
      Reply{4, Bool.pick(String, batch, "error:fuel", ""), "fuel"}

def counted(batch: Bool, result: T.Count) -> Reply:
  match result:
    case T.CountFuel{}:
      Reply{4, Bool.pick(String, batch, "count:fuel", ""), "fuel"}
    case other:
      Reply{0, Bool.pick(String, batch, "count:", "") ++ K.show(other), ""}

def rated(batch: Bool, result: D.RateResult) -> Reply:
  match batch result:
    case True{} D.Rated{+status, +tech, +steps, +score}:
      Reply{Bool.pick(U32, (status < 2 : U32), 0, (status + 1 : U32)), D.line(D.Rated{status, tech, steps, score}), ""}
    case False{} D.Rated{2, tech, steps, score}:
      Reply{3, "", "contradiction"}
    case False{} D.Rated{3, tech, steps, score}:
      Reply{4, "", "fuel"}
    case False{} D.Rated{status, tech, steps, +score}:
      Reply{0, "Difficulty: " ++ D.label(status, score) ++ "\nMax technique: " ++ D.technique_name(tech) ++ "\nSteps: " ++ U32.show(steps) ++ "\nScore: " ++ U32.show(score), ""}

def run(mode: U32, batch: Bool, fuel: Nat, ratefuel: Nat, b: Array<U32>) -> Reply:
  match mode:
    case 1:
      solved(batch, S.solve(fuel, b))
    case 2:
      Reply{0, "valid", ""}
    case 3:
      counted(batch, K.count2(fuel, b))
    case 4:
      rated(batch, A.rate(ratefuel, b))
    case _:
      Reply{1, "", "unknown mode"}

def invalid(+mode: U32, +batch: Bool, +reason: String) -> Reply:
  Reply{2, Bool.pick(String, batch, "error:" ++ reason, Bool.pick(String, U32.is_eq(mode, 2), "invalid " ++ reason, "")), Bool.pick(String, batch || U32.is_eq(mode, 2), "", "invalid " ++ reason)}

def checked(ok: Bool, mode: U32, batch: Bool, fuel: Nat, ratefuel: Nat, b: Array<U32>, reason: String) -> Reply:
  match ok:
    case True{}:
      run(mode, batch, fuel, ratefuel, b)
    case False{}:
      invalid(mode, batch, reason)

def validated(mode: U32, batch: Bool, fuel: Nat, ratefuel: Nat, pair: Array<U32> & String) -> Reply:
  (b, +reason) = pair
  checked(String.is_empty(reason), mode, batch, fuel, ratefuel, b, reason)

def parsed(mode: U32, batch: Bool, fuel: Nat, ratefuel: Nat, result: P.Parsed) -> Reply:
  match result:
    case P.ParseError{reason}:
      invalid(mode, batch, reason)
    case P.ParsedBoard{b}:
      validated(mode, batch, fuel, ratefuel, V.validate(b))

def run_prepared(mode: U32, batch: Bool, fuel: Nat, ratefuel: Nat, b: Array<U32>) -> Reply:
  match mode:
    case 1:
      solved(batch, S.solve_prepared(fuel, b))
    case 2:
      Reply{0, "valid", ""}
    case 3:
      counted(batch, K.count2_prepared(fuel, b))
    case 4:
      rated(batch, A.rate(ratefuel, b))
    case _:
      Reply{1, "", "unknown mode"}

def parsed_prepared(mode: U32, batch: Bool, fuel: Nat, ratefuel: Nat, result: P.Parsed) -> Reply:
  match result:
    case P.ParseError{reason}:
      invalid(mode, batch, reason)
    case P.ParsedBoard{b}:
      run_prepared(mode, batch, fuel, ratefuel, b)

def eval(mode: U32, batch: Bool, fuel: Nat, ratefuel: Nat, puzzle: String) -> Reply:
  parsed_prepared(mode, batch, fuel, ratefuel, P.prepare81(puzzle))

def only_out(reply: Reply) -> String:
  match reply:
    case Reply{code, out, err}:
      out

# The batch solve leaf writes its suffix while rendering the board. Public
# Reply/eval formatting remains the oracle for all paths and other modes.
def solved_tail(result: T.SolveResult, tail: String) -> String:
  match result:
    case T.Solved{b}:
      "solved:" ++ B.show_tail(b, tail)
    case T.Unsolved{}:
      "unsolved" ++ tail
    case T.OutOfFuel{}:
      "error:fuel" ++ tail

def prepared_solve_tail(parsed: P.Parsed, tail: String) -> String:
  match parsed:
    case P.ParseError{reason}:
      "error:" ++ reason ++ tail
    case P.ParsedBoard{b}:
      solved_tail(S.solve_prepared(T.solve_fuel(), b), tail)

def batch_solve_tail(puzzle: String, tail: String) -> String:
  prepared_solve_tail(P.prepare81(puzzle), tail)
