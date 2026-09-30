import Base

type SolveResult is Type:
  Solved{board: Array<U32>}
  Unsolved{}
  OutOfFuel{}

type Count is Data:
  CountZero{}
  CountOne{}
  CountMany{}
  CountFuel{}

def solve_fuel() -> Nat:
  200000n

def digging_fuel() -> Nat:
  20000n

def rate_fuel() -> Nat:
  729n
