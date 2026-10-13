# Source: bendlang/bend tests/proof/dependent_pair.bend, unchanged below attribution.
# Commit: ae1101ca7d15364f9274fa6b1367d175884a7da7 (Bend 2.0.36).
# https://github.com/bendlang/bend/blob/ae1101ca7d15364f9274fa6b1367d175884a7da7/tests/proof/dependent_pair.bend
# a dependent pair: the second field's type depends on the first field;
# matching refines snd's type to p(fst)
# ported from bend3: the parameterized type takes <> params like base Sigma
type N is Data:
  Z{}
  S{p: N}
type Uni is Data:
  U{}
type Emp is Data:

law isZ:
  for n: N
  Data

def isZ(n):
  match n:
    case Z{}:
      Uni
    case S{k}:
      Emp

type DPair<a, b, -T: Kind(a), -p: @x: T -> Kind(b)> is Kind(a <&> b):
  MkP{fst: T, snd: p(fst)}

law packed:
  DPair<&2, &2, N, isZ>

def packed(): MkP{Z{}, U{}}

law fst:
  for d: DPair<&2, &2, N, isZ>
  N

def fst(d):
  match d:
    case MkP{a, b}:
      a

law main:
  N

def main(): fst(packed())

#|Z{}
