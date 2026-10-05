import Base
import ./arithmetic.bend as M
import ./board.bend as B
import ./validate.bend as V
import ./candidates.bend as C

type Parsed is Type:
  ParsedBoard{board: Array<U32>}
  ParseError{reason: String}

def finish(ok: Bool, b: Array<U32>) -> Parsed:
  match ok:
    case True{}:
      ParsedBoard{b}
    case False{}:
      ParseError{"length"}

def parse_go(s: String, +i: U32, b: Array<U32>, good: Bool) -> Parsed:
  match s good:
    case _ False{}:
      ParseError{"character"}
    case SNil{} True{}:
      finish(U32.is_eq(i, 81), b)
    case SCon{+h, t} True{}:
      +d = Char.to_u32(h)
      +v = Bool.pick(U32, Char.is_eq(h, '.'), 0, (d - 48 : U32))
      parse_go(t, (i + 1 : U32), Array.set(U32, b, i, v), (i < 81 : U32) && ((d >= 48 : U32) && (d <= 57 : U32) || Char.is_eq(h, '.')))

def check_length(ok: Bool, s: String) -> Parsed:
  match ok:
    case True{}:
      parse_go(s, 0, B.empty(), True{})
    case False{}:
      ParseError{"length"}

def single_finish(length_ok: Bool, good: Bool, b: Array<U32>) -> Parsed:
  match length_ok good:
    case False{} _:
      ParseError{"length"}
    case True{} False{}:
      ParseError{"character"}
    case True{} True{}:
      ParsedBoard{b}

def parse_single(s: String, +i: U32, b: Array<U32>, good: Bool, room: Bool) -> Parsed:
  match s:
    case SNil{}:
      single_finish(U32.is_eq(i, 81), good, b)
    case SCon{+h, t}:
      match room:
        case False{}:
          ParseError{"length"}
        case True{}:
          +d = Char.to_u32(h)
          +valid = ((d >= 48 : U32) && (d <= 57 : U32)) || Char.is_eq(h, '.')
          +v = Bool.pick(U32, (d >= 48 : U32) && (d <= 57 : U32), (d - 48 : U32), 0)
          parse_single(t, (i + 1 : U32), Array.set(U32, b, i, v), good && valid, (i < 80 : U32))

def parse81(s: String) -> Parsed:
  parse_single(s, 0, B.empty(), True{}, True{})

# Fused preparation validates characters and unit duplicates while constructing
# the board and search-local occupancy. Public parse81 retains its old contract.
def prepared_reason(ok: Bool, +start: U32, bad: U32, b: Array<U32>) -> Parsed:
  match ok:
    case True{}:
      ParsedBoard{Array.set(U32, b, 108, start)}
    case False{}:
      ParseError{V.kind(bad)}

def prepared_end(length_ok: Bool, good: Bool, +start: U32, r: Array<U32> & U32) -> Parsed:
  match length_ok good:
    case False{} _:
      ParseError{"length"}
    case True{} False{}:
      ParseError{"character"}
    case True{} True{}:
      (b, +bad) = r
      prepared_reason(U32.is_eq(bad, 27), start, bad, b)

def prepared_used(+unit: U32, +bit: U32, +bad: U32, r: Array<U32> & U32) -> Array<U32> & U32:
  (b, +used) = r
  (Array.set(U32, b, (81 + unit : U32), U32.or(used, bit)), U32.min(bad, Bool.pick(U32, U32.is_ne(U32.and(used, bit), 0), unit, 27)))

def prepared_unit(+unit: U32, +bit: U32, r: Array<U32> & U32) -> Array<U32> & U32:
  (b, bad) = r
  prepared_used(unit, bit, bad, Array.get(U32, b, (81 + unit : U32)))

def prepared_row_used(+unit: U32, +bit: U32, empty: U32, +bad: U32, r: Array<U32> & U32) -> Array<U32> & U32:
  (b, +used) = r
  (Array.set(U32, b, (81 + unit : U32), U32.or(U32.and(used, U32.not(empty)), bit)), U32.min(bad, Bool.pick(U32, U32.is_ne(U32.and(used, bit), 0), unit, 27)))

def prepared_row(+pos: U32, +bit: U32, r: Array<U32> & U32) -> Array<U32> & U32:
  (b, bad) = r
  +unit = M.div9(pos)
  prepared_row_used(unit, bit, B.bit((10 + M.rem9(pos) : U32)), bad, Array.get(U32, b, (81 + unit : U32)))

def prepared_set(+pos: U32, digit: U32, r: Array<U32> & U32) -> Array<U32> & U32:
  (b, bad) = r
  (Array.set(U32, b, pos, digit), bad)

def prepared_store(+pos: U32, digit: U32, r: Array<U32> & U32) -> Array<U32> & U32:
  match digit:
    case 0:
      prepared_set(pos, 0, r)
    case +d:
      +bit = B.bit(d)
      prepared_set(pos, d, prepared_unit((18 + B.box_of(pos) : U32), bit, prepared_unit((9 + M.rem9(pos) : U32), bit, prepared_row(pos, bit, r))))

def row_digit(+pos: U32, +digit: U32, +word: U32, r: Array<U32> & U32) -> Array<U32> & U32:
  (b, +bad) = r
  +bit = B.bit(digit)
  (b, U32.min(bad, Bool.pick(U32, U32.is_ne(U32.and(word, bit), 0), M.div9(pos), 27)))

def row_store(+pos: U32, +col: U32, digit: U32, +word: U32, r: Array<U32> & U32) -> Array<U32> & U32:
  match digit:
    case 0:
      prepared_set(pos, 0, r)
    case +d:
      +bit = B.bit(d)
      prepared_set(pos, d, prepared_unit((18 + B.box_of(pos) : U32), bit, prepared_unit((9 + col : U32), bit, row_digit(pos, d, word, r))))

def row_word(+col: U32, digit: U32, word: U32) -> U32:
  match digit:
    case 0:
      word
    case +d:
      U32.or(U32.and(word, U32.not(B.bit((10 + col : U32)))), B.bit(d))

def row_flush(last: Bool, +pos: U32, word: U32, r: Array<U32> & U32) -> Array<U32> & U32:
  match last:
    case False{}:
      r
    case True{}:
      (b, bad) = r
      (Array.set(U32, b, (81 + M.div9(pos) : U32), word), bad)

# Carry the current row's occupancy in a scalar and flush it once per row.
def prepared_scan(s: String, +pos: U32, +col: U32, +good: Bool, +start: U32, +word: U32, r: Array<U32> & U32) -> Parsed:
  match s:
    case SNil{}:
      prepared_end(U32.is_eq(pos, 81), good, start, r)
    case SCon{+h, tail}:
      match pos:
        case 81:
          ParseError{"length"}
        case +p:
          +d = Char.to_u32(h)
          +numeric = ((d >= 48 : U32) && (d <= 57 : U32))
          +valid = numeric || Char.is_eq(h, '.')
          +v = Bool.pick(U32, numeric, (d - 48 : U32), 0)
          +last = U32.is_eq(col, 8)
          +next = row_word(col, v, word)
          prepared_scan(tail, (p + 1 : U32), Bool.pick(U32, last, 0, (col + 1 : U32)), good && valid, U32.min(start, Bool.pick(U32, U32.is_eq(v, 0), p, 81)), Bool.pick(U32, last, 523264, next), row_flush(last, p, next, row_store(p, col, v, word, r)))

def prepare81(s: String) -> Parsed:
  prepared_scan(s, 0, 0, True{}, 81, 523264, (B.empty(), 27))
