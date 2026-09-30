import Base
import ./board.bend as B
import ./candidates.bend as C
import ./parser.bend as P

def mirror_all(n: Nat, +i: U32) -> Bool:
  match n:
    case 0n:
      True{}
    case 1n+k:
      U32.is_eq(B.mirror(B.mirror(i)), i) && mirror_all(k, (i + 1 : U32))

def read_equals(value: U32, r: Array<U32> & U32) -> Bool:
  (board, got) = r
  U32.is_eq(value, got)

def set_get(+i: U32, +value: U32) -> Bool:
  read_equals(value, Array.get(U32, Array.set(U32, B.empty(), i, value), i))

def set_get_all(n: Nat, +i: U32) -> Bool:
  match n:
    case 0n:
      True{}
    case 1n+k:
      set_get(i, 0) && set_get(i, 1) && set_get(i, 9) && set_get(i, 4294967295) && set_get_all(k, (i + 1 : U32))

def mask_in_range(+mask: U32) -> Bool:
  U32.is_eq(U32.and(mask, 1), 0) && (mask <= 1022 : U32)

def candidate_all(n: Nat, +i: U32, r: Array<U32> & U32) -> Bool:
  match n:
    case 0n:
      True{}
    case 1n+k:
      (b, m) = r
      mask_in_range(m) && candidate_all(k, (i + 1 : U32), C.at(b, (i + 1 : U32)))

def parsed_candidates(parsed: P.Parsed) -> Bool:
  match parsed:
    case P.ParseError{reason}:
      False{}
    case P.ParsedBoard{board}:
      candidate_all(81n, 0, C.at(board, 0))
