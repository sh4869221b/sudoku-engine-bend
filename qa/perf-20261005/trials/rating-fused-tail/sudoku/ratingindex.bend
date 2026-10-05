import Base
import ./arithmetic.bend as M
import ./board.bend as B
import ./candidates.bend as C
import ./difficulty.bend as D

# Unit-digit support: low9 bits name unit members; bit10 means a fixed digit.
# Maintain this index after each action, rather than rebuilding and reading nine
# cells for every unit/digit on every ladder transition.
type IndexedState is Type:
  IndexedRating{cells: List<&2, D.Cell>, support: Array<U32>, tech: U32, steps: U32, score: U32}
  IndexedFinished{result: D.RateResult}

def write_bits(+index: U32, +remove: U32, +add: U32, r: Array<U32> & U32) -> Array<U32>:
  (cache, old) = r
  Array.set(U32, cache, index, U32.or(U32.and(old, U32.not(remove)), add))

def change(+unit: U32, +digit: U32, +remove: U32, +add: U32, cache: Array<U32>) -> Array<U32>:
  +index = (unit * 9 + digit - 1 : U32)
  write_bits(index, remove, add, Array.get(U32, cache, index))

def change_digit(+pos: U32, +digit: U32, +erase: Bool, +fixed: Bool, cache: Array<U32>) -> Array<U32>:
  +rowbit = B.bit((M.rem9(pos) : U32))
  +colbit = B.bit((M.div9(pos) : U32))
  +boxbit = B.bit(((M.rem3(M.div9(pos))) * 3 + M.rem3(pos) : U32))
  change((18 + B.box_of(pos) : U32), digit, Bool.pick(U32, erase, boxbit, 0), Bool.pick(U32, fixed, 1024, Bool.pick(U32, erase, 0, boxbit)),
    change((9 + M.rem9(pos) : U32), digit, Bool.pick(U32, erase, colbit, 0), Bool.pick(U32, fixed, 1024, Bool.pick(U32, erase, 0, colbit)),
      change((M.div9(pos) : U32), digit, Bool.pick(U32, erase, rowbit, 0), Bool.pick(U32, fixed, 1024, Bool.pick(U32, erase, 0, rowbit)), cache)))

def change_digits(ds: List<&2, U32>, +pos: U32, +erase: Bool, +fixed: Bool, cache: Array<U32>) -> Array<U32>:
  match ds:
    case Nil{}:
      cache
    case d <> tail:
      change_digits(tail, pos, erase, fixed, change_digit(pos, d, erase, fixed, cache))

def add_cell(+pos: U32, cell: D.Cell, cache: Array<U32>) -> Array<U32>:
  match cell:
    case D.Fixed{d}:
      change_digit(pos, d, False{}, True{}, cache)
    case D.Open{mask}:
      change_digits(C.mask_digits(mask), pos, False{}, False{}, cache)

def build(xs: List<&2, D.Cell>, +pos: U32, cache: Array<U32>) -> Array<U32>:
  match xs:
    case Nil{}:
      cache
    case h <> tail:
      build(tail, (pos + 1 : U32), add_cell(pos, h, cache))

def sync_masks(+same: Bool, +pos: U32, +mask: U32, +after: U32, cache: Array<U32>) -> Array<U32>:
  match same:
    case True{}:
      cache
    case False{}:
      change_digits(C.mask_digits(U32.and(mask, U32.not(after))), pos, True{}, False{}, cache)

def sync_cell(+pos: U32, old: D.Cell, next: D.Cell, cache: Array<U32>) -> Array<U32>:
  match old next:
    case D.Fixed{d} _:
      cache
    case D.Open{mask} D.Fixed{+d}:
      change_digit(pos, d, False{}, True{}, change_digits(C.mask_digits(mask), pos, True{}, False{}, cache))
    case D.Open{+mask} D.Open{+after}:
      sync_masks(U32.is_eq(mask, after), pos, mask, after, cache)

def sync(old: List<&2, D.Cell>, next: List<&2, D.Cell>, +pos: U32, cache: Array<U32>) -> Array<U32>:
  match old next:
    case h <> tail j <> rest:
      sync(tail, rest, (pos + 1 : U32), sync_cell(pos, h, j, cache))
    case _ _:
      cache

def missing(+n: Nat, +index: U32, r: Array<U32> & U32, +bad: Bool) -> Array<U32> & Bool:
  match n:
    case 0n:
      (Pair.fst(Array<U32>, U32, r), bad)
    case 1n:
      (cache, word) = r
      (cache, bad || U32.is_eq(word, 0))
    case 2n+k:
      (cache, word) = r
      missing(1n+k, (index + 1 : U32), Array.get(U32, cache, (index + 1 : U32)), bad || U32.is_eq(word, 0))

def naked_if(+one: Bool, +pos: U32, +mask: U32) -> D.Action:
  match one:
    case False{}:
      D.NoAction{}
    case True{}:
      D.Place{pos, C.mask_count((U32.and(mask, 1023) - 1 : U32)), 1}

def naked(xs: List<&2, D.Cell>, +pos: U32, found: D.Action) -> D.Action:
  match xs found:
    case _ D.Place{p, d, tech}:
      D.Place{p, d, tech}
    case _ D.Remove{ps, mask, tech}:
      D.Remove{ps, mask, tech}
    case Nil{} D.NoAction{}:
      D.NoAction{}
    case D.Fixed{d} <> tail D.NoAction{}:
      naked(tail, (pos + 1 : U32), D.NoAction{})
    case D.Open{+mask} <> tail D.NoAction{}:
      naked(tail, (pos + 1 : U32), naked_if(U32.is_eq(C.mask_count(mask), 1), pos, mask))

def hidden_if(+one: Bool, +index: U32, +word: U32, cache: Array<U32>) -> Array<U32> & D.Action:
  match one:
    case False{}:
      (cache, D.NoAction{})
    case True{}:
      +bit = U32.and(word, (0 - word : U32))
      (cache, D.Place{B.unit_pos((M.div9(index) : U32), C.mask_count((bit - 1 : U32))), (1 + M.rem9(index) : U32), 2})

def hidden_cell(+index: U32, r: Array<U32> & U32) -> Array<U32> & D.Action:
  (cache, +word) = r
  hidden_if((word < 1024 : U32) && U32.is_eq(C.mask_count(word), 1), index, word, cache)

def hidden(+n: Nat, +index: U32, r: Array<U32> & D.Action) -> Array<U32> & D.Action:
  match n r:
    case _ Tuple{cache, D.Place{p, d, tech}}:
      (cache, D.Place{p, d, tech})
    case _ Tuple{cache, D.Remove{ps, m, tech}}:
      (cache, D.Remove{ps, m, tech})
    case 0n Tuple{cache, D.NoAction{}}:
      (cache, D.NoAction{})
    case 1n+k Tuple{cache, D.NoAction{}}:
      hidden(k, (index + 1 : U32), hidden_cell(index, Array.get(U32, cache, index)))

# Continue checking every entry for missing support while retaining the first
# hidden single. Missing support has priority over any placement action.
def missing_hidden_found(+bad: Bool, r: Array<U32> & D.Action) -> Array<U32> & Bool & D.Action:
  (cache, found) = r
  (cache, (bad, found))

def missing_hidden_entry(+index: U32, +bad: Bool, r: Array<U32> & U32, action: D.Action) -> Array<U32> & Bool & D.Action:
  match r action:
    case Tuple{cache, +word} D.NoAction{}:
      missing_hidden_found(bad || U32.is_eq(word, 0), hidden_cell(index, (cache, word)))
    case Tuple{cache, word} other:
      (cache, (bad || U32.is_eq(word, 0), other))

def missing_hidden_tail(action: D.Action, r: Array<U32> & Bool) -> Array<U32> & Bool & D.Action:
  (cache, bad) = r
  (cache, (bad, action))

def missing_hidden(+n: Nat, +index: U32, r: Array<U32> & Bool & D.Action) -> Array<U32> & Bool & D.Action:
  match n r:
    case 0n other:
      other
    case 1n+k Tuple{cache, Tuple{bad, D.NoAction{}}}:
      missing_hidden(k, (index + 1 : U32), missing_hidden_entry(index, bad, Array.get(U32, cache, index), D.NoAction{}))
    case 1n+k Tuple{cache, Tuple{bad, action}}:
      missing_hidden_tail(action, missing(1n+k, index, Array.get(U32, cache, index), bad))

def positions(+unit: U32, ds: List<&2, U32>) -> List<&2, U32>:
  match ds:
    case Nil{}:
      Nil{}
    case +d <> tail:
      B.unit_pos(unit, (d - 1 : U32)) <> positions(unit, tail)

def locked_cell(+index: U32, xs: List<&2, D.Cell>, r: Array<U32> & U32) -> Array<U32> & D.Action:
  (cache, word) = r
  (cache, D.locked_support((M.div9(index) : U32), (1 + M.rem9(index) : U32), positions((M.div9(index) : U32), C.mask_digits(U32.shl(U32.and(word, 511)))), xs))

def locked(+n: Nat, +index: U32, +xs: List<&2, D.Cell>, r: Array<U32> & D.Action) -> Array<U32> & D.Action:
  match n r:
    case _ Tuple{cache, D.Place{p, d, tech}}:
      (cache, D.Place{p, d, tech})
    case _ Tuple{cache, D.Remove{ps, m, tech}}:
      (cache, D.Remove{ps, m, tech})
    case 0n Tuple{cache, D.NoAction{}}:
      (cache, D.NoAction{})
    case 1n+k Tuple{cache, D.NoAction{}}:
      locked(k, (index + 1 : U32), xs, locked_cell(index, xs, Array.get(U32, cache, index)))

def after_locked(xs: List<&2, D.Cell>, r: Array<U32> & D.Action) -> Array<U32> & D.Action:
  (cache, action) = r
  match action:
    case D.NoAction{}:
      (cache, D.cached_after_locked((D.cached_cells(xs, 0, [D.Open{0} : D.Cell*128n]), D.NoAction{})))
    case other:
      (cache, other)

def after_hidden(+xs: List<&2, D.Cell>, r: Array<U32> & D.Action) -> Array<U32> & D.Action:
  (cache, action) = r
  match action:
    case D.NoAction{}:
      after_locked(xs, locked(243n, 0, xs, (cache, D.NoAction{})))
    case other:
      (cache, other)

def after_naked(+xs: List<&2, D.Cell>, cache: Array<U32>, action: D.Action) -> Array<U32> & D.Action:
  match action:
    case D.NoAction{}:
      after_hidden(xs, hidden(243n, 0, (cache, D.NoAction{})))
    case other:
      (cache, other)

def make_step(+xs: List<&2, D.Cell>, +tech: U32, +steps: U32, +score: U32, r: Array<U32> & D.Action) -> IndexedState:
  (cache, action) = r
  match action:
    case D.NoAction{}:
      IndexedFinished{D.Rated{1, tech, steps, score}}
    case D.Place{+p, +d, +t}:
      +next = D.apply(xs, D.Place{p, d, t})
      IndexedRating{next, sync(xs, next, 0, cache), U32.max(tech, t), (steps + 1 : U32), (score + D.weight(t) : U32)}
    case D.Remove{+ps, +m, +t}:
      +next = D.apply(xs, D.Remove{ps, m, t})
      IndexedRating{next, sync(xs, next, 0, cache), U32.max(tech, t), (steps + 1 : U32), (score + D.weight(t) : U32)}

def ready(+bad: Bool, +complete: Bool, +xs: List<&2, D.Cell>, +tech: U32, +steps: U32, +score: U32, cache: Array<U32>) -> IndexedState:
  match bad complete:
    case True{} _:
      IndexedFinished{D.Rated{2, tech, steps, score}}
    case False{} True{}:
      IndexedFinished{D.Rated{0, tech, steps, score}}
    case False{} False{}:
      make_step(xs, tech, steps, score, after_naked(xs, cache, naked(xs, 0, D.NoAction{})))

def checked(+xs: List<&2, D.Cell>, +tech: U32, +steps: U32, +score: U32, r: Array<U32> & Bool) -> IndexedState:
  (cache, bad) = r
  ready(bad || D.zero_cell(xs), D.full(xs), xs, tech, steps, score, cache)

def loop(+fuel: Nat, state: IndexedState) -> D.RateResult:
  match fuel state:
    case _ IndexedFinished{result}:
      result
    case 0n IndexedRating{xs, cache, tech, steps, score}:
      D.Rated{3, tech, steps, score}
    case 1n+k IndexedRating{xs, cache, tech, steps, score}:
      loop(k, checked(xs, tech, steps, score, missing(243n, 0, Array.get(U32, cache, 0), False{})))

def rate_cells(+fuel: Nat, +xs: List<&2, D.Cell>) -> D.RateResult:
  loop(fuel, IndexedRating{xs, build(xs, 0, [0 : U32*256n]), 0, 0, 0})

def rate(+fuel: Nat, board: Array<U32>) -> D.RateResult:
  rate_cells(fuel, D.initialize_cached(D.from_values(List.take(&1, U32, Array.to_list(~U32, board), 81n))))
