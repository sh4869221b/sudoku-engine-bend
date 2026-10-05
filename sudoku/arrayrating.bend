import Base
import ./arithmetic.bend as M
import ./board.bend as B
import ./candidates.bend as C
import ./difficulty.bend as D
import ./ratingindex.bend as I
import ./arraytechniques.bend as X

type ArrayState is Type:
  ArrayRating{cells: Array<U32>, support: Array<U32>, tech: U32, steps: U32, score: U32}
  ArrayFinished{result: D.RateResult}

def packed(cell: D.Cell) -> U32:
  match cell:
    case D.Fixed{d}:
      d
    case D.Open{mask}:
      U32.shln(mask, 4n)

def unpack_blank(+blank: Bool, +word: U32) -> D.Cell:
  match blank:
    case True{}:
      D.Open{U32.shrn(word, 4n)}
    case False{}:
      D.Fixed{U32.and(word, 15)}

def unpack(+word: U32) -> D.Cell:
  unpack_blank(U32.is_eq(U32.and(word, 15), 0), word)

def from_cells(xs: List<&2, D.Cell>, +pos: U32, b: Array<U32>) -> Array<U32>:
  match xs:
    case Nil{}:
      b
    case h <> tail:
      from_cells(tail, (pos + 1 : U32), Array.set(U32, b, pos, packed(h)))

def to_cells(xs: List<&1, U32>) -> List<&2, D.Cell>:
  match xs:
    case Nil{}:
      Nil{}
    case h <> tail:
      unpack(h) <> to_cells(tail)

def single_scan(+one: Bool, +pos: U32, +mask: U32, +bad: Bool, +full: Bool, +first: U32, +digit: U32, b: Array<U32>) -> Array<U32> & Bool & Bool & U32 & U32:
  match one:
    case True{}:
      (b, (bad, (full, (pos, C.mask_count((mask - 1 : U32))))))
    case False{}:
      (b, (bad, (full, (first, digit))))

def scan_blank(+blank: Bool, +pos: U32, +word: U32, +bad: Bool, +full: Bool, +first: U32, +digit: U32, b: Array<U32>) -> Array<U32> & Bool & Bool & U32 & U32:
  match blank:
    case False{}:
      (b, (bad, (full, (first, digit))))
    case True{}:
      +mask = U32.shrn(word, 4n)
      single_scan(U32.is_eq(first, 81) && U32.is_ne(mask, 0) && U32.is_eq(U32.and(mask, (mask - 1 : U32)), 0), pos, mask, bad || U32.is_eq(mask, 0), False{}, first, digit, b)

def scan_cell(+pos: U32, +bad: Bool, +full: Bool, +first: U32, +digit: U32, r: Array<U32> & U32) -> Array<U32> & Bool & Bool & U32 & U32:
  (b, +word) = r
  scan_blank(U32.is_eq(U32.and(word, 15), 0), pos, word, bad, full, first, digit, b)

def scan(+n: Nat, +pos: U32, r: Array<U32> & Bool & Bool & U32 & U32) -> Array<U32> & Bool & Bool & U32 & U32:
  match n:
    case 0n:
      r
    case 1n+k:
      (b, (bad, (full, (first, digit)))) = r
      scan(k, (pos + 1 : U32), scan_cell(pos, bad, full, first, digit, Array.get(U32, b, pos)))

def clear_open(+changed: Bool, +pos: U32, +bits: U32, +mask: U32, cells: Array<U32>, support: Array<U32>) -> Array<U32> & Array<U32>:
  match changed:
    case False{}:
      (cells, support)
    case True{}:
      +next = U32.and(mask, U32.not(bits))
      (Array.set(U32, cells, pos, U32.shln(next, 4n)), I.change_digits(C.mask_digits(U32.and(mask, bits)), pos, True{}, False{}, support))

def clear_blank(+blank: Bool, +pos: U32, +bits: U32, +word: U32, support: Array<U32>, cells: Array<U32>) -> Array<U32> & Array<U32>:
  match blank:
    case False{}:
      (cells, support)
    case True{}:
      +mask = U32.shrn(word, 4n)
      clear_open(U32.is_ne(U32.and(mask, bits), 0), pos, bits, mask, cells, support)

def clear_cell(+pos: U32, +bits: U32, support: Array<U32>, r: Array<U32> & U32) -> Array<U32> & Array<U32>:
  (cells, +word) = r
  clear_blank(U32.is_eq(U32.and(word, 15), 0), pos, bits, word, support, cells)

def clear_at(+pos: U32, +bits: U32, r: Array<U32> & Array<U32>) -> Array<U32> & Array<U32>:
  (cells, support) = r
  clear_cell(pos, bits, support, Array.get(U32, cells, pos))

def clear_unit(+n: Nat, +unit: U32, +j: U32, +bits: U32, r: Array<U32> & Array<U32>) -> Array<U32> & Array<U32>:
  match n:
    case 0n:
      r
    case 1n+k:
      clear_unit(k, unit, (j + 1 : U32), bits, clear_at(B.unit_pos(unit, j), bits, r))

def placed(+pos: U32, +digit: U32, support: Array<U32>, r: Array<U32> & U32) -> Array<U32> & Array<U32>:
  (cells, word) = r
  +mask = U32.shrn(word, 4n)
  clear_unit(9n, (18 + B.box_of(pos) : U32), 0, B.bit(digit),
    clear_unit(9n, (9 + M.rem9(pos) : U32), 0, B.bit(digit),
      clear_unit(9n, (M.div9(pos) : U32), 0, B.bit(digit),
        (Array.set(U32, cells, pos, digit), I.change_digit(pos, digit, False{}, True{}, I.change_digits(C.mask_digits(mask), pos, True{}, False{}, support))))))

def place(+pos: U32, +digit: U32, r: Array<U32> & Array<U32>) -> Array<U32> & Array<U32>:
  (cells, support) = r
  placed(pos, digit, support, Array.get(U32, cells, pos))

def remove(ps: List<&2, U32>, +bits: U32, r: Array<U32> & Array<U32>) -> Array<U32> & Array<U32>:
  match ps:
    case Nil{}:
      r
    case p <> tail:
      remove(tail, bits, clear_at(p, bits, r))

def apply(action: D.Action, r: Array<U32> & Array<U32>) -> Array<U32> & Array<U32>:
  match action:
    case D.NoAction{}:
      r
    case D.Place{p, d, t}:
      place(p, d, r)
    case D.Remove{ps, bits, t}:
      remove(ps, bits, r)

def stepped(+tech: U32, +steps: U32, +score: U32, +t: U32, r: Array<U32> & Array<U32>) -> ArrayState:
  (cells, support) = r
  ArrayRating{cells, support, U32.max(tech, t), (steps + 1 : U32), (score + D.weight(t) : U32)}

def action(+tech: U32, +steps: U32, +score: U32, cells: Array<U32>, r: Array<U32> & D.Action) -> ArrayState:
  (support, next) = r
  match next:
    case D.NoAction{}:
      ArrayFinished{D.Rated{1, tech, steps, score}}
    case D.Place{p, d, +t}:
      stepped(tech, steps, score, t, apply(D.Place{p, d, t}, (cells, support)))
    case D.Remove{ps, bits, +t}:
      stepped(tech, steps, score, t, apply(D.Remove{ps, bits, t}, (cells, support)))

def advanced(+tech: U32, +steps: U32, +score: U32, r: Array<U32> & Array<U32> & D.Action) -> ArrayState:
  (cells, (support, next)) = r
  action(tech, steps, score, cells, (support, next))

def fallback(+tech: U32, +steps: U32, +score: U32, support: Array<U32>, cells: Array<U32>) -> ArrayState:
  advanced(tech, steps, score, X.after_hidden(cells, support))

def hidden(+tech: U32, +steps: U32, +score: U32, cells: Array<U32>, r: Array<U32> & D.Action) -> ArrayState:
  (support, next) = r
  match next:
    case D.NoAction{}:
      fallback(tech, steps, score, support, cells)
    case other:
      action(tech, steps, score, cells, (support, other))

def naked(+first: U32, +digit: U32, +tech: U32, +steps: U32, +score: U32, cells: Array<U32>, support: Array<U32>) -> ArrayState:
  match first:
    case 81:
      hidden(tech, steps, score, cells, I.hidden(243n, 0, (support, D.NoAction{})))
    case p:
      action(tech, steps, score, cells, (support, D.Place{p, digit, 1}))

def ready(+bad: Bool, +full: Bool, +first: U32, +digit: U32, +tech: U32, +steps: U32, +score: U32, cells: Array<U32>, support: Array<U32>) -> ArrayState:
  match bad full:
    case True{} _:
      ArrayFinished{D.Rated{2, tech, steps, score}}
    case False{} True{}:
      ArrayFinished{D.Rated{0, tech, steps, score}}
    case False{} False{}:
      naked(first, digit, tech, steps, score, cells, support)

def supported(+bad: Bool, +full: Bool, +first: U32, +digit: U32, +tech: U32, +steps: U32, +score: U32, cells: Array<U32>, r: Array<U32> & Bool) -> ArrayState:
  (support, missing) = r
  ready(bad || missing, full, first, digit, tech, steps, score, cells, support)

def scanned_hidden(+tech: U32, +steps: U32, +score: U32, cells: Array<U32>, r: Array<U32> & Bool & D.Action) -> ArrayState:
  match r:
    case Tuple{support, Tuple{True{}, next}}:
      ArrayFinished{D.Rated{2, tech, steps, score}}
    case Tuple{support, Tuple{False{}, next}}:
      hidden(tech, steps, score, cells, (support, next))

def scanned_choose(+bad: Bool, +full: Bool, +first: U32, +digit: U32, +tech: U32, +steps: U32, +score: U32, cells: Array<U32>, support: Array<U32>) -> ArrayState:
  match bad full first:
    case False{} False{} 81:
      scanned_hidden(tech, steps, score, cells, I.missing_hidden(243n, 0, (support, (False{}, D.NoAction{}))))
    case _ _ _:
      supported(bad, full, first, digit, tech, steps, score, cells, I.missing(243n, 0, Array.get(U32, support, 0), False{}))

def scanned(+tech: U32, +steps: U32, +score: U32, support: Array<U32>, r: Array<U32> & Bool & Bool & U32 & U32) -> ArrayState:
  (cells, (bad, (full, (first, digit)))) = r
  scanned_choose(bad, full, first, digit, tech, steps, score, cells, support)

def loop(+fuel: Nat, state: ArrayState) -> D.RateResult:
  match fuel state:
    case _ ArrayFinished{result}:
      result
    case 0n ArrayRating{cells, support, tech, steps, score}:
      D.Rated{3, tech, steps, score}
    case 1n+k ArrayRating{cells, support, tech, steps, score}:
      loop(k, scanned(tech, steps, score, support, scan(81n, 0, (cells, (False{}, (True{}, (81, 0)))))))

def rate_cells(+fuel: Nat, +xs: List<&2, D.Cell>) -> D.RateResult:
  loop(fuel, ArrayRating{from_cells(xs, 0, [0 : U32*128n]), I.build(xs, 0, [0 : U32*256n]), 0, 0, 0})

def rate(+fuel: Nat, board: Array<U32>) -> D.RateResult:
  rate_cells(fuel, D.initialize_cached(D.from_values(List.take(&1, U32, Array.to_list(~U32, board), 81n))))
