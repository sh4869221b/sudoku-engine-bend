import Base

def empty() -> Array<U32>:
  [0 : U32*128n]

def mirror(p: U32) -> U32:
  (80 - p : U32)

def box_of(+p: U32) -> U32:
  ((p / 27) * 3 + (p % 9) / 3 : U32)

def peers(+p: U32, +q: U32) -> Bool:
  U32.is_ne(p, q) && (U32.is_eq((p / 9 : U32), (q / 9 : U32)) || U32.is_eq((p % 9 : U32), (q % 9 : U32)) || U32.is_eq(box_of(p), box_of(q)))

def bit(d: U32) -> U32:
  U32.shln(1, U32.to_nat(d))

# Sudoku digits need one character, avoiding general integer formatting.
def show_digit(single: Bool, d: U32, tail: String) -> String:
  match single:
    case True{}:
      SCon{Char.from_u32((48 + d : U32)), tail}
    case False{}:
      U32.show(d) ++ tail

def show_go(n: Nat, +i: U32, r: Array<U32> & U32) -> String:
  match n:
    case 0n:
      ""
    case 1n+k:
      (b, +d) = r
      show_digit((d <= 9 : U32), d, show_go(k, (i + 1 : U32), Array.get(U32, b, (i + 1 : U32))))

def show(b: Array<U32>) -> String:
  show_go(81n, 0, Array.get(U32, b, 0))

def clues_go(n: Nat, +i: U32, r: Array<U32> & U32, count: U32) -> Array<U32> & U32:
  match n:
    case 0n:
      (Pair.fst(Array<U32>, U32, r), count)
    case 1n+k:
      (b, d) = r
      clues_go(k, (i + 1 : U32), Array.get(U32, b, (i + 1 : U32)), (count + Bool.pick(U32, U32.is_ne(d, 0), 1, 0) : U32))

def clues(b: Array<U32>) -> Array<U32> & U32:
  clues_go(81n, 0, Array.get(U32, b, 0), 0)

def unit_pos(+unit: U32, +j: U32) -> U32:
  Bool.pick(U32, (unit < 9 : U32), (unit * 9 + j : U32),
    Bool.pick(U32, (unit < 18 : U32), (j * 9 + unit - 9 : U32),
      (((unit - 18) / 3) * 27 + ((unit - 18) % 3) * 3 + (j / 3) * 9 + j % 3 : U32)))

def complete_go(n: Nat, +i: U32, r: Array<U32> & U32, ok: Bool) -> Bool:
  match n:
    case 0n:
      ok
    case 1n+k:
      (b, +d) = r
      complete_go(k, (i + 1 : U32), Array.get(U32, b, (i + 1 : U32)), ok && (d >= 1 : U32) && (d <= 9 : U32))

def full(b: Array<U32>) -> Bool:
  complete_go(81n, 0, Array.get(U32, b, 0), True{})

def get_cell(b: Array<U32>, pos: U32) -> Array<U32> & U32:
  Array.get(U32, b, pos)

def set_cell(b: Array<U32>, pos: U32, value: U32) -> Array<U32>:
  Array.set(U32, b, pos, value)

def indices(n: Nat, +unit: U32, +j: U32) -> List<&2, U32>:
  match n:
    case 0n:
      Nil{}
    case 1n+k:
      unit_pos(unit, j) <> indices(k, unit, (j + 1 : U32))

def row_indices(row: U32) -> List<&2, U32>:
  indices(9n, row, 0)

def col_indices(col: U32) -> List<&2, U32>:
  indices(9n, (9 + col : U32), 0)

def box_indices(box: U32) -> List<&2, U32>:
  indices(9n, (18 + box : U32), 0)

def peer_indices_go(n: Nat, +pos: U32, +i: U32) -> List<&2, U32>:
  match n:
    case 0n:
      Nil{}
    case 1n+k:
      List.append(&2, U32, Bool.pick(List<&2, U32>, peers(pos, i), [i], Nil{}), peer_indices_go(k, pos, (i + 1 : U32)))

def peer_indices(pos: U32) -> List<&2, U32>:
  peer_indices_go(81n, pos, 0)
