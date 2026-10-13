# Source: bendlang/bend tests/check/unsafe_kind.bend, unchanged below attribution.
# Commit: ae1101ca7d15364f9274fa6b1367d175884a7da7 (Bend 2.0.36).
# https://github.com/bendlang/bend/blob/ae1101ca7d15364f9274fa6b1367d175884a7da7/tests/check/unsafe_kind.bend
# An @unsafe reference reaches datatype kinds and parameter types,
# including datatypes with no constructors.
import Base

def qsize(j: Array<Nat>) -> Quant:
  match j:
    case ALeaf{value}: &1
    case ANode{xs, ys}: &1

type D is Kind(qsize(Array.join(Nat, ALeaf{0n}, ALeaf{0n}))):
  Mk{}

def use(d: D) -> Nat:
  match d:
    case Mk{}: 0n

type Zero is Kind(qsize(Array.join(Nat, ALeaf{0n}, ALeaf{0n}))):

type P<-A: Kind(qsize(Array.join(Nat, ALeaf{0n}, ALeaf{0n})))> is Type:

#|SOME PROOFS FAIL
#|Error: 4 defs rely on unsafe or foreign code:
#|- D
#|- use
#|- Zero
#|- P
#|exit 1
