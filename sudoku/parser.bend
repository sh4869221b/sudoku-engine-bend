import Base
import ./board.bend as B

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
