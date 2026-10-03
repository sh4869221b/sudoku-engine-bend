import Base
import ../sudoku/validate.bend as V
import ./validation-reference.bend as O
import ../sudoku/board.bend as B
import ../sudoku/generator.bend as G
import ../sudoku/parser.bend as P

def replies(a: Array<U32> & String, b: Array<U32> & String) -> Bool:
  (ba, sa) = a
  (bb, sb) = b
  String.eq(sa, sb)

def cloned(pair: Array<U32> & Array<U32>) -> Bool:
  (a, b) = pair
  replies(O.validate(a), V.validate(b))

def compare(b: Array<U32>) -> Bool:
  cloned(Array.clone(U32, b))

def fill(n: Nat, +pos: U32, +seed: U32, +mask: U32, b: Array<U32>) -> Array<U32>:
  match n:
    case 0n:
      b
    case 1n+k:
      fill(k, (pos + 1 : U32), G.next(seed), mask, Array.set(U32, b, pos, U32.and(seed, mask)))

def boards(n: Nat, +seed: U32) -> Bool:
  match n:
    case 0n:
      True{}
    case 1n+k:
      compare(fill(81n, 0, seed, 15, B.empty())) && compare(fill(81n, 0, seed, 4294967295, B.empty())) && boards(k, G.next(seed))

def parsed(p: P.Parsed) -> Bool:
  match p:
    case P.ParsedBoard{b}:
      compare(b)
    case _:
      False{}

def edits(n: Nat, +pos: U32, p: P.Parsed) -> Bool:
  match n p:
    case 0n _:
      True{}
    case 1n+k P.ParsedBoard{b}:
      compare(Array.set(U32, b, pos, 0)) && edits(k, (pos + 1 : U32), P.parse81("534678912672195348198342567859761423426853791713924856961537284287419635345286179"))
    case _ _:
      False{}

def emit(ok: Bool) -> IO(Unit):
  match ok:
    case True{}:
      IO.print("PASS validation reason priority:2048random bounded/full-width boards,81valid complete-grid edits and edge grids versus untouched reference")
    case False{}:
      IO.die(Unit, 1, "FAIL validation diagnostics")

def main() -> IO(Unit):
  emit(boards(1024n, 4294967295) && edits(81n, 0, P.parse81("534678912672195348198342567859761423426853791713924856961537284287419635345286179")) && parsed(P.parse81(".................................................................................")) && parsed(P.parse81("110000000000000000000000000000000000000000000000000000000000000000000000000000000")))
