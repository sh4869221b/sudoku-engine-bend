import Base
import ./search.bend as S
import ./types.bend as T

def count_add(a: T.Count, b: T.Count) -> T.Count:
  match a b:
    case T.CountMany{} _:
      T.CountMany{}
    case _ T.CountMany{}:
      T.CountMany{}
    case T.CountFuel{} _:
      T.CountFuel{}
    case _ T.CountFuel{}:
      T.CountFuel{}
    case T.CountZero{} x:
      x
    case x T.CountZero{}:
      x
    case T.CountOne{} T.CountOne{}:
      T.CountMany{}

def finish(state: S.SearchState) -> T.Count:
  match state:
    case S.SearchDone{0, answer}:
      T.CountZero{}
    case S.SearchDone{1, answer}:
      T.CountOne{}
    case S.SearchDone{n, answer}:
      T.CountMany{}
    case _:
      T.CountFuel{}

def count2(fuel: Nat, board: Array<U32>) -> T.Count:
  finish(S.run(fuel, 2, board))

def show(count: T.Count) -> String:
  match count:
    case T.CountZero{}:
      "0"
    case T.CountOne{}:
      "1"
    case T.CountMany{}:
      "2"
    case T.CountFuel{}:
      "fuel"

def count2_prepared(fuel: Nat, board: Array<U32>) -> T.Count:
  finish(S.run_prepared(fuel, 2, board))
