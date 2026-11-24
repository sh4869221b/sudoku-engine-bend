import Base
import ./sudoku/board.bend as B
import ./sudoku/counter.bend as K
import ./sudoku/types.bend as T
import ./sudoku/batch.bend as Batch
import ./sudoku/properties.bend as Props
import ./sudoku/parser.bend as P
import ./sudoku/commands.bend as Cmd
import ./sudoku/arrayrating.bend as A
import ./sudoku/difficulty.bend as D
import ./sudoku/solver.bend as S
import ./sudoku/candidates.bend as C
import ./sudoku/search.bend as Search
import ./sudoku/adaptivesearch.bend as Fast
import ./sudoku/validate.bend as V
import ./sudoku/queuedcandidates.bend as Q

law batch_solve_eq_seq:
  for +tree: Batch.JobTree
  {Batch.batch_solve(tree) == Batch.seq_solve(tree) : String}

law batch_check_eq_seq:
  for +tree: Batch.JobTree
  {Batch.batch_check(tree) == Batch.seq_check(tree) : String}

law batch_count_eq_seq:
  for +tree: Batch.JobTree
  {Batch.batch_count(tree) == Batch.seq_count(tree) : String}

law batch_rate_eq_seq:
  for +tree: Batch.JobTree
  {Batch.batch_rate(tree) == Batch.seq_rate(tree) : String}

law count_many_absorb:
  for count: T.Count
  {K.count_add(T.CountMany{}, count) == T.CountMany{} : T.Count}


# Modular subtraction is an involution for either initial carry bit.
law subtract_twice:
  for +n: Nat
  for +base: Word(n)
  for +word: Word(n)
  for +carry: Bool
  {Word.adc(n, base, Word.adc(n, base, word, True{}, carry), True{}, carry) == word : Word(n)}

law mirror_involute:
  for +position: U32
  {B.mirror(B.mirror(position)) == position : U32}

type DecidedCount is Data:
  DZero{}
  DOne{}
  DMany{}

def to_count(c: DecidedCount) -> T.Count:
  match c:
    case DZero{}:
      T.CountZero{}
    case DOne{}:
      T.CountOne{}
    case DMany{}:
      T.CountMany{}

law count_add_assoc:
  for +a: DecidedCount
  for +b: DecidedCount
  for +c: DecidedCount
  {K.count_add(K.count_add(to_count(a), to_count(b)), to_count(c)) == K.count_add(to_count(a), K.count_add(to_count(b), to_count(c))) : T.Count}

law string_append_empty:
  for +text: String
  {text ++ "" == text : String}

law string_append_assoc:
  for +a: String
  for -b: String
  for -c: String
  {(a ++ b) ++ c == a ++ (b ++ c) : String}

law batch_solve_tail:
  for +tree: Batch.JobTree
  for +tail: String
  {Batch.flatten(Batch.output_solve(tree), tail) == Batch.seq_solve(tree) ++ tail : String}

law batch_check_tail:
  for +tree: Batch.JobTree
  for +tail: String
  {Batch.flatten(Batch.output_check(tree), tail) == Batch.seq_check(tree) ++ tail : String}

law batch_count_tail:
  for +tree: Batch.JobTree
  for +tail: String
  {Batch.flatten(Batch.output_count(tree), tail) == Batch.seq_count(tree) ++ tail : String}

law batch_rate_tail:
  for +tree: Batch.JobTree
  for +tail: String
  {Batch.flatten(Batch.output_rate(tree), tail) == Batch.seq_rate(tree) ++ tail : String}

# CountMany is conclusive even if another branch exhausted its fuel.
# Otherwise fuel takes precedence over the sum of the exact counts.
def count_exact(c: T.Count) -> Nat:
  match c:
    case T.CountZero{}:
      0n
    case T.CountOne{}:
      1n
    case T.CountMany{}:
      2n
    case T.CountFuel{}:
      0n

def count_unknown(c: T.Count) -> Bool:
  match c:
    case T.CountFuel{}:
      True{}
    case _:
      False{}

def count_saturate(n: Nat, unknown: Bool) -> T.Count:
  match n unknown:
    case 2n+k _:
      T.CountMany{}
    case _ True{}:
      T.CountFuel{}
    case 0n False{}:
      T.CountZero{}
    case 1n False{}:
      T.CountOne{}

law count_add_spec:
  for +a: T.Count
  for +b: T.Count
  {K.count_add(a, b) == count_saturate(Nat.add(count_exact(a), count_exact(b)), count_unknown(a) || count_unknown(b)) : T.Count}

law count_show_spec:
  for +count: T.Count
  {K.show(count) == Bool.pick(String, count_unknown(count), "fuel", Nat.show(count_exact(count))) : String}

law show_digit_tail:
  for +short: Bool
  for +digit: U32
  for -rest: String
  for -tail: String
  {B.show_digit(short, digit, rest ++ tail) == B.show_digit(short, digit, rest) ++ tail : String}

law board_show_tail_go:
  for n: Nat
  for +index: U32
  for cells: Array<U32> & U32
  for +tail: String
  {B.show_tail_go(n, index, cells, tail) == B.show_go(n, index, cells) ++ tail : String}

law board_show_tail:
  for board: Array<U32>
  for +tail: String
  {B.show_tail(board, tail) == B.show(board) ++ tail : String}

law solved_tail:
  for result: T.SolveResult
  for +tail: String
  {Cmd.solved_tail(result, tail) == Cmd.only_out(Cmd.solved(True{}, result)) ++ tail : String}

# Pin the public batch markers separately from the formatter equivalence.
law unsolved_tail_text:
  for +tail: String
  {Cmd.solved_tail(T.Unsolved{}, tail) == "unsolved" ++ tail : String}

law out_of_fuel_tail_text:
  for +tail: String
  {Cmd.solved_tail(T.OutOfFuel{}, tail) == "error:fuel" ++ tail : String}

law prepared_solve_tail:
  for parsed: P.Parsed
  for +tail: String
  {Cmd.prepared_solve_tail(parsed, tail) == Cmd.only_out(Cmd.parsed_prepared(1, True{}, T.solve_fuel(), T.rate_fuel(), parsed)) ++ tail : String}

law batch_solve_leaf_tail:
  for puzzle: String
  for +tail: String
  {Cmd.batch_solve_tail(puzzle, tail) == Cmd.only_out(Cmd.eval(1, True{}, T.solve_fuel(), T.rate_fuel(), puzzle)) ++ tail : String}

# These are termination/dispatch contracts at exhausted fuel, not claims
# about boards returned by the search at nonzero fuel.
law solve_zero_fuel:
  for board: Array<U32>
  {S.solve(0n, board) == T.OutOfFuel{} : T.SolveResult}

law count_zero_fuel:
  for board: Array<U32>
  {K.count2(0n, board) == T.CountFuel{} : T.Count}

law rate_zero_fuel:
  for board: Array<U32>
  {A.rate(0n, board) == D.Rated{3, 0, 0, 0} : D.RateResult}

law mask_cmp_bit_le:
  for +bit: Bool
  for +value: Bool
  for +higher: Cmp
  for le: {Cmp.is_le(higher) == True{} : Bool}
  {Cmp.is_le(Word.cmp.fin(Bool.and(bit, value), bit, higher)) == True{} : Bool}

law mask_word_le:
  for +n: Nat
  for +mask: Word(n)
  for +value: Word(n)
  {Cmp.is_le(Word.cmp(n, Word.and(n, mask, value), mask)) == True{} : Bool}

law word_and_zero:
  for +n: Nat
  for +value: Word(n)
  {Word.and(n, value, Word.zero(n)) == Word.zero(n) : Word(n)}

law candidate_low_bit:
  for +value: U32
  {U32.and(U32.and(1022, value), 1) == 0 : U32}

law candidate_trim_bounds:
  for +value: U32
  {Props.mask_in_range(U32.and(1022, value)) == True{} : Bool}

law candidate_invert_bounds:
  for cells: Array<U32> & U32
  {Props.mask_in_range(Pair.snd(Array<U32>, U32, C.invert(cells))) == True{} : Bool}

law candidate_at_bounds:
  for board: Array<U32>
  for +position: U32
  {Props.mask_in_range(Pair.snd(Array<U32>, U32, C.at(board, position))) == True{} : Bool}

type BatchMode is Data:
  SolveMode{}
  CheckMode{}
  CountMode{}
  RateMode{}

def batch_mode(mode: BatchMode) -> U32:
  match mode:
    case SolveMode{}:
      1
    case CheckMode{}:
      2
    case CountMode{}:
      3
    case RateMode{}:
      4

law batch_job_line:
  for +mode: BatchMode
  for +index: U32
  for +puzzle: String
  {Batch.job_line(batch_mode(mode), Batch.Job{index, puzzle}) == U32.show(index) ++ " " ++ Cmd.only_out(Cmd.eval(batch_mode(mode), True{}, T.solve_fuel(), T.rate_fuel(), puzzle)) ++ "\n" : String}

law legacy_rate_zero_fuel:
  for board: Array<U32>
  {D.rate(0n, board) == D.Rated{3, 0, 0, 0} : D.RateResult}

# The write witness retains the updated array and proves that the write
# preserves its size and that its indexed read returns the new value.
# An affine array cannot be reused by two proof computations. Carry the
# updated tree, the common size, and the equations together through induction.
def ArrayWriteWitness(-a: Array<U32>, -n: U32, -i: U32, -v: U32, -z: Bool) -> Type:
  Sigma<&1, &1, Array<U32>, next =>
  Sigma<&1, &1, U32, old =>
  Sigma<&1, &1, U32, size =>
  ({Array.swap.go(U32, a, n, i, v, z) == (next, old) : Array<U32> & U32}
   & {Array.get.go(U32, next, n, i, z) == (next, v) : Array<U32> & U32}
   & {Array.size(U32, next) == (next, size) : Array<U32> & U32}
   & {Array.size(U32, a) == (a, size) : Array<U32> & U32})>>>

law array_swap_left:
  for -x: Array<U32>
  for y: Array<U32>
  for -n: U32
  for -i: U32
  for -v: U32
  for w: ArrayWriteWitness(x, U32.shr(n), i, v, U32.is_lt(i, U32.shr(U32.shr(n))))
  ArrayWriteWitness(ANode{x, y}, n, i, v, True{})

# Array.size follows the left spine and returns the original tree alongside
# its size. The reconstructed tree is an independently usable proof witness.
def ArraySizeWitness(-a: Array<U32>) -> Type:
  Sigma<&1, &1, Array<U32>, same =>
  Sigma<&1, &1, U32, size =>
  ({same == a : Array<U32>} & {Array.size(U32, a) == (same, size) : Array<U32> & U32})>>

law array_size_node:
  for -x: Array<U32>
  for y: Array<U32>
  for s: ArraySizeWitness(x)
  ArraySizeWitness(ANode{x, y})

law array_size_witness:
  for a: Array<U32>
  ArraySizeWitness(a)

law array_right_sizes:
  for -x: Array<U32>
  for -y: Array<U32>
  for -changed: Array<U32>
  for -n: U32
  for e: {Array.size(U32, x) == (x, n) : Array<U32> & U32}
  ({Array.size(U32, ANode{x, changed}) == (ANode{x, changed}, U32.shl(n)) : Array<U32> & U32}
  & {Array.size(U32, ANode{x, y}) == (ANode{x, y}, U32.shl(n)) : Array<U32> & U32})

law array_swap_right_at:
  for x: Array<U32>
  for -y: Array<U32>
  for +size: U32
  for +n: U32
  for +i: U32
  for -v: U32
  for esize: {Array.size(U32, x) == (x, size) : Array<U32> & U32}
  for w: ArrayWriteWitness(y, U32.shr(n), U32.sub(i, U32.shr(n)), v, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n))))
  ArrayWriteWitness(ANode{x, y}, n, i, v, False{})

law array_swap_right:
  for -x: Array<U32>
  for -y: Array<U32>
  for +n: U32
  for +i: U32
  for -v: U32
  for sized: ArraySizeWitness(x)
  for w: ArrayWriteWitness(y, U32.shr(n), U32.sub(i, U32.shr(n)), v, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n))))
  ArrayWriteWitness(ANode{x, y}, n, i, v, False{})

law array_swap_witness:
  for a: Array<U32>
  for +n: U32
  for +i: U32
  for +v: U32
  for z: Bool
  ArrayWriteWitness(a, n, i, v, z)

def BoardSetGet(-a: Array<U32>, -p: U32, -v: U32) -> Type:
  {Pair.snd(Array<U32>, U32, B.get_cell(B.set_cell(a, p, v), p)) == v : U32}

def read_after_swap(-p: U32, -v: U32, -r: Array<U32> & U32) -> Type:
  {Pair.snd(Array<U32>, U32, Array.get.at(U32, p, Array.size(U32, Array.set.fin(U32, r)))) == v : U32}

law board_set_get_aligned:
  for -a: Array<U32>
  for -p: U32
  for -v: U32
  for -size: U32
  for -next: Array<U32>
  for -old: U32
  for -next_size: U32
  for es: {Array.swap.go(U32, a, size, U32.and(p, U32.sub(size, 1)), v, U32.is_lt(U32.and(p, U32.sub(size, 1)), U32.shr(size))) == (next, old) : Array<U32> & U32}
  for eg: {Array.get.at(U32, p, (next, size)) == (next, v) : Array<U32> & U32}
  for en: {Array.size(U32, next) == (next, next_size) : Array<U32> & U32}
  for e: {(a, size) == (a, next_size) : Array<U32> & U32}
  read_after_swap(p, v, Array.swap.at(U32, p, v, (a, size)))

law board_set_get_witness:
  for -a: Array<U32>
  for -p: U32
  for -v: U32
  for -size: U32
  for e: {Array.size(U32, a) == (a, size) : Array<U32> & U32}
  for w: ArrayWriteWitness(a, size, U32.and(p, U32.sub(size, 1)), v, U32.is_lt(U32.and(p, U32.sub(size, 1)), U32.shr(size)))
  BoardSetGet(a, p, v)

law board_set_get_sized:
  for -a: Array<U32>
  for +p: U32
  for +v: U32
  for sized: ArraySizeWitness(a)
  BoardSetGet(a, p, v)

# Source-semantics read-after-write, with Base Array's index normalization.
law board_set_get:
  for board: Array<U32>
  for +position: U32
  for +value: U32
  {Pair.snd(Array<U32>, U32, B.get_cell(B.set_cell(board, position, value), position)) == value : U32}

law cached_candidate_bounds:
  for board: Array<U32>
  for +position: U32
  {Props.mask_in_range(Pair.snd(Array<U32>, U32, C.cached_at(board, position))) == True{} : Bool}

law row_candidate_bounds:
  for board: Array<U32>
  for +column: U32
  for +boxbase: U32
  for used: U32
  {Props.mask_in_range(Pair.snd(Array<U32>, U32, C.row_mask(board, column, boxbase, used))) == True{} : Bool}

# The witness returns the original tree and the actual read value.
def ArrayReadWitness(-a: Array<U32>, -n: U32, -i: U32, -z: Bool) -> Type:
  Sigma<&1, &1, Array<U32>, same =>
  Sigma<&1, &1, U32, value =>
  ({same == a : Array<U32>}
   & {Array.get.go(U32, a, n, i, z) == (same, value) : Array<U32> & U32})>>

law array_read_left:
  for -x: Array<U32>
  for y: Array<U32>
  for -n: U32
  for -i: U32
  for w: ArrayReadWitness(x, U32.shr(n), i, U32.is_lt(i, U32.shr(U32.shr(n))))
  ArrayReadWitness(ANode{x, y}, n, i, True{})

law array_read_right:
  for x: Array<U32>
  for -y: Array<U32>
  for +n: U32
  for +i: U32
  for w: ArrayReadWitness(y, U32.shr(n), U32.sub(i, U32.shr(n)), U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n))))
  ArrayReadWitness(ANode{x, y}, n, i, False{})

law array_get_witness:
  for a: Array<U32>
  for +n: U32
  for +i: U32
  for z: Bool
  ArrayReadWitness(a, n, i, z)

law array_read_projection:
  for -a: Array<U32>
  for -n: U32
  for -i: U32
  for -z: Bool
  for w: ArrayReadWitness(a, n, i, z)
  {Pair.fst(Array<U32>, U32, Array.get.go(U32, a, n, i, z)) == a : Array<U32>}

law array_get_at_preserves:
  for a: Array<U32>
  for +n: U32
  for +i: U32
  {Pair.fst(Array<U32>, U32, Array.get.at(U32, i, (a, n))) == a : Array<U32>}

law array_get_preserves_sized:
  for -a: Array<U32>
  for +i: U32
  for s: ArraySizeWitness(a)
  {Pair.fst(Array<U32>, U32, B.get_cell(a, i)) == a : Array<U32>}

law board_get_preserves:
  for a: Array<U32>
  for +i: U32
  {Pair.fst(Array<U32>, U32, B.get_cell(a, i)) == a : Array<U32>}

law solve_prepared_zero_fuel:
  for board: Array<U32>
  {S.solve_prepared(0n, board) == T.OutOfFuel{} : T.SolveResult}

law count_prepared_zero_fuel:
  for board: Array<U32>
  {K.count2_prepared(0n, board) == T.CountFuel{} : T.Count}

law search_terminal_done:
  for fuel: Nat
  for limit: U32
  for found: U32
  for board: Array<U32>
  {Search.search(fuel, limit, Search.SearchDone{found, board}) == Search.SearchDone{found, board} : Search.SearchState}

law search_terminal_fuel:
  for fuel: Nat
  for limit: U32
  {Search.search(fuel, limit, Search.SearchFuel{}) == Search.SearchFuel{} : Search.SearchState}

law adaptive_terminal_done:
  for fuel: Nat
  for limit: U32
  for found: U32
  for board: Array<U32>
  {Fast.search(fuel, limit, Fast.SnapshotDone{found, board}) == Fast.SnapshotDone{found, board} : Fast.State}

law adaptive_terminal_fuel:
  for fuel: Nat
  for limit: U32
  {Fast.search(fuel, limit, Fast.SnapshotFuel{}) == Fast.SnapshotFuel{} : Fast.State}

law adaptive_restore_empty:
  for pos: U32
  for remaining: U32
  for frames: Array<U32>
  for depth: U32
  for found: U32
  for active: Bool
  {Fast.restore(pos, remaining, frames, depth, found, Nil{}, active) == Fast.SnapshotFuel{} : Fast.State}

law solve_finish_zero:
  for board: Array<U32>
  {S.finish(Search.SearchDone{0, board}) == T.Unsolved{} : T.SolveResult}

law solve_finish_one:
  for board: Array<U32>
  {S.finish(Search.SearchDone{1, board}) == T.Solved{board} : T.SolveResult}

law solve_finish_fuel:
  {S.finish(Search.SearchFuel{}) == T.OutOfFuel{} : T.SolveResult}

law parser_bad_length_precedes_character:
  for ok: Bool
  for board: Array<U32>
  {P.single_finish(False{}, ok, board) == P.ParseError{"length"} : P.Parsed}

law prepared_bad_length_precedes_character:
  for ok: Bool
  for start: U32
  for pair: Array<U32> & U32
  {P.prepared_end(False{}, ok, start, pair) == P.ParseError{"length"} : P.Parsed}

law prepared_bad_character:
  for start: U32
  for pair: Array<U32> & U32
  {P.prepared_end(True{}, False{}, start, pair) == P.ParseError{"character"} : P.Parsed}

law validation_retains_prior:
  for unit: U32
  for prior: String
  for board: Array<U32>
  for ok: Bool
  {V.unused_reason(False{}, unit, prior, (board, ok)) == (board, prior) : Array<U32> & String}

law validation_first_reason:
  for unit: U32
  for board: Array<U32>
  {V.next_reason(unit, "", (board, False{})) == (board, V.kind(unit)) : Array<U32> & String}

law validation_no_reason_if_valid:
  for unit: U32
  for board: Array<U32>
  {V.next_reason(unit, "", (board, True{})) == (board, "") : Array<U32> & String}

# The complete 9x9 topology: independent row-major cell indices.

law row_indices_0:
  {B.row_indices(0) == [0, 1, 2, 3, 4, 5, 6, 7, 8] : List<&2, U32>}

law row_indices_1:
  {B.row_indices(1) == [9, 10, 11, 12, 13, 14, 15, 16, 17] : List<&2, U32>}

law row_indices_2:
  {B.row_indices(2) == [18, 19, 20, 21, 22, 23, 24, 25, 26] : List<&2, U32>}

law row_indices_3:
  {B.row_indices(3) == [27, 28, 29, 30, 31, 32, 33, 34, 35] : List<&2, U32>}

law row_indices_4:
  {B.row_indices(4) == [36, 37, 38, 39, 40, 41, 42, 43, 44] : List<&2, U32>}

law row_indices_5:
  {B.row_indices(5) == [45, 46, 47, 48, 49, 50, 51, 52, 53] : List<&2, U32>}

law row_indices_6:
  {B.row_indices(6) == [54, 55, 56, 57, 58, 59, 60, 61, 62] : List<&2, U32>}

law row_indices_7:
  {B.row_indices(7) == [63, 64, 65, 66, 67, 68, 69, 70, 71] : List<&2, U32>}

law row_indices_8:
  {B.row_indices(8) == [72, 73, 74, 75, 76, 77, 78, 79, 80] : List<&2, U32>}

law col_indices_0:
  {B.col_indices(0) == [0, 9, 18, 27, 36, 45, 54, 63, 72] : List<&2, U32>}

law col_indices_1:
  {B.col_indices(1) == [1, 10, 19, 28, 37, 46, 55, 64, 73] : List<&2, U32>}

law col_indices_2:
  {B.col_indices(2) == [2, 11, 20, 29, 38, 47, 56, 65, 74] : List<&2, U32>}

law col_indices_3:
  {B.col_indices(3) == [3, 12, 21, 30, 39, 48, 57, 66, 75] : List<&2, U32>}

law col_indices_4:
  {B.col_indices(4) == [4, 13, 22, 31, 40, 49, 58, 67, 76] : List<&2, U32>}

law col_indices_5:
  {B.col_indices(5) == [5, 14, 23, 32, 41, 50, 59, 68, 77] : List<&2, U32>}

law col_indices_6:
  {B.col_indices(6) == [6, 15, 24, 33, 42, 51, 60, 69, 78] : List<&2, U32>}

law col_indices_7:
  {B.col_indices(7) == [7, 16, 25, 34, 43, 52, 61, 70, 79] : List<&2, U32>}

law col_indices_8:
  {B.col_indices(8) == [8, 17, 26, 35, 44, 53, 62, 71, 80] : List<&2, U32>}

law box_indices_0:
  {B.box_indices(0) == [0, 1, 2, 9, 10, 11, 18, 19, 20] : List<&2, U32>}

law box_indices_1:
  {B.box_indices(1) == [3, 4, 5, 12, 13, 14, 21, 22, 23] : List<&2, U32>}

law box_indices_2:
  {B.box_indices(2) == [6, 7, 8, 15, 16, 17, 24, 25, 26] : List<&2, U32>}

law box_indices_3:
  {B.box_indices(3) == [27, 28, 29, 36, 37, 38, 45, 46, 47] : List<&2, U32>}

law box_indices_4:
  {B.box_indices(4) == [30, 31, 32, 39, 40, 41, 48, 49, 50] : List<&2, U32>}

law box_indices_5:
  {B.box_indices(5) == [33, 34, 35, 42, 43, 44, 51, 52, 53] : List<&2, U32>}

law box_indices_6:
  {B.box_indices(6) == [54, 55, 56, 63, 64, 65, 72, 73, 74] : List<&2, U32>}

law box_indices_7:
  {B.box_indices(7) == [57, 58, 59, 66, 67, 68, 75, 76, 77] : List<&2, U32>}

law box_indices_8:
  {B.box_indices(8) == [60, 61, 62, 69, 70, 71, 78, 79, 80] : List<&2, U32>}

# In addition to preservation, expose the exact value consumed by a scan.
def BoardReadWitness(-board: Array<U32>, -pos: U32) -> Type:
  Sigma<&1, &1, Array<U32>, same =>
  Sigma<&1, &1, U32, value =>
  ({same == board : Array<U32>}
   & {B.get_cell(board, pos) == (same, value) : Array<U32> & U32})>>

law board_read_sized_result:
  for -board: Array<U32>
  for -same: Array<U32>
  for -size: U32
  for -pos: U32
  for shape: {same == board : Array<U32>}
  for sized: {Array.size(U32, board) == (same, size) : Array<U32> & U32}
  for read: ArrayReadWitness(same, size, U32.and(pos, U32.sub(size, 1)), U32.is_lt(U32.and(pos, U32.sub(size, 1)), U32.shr(size)))
  BoardReadWitness(board, pos)

law board_read_sized:
  for -board: Array<U32>
  for +pos: U32
  for s: ArraySizeWitness(board)
  BoardReadWitness(board, pos)

law board_read_witness:
  for board: Array<U32>
  for +pos: U32
  BoardReadWitness(board, pos)

def ValidateUnitWitness(-n: Nat, -unit: U32, -j: U32, -input: Array<U32> & U32, -used: U32, -ok: Bool) -> Type:
  Sigma<&1, &1, Array<U32>, same =>
  Sigma<&1, &1, Bool, verdict =>
  ({same == Pair.fst(Array<U32>, U32, input) : Array<U32>}
   & {V.unit_go(n, unit, j, input, used, ok) == (same, verdict) : Array<U32> & Bool})>>

law validation_unit_join:
  for -n: Nat
  for -unit: U32
  for -j: U32
  for -board: Array<U32>
  for -d: U32
  for -used: U32
  for -ok: Bool
  for -next_board: Array<U32>
  for -next_d: U32
  for shape: {next_board == board : Array<U32>}
  for read: {B.get_cell(board, B.unit_pos(unit, (j + 1 : U32))) == (next_board, next_d) : Array<U32> & U32}
  for rest: ValidateUnitWitness(1n+n, unit, (j + 1 : U32), (next_board, next_d), U32.or(used, B.bit(d)), ok && (d <= 9 : U32) && (U32.is_eq(d, 0) || U32.is_eq(U32.and(used, B.bit(d)), 0)))
  ValidateUnitWitness(2n+n, unit, j, (board, d), used, ok)

law validation_unit_step:
  for +n: Nat
  for +unit: U32
  for +j: U32
  for -board: Array<U32>
  for +d: U32
  for +used: U32
  for +ok: Bool
  for read: BoardReadWitness(board, B.unit_pos(unit, (j + 1 : U32)))
  for visit: @r:(Array<U32> & U32) -> ValidateUnitWitness(1n+n, unit, (j + 1 : U32), r, U32.or(used, B.bit(d)), ok && (d <= 9 : U32) && (U32.is_eq(d, 0) || U32.is_eq(U32.and(used, B.bit(d)), 0)))
  ValidateUnitWitness(2n+n, unit, j, (board, d), used, ok)

law validation_unit_witness:
  for +n: Nat
  for +unit: U32
  for +j: U32
  for input: Array<U32> & U32
  for +used: U32
  for +ok: Bool
  ValidateUnitWitness(n, unit, j, input, used, ok)

law validation_unit_preserves_from_witness:
  for -n: Nat
  for -unit: U32
  for -j: U32
  for -input: Array<U32> & U32
  for -used: U32
  for -ok: Bool
  for w: ValidateUnitWitness(n, unit, j, input, used, ok)
  {Pair.fst(Array<U32>, Bool, V.unit_go(n, unit, j, input, used, ok)) == Pair.fst(Array<U32>, U32, input) : Array<U32>}

law validation_unit_preserves:
  for +n: Nat
  for +unit: U32
  for +j: U32
  for input: Array<U32> & U32
  for +used: U32
  for +ok: Bool
  {Pair.fst(Array<U32>, Bool, V.unit_go(n, unit, j, input, used, ok)) == Pair.fst(Array<U32>, U32, input) : Array<U32>}

law validation_unit_rejection_sticky:
  for +n: Nat
  for +unit: U32
  for +j: U32
  for input: Array<U32> & U32
  for +used: U32
  {Pair.snd(Array<U32>, Bool, V.unit_go(n, unit, j, input, used, False{})) == False{} : Bool}

law complete_rejection_sticky:
  for +n: Nat
  for +i: U32
  for input: Array<U32> & U32
  {B.complete_go(n, i, input, False{}) == False{} : Bool}

law parse_single_over_capacity:
  for head: Char
  for tail: String
  for i: U32
  for board: Array<U32>
  for good: Bool
  {P.parse_single(SCon{head, tail}, i, board, good, False{}) == P.ParseError{"length"} : P.Parsed}

law prepared_scan_over_capacity:
  for head: Char
  for tail: String
  for good: Bool
  for first: U32
  for pair: Array<U32> & U32
  {P.prepared_scan(SCon{head, tail}, 81, good, first, pair) == P.ParseError{"length"} : P.Parsed}

# Lift non-mutation from a single unit to the actual full-board validator.
def ValidateWitness(-n: Nat, -unit: U32, -input: Array<U32> & String) -> Type:
  Sigma<&1, &1, Array<U32>, same =>
  Sigma<&1, &1, String, reason =>
  ({same == Pair.fst(Array<U32>, String, input) : Array<U32>}
   & {V.go(n, unit, input) == (same, reason) : Array<U32> & String})>>

def next_reason_spec(+prior: String, +unit: U32, ok: Bool) -> String:
  match prior ok:
    case SNil{} True{}:
      ""
    case SNil{} False{}:
      V.kind(unit)
    case SCon{h, t} _:
      SCon{h, t}

law validation_reason_spec:
  for +unit: U32
  for +prior: String
  for -board: Array<U32>
  for ok: Bool
  {V.next_reason(unit, prior, (board, ok)) == (board, next_reason_spec(prior, unit, ok)) : Array<U32> & String}

law validation_continue:
  for -n: Nat
  for -unit: U32
  for -board: Array<U32>
  for -prior: String
  for -next_board: Array<U32>
  for -reason: String
  for shape: {next_board == board : Array<U32>}
  for step: {V.next_reason(unit, prior, V.unit_go(9n, unit, 0, B.get_cell(board, B.unit_pos(unit, 0)), 0, True{})) == (next_board, reason) : Array<U32> & String}
  for rest: ValidateWitness(n, (unit + 1 : U32), (next_board, reason))
  ValidateWitness(1n+n, unit, (board, prior))

law validation_continue_with_unit:
  for +n: Nat
  for +unit: U32
  for -board: Array<U32>
  for +prior: String
  for -read_board: Array<U32>
  for -digit: U32
  for same: {read_board == board : Array<U32>}
  for read: {B.get_cell(board, B.unit_pos(unit, 0)) == (read_board, digit) : Array<U32> & U32}
  for unit_result: ValidateUnitWitness(9n, unit, 0, (read_board, digit), 0, True{})
  for visit: @r:(Array<U32> & String) -> ValidateWitness(n, (unit + 1 : U32), r)
  ValidateWitness(1n+n, unit, (board, prior))

law validation_read_unit:
  for +n: Nat
  for +unit: U32
  for -board: Array<U32>
  for +prior: String
  for read: BoardReadWitness(board, B.unit_pos(unit, 0))
  for visit: @r:(Array<U32> & String) -> ValidateWitness(n, (unit + 1 : U32), r)
  ValidateWitness(1n+n, unit, (board, prior))

law validation_go_witness:
  for +n: Nat
  for +unit: U32
  for input: Array<U32> & String
  ValidateWitness(n, unit, input)

law validation_preserves_from_witness:
  for -board: Array<U32>
  for w: ValidateWitness(27n, 0, (board, ""))
  {Pair.fst(Array<U32>, String, V.validate(board)) == board : Array<U32>}

law validation_preserves_board:
  for board: Array<U32>
  {Pair.fst(Array<U32>, String, V.validate(board)) == board : Array<U32>}

law word_compare_reflexive:
  for +n: Nat
  for +w: Word(n)
  {Word.cmp(n, w, w) == EQ{} : Cmp}

law u32_compare_reflexive:
  for +p: U32
  {U32.cmp(p, p) == EQ{} : Cmp}

law peers_never_self:
  for +p: U32
  {B.peers(p, p) == False{} : Bool}

# Compare the real lookup table and low-bit enumeration with independent
# bit-by-bit references. The finite proof covers all 1,024 normalized inputs.
def mask_counts(+n: Nat, +mask: U32, +reference: Bool) -> List<&2, U32>:
  match n:
    case 0n:
      Nil{}
    case 1n+k:
      Bool.pick(U32, reference, C.pop(10n, mask, 0), C.mask_count(mask)) <> mask_counts(k, (mask + 1 : U32), reference)

def mask_lists(+n: Nat, +mask: U32, +reference: Bool) -> List<&2, List<&2, U32>>:
  match n:
    case 0n:
      Nil{}
    case 1n+k:
      Bool.pick(List<&2, U32>, reference, C.digits_go(9n, 1, mask), C.mask_digits(mask)) <> mask_lists(k, (mask + 1 : U32), reference)

law mask_counts_0000:
  {mask_counts(32n, 0, False{}) == mask_counts(32n, 0, True{}) : List<&2, U32>}

law mask_counts_0032:
  {mask_counts(32n, 32, False{}) == mask_counts(32n, 32, True{}) : List<&2, U32>}

law mask_counts_0064:
  {mask_counts(32n, 64, False{}) == mask_counts(32n, 64, True{}) : List<&2, U32>}

law mask_counts_0096:
  {mask_counts(32n, 96, False{}) == mask_counts(32n, 96, True{}) : List<&2, U32>}

law mask_counts_0128:
  {mask_counts(32n, 128, False{}) == mask_counts(32n, 128, True{}) : List<&2, U32>}

law mask_counts_0160:
  {mask_counts(32n, 160, False{}) == mask_counts(32n, 160, True{}) : List<&2, U32>}

law mask_counts_0192:
  {mask_counts(32n, 192, False{}) == mask_counts(32n, 192, True{}) : List<&2, U32>}

law mask_counts_0224:
  {mask_counts(32n, 224, False{}) == mask_counts(32n, 224, True{}) : List<&2, U32>}

law mask_counts_0256:
  {mask_counts(32n, 256, False{}) == mask_counts(32n, 256, True{}) : List<&2, U32>}

law mask_counts_0288:
  {mask_counts(32n, 288, False{}) == mask_counts(32n, 288, True{}) : List<&2, U32>}

law mask_counts_0320:
  {mask_counts(32n, 320, False{}) == mask_counts(32n, 320, True{}) : List<&2, U32>}

law mask_counts_0352:
  {mask_counts(32n, 352, False{}) == mask_counts(32n, 352, True{}) : List<&2, U32>}

law mask_counts_0384:
  {mask_counts(32n, 384, False{}) == mask_counts(32n, 384, True{}) : List<&2, U32>}

law mask_counts_0416:
  {mask_counts(32n, 416, False{}) == mask_counts(32n, 416, True{}) : List<&2, U32>}

law mask_counts_0448:
  {mask_counts(32n, 448, False{}) == mask_counts(32n, 448, True{}) : List<&2, U32>}

law mask_counts_0480:
  {mask_counts(32n, 480, False{}) == mask_counts(32n, 480, True{}) : List<&2, U32>}

law mask_counts_0512:
  {mask_counts(32n, 512, False{}) == mask_counts(32n, 512, True{}) : List<&2, U32>}

law mask_counts_0544:
  {mask_counts(32n, 544, False{}) == mask_counts(32n, 544, True{}) : List<&2, U32>}

law mask_counts_0576:
  {mask_counts(32n, 576, False{}) == mask_counts(32n, 576, True{}) : List<&2, U32>}

law mask_counts_0608:
  {mask_counts(32n, 608, False{}) == mask_counts(32n, 608, True{}) : List<&2, U32>}

law mask_counts_0640:
  {mask_counts(32n, 640, False{}) == mask_counts(32n, 640, True{}) : List<&2, U32>}

law mask_counts_0672:
  {mask_counts(32n, 672, False{}) == mask_counts(32n, 672, True{}) : List<&2, U32>}

law mask_counts_0704:
  {mask_counts(32n, 704, False{}) == mask_counts(32n, 704, True{}) : List<&2, U32>}

law mask_counts_0736:
  {mask_counts(32n, 736, False{}) == mask_counts(32n, 736, True{}) : List<&2, U32>}

law mask_counts_0768:
  {mask_counts(32n, 768, False{}) == mask_counts(32n, 768, True{}) : List<&2, U32>}

law mask_counts_0800:
  {mask_counts(32n, 800, False{}) == mask_counts(32n, 800, True{}) : List<&2, U32>}

law mask_counts_0832:
  {mask_counts(32n, 832, False{}) == mask_counts(32n, 832, True{}) : List<&2, U32>}

law mask_counts_0864:
  {mask_counts(32n, 864, False{}) == mask_counts(32n, 864, True{}) : List<&2, U32>}

law mask_counts_0896:
  {mask_counts(32n, 896, False{}) == mask_counts(32n, 896, True{}) : List<&2, U32>}

law mask_counts_0928:
  {mask_counts(32n, 928, False{}) == mask_counts(32n, 928, True{}) : List<&2, U32>}

law mask_counts_0960:
  {mask_counts(32n, 960, False{}) == mask_counts(32n, 960, True{}) : List<&2, U32>}

law mask_counts_0992:
  {mask_counts(32n, 992, False{}) == mask_counts(32n, 992, True{}) : List<&2, U32>}

law mask_lists_0000:
  {mask_lists(32n, 0, False{}) == mask_lists(32n, 0, True{}) : List<&2, List<&2, U32>>}

law mask_lists_0032:
  {mask_lists(32n, 32, False{}) == mask_lists(32n, 32, True{}) : List<&2, List<&2, U32>>}

law mask_lists_0064:
  {mask_lists(32n, 64, False{}) == mask_lists(32n, 64, True{}) : List<&2, List<&2, U32>>}

law mask_lists_0096:
  {mask_lists(32n, 96, False{}) == mask_lists(32n, 96, True{}) : List<&2, List<&2, U32>>}

law mask_lists_0128:
  {mask_lists(32n, 128, False{}) == mask_lists(32n, 128, True{}) : List<&2, List<&2, U32>>}

law mask_lists_0160:
  {mask_lists(32n, 160, False{}) == mask_lists(32n, 160, True{}) : List<&2, List<&2, U32>>}

law mask_lists_0192:
  {mask_lists(32n, 192, False{}) == mask_lists(32n, 192, True{}) : List<&2, List<&2, U32>>}

law mask_lists_0224:
  {mask_lists(32n, 224, False{}) == mask_lists(32n, 224, True{}) : List<&2, List<&2, U32>>}

law mask_lists_0256:
  {mask_lists(32n, 256, False{}) == mask_lists(32n, 256, True{}) : List<&2, List<&2, U32>>}

law mask_lists_0288:
  {mask_lists(32n, 288, False{}) == mask_lists(32n, 288, True{}) : List<&2, List<&2, U32>>}

law mask_lists_0320:
  {mask_lists(32n, 320, False{}) == mask_lists(32n, 320, True{}) : List<&2, List<&2, U32>>}

law mask_lists_0352:
  {mask_lists(32n, 352, False{}) == mask_lists(32n, 352, True{}) : List<&2, List<&2, U32>>}

law mask_lists_0384:
  {mask_lists(32n, 384, False{}) == mask_lists(32n, 384, True{}) : List<&2, List<&2, U32>>}

law mask_lists_0416:
  {mask_lists(32n, 416, False{}) == mask_lists(32n, 416, True{}) : List<&2, List<&2, U32>>}

law mask_lists_0448:
  {mask_lists(32n, 448, False{}) == mask_lists(32n, 448, True{}) : List<&2, List<&2, U32>>}

law mask_lists_0480:
  {mask_lists(32n, 480, False{}) == mask_lists(32n, 480, True{}) : List<&2, List<&2, U32>>}

law mask_lists_0512:
  {mask_lists(32n, 512, False{}) == mask_lists(32n, 512, True{}) : List<&2, List<&2, U32>>}

law mask_lists_0544:
  {mask_lists(32n, 544, False{}) == mask_lists(32n, 544, True{}) : List<&2, List<&2, U32>>}

law mask_lists_0576:
  {mask_lists(32n, 576, False{}) == mask_lists(32n, 576, True{}) : List<&2, List<&2, U32>>}

law mask_lists_0608:
  {mask_lists(32n, 608, False{}) == mask_lists(32n, 608, True{}) : List<&2, List<&2, U32>>}

law mask_lists_0640:
  {mask_lists(32n, 640, False{}) == mask_lists(32n, 640, True{}) : List<&2, List<&2, U32>>}

law mask_lists_0672:
  {mask_lists(32n, 672, False{}) == mask_lists(32n, 672, True{}) : List<&2, List<&2, U32>>}

law mask_lists_0704:
  {mask_lists(32n, 704, False{}) == mask_lists(32n, 704, True{}) : List<&2, List<&2, U32>>}

law mask_lists_0736:
  {mask_lists(32n, 736, False{}) == mask_lists(32n, 736, True{}) : List<&2, List<&2, U32>>}

law mask_lists_0768:
  {mask_lists(32n, 768, False{}) == mask_lists(32n, 768, True{}) : List<&2, List<&2, U32>>}

law mask_lists_0800:
  {mask_lists(32n, 800, False{}) == mask_lists(32n, 800, True{}) : List<&2, List<&2, U32>>}

law mask_lists_0832:
  {mask_lists(32n, 832, False{}) == mask_lists(32n, 832, True{}) : List<&2, List<&2, U32>>}

law mask_lists_0864:
  {mask_lists(32n, 864, False{}) == mask_lists(32n, 864, True{}) : List<&2, List<&2, U32>>}

law mask_lists_0896:
  {mask_lists(32n, 896, False{}) == mask_lists(32n, 896, True{}) : List<&2, List<&2, U32>>}

law mask_lists_0928:
  {mask_lists(32n, 928, False{}) == mask_lists(32n, 928, True{}) : List<&2, List<&2, U32>>}

law mask_lists_0960:
  {mask_lists(32n, 960, False{}) == mask_lists(32n, 960, True{}) : List<&2, List<&2, U32>>}

law mask_lists_0992:
  {mask_lists(32n, 992, False{}) == mask_lists(32n, 992, True{}) : List<&2, List<&2, U32>>}

# These are word-level laws. The full encode/decode loop additionally needs
# noninterference between a logical cell, other cells, and flag slots.
def fixed_roundtrip(+n: Nat, +digit: U32) -> List<&2, U32>:
  match n:
    case 0n:
      Nil{}
    case 1n+k:
      U32.shrn(U32.shln(digit, 10n), 10n) <> fixed_roundtrip(k, (digit + 1 : U32))

law fixed_word_roundtrip:
  {fixed_roundtrip(9n, 1) == [1,2,3,4,5,6,7,8,9] : List<&2, U32>}

law decode_cell_written:
  for board: Array<U32>
  for +pos: U32
  for +word: U32
  {Pair.snd(Array<U32>, U32, B.get_cell(Q.decoded(pos, (board, word)), pos)) == U32.shrn(word, 10n) : U32}

law decode_zero_steps:
  for +pos: U32
  for board: Array<U32>
  {Q.decode(0n, pos, board) == board : Array<U32>}

# Q.encoded's fixed-cell branch uses the actual array update.

law encode_fixed_cell_1:
  for board: Array<U32>
  for +pos: U32
  {Pair.snd(Array<U32>, U32, B.get_cell(Q.encoded(pos, (board, 1)), pos)) == 1024 : U32}

law encode_fixed_cell_2:
  for board: Array<U32>
  for +pos: U32
  {Pair.snd(Array<U32>, U32, B.get_cell(Q.encoded(pos, (board, 2)), pos)) == 2048 : U32}

law encode_fixed_cell_3:
  for board: Array<U32>
  for +pos: U32
  {Pair.snd(Array<U32>, U32, B.get_cell(Q.encoded(pos, (board, 3)), pos)) == 3072 : U32}

law encode_fixed_cell_4:
  for board: Array<U32>
  for +pos: U32
  {Pair.snd(Array<U32>, U32, B.get_cell(Q.encoded(pos, (board, 4)), pos)) == 4096 : U32}

law encode_fixed_cell_5:
  for board: Array<U32>
  for +pos: U32
  {Pair.snd(Array<U32>, U32, B.get_cell(Q.encoded(pos, (board, 5)), pos)) == 5120 : U32}

law encode_fixed_cell_6:
  for board: Array<U32>
  for +pos: U32
  {Pair.snd(Array<U32>, U32, B.get_cell(Q.encoded(pos, (board, 6)), pos)) == 6144 : U32}

law encode_fixed_cell_7:
  for board: Array<U32>
  for +pos: U32
  {Pair.snd(Array<U32>, U32, B.get_cell(Q.encoded(pos, (board, 7)), pos)) == 7168 : U32}

law encode_fixed_cell_8:
  for board: Array<U32>
  for +pos: U32
  {Pair.snd(Array<U32>, U32, B.get_cell(Q.encoded(pos, (board, 8)), pos)) == 8192 : U32}

law encode_fixed_cell_9:
  for board: Array<U32>
  for +pos: U32
  {Pair.snd(Array<U32>, U32, B.get_cell(Q.encoded(pos, (board, 9)), pos)) == 9216 : U32}

law word_and_repeat:
  for +n: Nat
  for +mask: Word(n)
  for +word: Word(n)
  {Word.and(n, Word.and(n, word, mask), mask) == Word.and(n, word, mask) : Word(n)}

law mask_digits_normalize:
  for +mask: U32
  {C.mask_digits(U32.and(mask, 1022)) == C.mask_digits(mask) : List<&2, U32>}

law mask_count_normalize:
  for +mask: U32
  {C.mask_count(U32.and(mask, 1023)) == C.mask_count(mask) : U32}

# Structural zero of the candidate representation after removing ten bits.
law word_zero_and:
  for +n: Nat
  for +word: Word(n)
  {Word.and(n, Word.zero(n), word) == Word.zero(n) : Word(n)}

law candidate_word_decodes_blank:
  for +word: U32
  {U32.shrn(U32.and(1022, word), 10n) == 0 : U32}

law inverted_candidate_decodes_blank:
  for cells: Array<U32> & U32
  {U32.shrn(Pair.snd(Array<U32>, U32, C.invert(cells)), 10n) == 0 : U32}

# All possible one-hot inputs, including bit 31 and wrapped multiplication.
def flag_positions(+n: Nat, +index: Nat) -> List<&2, U32>:
  match n:
    case 0n:
      Nil{}
    case 1n+k:
      +bit = U32.shln(1, index)
      Q.trailing(U32.shrn((bit * 125613361 : U32), 27n)) <> flag_positions(k, (1n+index))

law urgent_flag_positions:
  {flag_positions(32n, 0n) == [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31] : List<&2, U32>}

law queued_occupied_not_a_candidate:
  for board: Array<U32>
  for +pos: U32
  for +prior_pos: U32
  for +prior_mask: U32
  for +prior_size: U32
  for +word: U32
  {Q.advance(False{}, pos, prior_pos, prior_mask, prior_size, board, word) == (board, (prior_pos, (prior_mask, prior_size))) : Array<U32> & U32 & U32 & U32}

law queued_urgent_zero:
  for board: Array<U32>
  for +pos: U32
  {Q.urgent(pos, (board, 0)) == (board, C.Choice{pos, 0, 0}) : Array<U32> & C.Choice}

law adaptive_alternative_exhausted:
  for +pos: U32
  for frames: Array<U32>
  for +depth: U32
  for +found: U32
  for snapshots: List<&1, Array<U32>>
  for +active: Bool
  for board: Array<U32>
  {Fast.alternative(0, pos, frames, depth, found, snapshots, active, board) == Fast.Backtracking{board, frames, depth, found, snapshots, active} : Fast.State}

law adaptive_empty_alternatives_restore_snapshot:
  for +pos: U32
  for frames: Array<U32>
  for +depth: U32
  for +found: U32
  for saved: Array<U32>
  for snapshots: List<&1, Array<U32>>
  for +active: Bool
  {Fast.restore(pos, 0, frames, depth, found, saved <> snapshots, active) == Fast.Backtracking{saved, frames, depth, found, snapshots, active} : Fast.State}

# A read and a write which diverge at a tree node do not interfere.

law cross_left_read_projection:
  for -before: Array<U32>
  for -after: Array<U32>
  for read_result: Array<U32> & U32
  {Pair.snd(Array<U32>, U32, Array.swap.hi(U32, after, read_result)) == Pair.snd(Array<U32>, U32, Array.swap.hi(U32, before, read_result)) : U32}

law cross_left_write_result:
  for -written: Array<U32>
  for read_tree: Array<U32>
  for +n: U32
  for +j: U32
  for write_result: Array<U32> & U32
  {Pair.snd(Array<U32>, U32, Array.get.go(U32, Array.set.fin(U32, Array.swap.lo(U32, read_tree, write_result)), n, j, False{})) == Pair.snd(Array<U32>, U32, Array.get.go(U32, ANode{written, read_tree}, n, j, False{})) : U32}

law array_write_left_preserves_other:
  for written: Array<U32>
  for read_tree: Array<U32>
  for +n: U32
  for +i: U32
  for +j: U32
  for +value: U32
  {Pair.snd(Array<U32>, U32, Array.get.go(U32, Array.set.fin(U32, Array.swap.go(U32, ANode{written, read_tree}, n, i, value, True{})), n, j, False{})) == Pair.snd(Array<U32>, U32, Array.get.go(U32, ANode{written, read_tree}, n, j, False{})) : U32}

law cross_right_read_projection:
  for -before: Array<U32>
  for -after: Array<U32>
  for read_result: Array<U32> & U32
  {Pair.snd(Array<U32>, U32, Array.swap.lo(U32, after, read_result)) == Pair.snd(Array<U32>, U32, Array.swap.lo(U32, before, read_result)) : U32}

law cross_right_write_result:
  for -written: Array<U32>
  for read_tree: Array<U32>
  for +n: U32
  for +j: U32
  for write_result: Array<U32> & U32
  {Pair.snd(Array<U32>, U32, Array.get.go(U32, Array.set.fin(U32, Array.swap.hi(U32, read_tree, write_result)), n, j, True{})) == Pair.snd(Array<U32>, U32, Array.get.go(U32, ANode{read_tree, written}, n, j, True{})) : U32}

law array_write_right_preserves_other:
  for written: Array<U32>
  for read_tree: Array<U32>
  for +n: U32
  for +i: U32
  for +j: U32
  for +value: U32
  {Pair.snd(Array<U32>, U32, Array.get.go(U32, Array.set.fin(U32, Array.swap.go(U32, ANode{read_tree, written}, n, i, value, False{})), n, j, True{})) == Pair.snd(Array<U32>, U32, Array.get.go(U32, ANode{read_tree, written}, n, j, True{})) : U32}

# Snapshot ownership: cloning duplicates the exact source tree, not just digits.
law array_clone_join:
  for -left: Array<U32>
  for -right: Array<U32>
  for ea: {Array.clone(U32, left) == (left, left) : Array<U32> & Array<U32>}
  for eb: {Array.clone(U32, right) == (right, right) : Array<U32> & Array<U32>}
  {Array.clone(U32, ANode{left, right}) == (ANode{left, right}, ANode{left, right}) : Array<U32> & Array<U32>}

law array_clone_exact:
  for a: Array<U32>
  {Array.clone(U32, a) == (a, a) : Array<U32> & Array<U32>}

law adaptive_guess_saves_activated_board:
  for +pos: U32
  for +digit: U32
  for +remaining: U32
  for frames: Array<U32>
  for +depth: U32
  for +found: U32
  for snapshots: List<&1, Array<U32>>
  for +active: Bool
  for board: Array<U32>
  {Fast.place(True{}, pos, digit, remaining, frames, depth, found, snapshots, active, board) ==
   Fast.guessed(pos, digit, remaining, frames, depth, found, snapshots, active,
     (Fast.activated(active, board), Fast.activated(active, board))) : Fast.State}

# A path certificate transports all three equations through ancestors: the
# exact write, and an unchanged observation of the other leaf in either tree.
def SeparateRead(-tree: Array<U32>, -n: U32, -i: U32, -j: U32, -value: U32, -write_left: Bool, -read_left: Bool) -> Type:
  Sigma<&1, &1, Array<U32>, next =>
  Sigma<&1, &1, U32, old =>
  Sigma<&1, &1, U32, seen =>
  ({Array.swap.go(U32, tree, n, i, value, write_left) == (next, old) : Array<U32> & U32}
   & {Array.get.go(U32, tree, n, j, read_left) == (tree, seen) : Array<U32> & U32}
   & {Array.get.go(U32, next, n, j, read_left) == (next, seen) : Array<U32> & U32})>>>

law separate_descend_left:
  for -child: Array<U32>
  for other: Array<U32>
  for +n: U32
  for +i: U32
  for +j: U32
  for +value: U32
  for descent: SeparateRead(child, U32.shr(n), i, j, value, U32.is_lt(i, U32.shr(U32.shr(n))), U32.is_lt(j, U32.shr(U32.shr(n))))
  SeparateRead(ANode{child, other}, n, i, j, value, True{}, True{})

law separate_at_left_shape:
  for -child: Array<U32>
  for other: Array<U32>
  for +n: U32
  for +i: U32
  for +j: U32
  for +value: U32
  for +seen: U32
  for written: ArrayWriteWitness(child, U32.shr(n), i, value, U32.is_lt(i, U32.shr(U32.shr(n))))
  for read: {Array.get.go(U32, other, U32.shr(n), U32.sub(j, U32.shr(n)), U32.is_lt(U32.sub(j, U32.shr(n)), U32.shr(U32.shr(n)))) == (other, seen) : Array<U32> & U32}
  SeparateRead(ANode{child, other}, n, i, j, value, True{}, False{})

law separate_at_left:
  for -child: Array<U32>
  for -other: Array<U32>
  for +n: U32
  for +i: U32
  for +j: U32
  for +value: U32
  for written: ArrayWriteWitness(child, U32.shr(n), i, value, U32.is_lt(i, U32.shr(U32.shr(n))))
  for observed: ArrayReadWitness(other, U32.shr(n), U32.sub(j, U32.shr(n)), U32.is_lt(U32.sub(j, U32.shr(n)), U32.shr(U32.shr(n))))
  SeparateRead(ANode{child, other}, n, i, j, value, True{}, False{})

law separate_observations_left:
  for -child: Array<U32>
  for -next: Array<U32>
  for -other: Array<U32>
  for +half: U32
  for +j: U32
  for +z: Bool
  for +seen: U32
  for read: {Array.get.go(U32, other, half, j, z) == (other, seen) : Array<U32> & U32}
  ({Array.swap.hi(U32, child, Array.get.go(U32, other, half, j, z)) == (ANode{child, other}, seen) : Array<U32> & U32} & {Array.swap.hi(U32, next, Array.get.go(U32, other, half, j, z)) == (ANode{next, other}, seen) : Array<U32> & U32})

law separate_descend_right:
  for -child: Array<U32>
  for other: Array<U32>
  for +n: U32
  for +i: U32
  for +j: U32
  for +value: U32
  for descent: SeparateRead(child, U32.shr(n), U32.sub(i, U32.shr(n)), U32.sub(j, U32.shr(n)), value, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n))), U32.is_lt(U32.sub(j, U32.shr(n)), U32.shr(U32.shr(n))))
  SeparateRead(ANode{other, child}, n, i, j, value, False{}, False{})

law separate_at_right_shape:
  for -child: Array<U32>
  for other: Array<U32>
  for +n: U32
  for +i: U32
  for +j: U32
  for +value: U32
  for +seen: U32
  for written: ArrayWriteWitness(child, U32.shr(n), U32.sub(i, U32.shr(n)), value, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n))))
  for read: {Array.get.go(U32, other, U32.shr(n), j, U32.is_lt(j, U32.shr(U32.shr(n)))) == (other, seen) : Array<U32> & U32}
  SeparateRead(ANode{other, child}, n, i, j, value, False{}, True{})

law separate_at_right:
  for -child: Array<U32>
  for -other: Array<U32>
  for +n: U32
  for +i: U32
  for +j: U32
  for +value: U32
  for written: ArrayWriteWitness(child, U32.shr(n), U32.sub(i, U32.shr(n)), value, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n))))
  for observed: ArrayReadWitness(other, U32.shr(n), j, U32.is_lt(j, U32.shr(U32.shr(n))))
  SeparateRead(ANode{other, child}, n, i, j, value, False{}, True{})

law separate_observations_right:
  for -child: Array<U32>
  for -next: Array<U32>
  for -other: Array<U32>
  for +half: U32
  for +j: U32
  for +z: Bool
  for +seen: U32
  for read: {Array.get.go(U32, other, half, j, z) == (other, seen) : Array<U32> & U32}
  ({Array.swap.lo(U32, child, Array.get.go(U32, other, half, j, z)) == (ANode{other, child}, seen) : Array<U32> & U32} & {Array.swap.lo(U32, next, Array.get.go(U32, other, half, j, z)) == (ANode{other, next}, seen) : Array<U32> & U32})

law separate_read_projection:
  for -tree: Array<U32>
  for +n: U32
  for +i: U32
  for +j: U32
  for +value: U32
  for +wz: Bool
  for +rz: Bool
  for proof: SeparateRead(tree, n, i, j, value, wz, rz)
  {Pair.snd(Array<U32>, U32, Array.get.go(U32, Array.set.fin(U32, Array.swap.go(U32, tree, n, i, value, wz)), n, j, rz)) ==
   Pair.snd(Array<U32>, U32, Array.get.go(U32, tree, n, j, rz)) : U32}

# Computes just the two routes, ignoring leaf values. Distinct raw indices
# alone are insufficient because the public Array API masks/wraps them.
def routes_separate(tree: Array<U32>, +n: U32, +i: U32, +j: U32, +wz: Bool, +rz: Bool) -> Bool:
  match tree wz rz:
    case ALeaf{x} _ _:
      False{}
    case ANode{left, right} True{} False{}:
      True{}
    case ANode{left, right} False{} True{}:
      True{}
    case ANode{left, right} True{} True{}:
      +half = U32.shr(n)
      routes_separate(left, half, i, j, U32.is_lt(i, U32.shr(half)), U32.is_lt(j, U32.shr(half)))
    case ANode{left, right} False{} False{}:
      +half = U32.shr(n)
      +wi = U32.sub(i, half)
      +ri = U32.sub(j, half)
      routes_separate(right, half, wi, ri, U32.is_lt(wi, U32.shr(half)), U32.is_lt(ri, U32.shr(half)))

def TrueOnly(tag: Bool) -> Type:
  match tag:
    case True{}:
      Unit
    case False{}:
      Empty

law false_is_not_true:
  for e: {False{} == True{} : Bool}
  Empty

law array_swap_preserves_separate_read:
  for tree: Array<U32>
  for +n: U32
  for +i: U32
  for +j: U32
  for +value: U32
  for +wz: Bool
  for +rz: Bool
  for distinct: {routes_separate(tree, n, i, j, wz, rz) == True{} : Bool}
  SeparateRead(tree, n, i, j, value, wz, rz)

def SameCapacity(-a: Array<U32>, -i: U32, -v: U32) -> Type:
  {Pair.snd(Array<U32>, U32, Array.size(U32, B.set_cell(a, i, v))) ==
   Pair.snd(Array<U32>, U32, Array.size(U32, a)) : U32}

law capacity_aligned:
  for -a: Array<U32>
  for +n: U32
  for +i: U32
  for +v: U32
  for -next: Array<U32>
  for -old: U32
  for +cap: U32
  for write: {Array.swap.at(U32, i, v, (a, n)) == (next, old) : Array<U32> & U32}
  for after: {Array.size(U32, next) == (next, cap) : Array<U32> & U32}
  for eq: {(a, cap) == (a, n) : Array<U32> & U32}
  {Pair.snd(Array<U32>, U32, Array.size(U32, Array.set.fin(U32, Array.swap.at(U32, i, v, (a, n))))) == n : U32}

law capacity_from_write_witness:
  for -a: Array<U32>
  for +n: U32
  for +i: U32
  for +v: U32
  for size: {Array.size(U32, a) == (a, n) : Array<U32> & U32}
  for w: ArrayWriteWitness(a, n, U32.and(i, U32.sub(n, 1)), v, U32.is_lt(U32.and(i, U32.sub(n, 1)), U32.shr(n)))
  SameCapacity(a, i, v)

law capacity_from_size_witness:
  for -a: Array<U32>
  for +i: U32
  for +v: U32
  for size: ArraySizeWitness(a)
  SameCapacity(a, i, v)

law board_set_keeps_capacity:
  for a: Array<U32>
  for +i: U32
  for +v: U32
  SameCapacity(a, i, v)

# Bridge the routing certificate to the production wrappers, with a common
# measured size so get/set normalize the addresses using the same modulus.
law board_isolation_aligned:
  for -a: Array<U32>
  for +n: U32
  for +p: U32
  for +q: U32
  for +v: U32
  for before: {Array.size(U32, a) == (a, n) : Array<U32> & U32}
  for after: {Array.size(U32, B.set_cell(a, p, v)) == (B.set_cell(a, p, v), n) : Array<U32> & U32}
  for observed: {Pair.snd(Array<U32>, U32, Array.get.go(U32, Array.set.fin(U32, Array.swap.go(U32, a, n, U32.and(p, U32.sub(n, 1)), v, U32.is_lt(U32.and(p, U32.sub(n, 1)), U32.shr(n)))), n, U32.and(q, U32.sub(n, 1)), U32.is_lt(U32.and(q, U32.sub(n, 1)), U32.shr(n)))) == Pair.snd(Array<U32>, U32, Array.get.go(U32, a, n, U32.and(q, U32.sub(n, 1)), U32.is_lt(U32.and(q, U32.sub(n, 1)), U32.shr(n)))) : U32}
  {Pair.snd(Array<U32>, U32, B.get_cell(B.set_cell(a, p, v), q)) == Pair.snd(Array<U32>, U32, B.get_cell(a, q)) : U32}

law board_write_preserves_separate_read:
  for a: Array<U32>
  for +n: U32
  for +p: U32
  for +q: U32
  for +v: U32
  for before: {Array.size(U32, a) == (a, n) : Array<U32> & U32}
  for after: {Array.size(U32, B.set_cell(a, p, v)) == (B.set_cell(a, p, v), n) : Array<U32> & U32}
  for disjoint: {routes_separate(a, n, U32.and(p, U32.sub(n, 1)), U32.and(q, U32.sub(n, 1)), U32.is_lt(U32.and(p, U32.sub(n, 1)), U32.shr(n)), U32.is_lt(U32.and(q, U32.sub(n, 1)), U32.shr(n))) == True{} : Bool}
  {Pair.snd(Array<U32>, U32, B.get_cell(B.set_cell(a, p, v), q)) == Pair.snd(Array<U32>, U32, B.get_cell(a, q)) : U32}

# Alias counterexample: even on the production 128-slot tree, an out-of-range
# raw index is not another cell. The public access normalizes it.
law raw_128_aliases_zero:
  for +value: U32
  {Pair.snd(Array<U32>, U32, B.get_cell(B.set_cell(B.empty(), 0, value), 128)) == value : U32}

def flag_slot(+pos: U32) -> U32:
  (109 + U32.shrn(pos, 5n) : U32)

def flag_word(+pos: U32, +present: Bool, +old: U32) -> U32:
  +bit = U32.shln(1, U32.to_nat(U32.and(pos, 31)))
  Bool.pick(U32, present, U32.or(old, bit), U32.and(old, U32.not(bit)))

def flag_slots(+n: Nat, +pos: U32) -> List<&2, U32>:
  match n:
    case 0n:
      Nil{}
    case 1n+k:
      flag_slot(pos) <> flag_slots(k, (pos + 1 : U32))

law queued_flag_slot_is_padding:
  {flag_slots(81n, 0) ==
   List.append(&2, U32, List.replicate(U32, 32n, 109),
     List.append(&2, U32, List.replicate(U32, 32n, 110), List.replicate(U32, 17n, 111))) : List<&2, U32>}

law queued_flagged_keeps_separate_cell:
  for a: Array<U32>
  for +pos: U32
  for +read_pos: U32
  for +present: Bool
  for +old: U32
  for +n: U32
  for before: {Array.size(U32, a) == (a, n) : Array<U32> & U32}
  for after: {Array.size(U32, Q.flagged(pos, present, (a, old))) == (Q.flagged(pos, present, (a, old)), n) : Array<U32> & U32}
  for separate: {routes_separate(a, n, U32.and(flag_slot(pos), U32.sub(n, 1)), U32.and(read_pos, U32.sub(n, 1)),
    U32.is_lt(U32.and(flag_slot(pos), U32.sub(n, 1)), U32.shr(n)), U32.is_lt(U32.and(read_pos, U32.sub(n, 1)), U32.shr(n))) == True{} : Bool}
  {Pair.snd(Array<U32>, U32, B.get_cell(Q.flagged(pos, present, (a, old)), read_pos)) ==
   Pair.snd(Array<U32>, U32, B.get_cell(a, read_pos)) : U32}

law candidate_at_decodes_blank:
  for board: Array<U32>
  for +pos: U32
  {U32.shrn(Pair.snd(Array<U32>, U32, C.at(board, pos)), 10n) == 0 : U32}

law cached_at_decodes_blank:
  for board: Array<U32>
  for +pos: U32
  {U32.shrn(Pair.snd(Array<U32>, U32, C.cached_at(board, pos)), 10n) == 0 : U32}

# Size follows the left spine. This is not a regular 128-slot board;
# positions 80 and 109 both fall through to its lone right leaf.
def irregular_board() -> Array<U32>:
  ANode{[0 : U32*64n], ALeaf{0}}

law irregular_board_size:
  {Pair.snd(Array<U32>, U32, Array.size(U32, irregular_board())) == 128 : U32}

law irregular_board_alias:
  for +value: U32
  {Pair.snd(Array<U32>, U32, B.get_cell(B.set_cell(irregular_board(), 109, value), 80)) == value : U32}

law irregular_board_does_not_separate:
  {routes_separate(irregular_board(), 128, 109, 80, False{}, False{}) == False{} : Bool}

type ArrayShape is Data:
  ShapeLeaf{}
  ShapeNode{left: ArrayShape, right: ArrayShape}

def array_shape(a: Array<U32>) -> ArrayShape:
  match a:
    case ALeaf{v}:
      ShapeLeaf{}
    case ANode{x,y}:
      ShapeNode{array_shape(x), array_shape(y)}

def ShapeWrite(-a: Array<U32>, -n: U32, -i: U32, -v: U32, -z: Bool) -> Type:
  Sigma<&1, &1, Array<U32>, next =>
  Sigma<&1, &1, U32, old =>
    ({Array.swap.go(U32, a, n, i, v, z) == (next, old) : Array<U32> & U32}
     & {array_shape(next) == array_shape(a) : ArrayShape})>>

law shape_write_left:
  for -x: Array<U32>
  for y: Array<U32>
  for +n: U32
  for +i: U32
  for +v: U32
  for w: ShapeWrite(x, U32.shr(n), i, v, U32.is_lt(i, U32.shr(U32.shr(n))))
  ShapeWrite(ANode{x,y}, n, i, v, True{})

law shape_write_right:
  for x: Array<U32>
  for -y: Array<U32>
  for +n: U32
  for +i: U32
  for +v: U32
  for w: ShapeWrite(y, U32.shr(n), U32.sub(i, U32.shr(n)), v, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n))))
  ShapeWrite(ANode{x,y}, n, i, v, False{})

law shape_write_witness:
  for a: Array<U32>
  for +n: U32
  for +i: U32
  for +v: U32
  for +z: Bool
  ShapeWrite(a,n,i,v,z)

def SameShape(-a: Array<U32>, -i: U32, -v: U32) -> Type:
  {array_shape(B.set_cell(a,i,v)) == array_shape(a) : ArrayShape}

law shape_aligned:
  for -a: Array<U32>
  for +n: U32
  for +i: U32
  for +v: U32
  for w: ShapeWrite(a,n,U32.and(i,U32.sub(n,1)),v,U32.is_lt(U32.and(i,U32.sub(n,1)),U32.shr(n)))
  {array_shape(Array.set.fin(U32, Array.swap.at(U32,i,v,(a,n)))) == array_shape(a) : ArrayShape}

law shape_from_size:
  for -a: Array<U32>
  for +i: U32
  for +v: U32
  for s: ArraySizeWitness(a)
  SameShape(a,i,v)

law board_set_keeps_shape:
  for a: Array<U32>
  for +i: U32
  for +v: U32
  SameShape(a,i,v)

def perfect_shape(+height: Nat) -> ArrayShape:
  match height:
    case 0n:
      ShapeLeaf{}
    case 1n+h:
      ShapeNode{perfect_shape(h), perfect_shape(h)}

law empty_board_depth_seven:
  {array_shape(B.empty()) == perfect_shape(7n) : ArrayShape}

law board_set_keeps_perfect:
  for a: Array<U32>
  for +i: U32
  for +v: U32
  for +height: Nat
  for perfect: {array_shape(a) == perfect_shape(height) : ArrayShape}
  {array_shape(B.set_cell(a,i,v)) == perfect_shape(height) : ArrayShape}

# Compare routes without depending on cell contents. Equality with this
# observer makes a separation certificate reusable after a shape-preserving write.
def shape_routes(shape: ArrayShape, +n: U32, +i: U32, +j: U32, +wz: Bool, +rz: Bool) -> Bool:
  match shape wz rz:
    case ShapeLeaf{} _ _:
      False{}
    case ShapeNode{left,right} True{} False{}:
      True{}
    case ShapeNode{left,right} False{} True{}:
      True{}
    case ShapeNode{left,right} True{} True{}:
      +half = U32.shr(n)
      shape_routes(left,half,i,j,U32.is_lt(i,U32.shr(half)),U32.is_lt(j,U32.shr(half)))
    case ShapeNode{left,right} False{} False{}:
      +half = U32.shr(n)
      +wi = U32.sub(i,half)
      +ri = U32.sub(j,half)
      shape_routes(right,half,wi,ri,U32.is_lt(wi,U32.shr(half)),U32.is_lt(ri,U32.shr(half)))

law routes_depend_on_shape:
  for tree: Array<U32>
  for +n: U32
  for +i: U32
  for +j: U32
  for +wz: Bool
  for +rz: Bool
  {routes_separate(tree,n,i,j,wz,rz) == shape_routes(array_shape(tree),n,i,j,wz,rz) : Bool}

# Normalized 128-slot production addresses. Prove all logical/flag pairs as
# one bounded family; no assumption about metadata or the values in the tree.
def regular_routes(+i: U32, +j: U32) -> Bool:
  shape_routes(perfect_shape(7n),128,i,j,(i < 64 : U32),(j < 64 : U32))

def logical_vs_metadata(+count: Nat, +q: U32) -> Bool:
  match count:
    case 0n:
      True{}
    case 1n+k:
      regular_routes(108,q) && regular_routes(109,q) && regular_routes(110,q) && regular_routes(111,q)
        && regular_routes(q,108) && regular_routes(q,109) && regular_routes(q,110) && regular_routes(q,111)
        && logical_vs_metadata(k,(q + 1 : U32))

law routes_from_perfect_shape:
  for tree: Array<U32>
  for +n: U32
  for +i: U32
  for +j: U32
  for +wz: Bool
  for +rz: Bool
  for +height: Nat
  for perfect: {array_shape(tree) == perfect_shape(height) : ArrayShape}
  {routes_separate(tree,n,i,j,wz,rz) == shape_routes(perfect_shape(height),n,i,j,wz,rz) : Bool}

law logical_metadata_routes_00:
  {logical_vs_metadata(9n,0) == True{} : Bool}

law logical_metadata_routes_09:
  {logical_vs_metadata(9n,9) == True{} : Bool}

law logical_metadata_routes_18:
  {logical_vs_metadata(9n,18) == True{} : Bool}

law logical_metadata_routes_27:
  {logical_vs_metadata(9n,27) == True{} : Bool}

law logical_metadata_routes_36:
  {logical_vs_metadata(9n,36) == True{} : Bool}

law logical_metadata_routes_45:
  {logical_vs_metadata(9n,45) == True{} : Bool}

law logical_metadata_routes_54:
  {logical_vs_metadata(9n,54) == True{} : Bool}

law logical_metadata_routes_63:
  {logical_vs_metadata(9n,63) == True{} : Bool}

law logical_metadata_routes_72:
  {logical_vs_metadata(9n,72) == True{} : Bool}

# Finite complete table for the logical 81×81 domain, independently expected
# to be true exactly when the two logical coordinates differ.
def logical_row(+count: Nat, +i: U32, +j: U32) -> Bool:
  match count:
    case 0n:
      True{}
    case 1n+k:
      Bool.pick(Bool, U32.is_eq(i,j), Bool.not(regular_routes(i,j)), regular_routes(i,j))
        && logical_row(k,i,(j + 1 : U32))

def logical_rows(+count: Nat, +i: U32) -> Bool:
  match count:
    case 0n:
      True{}
    case 1n+k:
      logical_row(81n,i,0) && logical_rows(k,(i + 1 : U32))

law logical_routes_00:
  {logical_rows(9n,0) == True{} : Bool}

law logical_routes_09:
  {logical_rows(9n,9) == True{} : Bool}

law logical_routes_18:
  {logical_rows(9n,18) == True{} : Bool}

law logical_routes_27:
  {logical_rows(9n,27) == True{} : Bool}

law logical_routes_36:
  {logical_rows(9n,36) == True{} : Bool}

law logical_routes_45:
  {logical_rows(9n,45) == True{} : Bool}

law logical_routes_54:
  {logical_rows(9n,54) == True{} : Bool}

law logical_routes_63:
  {logical_rows(9n,63) == True{} : Bool}

law logical_routes_72:
  {logical_rows(9n,72) == True{} : Bool}

def shape_capacity(shape: ArrayShape) -> U32:
  match shape:
    case ShapeLeaf{}:
      1
    case ShapeNode{left,right}:
      U32.shl(shape_capacity(left))

law shape_measure_lift:
  for -x: Array<U32>
  for -y: Array<U32>
  for measured: {Array.size(U32,x) == (x,shape_capacity(array_shape(x))) : Array<U32> & U32}
  {Array.size(U32,ANode{x,y}) == (ANode{x,y},shape_capacity(array_shape(ANode{x,y}))) : Array<U32> & U32}

law array_size_follows_shape:
  for a: Array<U32>
  {Array.size(U32,a) == (a,shape_capacity(array_shape(a))) : Array<U32> & U32}

law perfect_board_has_128_slots:
  for a: Array<U32>
  for perfect: {array_shape(a) == perfect_shape(7n) : ArrayShape}
  {Array.size(U32,a) == (a,128) : Array<U32> & U32}

def PublicShapeWrite(-a: Array<U32>, -i: U32, -v: U32) -> Type:
  Sigma<&1,&1,Array<U32>,next =>
    ({B.set_cell(a,i,v) == next : Array<U32>}
     & {array_shape(next) == array_shape(a) : ArrayShape})>

law set_shape_write_aligned:
  for -a: Array<U32>
  for +n: U32
  for +i: U32
  for +v: U32
  for actual: {Array.size(U32,a) == (a,n) : Array<U32> & U32}
  for witness: ShapeWrite(a,n,U32.and(i,U32.sub(n,1)),v,U32.is_lt(U32.and(i,U32.sub(n,1)),U32.shr(n)))
  PublicShapeWrite(a,i,v)

law set_shape_write_sized:
  for -a: Array<U32>
  for +i: U32
  for +v: U32
  for s: ArraySizeWitness(a)
  PublicShapeWrite(a,i,v)

law set_shape_write:
  for a: Array<U32>
  for +i: U32
  for +v: U32
  PublicShapeWrite(a,i,v)

law decode_shape_join:
  for +n: Nat
  for +pos: U32
  for -board: Array<U32>
  for -read_board: Array<U32>
  for +word: U32
  for -next: Array<U32>
  for unchanged: {read_board == board : Array<U32>}
  for rd: {Array.get(U32,board,pos) == (read_board,word) : Array<U32> & U32}
  for write: {B.set_cell(read_board,pos,U32.shrn(word,10n)) == next : Array<U32>}
  for next_shape: {array_shape(next) == array_shape(read_board) : ArrayShape}
  for later: {array_shape(Q.decode(n,(pos + 1 : U32),next)) == array_shape(next) : ArrayShape}
  {array_shape(Q.decode(1n+n,pos,board)) == array_shape(board) : ArrayShape}

law decode_shape_written:
  for +n: Nat
  for +pos: U32
  for -board: Array<U32>
  for -read_board: Array<U32>
  for +word: U32
  for unchanged: {read_board == board : Array<U32>}
  for read: {Array.get(U32,board,pos) == (read_board,word) : Array<U32> & U32}
  for w: PublicShapeWrite(read_board,pos,U32.shrn(word,10n))
  for prove: @sub:Array<U32> -> {array_shape(Q.decode(n,(pos + 1 : U32),sub)) == array_shape(sub) : ArrayShape}
  {array_shape(Q.decode(1n+n,pos,board)) == array_shape(board) : ArrayShape}

law decode_shape_read:
  for +n: Nat
  for +pos: U32
  for -board: Array<U32>
  for rd: BoardReadWitness(board,pos)
  for prove: @sub:Array<U32> -> {array_shape(Q.decode(n,(pos + 1 : U32),sub)) == array_shape(sub) : ArrayShape}
  {array_shape(Q.decode(1n+n,pos,board)) == array_shape(board) : ArrayShape}

law queued_decode_preserves_shape:
  for +n: Nat
  for +pos: U32
  for board: Array<U32>
  {array_shape(Q.decode(n,pos,board)) == array_shape(board) : ArrayShape}

# Value transformations preserve the board owning the read.
def SameBoardRead(-board: Array<U32>, -expr: Array<U32> & U32) -> Type:
  Sigma<&1,&1,Array<U32>,same =>
  Sigma<&1,&1,U32,value =>
    ({same == board : Array<U32>} & {expr == (same,value) : Array<U32> & U32})>>

law cached_merge_observed:
  for -board: Array<U32>
  for -expr: Array<U32> & U32
  for +used: U32
  for r: SameBoardRead(board,expr)
  SameBoardRead(board,C.cached_merge(used,expr))

law cached_add_observed_step:
  for -board: Array<U32>
  for -expr: Array<U32> & U32
  for -read_board: Array<U32>
  for +pos: U32
  for +used: U32
  for out: {expr == (read_board,used) : Array<U32> & U32}
  for kept: {read_board == board : Array<U32>}
  for r: SameBoardRead(read_board,C.cached_merge(used,Array.get(U32,read_board,pos)))
  SameBoardRead(board,C.cached_add(pos,expr))

law cached_add_observed:
  for -board: Array<U32>
  for -expr: Array<U32> & U32
  for +pos: U32
  for r: SameBoardRead(board,expr)
  SameBoardRead(board,C.cached_add(pos,expr))

law invert_observed:
  for -board: Array<U32>
  for -expr: Array<U32> & U32
  for r: SameBoardRead(board,expr)
  SameBoardRead(board,C.invert(expr))

law cached_at_observed:
  for board: Array<U32>
  for +pos: U32
  SameBoardRead(board,C.cached_at(board,pos))

# A transition retains the concrete output tree and its unchanged shape so
# the next induction step can use the single affine owner of that tree.
def ShapeTransition(-board: Array<U32>, -expr: Array<U32>) -> Type:
  Sigma<&1,&1,Array<U32>,next =>
    ({expr == next : Array<U32>} & {array_shape(next) == array_shape(board) : ArrayShape})>

law shape_transition_compose_finish:
  for -a: Array<U32>
  for -b: Array<U32>
  for -x: Array<U32>
  for -f: @b:Array<U32> -> Array<U32>
  for ex: {x == b : Array<U32>}
  for es: {array_shape(b) == array_shape(a) : ArrayShape}
  for step: ShapeTransition(b,f(b))
  ShapeTransition(a,f(x))

law shape_transition_compose:
  for -a: Array<U32>
  for -x: Array<U32>
  for -f: @b:Array<U32> -> Array<U32>
  for first: ShapeTransition(a,x)
  for next: @b:Array<U32> -> ShapeTransition(b,f(b))
  ShapeTransition(a,f(x))

law flag_from_observed:
  for -board: Array<U32>
  for +pos: U32
  for +present: Bool
  for -same: Array<U32>
  for +old: U32
  for unchanged: {same == board : Array<U32>}
  for read: {B.get_cell(board,flag_slot(pos)) == (same,old) : Array<U32> & U32}
  for step: ShapeTransition(same,Q.flagged(pos,present,(same,old)))
  ShapeTransition(board,Q.flag(board,pos,present))

law flag_shape_read:
  for -board: Array<U32>
  for +pos: U32
  for +present: Bool
  for read: BoardReadWitness(board,flag_slot(pos))
  ShapeTransition(board,Q.flag(board,pos,present))

law flag_shape:
  for board: Array<U32>
  for +pos: U32
  for +present: Bool
  ShapeTransition(board,Q.flag(board,pos,present))

law encoded_mask_shape:
  for +pos: U32
  for cells: Array<U32> & U32
  ShapeTransition(Pair.fst(Array<U32>,U32,cells),Q.encoded_mask(pos,cells))

law encoded_blank_shape_observed:
  for -board: Array<U32>
  for +pos: U32
  for obs: SameBoardRead(board,C.cached_at(board,pos))
  ShapeTransition(board,Q.encoded(pos,(board,0)))

law encoded_digit_shape:
  for board: Array<U32>
  for +pos: U32
  for +digit: U32
  ShapeTransition(board,Q.encoded(pos,(board,digit)))

law encoded_shape:
  for +pos: U32
  for cells: Array<U32> & U32
  ShapeTransition(Pair.fst(Array<U32>,U32,cells),Q.encoded(pos,cells))

law encode_go_shape_step:
  for +n: Nat
  for +pos: U32
  for -board: Array<U32>
  for -same: Array<U32>
  for +digit: U32
  for shape: {same == board : Array<U32>}
  for rd: {Array.get(U32,board,pos) == (same,digit) : Array<U32> & U32}
  for result: ShapeTransition(same,Q.encode_go(n,(pos + 1 : U32),Q.encoded(pos,(same,digit))))
  ShapeTransition(board,Q.encode_go(1n+n,pos,board))

law encode_go_shape_read:
  for +n: Nat
  for +pos: U32
  for -board: Array<U32>
  for obs: BoardReadWitness(board,pos)
  for recurse: @sub:Array<U32> -> ShapeTransition(sub,Q.encode_go(n,(pos + 1 : U32),sub))
  ShapeTransition(board,Q.encode_go(1n+n,pos,board))

law encode_loop_shape:
  for +n: Nat
  for +pos: U32
  for board: Array<U32>
  ShapeTransition(board,Q.encode_go(n,pos,board))

law queue_seed_shape:
  for board: Array<U32>
  ShapeTransition(board,B.set_cell(B.set_cell(B.set_cell(board,109,0),110,0),111,0))

law encoded_full_shape_witness:
  for board: Array<U32>
  ShapeTransition(board,Q.encode(board))

law project_shape_transition:
  for -board: Array<U32>
  for -result: Array<U32>
  for proof: ShapeTransition(board,result)
  {array_shape(result) == array_shape(board) : ArrayShape}

law queued_encode_preserves_shape:
  for board: Array<U32>
  {array_shape(Q.encode(board)) == array_shape(board) : ArrayShape}

def cell_value(board: Array<U32>, +pos: U32) -> U32:
  Pair.snd(Array<U32>,U32,B.get_cell(board,pos))

def Board128(-board: Array<U32>) -> Type:
  {array_shape(board) == perfect_shape(7n) : ArrayShape}

def normalized_route(+i: U32) -> U32:
  U32.and(i,127)

def RoutedApart(+written: U32, +watched: U32) -> Type:
  {regular_routes(normalized_route(written),normalized_route(watched)) == True{} : Bool}

law copy_shape_proof:
  for -a: ArrayShape
  for -b: ArrayShape
  for eq: {a == b : ArrayShape}
  ({a == b : ArrayShape} & {a == b : ArrayShape})

law copy_shape_three:
  for -a: ArrayShape
  for -b: ArrayShape
  for eq: {a == b : ArrayShape}
  ({a == b : ArrayShape} & {a == b : ArrayShape} & {a == b : ArrayShape})

# A duplicable mathematical image of a source array, with a reconstruction witness.
type BoardImage is Data:
  ImageLeaf{value: U32}
  ImageNode{left: BoardImage, right: BoardImage}

def image_board(+image: BoardImage) -> Array<U32>:
  match image:
    case ImageLeaf{value}:
      ALeaf{value}
    case ImageNode{left,right}:
      ANode{image_board(left),image_board(right)}

def ReifiedBoard(-board: Array<U32>) -> Type:
  Sigma<&2,&1,BoardImage,image => {image_board(image) == board : Array<U32>}>

law reify_board_join:
  for -left: Array<U32>
  for -right: Array<U32>
  for e0: ReifiedBoard(left)
  for e1: ReifiedBoard(right)
  ReifiedBoard(ANode{left,right})

law reify_board:
  for board: Array<U32>
  ReifiedBoard(board)

law on_reified_board:
  for -board: Array<U32>
  for -P: Array<U32> -> Type
  for witness: ReifiedBoard(board)
  for prove: @image:BoardImage -> P(image_board(image))
  P(board)

law perfect_write_keeps_cell_from:
  for +image: BoardImage
  for +written: U32
  for +watched: U32
  for +value: U32
  for shapes: (Board128(image_board(image)) & Board128(image_board(image)) & Board128(image_board(image)))
  for apart: RoutedApart(written,watched)
  {cell_value(B.set_cell(image_board(image),written,value),watched) == cell_value(image_board(image),watched) : U32}

law perfect_write_keeps_cell:
  for board: Array<U32>
  for +written: U32
  for +watched: U32
  for +value: U32
  for shape: Board128(board)
  for apart: RoutedApart(written,watched)
  {cell_value(B.set_cell(board,written,value),watched) == cell_value(board,watched) : U32}

law observed_word:
  for -board: Array<U32>
  for +pos: U32
  for -same: Array<U32>
  for -word: U32
  for observed: {Array.get(U32,board,pos) == (same,word) : Array<U32> & U32}
  {cell_value(board,pos) == word : U32}

law decode_step_update:
  for -board: Array<U32>
  for +pos: U32
  for -same: Array<U32>
  for +word: U32
  for untouched: {same == board : Array<U32>}
  for observed: {Array.get(U32,board,pos) == (same,word) : Array<U32> & U32}
  {Q.decoded(pos,Array.get(U32,board,pos)) == B.set_cell(board,pos,U32.shrn(cell_value(board,pos),10n)) : Array<U32>}

law decode_step_normalized:
  for board: Array<U32>
  for +pos: U32
  for read: BoardReadWitness(board,pos)
  {Q.decoded(pos,Array.get(U32,board,pos)) == B.set_cell(board,pos,U32.shrn(cell_value(board,pos),10n)) : Array<U32>}

law decode_step_keeps_cell_image:
  for +image: BoardImage
  for +pos: U32
  for +watched: U32
  for shape: Board128(image_board(image))
  for apart: RoutedApart(pos,watched)
  {cell_value(Q.decoded(pos,Array.get(U32,image_board(image),pos)),watched) == cell_value(image_board(image),watched) : U32}

law decode_step_keeps_cell:
  for board: Array<U32>
  for +pos: U32
  for +watched: U32
  for shape: Board128(board)
  for apart: RoutedApart(pos,watched)
  {cell_value(Q.decoded(pos,Array.get(U32,board,pos)),watched) == cell_value(board,watched) : U32}

law decode_step_reads_cell_image:
  for +image: BoardImage
  for +pos: U32
  {cell_value(Q.decoded(pos,Array.get(U32,image_board(image),pos)),pos) == U32.shrn(cell_value(image_board(image),pos),10n) : U32}

law decode_step_reads_cell:
  for board: Array<U32>
  for +pos: U32
  {cell_value(Q.decoded(pos,Array.get(U32,board,pos)),pos) == U32.shrn(cell_value(board,pos),10n) : U32}

law decode_step_keeps_perfect_image:
  for +image: BoardImage
  for +pos: U32
  for shape: Board128(image_board(image))
  Board128(Q.decoded(pos,Array.get(U32,image_board(image),pos)))

law decode_step_keeps_perfect:
  for board: Array<U32>
  for +pos: U32
  for shape: Board128(board)
  Board128(Q.decoded(pos,Array.get(U32,board,pos)))

def DecodeApart(+n: Nat, +pos: U32, +watched: U32) -> Type:
  match n:
    case 0n:
      {True{} == True{} : Bool}
    case 1n+k:
      RoutedApart(pos,watched) & DecodeApart(k,(pos + 1 : U32),watched)

def DecodeTailProof(+n: Nat, +pos: U32, +watched: U32) -> Type:
  @sub:Array<U32> -> Board128(sub) -> DecodeApart(n,pos,watched) ->
  {cell_value(Q.decode(n,pos,sub),watched) == cell_value(sub,watched) : U32}

law decode_sweep_keep_step_image:
  for +n: Nat
  for +pos: U32
  for +image: BoardImage
  for +watched: U32
  for shapes: (Board128(image_board(image)) & Board128(image_board(image)))
  for apart: RoutedApart(pos,watched)
  for rest: DecodeApart(n,(pos + 1 : U32),watched)
  for recurse: DecodeTailProof(n,(pos + 1 : U32),watched)
  {cell_value(Q.decode(1n+n,pos,image_board(image)),watched) == cell_value(image_board(image),watched) : U32}

law decode_sweep_keep_step:
  for +n: Nat
  for +pos: U32
  for board: Array<U32>
  for +watched: U32
  for shapes: (Board128(board) & Board128(board))
  for apart: RoutedApart(pos,watched)
  for rest: DecodeApart(n,(pos + 1 : U32),watched)
  for recurse: DecodeTailProof(n,(pos + 1 : U32),watched)
  {cell_value(Q.decode(1n+n,pos,board),watched) == cell_value(board,watched) : U32}

law decode_sweep_keeps_apart:
  for +n: Nat
  for +pos: U32
  for board: Array<U32>
  for +watched: U32
  for shape: Board128(board)
  for apart: DecodeApart(n,pos,watched)
  {cell_value(Q.decode(n,pos,board),watched) == cell_value(board,watched) : U32}

law decode_head_value_image:
  for +n: Nat
  for +pos: U32
  for +image: BoardImage
  for shape: Board128(image_board(image))
  for apart: DecodeApart(n,(pos + 1 : U32),pos)
  {cell_value(Q.decode(1n+n,pos,image_board(image)),pos) == U32.shrn(cell_value(image_board(image),pos),10n) : U32}

law decode_head_value:
  for +n: Nat
  for +pos: U32
  for board: Array<U32>
  for shape: Board128(board)
  for apart: DecodeApart(n,(pos + 1 : U32),pos)
  {cell_value(Q.decode(1n+n,pos,board),pos) == U32.shrn(cell_value(board,pos),10n) : U32}

def walk_position(+prefix: Nat, +start: U32) -> U32:
  match prefix:
    case 0n:
      start
    case 1n+k:
      walk_position(k,(start + 1 : U32))

def with_center(+prefix: Nat, +suffix: Nat) -> Nat:
  match prefix:
    case 0n:
      1n+suffix
    case 1n+k:
      1n+with_center(k,suffix)

def DecodeMiddleProof(+prefix: Nat, +suffix: Nat, +start: U32) -> Type:
  @sub:Array<U32> -> Board128(sub) ->
  DecodeApart(prefix,start,walk_position(prefix,start)) ->
  DecodeApart(suffix,(walk_position(prefix,start) + 1 : U32),walk_position(prefix,start)) ->
  {cell_value(Q.decode(with_center(prefix,suffix),start,sub),walk_position(prefix,start))
    == U32.shrn(cell_value(sub,walk_position(prefix,start)),10n) : U32}

law decode_middle_value_step_image:
  for +prefix: Nat
  for +suffix: Nat
  for +start: U32
  for +image: BoardImage
  for shapes: (Board128(image_board(image)) & Board128(image_board(image)))
  for prior: DecodeApart(1n+prefix,start,walk_position(1n+prefix,start))
  for later: DecodeApart(suffix,(walk_position(1n+prefix,start) + 1 : U32),walk_position(1n+prefix,start))
  for recurse: DecodeMiddleProof(prefix,suffix,(start + 1 : U32))
  {cell_value(Q.decode(with_center(1n+prefix,suffix),start,image_board(image)),walk_position(1n+prefix,start))
    == U32.shrn(cell_value(image_board(image),walk_position(1n+prefix,start)),10n) : U32}

law decode_middle_value_step:
  for +prefix: Nat
  for +suffix: Nat
  for +start: U32
  for board: Array<U32>
  for shapes: (Board128(board) & Board128(board))
  for prior: DecodeApart(1n+prefix,start,walk_position(1n+prefix,start))
  for later: DecodeApart(suffix,(walk_position(1n+prefix,start) + 1 : U32),walk_position(1n+prefix,start))
  for recurse: DecodeMiddleProof(prefix,suffix,(start + 1 : U32))
  {cell_value(Q.decode(with_center(1n+prefix,suffix),start,board),walk_position(1n+prefix,start))
    == U32.shrn(cell_value(board,walk_position(1n+prefix,start)),10n) : U32}

law decode_middle_value:
  for +prefix: Nat
  for +suffix: Nat
  for +start: U32
  for board: Array<U32>
  for shape: Board128(board)
  for prior: DecodeApart(prefix,start,walk_position(prefix,start))
  for later: DecodeApart(suffix,(walk_position(prefix,start) + 1 : U32),walk_position(prefix,start))
  {cell_value(Q.decode(with_center(prefix,suffix),start,board),walk_position(prefix,start))
    == U32.shrn(cell_value(board,walk_position(prefix,start)),10n) : U32}

law flag_normalized_read:
  for -b: Array<U32>
  for +p: U32
  for +on: Bool
  for -same: Array<U32>
  for +old: U32
  for untouched: {same == b : Array<U32>}
  for observed: {B.get_cell(b,flag_slot(p)) == (same,old) : Array<U32> & U32}
  {Q.flag(b,p,on) == B.set_cell(b,flag_slot(p),flag_word(p,on,cell_value(b,flag_slot(p)))) : Array<U32>}

law flag_normalized:
  for -b: Array<U32>
  for +p: U32
  for +on: Bool
  for read: BoardReadWitness(b,flag_slot(p))
  {Q.flag(b,p,on) == B.set_cell(b,flag_slot(p),flag_word(p,on,cell_value(b,flag_slot(p)))) : Array<U32>}

def FlagKeeps(-b: Array<U32>, +p: U32, +on: Bool, +q: U32) -> Type:
  Board128(b) -> RoutedApart(flag_slot(p),q) ->
  {cell_value(Q.flag(b,p,on),q) == cell_value(b,q) : U32}

law flag_keeps_cell_image:
  for +image: BoardImage
  for +p: U32
  for +on: Bool
  for +q: U32
  FlagKeeps(image_board(image),p,on,q)

law flag_keeps_cell:
  for b: Array<U32>
  for +p: U32
  for +on: Bool
  for +q: U32
  FlagKeeps(b,p,on,q)

def MaskKeeps(-b: Array<U32>, +p: U32, +mask: U32, +q: U32) -> Type:
  Board128(b) -> RoutedApart(p,q) -> RoutedApart(flag_slot(p),q) ->
  {cell_value(Q.encoded_mask(p,(b,mask)),q) == cell_value(b,q) : U32}

law encoded_mask_keeps_step:
  for +image: BoardImage
  for +p: U32
  for +mask: U32
  for +q: U32
  for shapes: (Board128(image_board(image)) & Board128(image_board(image)))
  for distinct: RoutedApart(p,q)
  for flags: RoutedApart(flag_slot(p),q)
  {cell_value(Q.encoded_mask(p,(image_board(image),mask)),q) == cell_value(image_board(image),q) : U32}

law encoded_mask_keeps_image:
  for +image: BoardImage
  for +p: U32
  for +mask: U32
  for +q: U32
  MaskKeeps(image_board(image),p,mask,q)

law encoded_mask_keeps_cell:
  for b: Array<U32>
  for +p: U32
  for +mask: U32
  for +q: U32
  MaskKeeps(b,p,mask,q)

def MaskWrites(-b: Array<U32>, +p: U32, +mask: U32) -> Type:
  Board128(b) -> RoutedApart(flag_slot(p),p) ->
  {cell_value(Q.encoded_mask(p,(b,mask)),p) == mask : U32}

law encoded_mask_writes_image:
  for +image: BoardImage
  for +p: U32
  for +mask: U32
  MaskWrites(image_board(image),p,mask)

law encoded_mask_writes_cell:
  for b: Array<U32>
  for +p: U32
  for +mask: U32
  MaskWrites(b,p,mask)

def cached_word(b: Array<U32>, +p: U32) -> U32:
  Pair.snd(Array<U32>,U32,C.cached_at(b,p))

law encoded_blank_normalized_read:
  for -b: Array<U32>
  for +p: U32
  for -same: Array<U32>
  for +mask: U32
  for unchanged: {same == b : Array<U32>}
  for observed: {C.cached_at(b,p) == (same,mask) : Array<U32> & U32}
  {Q.encoded(p,(b,0)) == Q.encoded_mask(p,(b,cached_word(b,p))) : Array<U32>}

law encoded_blank_normalized:
  for -b: Array<U32>
  for +p: U32
  for read: SameBoardRead(b,C.cached_at(b,p))
  {Q.encoded(p,(b,0)) == Q.encoded_mask(p,(b,cached_word(b,p))) : Array<U32>}

def EncodedKeeps(-b: Array<U32>, +p: U32, +d: U32, +q: U32) -> Type:
  Board128(b) -> RoutedApart(p,q) -> RoutedApart(flag_slot(p),q) ->
  {cell_value(Q.encoded(p,(b,d)),q) == cell_value(b,q) : U32}

law encoded_blank_keeps_image:
  for +image: BoardImage
  for +p: U32
  for +q: U32
  EncodedKeeps(image_board(image),p,0,q)

law encoded_blank_keeps:
  for b: Array<U32>
  for +p: U32
  for +q: U32
  EncodedKeeps(b,p,0,q)

def EncodedRestores(-b: Array<U32>, +p: U32, +d: U32) -> Type:
  Board128(b) -> RoutedApart(flag_slot(p),p) ->
  {U32.shrn(cell_value(Q.encoded(p,(b,d)),p),10n) == d : U32}

law encoded_blank_restores_image:
  for +image: BoardImage
  for +p: U32
  EncodedRestores(image_board(image),p,0)

law encoded_blank_restores:
  for b: Array<U32>
  for +p: U32
  EncodedRestores(b,p,0)

type BoardDigit is Data:
  D0{}
  D1{}
  D2{}
  D3{}
  D4{}
  D5{}
  D6{}
  D7{}
  D8{}
  D9{}

def digit_word(+d: BoardDigit) -> U32:
  match d:
    case D0{}:
      0
    case D1{}:
      1
    case D2{}:
      2
    case D3{}:
      3
    case D4{}:
      4
    case D5{}:
      5
    case D6{}:
      6
    case D7{}:
      7
    case D8{}:
      8
    case D9{}:
      9

law encoded_digit_keeps:
  for +d: BoardDigit
  for b: Array<U32>
  for +p: U32
  for +q: U32
  EncodedKeeps(b,p,digit_word(d),q)

law encoded_digit_restores:
  for +d: BoardDigit
  for b: Array<U32>
  for +p: U32
  EncodedRestores(b,p,digit_word(d))

law encoded_any_keeps:
  for +d: U32
  for b: Array<U32>
  for +p: U32
  for +q: U32
  EncodedKeeps(b,p,d,q)

def actual_encoded_step(b: Array<U32>, +p: U32) -> Array<U32>:
  Q.encoded(p,B.get_cell(b,p))

law encode_step_normalized_read:
  for -b: Array<U32>
  for +p: U32
  for -same: Array<U32>
  for +word: U32
  for untouched: {same == b : Array<U32>}
  for observed: {B.get_cell(b,p) == (same,word) : Array<U32> & U32}
  {actual_encoded_step(b,p) == Q.encoded(p,(b,cell_value(b,p))) : Array<U32>}

law encode_step_normalized:
  for -b: Array<U32>
  for +p: U32
  for read: BoardReadWitness(b,p)
  {actual_encoded_step(b,p) == Q.encoded(p,(b,cell_value(b,p))) : Array<U32>}

def EncodeStepKeeps(-b: Array<U32>, +p: U32, +q: U32) -> Type:
  Board128(b) -> RoutedApart(p,q) -> RoutedApart(flag_slot(p),q) ->
  {cell_value(actual_encoded_step(b,p),q) == cell_value(b,q) : U32}

law encode_step_keeps_image:
  for +image: BoardImage
  for +p: U32
  for +q: U32
  EncodeStepKeeps(image_board(image),p,q)

law encode_step_keeps:
  for b: Array<U32>
  for +p: U32
  for +q: U32
  EncodeStepKeeps(b,p,q)

def EncodeStepRestores(-b: Array<U32>, +p: U32, +d: BoardDigit) -> Type:
  Board128(b) -> RoutedApart(flag_slot(p),p) ->
  {cell_value(b,p) == digit_word(d) : U32} ->
  {U32.shrn(cell_value(actual_encoded_step(b,p),p),10n) == digit_word(d) : U32}

law encode_step_restores_image:
  for +image: BoardImage
  for +p: U32
  for +d: BoardDigit
  EncodeStepRestores(image_board(image),p,d)

law encode_step_restores:
  for b: Array<U32>
  for +p: U32
  for +d: BoardDigit
  EncodeStepRestores(b,p,d)

law actual_encode_step_keeps_perfect:
  for b: Array<U32>
  for +p: U32
  for shape: Board128(b)
  Board128(actual_encoded_step(b,p))

def EncodeApart(+n: Nat, +p: U32, +q: U32) -> Type:
  match n:
    case 0n:
      {True{} == True{} : Bool}
    case 1n+k:
      RoutedApart(p,q) & RoutedApart(flag_slot(p),q) & EncodeApart(k,(p + 1 : U32),q)

def EncodeTailProof(+n: Nat, +p: U32, +q: U32) -> Type:
  @b:Array<U32> -> Board128(b) -> EncodeApart(n,p,q) ->
  {cell_value(Q.encode_go(n,p,b),q) == cell_value(b,q) : U32}

def EncodeKeepStep(-b: Array<U32>, +n: Nat, +p: U32, +q: U32) -> Type:
  Board128(b) -> EncodeApart(1n+n,p,q) -> EncodeTailProof(n,(p + 1 : U32),q) ->
  {cell_value(Q.encode_go(1n+n,p,b),q) == cell_value(b,q) : U32}

law encode_sweep_keep_image_step:
  for +image: BoardImage
  for +n: Nat
  for +p: U32
  for +q: U32
  for shapes: (Board128(image_board(image)) & Board128(image_board(image)))
  for apart: EncodeApart(1n+n,p,q)
  for next: EncodeTailProof(n,(p + 1 : U32),q)
  {cell_value(Q.encode_go(1n+n,p,image_board(image)),q) == cell_value(image_board(image),q) : U32}

law encode_sweep_keep_image:
  for +image: BoardImage
  for +n: Nat
  for +p: U32
  for +q: U32
  EncodeKeepStep(image_board(image),n,p,q)

law encode_sweep_keep_step:
  for b: Array<U32>
  for +n: Nat
  for +p: U32
  for +q: U32
  EncodeKeepStep(b,n,p,q)

law encode_sweep_keeps:
  for +n: Nat
  for +p: U32
  for +q: U32
  for b: Array<U32>
  for shape: Board128(b)
  for apart: EncodeApart(n,p,q)
  {cell_value(Q.encode_go(n,p,b),q) == cell_value(b,q) : U32}

def EncodeMiddleValue(-b: Array<U32>, +prefix: Nat, +suffix: Nat, +p: U32, +d: BoardDigit) -> Type:
  Board128(b) ->
  EncodeApart(prefix,p,walk_position(prefix,p)) ->
  RoutedApart(flag_slot(walk_position(prefix,p)),walk_position(prefix,p)) ->
  EncodeApart(suffix,(walk_position(prefix,p) + 1 : U32),walk_position(prefix,p)) ->
  {cell_value(b,walk_position(prefix,p)) == digit_word(d) : U32} ->
  {U32.shrn(cell_value(Q.encode_go(with_center(prefix,suffix),p,b),walk_position(prefix,p)),10n) == digit_word(d) : U32}

def EncodeMiddleProof(+prefix: Nat, +suffix: Nat, +p: U32, +d: BoardDigit) -> Type:
  @b:Array<U32> -> EncodeMiddleValue(b,prefix,suffix,p,d)

law encode_middle_base_image:
  for +image: BoardImage
  for +suffix: Nat
  for +p: U32
  for +d: BoardDigit
  for shapes: (Board128(image_board(image)) & Board128(image_board(image)))
  for safe: RoutedApart(flag_slot(p),p)
  for tail: EncodeApart(suffix,(p + 1 : U32),p)
  for digit: {cell_value(image_board(image),p) == digit_word(d) : U32}
  {U32.shrn(cell_value(Q.encode_go(1n+suffix,p,image_board(image)),p),10n) == digit_word(d) : U32}

law encode_middle_base:
  for +image: BoardImage
  for +suffix: Nat
  for +p: U32
  for +d: BoardDigit
  EncodeMiddleValue(image_board(image),0n,suffix,p,d)

law encode_middle_step_image:
  for +image: BoardImage
  for +k: Nat
  for +suffix: Nat
  for +p: U32
  for +d: BoardDigit
  for shapes: (Board128(image_board(image)) & Board128(image_board(image)))
  for before: EncodeApart(1n+k,p,walk_position(1n+k,p))
  for safe: RoutedApart(flag_slot(walk_position(1n+k,p)),walk_position(1n+k,p))
  for after: EncodeApart(suffix,(walk_position(1n+k,p) + 1 : U32),walk_position(1n+k,p))
  for digit: {cell_value(image_board(image),walk_position(1n+k,p)) == digit_word(d) : U32}
  for next: EncodeMiddleProof(k,suffix,(p + 1 : U32),d)
  {U32.shrn(cell_value(Q.encode_go(with_center(1n+k,suffix),p,image_board(image)),walk_position(1n+k,p)),10n) == digit_word(d) : U32}

law encode_middle_step:
  for +image: BoardImage
  for +k: Nat
  for +suffix: Nat
  for +p: U32
  for +d: BoardDigit
  for next: EncodeMiddleProof(k,suffix,(p + 1 : U32),d)
  EncodeMiddleValue(image_board(image),1n+k,suffix,p,d)

law encode_middle_from_image:
  for +prefix: Nat
  for +image: BoardImage
  for +suffix: Nat
  for +p: U32
  for +d: BoardDigit
  EncodeMiddleValue(image_board(image),prefix,suffix,p,d)

law encode_middle_value:
  for b: Array<U32>
  for +prefix: Nat
  for +suffix: Nat
  for +p: U32
  for +d: BoardDigit
  EncodeMiddleValue(b,prefix,suffix,p,d)

law encode_sweep_keeps_perfect:
  for b: Array<U32>
  for +n: Nat
  for +p: U32
  for shape: Board128(b)
  Board128(Q.encode_go(n,p,b))

def RoundTripAt(-b: Array<U32>, +before: Nat, +after: Nat, +p: U32, +d: BoardDigit) -> Type:
  Board128(b) ->
  EncodeApart(before,p,walk_position(before,p)) ->
  RoutedApart(flag_slot(walk_position(before,p)),walk_position(before,p)) ->
  EncodeApart(after,(walk_position(before,p) + 1 : U32),walk_position(before,p)) ->
  DecodeApart(before,p,walk_position(before,p)) ->
  DecodeApart(after,(walk_position(before,p) + 1 : U32),walk_position(before,p)) ->
  {cell_value(b,walk_position(before,p)) == digit_word(d) : U32} ->
  {cell_value(Q.decode(with_center(before,after),p,Q.encode_go(with_center(before,after),p,b)),walk_position(before,p))
    == digit_word(d) : U32}

law roundtrip_at_image_step:
  for +image: BoardImage
  for +before: Nat
  for +after: Nat
  for +p: U32
  for +d: BoardDigit
  for shapes: (Board128(image_board(image)) & Board128(image_board(image)))
  for ep: EncodeApart(before,p,walk_position(before,p))
  for safe: RoutedApart(flag_slot(walk_position(before,p)),walk_position(before,p))
  for es: EncodeApart(after,(walk_position(before,p) + 1 : U32),walk_position(before,p))
  for dp: DecodeApart(before,p,walk_position(before,p))
  for ds: DecodeApart(after,(walk_position(before,p) + 1 : U32),walk_position(before,p))
  for digit: {cell_value(image_board(image),walk_position(before,p)) == digit_word(d) : U32}
  {cell_value(Q.decode(with_center(before,after),p,Q.encode_go(with_center(before,after),p,image_board(image))),walk_position(before,p))
    == digit_word(d) : U32}

law roundtrip_at_image:
  for +image: BoardImage
  for +before: Nat
  for +after: Nat
  for +p: U32
  for +d: BoardDigit
  RoundTripAt(image_board(image),before,after,p,d)

law queued_roundtrip_at:
  for b: Array<U32>
  for +before: Nat
  for +after: Nat
  for +p: U32
  for +d: BoardDigit
  RoundTripAt(b,before,after,p,d)

def queue_seed(b: Array<U32>) -> Array<U32>:
  B.set_cell(B.set_cell(B.set_cell(b,109,0),110,0),111,0)

law queue_seed_perfect:
  for b: Array<U32>
  for shape: Board128(b)
  Board128(queue_seed(b))

def QueueSeedKeeps(-b: Array<U32>, +q: U32) -> Type:
  Board128(b) -> RoutedApart(109,q) -> RoutedApart(110,q) -> RoutedApart(111,q) ->
  {cell_value(queue_seed(b),q) == cell_value(b,q) : U32}

law queue_seed_keeps_step:
  for +image: BoardImage
  for +q: U32
  for shapes: (Board128(image_board(image)) & Board128(image_board(image)) & Board128(image_board(image)))
  for r9: RoutedApart(109,q)
  for r10: RoutedApart(110,q)
  for r11: RoutedApart(111,q)
  {cell_value(queue_seed(image_board(image)),q) == cell_value(image_board(image),q) : U32}

law queue_seed_keeps_image:
  for +image: BoardImage
  for +q: U32
  QueueSeedKeeps(image_board(image),q)

law queue_seed_keeps_cell:
  for b: Array<U32>
  for +q: U32
  QueueSeedKeeps(b,q)

def RoundTrip81At(-b: Array<U32>, +before: Nat, +after: Nat, +d: BoardDigit) -> Type:
  Board128(b) ->
  RoutedApart(109,walk_position(before,0)) ->
  RoutedApart(110,walk_position(before,0)) ->
  RoutedApart(111,walk_position(before,0)) ->
  EncodeApart(before,0,walk_position(before,0)) ->
  RoutedApart(flag_slot(walk_position(before,0)),walk_position(before,0)) ->
  EncodeApart(after,(walk_position(before,0) + 1 : U32),walk_position(before,0)) ->
  DecodeApart(before,0,walk_position(before,0)) ->
  DecodeApart(after,(walk_position(before,0) + 1 : U32),walk_position(before,0)) ->
  {with_center(before,after) == 81n : Nat} ->
  {cell_value(b,walk_position(before,0)) == digit_word(d) : U32} ->
  {cell_value(Q.decode(81n,0,Q.encode(b)),walk_position(before,0)) == digit_word(d) : U32}

law roundtrip81_at_step:
  for +image: BoardImage
  for +before: Nat
  for +after: Nat
  for +d: BoardDigit
  for shapes: (Board128(image_board(image)) & Board128(image_board(image)))
  for r9: RoutedApart(109,walk_position(before,0))
  for r10: RoutedApart(110,walk_position(before,0))
  for r11: RoutedApart(111,walk_position(before,0))
  for ep: EncodeApart(before,0,walk_position(before,0))
  for safe: RoutedApart(flag_slot(walk_position(before,0)),walk_position(before,0))
  for es: EncodeApart(after,(walk_position(before,0) + 1 : U32),walk_position(before,0))
  for dp: DecodeApart(before,0,walk_position(before,0))
  for ds: DecodeApart(after,(walk_position(before,0) + 1 : U32),walk_position(before,0))
  for count: {with_center(before,after) == 81n : Nat}
  for digit: {cell_value(image_board(image),walk_position(before,0)) == digit_word(d) : U32}
  {cell_value(Q.decode(81n,0,Q.encode(image_board(image))),walk_position(before,0)) == digit_word(d) : U32}

law roundtrip81_at_image:
  for +image: BoardImage
  for +before: Nat
  for +after: Nat
  for +d: BoardDigit
  RoundTrip81At(image_board(image),before,after,d)

law public_queue_roundtrip_at:
  for b: Array<U32>
  for +before: Nat
  for +after: Nat
  for +d: BoardDigit
  RoundTrip81At(b,before,after,d)

law both_true:
  for +a: Bool
  for +b: Bool
  for combined: {Bool.and(a,b) == True{} : Bool}
  ({a == True{} : Bool} & {b == True{} : Bool})

law copy_true:
  for -a: Bool
  for valid: {a == True{} : Bool}
  ({a == True{} : Bool} & {a == True{} : Bool})

def apart_guard(+p: U32, +q: U32) -> Bool:
  regular_routes(normalized_route(p),normalized_route(q))

def sweep_guard(+n: Nat, +p: U32, +q: U32) -> Bool:
  match n:
    case 0n:
      True{}
    case 1n+k:
      Bool.and(apart_guard(p,q),Bool.and(apart_guard(flag_slot(p),q),sweep_guard(k,(p + 1 : U32),q)))

def SweepWitnesses(+n: Nat, +p: U32, +q: U32) -> Type:
  (EncodeApart(n,p,q) & DecodeApart(n,p,q))

law sweep_witness_combine:
  for +n: Nat
  for +p: U32
  for +q: U32
  for logical: (RoutedApart(p,q) & RoutedApart(p,q))
  for flag: RoutedApart(flag_slot(p),q)
  for later: SweepWitnesses(n,(p + 1 : U32),q)
  SweepWitnesses(1n+n,p,q)

law sweep_witness_parts:
  for +n: Nat
  for +p: U32
  for +q: U32
  for first: RoutedApart(p,q)
  for right: ({apart_guard(flag_slot(p),q) == True{} : Bool} & {sweep_guard(n,(p + 1 : U32),q) == True{} : Bool})
  for recurse: ({sweep_guard(n,(p + 1 : U32),q) == True{} : Bool} -> SweepWitnesses(n,(p + 1 : U32),q))
  SweepWitnesses(1n+n,p,q)

law sweep_witness_head:
  for +n: Nat
  for +p: U32
  for +q: U32
  for parts: (RoutedApart(p,q) & {Bool.and(apart_guard(flag_slot(p),q),sweep_guard(n,(p + 1 : U32),q)) == True{} : Bool})
  for recurse: ({sweep_guard(n,(p + 1 : U32),q) == True{} : Bool} -> SweepWitnesses(n,(p + 1 : U32),q))
  SweepWitnesses(1n+n,p,q)

law sweep_witnesses:
  for +n: Nat
  for +p: U32
  for +q: U32
  for valid: {sweep_guard(n,p,q) == True{} : Bool}
  SweepWitnesses(n,p,q)

def window_guard(+before: Nat, +after: Nat, +q: U32, +next: U32) -> Bool:
  Bool.and(apart_guard(109,q),Bool.and(apart_guard(110,q),Bool.and(apart_guard(111,q),Bool.and(apart_guard(flag_slot(q),q),Bool.and(sweep_guard(before,0,q),sweep_guard(after,next,q))))))

def WindowRoutes(+before: Nat, +after: Nat, +q: U32, +next: U32) -> Type:
  RoutedApart(109,q) & RoutedApart(110,q) & RoutedApart(111,q) & RoutedApart(flag_slot(q),q) & SweepWitnesses(before,0,q) & SweepWitnesses(after,next,q)

law window_routes_split_4:
  for +before: Nat
  for +after: Nat
  for +q: U32
  for +next: U32
  for r9: RoutedApart(109,q)
  for r10: RoutedApart(110,q)
  for r11: RoutedApart(111,q)
  for safe: RoutedApart(flag_slot(q),q)
  for parts: ({sweep_guard(before,0,q) == True{} : Bool} & {sweep_guard(after,next,q) == True{} : Bool})
  WindowRoutes(before,after,q,next)

law window_routes_split_3:
  for +before: Nat
  for +after: Nat
  for +q: U32
  for +next: U32
  for r9: RoutedApart(109,q)
  for r10: RoutedApart(110,q)
  for r11: RoutedApart(111,q)
  for parts: ({apart_guard(flag_slot(q),q) == True{} : Bool} & {Bool.and(sweep_guard(before,0,q),sweep_guard(after,next,q)) == True{} : Bool})
  WindowRoutes(before,after,q,next)

law window_routes_split_2:
  for +before: Nat
  for +after: Nat
  for +q: U32
  for +next: U32
  for r9: RoutedApart(109,q)
  for r10: RoutedApart(110,q)
  for parts: ({apart_guard(111,q) == True{} : Bool} & {Bool.and(apart_guard(flag_slot(q),q),Bool.and(sweep_guard(before,0,q),sweep_guard(after,next,q))) == True{} : Bool})
  WindowRoutes(before,after,q,next)

law window_routes_split_1:
  for +before: Nat
  for +after: Nat
  for +q: U32
  for +next: U32
  for r9: RoutedApart(109,q)
  for parts: ({apart_guard(110,q) == True{} : Bool} & {Bool.and(apart_guard(111,q),Bool.and(apart_guard(flag_slot(q),q),Bool.and(sweep_guard(before,0,q),sweep_guard(after,next,q)))) == True{} : Bool})
  WindowRoutes(before,after,q,next)

law window_routes_split_0:
  for +before: Nat
  for +after: Nat
  for +q: U32
  for +next: U32
  for parts: ({apart_guard(109,q) == True{} : Bool} & {Bool.and(apart_guard(110,q),Bool.and(apart_guard(111,q),Bool.and(apart_guard(flag_slot(q),q),Bool.and(sweep_guard(before,0,q),sweep_guard(after,next,q))))) == True{} : Bool})
  WindowRoutes(before,after,q,next)

law window_routes:
  for +before: Nat
  for +after: Nat
  for +q: U32
  for +next: U32
  for guard: {window_guard(before,after,q,next) == True{} : Bool}
  WindowRoutes(before,after,q,next)

def VerifiedWindow(+before: Nat, +after: Nat) -> Type:
  ({window_guard(before,after,walk_position(before,0),(walk_position(before,0) + 1 : U32)) == True{} : Bool}
    & {with_center(before,after) == 81n : Nat})

law public_roundtrip_routes:
  for b: Array<U32>
  for +before: Nat
  for +after: Nat
  for +d: BoardDigit
  for shape: Board128(b)
  for routes: WindowRoutes(before,after,walk_position(before,0),(walk_position(before,0) + 1 : U32))
  for count: {with_center(before,after) == 81n : Nat}
  for digit: {cell_value(b,walk_position(before,0)) == digit_word(d) : U32}
  {cell_value(Q.decode(81n,0,Q.encode(b)),walk_position(before,0)) == digit_word(d) : U32}

law public_roundtrip_checked:
  for b: Array<U32>
  for +before: Nat
  for +after: Nat
  for +d: BoardDigit
  for shape: Board128(b)
  for window: VerifiedWindow(before,after)
  for digit: {cell_value(b,walk_position(before,0)) == digit_word(d) : U32}
  {cell_value(Q.decode(81n,0,Q.encode(b)),walk_position(before,0)) == digit_word(d) : U32}

type CellCoordinate is Data:
  Coordinate0{}
  Coordinate1{}
  Coordinate2{}
  Coordinate3{}
  Coordinate4{}
  Coordinate5{}
  Coordinate6{}
  Coordinate7{}
  Coordinate8{}

def coordinate_nat(+index: CellCoordinate) -> Nat:
  match index:
    case Coordinate0{}:
      0n
    case Coordinate1{}:
      1n
    case Coordinate2{}:
      2n
    case Coordinate3{}:
      3n
    case Coordinate4{}:
      4n
    case Coordinate5{}:
      5n
    case Coordinate6{}:
      6n
    case Coordinate7{}:
      7n
    case Coordinate8{}:
      8n

def row_start(+row: CellCoordinate) -> Nat:
  match row:
    case Coordinate0{}:
      0n
    case Coordinate1{}:
      9n
    case Coordinate2{}:
      18n
    case Coordinate3{}:
      27n
    case Coordinate4{}:
      36n
    case Coordinate5{}:
      45n
    case Coordinate6{}:
      54n
    case Coordinate7{}:
      63n
    case Coordinate8{}:
      72n

def logical_offset(+row: CellCoordinate, +col: CellCoordinate) -> Nat:
  Nat.add(row_start(row),coordinate_nat(col))

def logical_tail(+row: CellCoordinate, +col: CellCoordinate) -> Nat:
  Nat.sub(80n,logical_offset(row,col))

def logical_position(+row: CellCoordinate, +col: CellCoordinate) -> U32:
  walk_position(logical_offset(row,col),0)

law row_window_0:
  for +col: CellCoordinate
  VerifiedWindow(logical_offset(Coordinate0{},col),logical_tail(Coordinate0{},col))

law row_window_1:
  for +col: CellCoordinate
  VerifiedWindow(logical_offset(Coordinate1{},col),logical_tail(Coordinate1{},col))

law row_window_2:
  for +col: CellCoordinate
  VerifiedWindow(logical_offset(Coordinate2{},col),logical_tail(Coordinate2{},col))

law row_window_3:
  for +col: CellCoordinate
  VerifiedWindow(logical_offset(Coordinate3{},col),logical_tail(Coordinate3{},col))

law row_window_4:
  for +col: CellCoordinate
  VerifiedWindow(logical_offset(Coordinate4{},col),logical_tail(Coordinate4{},col))

law row_window_5:
  for +col: CellCoordinate
  VerifiedWindow(logical_offset(Coordinate5{},col),logical_tail(Coordinate5{},col))

law row_window_6:
  for +col: CellCoordinate
  VerifiedWindow(logical_offset(Coordinate6{},col),logical_tail(Coordinate6{},col))

law row_window_7:
  for +col: CellCoordinate
  VerifiedWindow(logical_offset(Coordinate7{},col),logical_tail(Coordinate7{},col))

law row_window_8:
  for +col: CellCoordinate
  VerifiedWindow(logical_offset(Coordinate8{},col),logical_tail(Coordinate8{},col))

law every_cell_window:
  for +row: CellCoordinate
  for +col: CellCoordinate
  VerifiedWindow(logical_offset(row,col),logical_tail(row,col))


law any_logical_cell_roundtrip:
  for b: Array<U32>
  for +row: CellCoordinate
  for +col: CellCoordinate
  for +d: BoardDigit
  for shape: Board128(b)
  for digit: {cell_value(b,logical_position(row,col)) == digit_word(d) : U32}
  {cell_value(Q.decode(81n,0,Q.encode(b)),logical_position(row,col)) == digit_word(d) : U32}
