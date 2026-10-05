import Base
import ../sudoku/parser.bend as P
import ./parser-baseline-reference.bend as Ref
import ./row-bitmap.bend as Q
import ../sudoku/board.bend as B
import ../sudoku/prng.bend as R

def words(n: Nat, +pos: U32, a: Array<U32> & U32, b: Array<U32> & U32) -> Bool:
  match n a b:
    case 0n _ _:
      True{}
    case 1n+k Tuple{aa, x} Tuple{bb, y}:
      U32.is_eq(x, y) && words(k, (pos + 1 : U32), Array.get(U32, aa, (pos + 1 : U32)), Array.get(U32, bb, (pos + 1 : U32)))

def prepared(a: P.Parsed, b: Ref.Parsed) -> Bool:
  match a b:
    case P.ParseError{x} Ref.ParseError{y}:
      String.eq(x, y)
    case P.ParsedBoard{aa} Ref.ParsedBoard{bb}:
      words(128n, 0, Array.get(U32, aa, 0), Array.get(U32, bb, 0))
    case _ _:
      False{}

def prepare(+text: String) -> Bool:
  prepared(P.prepare81(text), Ref.prepare81(text))

def cases(n: Nat, +mode: U32, +seed: U32) -> Bool:
  match n:
    case 0n:
      True{}
    case 1n+k:
      prepare(B.show(Q.board(81n, 0, mode, seed, U32.and(U32.shrn(seed, 8n), 15), B.empty()))) && cases(k, mode, R.next(seed))

def replaced(n: Nat, s: String, +char: Char) -> String:
  match n s:
    case _ SNil{}:
      SNil{}
    case 0n SCon{h, t}:
      SCon{char, t}
    case 1n+k SCon{h, t}:
      SCon{h, replaced(k, t, char)}

def mutations(n: Nat, +pos: U32, +char: Char, +text: String) -> Bool:
  match n:
    case 0n:
      True{}
    case 1n+k:
      prepare(replaced(U32.to_nat(pos), text, char)) && mutations(k, (pos + 1 : U32), char, text)

def emit(ok: Bool) -> IO(Unit):
  match ok:
    case True{}:
      IO.print("PASS parser row-local:4096 random boards,486 character mutations,length edges;exact128-word arrays and exact errors versus baseline")
    case False{}:
      IO.die(Unit, 1, "FAIL parser row-local")

def run(+s: String) -> IO(Unit):
  emit(cases(1024n, 0, 42) && cases(1024n, 1, 19088743) && cases(1024n, 2, 4294967295) && cases(1024n, 3, 2654435769) && mutations(81n, 0, 'x', s) && mutations(81n, 0, '/', s) && mutations(81n, 0, ':', s) && mutations(81n, 0, '.', s) && mutations(81n, 0, '0', s) && mutations(81n, 0, Char.from_u32(128512), s) && prepare(s) && prepare(String.append(s, "x")) && prepare("x") && prepare("") && prepare("000000000000000000000000000000000000000000000000000000000000000000000000000000000") && prepare("00000000000000000000000000000000000000000000000000000000000000000000000000000000"))

def main() -> IO(Unit):
  run("123456789456789123789123456234567891567891234891234567345678912678912345912345678")
