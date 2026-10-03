import Base
import ./arithmetic.bend as M
import ./orderstat.bend as F
import ./prng.bend as R
import ./board.bend as B
import ./counter.bend as K
import ./types.bend as T

type Rng is Data:
  Rng{state: U32}

def normalize(+seed: U32) -> U32:
  Bool.pick(U32, U32.is_eq(seed, 0), 2463534242, seed)

def next(seed: U32) -> U32:
  R.next(seed)

def random(rng: Rng) -> Rng:
  match rng:
    case Rng{s}:
      Rng{next(s)}

def or_zero(v: Maybe<&2, U32>) -> U32:
  match v:
    case Some{x}:
      x
    case None{}:
      0

def nth(xs: List<&2, U32>, i: U32) -> U32:
  or_zero(List.get(&2, U32, xs, U32.to_nat(i)))

def without(xs: List<&2, U32>, i: Nat) -> List<&2, U32>:
  match xs i:
    case Nil{} _:
      Nil{}
    case h <> tail 0n:
      tail
    case h <> tail 1n+k:
      h <> without(tail, k)

def shuffle_go(+n: Nat, +seed: U32, +xs: List<&2, U32>) -> List<&2, U32>:
  match n:
    case 0n:
      Nil{}
    case 1n+k:
      +i = (seed % U32.from_nat(1n+k) : U32)
      nth(xs, i) <> shuffle_go(k, next(seed), without(xs, U32.to_nat(i)))

def shuffle(seed: U32, +xs: List<&2, U32>) -> List<&2, U32>:
  shuffle_go(List.length(&2, U32, xs), normalize(seed), xs)

def range(n: Nat, +start: U32) -> List<&2, U32>:
  match n:
    case 0n:
      Nil{}
    case 1n+k:
      start <> range(k, (start + 1 : U32))

# Each band/stack has an independently seeded permutation of its three entries.
def axis(+seed: U32, +i: U32) -> U32:
  (3 * nth(shuffle(seed, [0,1,2]), (M.div3(i) : U32)) + nth(shuffle(next((seed + M.div3(i) + 1 : U32)), [0,1,2]), (M.rem3(i) : U32)) : U32)

def complete_go(n: Nat, +i: U32, +seed: U32, +digits: List<&2, U32>, b: Array<U32>) -> Array<U32>:
  match n:
    case 0n:
      b
    case 1n+k:
      +r0 = (M.div9(i) : U32)
      +c0 = (M.rem9(i) : U32)
      +transpose = U32.is_ne(U32.and(seed, 1), 0)
      +r = axis(next(seed), Bool.pick(U32, transpose, c0, r0))
      +c = axis(next(next(seed)), Bool.pick(U32, transpose, r0, c0))
      +d = nth(digits, ((r * 3 + M.div3(r) + c) % 9 : U32))
      complete_go(k, (i + 1 : U32), seed, digits, Array.set(U32, b, i, d))

def axis_values(n: Nat, +i: U32, +seed: U32) -> List<&2, U32>:
  match n:
    case 0n:
      Nil{}
    case 1n+k:
      axis(seed, i) <> axis_values(k, (i + 1 : U32), seed)

def complete_cached(n: Nat, +i: U32, +transpose: Bool, +rows: List<&2, U32>, +cols: List<&2, U32>, +digits: List<&2, U32>, b: Array<U32>) -> Array<U32>:
  match n:
    case 0n:
      b
    case 1n+k:
      +r0 = (M.div9(i) : U32)
      +c0 = (M.rem9(i) : U32)
      +r = nth(rows, Bool.pick(U32, transpose, c0, r0))
      +c = nth(cols, Bool.pick(U32, transpose, r0, c0))
      +d = nth(digits, ((r * 3 + M.div3(r) + c) % 9 : U32))
      complete_cached(k, (i + 1 : U32), transpose, rows, cols, digits, Array.set(U32, b, i, d))

def complete(+seed: U32) -> Array<U32>:
  +s = normalize(seed)
  complete_cached(81n, 0, U32.is_ne(U32.and(s, 1), 0), axis_values(9n, 0, next(s)), axis_values(9n, 0, next(next(s))), shuffle(next(next(next(s))), [1,2,3,4,5,6,7,8,9]), B.empty())

type RemovalUnit is Data:
  Single{pos: U32}
  PairUnit{pos: U32}

def removal_units(positions: List<&2, U32>, +symmetry: Bool) -> List<&2, RemovalUnit>:
  match positions:
    case Nil{}:
      Nil{}
    case +p <> tail:
      Bool.pick(RemovalUnit, symmetry && U32.is_ne(p, 40), PairUnit{p}, Single{p}) <> removal_units(tail, symmetry)

def removal_pos(unit: RemovalUnit) -> U32:
  match unit:
    case Single{p}:
      p
    case PairUnit{p}:
      p

def removal_size(unit: RemovalUnit) -> U32:
  match unit:
    case Single{p}:
      1
    case PairUnit{p}:
      2

type DigResult is Type:
  DigDone{board: Array<U32>, clues: U32}
  DigFuel{}

def remove_unit(b: Array<U32>, +pos: U32, symmetry: Bool) -> Array<U32>:
  match symmetry:
    case False{}:
      Array.set(U32, b, pos, 0)
    case True{}:
      Array.set(U32, Array.set(U32, b, pos, 0), B.mirror(pos), 0)

def accept(old: Array<U32>, candidate: Array<U32>, clues: U32, size: U32, count: T.Count) -> DigResult:
  match count:
    case T.CountOne{}:
      DigDone{candidate, (clues - size : U32)}
    case T.CountFuel{}:
      DigFuel{}
    case _:
      DigDone{old, clues}

def count_candidate(fuel: Nat, old: Array<U32>, clues: U32, size: U32, pair: Array<U32> & Array<U32>) -> DigResult:
  (candidate, test) = pair
  accept(old, candidate, clues, size, K.count2(fuel, test))

def attempt(fuel: Nat, pos: U32, symmetry: Bool, clues: U32, size: U32, pair: Array<U32> & Array<U32>) -> DigResult:
  (old, candidate) = pair
  count_candidate(fuel, old, clues, size, Array.clone(U32, remove_unit(candidate, pos, symmetry)))

def try_unit(ok: Bool, fuel: Nat, pos: U32, symmetry: Bool, clues: U32, size: U32, b: Array<U32>) -> DigResult:
  match ok:
    case False{}:
      DigDone{b, clues}
    case True{}:
      attempt(fuel, pos, symmetry, clues, size, Array.clone(U32, b))

def dig_go(units: List<&2, RemovalUnit>, +fuel: Nat, +target: U32, +symmetry: Bool, state: DigResult) -> DigResult:
  match units state:
    case _ DigFuel{}:
      DigFuel{}
    case Nil{} DigDone{b, clues}:
      DigDone{b, clues}
    case +unit <> tail DigDone{b, +clues}:
      +pos = removal_pos(unit)
      +size = removal_size(unit)
      dig_go(tail, fuel, target, symmetry, try_unit((clues >= target + size : U32), fuel, pos, symmetry, clues, size, b))

def generate(fuel: Nat, +seed: U32, target: U32, +symmetry: Bool) -> DigResult:
  dig_go(removal_units(F.shuffle(Bool.pick(Nat, symmetry, 41n, 81n), normalize(next(normalize(seed)))), symmetry), fuel, target, symmetry, DigDone{complete(seed), 81})
