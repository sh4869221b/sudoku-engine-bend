import Base
import ./candidates.bend as C
import ./types.bend as T

# Every placement, including a forced single, records its old cell value.
# One affine Array is threaded through the entire sequential DFS.
type Frame is Data:
  Frame{pos: U32, old: U32, remaining: List<&2, U32>}

type SearchState is Type:
  Searching{board: Array<U32>, frames: List<&2, Frame>, found: U32}
  Backtracking{board: Array<U32>, frames: List<&2, Frame>, found: U32}
  SearchDone{found: U32, answer: Array<U32>}
  SearchFuel{}

def placed(pos: U32, remaining: List<&2, U32>, frames: List<&2, Frame>, found: U32, result: Array<U32> & U32) -> SearchState:
  (board, old) = result
  Searching{board, Frame{pos, old, remaining} <> frames, found}

def alternatives(digits: List<&2, U32>, +pos: U32, frames: List<&2, Frame>, found: U32, board: Array<U32>) -> SearchState:
  match digits:
    case Nil{}:
      Backtracking{board, frames, found}
    case digit <> rest:
      placed(pos, rest, frames, found, Array.swap(U32, board, pos, digit))

def restored(digits: List<&2, U32>, pos: U32, frames: List<&2, Frame>, found: U32, result: Array<U32> & U32) -> SearchState:
  (board, discarded) = result
  alternatives(digits, pos, frames, found, board)

def backtrack(frames: List<&2, Frame>, found: U32, board: Array<U32>) -> SearchState:
  match frames:
    case Nil{}:
      SearchDone{found, board}
    case Frame{+pos, old, remaining} <> rest:
      restored(remaining, pos, rest, found, Array.swap(U32, board, pos, old))

def record(stop: Bool, board: Array<U32>, frames: List<&2, Frame>, found: U32) -> SearchState:
  match stop:
    case True{}:
      SearchDone{found, board}
    case False{}:
      Backtracking{board, frames, found}

def selected_dead(dead: Bool, frames: List<&2, Frame>, found: U32, board: Array<U32>, pos: U32, mask: U32) -> SearchState:
  match dead:
    case True{}:
      Backtracking{board, frames, found}
    case False{}:
      alternatives(C.mask_digits(mask), pos, frames, found, board)

def selected_complete(complete: Bool, limit: U32, frames: List<&2, Frame>, +found: U32, board: Array<U32>, pos: U32, mask: U32, size: U32) -> SearchState:
  match complete:
    case True{}:
      record(((found + 1) >= limit : U32), board, frames, (found + 1 : U32))
    case False{}:
      selected_dead(U32.is_eq(size, 0), frames, found, board, pos, mask)

def selected(limit: U32, frames: List<&2, Frame>, found: U32, result: Array<U32> & C.Choice) -> SearchState:
  (board, choice) = result
  match choice:
    case C.Choice{+pos, mask, size}:
      selected_complete(U32.is_eq(pos, 81), limit, frames, found, board, pos, mask, size)

def search(fuel: Nat, +limit: U32, state: SearchState) -> SearchState:
  match fuel state:
    case _ SearchDone{found, answer}:
      SearchDone{found, answer}
    case _ SearchFuel{}:
      SearchFuel{}
    case 0n _:
      SearchFuel{}
    case 1n+k Searching{board, frames, found}:
      search(k, limit, selected(limit, frames, found, C.select(board)))
    case 1n+k Backtracking{board, frames, found}:
      search(k, limit, backtrack(frames, found, board))

def run(fuel: Nat, limit: U32, board: Array<U32>) -> SearchState:
  search(fuel, limit, Searching{board, Nil{}, 0})
