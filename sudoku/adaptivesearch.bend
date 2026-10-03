import Base
import ./candidates.bend as C
import ./queuedcandidates.bend as Q

# Save a board only at a guess. Forced unwind clears a logical cell; before
# another forward step a guess restores its exact pre-choice occupancy snapshot.
# Every placement and every frame unwind remains one actual fuel operation.
type State is Type:
  Searching{board: Array<U32>, frames: Array<U32>, depth: U32, found: U32, snapshots: List<&1, Array<U32>>, active: Bool}
  Backtracking{board: Array<U32>, frames: Array<U32>, depth: U32, found: U32, snapshots: List<&1, Array<U32>>, active: Bool}
  SnapshotDone{found: U32, answer: Array<U32>}
  SnapshotFuel{}

def activated(+active: Bool, board: Array<U32>) -> Array<U32>:
  match active:
    case True{}:
      board
    case False{}:
      Q.encode(board)

def finish(+active: Bool, board: Array<U32>) -> Array<U32>:
  match active:
    case True{}:
      Q.decode(81n, 0, board)
    case False{}:
      board

def cleared(+active: Bool, board: Array<U32>, +pos: U32) -> Array<U32>:
  match active:
    case True{}:
      Array.set(U32, board, pos, 0)
    case False{}:
      Pair.fst(Array<U32>, U32, C.swap(board, pos, 0))

def swapped(+active: Bool, board: Array<U32>, +pos: U32, +digit: U32) -> Array<U32> & U32:
  match active:
    case True{}:
      (Q.place(False{}, pos, digit, board), 0)
    case False{}:
      C.swap(board, pos, digit)

def selection(+active: Bool, board: Array<U32>) -> Array<U32> & C.Choice:
  match active:
    case True{}:
      Q.select(board)
    case False{}:
      C.cached_select(board)

def placed(+pos: U32, +remaining: U32, +guess: Bool, frames: Array<U32>, +depth: U32, +found: U32, snapshots: List<&1, Array<U32>>, +active: Bool, r: Array<U32> & U32) -> State:
  (board, old) = r
  +frame = U32.or(pos, U32.or(U32.shln(remaining, 11n), Bool.pick(U32, guess, 2097152, 0)))
  Searching{board, Array.set(U32, frames, depth, frame), (depth + 1 : U32), found, snapshots, active}

def guessed(+pos: U32, +digit: U32, +remaining: U32, frames: Array<U32>, +depth: U32, +found: U32, snapshots: List<&1, Array<U32>>, +active: Bool, pair: Array<U32> & Array<U32>) -> State:
  (saved, board) = pair
  placed(pos, remaining, True{}, frames, depth, found, saved <> snapshots, True{}, (Q.place(True{}, pos, digit, board), 0))

def place(+guess: Bool, +pos: U32, +digit: U32, +remaining: U32, frames: Array<U32>, +depth: U32, +found: U32, snapshots: List<&1, Array<U32>>, +active: Bool, board: Array<U32>) -> State:
  match guess:
    case False{}:
      placed(pos, remaining, False{}, frames, depth, found, snapshots, active, swapped(active, board, pos, digit))
    case True{}:
      guessed(pos, digit, remaining, frames, depth, found, snapshots, active, Array.clone(U32, activated(active, board)))

def alternative(+digits: U32, +pos: U32, frames: Array<U32>, +depth: U32, +found: U32, snapshots: List<&1, Array<U32>>, +active: Bool, board: Array<U32>) -> State:
  match digits:
    case 0:
      Backtracking{board, frames, depth, found, snapshots, active}
    case +mask:
      +bit = U32.and(mask, (0 - mask : U32))
      guessed(pos, C.mask_count((bit - 1 : U32)), U32.xor(mask, bit), frames, depth, found, snapshots, active, Array.clone(U32, board))

def restore(+pos: U32, +remaining: U32, frames: Array<U32>, +depth: U32, +found: U32, snapshots: List<&1, Array<U32>>, +active: Bool) -> State:
  match snapshots:
    case saved <> tail:
      alternative(remaining, pos, frames, depth, found, tail, active, saved)
    case Nil{}:
      SnapshotFuel{}

def popped_guess(+guess: Bool, +pos: U32, +remaining: U32, frames: Array<U32>, +depth: U32, +found: U32, snapshots: List<&1, Array<U32>>, +active: Bool, board: Array<U32>) -> State:
  match guess:
    case True{}:
      restore(pos, remaining, frames, depth, found, snapshots, active)
    case False{}:
      Backtracking{cleared(active, board, pos), frames, depth, found, snapshots, active}

def popped(+depth: U32, +found: U32, snapshots: List<&1, Array<U32>>, +active: Bool, board: Array<U32>, r: Array<U32> & U32) -> State:
  (frames, +frame) = r
  popped_guess(U32.is_ne(U32.and(frame, 2097152), 0), U32.and(frame, 127), U32.and(U32.shrn(frame, 11n), 1023), frames, depth, found, snapshots, active, board)

def backtrack(+empty: Bool, frames: Array<U32>, +depth: U32, +found: U32, snapshots: List<&1, Array<U32>>, +active: Bool, board: Array<U32>) -> State:
  match empty:
    case True{}:
      SnapshotDone{found, finish(active, board)}
    case False{}:
      popped((depth - 1 : U32), found, snapshots, active, board, Array.get(U32, frames, (depth - 1 : U32)))

def record(+stop: Bool, board: Array<U32>, frames: Array<U32>, +depth: U32, +found: U32, snapshots: List<&1, Array<U32>>, +active: Bool) -> State:
  match stop:
    case True{}:
      SnapshotDone{found, finish(active, board)}
    case False{}:
      Backtracking{board, frames, depth, found, snapshots, active}

def selected_dead(+dead: Bool, frames: Array<U32>, +depth: U32, +found: U32, snapshots: List<&1, Array<U32>>, +active: Bool, board: Array<U32>, +pos: U32, +mask: U32, +size: U32) -> State:
  match dead:
    case True{}:
      Backtracking{board, frames, depth, found, snapshots, active}
    case False{}:
      +bit = U32.and(mask, (0 - mask : U32))
      place((size > 1 : U32), pos, C.mask_count((bit - 1 : U32)), U32.xor(mask, bit), frames, depth, found, snapshots, active, board)

def selected_complete(+complete: Bool, +limit: U32, frames: Array<U32>, +depth: U32, +found: U32, snapshots: List<&1, Array<U32>>, +active: Bool, board: Array<U32>, +pos: U32, +mask: U32, +size: U32) -> State:
  match complete:
    case True{}:
      record(((found + 1) >= limit : U32), board, frames, depth, (found + 1 : U32), snapshots, active)
    case False{}:
      selected_dead(U32.is_eq(size, 0), frames, depth, found, snapshots, active, board, pos, mask, size)

def selected(+limit: U32, frames: Array<U32>, +depth: U32, +found: U32, snapshots: List<&1, Array<U32>>, +active: Bool, r: Array<U32> & C.Choice) -> State:
  (board, choice) = r
  match choice:
    case C.Choice{+pos, mask, size}:
      selected_complete(U32.is_eq(pos, 81), limit, frames, depth, found, snapshots, active, board, pos, mask, size)

def search(+fuel: Nat, +limit: U32, state: State) -> State:
  match fuel state:
    case _ SnapshotDone{found, answer}:
      SnapshotDone{found, answer}
    case _ SnapshotFuel{}:
      SnapshotFuel{}
    case 0n _:
      SnapshotFuel{}
    case 1n+k Searching{board, frames, depth, found, snapshots, +active}:
      search(k, limit, selected(limit, frames, depth, found, snapshots, active, selection(active, board)))
    case 1n+k Backtracking{board, frames, +depth, found, snapshots, +active}:
      search(k, limit, backtrack(U32.is_eq(depth, 0), frames, depth, found, snapshots, active, board))

def prepared(+fuel: Nat, +limit: U32, board: Array<U32>) -> State:
  search(fuel, limit, Searching{board, [0 : U32*128n], 0, 0, Nil{}, False{}})
