import Base
import ./arithmetic.bend as M
import ./board.bend as B
import ./candidates.bend as C
import ./difficulty.bend as D

# Advanced rating actions use the affine packed cells directly. Action order is
# the original unit/digit, row/column/box target, and unit-member order.
def inside(+n: Nat, +bits: U32, +source: U32, +target: U32) -> Bool:
  match n bits:
    case _ 0:
      True{}
    case 0n _:
      False{}
    case 1n+k +mask:
      +bit = U32.and(mask, (0 - mask : U32))
      D.in_unit(target, B.unit_pos(source, C.mask_count((bit - 1 : U32)))) && inside(k, U32.xor(mask, bit), source, target)

def target_cell(+source: U32, +pos: U32, +bit: U32, +ps: List<&2, U32>, r: Array<U32> & U32) -> Array<U32> & List<&2, U32>:
  (cells, word) = r
  (cells, Bool.pick(List<&2, U32>, Bool.not(D.in_unit(source, pos)) && U32.is_ne(U32.and(U32.shrn(word, 4n), bit), 0), pos <> ps, ps))

def target_positions(+n: Nat, +source: U32, +target: U32, +j: U32, +bit: U32, r: Array<U32> & List<&2, U32>) -> Array<U32> & List<&2, U32>:
  match n:
    case 0n:
      r
    case 1n+k:
      (cells, ps) = r
      +pos = B.unit_pos(target, j)
      target_positions(k, source, target, (j + 1 : U32), bit, target_cell(source, pos, bit, ps, Array.get(U32, cells, pos)))

def removed(+bit: U32, r: Array<U32> & List<&2, U32>) -> Array<U32> & D.Action:
  (cells, ps) = r
  (cells, D.removal(List.reverse(&2, U32, ps), bit, 3))

def target_ready(+yes: Bool, +source: U32, +target: U32, +digit: U32, cells: Array<U32>) -> Array<U32> & D.Action:
  match yes:
    case False{}:
      (cells, D.NoAction{})
    case True{}:
      removed(B.bit(digit), target_positions(9n, source, target, 0, B.bit(digit), (cells, Nil{})))

def target(+source: U32, +target: U32, +digit: U32, +bits: U32, cells: Array<U32>) -> Array<U32> & D.Action:
  target_ready(U32.is_ne(source, target) && inside(9n, bits, source, target), source, target, digit, cells)

def box_target(+source: U32, +first: U32, +digit: U32, +bits: U32, r: Array<U32> & D.Action) -> Array<U32> & D.Action:
  match r:
    case Tuple{cells, D.NoAction{}}:
      target(source, (18 + B.box_of(first) : U32), digit, bits, cells)
    case other:
      other

def col_target(+source: U32, +first: U32, +digit: U32, +bits: U32, r: Array<U32> & D.Action) -> Array<U32> & D.Action:
  match r:
    case Tuple{cells, D.NoAction{}}:
      box_target(source, first, digit, bits, target(source, (9 + M.rem9(first) : U32), digit, bits, cells))
    case other:
      other

def locked_bits(+bits: U32, +source: U32, +digit: U32, cells: Array<U32>) -> Array<U32> & D.Action:
  match bits:
    case 0:
      (cells, D.NoAction{})
    case +mask:
      +first = B.unit_pos(source, C.mask_count((U32.and(mask, (0 - mask : U32)) - 1 : U32)))
      col_target(source, first, digit, mask, target(source, (M.div9(first) : U32), digit, mask, cells))

def entry_result(support: Array<U32>, r: Array<U32> & D.Action) -> Array<U32> & Array<U32> & D.Action:
  (cells, action) = r
  (cells, (support, action))

def locked_entry(+index: U32, cells: Array<U32>, r: Array<U32> & U32) -> Array<U32> & Array<U32> & D.Action:
  (support, word) = r
  entry_result(support, locked_bits(U32.and(word, 511), (M.div9(index) : U32), (1 + M.rem9(index) : U32), cells))

def locked(+n: Nat, +index: U32, r: Array<U32> & Array<U32> & D.Action) -> Array<U32> & Array<U32> & D.Action:
  match n r:
    case 1n+k Tuple{cells, Tuple{support, D.NoAction{}}}:
      locked(k, (index + 1 : U32), locked_entry(index, cells, Array.get(U32, support, index)))
    case _ other:
      other

def cached_pair_count_add(+bits: U32, +count: U32, r: Array<U32> & U32) -> Array<U32> & U32:
  (cache, c) = r
  (cache, (count + Bool.pick(U32, U32.is_eq(U32.shrn(c, 4n), bits), 1, 0) : U32))

def cached_pair_count_go(+n: Nat, +u: U32, +j: U32, +bits: U32, r: Array<U32> & U32) -> Array<U32> & U32:
  match n:
    case 0n:
      r
    case 1n+k:
      (cache, count) = r
      cached_pair_count_go(k, u, (j + 1 : U32), bits, cached_pair_count_add(bits, count, Array.get(U32, cache, B.unit_pos(u, j))))

def cached_pair_positions_add(+p: U32, +bits: U32, +ps: List<&2, U32>, r: Array<U32> & U32) -> Array<U32> & List<&2, U32>:
  (cache, c) = r
  +m = U32.shrn(c, 4n)
  (cache, Bool.pick(List<&2, U32>, U32.is_ne(m, bits) && U32.is_ne(U32.and(m, bits), 0), p <> ps, ps))

def cached_pair_positions_go(+n: Nat, +u: U32, +j: U32, +bits: U32, r: Array<U32> & List<&2, U32>) -> Array<U32> & List<&2, U32>:
  match n:
    case 0n:
      r
    case 1n+k:
      (cache, ps) = r
      +p = B.unit_pos(u, j)
      cached_pair_positions_go(k, u, (j + 1 : U32), bits, cached_pair_positions_add(p, bits, ps, Array.get(U32, cache, p)))

def cached_pair_remove(+bits: U32, r: Array<U32> & List<&2, U32>) -> Array<U32> & D.Action:
  (cache, ps) = r
  (cache, D.removal(List.reverse(&2, U32, ps), bits, 4))

def cached_pair_ready(+two: Bool, +unit: U32, +bits: U32, cache: Array<U32>) -> Array<U32> & D.Action:
  match two:
    case False{}:
      (cache, D.NoAction{})
    case True{}:
      cached_pair_remove(bits, cached_pair_positions_go(9n, unit, 0, bits, (cache, Nil{})))

def cached_pair_counted(+unit: U32, +bits: U32, r: Array<U32> & U32) -> Array<U32> & D.Action:
  (cache, count) = r
  cached_pair_ready(U32.is_eq(count, 2), unit, bits, cache)

def cached_pair_mask(+two: Bool, +unit: U32, +bits: U32, cache: Array<U32>) -> Array<U32> & D.Action:
  match two:
    case False{}:
      (cache, D.NoAction{})
    case True{}:
      cached_pair_counted(unit, bits, cached_pair_count_go(9n, unit, 0, bits, (cache, 0)))

def cached_pair_cell(+unit: U32, r: Array<U32> & U32) -> Array<U32> & D.Action:
  (cache, c) = r
  +bits = U32.shrn(c, 4n)
  cached_pair_mask(U32.is_eq(C.mask_count(bits), 2), unit, bits, cache)

def cached_pair_go(+n: Nat, +index: U32, r: Array<U32> & D.Action) -> Array<U32> & D.Action:
  match n r:
    case _ Tuple{cache, D.Place{p, d, tech}}:
      (cache, D.Place{p, d, tech})
    case _ Tuple{cache, D.Remove{ps, m, tech}}:
      (cache, D.Remove{ps, m, tech})
    case 0n Tuple{cache, D.NoAction{}}:
      (cache, D.NoAction{})
    case 1n+k Tuple{cache, D.NoAction{}}:
      +unit = (M.div9(index) : U32)
      cached_pair_go(k, (index + 1 : U32), cached_pair_cell(unit, Array.get(U32, cache, B.unit_pos(unit, (M.rem9(index) : U32)))))


def after_locked(r: Array<U32> & Array<U32> & D.Action) -> Array<U32> & Array<U32> & D.Action:
  match r:
    case Tuple{cells, Tuple{support, D.NoAction{}}}:
      entry_result(support, cached_pair_go(243n, 0, (cells, D.NoAction{})))
    case other:
      other

def after_hidden(cells: Array<U32>, support: Array<U32>) -> Array<U32> & Array<U32> & D.Action:
  after_locked(locked(243n, 0, (cells, (support, D.NoAction{}))))
