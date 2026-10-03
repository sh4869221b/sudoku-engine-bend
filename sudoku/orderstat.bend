import Base
import ./prng.bend as R

# A Fenwick tree represents the surviving positions in their original order.
# Selecting/removing the same ordinal preserves the old list shuffle exactly.
def initialize(+n: Nat, +index: U32, tree: Array<U32>) -> Array<U32>:
  match n:
    case 0n:
      tree
    case 1n+k:
      initialize(k, (index + 1 : U32), Array.set(U32, tree, index, U32.and(index, (0 - index : U32))))

def selected(+step: U32, +pos: U32, +rank: U32, r: Array<U32> & U32) -> Array<U32> & U32 & U32:
  (tree, +value) = r
  +take = (value <= rank : U32)
  (tree, (Bool.pick(U32, take, (pos + step : U32), pos), Bool.pick(U32, take, (rank - value : U32), rank)))

def read(+inside: Bool, +step: U32, +pos: U32, +rank: U32, tree: Array<U32>) -> Array<U32> & U32 & U32:
  match inside:
    case False{}:
      (tree, (pos, rank))
    case True{}:
      selected(step, pos, rank, Array.get(U32, tree, (pos + step : U32)))

def choose(+n: Nat, +step: U32, +bound: U32, r: Array<U32> & U32 & U32) -> Array<U32> & U32:
  match n:
    case 0n:
      (tree, (pos, rank)) = r
      (tree, pos)
    case 1n+k:
      (tree, (+pos, rank)) = r
      choose(k, U32.shr(step), bound, read(((pos + step) <= bound : U32), step, pos, rank, tree))

def decremented(+index: U32, r: Array<U32> & U32) -> Array<U32>:
  (tree, value) = r
  Array.set(U32, tree, index, (value - 1 : U32))

def erase(+n: Nat, +index: U32, +bound: U32, +active: Bool, tree: Array<U32>) -> Array<U32>:
  match n active:
    case _ False{}:
      tree
    case 0n True{}:
      tree
    case 1n+k True{}:
      +next = (index + U32.and(index, (0 - index : U32)) : U32)
      erase(k, next, bound, (next <= bound : U32), decremented(index, Array.get(U32, tree, index)))

def draws(+n: Nat, +seed: U32, +bound: U32, r: Array<U32> & U32) -> List<&2, U32>:
  match n:
    case 0n:
      Nil{}
    case 1n:
      [Pair.snd(Array<U32>, U32, r)]
    case 2n+k:
      (tree, +pos) = r
      +following = R.next(seed)
      pos <> draws(1n+k, following, bound, choose(7n, 64, bound, (erase(7n, (pos + 1 : U32), bound, True{}, tree), (0, (following % U32.from_nat(1n+k) : U32)))))

def shuffle(+n: Nat, +seed: U32) -> List<&2, U32>:
  match n:
    case 0n:
      Nil{}
    case 1n+k:
      +bound = U32.from_nat(1n+k)
      draws(1n+k, seed, bound, choose(7n, 64, bound, (initialize(1n+k, 1, [0 : U32*128n]), (0, (seed % bound : U32)))))
