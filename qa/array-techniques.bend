import Base
import ../sudoku/arraytechniques.bend as X
import ../sudoku/arrayrating.bend as A
import ../sudoku/ratingindex.bend as I
import ../sudoku/difficulty.bend as D
import ../sudoku/parser.bend as P
import ../sudoku/generator.bend as G
import ./rating-cache.bend as R

# Compare the full ordered action, including every elimination position.
# Expected actions use the unchanged list-based LC/NP implementation.
def compared(expected: D.Action, r: Array<U32> & Array<U32> & D.Action) -> Bool:
  (cells, (support, actual)) = r
  R.equal_action(expected, actual)

def compare(+xs: List<&2, D.Cell>) -> Bool:
  compared(D.ladder_locked(xs, D.NoAction{}), X.after_hidden(A.from_cells(xs, 0, [0 : U32*128n]), I.build(xs, 0, [0 : U32*256n])))

def trace(n: Nat, +xs: List<&2, D.Cell>) -> Bool:
  match n:
    case 0n:
      True{}
    case 1n+k:
      compare(xs) && trace(k, D.apply(xs, D.ladder(xs)))

def parsed(p: P.Parsed) -> Bool:
  match p:
    case P.ParseError{reason}:
      False{}
    case P.ParsedBoard{b}:
      trace(60n, D.initialize_cached(D.from_values(List.take(&1, U32, Array.to_list(~U32, b), 81n))))

def random_cells(n: Nat, +seed: U32) -> List<&2, D.Cell>:
  match n:
    case 0n:
      Nil{}
    case 1n+k:
      D.Open{U32.and(seed, 1022)} <> random_cells(k, G.next(seed))

def random_states(n: Nat, +seed: U32) -> Bool:
  match n:
    case 0n:
      True{}
    case 1n+k:
      compare(random_cells(81n, G.normalize(seed))) && random_states(k, (seed + 1 : U32))

def main() -> IO(Unit):
  do IO<Unit>:
    R.emit(parsed(P.parse81("530070000600195000098000060800060003400803001700020006060000280000419005000080079")), "packed LC/NP action order on60NS states")
    R.emit(parsed(P.parse81("000005601008100070000400000000900000005002700800000540000020103590000000080740090")), "packed LC/NP action order on60HS states")
    R.emit(parsed(P.parse81("008740006004200003060903700401050089000000000090400000000000900000000500025008040")), "packed LC/NP action order on60advanced states")
    R.emit(compare(R.pair_cells(81n, 0, 6)), "packed synthetic naked-pair action order")
    R.emit(random_states(256n, 0), "packed LC/NP versus untouched list reference256random mask states")
