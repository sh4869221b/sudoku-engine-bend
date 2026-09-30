import Base
import ./candidates.bend as C
import ./types.bend as T

# One affine board and one fixed-capacity affine stack. A frame packs position
# (7bits), old digit (4bits), and remaining candidate mask (10bits).
type SearchState is Type:
  Searching{board: Array<U32>, frames: Array<U32>, depth: U32, found: U32}
  Backtracking{board: Array<U32>, frames: Array<U32>, depth: U32, found: U32}
  SearchDone{found: U32, answer: Array<U32>}
  SearchFuel{}

def placed(pos: U32, remaining: U32, frames: Array<U32>, +depth: U32, found: U32, result: Array<U32> & U32) -> SearchState:
  (board, old) = result
  frame = U32.or(pos, U32.or(U32.shln(old, 7n), U32.shln(remaining, 11n)))
  Searching{board, Array.set(U32, frames, depth, frame), (depth + 1 : U32), found}

def alternatives(digits: U32, +pos: U32, frames: Array<U32>, depth: U32, found: U32, board: Array<U32>) -> SearchState:
  match digits:
    case 0:
      Backtracking{board, frames, depth, found}
    case +mask:
      +bit = U32.and(mask, (0 - mask : U32))
      +digit = C.mask_count((bit - 1 : U32))
      placed(pos, U32.xor(mask, bit), frames, depth, found, C.swap(board, pos, digit))

def restored(digits: U32, pos: U32, frames: Array<U32>, depth: U32, found: U32, result: Array<U32> & U32) -> SearchState:
  (board, discarded) = result
  alternatives(digits, pos, frames, depth, found, board)

def popped(depth: U32, found: U32, board: Array<U32>, r: Array<U32> & U32) -> SearchState:
  (frames, +frame) = r
  +pos = U32.and(frame, 127)
  +old = U32.and(U32.shrn(frame, 7n), 15)
  restored(U32.shrn(frame, 11n), pos, frames, depth, found, C.swap(board, pos, old))

def backtrack(empty: Bool, frames: Array<U32>, +depth: U32, found: U32, board: Array<U32>) -> SearchState:
  match empty:
    case True{}:
      SearchDone{found, board}
    case False{}:
      popped((depth - 1 : U32), found, board, Array.get(U32, frames, (depth - 1 : U32)))

def record(stop: Bool, board: Array<U32>, frames: Array<U32>, depth: U32, found: U32) -> SearchState:
  match stop:
    case True{}:
      SearchDone{found, board}
    case False{}:
      Backtracking{board, frames, depth, found}

def selected_dead(dead: Bool, frames: Array<U32>, depth: U32, found: U32, board: Array<U32>, pos: U32, mask: U32) -> SearchState:
  match dead:
    case True{}:
      Backtracking{board, frames, depth, found}
    case False{}:
      alternatives(mask, pos, frames, depth, found, board)

def selected_complete(complete: Bool, limit: U32, frames: Array<U32>, depth: U32, +found: U32, board: Array<U32>, pos: U32, mask: U32, size: U32) -> SearchState:
  match complete:
    case True{}:
      record(((found + 1) >= limit : U32), board, frames, depth, (found + 1 : U32))
    case False{}:
      selected_dead(U32.is_eq(size, 0), frames, depth, found, board, pos, mask)

def selected(limit: U32, frames: Array<U32>, depth: U32, found: U32, result: Array<U32> & C.Choice) -> SearchState:
  (board, choice) = result
  match choice:
    case C.Choice{+pos, mask, size}:
      selected_complete(U32.is_eq(pos, 81), limit, frames, depth, found, board, pos, mask, size)

def search(fuel: Nat, +limit: U32, state: SearchState) -> SearchState:
  match fuel state:
    case _ SearchDone{found, answer}:
      SearchDone{found, answer}
    case _ SearchFuel{}:
      SearchFuel{}
    case 0n _:
      SearchFuel{}
    case 1n+k Searching{board, frames, depth, found}:
      search(k, limit, selected(limit, frames, depth, found, C.cached_select(board)))
    case 1n+k Backtracking{board, frames, +depth, found}:
      search(k, limit, backtrack(U32.is_eq(depth, 0), frames, depth, found, board))

def run(fuel: Nat, limit: U32, board: Array<U32>) -> SearchState:
  search(fuel, limit, Searching{C.cache(board), [0 : U32*128n], 0, 0})
