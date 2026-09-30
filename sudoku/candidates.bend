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

def mask_count(+mask: U32) -> U32:
  +v = U32.and(mask, 1023)
  +a = (v - U32.and(U32.shrn(v, 1n), 341) : U32)
  +b = (U32.and(a, 819) + U32.and(U32.shrn(a, 2n), 819) : U32)
  +c = U32.and((b + U32.shrn(b, 4n) : U32), 3855)
  U32.and((c + U32.shrn(c, 8n) : U32), 31)

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

# Search-local unit occupancy occupies unused padding cells81..107. The public
# candidate API above remains valid for arbitrary uncached boards.
def cached_merge(used: U32, r: Array<U32> & U32) -> Array<U32> & U32:
  (b, next) = r
  (b, U32.or(used, next))

def cached_add(pos: U32, r: Array<U32> & U32) -> Array<U32> & U32:
  (b, used) = r
  cached_merge(used, Array.get(U32, b, pos))

def cached_at(b: Array<U32>, +p: U32) -> Array<U32> & U32:
  invert(cached_add((99 + B.box_of(p) : U32), cached_add((90 + p % 9 : U32), Array.get(U32, b, (81 + p / 9 : U32)))))

def cached_inspect(+pos: U32, prior: Choice, r: Array<U32> & U32) -> Array<U32> & Choice:
  (b, d) = r
  match d:
    case 0:
      choose(pos, prior, cached_at(b, pos))
    case _:
      (b, prior)

def cached_select_go(n: Nat, +pos: U32, r: Array<U32> & Choice) -> Array<U32> & Choice:
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
          cached_select_go(k, (pos + 1 : U32), cached_inspect(pos, Choice{p, m, size}, Array.get(U32, b, pos)))

def cached_start(r: Array<U32> & U32) -> Array<U32> & Choice:
  (b, +start) = r
  cached_select_go(U32.to_nat((81 - start : U32)), start, (b, Choice{81, 0, 10}))

def cached_select(b: Array<U32>) -> Array<U32> & Choice:
  cached_start(Array.get(U32, b, 108))

# The first empty cell is a lower bound for every MRV scan. Reuse that prefix
# instead of repeatedly reading already filled cells after forced placements.
def first_empty(n: Nat, +pos: U32, r: Array<U32> & U32) -> Array<U32>:
  match n:
    case 0n:
      Array.set(U32, Pair.fst(Array<U32>, U32, r), 108, 81)
    case 1n+k:
      (b, d) = r
      match d:
        case 0:
          Array.set(U32, b, 108, pos)
        case _:
          first_empty(k, (pos + 1 : U32), Array.get(U32, b, (pos + 1 : U32)))

def refresh_start(b: Array<U32>, +pos: U32) -> Array<U32>:
  first_empty(U32.to_nat((81 - pos : U32)), pos, Array.get(U32, b, pos))

def refresh_if(needed: Bool, b: Array<U32>, start: U32) -> Array<U32>:
  match needed:
    case True{}:
      refresh_start(b, start)
    case False{}:
      b

def start_after_set(blank: Bool, +pos: U32, r: Array<U32> & U32) -> Array<U32>:
  match blank:
    case True{}:
      (b, start) = r
      Array.set(U32, b, 108, U32.min(start, pos))
    case False{}:
      (b, +start) = r
      refresh_if(U32.is_eq(pos, start), b, start)


def cache_unit_done(pos: U32, r: Array<U32> & U32) -> Array<U32>:
  (b, used) = r
  Array.set(U32, b, pos, used)

def cache_units(n: Nat, +unit: U32, b: Array<U32>) -> Array<U32>:
  match n:
    case 0n:
      b
    case 1n+k:
      cache_units(k, (unit + 1 : U32), cache_unit_done((81 + unit : U32), unit_used(b, unit)))

def cache(b: Array<U32>) -> Array<U32>:
  refresh_start(cache_units(27n, 0, b), 0)

# Clearing the old digit then adding the replacement keeps row/column/box
# occupancy coherent on both placement and backtracking. Blank bit0 is ignored.
def update_done(pos: U32, old: U32, value: U32, r: Array<U32> & U32) -> Array<U32>:
  (b, used) = r
  Array.set(U32, b, pos, U32.or(U32.and(used, U32.not(B.bit(old))), B.bit(value)))

def update_unit(+pos: U32, old: U32, value: U32, b: Array<U32>) -> Array<U32>:
  update_done(pos, old, value, Array.get(U32, b, pos))

def swapped(+pos: U32, +value: U32, r: Array<U32> & U32) -> Array<U32> & U32:
  (b, +old) = r
  changed = update_unit((99 + B.box_of(pos) : U32), old, value, update_unit((90 + pos % 9 : U32), old, value, update_unit((81 + pos / 9 : U32), old, value, b)))
  (start_after_set(U32.is_eq(value, 0), pos, Array.get(U32, changed, 108)), old)

def swap(b: Array<U32>, +pos: U32, +value: U32) -> Array<U32> & U32:
  swapped(pos, value, Array.swap(U32, b, pos, value))
