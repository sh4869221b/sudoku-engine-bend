import Base
import ./board.bend as B

def used_go(n: Nat, +unit: U32, +j: U32, r: Array<U32> & U32, used: U32) -> Array<U32> & U32:
  match n:
    case 0n:
      (Pair.fst(Array<U32>, U32, r), used)
    case 1n+k:
      (b, d) = r
      used_go(k, unit, (j + 1 : U32), Array.get(U32, b, B.unit_pos(unit, (j + 1 : U32))), U32.or(used, B.bit(d)))

def unit_used(b: Array<U32>, +unit: U32) -> Array<U32> & U32:
  used_go(9n, unit, 0, Array.get(U32, b, B.unit_pos(unit, 0)), 0)

def add_unit(+unit: U32, r: Array<U32> & U32) -> Array<U32> & U32:
  (b, used) = r
  used_go(9n, unit, 0, Array.get(U32, b, B.unit_pos(unit, 0)), used)

def invert(r: Array<U32> & U32) -> Array<U32> & U32:
  (b, used) = r
  (b, U32.and(1022, U32.not(used)))

def at(b: Array<U32>, +p: U32) -> Array<U32> & U32:
  invert(add_unit((18 + B.box_of(p) : U32), add_unit((9 + p % 9 : U32), unit_used(b, (p / 9 : U32)))))

def pop(n: Nat, +mask: U32, acc: U32) -> U32:
  match n:
    case 0n:
      acc
    case 1n+k:
      pop(k, U32.shr(mask), (acc + U32.and(mask, 1) : U32))

def mask_count(mask: U32) -> U32:
  pop(10n, mask, 0)

def digits_go(n: Nat, +d: U32, +mask: U32) -> List<&2, U32>:
  match n:
    case 0n:
      Nil{}
    case 1n+k:
      List.append(&2, U32, Bool.pick(List<&2, U32>, U32.is_ne(U32.and(mask, B.bit(d)), 0), [d], Nil{}), digits_go(k, (d + 1 : U32), mask))


def mask_digits(mask: U32) -> List<&2, U32>:
  digits_go(9n, 1, mask)

type Choice is Data:
  Choice{pos: U32, mask: U32, size: U32}

def choose(+pos: U32, prior: Choice, r: Array<U32> & U32) -> Array<U32> & Choice:
  match prior:
    case Choice{oldpos, oldmask, +size}:
      (b, +mask) = r
      +n = mask_count(mask)
      (b, Bool.pick(Choice, (n < size : U32), Choice{pos, mask, n}, Choice{oldpos, oldmask, size}))

def inspect(+pos: U32, prior: Choice, r: Array<U32> & U32) -> Array<U32> & Choice:
  (b, d) = r
  match d:
    case 0:
      choose(pos, prior, at(b, pos))
    case _:
      (b, prior)

def select_go(n: Nat, +pos: U32, r: Array<U32> & Choice) -> Array<U32> & Choice:
  match n:
    case 0n:
      r
    case 1n+k:
      (b, choice) = r
      match choice:
        case Choice{p, m, 0}:
          (b, Choice{p, m, 0})
        case Choice{p, m, 1}:
          (b, Choice{p, m, 1})
        case Choice{p, m, size}:
          select_go(k, (pos + 1 : U32), inspect(pos, Choice{p, m, size}, Array.get(U32, b, pos)))

def select(b: Array<U32>) -> Array<U32> & Choice:
  select_go(81n, 0, (b, Choice{81, 0, 10}))
