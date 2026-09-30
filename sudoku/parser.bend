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

def parse81(+s: String) -> Parsed:
  check_length(Nat.is_eq(String.length(s), 81n), s)
