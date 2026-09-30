import Base
import ./board.bend as B

def unit_go(n: Nat, +unit: U32, +j: U32, r: Array<U32> & U32, +used: U32, ok: Bool) -> Array<U32> & Bool:
  match n:
    case 0n:
      (Pair.fst(Array<U32>, U32, r), ok)
    case 1n+k:
      (b, +d) = r
      +bit = B.bit(d)
      unit_go(k, unit, (j + 1 : U32), Array.get(U32, b, B.unit_pos(unit, (j + 1 : U32))), U32.or(used, bit), ok && (d <= 9 : U32) && (U32.is_eq(d, 0) || U32.is_eq(U32.and(used, bit), 0)))

def kind(+unit: U32) -> String:
  Bool.pick(String, (unit < 9 : U32), "row:", Bool.pick(String, (unit < 18 : U32), "col:", "box:")) ++ U32.show((unit % 9 : U32))

def next_reason(+unit: U32, +prior: String, r: Array<U32> & Bool) -> Array<U32> & String:
  (b, ok) = r
  (b, Bool.pick(String, String.is_empty(prior), Bool.pick(String, ok, "", kind(unit)), prior))

def go(n: Nat, +unit: U32, r: Array<U32> & String) -> Array<U32> & String:
  match n:
    case 0n:
      r
    case 1n+k:
      (b, prior) = r
      go(k, (unit + 1 : U32), next_reason(unit, prior, unit_go(9n, unit, 0, Array.get(U32, b, B.unit_pos(unit, 0)), 0, True{})))

def validate(b: Array<U32>) -> Array<U32> & String:
  go(27n, 0, (b, ""))
