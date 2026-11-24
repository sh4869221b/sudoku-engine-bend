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
