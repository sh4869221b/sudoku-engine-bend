import ./sudoku/generator.bend as G
import Base
import ./sudoku/arithmetic.bend as M
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

def search_digit(+active: Bool, b: Array<U32>, +p: U32) -> U32:
  match active:
    case True{}:
      U32.shrn(cell_value(b,p),10n)
    case False{}:
      cell_value(b,p)

law adaptive_activation_finish:
  for b: Array<U32>
  for +row: CellCoordinate
  for +col: CellCoordinate
  for +d: BoardDigit
  for shape: Board128(b)
  for given: {cell_value(b,logical_position(row,col)) == digit_word(d) : U32}
  {cell_value(Fast.finish(True{},Fast.activated(False{},b)),logical_position(row,col)) == digit_word(d) : U32}

def answer_digit(state: Fast.State, +p: U32) -> U32:
  match state:
    case Fast.SnapshotDone{found,answer}:
      cell_value(answer,p)
    case _:
      0

law adaptive_new_mode_record:
  for b: Array<U32>
  for frames: Array<U32>
  for +depth: U32
  for +found: U32
  for snapshots: List<&1,Array<U32>>
  for +row: CellCoordinate
  for +col: CellCoordinate
  for +d: BoardDigit
  for shape: Board128(b)
  for given: {cell_value(b,logical_position(row,col)) == digit_word(d) : U32}
  {answer_digit(Fast.record(True{},Fast.activated(False{},b),frames,depth,found,snapshots,True{}),logical_position(row,col))
    == digit_word(d) : U32}

law adaptive_active_clear_keeps_clue:
  for b: Array<U32>
  for +written: U32
  for +clue: U32
  for shape: Board128(b)
  for separate: RoutedApart(written,clue)
  {search_digit(True{},Fast.cleared(True{},b,written),clue) == search_digit(True{},b,clue) : U32}

law adaptive_active_clear_keeps_shape:
  for b: Array<U32>
  for +written: U32
  for shape: Board128(b)
  Board128(Fast.cleared(True{},b,written))

def backtrack_digit(state: Fast.State, +p: U32) -> U32:
  match state:
    case Fast.Backtracking{board,frames,depth,found,snapshots,+active}:
      search_digit(active,board,p)
    case _:
      0

law adaptive_active_unwind_keeps_clue:
  for b: Array<U32>
  for +written: U32
  for +clue: U32
  for frames: Array<U32>
  for +depth: U32
  for +found: U32
  for snapshots: List<&1,Array<U32>>
  for shape: Board128(b)
  for separate: RoutedApart(written,clue)
  {backtrack_digit(Fast.popped_guess(False{},written,0,frames,depth,found,snapshots,True{},b),clue)
    == search_digit(True{},b,clue) : U32}

law adaptive_restore_reads_saved_clue:
  for saved: Array<U32>
  for +pos: U32
  for +clue: U32
  for frames: Array<U32>
  for +depth: U32
  for +found: U32
  for snapshots: List<&1,Array<U32>>
  for +active: Bool
  {backtrack_digit(Fast.restore(pos,0,frames,depth,found,saved <> snapshots,active),clue)
    == search_digit(active,saved,clue) : U32}

law queue_peer_without_bit:
  for b: Array<U32>
  for +p: U32
  for +bit: U32
  for +word: U32
  for clear: {U32.and(word,bit) == 0 : U32}
  {Q.peer(p,bit,(b,word)) == b : Array<U32>}

law queue_peer_reads_fixed:
  for b: Array<U32>
  for +p: U32
  for +bit: U32
  for -same: Array<U32>
  for +word: U32
  for unchanged: {same == b : Array<U32>}
  for observed: {B.get_cell(b,p) == (same,word) : Array<U32> & U32}
  for clear: {U32.and(word,bit) == 0 : U32}
  {Q.peer(p,bit,B.get_cell(b,p)) == b : Array<U32>}

def fixed_hi_word(+hi: Word(22n)) -> U32:
  U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, hi}}}}}}}}}}}

law word_fixed_high_ignores_trimmed:
  for +hi: Word(22n)
  for +tail: Word(22n)
  {Word.and(22n,hi,Word.and(22n,Word.zero(22n),tail)) == Word.zero(22n) : Word(22n)}

law fixed_high_ignores_trimmed:
  for +hi: Word(22n)
  for +mask: U32
  {U32.and(fixed_hi_word(hi),U32.and(1023,mask)) == 0 : U32}

law shifted_digit_ignores_trimmed:
  for +fixed: BoardDigit
  for +mask: U32
  {U32.and(U32.shln(digit_word(fixed),10n),U32.and(1023,mask)) == 0 : U32}

law placement_bit_fits_low:
  for +d: BoardDigit
  {B.bit(digit_word(d)) == U32.and(1023,B.bit(digit_word(d))) : U32}

law queued_placement_bit_excludes_fixed:
  for +fixed: BoardDigit
  for +placed: BoardDigit
  {U32.and(U32.shln(digit_word(fixed),10n),B.bit(digit_word(placed))) == 0 : U32}

law queued_peer_on_fixed_digit:
  for b: Array<U32>
  for +p: U32
  for +fixed: BoardDigit
  for +placed: BoardDigit
  {Q.peer(p,B.bit(digit_word(placed)),(b,U32.shln(digit_word(fixed),10n))) == b : Array<U32>}

law queue_peer_fixed_observed:
  for b: Array<U32>
  for +p: U32
  for +fixed: BoardDigit
  for +placed: BoardDigit
  for -same: Array<U32>
  for +word: U32
  for kept: {same == b : Array<U32>}
  for read: {B.get_cell(b,p) == (same,word) : Array<U32> & U32}
  for given: {cell_value(b,p) == U32.shln(digit_word(fixed),10n) : U32}
  {Q.peer(p,B.bit(digit_word(placed)),B.get_cell(b,p)) == b : Array<U32>}

law queue_peer_fixed_read:
  for b: Array<U32>
  for +p: U32
  for +fixed: BoardDigit
  for +placed: BoardDigit
  for rd: BoardReadWitness(b,p)
  for given: {cell_value(b,p) == U32.shln(digit_word(fixed),10n) : U32}
  {Q.peer(p,B.bit(digit_word(placed)),B.get_cell(b,p)) == b : Array<U32>}

def PeerFixed(-b: Array<U32>, +p: U32, +fixed: BoardDigit, +placed: BoardDigit) -> Type:
  {cell_value(b,p) == U32.shln(digit_word(fixed),10n) : U32} ->
  {Q.peer(p,B.bit(digit_word(placed)),B.get_cell(b,p)) == b : Array<U32>}

law queue_actual_peer_fixed_image:
  for +image: BoardImage
  for +p: U32
  for +fixed: BoardDigit
  for +placed: BoardDigit
  PeerFixed(image_board(image),p,fixed,placed)

law queue_actual_peer_fixed:
  for b: Array<U32>
  for +p: U32
  for +fixed: BoardDigit
  for +placed: BoardDigit
  PeerFixed(b,p,fixed,placed)

def FirstOnlyWritesPointer(-b: Array<U32>, -out: Array<U32>) -> Type:
  Sigma<&2,&1,U32,ptr => {out == B.set_cell(b,108,ptr) : Array<U32>}>

law queued_first_pointer_from_read:
  for +n: Nat
  for +p: U32
  for -b: Array<U32>
  for -same: Array<U32>
  for +word: U32
  for kept: {same == b : Array<U32>}
  for actual: {B.get_cell(b,(p + 1 : U32)) == (same,word) : Array<U32> & U32}
  for later: FirstOnlyWritesPointer(same,Q.first_step(n,(p + 1 : U32),(same,(word < 1024 : U32))))
  FirstOnlyWritesPointer(b,Q.first_step(1n+n,p,(b,False{})))

def PointerTail(+n: Nat, +next: U32) -> Type:
  @sub:Array<U32> -> @open:Bool -> FirstOnlyWritesPointer(sub,Q.first_step(n,next,(sub,open)))

law queued_first_pointer_read:
  for +n: Nat
  for +p: U32
  for -b: Array<U32>
  for read: BoardReadWitness(b,(p + 1 : U32))
  for recurse: PointerTail(n,(p + 1 : U32))
  FirstOnlyWritesPointer(b,Q.first_step(1n+n,p,(b,False{})))

law queued_first_pointer_live:
  for +n: Nat
  for +p: U32
  for b: Array<U32>
  for +open: Bool
  for recurse: PointerTail(n,(p + 1 : U32))
  FirstOnlyWritesPointer(b,Q.first_step(1n+n,p,(b,open)))

law queued_first_pointer:
  for +n: Nat
  for +p: U32
  for b: Array<U32>
  for +open: Bool
  FirstOnlyWritesPointer(b,Q.first_step(n,p,(b,open)))

law pointer_keeps_logical_witness:
  for b: Array<U32>
  for -out: Array<U32>
  for +q: U32
  for shape: Board128(b)
  for separate: RoutedApart(108,q)
  for witness: FirstOnlyWritesPointer(b,out)
  {cell_value(out,q) == cell_value(b,q) : U32}

law queue_first_pointer_keeps_clue_image:
  for +image: BoardImage
  for +n: Nat
  for +p: U32
  for +q: U32
  for +open: Bool
  Board128(image_board(image)) -> RoutedApart(108,q) ->
  {cell_value(Q.first_step(n,p,(image_board(image),open)),q) == cell_value(image_board(image),q) : U32}

law queue_first_pointer_keeps_clue:
  for b: Array<U32>
  for +n: Nat
  for +p: U32
  for +q: U32
  for +open: Bool
  Board128(b) -> RoutedApart(108,q) ->
  {cell_value(Q.first_step(n,p,(b,open)),q) == cell_value(b,q) : U32}

def KeepsWord(-b: Array<U32>, -out: Array<U32>, +q: U32) -> Type:
  Board128(b) -> {cell_value(out,q) == cell_value(b,q) : U32}

law queue_flag_perfect:
  for b: Array<U32>
  for +p: U32
  for +present: Bool
  for shape: Board128(b)
  Board128(Q.flag(b,p,present))

law queue_changed_flag_perfect:
  for b: Array<U32>
  for +p: U32
  for +needed: Bool
  for shape: Board128(b)
  Board128(Q.changed_flag(needed,b,p))

law queue_changed_flag_keeps:
  for b: Array<U32>
  for +needed: Bool
  for +p: U32
  for +q: U32
  for sep: RoutedApart(flag_slot(p),q)
  KeepsWord(b,Q.changed_flag(needed,b,p),q)

def peer_mask(+old: U32, +bit: U32) -> U32:
  U32.and(old,U32.not(bit))

def peer_reflag(+old: U32, +bit: U32) -> Bool:
  U32.is_ne(U32.and(old,(old - 1 : U32)),0) && Q.zero_or_single(peer_mask(old,bit))

law queue_changed_perfect_image:
  for +image: BoardImage
  for +needed: Bool
  for +p: U32
  for +bit: U32
  for +old: U32
  Board128(image_board(image)) -> Board128(Q.changed(needed,p,bit,image_board(image),old))

law queue_changed_perfect:
  for b: Array<U32>
  for +needed: Bool
  for +p: U32
  for +bit: U32
  for +old: U32
  for shape: Board128(b)
  Board128(Q.changed(needed,p,bit,b,old))

def ChangedKeeps(-b: Array<U32>, +needed: Bool, +p: U32, +bit: U32, +old: U32, +q: U32) -> Type:
  Board128(b) -> RoutedApart(p,q) -> RoutedApart(flag_slot(p),q) ->
  {cell_value(Q.changed(needed,p,bit,b,old),q) == cell_value(b,q) : U32}

law queue_changed_keeps_yes:
  for +image: BoardImage
  for +p: U32
  for +bit: U32
  for +old: U32
  for +q: U32
  for shapes: (Board128(image_board(image)) & Board128(image_board(image)))
  for apart: RoutedApart(p,q)
  for flag: RoutedApart(flag_slot(p),q)
  {cell_value(Q.changed(True{},p,bit,image_board(image),old),q) == cell_value(image_board(image),q) : U32}

law queue_changed_keeps_image:
  for +image: BoardImage
  for +needed: Bool
  for +p: U32
  for +bit: U32
  for +old: U32
  for +q: U32
  ChangedKeeps(image_board(image),needed,p,bit,old,q)

law queue_changed_keeps:
  for b: Array<U32>
  for +needed: Bool
  for +p: U32
  for +bit: U32
  for +old: U32
  for +q: U32
  ChangedKeeps(b,needed,p,bit,old,q)

def actual_peer(b: Array<U32>, +p: U32, +bit: U32) -> Array<U32>:
  Q.peer(p,bit,B.get_cell(b,p))

law peer_normalized_observed:
  for -b: Array<U32>
  for +p: U32
  for +bit: U32
  for -same: Array<U32>
  for +old: U32
  for kept: {same == b : Array<U32>}
  for read: {B.get_cell(b,p) == (same,old) : Array<U32> & U32}
  {actual_peer(b,p,bit) == Q.changed(U32.is_ne(U32.and(cell_value(b,p),bit),0),p,bit,b,cell_value(b,p)) : Array<U32>}

law peer_normalized:
  for -b: Array<U32>
  for +p: U32
  for +bit: U32
  for rd: BoardReadWitness(b,p)
  {actual_peer(b,p,bit) == Q.changed(U32.is_ne(U32.and(cell_value(b,p),bit),0),p,bit,b,cell_value(b,p)) : Array<U32>}

def PeerKeeps(-b: Array<U32>, +p: U32, +bit: U32, +q: U32) -> Type:
  Board128(b) -> RoutedApart(p,q) -> RoutedApart(flag_slot(p),q) ->
  {cell_value(actual_peer(b,p,bit),q) == cell_value(b,q) : U32}

law peer_keeps_image:
  for +image: BoardImage
  for +p: U32
  for +bit: U32
  for +q: U32
  PeerKeeps(image_board(image),p,bit,q)

law peer_keeps:
  for b: Array<U32>
  for +p: U32
  for +bit: U32
  for +q: U32
  PeerKeeps(b,p,bit,q)

law peer_perfect_image:
  for +image: BoardImage
  for +p: U32
  for +bit: U32
  Board128(image_board(image)) -> Board128(actual_peer(image_board(image),p,bit))

law peer_perfect:
  for b: Array<U32>
  for +p: U32
  for +bit: U32
  Board128(b) -> Board128(actual_peer(b,p,bit))

def fixed_word(+d: BoardDigit) -> U32:
  U32.shln(digit_word(d),10n)

def FixedClue(-b: Array<U32>, +q: U32, +d: BoardDigit) -> Type:
  (Board128(b) & {cell_value(b,q) == fixed_word(d) : U32})

def PeerRoute(+p: U32, +q: U32) -> Type:
  Either<&1,&1,{p == q : U32},(RoutedApart(p,q) & RoutedApart(flag_slot(p),q))>

law copy_word_eq:
  for -word: U32
  for -expected: U32
  for known: {word == expected : U32}
  ({word == expected : U32} & {word == expected : U32})

law peer_keeps_same_step:
  for +image: BoardImage
  for +q: U32
  for +fixed: BoardDigit
  for +placed: BoardDigit
  for shape: Board128(image_board(image))
  for given: ({cell_value(image_board(image),q) == fixed_word(fixed) : U32} & {cell_value(image_board(image),q) == fixed_word(fixed) : U32})
  FixedClue(actual_peer(image_board(image),q,B.bit(digit_word(placed))),q,fixed)

law peer_keeps_same_image:
  for +image: BoardImage
  for +q: U32
  for +fixed: BoardDigit
  for +placed: BoardDigit
  FixedClue(image_board(image),q,fixed) ->
  FixedClue(actual_peer(image_board(image),q,B.bit(digit_word(placed))),q,fixed)

law peer_keeps_separate_step:
  for +image: BoardImage
  for +p: U32
  for +q: U32
  for +fixed: BoardDigit
  for +placed: BoardDigit
  for shapes: (Board128(image_board(image)) & Board128(image_board(image)))
  for given: {cell_value(image_board(image),q) == fixed_word(fixed) : U32}
  for sep: RoutedApart(p,q)
  for flag: RoutedApart(flag_slot(p),q)
  FixedClue(actual_peer(image_board(image),p,B.bit(digit_word(placed))),q,fixed)

law peer_keeps_separate_image:
  for +image: BoardImage
  for +p: U32
  for +q: U32
  for +fixed: BoardDigit
  for +placed: BoardDigit
  for apart: (RoutedApart(p,q) & RoutedApart(flag_slot(p),q))
  FixedClue(image_board(image),q,fixed) ->
  FixedClue(actual_peer(image_board(image),p,B.bit(digit_word(placed))),q,fixed)

def PeerClueTransition(-b: Array<U32>, +p: U32, +q: U32, +fixed: BoardDigit, +placed: BoardDigit) -> Type:
  PeerRoute(p,q) -> FixedClue(b,q,fixed) ->
  FixedClue(actual_peer(b,p,B.bit(digit_word(placed))),q,fixed)

law peer_clue_transition_image:
  for +image: BoardImage
  for +p: U32
  for +q: U32
  for +fixed: BoardDigit
  for +placed: BoardDigit
  PeerClueTransition(image_board(image),p,q,fixed,placed)

law peer_clue_transition:
  for b: Array<U32>
  for +p: U32
  for +q: U32
  for +fixed: BoardDigit
  for +placed: BoardDigit
  PeerClueTransition(b,p,q,fixed,placed)

def RowClueRoutes(+n: Nat, +j: U32, +base: U32, +q: U32) -> Type:
  match n:
    case 0n:
      {True{} == True{} : Bool}
    case 1n+k:
      PeerRoute((base + j : U32),q) & RowClueRoutes(k,(j + 1 : U32),base,q)

def RowClueProof(+n: Nat, +j: U32, +base: U32, +placed: U32, +q: U32, +fixed: BoardDigit, +d: BoardDigit) -> Type:
  @b:Array<U32> -> RowClueRoutes(n,j,base,q) -> FixedClue(b,q,fixed) ->
  FixedClue(Q.row_line(n,j,base,placed,B.bit(digit_word(d)),b),q,fixed)

def RowClueStep(-b: Array<U32>, +n: Nat, +j: U32, +base: U32, +placed: U32, +q: U32, +fixed: BoardDigit, +d: BoardDigit) -> Type:
  RowClueRoutes(1n+n,j,base,q) -> FixedClue(b,q,fixed) ->
  RowClueProof(n,(j + 1 : U32),base,placed,q,fixed,d) ->
  FixedClue(Q.row_line(1n+n,j,base,placed,B.bit(digit_word(d)),b),q,fixed)

law row_clue_step_image:
  for +image: BoardImage
  for +n: Nat
  for +j: U32
  for +base: U32
  for +placed: U32
  for +q: U32
  for +fixed: BoardDigit
  for +d: BoardDigit
  RowClueStep(image_board(image),n,j,base,placed,q,fixed,d)

law row_clue_step:
  for b: Array<U32>
  for +n: Nat
  for +j: U32
  for +base: U32
  for +placed: U32
  for +q: U32
  for +fixed: BoardDigit
  for +d: BoardDigit
  RowClueStep(b,n,j,base,placed,q,fixed,d)

law row_clue_line:
  for +n: Nat
  for +j: U32
  for +base: U32
  for +placed: U32
  for +q: U32
  for +fixed: BoardDigit
  for +d: BoardDigit
  RowClueProof(n,j,base,placed,q,fixed,d)

def ColumnClueRoutes(+n: Nat, +j: U32, +col: U32, +q: U32) -> Type:
  match n:
    case 0n:
      {True{} == True{} : Bool}
    case 1n+k:
      PeerRoute((j * 9 + col : U32),q) & ColumnClueRoutes(k,(j + 1 : U32),col,q)

def ColumnClueProof(+n: Nat, +j: U32, +col: U32, +placed: U32, +q: U32, +fixed: BoardDigit, +d: BoardDigit) -> Type:
  @b:Array<U32> -> ColumnClueRoutes(n,j,col,q) -> FixedClue(b,q,fixed) ->
  FixedClue(Q.column_line(n,j,col,placed,B.bit(digit_word(d)),b),q,fixed)

def ColumnClueStep(-b: Array<U32>, +n: Nat, +j: U32, +col: U32, +placed: U32, +q: U32, +fixed: BoardDigit, +d: BoardDigit) -> Type:
  ColumnClueRoutes(1n+n,j,col,q) -> FixedClue(b,q,fixed) ->
  ColumnClueProof(n,(j + 1 : U32),col,placed,q,fixed,d) ->
  FixedClue(Q.column_line(1n+n,j,col,placed,B.bit(digit_word(d)),b),q,fixed)

law column_clue_step_image:
  for +image: BoardImage
  for +n: Nat
  for +j: U32
  for +col: U32
  for +placed: U32
  for +q: U32
  for +fixed: BoardDigit
  for +d: BoardDigit
  ColumnClueStep(image_board(image),n,j,col,placed,q,fixed,d)

law column_clue_step:
  for b: Array<U32>
  for +n: Nat
  for +j: U32
  for +col: U32
  for +placed: U32
  for +q: U32
  for +fixed: BoardDigit
  for +d: BoardDigit
  ColumnClueStep(b,n,j,col,placed,q,fixed,d)

law column_clue_line:
  for +n: Nat
  for +j: U32
  for +col: U32
  for +placed: U32
  for +q: U32
  for +fixed: BoardDigit
  for +d: BoardDigit
  ColumnClueProof(n,j,col,placed,q,fixed,d)

def run_peer_list(positions: List<&2,U32>, b: Array<U32>, +bit: U32) -> Array<U32>:
  match positions:
    case Nil{}:
      b
    case +p <> tail:
      run_peer_list(tail,actual_peer(b,p,bit),bit)

def PeerListRoutes(positions: List<&2,U32>, +q: U32) -> Type:
  match positions:
    case Nil{}:
      {True{} == True{} : Bool}
    case +p <> tail:
      PeerRoute(p,q) & PeerListRoutes(tail,q)

def PeerListProof(-positions: List<&2,U32>, +q: U32, +fixed: BoardDigit, +d: BoardDigit) -> Type:
  @b:Array<U32> -> PeerListRoutes(positions,q) -> FixedClue(b,q,fixed) ->
  FixedClue(run_peer_list(positions,b,B.bit(digit_word(d))),q,fixed)

law peer_list_step_image:
  for +image: BoardImage
  for +p: U32
  for -tail: List<&2,U32>
  for +q: U32
  for +fixed: BoardDigit
  for +d: BoardDigit
  for routes: PeerListRoutes(p <> tail,q)
  for state: FixedClue(image_board(image),q,fixed)
  for next: PeerListProof(tail,q,fixed,d)
  FixedClue(run_peer_list(p <> tail,image_board(image),B.bit(digit_word(d))),q,fixed)

law peer_list_step:
  for b: Array<U32>
  for +p: U32
  for -tail: List<&2,U32>
  for +q: U32
  for +fixed: BoardDigit
  for +d: BoardDigit
  for routes: PeerListRoutes(p <> tail,q)
  for state: FixedClue(b,q,fixed)
  for next: PeerListProof(tail,q,fixed,d)
  FixedClue(run_peer_list(p <> tail,b,B.bit(digit_word(d))),q,fixed)

law peer_list_clue:
  for positions: List<&2,U32>
  for +q: U32
  for +fixed: BoardDigit
  for +d: BoardDigit
  PeerListProof(positions,q,fixed,d)

def box_positions(+base: U32, +r1: U32, +r2: U32, +c1: U32, +c2: U32) -> List<&2,U32>:
  [(base + r1 * 9 + c1 : U32),(base + r1 * 9 + c2 : U32),(base + r2 * 9 + c1 : U32),(base + r2 * 9 + c2 : U32)]

law box_four_keeps_clue:
  for b: Array<U32>
  for +base: U32
  for +r1: U32
  for +r2: U32
  for +c1: U32
  for +c2: U32
  for +q: U32
  for +fixed: BoardDigit
  for +d: BoardDigit
  for routes: PeerListRoutes(box_positions(base,r1,r2,c1,c2),q)
  for state: FixedClue(b,q,fixed)
  FixedClue(Q.box_four(base,r1,r2,c1,c2,B.bit(digit_word(d)),b),q,fixed)

law fixed_after_pointer_write:
  for +image: BoardImage
  for -out: Array<U32>
  for +q: U32
  for +d: BoardDigit
  for shape: (Board128(image_board(image)) & Board128(image_board(image)))
  for known: {cell_value(image_board(image),q) == fixed_word(d) : U32}
  for apart: RoutedApart(108,q)
  for witness: FirstOnlyWritesPointer(image_board(image),out)
  FixedClue(out,q,d)

law first_step_keeps_fixed_image:
  for +image: BoardImage
  for +n: Nat
  for +p: U32
  for +open: Bool
  for +q: U32
  for +d: BoardDigit
  for apart: RoutedApart(108,q)
  for state: FixedClue(image_board(image),q,d)
  FixedClue(Q.first_step(n,p,(image_board(image),open)),q,d)

def first_actual(b: Array<U32>, +n: Nat, +p: U32) -> Array<U32>:
  Q.first_step(n,p,Q.first_read(B.get_cell(b,p)))

law first_actual_from_read:
  for +n: Nat
  for +p: U32
  for -b: Array<U32>
  for same: Array<U32>
  for +word: U32
  for kept: {same == b : Array<U32>}
  for observed: {B.get_cell(b,p) == (same,word) : Array<U32> & U32}
  for recurse: PointerTail(n,p)
  FirstOnlyWritesPointer(b,first_actual(b,n,p))

law first_actual_pointer:
  for +n: Nat
  for +p: U32
  for -b: Array<U32>
  for read: BoardReadWitness(b,p)
  FirstOnlyWritesPointer(b,first_actual(b,n,p))

law refresh_needed_clue_image:
  for +image: BoardImage
  for +needed: Bool
  for +start: U32
  for +q: U32
  for +d: BoardDigit
  for apart: RoutedApart(108,q)
  for state: FixedClue(image_board(image),q,d)
  FixedClue(Q.refresh_needed(needed,image_board(image),start),q,d)

def refresh_actual(b: Array<U32>, +p: U32) -> Array<U32>:
  Q.refresh(p,B.get_cell(b,108))

law refresh_normalized_read:
  for -b: Array<U32>
  for +p: U32
  for -same: Array<U32>
  for +start: U32
  for kept: {same == b : Array<U32>}
  for observed: {B.get_cell(b,108) == (same,start) : Array<U32> & U32}
  {refresh_actual(b,p) == Q.refresh_needed(U32.is_eq(p,cell_value(b,108)),b,cell_value(b,108)) : Array<U32>}

law refresh_normalized:
  for -b: Array<U32>
  for +p: U32
  for read: BoardReadWitness(b,108)
  {refresh_actual(b,p) == Q.refresh_needed(U32.is_eq(p,cell_value(b,108)),b,cell_value(b,108)) : Array<U32>}

def RefreshClue(-b: Array<U32>, +p: U32, +q: U32, +d: BoardDigit) -> Type:
  RoutedApart(108,q) -> FixedClue(b,q,d) -> FixedClue(refresh_actual(b,p),q,d)

law refresh_keeps_clue_image:
  for +image: BoardImage
  for +p: U32
  for +q: U32
  for +d: BoardDigit
  RefreshClue(image_board(image),p,q,d)

law refresh_keeps_clue:
  for b: Array<U32>
  for +p: U32
  for +q: U32
  for +d: BoardDigit
  RefreshClue(b,p,q,d)

law clear_forced_clue_image_step:
  for +image: BoardImage
  for +p: U32
  for +q: U32
  for +d: BoardDigit
  for flag: RoutedApart(flag_slot(p),q)
  for shapes: (Board128(image_board(image)) & Board128(image_board(image)))
  for known: {cell_value(image_board(image),q) == fixed_word(d) : U32}
  FixedClue(Q.clear_forced(False{},image_board(image),p),q,d)

law clear_forced_clue_image:
  for +image: BoardImage
  for +guess: Bool
  for +p: U32
  for +q: U32
  for +d: BoardDigit
  for flag: RoutedApart(flag_slot(p),q)
  for state: FixedClue(image_board(image),q,d)
  FixedClue(Q.clear_forced(guess,image_board(image),p),q,d)

law clear_forced_clue:
  for b: Array<U32>
  for +guess: Bool
  for +p: U32
  for +q: U32
  for +d: BoardDigit
  for flag: RoutedApart(flag_slot(p),q)
  for state: FixedClue(b,q,d)
  FixedClue(Q.clear_forced(guess,b,p),q,d)

law write_fixed_other_step:
  for +image: BoardImage
  for +p: U32
  for +value: U32
  for +q: U32
  for +fixed: BoardDigit
  for apart: RoutedApart(p,q)
  for shapes: (Board128(image_board(image)) & Board128(image_board(image)))
  for known: {cell_value(image_board(image),q) == fixed_word(fixed) : U32}
  FixedClue(B.set_cell(image_board(image),p,value),q,fixed)

law write_fixed_other_image:
  for +image: BoardImage
  for +p: U32
  for +value: U32
  for +q: U32
  for +fixed: BoardDigit
  for apart: RoutedApart(p,q)
  for state: FixedClue(image_board(image),q,fixed)
  FixedClue(B.set_cell(image_board(image),p,value),q,fixed)

law write_fixed_other:
  for b: Array<U32>
  for +p: U32
  for +value: U32
  for +q: U32
  for +fixed: BoardDigit
  for apart: RoutedApart(p,q)
  for state: FixedClue(b,q,fixed)
  FixedClue(B.set_cell(b,p,value),q,fixed)

def place_row_base(+pos: U32) -> U32:
  (M.div9(pos) * 9 : U32)

def place_box_base(+pos: U32) -> U32:
  (M.div3(M.div9(pos)) * 27 + M.div3(M.rem9(pos)) * 3 : U32)

def place_box_r1(+pos: U32) -> U32:
  M.rem3((M.div9(pos) + 1 : U32))

def place_box_r2(+pos: U32) -> U32:
  M.rem3((M.div9(pos) + 2 : U32))

def place_box_c1(+pos: U32) -> U32:
  M.rem3((M.rem9(pos) + 1 : U32))

def place_box_c2(+pos: U32) -> U32:
  M.rem3((M.rem9(pos) + 2 : U32))

def PlacePeerRoutes(+p: U32, +q: U32) -> Type:
  (RowClueRoutes(9n,0,place_row_base(p),q) & ColumnClueRoutes(9n,0,M.rem9(p),q)
   & PeerListRoutes(box_positions(place_box_base(p),place_box_r1(p),place_box_r2(p),place_box_c1(p),place_box_c2(p)),q)
   & RoutedApart(108,q))

def place_rows(b: Array<U32>, +p: U32, +d: BoardDigit) -> Array<U32>:
  Q.row_line(9n,0,place_row_base(p),p,B.bit(digit_word(d)),b)

def place_columns(b: Array<U32>, +p: U32, +d: BoardDigit) -> Array<U32>:
  Q.column_line(9n,0,M.rem9(p),p,B.bit(digit_word(d)),place_rows(b,p,d))

def place_boxes(b: Array<U32>, +p: U32, +d: BoardDigit) -> Array<U32>:
  Q.box_four(place_box_base(p),place_box_r1(p),place_box_r2(p),place_box_c1(p),place_box_c2(p),B.bit(digit_word(d)),place_columns(b,p,d))

def PlacePeersKeeps(-b: Array<U32>, +p: U32, +q: U32, +fixed: BoardDigit, +d: BoardDigit) -> Type:
  PlacePeerRoutes(p,q) -> FixedClue(b,q,fixed) -> FixedClue(refresh_actual(place_boxes(b,p,d),p),q,fixed)

law place_peers_image:
  for +image: BoardImage
  for +p: U32
  for +q: U32
  for +fixed: BoardDigit
  for +d: BoardDigit
  PlacePeersKeeps(image_board(image),p,q,fixed,d)

law place_peers_keeps:
  for b: Array<U32>
  for +p: U32
  for +q: U32
  for +fixed: BoardDigit
  for +d: BoardDigit
  PlacePeersKeeps(b,p,q,fixed,d)

def PlaceClueKeeps(-b: Array<U32>, +guess: Bool, +p: U32, +q: U32, +fixed: BoardDigit, +d: BoardDigit) -> Type:
  RoutedApart(p,q) -> RoutedApart(flag_slot(p),q) -> PlacePeerRoutes(p,q) -> FixedClue(b,q,fixed) ->
  FixedClue(Q.place(guess,p,digit_word(d),b),q,fixed)

law place_keeps_clue_image:
  for +image: BoardImage
  for +guess: Bool
  for +p: U32
  for +q: U32
  for +fixed: BoardDigit
  for +d: BoardDigit
  PlaceClueKeeps(image_board(image),guess,p,q,fixed,d)

law queued_place_keeps_clue:
  for b: Array<U32>
  for +guess: Bool
  for +p: U32
  for +q: U32
  for +fixed: BoardDigit
  for +d: BoardDigit
  PlaceClueKeeps(b,guess,p,q,fixed,d)

def IsEqCmp(c: Cmp) -> Type:
  {c == EQ{} : Cmp}

law cmp_is_eq_sound:
  for +c: Cmp
  for yes: {Cmp.is_eq(c) == True{} : Bool}
  IsEqCmp(c)

law word_cmp_fin_head_tail:
  for +tail: Cmp
  for +a: Bool
  for +b: Bool
  for yes: {Word.cmp.fin(a,b,tail) == EQ{} : Cmp}
  ({a == b : Bool} & {tail == EQ{} : Cmp})

law word_cmp_fin_lift:
  for +n: Nat
  for +a: Bool
  for +b: Bool
  for +left: Word(n)
  for +right: Word(n)
  for pair: ({a == b : Bool} & {Word.cmp(n,left,right) == EQ{} : Cmp})
  for sub: ({Word.cmp(n,left,right) == EQ{} : Cmp} -> {left == right : Word(n)})
  {WCon{a,left} == WCon{b,right} : Word(1n+n)}

law word_cmp_equal:
  for +n: Nat
  for +a: Word(n)
  for +b: Word(n)
  for proof: {Word.cmp(n,a,b) == EQ{} : Cmp}
  {a == b : Word(n)}

law u32_equals_sound:
  for +a: U32
  for +b: U32
  for yes: {U32.is_eq(a,b) == True{} : Bool}
  {a == b : U32}

def route_matrix_entry(+i: U32, +j: U32) -> Bool:
  Bool.pick(Bool,U32.is_eq(i,j),Bool.not(regular_routes(i,j)),regular_routes(i,j))

law row_entry_first:
  for +tail: Nat
  for +i: U32
  for +j: U32
  for both: ({route_matrix_entry(i,j) == True{} : Bool} & {logical_row(tail,i,(j + 1 : U32)) == True{} : Bool})
  {route_matrix_entry(i,j) == True{} : Bool}

law row_entry_tail:
  for +before: Nat
  for +after: Nat
  for +i: U32
  for +start: U32
  for both: ({route_matrix_entry(i,start) == True{} : Bool} & {logical_row(with_center(before,after),i,(start + 1 : U32)) == True{} : Bool})
  for next: ({logical_row(with_center(before,after),i,(start + 1 : U32)) == True{} : Bool} ->
    {route_matrix_entry(i,walk_position(before,(start + 1 : U32))) == True{} : Bool})
  {route_matrix_entry(i,walk_position(1n+before,start)) == True{} : Bool}

law row_entry_at:
  for +before: Nat
  for +after: Nat
  for +i: U32
  for +start: U32
  for all: {logical_row(with_center(before,after),i,start) == True{} : Bool}
  {route_matrix_entry(i,walk_position(before,start)) == True{} : Bool}

law matrix_row_first:
  for +after: Nat
  for +i: U32
  for both: ({logical_row(81n,i,0) == True{} : Bool} & {logical_rows(after,(i + 1 : U32)) == True{} : Bool})
  {logical_row(81n,i,0) == True{} : Bool}

law matrix_row_tail:
  for +before: Nat
  for +after: Nat
  for +start: U32
  for both: ({logical_row(81n,start,0) == True{} : Bool} & {logical_rows(with_center(before,after),(start + 1 : U32)) == True{} : Bool})
  for next: ({logical_rows(with_center(before,after),(start + 1 : U32)) == True{} : Bool} ->
    {logical_row(81n,walk_position(before,(start + 1 : U32)),0) == True{} : Bool})
  {logical_row(81n,walk_position(1n+before,start),0) == True{} : Bool}

law matrix_row_at:
  for +before: Nat
  for +after: Nat
  for +start: U32
  for all: {logical_rows(with_center(before,after),start) == True{} : Bool}
  {logical_row(81n,walk_position(before,start),0) == True{} : Bool}

def column_tail(+col: CellCoordinate) -> Nat:
  Nat.sub(8n,coordinate_nat(col))

law column_count_nine:
  for +col: CellCoordinate
  {with_center(coordinate_nat(col),column_tail(col)) == 9n : Nat}

law matrix_row_checked:
  for +col: CellCoordinate
  for +start: U32
  for all: {logical_rows(9n,start) == True{} : Bool}
  {logical_row(81n,walk_position(coordinate_nat(col),start),0) == True{} : Bool}

def row_origin(+row: CellCoordinate) -> U32:
  walk_position(row_start(row),0)

law logical_origin:
  for +row: CellCoordinate
  for +col: CellCoordinate
  {walk_position(coordinate_nat(col),row_origin(row)) == logical_position(row,col) : U32}

law matrix_start_guard:
  for +row: CellCoordinate
  {logical_rows(9n,row_origin(row)) == True{} : Bool}

law matrix_logical_row:
  for +row: CellCoordinate
  for +col: CellCoordinate
  {logical_row(81n,logical_position(row,col),0) == True{} : Bool}

law matrix_logical_entry_checked:
  for +i: U32
  for +row: CellCoordinate
  for +col: CellCoordinate
  for all: {logical_row(81n,i,0) == True{} : Bool}
  for window: VerifiedWindow(logical_offset(row,col),logical_tail(row,col))
  {route_matrix_entry(i,logical_position(row,col)) == True{} : Bool}

law matrix_logical_entry:
  for +row1: CellCoordinate
  for +col1: CellCoordinate
  for +row2: CellCoordinate
  for +col2: CellCoordinate
  {route_matrix_entry(logical_position(row1,col1),logical_position(row2,col2)) == True{} : Bool}

def FlagSlot(+p: U32) -> Type:
  Either<&1,&1,{flag_slot(p) == 109 : U32},
    Either<&1,&1,{flag_slot(p) == 110 : U32},{flag_slot(p) == 111 : U32}>>

def LogicalRouteFacts(+p: U32) -> Type:
  ({normalized_route(p) == p : U32} & FlagSlot(p)
   & RoutedApart(108,p) & RoutedApart(109,p) & RoutedApart(110,p) & RoutedApart(111,p))

law logical_address_row_0:
  for +col: CellCoordinate
  LogicalRouteFacts(logical_position(Coordinate0{},col))

law logical_address_row_1:
  for +col: CellCoordinate
  LogicalRouteFacts(logical_position(Coordinate1{},col))

law logical_address_row_2:
  for +col: CellCoordinate
  LogicalRouteFacts(logical_position(Coordinate2{},col))

law logical_address_row_3:
  for +col: CellCoordinate
  LogicalRouteFacts(logical_position(Coordinate3{},col))

law logical_address_row_4:
  for +col: CellCoordinate
  LogicalRouteFacts(logical_position(Coordinate4{},col))

law logical_address_row_5:
  for +col: CellCoordinate
  LogicalRouteFacts(logical_position(Coordinate5{},col))

law logical_address_row_6:
  for +col: CellCoordinate
  LogicalRouteFacts(logical_position(Coordinate6{},col))

law logical_address_row_7:
  for +col: CellCoordinate
  LogicalRouteFacts(logical_position(Coordinate7{},col))

law logical_address_row_8:
  for +col: CellCoordinate
  LogicalRouteFacts(logical_position(Coordinate8{},col))

law logical_address_facts:
  for +row: CellCoordinate
  for +col: CellCoordinate
  LogicalRouteFacts(logical_position(row,col))


law route_for_flag_choice:
  for +p: U32
  for +q: U32
  for fact: FlagSlot(p)
  for a: RoutedApart(109,q)
  for b: RoutedApart(110,q)
  for c: RoutedApart(111,q)
  RoutedApart(flag_slot(p),q)

law flag_slot_peer_route:
  for +p: U32
  for +q: U32
  for facts: LogicalRouteFacts(q)
  for slot: FlagSlot(p)
  RoutedApart(flag_slot(p),q)

law extract_logical_flag_slot:
  for +p: U32
  for facts: LogicalRouteFacts(p)
  FlagSlot(p)

law any_logical_flag_route:
  for +row1: CellCoordinate
  for +col1: CellCoordinate
  for +row2: CellCoordinate
  for +col2: CellCoordinate
  RoutedApart(flag_slot(logical_position(row1,col1)),logical_position(row2,col2))

law apart_from_raw:
  for +p: U32
  for +q: U32
  for p_norm: {normalized_route(p) == p : U32}
  for q_norm: {normalized_route(q) == q : U32}
  for good: {regular_routes(p,q) == True{} : Bool}
  RoutedApart(p,q)

law apart_from_logical_facts:
  for +p: U32
  for +q: U32
  for pf: LogicalRouteFacts(p)
  for qf: LogicalRouteFacts(q)
  for good: {regular_routes(p,q) == True{} : Bool}
  RoutedApart(p,q)

law pair_route_decide:
  for +p: U32
  for +q: U32
  for +same: Bool
  for equality: {U32.is_eq(p,q) == same : Bool}
  for check: {Bool.pick(Bool,same,Bool.not(regular_routes(p,q)),regular_routes(p,q)) == True{} : Bool}
  for apart: ({regular_routes(p,q) == True{} : Bool} -> RoutedApart(p,q))
  for flag: RoutedApart(flag_slot(p),q)
  PeerRoute(p,q)

law pair_route_checked:
  for +p: U32
  for +q: U32
  for check: {route_matrix_entry(p,q) == True{} : Bool}
  for apart: ({regular_routes(p,q) == True{} : Bool} -> RoutedApart(p,q))
  for flag: RoutedApart(flag_slot(p),q)
  PeerRoute(p,q)

law logical_pair_peer_route:
  for +row1: CellCoordinate
  for +col1: CellCoordinate
  for +row2: CellCoordinate
  for +col2: CellCoordinate
  PeerRoute(logical_position(row1,col1),logical_position(row2,col2))

def coord_u32(+coord: CellCoordinate) -> U32:
  walk_position(coordinate_nat(coord),0)

law row_routes_from_coordinates:
  for +source: CellCoordinate
  for +watched_row: CellCoordinate
  for +watched_col: CellCoordinate
  RowClueRoutes(9n,0,row_origin(source),logical_position(watched_row,watched_col))

law column_routes_from_coordinates:
  for +source: CellCoordinate
  for +watched_row: CellCoordinate
  for +watched_col: CellCoordinate
  ColumnClueRoutes(9n,0,coord_u32(source),logical_position(watched_row,watched_col))

def PlaceGeometry(+row: CellCoordinate, +col: CellCoordinate) -> Type:
  ({place_row_base(logical_position(row,col)) == row_origin(row) : U32}
   & {M.rem9(logical_position(row,col)) == coord_u32(col) : U32})

law source_place_geometry:
  for +row: CellCoordinate
  for +col: CellCoordinate
  PlaceGeometry(row,col)

def placed_box_positions(+p: U32) -> List<&2,U32>:
  box_positions(place_box_base(p),place_box_r1(p),place_box_r2(p),place_box_c1(p),place_box_c2(p))

law box_routes_from_coordinates:
  for +source_row: CellCoordinate
  for +source_col: CellCoordinate
  for +watched_row: CellCoordinate
  for +watched_col: CellCoordinate
  PeerListRoutes(placed_box_positions(logical_position(source_row,source_col)),logical_position(watched_row,watched_col))

law pointer_route_from_logical:
  for +p: U32
  for facts: LogicalRouteFacts(p)
  RoutedApart(108,p)

law placement_routes_from_geometry:
  for +source_row: CellCoordinate
  for +source_col: CellCoordinate
  for +watched_row: CellCoordinate
  for +watched_col: CellCoordinate
  for geometry: PlaceGeometry(source_row,source_col)
  PlacePeerRoutes(logical_position(source_row,source_col),logical_position(watched_row,watched_col))

law placement_routes_from_coordinates:
  for +source_row: CellCoordinate
  for +source_col: CellCoordinate
  for +watched_row: CellCoordinate
  for +watched_col: CellCoordinate
  PlacePeerRoutes(logical_position(source_row,source_col),logical_position(watched_row,watched_col))

law logical_distinct_apart:
  for +p: U32
  for +q: U32
  for distinct: {U32.is_eq(p,q) == False{} : Bool}
  for checked: {route_matrix_entry(p,q) == True{} : Bool}
  for pf: LogicalRouteFacts(p)
  for qf: LogicalRouteFacts(q)
  RoutedApart(p,q)

law logical_placement_keeps_other_clue:
  for b: Array<U32>
  for +guess: Bool
  for +source_row: CellCoordinate
  for +source_col: CellCoordinate
  for +watched_row: CellCoordinate
  for +watched_col: CellCoordinate
  for +fixed: BoardDigit
  for +digit: BoardDigit
  for distinct: {U32.is_eq(logical_position(source_row,source_col),logical_position(watched_row,watched_col)) == False{} : Bool}
  for state: FixedClue(b,logical_position(watched_row,watched_col),fixed)
  FixedClue(Q.place(guess,logical_position(source_row,source_col),digit_word(digit),b),logical_position(watched_row,watched_col),fixed)

def searching_word(state: Fast.State, +p: U32) -> U32:
  match state:
    case Fast.Searching{board,frames,depth,found,snapshots,active}:
      cell_value(board,p)
    case _:
      0

law fixed_clue_word:
  for -b: Array<U32>
  for +p: U32
  for +d: BoardDigit
  for inherited: FixedClue(b,p,d)
  {cell_value(b,p) == fixed_word(d) : U32}

law adaptive_active_forced_place_keeps_clue:
  for b: Array<U32>
  for frames: Array<U32>
  for +depth: U32
  for +found: U32
  for snapshots: List<&1,Array<U32>>
  for +sr: CellCoordinate
  for +sc: CellCoordinate
  for +qr: CellCoordinate
  for +qc: CellCoordinate
  for +fixed: BoardDigit
  for +digit: BoardDigit
  for distinct: {U32.is_eq(logical_position(sr,sc),logical_position(qr,qc)) == False{} : Bool}
  for state: FixedClue(b,logical_position(qr,qc),fixed)
  {searching_word(Fast.place(False{},logical_position(sr,sc),digit_word(digit),0,frames,depth,found,snapshots,True{},b),logical_position(qr,qc)) == fixed_word(fixed) : U32}

def PlainWord(-b: Array<U32>, +q: U32, +v: U32) -> Type:
  (Board128(b) & {cell_value(b,q) == v : U32})

def OneWrite(-b: Array<U32>, -out: Array<U32>, +slot: U32) -> Type:
  Sigma<&2,&1,U32,value => {out == B.set_cell(b,slot,value) : Array<U32>}>

law plain_write_step:
  for +image: BoardImage
  for +p: U32
  for +value: U32
  for +q: U32
  for +clue: U32
  for apart: RoutedApart(p,q)
  for shapes: (Board128(image_board(image)) & Board128(image_board(image)))
  for known: {cell_value(image_board(image),q) == clue : U32}
  PlainWord(B.set_cell(image_board(image),p,value),q,clue)

law plain_write_image:
  for +image: BoardImage
  for +p: U32
  for +value: U32
  for +q: U32
  for +clue: U32
  for apart: RoutedApart(p,q)
  for state: PlainWord(image_board(image),q,clue)
  PlainWord(B.set_cell(image_board(image),p,value),q,clue)

law plain_write:
  for b: Array<U32>
  for +p: U32
  for +value: U32
  for +q: U32
  for +clue: U32
  for apart: RoutedApart(p,q)
  for state: PlainWord(b,q,clue)
  PlainWord(B.set_cell(b,p,value),q,clue)

law plain_one_write:
  for b: Array<U32>
  for -out: Array<U32>
  for +slot: U32
  for +q: U32
  for +clue: U32
  for apart: RoutedApart(slot,q)
  for state: PlainWord(b,q,clue)
  for write: OneWrite(b,out,slot)
  PlainWord(out,q,clue)

def ordinary_unit_word(+old: U32, +value: U32, +used: U32) -> U32:
  U32.or(U32.and(used,U32.not(B.bit(old))),B.bit(value))

def ordinary_row_word(+old: U32, +value: U32, +empty: U32, +used: U32) -> U32:
  +next = U32.or(U32.and(used,U32.not(U32.and(B.bit(old),1023))),U32.and(B.bit(value),1023))
  Bool.pick(U32,U32.is_eq(value,0),U32.or(next,empty),U32.and(next,U32.not(empty)))

law ordinary_unit_single_from_read:
  for -b: Array<U32>
  for +slot: U32
  for +old: U32
  for +value: U32
  for -same: Array<U32>
  for +used: U32
  for kept: {same == b : Array<U32>}
  for actual: {B.get_cell(b,slot) == (same,used) : Array<U32> & U32}
  OneWrite(b,C.update_unit(slot,old,value,b),slot)

law ordinary_unit_single:
  for -b: Array<U32>
  for +slot: U32
  for +old: U32
  for +value: U32
  for read: BoardReadWitness(b,slot)
  OneWrite(b,C.update_unit(slot,old,value,b),slot)

def ordinary_row_slot(+p: U32) -> U32:
  (81 + M.div9(p) : U32)

def ordinary_empty_bit(+p: U32) -> U32:
  B.bit((10 + M.rem9(p) : U32))

law ordinary_row_single_from_read:
  for -b: Array<U32>
  for +p: U32
  for +old: U32
  for +value: U32
  for -same: Array<U32>
  for +used: U32
  for kept: {same == b : Array<U32>}
  for actual: {B.get_cell(b,ordinary_row_slot(p)) == (same,used) : Array<U32> & U32}
  OneWrite(b,C.update_row(p,old,value,b),ordinary_row_slot(p))

law ordinary_row_single:
  for -b: Array<U32>
  for +p: U32
  for +old: U32
  for +value: U32
  for read: BoardReadWitness(b,ordinary_row_slot(p))
  OneWrite(b,C.update_row(p,old,value,b),ordinary_row_slot(p))

def MetaUpdatesKeeps(-b: Array<U32>, -out: Array<U32>, +slot: U32, +q: U32, +clue: U32) -> Type:
  RoutedApart(slot,q) -> PlainWord(b,q,clue) -> PlainWord(out,q,clue)

law ordinary_unit_keeps_image:
  for +image: BoardImage
  for +slot: U32
  for +old: U32
  for +value: U32
  for +q: U32
  for +clue: U32
  MetaUpdatesKeeps(image_board(image),C.update_unit(slot,old,value,image_board(image)),slot,q,clue)

law ordinary_unit_keeps:
  for b: Array<U32>
  for +slot: U32
  for +old: U32
  for +value: U32
  for +q: U32
  for +clue: U32
  MetaUpdatesKeeps(b,C.update_unit(slot,old,value,b),slot,q,clue)

law ordinary_row_keeps_image:
  for +image: BoardImage
  for +p: U32
  for +old: U32
  for +value: U32
  for +q: U32
  for +clue: U32
  MetaUpdatesKeeps(image_board(image),C.update_row(p,old,value,image_board(image)),ordinary_row_slot(p),q,clue)

law ordinary_row_keeps:
  for b: Array<U32>
  for +p: U32
  for +old: U32
  for +value: U32
  for +q: U32
  for +clue: U32
  MetaUpdatesKeeps(b,C.update_row(p,old,value,b),ordinary_row_slot(p),q,clue)

def PlainPointerTail(+n: Nat, +p: U32) -> Type:
  @b:Array<U32> -> @word:U32 -> FirstOnlyWritesPointer(b,C.first_empty(n,p,(b,word)))

law plain_first_observed:
  for +n: Nat
  for +p: U32
  for -b: Array<U32>
  for same: Array<U32>
  for +word: U32
  for kept: {same == b : Array<U32>}
  for observed: {B.get_cell(b,p) == (same,word) : Array<U32> & U32}
  for next: PlainPointerTail(n,p)
  FirstOnlyWritesPointer(b,C.first_empty(n,p,B.get_cell(b,p)))

law plain_first_from_read:
  for +n: Nat
  for +p: U32
  for -b: Array<U32>
  for read: BoardReadWitness(b,p)
  for next: PlainPointerTail(n,p)
  FirstOnlyWritesPointer(b,C.first_empty(n,p,B.get_cell(b,p)))

law plain_first_branch:
  for +word: U32
  for +n: Nat
  for +p: U32
  for -b: Array<U32>
  for later: FirstOnlyWritesPointer(b,C.first_empty(n,(p + 1 : U32),B.get_cell(b,(p + 1 : U32))))
  FirstOnlyWritesPointer(b,C.first_empty(1n+n,p,(b,word)))

law plain_first_live:
  for +n: Nat
  for +p: U32
  for b: Array<U32>
  for +word: U32
  for next: PlainPointerTail(n,(p + 1 : U32))
  FirstOnlyWritesPointer(b,C.first_empty(1n+n,p,(b,word)))

law plain_first_pointer:
  for +n: Nat
  for +p: U32
  PlainPointerTail(n,p)

law ordinary_refresh_pointer:
  for b: Array<U32>
  for +p: U32
  FirstOnlyWritesPointer(b,C.refresh_start(b,p))

law plain_pointer_keeps:
  for b: Array<U32>
  for -out: Array<U32>
  for +q: U32
  for +clue: U32
  for apart: RoutedApart(108,q)
  for state: PlainWord(b,q,clue)
  for write: FirstOnlyWritesPointer(b,out)
  PlainWord(out,q,clue)

def OrdinaryRefreshKeeps(-b: Array<U32>, +which: Bool, +p: U32, +q: U32, +clue: U32) -> Type:
  RoutedApart(108,q) -> PlainWord(b,q,clue) -> PlainWord(C.refresh_if(which,b,p),q,clue)

law ordinary_refresh_keeps_image:
  for +image: BoardImage
  for +which: Bool
  for +p: U32
  for +q: U32
  for +clue: U32
  OrdinaryRefreshKeeps(image_board(image),which,p,q,clue)

law ordinary_refresh_keeps:
  for b: Array<U32>
  for +which: Bool
  for +p: U32
  for +q: U32
  for +clue: U32
  OrdinaryRefreshKeeps(b,which,p,q,clue)

law ordinary_start_pair_keeps:
  for +blank: Bool
  for b: Array<U32>
  for +p: U32
  for +start: U32
  for +q: U32
  for +clue: U32
  for apart: RoutedApart(108,q)
  for state: PlainWord(b,q,clue)
  PlainWord(C.start_after_set(blank,p,(b,start)),q,clue)

law ordinary_start_keeps_observed:
  for +blank: Bool
  for b: Array<U32>
  for +p: U32
  for +q: U32
  for +clue: U32
  for -same: Array<U32>
  for +start: U32
  for kept: {same == b : Array<U32>}
  for read: {B.get_cell(b,108) == (same,start) : Array<U32> & U32}
  for apart: RoutedApart(108,q)
  for state: PlainWord(b,q,clue)
  PlainWord(C.start_after_set(blank,p,B.get_cell(b,108)),q,clue)

law ordinary_start_keeps_read:
  for +blank: Bool
  for b: Array<U32>
  for +p: U32
  for +q: U32
  for +clue: U32
  for read: BoardReadWitness(b,108)
  for apart: RoutedApart(108,q)
  for state: PlainWord(b,q,clue)
  PlainWord(C.start_after_set(blank,p,B.get_cell(b,108)),q,clue)

def PlainStartKeeps(-b: Array<U32>, +blank: Bool, +p: U32, +q: U32, +clue: U32) -> Type:
  RoutedApart(108,q) -> PlainWord(b,q,clue) ->
  PlainWord(C.start_after_set(blank,p,B.get_cell(b,108)),q,clue)

law ordinary_start_keeps_image:
  for +image: BoardImage
  for +blank: Bool
  for +p: U32
  for +q: U32
  for +clue: U32
  PlainStartKeeps(image_board(image),blank,p,q,clue)

law ordinary_start_keeps:
  for b: Array<U32>
  for +blank: Bool
  for +p: U32
  for +q: U32
  for +clue: U32
  PlainStartKeeps(b,blank,p,q,clue)

def ordinary_col_slot(+p: U32) -> U32:
  (90 + M.rem9(p) : U32)

def ordinary_box_slot(+p: U32) -> U32:
  (99 + B.box_of(p) : U32)

def OrdinaryMetaRoutes(+p: U32, +q: U32) -> Type:
  (RoutedApart(ordinary_row_slot(p),q) & RoutedApart(ordinary_col_slot(p),q)
    & RoutedApart(ordinary_box_slot(p),q) & RoutedApart(108,q))

def ordinary_from_row(b: Array<U32>, +p: U32, +old: U32, +value: U32) -> Array<U32>:
  C.update_row(p,old,value,b)

def ordinary_from_col(b: Array<U32>, +p: U32, +old: U32, +value: U32) -> Array<U32>:
  C.update_unit(ordinary_col_slot(p),old,value,ordinary_from_row(b,p,old,value))

def ordinary_from_box(b: Array<U32>, +p: U32, +old: U32, +value: U32) -> Array<U32>:
  C.update_unit(ordinary_box_slot(p),old,value,ordinary_from_col(b,p,old,value))

def ordinary_after_write(b: Array<U32>, +p: U32, +old: U32, +value: U32) -> Array<U32>:
  Pair.fst(Array<U32>,U32,C.swapped(p,value,(b,old)))

def OrdinaryAfterWriteKeeps(-b: Array<U32>, +p: U32, +old: U32, +value: U32, +q: U32, +clue: U32) -> Type:
  OrdinaryMetaRoutes(p,q) -> PlainWord(b,q,clue) ->
  PlainWord(ordinary_after_write(b,p,old,value),q,clue)

law ordinary_after_write_image:
  for +image: BoardImage
  for +p: U32
  for +old: U32
  for +value: U32
  for +q: U32
  for +clue: U32
  OrdinaryAfterWriteKeeps(image_board(image),p,old,value,q,clue)

law ordinary_after_write_keeps:
  for b: Array<U32>
  for +p: U32
  for +old: U32
  for +value: U32
  for +q: U32
  for +clue: U32
  OrdinaryAfterWriteKeeps(b,p,old,value,q,clue)

law ordinary_swapped_keeps:
  for +p: U32
  for +value: U32
  for +q: U32
  for +clue: U32
  for edited: (Array<U32> & U32)
  for routes: OrdinaryMetaRoutes(p,q)
  for state: PlainWord(Pair.fst(Array<U32>,U32,edited),q,clue)
  PlainWord(Pair.fst(Array<U32>,U32,C.swapped(p,value,edited)),q,clue)

def swap_board_out(b: Array<U32>, +p: U32, +value: U32) -> Array<U32>:
  Pair.fst(Array<U32>,U32,C.swap(b,p,value))

def OrdinarySwapKeeps(-b: Array<U32>, +p: U32, +value: U32, +q: U32, +clue: U32) -> Type:
  RoutedApart(p,q) -> OrdinaryMetaRoutes(p,q) -> PlainWord(b,q,clue) ->
  PlainWord(swap_board_out(b,p,value),q,clue)

law swap_pair_first_is_set_fin:
  for r: (Array<U32> & U32)
  {Pair.fst(Array<U32>,U32,r) == Array.set.fin(U32,r) : Array<U32>}

law use_swap_pair_first:
  for -r: (Array<U32> & U32)
  for +q: U32
  for +clue: U32
  for eq: {Pair.fst(Array<U32>,U32,r) == Array.set.fin(U32,r) : Array<U32>}
  for settled: PlainWord(Array.set.fin(U32,r),q,clue)
  PlainWord(Pair.fst(Array<U32>,U32,r),q,clue)

law ordinary_swap_keeps_image:
  for +image: BoardImage
  for +p: U32
  for +value: U32
  for +q: U32
  for +clue: U32
  OrdinarySwapKeeps(image_board(image),p,value,q,clue)

law ordinary_swap_keeps:
  for b: Array<U32>
  for +p: U32
  for +value: U32
  for +q: U32
  for +clue: U32
  OrdinarySwapKeeps(b,p,value,q,clue)

type CacheGroup is Data:
  CacheRows{}
  CacheColumns{}
  CacheBoxes{}

def cache_group_base(+group: CacheGroup) -> U32:
  match group:
    case CacheRows{}:
      81
    case CacheColumns{}:
      90
    case CacheBoxes{}:
      99

def cache_group_slot(+group: CacheGroup, +ordinal: CellCoordinate) -> U32:
  walk_position(coordinate_nat(ordinal),cache_group_base(group))

def meta_guard(+n: Nat, +p: U32, +q: U32) -> Bool:
  match n:
    case 0n:
      True{}
    case 1n+k:
      Bool.and(apart_guard(p,q),meta_guard(k,(p + 1 : U32),q))

law meta_guard_first:
  for +n: Nat
  for +p: U32
  for +q: U32
  for both: (RoutedApart(p,q) & {meta_guard(n,(p + 1 : U32),q) == True{} : Bool})
  RoutedApart(p,q)

law meta_guard_tail:
  for +before: Nat
  for +after: Nat
  for +p: U32
  for +q: U32
  for both: (RoutedApart(p,q) & {meta_guard(with_center(before,after),(p + 1 : U32),q) == True{} : Bool})
  for next: ({meta_guard(with_center(before,after),(p + 1 : U32),q) == True{} : Bool} ->
    RoutedApart(walk_position(before,(p + 1 : U32)),q))
  RoutedApart(walk_position(1n+before,p),q)

law meta_guard_at:
  for +before: Nat
  for +after: Nat
  for +p: U32
  for +q: U32
  for guard: {meta_guard(with_center(before,after),p,q) == True{} : Bool}
  RoutedApart(walk_position(before,p),q)

law cache_meta_at:
  for +group: CacheGroup
  for +index: CellCoordinate
  for +q: U32
  for guard: {meta_guard(9n,cache_group_base(group),q) == True{} : Bool}
  RoutedApart(cache_group_slot(group,index),q)

def CacheMetaFacts(+q: U32) -> Type:
  ({meta_guard(9n,81,q) == True{} : Bool} & {meta_guard(9n,90,q) == True{} : Bool} & {meta_guard(9n,99,q) == True{} : Bool})

law cache_meta_facts_row_0:
  for +col: CellCoordinate
  CacheMetaFacts(logical_position(Coordinate0{},col))

law cache_meta_facts_row_1:
  for +col: CellCoordinate
  CacheMetaFacts(logical_position(Coordinate1{},col))

law cache_meta_facts_row_2:
  for +col: CellCoordinate
  CacheMetaFacts(logical_position(Coordinate2{},col))

law cache_meta_facts_row_3:
  for +col: CellCoordinate
  CacheMetaFacts(logical_position(Coordinate3{},col))

law cache_meta_facts_row_4:
  for +col: CellCoordinate
  CacheMetaFacts(logical_position(Coordinate4{},col))

law cache_meta_facts_row_5:
  for +col: CellCoordinate
  CacheMetaFacts(logical_position(Coordinate5{},col))

law cache_meta_facts_row_6:
  for +col: CellCoordinate
  CacheMetaFacts(logical_position(Coordinate6{},col))

law cache_meta_facts_row_7:
  for +col: CellCoordinate
  CacheMetaFacts(logical_position(Coordinate7{},col))

law cache_meta_facts_row_8:
  for +col: CellCoordinate
  CacheMetaFacts(logical_position(Coordinate8{},col))

law cache_meta_facts:
  for +row: CellCoordinate
  for +col: CellCoordinate
  CacheMetaFacts(logical_position(row,col))

type CacheBand is Data:
  CacheBand0{}
  CacheBand1{}
  CacheBand2{}

def cache_band(+coord: CellCoordinate) -> CacheBand:
  match coord:
    case Coordinate0{}:
      CacheBand0{}
    case Coordinate1{}:
      CacheBand0{}
    case Coordinate2{}:
      CacheBand0{}
    case Coordinate3{}:
      CacheBand1{}
    case Coordinate4{}:
      CacheBand1{}
    case Coordinate5{}:
      CacheBand1{}
    case Coordinate6{}:
      CacheBand2{}
    case Coordinate7{}:
      CacheBand2{}
    case Coordinate8{}:
      CacheBand2{}

def cache_box_coordinate(+row: CacheBand, +col: CacheBand) -> CellCoordinate:
  match row col:
    case CacheBand0{} CacheBand0{}:
      Coordinate0{}
    case CacheBand0{} CacheBand1{}:
      Coordinate1{}
    case CacheBand0{} CacheBand2{}:
      Coordinate2{}
    case CacheBand1{} CacheBand0{}:
      Coordinate3{}
    case CacheBand1{} CacheBand1{}:
      Coordinate4{}
    case CacheBand1{} CacheBand2{}:
      Coordinate5{}
    case CacheBand2{} CacheBand0{}:
      Coordinate6{}
    case CacheBand2{} CacheBand1{}:
      Coordinate7{}
    case CacheBand2{} CacheBand2{}:
      Coordinate8{}

def box_coordinate(+row: CellCoordinate, +col: CellCoordinate) -> CellCoordinate:
  cache_box_coordinate(cache_band(row),cache_band(col))

def OrdinaryGeometry(+row: CellCoordinate, +col: CellCoordinate) -> Type:
  ({ordinary_row_slot(logical_position(row,col)) == cache_group_slot(CacheRows{},row) : U32}
   & {ordinary_col_slot(logical_position(row,col)) == cache_group_slot(CacheColumns{},col) : U32}
   & {ordinary_box_slot(logical_position(row,col)) == cache_group_slot(CacheBoxes{},box_coordinate(row,col)) : U32})

law checked_ordinary_geometry:
  for +row: CellCoordinate
  for +col: CellCoordinate
  OrdinaryGeometry(row,col)

law ordinary_routes_from_geometry:
  for +sr: CellCoordinate
  for +sc: CellCoordinate
  for +qr: CellCoordinate
  for +qc: CellCoordinate
  for geometry: OrdinaryGeometry(sr,sc)
  for facts: CacheMetaFacts(logical_position(qr,qc))
  OrdinaryMetaRoutes(logical_position(sr,sc),logical_position(qr,qc))

law ordinary_routes_from_coordinates:
  for +sr: CellCoordinate
  for +sc: CellCoordinate
  for +qr: CellCoordinate
  for +qc: CellCoordinate
  OrdinaryMetaRoutes(logical_position(sr,sc),logical_position(qr,qc))

law logical_ordinary_swap_keeps_clue:
  for b: Array<U32>
  for +sr: CellCoordinate
  for +sc: CellCoordinate
  for +qr: CellCoordinate
  for +qc: CellCoordinate
  for +value: U32
  for +clue: U32
  for distinct: {U32.is_eq(logical_position(sr,sc),logical_position(qr,qc)) == False{} : Bool}
  for state: PlainWord(b,logical_position(qr,qc),clue)
  PlainWord(swap_board_out(b,logical_position(sr,sc),value),logical_position(qr,qc),clue)

law inactive_clear_keeps_clue:
  for b: Array<U32>
  for +sr: CellCoordinate
  for +sc: CellCoordinate
  for +qr: CellCoordinate
  for +qc: CellCoordinate
  for +clue: U32
  for distinct: {U32.is_eq(logical_position(sr,sc),logical_position(qr,qc)) == False{} : Bool}
  for state: PlainWord(b,logical_position(qr,qc),clue)
  PlainWord(Fast.cleared(False{},b,logical_position(sr,sc)),logical_position(qr,qc),clue)

law inactive_swap_keeps_clue:
  for b: Array<U32>
  for +sr: CellCoordinate
  for +sc: CellCoordinate
  for +qr: CellCoordinate
  for +qc: CellCoordinate
  for +value: U32
  for +clue: U32
  for distinct: {U32.is_eq(logical_position(sr,sc),logical_position(qr,qc)) == False{} : Bool}
  for state: PlainWord(b,logical_position(qr,qc),clue)
  PlainWord(Pair.fst(Array<U32>,U32,Fast.swapped(False{},b,logical_position(sr,sc),value)),logical_position(qr,qc),clue)

# The saved pre-choice board and the live post-choice board are distinct
# observations of the actual adaptive search transition.
def first_snapshot_word(snapshots: List<&1,Array<U32>>, +q: U32) -> U32:
  match snapshots:
    case saved <> tail:
      cell_value(saved,q)
    case Nil{}:
      0

def searching_snapshot_word(state: Fast.State, +q: U32) -> U32:
  match state:
    case Fast.Searching{board,frames,depth,found,snapshots,active}:
      first_snapshot_word(snapshots,q)
    case _:
      0

law adaptive_guess_snapshot_word:
  for b: Array<U32>
  for frames: Array<U32>
  for +depth: U32
  for +found: U32
  for snapshots: List<&1,Array<U32>>
  for +p: U32
  for +q: U32
  for +digit: U32
  for +remaining: U32
  for +active: Bool
  {searching_snapshot_word(Fast.place(True{},p,digit,remaining,frames,depth,found,snapshots,active,b),q)
    == cell_value(Fast.activated(active,b),q) : U32}

law adaptive_active_guess_keeps_clue_image:
  for +image: BoardImage
  for frames: Array<U32>
  for +depth: U32
  for +found: U32
  for snapshots: List<&1,Array<U32>>
  for +sr: CellCoordinate
  for +sc: CellCoordinate
  for +qr: CellCoordinate
  for +qc: CellCoordinate
  for +fixed: BoardDigit
  for +digit: BoardDigit
  for +remaining: U32
  for distinct: {U32.is_eq(logical_position(sr,sc),logical_position(qr,qc)) == False{} : Bool}
  for state: FixedClue(image_board(image),logical_position(qr,qc),fixed)
  {searching_word(Fast.place(True{},logical_position(sr,sc),digit_word(digit),remaining,frames,depth,found,snapshots,True{},image_board(image)),logical_position(qr,qc)) == fixed_word(fixed) : U32}

law adaptive_active_guess_keeps_clue:
  for b: Array<U32>
  for frames: Array<U32>
  for +depth: U32
  for +found: U32
  for snapshots: List<&1,Array<U32>>
  for +sr: CellCoordinate
  for +sc: CellCoordinate
  for +qr: CellCoordinate
  for +qc: CellCoordinate
  for +fixed: BoardDigit
  for +digit: BoardDigit
  for +remaining: U32
  for distinct: {U32.is_eq(logical_position(sr,sc),logical_position(qr,qc)) == False{} : Bool}
  for state: FixedClue(b,logical_position(qr,qc),fixed)
  {searching_word(Fast.place(True{},logical_position(sr,sc),digit_word(digit),remaining,frames,depth,found,snapshots,True{},b),logical_position(qr,qc)) == fixed_word(fixed) : U32}

law adaptive_active_guess_snapshot_keeps_clue_image:
  for +image: BoardImage
  for frames: Array<U32>
  for +depth: U32
  for +found: U32
  for snapshots: List<&1,Array<U32>>
  for +p: U32
  for +q: U32
  for +fixed: BoardDigit
  for +digit: U32
  for +remaining: U32
  for state: FixedClue(image_board(image),q,fixed)
  {searching_snapshot_word(Fast.place(True{},p,digit,remaining,frames,depth,found,snapshots,True{},image_board(image)),q)
    == fixed_word(fixed) : U32}

law adaptive_active_guess_snapshot_keeps_clue:
  for b: Array<U32>
  for frames: Array<U32>
  for +depth: U32
  for +found: U32
  for snapshots: List<&1,Array<U32>>
  for +p: U32
  for +q: U32
  for +fixed: BoardDigit
  for +digit: U32
  for +remaining: U32
  for state: FixedClue(b,q,fixed)
  {searching_snapshot_word(Fast.place(True{},p,digit,remaining,frames,depth,found,snapshots,True{},b),q)
    == fixed_word(fixed) : U32}

def Nonblank(+d: BoardDigit) -> Type:
  {U32.is_eq(digit_word(d),0) == False{} : Bool}

law encoded_nonblank_word:
  for +d: BoardDigit
  for b: Array<U32>
  for +p: U32
  for nonblank: Nonblank(d)
  {cell_value(Q.encoded(p,(b,digit_word(d))),p) == fixed_word(d) : U32}

law actual_encode_nonblank_word:
  for +image: BoardImage
  for +p: U32
  for +d: BoardDigit
  for nonblank: Nonblank(d)
  for word_is: {cell_value(image_board(image),p) == digit_word(d) : U32}
  {cell_value(actual_encoded_step(image_board(image),p),p) == fixed_word(d) : U32}

def EncodeMiddleRaw(-b: Array<U32>, +prefix: Nat, +suffix: Nat, +p: U32, +d: BoardDigit) -> Type:
  Board128(b) ->
  EncodeApart(prefix,p,walk_position(prefix,p)) ->
  RoutedApart(flag_slot(walk_position(prefix,p)),walk_position(prefix,p)) ->
  EncodeApart(suffix,(walk_position(prefix,p) + 1 : U32),walk_position(prefix,p)) ->
  Nonblank(d) ->
  {cell_value(b,walk_position(prefix,p)) == digit_word(d) : U32} ->
  {cell_value(Q.encode_go(with_center(prefix,suffix),p,b),walk_position(prefix,p)) == fixed_word(d) : U32}

def EncodeMiddleRawProof(+prefix: Nat, +suffix: Nat, +p: U32, +d: BoardDigit) -> Type:
  @b:Array<U32> -> EncodeMiddleRaw(b,prefix,suffix,p,d)

law encode_raw_middle_base_image:
  for +image: BoardImage
  for +suffix: Nat
  for +p: U32
  for +d: BoardDigit
  for shapes: (Board128(image_board(image)) & Board128(image_board(image)))
  for safe: RoutedApart(flag_slot(p),p)
  for tail: EncodeApart(suffix,(p + 1 : U32),p)
  for nonblank: Nonblank(d)
  for digit: {cell_value(image_board(image),p) == digit_word(d) : U32}
  {cell_value(Q.encode_go(1n+suffix,p,image_board(image)),p) == fixed_word(d) : U32}

law encode_raw_middle_base:
  for +image: BoardImage
  for +suffix: Nat
  for +p: U32
  for +d: BoardDigit
  EncodeMiddleRaw(image_board(image),0n,suffix,p,d)

law encode_raw_middle_step_image:
  for +image: BoardImage
  for +k: Nat
  for +suffix: Nat
  for +p: U32
  for +d: BoardDigit
  for shapes: (Board128(image_board(image)) & Board128(image_board(image)))
  for before: EncodeApart(1n+k,p,walk_position(1n+k,p))
  for safe: RoutedApart(flag_slot(walk_position(1n+k,p)),walk_position(1n+k,p))
  for after: EncodeApart(suffix,(walk_position(1n+k,p) + 1 : U32),walk_position(1n+k,p))
  for nonblank: Nonblank(d)
  for digit: {cell_value(image_board(image),walk_position(1n+k,p)) == digit_word(d) : U32}
  for next: EncodeMiddleRawProof(k,suffix,(p + 1 : U32),d)
  {cell_value(Q.encode_go(with_center(1n+k,suffix),p,image_board(image)),walk_position(1n+k,p)) == fixed_word(d) : U32}

law encode_raw_middle_step:
  for +image: BoardImage
  for +k: Nat
  for +suffix: Nat
  for +p: U32
  for +d: BoardDigit
  for next: EncodeMiddleRawProof(k,suffix,(p + 1 : U32),d)
  EncodeMiddleRaw(image_board(image),1n+k,suffix,p,d)

law encode_raw_middle_from_image:
  for +prefix: Nat
  for +image: BoardImage
  for +suffix: Nat
  for +p: U32
  for +d: BoardDigit
  EncodeMiddleRaw(image_board(image),prefix,suffix,p,d)

law encode_raw_middle_value:
  for b: Array<U32>
  for +prefix: Nat
  for +suffix: Nat
  for +p: U32
  for +d: BoardDigit
  EncodeMiddleRaw(b,prefix,suffix,p,d)


def Encode81At(-b: Array<U32>, +before: Nat, +after: Nat, +d: BoardDigit) -> Type:
  Board128(b) ->
  RoutedApart(109,walk_position(before,0)) ->
  RoutedApart(110,walk_position(before,0)) ->
  RoutedApart(111,walk_position(before,0)) ->
  EncodeApart(before,0,walk_position(before,0)) ->
  RoutedApart(flag_slot(walk_position(before,0)),walk_position(before,0)) ->
  EncodeApart(after,(walk_position(before,0) + 1 : U32),walk_position(before,0)) ->
  {with_center(before,after) == 81n : Nat} ->
  Nonblank(d) ->
  {cell_value(b,walk_position(before,0)) == digit_word(d) : U32} ->
  {cell_value(Q.encode(b),walk_position(before,0)) == fixed_word(d) : U32}

law encode81_at_step:
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
  for count: {with_center(before,after) == 81n : Nat}
  for nonblank: Nonblank(d)
  for digit: {cell_value(image_board(image),walk_position(before,0)) == digit_word(d) : U32}
  {cell_value(Q.encode(image_board(image)),walk_position(before,0)) == fixed_word(d) : U32}

law encode81_at_image:
  for +image: BoardImage
  for +before: Nat
  for +after: Nat
  for +d: BoardDigit
  Encode81At(image_board(image),before,after,d)

law public_queue_encode_nonblank_at:
  for b: Array<U32>
  for +before: Nat
  for +after: Nat
  for +d: BoardDigit
  Encode81At(b,before,after,d)

law public_encode_nonblank_routes:
  for b: Array<U32>
  for +before: Nat
  for +after: Nat
  for +d: BoardDigit
  for shape: Board128(b)
  for routes: WindowRoutes(before,after,walk_position(before,0),(walk_position(before,0) + 1 : U32))
  for count: {with_center(before,after) == 81n : Nat}
  for nonblank: Nonblank(d)
  for digit: {cell_value(b,walk_position(before,0)) == digit_word(d) : U32}
  {cell_value(Q.encode(b),walk_position(before,0)) == fixed_word(d) : U32}

law public_encode_nonblank_checked:
  for b: Array<U32>
  for +before: Nat
  for +after: Nat
  for +d: BoardDigit
  for shape: Board128(b)
  for window: VerifiedWindow(before,after)
  for nonblank: Nonblank(d)
  for digit: {cell_value(b,walk_position(before,0)) == digit_word(d) : U32}
  {cell_value(Q.encode(b),walk_position(before,0)) == fixed_word(d) : U32}

law any_logical_cell_encode_nonblank:
  for b: Array<U32>
  for +row: CellCoordinate
  for +col: CellCoordinate
  for +d: BoardDigit
  for shape: Board128(b)
  for nonblank: Nonblank(d)
  for digit: {cell_value(b,logical_position(row,col)) == digit_word(d) : U32}
  {cell_value(Q.encode(b),logical_position(row,col)) == fixed_word(d) : U32}


law activation_shape_and_word_parts:
  for +image: BoardImage
  for +row: CellCoordinate
  for +col: CellCoordinate
  for +d: BoardDigit
  for nonblank: Nonblank(d)
  for shapes: (Board128(image_board(image)) & Board128(image_board(image)))
  for word: {cell_value(image_board(image),logical_position(row,col)) == digit_word(d) : U32}
  FixedClue(Fast.activated(False{},image_board(image)),logical_position(row,col),d)

law activation_shape_and_word_image:
  for +image: BoardImage
  for +row: CellCoordinate
  for +col: CellCoordinate
  for +d: BoardDigit
  for nonblank: Nonblank(d)
  for clue: PlainWord(image_board(image),logical_position(row,col),digit_word(d))
  FixedClue(Fast.activated(False{},image_board(image)),logical_position(row,col),d)

law adaptive_activation_fixed_clue:
  for b: Array<U32>
  for +row: CellCoordinate
  for +col: CellCoordinate
  for +d: BoardDigit
  for nonblank: Nonblank(d)
  for clue: PlainWord(b,logical_position(row,col),digit_word(d))
  FixedClue(Fast.activated(False{},b),logical_position(row,col),d)

law guessed_ignores_supplied_mode:
  for -frames: Array<U32>
  for +depth: U32
  for +found: U32
  for -snapshots: List<&1,Array<U32>>
  for +p: U32
  for +digit: U32
  for +remaining: U32
  for pair: Array<U32> & Array<U32>
  {Fast.guessed(p,digit,remaining,frames,depth,found,snapshots,False{},pair) ==
    Fast.guessed(p,digit,remaining,frames,depth,found,snapshots,True{},pair) : Fast.State}

law adaptive_first_guess_matches_queued:
  for b: Array<U32>
  for -frames: Array<U32>
  for +depth: U32
  for +found: U32
  for -snapshots: List<&1,Array<U32>>
  for +p: U32
  for +digit: U32
  for +remaining: U32
  {Fast.place(True{},p,digit,remaining,frames,depth,found,snapshots,False{},b) ==
    Fast.place(True{},p,digit,remaining,frames,depth,found,snapshots,True{},Q.encode(b)) : Fast.State}

law adaptive_first_guess_live_keeps_clue_image:
  for +image: BoardImage
  for frames: Array<U32>
  for +depth: U32
  for +found: U32
  for snapshots: List<&1,Array<U32>>
  for +sr: CellCoordinate
  for +sc: CellCoordinate
  for +qr: CellCoordinate
  for +qc: CellCoordinate
  for +fixed: BoardDigit
  for +digit: BoardDigit
  for +remaining: U32
  for nonblank: Nonblank(fixed)
  for distinct: {U32.is_eq(logical_position(sr,sc),logical_position(qr,qc)) == False{} : Bool}
  for clue: PlainWord(image_board(image),logical_position(qr,qc),digit_word(fixed))
  {searching_word(Fast.place(True{},logical_position(sr,sc),digit_word(digit),remaining,frames,depth,found,snapshots,False{},image_board(image)),logical_position(qr,qc)) == fixed_word(fixed) : U32}

law adaptive_first_guess_live_keeps_clue:
  for b: Array<U32>
  for frames: Array<U32>
  for +depth: U32
  for +found: U32
  for snapshots: List<&1,Array<U32>>
  for +sr: CellCoordinate
  for +sc: CellCoordinate
  for +qr: CellCoordinate
  for +qc: CellCoordinate
  for +fixed: BoardDigit
  for +digit: BoardDigit
  for +remaining: U32
  for nonblank: Nonblank(fixed)
  for distinct: {U32.is_eq(logical_position(sr,sc),logical_position(qr,qc)) == False{} : Bool}
  for clue: PlainWord(b,logical_position(qr,qc),digit_word(fixed))
  {searching_word(Fast.place(True{},logical_position(sr,sc),digit_word(digit),remaining,frames,depth,found,snapshots,False{},b),logical_position(qr,qc)) == fixed_word(fixed) : U32}

law adaptive_first_guess_snapshot_keeps_clue_image:
  for +image: BoardImage
  for frames: Array<U32>
  for +depth: U32
  for +found: U32
  for snapshots: List<&1,Array<U32>>
  for +sr: CellCoordinate
  for +sc: CellCoordinate
  for +qr: CellCoordinate
  for +qc: CellCoordinate
  for +fixed: BoardDigit
  for +digit: BoardDigit
  for +remaining: U32
  for nonblank: Nonblank(fixed)
  for clue: PlainWord(image_board(image),logical_position(qr,qc),digit_word(fixed))
  {searching_snapshot_word(Fast.place(True{},logical_position(sr,sc),digit_word(digit),remaining,frames,depth,found,snapshots,False{},image_board(image)),logical_position(qr,qc)) == fixed_word(fixed) : U32}

law adaptive_first_guess_snapshot_keeps_clue:
  for b: Array<U32>
  for frames: Array<U32>
  for +depth: U32
  for +found: U32
  for snapshots: List<&1,Array<U32>>
  for +sr: CellCoordinate
  for +sc: CellCoordinate
  for +qr: CellCoordinate
  for +qc: CellCoordinate
  for +fixed: BoardDigit
  for +digit: BoardDigit
  for +remaining: U32
  for nonblank: Nonblank(fixed)
  for clue: PlainWord(b,logical_position(qr,qc),digit_word(fixed))
  {searching_snapshot_word(Fast.place(True{},logical_position(sr,sc),digit_word(digit),remaining,frames,depth,found,snapshots,False{},b),logical_position(qr,qc)) == fixed_word(fixed) : U32}

# The production selectors trust metadata; shape and a fixed cell alone do
# not suffice to prove a selector avoids it.
def inconsistent_queued_board() -> Array<U32>:
  B.set_cell(B.set_cell(B.empty(),0,1024),109,1)

def inconsistent_plain_board() -> Array<U32>:
  B.set_cell(B.set_cell(B.empty(),0,1),81,2044)

law queued_stale_flag_can_select_clue:
  ({cell_value(inconsistent_queued_board(),0) == 1024 : U32} &
   {Pair.snd(Array<U32>,C.Choice,Q.select(inconsistent_queued_board())) == C.Choice{0,1024,1} : C.Choice})

law ordinary_stale_bitmap_can_select_clue:
  ({cell_value(inconsistent_plain_board(),0) == 1 : U32} &
   {Pair.snd(Array<U32>,C.Choice,C.cached_select(inconsistent_plain_board())) == C.Choice{0,2,1} : C.Choice})

# An alternative uses the restored board rather than transient unwind words.
def lowest_bit(+mask: U32) -> U32:
  U32.and(mask,(0 - mask : U32))

def alternative_digit(+mask: U32) -> U32:
  C.mask_count((lowest_bit(mask) - 1 : U32))

def alternatives_after(+mask: U32) -> U32:
  U32.xor(mask,lowest_bit(mask))

law adaptive_nonzero_alternative_replays_guess:
  for +mask: U32
  for +p: U32
  for -frames: Array<U32>
  for +depth: U32
  for +found: U32
  for -snapshots: List<&1,Array<U32>>
  for -saved: Array<U32>
  for present: {U32.is_eq(mask,0) == False{} : Bool}
  {Fast.alternative(mask,p,frames,depth,found,snapshots,True{},saved) ==
    Fast.place(True{},p,alternative_digit(mask),alternatives_after(mask),frames,depth,found,snapshots,True{},saved) : Fast.State}

law adaptive_nonzero_restore_replays_guess:
  for +mask: U32
  for +p: U32
  for -frames: Array<U32>
  for +depth: U32
  for +found: U32
  for -snapshots: List<&1,Array<U32>>
  for -saved: Array<U32>
  for present: {U32.is_eq(mask,0) == False{} : Bool}
  {Fast.restore(p,mask,frames,depth,found,saved <> snapshots,True{}) ==
    Fast.place(True{},p,alternative_digit(mask),alternatives_after(mask),frames,depth,found,snapshots,True{},saved) : Fast.State}

# For an arbitrary fixed-width word, isolate its first set bit without using a
# truth table or assuming a candidate range.
def first_one_word(+n: Nat, +w: Word(n)) -> Word(n):
  match n w:
    case 0n WNil{}:
      WNil{}
    case 1n+k WCon{True{}, tail}:
      WCon{True{}, Word.zero(k)}
    case 1n+k WCon{False{}, tail}:
      WCon{False{}, first_one_word(k,tail)}

law zero_subtract_no_carry_is_not:
  for +n: Nat
  for +w: Word(n)
  {Word.adc(n,Word.zero(n),w,True{},False{}) == Word.not(n,w) : Word(n)}

law word_and_complement_zero:
  for +n: Nat
  for +w: Word(n)
  {Word.and(n,w,Word.not(n,w)) == Word.zero(n) : Word(n)}

law word_first_one_is_lowest_bit:
  for +n: Nat
  for +w: Word(n)
  {Word.and(n,w,Word.sub(n,Word.zero(n),w)) == first_one_word(n,w) : Word(n)}

law u32_first_one_is_lowest_bit:
  for +w: Word(32n)
  {lowest_bit(U32{w}) == U32{first_one_word(32n,w)} : U32}

law first_one_word_is_present:
  for +n: Nat
  for +w: Word(n)
  {Word.and(n,first_one_word(n,w),w) == first_one_word(n,w) : Word(n)}

law lowest_bit_is_present:
  for +w: Word(32n)
  {U32.and(lowest_bit(U32{w}),U32{w}) == lowest_bit(U32{w}) : U32}

def remove_first_one_word(+n: Nat, +w: Word(n)) -> Word(n):
  match n w:
    case 0n WNil{}:
      WNil{}
    case 1n+k WCon{True{},tail}:
      WCon{False{},tail}
    case 1n+k WCon{False{},tail}:
      WCon{False{},remove_first_one_word(k,tail)}

law word_xor_zero_right:
  for +n: Nat
  for +w: Word(n)
  {Word.xor(n,w,Word.zero(n)) == w : Word(n)}

law word_xor_first_one_removes_only_first:
  for +n: Nat
  for +w: Word(n)
  {Word.xor(n,w,first_one_word(n,w)) == remove_first_one_word(n,w) : Word(n)}

law alternatives_after_removes_only_first:
  for +w: Word(32n)
  {alternatives_after(U32{w}) == U32{remove_first_one_word(32n,w)} : U32}

def pad_candidate(+n: Nat, +bits: Word(n)) -> Word(Nat.add(n,22n)):
  match n bits:
    case 0n WNil{}:
      Word.zero(22n)
    case 1n+k WCon{head,tail}:
      WCon{head,pad_candidate(k,tail)}

def candidate_bits_word(+bits: Word(9n)) -> U32:
  U32{WCon{False{},pad_candidate(9n,bits)}}

def ChosenAlternative(+mask: U32) -> Type:
  Sigma<&2,&1,BoardDigit,d =>
    (Nonblank(d) & {alternative_digit(mask) == digit_word(d) : U32}
      & {lowest_bit(mask) == B.bit(digit_word(d)) : U32})>

law chosen_alternative_pack:
  for +w: Word(32n)
  for +d: BoardDigit
  for nonblank: Nonblank(d)
  for count: {C.mask_count((B.bit(digit_word(d)) - 1 : U32)) == digit_word(d) : U32}
  for eq: {lowest_bit(U32{w}) == B.bit(digit_word(d)) : U32}
  ChosenAlternative(U32{w})

law chosen_alternative_from_first_one:
  for +w: Word(32n)
  for +d: BoardDigit
  for nonblank: Nonblank(d)
  for found: {U32{first_one_word(32n,w)} == B.bit(digit_word(d)) : U32}
  for count: {C.mask_count((B.bit(digit_word(d)) - 1 : U32)) == digit_word(d) : U32}
  ChosenAlternative(U32{w})

law candidate_bits_select_digit:
  for +bits: Word(9n)
  for nonempty: {U32.is_eq(candidate_bits_word(bits),0) == False{} : Bool}
  ChosenAlternative(candidate_bits_word(bits))

def CandidateMaskImage(+word: U32) -> Type:
  Sigma<&2,&1,Word(9n),bits => {U32.and(1022,word) == candidate_bits_word(bits) : U32}>

law low_candidate_mask_image:
  for +word: U32
  CandidateMaskImage(word)

law clipped_candidate_selects_digit_image:
  for +word: U32
  for image: CandidateMaskImage(word)
  for nonempty: {U32.is_eq(U32.and(1022,word),0) == False{} : Bool}
  ChosenAlternative(U32.and(1022,word))

law clipped_candidate_selects_digit:
  for +word: U32
  for nonempty: {U32.is_eq(U32.and(1022,word),0) == False{} : Bool}
  ChosenAlternative(U32.and(1022,word))

law normalized_candidate_selects_digit:
  for +mask: U32
  for clipped: {U32.and(1022,mask) == mask : U32}
  for nonempty: {U32.is_eq(mask,0) == False{} : Bool}
  ChosenAlternative(mask)

law adaptive_restore_replays_chosen_digit:
  for +mask: U32
  for +p: U32
  for -frames: Array<U32>
  for +depth: U32
  for +found: U32
  for -snapshots: List<&1,Array<U32>>
  for -saved: Array<U32>
  for +d: BoardDigit
  for present: {U32.is_eq(mask,0) == False{} : Bool}
  for digit_is: {alternative_digit(mask) == digit_word(d) : U32}
  {Fast.restore(p,mask,frames,depth,found,saved <> snapshots,True{}) ==
    Fast.place(True{},p,digit_word(d),alternatives_after(mask),frames,depth,found,snapshots,True{},saved) : Fast.State}

law adaptive_restored_working_keeps_clue_image:
  for +image: BoardImage
  for frames: Array<U32>
  for +depth: U32
  for +found: U32
  for snapshots: List<&1,Array<U32>>
  for +sr: CellCoordinate
  for +sc: CellCoordinate
  for +qr: CellCoordinate
  for +qc: CellCoordinate
  for +fixed: BoardDigit
  for +digit: BoardDigit
  for +mask: U32
  for present: {U32.is_eq(mask,0) == False{} : Bool}
  for digit_is: {alternative_digit(mask) == digit_word(digit) : U32}
  for distinct: {U32.is_eq(logical_position(sr,sc),logical_position(qr,qc)) == False{} : Bool}
  for clue: FixedClue(image_board(image),logical_position(qr,qc),fixed)
  {searching_word(Fast.restore(logical_position(sr,sc),mask,frames,depth,found,image_board(image) <> snapshots,True{}),logical_position(qr,qc)) == fixed_word(fixed) : U32}

law adaptive_restored_working_keeps_clue:
  for saved: Array<U32>
  for frames: Array<U32>
  for +depth: U32
  for +found: U32
  for snapshots: List<&1,Array<U32>>
  for +sr: CellCoordinate
  for +sc: CellCoordinate
  for +qr: CellCoordinate
  for +qc: CellCoordinate
  for +fixed: BoardDigit
  for +digit: BoardDigit
  for +mask: U32
  for present: {U32.is_eq(mask,0) == False{} : Bool}
  for digit_is: {alternative_digit(mask) == digit_word(digit) : U32}
  for distinct: {U32.is_eq(logical_position(sr,sc),logical_position(qr,qc)) == False{} : Bool}
  for clue: FixedClue(saved,logical_position(qr,qc),fixed)
  {searching_word(Fast.restore(logical_position(sr,sc),mask,frames,depth,found,saved <> snapshots,True{}),logical_position(qr,qc)) == fixed_word(fixed) : U32}

law adaptive_restored_snapshot_keeps_clue_image:
  for +image: BoardImage
  for frames: Array<U32>
  for +depth: U32
  for +found: U32
  for snapshots: List<&1,Array<U32>>
  for +p: U32
  for +q: U32
  for +fixed: BoardDigit
  for +digit: BoardDigit
  for +mask: U32
  for present: {U32.is_eq(mask,0) == False{} : Bool}
  for digit_is: {alternative_digit(mask) == digit_word(digit) : U32}
  for clue: FixedClue(image_board(image),q,fixed)
  {searching_snapshot_word(Fast.restore(p,mask,frames,depth,found,image_board(image) <> snapshots,True{}),q) == fixed_word(fixed) : U32}

law adaptive_restored_snapshot_keeps_clue:
  for saved: Array<U32>
  for frames: Array<U32>
  for +depth: U32
  for +found: U32
  for snapshots: List<&1,Array<U32>>
  for +p: U32
  for +q: U32
  for +fixed: BoardDigit
  for +digit: BoardDigit
  for +mask: U32
  for present: {U32.is_eq(mask,0) == False{} : Bool}
  for digit_is: {alternative_digit(mask) == digit_word(digit) : U32}
  for clue: FixedClue(saved,q,fixed)
  {searching_snapshot_word(Fast.restore(p,mask,frames,depth,found,saved <> snapshots,True{}),q) == fixed_word(fixed) : U32}

law copy_mask_nonempty:
  for +mask: U32
  for known: {U32.is_eq(mask,0) == False{} : Bool}
  ({U32.is_eq(mask,0) == False{} : Bool} & {U32.is_eq(mask,0) == False{} : Bool})

law adaptive_normalized_restore_working_keeps_clue_take:
  for saved: Array<U32>
  for frames: Array<U32>
  for +depth: U32
  for +found: U32
  for snapshots: List<&1,Array<U32>>
  for +sr: CellCoordinate
  for +sc: CellCoordinate
  for +qr: CellCoordinate
  for +qc: CellCoordinate
  for +fixed: BoardDigit
  for +mask: U32
  for present: {U32.is_eq(mask,0) == False{} : Bool}
  for choice: ChosenAlternative(mask)
  for distinct: {U32.is_eq(logical_position(sr,sc),logical_position(qr,qc)) == False{} : Bool}
  for clue: FixedClue(saved,logical_position(qr,qc),fixed)
  {searching_word(Fast.restore(logical_position(sr,sc),mask,frames,depth,found,saved <> snapshots,True{}),logical_position(qr,qc)) == fixed_word(fixed) : U32}

law adaptive_normalized_restore_working_keeps_clue_split:
  for saved: Array<U32>
  for frames: Array<U32>
  for +depth: U32
  for +found: U32
  for snapshots: List<&1,Array<U32>>
  for +sr: CellCoordinate
  for +sc: CellCoordinate
  for +qr: CellCoordinate
  for +qc: CellCoordinate
  for +fixed: BoardDigit
  for +mask: U32
  for both: ({U32.is_eq(mask,0) == False{} : Bool} & {U32.is_eq(mask,0) == False{} : Bool})
  for clipped: {U32.and(1022,mask) == mask : U32}
  for distinct: {U32.is_eq(logical_position(sr,sc),logical_position(qr,qc)) == False{} : Bool}
  for clue: FixedClue(saved,logical_position(qr,qc),fixed)
  {searching_word(Fast.restore(logical_position(sr,sc),mask,frames,depth,found,saved <> snapshots,True{}),logical_position(qr,qc)) == fixed_word(fixed) : U32}

law adaptive_normalized_restore_working_keeps_clue:
  for saved: Array<U32>
  for frames: Array<U32>
  for +depth: U32
  for +found: U32
  for snapshots: List<&1,Array<U32>>
  for +sr: CellCoordinate
  for +sc: CellCoordinate
  for +qr: CellCoordinate
  for +qc: CellCoordinate
  for +fixed: BoardDigit
  for +mask: U32
  for present: {U32.is_eq(mask,0) == False{} : Bool}
  for clipped: {U32.and(1022,mask) == mask : U32}
  for distinct: {U32.is_eq(logical_position(sr,sc),logical_position(qr,qc)) == False{} : Bool}
  for clue: FixedClue(saved,logical_position(qr,qc),fixed)
  {searching_word(Fast.restore(logical_position(sr,sc),mask,frames,depth,found,saved <> snapshots,True{}),logical_position(qr,qc)) == fixed_word(fixed) : U32}

law adaptive_normalized_restore_snapshot_keeps_clue_take:
  for saved: Array<U32>
  for frames: Array<U32>
  for +depth: U32
  for +found: U32
  for snapshots: List<&1,Array<U32>>
  for +p: U32
  for +q: U32
  for +fixed: BoardDigit
  for +mask: U32
  for present: {U32.is_eq(mask,0) == False{} : Bool}
  for choice: ChosenAlternative(mask)
  for clue: FixedClue(saved,q,fixed)
  {searching_snapshot_word(Fast.restore(p,mask,frames,depth,found,saved <> snapshots,True{}),q) == fixed_word(fixed) : U32}

law adaptive_normalized_restore_snapshot_keeps_clue_split:
  for saved: Array<U32>
  for frames: Array<U32>
  for +depth: U32
  for +found: U32
  for snapshots: List<&1,Array<U32>>
  for +p: U32
  for +q: U32
  for +fixed: BoardDigit
  for +mask: U32
  for both: ({U32.is_eq(mask,0) == False{} : Bool} & {U32.is_eq(mask,0) == False{} : Bool})
  for clipped: {U32.and(1022,mask) == mask : U32}
  for clue: FixedClue(saved,q,fixed)
  {searching_snapshot_word(Fast.restore(p,mask,frames,depth,found,saved <> snapshots,True{}),q) == fixed_word(fixed) : U32}

law adaptive_normalized_restore_snapshot_keeps_clue:
  for saved: Array<U32>
  for frames: Array<U32>
  for +depth: U32
  for +found: U32
  for snapshots: List<&1,Array<U32>>
  for +p: U32
  for +q: U32
  for +fixed: BoardDigit
  for +mask: U32
  for present: {U32.is_eq(mask,0) == False{} : Bool}
  for clipped: {U32.and(1022,mask) == mask : U32}
  for clue: FixedClue(saved,q,fixed)
  {searching_snapshot_word(Fast.restore(p,mask,frames,depth,found,saved <> snapshots,True{}),q) == fixed_word(fixed) : U32}

# The generator's acceptance gate is independent of correspondence between
# CountOne and mathematical uniqueness.
def removal_gate_spec(old: Array<U32>, candidate: Array<U32>, +clues: U32, +size: U32, count: T.Count) -> G.DigResult:
  match count:
    case T.CountOne{}:
      G.DigDone{candidate,(clues - size : U32)}
    case T.CountFuel{}:
      G.DigFuel{}
    case T.CountZero{}:
      G.DigDone{old,clues}
    case T.CountMany{}:
      G.DigDone{old,clues}

law generator_accept_gate:
  for -old: Array<U32>
  for -candidate: Array<U32>
  for +clues: U32
  for +size: U32
  for count: T.Count
  {G.accept(old,candidate,clues,size,count) == removal_gate_spec(old,candidate,clues,size,count) : G.DigResult}

law generator_count_gate:
  for +fuel: Nat
  for -old: Array<U32>
  for +clues: U32
  for +size: U32
  for -candidate: Array<U32>
  for test: Array<U32>
  {G.count_candidate(fuel,old,clues,size,(candidate,test)) == removal_gate_spec(old,candidate,clues,size,K.count2(fuel,test)) : G.DigResult}

law generator_attempt_counts_exact_removed_board:
  for +fuel: Nat
  for +pos: U32
  for +symmetry: Bool
  for +clues: U32
  for +size: U32
  for old: Array<U32>
  for candidate: Array<U32>
  {G.attempt(fuel,pos,symmetry,clues,size,(old,candidate)) ==
    G.count_candidate(fuel,old,clues,size,
      (G.remove_unit(candidate,pos,symmetry),G.remove_unit(candidate,pos,symmetry))) : G.DigResult}

law generator_count_zero_fuel_rejects:
  for -old: Array<U32>
  for +clues: U32
  for +size: U32
  for -candidate: Array<U32>
  for -test: Array<U32>
  {G.count_candidate(0n,old,clues,size,(candidate,test)) == G.DigFuel{} : G.DigResult}

law generator_fuel_stays_terminal:
  for units: List<&2,G.RemovalUnit>
  for +fuel: Nat
  for +target: U32
  for +symmetry: Bool
  {G.dig_go(units,fuel,target,symmetry,G.DigFuel{}) == G.DigFuel{} : G.DigResult}

law generator_skips_disallowed_removal:
  for +fuel: Nat
  for +pos: U32
  for +symmetry: Bool
  for +clues: U32
  for +size: U32
  for -board: Array<U32>
  {G.try_unit(False{},fuel,pos,symmetry,clues,size,board) == G.DigDone{board,clues} : G.DigResult}

# Extract the owned board from the actual ordinary selector state.
def row_state_board(state: C.RowScan) -> Array<U32>:
  match state:
    case C.RowDone{b,p,m,size}:
      b
    case C.RowLive{b,row,bits,used,boxbase,p,m,size}:
      b

law row_mask_reads_board:
  for b: Array<U32>
  for +col: U32
  for +boxbase: U32
  for +used: U32
  SameBoardRead(b,C.row_mask(b,col,boxbase,used))

law row_scan_open_reads_board:
  for -b: Array<U32>
  for +open: Bool
  for +row: U32
  for +p: U32
  for +m: U32
  for +size: U32
  for +word: U32
  {row_state_board(C.row_scan_open(open,row,p,m,size,(b,word))) == b : Array<U32>}

law row_scan_start_reads_board:
  for -b: Array<U32>
  for -r: Array<U32> & U32
  for +row: U32
  for +p: U32
  for +m: U32
  for +size: U32
  for read: SameBoardRead(b,r)
  {row_state_board(C.row_scan_start(row,p,m,size,r)) == b : Array<U32>}

law row_scan_result_keeps_board:
  for -b: Array<U32>
  for +urgent: Bool
  for +row: U32
  for +bits: U32
  for +used: U32
  for +boxbase: U32
  for +pos: U32
  for +mask: U32
  for +count: U32
  for +p: U32
  for +m: U32
  for +size: U32
  {row_state_board(C.row_scan_result(urgent,row,bits,used,boxbase,pos,mask,count,p,m,size,b)) == b : Array<U32>}

law row_scan_take_reads_board:
  for -b: Array<U32>
  for -r: Array<U32> & U32
  for +row: U32
  for +bits: U32
  for +used: U32
  for +boxbase: U32
  for +pos: U32
  for +p: U32
  for +m: U32
  for +size: U32
  for read: SameBoardRead(b,r)
  {row_state_board(C.row_scan_take(row,bits,used,boxbase,pos,p,m,size,r)) == b : Array<U32>}


law ordinary_row_take_normalized_keeps:
  for +image: BoardImage
  for +row: U32
  for +bits: U32
  for +used: U32
  for +boxbase: U32
  for +p: U32
  for +m: U32
  for +size: U32
  {row_state_board(C.row_scan_take(row,alternatives_after(bits),used,boxbase,(row * 9 + alternative_digit(bits) : U32),p,m,size,
    C.row_mask(image_board(image),alternative_digit(bits),boxbase,used))) == image_board(image) : Array<U32>}

law ordinary_row_step_preserves_board_image:
  for +image: BoardImage
  for +row: U32
  for +bits: U32
  for +used: U32
  for +boxbase: U32
  for +p: U32
  for +m: U32
  for +size: U32
  {row_state_board(C.row_scan_step(row,bits,used,boxbase,p,m,size,image_board(image))) == image_board(image) : Array<U32>}

law ordinary_row_step_preserves_board:
  for b: Array<U32>
  for +row: U32
  for +bits: U32
  for +used: U32
  for +boxbase: U32
  for +p: U32
  for +m: U32
  for +size: U32
  {row_state_board(C.row_scan_step(row,bits,used,boxbase,p,m,size,b)) == b : Array<U32>}

law ordinary_row_scan_join:
  for +fuel: Nat
  for -b: Array<U32>
  for -next: C.RowScan
  for next_keeps: {row_state_board(next) == b : Array<U32>}
  for later: {Pair.fst(Array<U32>,C.Choice,C.row_scan(fuel,next)) == row_state_board(next) : Array<U32>}
  {Pair.fst(Array<U32>,C.Choice,C.row_scan(fuel,next)) == b : Array<U32>}

law ordinary_row_scan_continue_image:
  for +fuel: Nat
  for +image: BoardImage
  for +row: U32
  for +bits: U32
  for +used: U32
  for +boxbase: U32
  for +p: U32
  for +m: U32
  for +size: U32
  for later: @next:C.RowScan -> {Pair.fst(Array<U32>,C.Choice,C.row_scan(fuel,next)) == row_state_board(next) : Array<U32>}
  {Pair.fst(Array<U32>,C.Choice,C.row_scan(1n+fuel,C.RowLive{image_board(image),row,bits,used,boxbase,p,m,size})) == image_board(image) : Array<U32>}

law ordinary_row_scan_continue:
  for +fuel: Nat
  for b: Array<U32>
  for +row: U32
  for +bits: U32
  for +used: U32
  for +boxbase: U32
  for +p: U32
  for +m: U32
  for +size: U32
  for later: @next:C.RowScan -> {Pair.fst(Array<U32>,C.Choice,C.row_scan(fuel,next)) == row_state_board(next) : Array<U32>}
  {Pair.fst(Array<U32>,C.Choice,C.row_scan(1n+fuel,C.RowLive{b,row,bits,used,boxbase,p,m,size})) == b : Array<U32>}

law ordinary_row_scan_preserves_board:
  for +fuel: Nat
  for state: C.RowScan
  {Pair.fst(Array<U32>,C.Choice,C.row_scan(fuel,state)) == row_state_board(state) : Array<U32>}


law ordinary_row_begin_from_image:
  for +row: U32
  for +index: U32
  for +fuel: Nat
  for +image: BoardImage
  {Pair.fst(Array<U32>,C.Choice,C.row_scan(fuel,C.row_scan_start(row,81,0,10,Array.get(U32,image_board(image),index)))) == image_board(image) : Array<U32>}

law ordinary_row_begin_reads_board:
  for -b: Array<U32>
  for -r: Array<U32> & U32
  for read: SameBoardRead(b,r)
  {Pair.fst(Array<U32>,C.Choice,C.row_scan_begin(r)) == b : Array<U32>}

law ordinary_production_selector_does_not_write:
  for b: Array<U32>
  {Pair.fst(Array<U32>,C.Choice,C.cached_select(b)) == b : Array<U32>}

def scalar_board(r: Array<U32> & U32 & U32 & U32) -> Array<U32>:
  (b,rest) = r
  b

law queued_advance_keeps_board:
  for -b: Array<U32>
  for +open: Bool
  for +pos: U32
  for +p: U32
  for +m: U32
  for +size: U32
  for +word: U32
  {scalar_board(Q.advance(open,pos,p,m,size,b,word)) == b : Array<U32>}

law queued_inspected_reads_board:
  for -b: Array<U32>
  for -r: Array<U32> & U32
  for +pos: U32
  for +p: U32
  for +m: U32
  for +size: U32
  for read: SameBoardRead(b,r)
  {scalar_board(Q.inspected(pos,p,m,size,r)) == b : Array<U32>}

law queued_urgent_reads_board:
  for -b: Array<U32>
  for -r: Array<U32> & U32
  for +pos: U32
  for read: SameBoardRead(b,r)
  {Pair.fst(Array<U32>,C.Choice,Q.urgent(pos,r)) == b : Array<U32>}

law queue_fixed_raw_word_is_closed:
  for +d: BoardDigit
  for nonblank: Nonblank(d)
  {(fixed_word(d) < 1024 : U32) == False{} : Bool}

law queued_scan_skips_fixed_word:
  for -b: Array<U32>
  for +pos: U32
  for +p: U32
  for +m: U32
  for +size: U32
  for +d: BoardDigit
  for nonblank: Nonblank(d)
  {Q.inspected(pos,p,m,size,(b,fixed_word(d))) == (b,(p,(m,size))) : Array<U32> & U32 & U32 & U32}

def QueuedScanTuple() -> Type:
  Array<U32> & U32 & U32 & U32

def QueuedSelectResult() -> Type:
  Array<U32> & C.Choice

def selector_board(r: QueuedSelectResult()) -> Array<U32>:
  Pair.fst(Array<U32>,C.Choice,r)

law queued_scan_step_preserves_from_image:
  for +n: Nat
  for +pos: U32
  for +p: U32
  for +m: U32
  for +size: U32
  for +image: BoardImage
  for later: @next:QueuedScanTuple() -> {selector_board(Q.scan(n,(pos + 1 : U32),next)) == scalar_board(next) : Array<U32>}
  {selector_board(Q.scan(n,(pos + 1 : U32),Q.inspected(pos,p,m,size,Array.get(U32,image_board(image),pos)))) == image_board(image) : Array<U32>}

law queued_scan_step_preserves:
  for +n: Nat
  for +pos: U32
  for +p: U32
  for +m: U32
  for +size: U32
  for b: Array<U32>
  for later: @next:QueuedScanTuple() -> {selector_board(Q.scan(n,(pos + 1 : U32),next)) == scalar_board(next) : Array<U32>}
  {selector_board(Q.scan(n,(pos + 1 : U32),Q.inspected(pos,p,m,size,Array.get(U32,b,pos)))) == b : Array<U32>}

law queued_scan_zero_keeps:
  for +pos: U32
  for -b: Array<U32>
  for +p: U32
  for +m: U32
  for +size: U32
  {selector_board(Q.scan(0n,pos,(b,(p,(m,size))))) == b : Array<U32>}

law queued_scan_succ_keeps:
  for +n: Nat
  for +pos: U32
  for +p: U32
  for +m: U32
  for +size: U32
  for b: Array<U32>
  for later: @next:QueuedScanTuple() -> {selector_board(Q.scan(n,(pos + 1 : U32),next)) == scalar_board(next) : Array<U32>}
  {selector_board(Q.scan(1n+n,pos,(b,(p,(m,size))))) == b : Array<U32>}

law queued_scan_last_zero:
  for +pos: U32
  for -b: Array<U32>
  for +p: U32
  for rest: U32 & U32
  {selector_board(Q.scan(0n,pos,(b,(p,rest)))) == b : Array<U32>}

law queued_scan_tail_zero:
  for +pos: U32
  for -b: Array<U32>
  for tail: U32 & U32 & U32
  {selector_board(Q.scan(0n,pos,(b,tail))) == b : Array<U32>}

law queued_scan_last_succ:
  for +n: Nat
  for +pos: U32
  for b: Array<U32>
  for +p: U32
  for rest: U32 & U32
  for later: @next:QueuedScanTuple() -> {selector_board(Q.scan(n,(pos + 1 : U32),next)) == scalar_board(next) : Array<U32>}
  {selector_board(Q.scan(1n+n,pos,(b,(p,rest)))) == b : Array<U32>}

law queued_scan_tail_succ:
  for +n: Nat
  for +pos: U32
  for b: Array<U32>
  for tail: U32 & U32 & U32
  for later: @next:QueuedScanTuple() -> {selector_board(Q.scan(n,(pos + 1 : U32),next)) == scalar_board(next) : Array<U32>}
  {selector_board(Q.scan(1n+n,pos,(b,tail))) == b : Array<U32>}

law queued_scan_tuple_zero:
  for +pos: U32
  for r: QueuedScanTuple()
  {selector_board(Q.scan(0n,pos,r)) == scalar_board(r) : Array<U32>}

law queued_scan_tuple_succ:
  for +n: Nat
  for +pos: U32
  for r: QueuedScanTuple()
  for later: @next:QueuedScanTuple() -> {selector_board(Q.scan(n,(pos + 1 : U32),next)) == scalar_board(next) : Array<U32>}
  {selector_board(Q.scan(1n+n,pos,r)) == scalar_board(r) : Array<U32>}

law queued_scan_reads_board:
  for +n: Nat
  for +pos: U32
  for r: QueuedScanTuple()
  {selector_board(Q.scan(n,pos,r)) == scalar_board(r) : Array<U32>}

law queued_start_reads_board:
  for -b: Array<U32>
  for -r: Array<U32> & U32
  for read: SameBoardRead(b,r)
  {selector_board(Q.start(r)) == b : Array<U32>}

def urgent_pos(+base: U32, +bits: U32) -> U32:
  (base + Q.trailing(U32.shrn((lowest_bit(bits) * 125613361 : U32),27n)) : U32)

law queued_urgent_from_board:
  for b: Array<U32>
  for +p: U32
  {selector_board(Q.urgent(p,Array.get(U32,b,p))) == b : Array<U32>}

law queued_flags_empty_reads_start:
  for -b: Array<U32>
  for +base: U32
  for -r: Array<U32> & U32
  for read: SameBoardRead(b,r)
  {selector_board(Q.flags(0n,base,r)) == b : Array<U32>}

law queued_flag_word_keeps_board:
  for +n: Nat
  for +base: U32
  for b: Array<U32>
  for +bits: U32
  for next: @p:Array<U32> -> {selector_board(Q.flags(n,(base + 32 : U32),Array.get(U32,p,(110 + U32.shrn(base,5n) : U32)))) == p : Array<U32>}
  {selector_board(Q.flags(1n+n,base,(b,bits))) == b : Array<U32>}

law queued_flags_step_reads_board:
  for +n: Nat
  for +base: U32
  for -b: Array<U32>
  for -r: Array<U32> & U32
  for read: SameBoardRead(b,r)
  for next: @p:Array<U32> -> {selector_board(Q.flags(n,(base + 32 : U32),Array.get(U32,p,(110 + U32.shrn(base,5n) : U32)))) == p : Array<U32>}
  {selector_board(Q.flags(1n+n,base,r)) == b : Array<U32>}

law queued_flags_reads_board:
  for +n: Nat
  for +base: U32
  for -b: Array<U32>
  for -r: Array<U32> & U32
  for read: SameBoardRead(b,r)
  {selector_board(Q.flags(n,base,r)) == b : Array<U32>}

law queued_production_selector_does_not_write:
  for b: Array<U32>
  {selector_board(Q.select(b)) == b : Array<U32>}

law adaptive_selector_does_not_write:
  for +active: Bool
  for b: Array<U32>
  {selector_board(Fast.selection(active,b)) == b : Array<U32>}

# The urgent fast path reads a flagged raw word; it does not recompute the
# size, so validity of the flag is a separate semantic requirement.
def selector_choice(r: Array<U32> & C.Choice) -> C.Choice:
  Pair.snd(Array<U32>,C.Choice,r)

law queued_urgent_mask_zero_reports_zero:
  for -b: Array<U32>
  for +p: U32
  {selector_choice(Q.urgent(p,(b,0))) == C.Choice{p,0,C.mask_count(0)} : C.Choice}

law queued_urgent_singleton_reports_exact_count:
  for -b: Array<U32>
  for +p: U32
  for +mask: U32
  for nonempty: {U32.is_eq(mask,0) == False{} : Bool}
  for one: {C.mask_count(mask) == 1 : U32}
  {selector_choice(Q.urgent(p,(b,mask))) == C.Choice{p,mask,C.mask_count(mask)} : C.Choice}

def selector_contract_board(+start: U32, +flag: U32) -> Array<U32>:
  Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,Array.set(U32,[1024 : U32*128n],111,0),110,0),109,flag),108,start),0,6)

law queued_late_pointer_hides_existing_blank:
  ({cell_value(selector_contract_board(81,0),0) == 6 : U32}
   & {selector_choice(Q.select(selector_contract_board(81,0))) == C.Choice{81,0,10} : C.Choice})

law queued_valid_start_finds_pair:
  {selector_choice(Q.select(selector_contract_board(0,0))) == C.Choice{0,6,2} : C.Choice}

law queued_false_urgent_flag_underreports_pair:
  ({C.mask_count(6) == 2 : U32}
   & {selector_choice(Q.select(selector_contract_board(0,1))) == C.Choice{0,6,1} : C.Choice})

def flag_offset(+bits: U32) -> U32:
  Q.trailing(U32.shrn((lowest_bit(bits) * 125613361 : U32),27n))

def flag_bit_at(+index: U32) -> U32:
  U32.shln(1,U32.to_nat(index))

def FirstFlag(+bits: U32) -> Type:
  Sigma<&2,&1,U32,index => (
    {(index < 32 : U32) == True{} : Bool} &
    {flag_offset(bits) == index : U32} &
    {U32.and(flag_bit_at(index),bits) == flag_bit_at(index) : U32})>

law flag_present_at_known_lowest:
  for +w: Word(32n)
  for +index: U32
  for seen: {lowest_bit(U32{w}) == flag_bit_at(index) : U32}
  {U32.and(flag_bit_at(index),U32{w}) == flag_bit_at(index) : U32}

law first_flag_pack:
  for +w: Word(32n)
  for +index: U32
  for bound: {(index < 32 : U32) == True{} : Bool}
  for offset: {flag_offset(U32{w}) == index : U32}
  for seen: {lowest_bit(U32{w}) == flag_bit_at(index) : U32}
  FirstFlag(U32{w})

law first_flag_from_lowest_pair:
  for +w: Word(32n)
  for +index: U32
  for bound: {(index < 32 : U32) == True{} : Bool}
  for seen: ({lowest_bit(U32{w}) == flag_bit_at(index) : U32} & {lowest_bit(U32{w}) == flag_bit_at(index) : U32})
  for math: {Q.trailing(U32.shrn((flag_bit_at(index) * 125613361 : U32),27n)) == index : U32}
  FirstFlag(U32{w})

law first_flag_at_known_index:
  for +w: Word(32n)
  for +index: U32
  for bound: {(index < 32 : U32) == True{} : Bool}
  for first: {U32{first_one_word(32n,w)} == flag_bit_at(index) : U32}
  for math: {Q.trailing(U32.shrn((flag_bit_at(index) * 125613361 : U32),27n)) == index : U32}
  FirstFlag(U32{w})

law queued_urgent_math_selects_present_flag:
  for +bits: U32
  for nonzero: {U32.is_eq(bits,0) == False{} : Bool}
  FirstFlag(bits)

def QueuedVacantAt(-board: Array<U32>, +pos: U32) -> Type:
  ({(pos < 81 : U32) == True{} : Bool} & {(cell_value(board,pos) < 1024 : U32) == True{} : Bool})

def FlaggedVacancies(-board: Array<U32>, +base: U32, +bits: U32) -> Type:
  @i:U32 -> {(i < 32 : U32) == True{} : Bool} ->
  {U32.and(flag_bit_at(i),bits) == flag_bit_at(i) : U32} ->
  QueuedVacantAt(board,(base + i : U32))

law urgent_position_from_flag_witness:
  for -board: Array<U32>
  for +base: U32
  for +bits: U32
  for flags: FlaggedVacancies(board,base,bits)
  for chosen: FirstFlag(bits)
  QueuedVacantAt(board,urgent_pos(base,bits))

law sound_flags_point_to_vacancy:
  for -board: Array<U32>
  for +base: U32
  for +bits: U32
  for flags: FlaggedVacancies(board,base,bits)
  for nonempty: {U32.is_eq(bits,0) == False{} : Bool}
  QueuedVacantAt(board,urgent_pos(base,bits))

def QueuedChoicePosition(-board: Array<U32>, -pos: U32) -> Type:
  Either<&1,&1,{pos == 81 : U32},({(pos < 81 : U32) == True{} : Bool} & {(cell_value(board,pos) < 1024 : U32) == True{} : Bool})>

def scalar_result_position(r: U32 & U32 & U32) -> U32:
  (pos,rest) = r
  pos

def scalar_choice_position(r: QueuedScanTuple()) -> U32:
  (board,tail) = r
  scalar_result_position(tail)

law queued_choose_between_valid_positions:
  for -b: Array<U32>
  for +take: Bool
  for +pos: U32
  for +best: U32
  for current: QueuedChoicePosition(b,pos)
  for prior: QueuedChoicePosition(b,best)
  QueuedChoicePosition(b,Bool.pick(U32,take,pos,best))

law queued_advance_position_is_valid:
  for -b: Array<U32>
  for +open: Bool
  for +pos: U32
  for +p: U32
  for +mask: U32
  for +size: U32
  for +word: U32
  for current: {open == True{} : Bool} -> QueuedVacantAt(b,pos)
  for prior: QueuedChoicePosition(b,p)
  QueuedChoicePosition(b,scalar_choice_position(Q.advance(open,pos,p,mask,size,b,word)))

law queued_vacancy_from_read_word:
  for -b: Array<U32>
  for +pos: U32
  for +word: U32
  for pos_ok: {(pos < 81 : U32) == True{} : Bool}
  for observe: {cell_value(b,pos) == word : U32}
  for open: {(word < 1024 : U32) == True{} : Bool}
  QueuedVacantAt(b,pos)

law duplicate_queued_read_equality:
  for -lhs: Array<U32> & U32
  for -rhs: Array<U32> & U32
  for same: {lhs == rhs : Array<U32> & U32}
  ({lhs == rhs : Array<U32> & U32} & {lhs == rhs : Array<U32> & U32})

law queued_inspected_with_real_word:
  for -b: Array<U32>
  for +pos: U32
  for +p: U32
  for +mask: U32
  for +size: U32
  for +word: U32
  for pos_ok: {(pos < 81 : U32) == True{} : Bool}
  for observed: ({Array.get(U32,b,pos) == (b,word) : Array<U32> & U32} & {Array.get(U32,b,pos) == (b,word) : Array<U32> & U32})
  for prior: QueuedChoicePosition(b,p)
  QueuedChoicePosition(b,scalar_choice_position(Q.inspected(pos,p,mask,size,Array.get(U32,b,pos))))

law queued_inspect_from_same_board:
  for -b: Array<U32>
  for +pos: U32
  for +p: U32
  for +mask: U32
  for +size: U32
  for -same: Array<U32>
  for +word: U32
  for pos_ok: {(pos < 81 : U32) == True{} : Bool}
  for same_board: {same == b : Array<U32>}
  for observed: {Array.get(U32,b,pos) == (same,word) : Array<U32> & U32}
  for prior: QueuedChoicePosition(b,p)
  QueuedChoicePosition(b,scalar_choice_position(Q.inspected(pos,p,mask,size,Array.get(U32,b,pos))))

law queued_inspect_from_witness:
  for -b: Array<U32>
  for +pos: U32
  for +p: U32
  for +mask: U32
  for +size: U32
  for pos_ok: {(pos < 81 : U32) == True{} : Bool}
  for observed: SameBoardRead(b,Array.get(U32,b,pos))
  for prior: QueuedChoicePosition(b,p)
  QueuedChoicePosition(b,scalar_choice_position(Q.inspected(pos,p,mask,size,Array.get(U32,b,pos))))

law queued_inspection_preserves_valid_position:
  for b: Array<U32>
  for +pos: U32
  for +p: U32
  for +mask: U32
  for +size: U32
  for pos_ok: {(pos < 81 : U32) == True{} : Bool}
  for prior: QueuedChoicePosition(b,p)
  QueuedChoicePosition(b,scalar_choice_position(Q.inspected(pos,p,mask,size,Array.get(U32,b,pos))))

# A low word is not by itself sufficient to exclude false completion:
# illegal bit zero plus the nine legal bits produces the sentinel's size 10.
law queued_out_of_contract_full_mask_can_leave_sentinel:
  ({(1023 < 1024 : U32) == True{} : Bool}
   & {C.scalar_size(1023) == 10 : U32}
   & {selector_choice(Q.start((Array.set(U32,[1024 : U32*128n],80,1023),80))) == C.Choice{81,0,10} : C.Choice})

def selector_result_position(r: C.Choice) -> U32:
  match r:
    case C.Choice{p,m,s}:
      p

def selector_position(r: QueuedSelectResult()) -> U32:
  selector_result_position(selector_choice(r))

def QueuedScanRange(+n: Nat, +pos: U32) -> Type:
  match n:
    case 0n:
      Unit
    case 1n+k:
      ({(pos < 81 : U32) == True{} : Bool} & QueuedScanRange(k,(pos + 1 : U32)))

def NextChoicePosition(-r: QueuedScanTuple()) -> Type:
  QueuedChoicePosition(scalar_board(r),scalar_choice_position(r))

def QueuedSafeScan(-r: QueuedScanTuple(), +n: Nat, +pos: U32) -> Type:
  QueuedScanRange(n,pos) -> NextChoicePosition(r) ->
  QueuedChoicePosition(scalar_board(r),selector_position(Q.scan(n,pos,r)))

def QueuedNextSafe(+n: Nat, +pos: U32) -> Type:
  @r:QueuedScanTuple() -> QueuedSafeScan(r,n,(pos + 1 : U32))

law queued_safe_scan_transport:
  for +n: Nat
  for +pos: U32
  for -b: Array<U32>
  for next: QueuedScanTuple()
  for same: {scalar_board(next) == b : Array<U32>}
  for safe: QueuedChoicePosition(b,scalar_choice_position(next))
  for range: QueuedScanRange(n,(pos + 1 : U32))
  for continue: QueuedNextSafe(n,pos)
  QueuedChoicePosition(b,selector_position(Q.scan(n,(pos + 1 : U32),next)))

law queued_safe_scan_step_image:
  for +n: Nat
  for +pos: U32
  for +p: U32
  for +mask: U32
  for +size: U32
  for +image: BoardImage
  for range: QueuedScanRange(1n+n,pos)
  for prior: QueuedChoicePosition(image_board(image),p)
  for continue: QueuedNextSafe(n,pos)
  QueuedChoicePosition(image_board(image),
    selector_position(Q.scan(n,(pos + 1 : U32),Q.inspected(pos,p,mask,size,Array.get(U32,image_board(image),pos)))))

law queued_safe_scan_step:
  for +n: Nat
  for +pos: U32
  for +p: U32
  for +mask: U32
  for +size: U32
  for b: Array<U32>
  for range: QueuedScanRange(1n+n,pos)
  for prior: QueuedChoicePosition(b,p)
  for continue: QueuedNextSafe(n,pos)
  QueuedChoicePosition(b,
    selector_position(Q.scan(n,(pos + 1 : U32),Q.inspected(pos,p,mask,size,Array.get(U32,b,pos)))))

law queued_safe_zero:
  for +pos: U32
  for -b: Array<U32>
  for +p: U32
  for +m: U32
  for +size: U32
  for prior: QueuedChoicePosition(b,p)
  QueuedChoicePosition(b,selector_position(Q.scan(0n,pos,(b,(p,(m,size))))))

law queued_safe_succ:
  for +n: Nat
  for +pos: U32
  for +p: U32
  for +m: U32
  for +size: U32
  for b: Array<U32>
  for range: QueuedScanRange(1n+n,pos)
  for prior: QueuedChoicePosition(b,p)
  for continue: QueuedNextSafe(n,pos)
  QueuedChoicePosition(b,selector_position(Q.scan(1n+n,pos,(b,(p,(m,size))))))

law queued_safe_last_zero:
  for +pos: U32
  for -b: Array<U32>
  for +p: U32
  for rest: U32 & U32
  QueuedSafeScan((b,(p,rest)),0n,pos)

law queued_safe_tail_zero:
  for +pos: U32
  for -b: Array<U32>
  for tail: U32 & U32 & U32
  QueuedSafeScan((b,tail),0n,pos)

law queued_safe_tuple_zero:
  for +pos: U32
  for r: QueuedScanTuple()
  QueuedSafeScan(r,0n,pos)

law queued_safe_last_succ:
  for +n: Nat
  for +pos: U32
  for b: Array<U32>
  for +p: U32
  for rest: U32 & U32
  for continue: QueuedNextSafe(n,pos)
  QueuedSafeScan((b,(p,rest)),1n+n,pos)

law queued_safe_tail_succ:
  for +n: Nat
  for +pos: U32
  for b: Array<U32>
  for tail: U32 & U32 & U32
  for continue: QueuedNextSafe(n,pos)
  QueuedSafeScan((b,tail),1n+n,pos)

law queued_safe_tuple_succ:
  for +n: Nat
  for +pos: U32
  for r: QueuedScanTuple()
  for continue: QueuedNextSafe(n,pos)
  QueuedSafeScan(r,1n+n,pos)

law queued_safe_scan:
  for +n: Nat
  for +pos: U32
  for r: QueuedScanTuple()
  QueuedSafeScan(r,n,pos)

law queued_safe_start:
  for b: Array<U32>
  for +pos: U32
  for range: QueuedScanRange(U32.to_nat((81 - pos : U32)),pos)
  QueuedChoicePosition(b,selector_position(Q.start((b,pos))))

def queued_range_guard(+n: Nat, +pos: U32) -> Bool:
  match n:
    case 0n:
      True{}
    case 1n+k:
      Bool.and((pos < 81 : U32),queued_range_guard(k,(pos + 1 : U32)))

law queued_guard_step:
  for +n: Nat
  for +pos: U32
  for tail: ({(pos < 81 : U32) == True{} : Bool} & {queued_range_guard(n,(pos + 1 : U32)) == True{} : Bool})
  for next: {queued_range_guard(n,(pos + 1 : U32)) == True{} : Bool} -> QueuedScanRange(n,(pos + 1 : U32))
  QueuedScanRange(1n+n,pos)

law queued_range_guard_sound:
  for +n: Nat
  for +pos: U32
  for checked: {queued_range_guard(n,pos) == True{} : Bool}
  QueuedScanRange(n,pos)

def QueuedStartGuard(+row: CellCoordinate, +col: CellCoordinate) -> Type:
  {queued_range_guard(U32.to_nat((81 - logical_position(row,col) : U32)),logical_position(row,col)) == True{} : Bool}

law queued_start_guard_row_0:
  for +col: CellCoordinate
  QueuedStartGuard(Coordinate0{},col)

law queued_start_guard_row_1:
  for +col: CellCoordinate
  QueuedStartGuard(Coordinate1{},col)

law queued_start_guard_row_2:
  for +col: CellCoordinate
  QueuedStartGuard(Coordinate2{},col)

law queued_start_guard_row_3:
  for +col: CellCoordinate
  QueuedStartGuard(Coordinate3{},col)

law queued_start_guard_row_4:
  for +col: CellCoordinate
  QueuedStartGuard(Coordinate4{},col)

law queued_start_guard_row_5:
  for +col: CellCoordinate
  QueuedStartGuard(Coordinate5{},col)

law queued_start_guard_row_6:
  for +col: CellCoordinate
  QueuedStartGuard(Coordinate6{},col)

law queued_start_guard_row_7:
  for +col: CellCoordinate
  QueuedStartGuard(Coordinate7{},col)

law queued_start_guard_row_8:
  for +col: CellCoordinate
  QueuedStartGuard(Coordinate8{},col)

law queued_start_guard_every_cell:
  for +row: CellCoordinate
  for +col: CellCoordinate
  QueuedStartGuard(row,col)

law queued_logical_start_range:
  for +row: CellCoordinate
  for +col: CellCoordinate
  QueuedScanRange(U32.to_nat((81 - logical_position(row,col) : U32)),logical_position(row,col))

law queued_logical_start_selects_only_vacancy_or_sentinel:
  for b: Array<U32>
  for +row: CellCoordinate
  for +col: CellCoordinate
  QueuedChoicePosition(b,selector_position(Q.start((b,logical_position(row,col)))))

law queued_end_start_returns_completion_marker:
  for -b: Array<U32>
  {selector_position(Q.start((b,81))) == 81 : U32}

# Once a real position is recorded, subsequent in-range inspections
# cannot return to the completion marker (position 81).
def NotCompleted(-pos: U32) -> Type:
  {pos == 81 : U32} -> Empty

law queued_in_range_not_completed:
  for +pos: U32
  for good: {(pos < 81 : U32) == True{} : Bool}
  NotCompleted(pos)

law queued_pick_keeps_non_sentinel:
  for +take: Bool
  for +pos: U32
  for +best: U32
  for now: NotCompleted(pos)
  for old: NotCompleted(best)
  NotCompleted(Bool.pick(U32,take,pos,best))

law queued_advance_keeps_non_sentinel:
  for -b: Array<U32>
  for +open: Bool
  for +pos: U32
  for +p: U32
  for +m: U32
  for +size: U32
  for +word: U32
  for now: NotCompleted(pos)
  for old: NotCompleted(p)
  NotCompleted(scalar_choice_position(Q.advance(open,pos,p,m,size,b,word)))

law queued_inspected_keeps_non_sentinel:
  for -b: Array<U32>
  for -r: Array<U32> & U32
  for +pos: U32
  for +p: U32
  for +m: U32
  for +size: U32
  for now: NotCompleted(pos)
  for old: NotCompleted(p)
  for read: SameBoardRead(b,r)
  NotCompleted(scalar_choice_position(Q.inspected(pos,p,m,size,r)))

law queued_read_keeps_non_sentinel:
  for b: Array<U32>
  for +pos: U32
  for +p: U32
  for +m: U32
  for +size: U32
  for in_range: {(pos < 81 : U32) == True{} : Bool}
  for old: NotCompleted(p)
  NotCompleted(scalar_choice_position(Q.inspected(pos,p,m,size,Array.get(U32,b,pos))))

law queued_eligible_raw_beats_no_candidate:
  for -b: Array<U32>
  for +pos: U32
  for +word: U32
  for open: {(word < 1024 : U32) == True{} : Bool}
  for better: {(C.scalar_size(word) < 10 : U32) == True{} : Bool}
  {scalar_choice_position(Q.inspected(pos,81,0,10,(b,word))) == pos : U32}

def QueuedSeenScan(-r: QueuedScanTuple(), +n: Nat, +pos: U32) -> Type:
  QueuedScanRange(n,pos) -> NotCompleted(scalar_choice_position(r)) ->
  NotCompleted(selector_position(Q.scan(n,pos,r)))

def QueuedNextSeen(+n: Nat, +pos: U32) -> Type:
  @next:QueuedScanTuple() -> QueuedSeenScan(next,n,(pos + 1 : U32))

law queued_seen_step_image:
  for +n: Nat
  for +pos: U32
  for +p: U32
  for +m: U32
  for +size: U32
  for +image: BoardImage
  for range: QueuedScanRange(1n+n,pos)
  for old: NotCompleted(p)
  for later: QueuedNextSeen(n,pos)
  NotCompleted(selector_position(Q.scan(n,(pos + 1 : U32),
    Q.inspected(pos,p,m,size,Array.get(U32,image_board(image),pos)))))

law queued_seen_step:
  for +n: Nat
  for +pos: U32
  for +p: U32
  for +m: U32
  for +size: U32
  for b: Array<U32>
  for range: QueuedScanRange(1n+n,pos)
  for old: NotCompleted(p)
  for later: QueuedNextSeen(n,pos)
  NotCompleted(selector_position(Q.scan(n,(pos + 1 : U32),
    Q.inspected(pos,p,m,size,Array.get(U32,b,pos)))))

law queued_seen_zero:
  for +pos: U32
  for -b: Array<U32>
  for +p: U32
  for +m: U32
  for +size: U32
  for prior: NotCompleted(p)
  NotCompleted(selector_position(Q.scan(0n,pos,(b,(p,(m,size))))))

law queued_seen_succ:
  for +n: Nat
  for +pos: U32
  for +p: U32
  for +m: U32
  for +size: U32
  for b: Array<U32>
  for range: QueuedScanRange(1n+n,pos)
  for prior: NotCompleted(p)
  for continue: QueuedNextSeen(n,pos)
  NotCompleted(selector_position(Q.scan(1n+n,pos,(b,(p,(m,size))))))

law queued_seen_last_zero:
  for +pos: U32
  for -b: Array<U32>
  for +p: U32
  for rest: U32 & U32
  QueuedSeenScan((b,(p,rest)),0n,pos)

law queued_seen_tail_zero:
  for +pos: U32
  for -b: Array<U32>
  for tail: U32 & U32 & U32
  QueuedSeenScan((b,tail),0n,pos)

law queued_seen_tuple_zero:
  for +pos: U32
  for r: QueuedScanTuple()
  QueuedSeenScan(r,0n,pos)

law queued_seen_last_succ:
  for +n: Nat
  for +pos: U32
  for b: Array<U32>
  for +p: U32
  for rest: U32 & U32
  for continue: QueuedNextSeen(n,pos)
  QueuedSeenScan((b,(p,rest)),1n+n,pos)

law queued_seen_tail_succ:
  for +n: Nat
  for +pos: U32
  for b: Array<U32>
  for tail: U32 & U32 & U32
  for continue: QueuedNextSeen(n,pos)
  QueuedSeenScan((b,tail),1n+n,pos)

law queued_seen_tuple_succ:
  for +n: Nat
  for +pos: U32
  for r: QueuedScanTuple()
  for continue: QueuedNextSeen(n,pos)
  QueuedSeenScan(r,1n+n,pos)

law queued_seen_scan:
  for +n: Nat
  for +pos: U32
  for r: QueuedScanTuple()
  QueuedSeenScan(r,n,pos)


def QueueEligibleWord(-word: U32) -> Type:
  ({(word < 1024 : U32) == True{} : Bool} & {(C.scalar_size(word) < 10 : U32) == True{} : Bool})

def QueueEligibleAt(-b: Array<U32>, +pos: U32) -> Type:
  QueueEligibleWord(cell_value(b,pos))

def QueueHasEligible(-b: Array<U32>, +n: Nat, +pos: U32) -> Type:
  match n:
    case 0n:
      Empty
    case 1n+k:
      Either<&1,&1,QueueEligibleAt(b,pos),QueueHasEligible(b,k,(pos + 1 : U32))>

def QueueInitial(b: Array<U32>) -> QueuedScanTuple():
  (b,(81,(0,10)))

def QueuedInitialScanProgress(-b: Array<U32>, +n: Nat, +pos: U32) -> Type:
  QueuedScanRange(n,pos) -> QueueHasEligible(b,n,pos) ->
  NotCompleted(selector_position(Q.scan(n,pos,QueueInitial(b))))

law queued_eligible_actual_initial_non_sentinel:
  for -b: Array<U32>
  for +pos: U32
  for +word: U32
  for range: {(pos < 81 : U32) == True{} : Bool}
  for yes: QueueEligibleWord(word)
  NotCompleted(scalar_choice_position(Q.inspected(pos,81,0,10,(b,word))))

law queued_initial_closed_keeps_tuple:
  for -b: Array<U32>
  for +pos: U32
  for +word: U32
  for closed: {(word < 1024 : U32) == False{} : Bool}
  {Q.inspected(pos,81,0,10,(b,word)) == QueueInitial(b) : QueuedScanTuple()}

law queued_initial_not_better_keeps_tuple:
  for -b: Array<U32>
  for +pos: U32
  for +word: U32
  for open: {(word < 1024 : U32) == True{} : Bool}
  for size: {(C.scalar_size(word) < 10 : U32) == False{} : Bool}
  {Q.inspected(pos,81,0,10,(b,word)) == QueueInitial(b) : QueuedScanTuple()}

def QueuedInitialStep(-b: Array<U32>, +pos: U32, +word: U32) -> Type:
  Either<&1,&1,NotCompleted(scalar_choice_position(Q.inspected(pos,81,0,10,(b,word)))),
    {Q.inspected(pos,81,0,10,(b,word)) == QueueInitial(b) : QueuedScanTuple()}>

law queued_initial_step_size:
  for -b: Array<U32>
  for +pos: U32
  for +word: U32
  for +small: Bool
  for range: {(pos < 81 : U32) == True{} : Bool}
  for open: {(word < 1024 : U32) == True{} : Bool}
  for size: {(C.scalar_size(word) < 10 : U32) == small : Bool}
  QueuedInitialStep(b,pos,word)

law queued_initial_step_open:
  for -b: Array<U32>
  for +pos: U32
  for +word: U32
  for +open: Bool
  for range: {(pos < 81 : U32) == True{} : Bool}
  for observed: {(word < 1024 : U32) == open : Bool}
  QueuedInitialStep(b,pos,word)

law queued_initial_step_classifies:
  for -b: Array<U32>
  for +pos: U32
  for +word: U32
  for range: {(pos < 81 : U32) == True{} : Bool}
  QueuedInitialStep(b,pos,word)

law queued_eligible_word_from_read:
  for -b: Array<U32>
  for +pos: U32
  for +word: U32
  for observe: {cell_value(b,pos) == word : U32}
  for proof: QueueEligibleAt(b,pos)
  QueueEligibleWord(word)

def QueuedProgressNext(+n: Nat, +pos: U32) -> Type:
  @b:Array<U32> -> QueuedInitialScanProgress(b,n,(pos + 1 : U32))

law queued_progress_decision:
  for +image: BoardImage
  for +n: Nat
  for +pos: U32
  for +word: U32
  for range: QueuedScanRange(n,(pos + 1 : U32))
  for tail: QueueHasEligible(image_board(image),n,(pos + 1 : U32))
  for step: QueuedInitialStep(image_board(image),pos,word)
  for later: QueuedProgressNext(n,pos)
  NotCompleted(selector_position(Q.scan(n,(pos + 1 : U32),Q.inspected(pos,81,0,10,(image_board(image),word)))))

law queued_progress_use_witness:
  for +image: BoardImage
  for +n: Nat
  for +pos: U32
  for +word: U32
  for real: {cell_value(image_board(image),pos) == word : U32}
  for in_range: {(pos < 81 : U32) == True{} : Bool}
  for range: QueuedScanRange(n,(pos + 1 : U32))
  for has_one: QueueHasEligible(image_board(image),1n+n,pos)
  for later: QueuedProgressNext(n,pos)
  NotCompleted(selector_position(Q.scan(n,(pos + 1 : U32),Q.inspected(pos,81,0,10,(image_board(image),word)))))

law queued_progress_real_word:
  for +image: BoardImage
  for +n: Nat
  for +pos: U32
  for +word: U32
  for interval: QueuedScanRange(1n+n,pos)
  for has_one: QueueHasEligible(image_board(image),1n+n,pos)
  for observed:
    ({Array.get(U32,image_board(image),pos) == (image_board(image),word) : Array<U32> & U32} &
     {Array.get(U32,image_board(image),pos) == (image_board(image),word) : Array<U32> & U32})
  for later: QueuedProgressNext(n,pos)
  NotCompleted(selector_position(Q.scan(1n+n,pos,QueueInitial(image_board(image)))))

law queued_progress_observed:
  for +image: BoardImage
  for +n: Nat
  for +pos: U32
  for interval: QueuedScanRange(1n+n,pos)
  for has_one: QueueHasEligible(image_board(image),1n+n,pos)
  for observed: SameBoardRead(image_board(image),Array.get(U32,image_board(image),pos))
  for later: QueuedProgressNext(n,pos)
  NotCompleted(selector_position(Q.scan(1n+n,pos,QueueInitial(image_board(image)))))

law queued_initial_progress_image:
  for +image: BoardImage
  for +n: Nat
  for +pos: U32
  for later: QueuedProgressNext(n,pos)
  QueuedInitialScanProgress(image_board(image),1n+n,pos)

law queued_initial_progress_step:
  for b: Array<U32>
  for +n: Nat
  for +pos: U32
  for later: QueuedProgressNext(n,pos)
  QueuedInitialScanProgress(b,1n+n,pos)

law queued_scan_cannot_hide_eligible:
  for +n: Nat
  for +pos: U32
  for b: Array<U32>
  QueuedInitialScanProgress(b,n,pos)

law queued_logical_start_cannot_hide_eligible:
  for b: Array<U32>
  for +row: CellCoordinate
  for +col: CellCoordinate
  for exists: QueueHasEligible(b,U32.to_nat((81 - logical_position(row,col) : U32)),logical_position(row,col))
  NotCompleted(selector_position(Q.start((b,logical_position(row,col)))))

law queued_eligible_at_window_middle:
  for +before: Nat
  for -b: Array<U32>
  for +start: U32
  for +after: Nat
  for witness: QueueEligibleAt(b,walk_position(before,start))
  QueueHasEligible(b,with_center(before,after),start)

law queued_scanned_eligible_prevents_completion:
  for b: Array<U32>
  for +start: U32
  for +before: Nat
  for +after: Nat
  for range: QueuedScanRange(with_center(before,after),start)
  for witness: QueueEligibleAt(b,walk_position(before,start))
  NotCompleted(selector_position(Q.scan(with_center(before,after),start,QueueInitial(b))))

law queued_completion_conflicts_with_eligible:
  for b: Array<U32>
  for +row: CellCoordinate
  for +col: CellCoordinate
  for exists: QueueHasEligible(b,U32.to_nat((81 - logical_position(row,col) : U32)),logical_position(row,col))
  for completed: {selector_position(Q.start((b,logical_position(row,col)))) == 81 : U32}
  Empty

def eligible_candidate_bits(+bits: Word(9n)) -> Bool:
  +mask = candidate_bits_word(bits)
  Bool.and((mask < 1024 : U32),(C.scalar_size(mask) < 10 : U32))

def candidate_eligibility_tree_9(+b0: Bool,+b1: Bool,+b2: Bool,+b3: Bool,+b4: Bool,+b5: Bool,+b6: Bool,+b7: Bool,+b8: Bool) -> Bool:
  eligible_candidate_bits(WCon{b0,WCon{b1,WCon{b2,WCon{b3,WCon{b4,WCon{b5,WCon{b6,WCon{b7,WCon{b8,WNil{}}}}}}}}}})

def candidate_eligibility_tree_8(+b0: Bool,+b1: Bool,+b2: Bool,+b3: Bool,+b4: Bool,+b5: Bool,+b6: Bool,+b7: Bool) -> Bool:
  Bool.and(candidate_eligibility_tree_9(b0,b1,b2,b3,b4,b5,b6,b7,False{}),candidate_eligibility_tree_9(b0,b1,b2,b3,b4,b5,b6,b7,True{}))

def candidate_eligibility_tree_7(+b0: Bool,+b1: Bool,+b2: Bool,+b3: Bool,+b4: Bool,+b5: Bool,+b6: Bool) -> Bool:
  Bool.and(candidate_eligibility_tree_8(b0,b1,b2,b3,b4,b5,b6,False{}),candidate_eligibility_tree_8(b0,b1,b2,b3,b4,b5,b6,True{}))

def candidate_eligibility_tree_6(+b0: Bool,+b1: Bool,+b2: Bool,+b3: Bool,+b4: Bool,+b5: Bool) -> Bool:
  Bool.and(candidate_eligibility_tree_7(b0,b1,b2,b3,b4,b5,False{}),candidate_eligibility_tree_7(b0,b1,b2,b3,b4,b5,True{}))

def candidate_eligibility_tree_5(+b0: Bool,+b1: Bool,+b2: Bool,+b3: Bool,+b4: Bool) -> Bool:
  Bool.and(candidate_eligibility_tree_6(b0,b1,b2,b3,b4,False{}),candidate_eligibility_tree_6(b0,b1,b2,b3,b4,True{}))

def candidate_eligibility_tree_4(+b0: Bool,+b1: Bool,+b2: Bool,+b3: Bool) -> Bool:
  Bool.and(candidate_eligibility_tree_5(b0,b1,b2,b3,False{}),candidate_eligibility_tree_5(b0,b1,b2,b3,True{}))

def candidate_eligibility_tree_3(+b0: Bool,+b1: Bool,+b2: Bool) -> Bool:
  Bool.and(candidate_eligibility_tree_4(b0,b1,b2,False{}),candidate_eligibility_tree_4(b0,b1,b2,True{}))

def candidate_eligibility_tree_2(+b0: Bool,+b1: Bool) -> Bool:
  Bool.and(candidate_eligibility_tree_3(b0,b1,False{}),candidate_eligibility_tree_3(b0,b1,True{}))

def candidate_eligibility_tree_1(+b0: Bool) -> Bool:
  Bool.and(candidate_eligibility_tree_2(b0,False{}),candidate_eligibility_tree_2(b0,True{}))

def candidate_eligibility_tree_0() -> Bool:
  Bool.and(candidate_eligibility_tree_1(False{}),candidate_eligibility_tree_1(True{}))

law check_candidate_eligibility_tree_9:
  for +b0: Bool
  for +b1: Bool
  for +b2: Bool
  for +b3: Bool
  for +b4: Bool
  for +b5: Bool
  for +b6: Bool
  for +b7: Bool
  for +b8: Bool
  for +suffix: Word(0n)
  for checked: {candidate_eligibility_tree_9(b0,b1,b2,b3,b4,b5,b6,b7,b8) == True{} : Bool}
  {eligible_candidate_bits(WCon{b0,WCon{b1,WCon{b2,WCon{b3,WCon{b4,WCon{b5,WCon{b6,WCon{b7,WCon{b8,suffix}}}}}}}}}) == True{} : Bool}

law select_eligibility_subtree_8:
  for +b0: Bool
  for +b1: Bool
  for +b2: Bool
  for +b3: Bool
  for +b4: Bool
  for +b5: Bool
  for +b6: Bool
  for +b7: Bool
  for +bit: Bool
  for both: ({candidate_eligibility_tree_9(b0,b1,b2,b3,b4,b5,b6,b7,False{}) == True{} : Bool} & {candidate_eligibility_tree_9(b0,b1,b2,b3,b4,b5,b6,b7,True{}) == True{} : Bool})
  {candidate_eligibility_tree_9(b0,b1,b2,b3,b4,b5,b6,b7,bit) == True{} : Bool}

law check_candidate_eligibility_tree_8:
  for +b0: Bool
  for +b1: Bool
  for +b2: Bool
  for +b3: Bool
  for +b4: Bool
  for +b5: Bool
  for +b6: Bool
  for +b7: Bool
  for +suffix: Word(1n)
  for checked: {candidate_eligibility_tree_8(b0,b1,b2,b3,b4,b5,b6,b7) == True{} : Bool}
  {eligible_candidate_bits(WCon{b0,WCon{b1,WCon{b2,WCon{b3,WCon{b4,WCon{b5,WCon{b6,WCon{b7,suffix}}}}}}}}) == True{} : Bool}

law select_eligibility_subtree_7:
  for +b0: Bool
  for +b1: Bool
  for +b2: Bool
  for +b3: Bool
  for +b4: Bool
  for +b5: Bool
  for +b6: Bool
  for +bit: Bool
  for both: ({candidate_eligibility_tree_8(b0,b1,b2,b3,b4,b5,b6,False{}) == True{} : Bool} & {candidate_eligibility_tree_8(b0,b1,b2,b3,b4,b5,b6,True{}) == True{} : Bool})
  {candidate_eligibility_tree_8(b0,b1,b2,b3,b4,b5,b6,bit) == True{} : Bool}

law check_candidate_eligibility_tree_7:
  for +b0: Bool
  for +b1: Bool
  for +b2: Bool
  for +b3: Bool
  for +b4: Bool
  for +b5: Bool
  for +b6: Bool
  for +suffix: Word(2n)
  for checked: {candidate_eligibility_tree_7(b0,b1,b2,b3,b4,b5,b6) == True{} : Bool}
  {eligible_candidate_bits(WCon{b0,WCon{b1,WCon{b2,WCon{b3,WCon{b4,WCon{b5,WCon{b6,suffix}}}}}}}) == True{} : Bool}

law select_eligibility_subtree_6:
  for +b0: Bool
  for +b1: Bool
  for +b2: Bool
  for +b3: Bool
  for +b4: Bool
  for +b5: Bool
  for +bit: Bool
  for both: ({candidate_eligibility_tree_7(b0,b1,b2,b3,b4,b5,False{}) == True{} : Bool} & {candidate_eligibility_tree_7(b0,b1,b2,b3,b4,b5,True{}) == True{} : Bool})
  {candidate_eligibility_tree_7(b0,b1,b2,b3,b4,b5,bit) == True{} : Bool}

law check_candidate_eligibility_tree_6:
  for +b0: Bool
  for +b1: Bool
  for +b2: Bool
  for +b3: Bool
  for +b4: Bool
  for +b5: Bool
  for +suffix: Word(3n)
  for checked: {candidate_eligibility_tree_6(b0,b1,b2,b3,b4,b5) == True{} : Bool}
  {eligible_candidate_bits(WCon{b0,WCon{b1,WCon{b2,WCon{b3,WCon{b4,WCon{b5,suffix}}}}}}) == True{} : Bool}

law select_eligibility_subtree_5:
  for +b0: Bool
  for +b1: Bool
  for +b2: Bool
  for +b3: Bool
  for +b4: Bool
  for +bit: Bool
  for both: ({candidate_eligibility_tree_6(b0,b1,b2,b3,b4,False{}) == True{} : Bool} & {candidate_eligibility_tree_6(b0,b1,b2,b3,b4,True{}) == True{} : Bool})
  {candidate_eligibility_tree_6(b0,b1,b2,b3,b4,bit) == True{} : Bool}

law check_candidate_eligibility_tree_5:
  for +b0: Bool
  for +b1: Bool
  for +b2: Bool
  for +b3: Bool
  for +b4: Bool
  for +suffix: Word(4n)
  for checked: {candidate_eligibility_tree_5(b0,b1,b2,b3,b4) == True{} : Bool}
  {eligible_candidate_bits(WCon{b0,WCon{b1,WCon{b2,WCon{b3,WCon{b4,suffix}}}}}) == True{} : Bool}

law select_eligibility_subtree_4:
  for +b0: Bool
  for +b1: Bool
  for +b2: Bool
  for +b3: Bool
  for +bit: Bool
  for both: ({candidate_eligibility_tree_5(b0,b1,b2,b3,False{}) == True{} : Bool} & {candidate_eligibility_tree_5(b0,b1,b2,b3,True{}) == True{} : Bool})
  {candidate_eligibility_tree_5(b0,b1,b2,b3,bit) == True{} : Bool}

law check_candidate_eligibility_tree_4:
  for +b0: Bool
  for +b1: Bool
  for +b2: Bool
  for +b3: Bool
  for +suffix: Word(5n)
  for checked: {candidate_eligibility_tree_4(b0,b1,b2,b3) == True{} : Bool}
  {eligible_candidate_bits(WCon{b0,WCon{b1,WCon{b2,WCon{b3,suffix}}}}) == True{} : Bool}

law select_eligibility_subtree_3:
  for +b0: Bool
  for +b1: Bool
  for +b2: Bool
  for +bit: Bool
  for both: ({candidate_eligibility_tree_4(b0,b1,b2,False{}) == True{} : Bool} & {candidate_eligibility_tree_4(b0,b1,b2,True{}) == True{} : Bool})
  {candidate_eligibility_tree_4(b0,b1,b2,bit) == True{} : Bool}

law check_candidate_eligibility_tree_3:
  for +b0: Bool
  for +b1: Bool
  for +b2: Bool
  for +suffix: Word(6n)
  for checked: {candidate_eligibility_tree_3(b0,b1,b2) == True{} : Bool}
  {eligible_candidate_bits(WCon{b0,WCon{b1,WCon{b2,suffix}}}) == True{} : Bool}

law select_eligibility_subtree_2:
  for +b0: Bool
  for +b1: Bool
  for +bit: Bool
  for both: ({candidate_eligibility_tree_3(b0,b1,False{}) == True{} : Bool} & {candidate_eligibility_tree_3(b0,b1,True{}) == True{} : Bool})
  {candidate_eligibility_tree_3(b0,b1,bit) == True{} : Bool}

law check_candidate_eligibility_tree_2:
  for +b0: Bool
  for +b1: Bool
  for +suffix: Word(7n)
  for checked: {candidate_eligibility_tree_2(b0,b1) == True{} : Bool}
  {eligible_candidate_bits(WCon{b0,WCon{b1,suffix}}) == True{} : Bool}

law select_eligibility_subtree_1:
  for +b0: Bool
  for +bit: Bool
  for both: ({candidate_eligibility_tree_2(b0,False{}) == True{} : Bool} & {candidate_eligibility_tree_2(b0,True{}) == True{} : Bool})
  {candidate_eligibility_tree_2(b0,bit) == True{} : Bool}

law check_candidate_eligibility_tree_1:
  for +b0: Bool
  for +suffix: Word(8n)
  for checked: {candidate_eligibility_tree_1(b0) == True{} : Bool}
  {eligible_candidate_bits(WCon{b0,suffix}) == True{} : Bool}

law select_eligibility_subtree_0:
  for +bit: Bool
  for both: ({candidate_eligibility_tree_1(False{}) == True{} : Bool} & {candidate_eligibility_tree_1(True{}) == True{} : Bool})
  {candidate_eligibility_tree_1(bit) == True{} : Bool}

law check_candidate_eligibility_tree_0:
  for +suffix: Word(9n)
  for checked: {candidate_eligibility_tree_0() == True{} : Bool}
  {eligible_candidate_bits(suffix) == True{} : Bool}

law check_all_normalized_candidate_masks:
  {candidate_eligibility_tree_0() == True{} : Bool}

law normalized_candidate_bits_are_eligible:
  for +bits: Word(9n)
  QueueEligibleWord(candidate_bits_word(bits))

law normalized_word_eligibility_from_bits:
  for +raw: U32
  for image: CandidateMaskImage(raw)
  QueueEligibleWord(U32.and(1022,raw))

law normalized_masks_are_eligible:
  for +mask: U32
  for normalized: {U32.and(1022,mask) == mask : U32}
  QueueEligibleWord(mask)

law queued_visible_normalized_word_board_image:
  for +image: BoardImage
  for +start: U32
  for +before: Nat
  for +after: Nat
  for interval: QueuedScanRange(with_center(before,after),start)
  for normalized: {U32.and(1022,cell_value(image_board(image),walk_position(before,start))) == cell_value(image_board(image),walk_position(before,start)) : U32}
  NotCompleted(selector_position(Q.scan(with_center(before,after),start,QueueInitial(image_board(image)))))

law queued_visible_normalized_word_prevents_completion:
  for b: Array<U32>
  for +start: U32
  for +before: Nat
  for +after: Nat
  for interval: QueuedScanRange(with_center(before,after),start)
  for normalized: {U32.and(1022,cell_value(b,walk_position(before,start))) == cell_value(b,walk_position(before,start)) : U32}
  NotCompleted(selector_position(Q.scan(with_center(before,after),start,QueueInitial(b))))


# The real cache inversion and the actual blank encoder produce bits 1..9.
def NormalizedQueueMask(+mask: U32) -> Type:
  {U32.and(1022,mask) == mask : U32}

law word_clip_repeat:
  for +n: Nat
  for +clip: Word(n)
  for +word: Word(n)
  {Word.and(n,clip,Word.and(n,clip,word)) == Word.and(n,clip,word) : Word(n)}

law trim_is_normalized:
  for +raw: U32
  NormalizedQueueMask(U32.and(1022,raw))

law inverted_mask_is_normalized:
  for cells: Array<U32> & U32
  NormalizedQueueMask(Pair.snd(Array<U32>,U32,C.invert(cells)))

law cached_mask_is_normalized:
  for b: Array<U32>
  for +p: U32
  NormalizedQueueMask(cached_word(b,p))

def EncodedBlankMask(-b: Array<U32>, +p: U32) -> Type:
  Board128(b) -> RoutedApart(flag_slot(p),p) ->
  NormalizedQueueMask(cell_value(Q.encoded(p,(b,0)),p))

law encoded_blank_mask_image:
  for +image: BoardImage
  for +p: U32
  EncodedBlankMask(image_board(image),p)

law encoded_blank_mask:
  for b: Array<U32>
  for +p: U32
  EncodedBlankMask(b,p)

def ActualEncodedBlankMask(-b: Array<U32>, +p: U32) -> Type:
  Board128(b) -> RoutedApart(flag_slot(p),p) -> {cell_value(b,p) == 0 : U32} ->
  NormalizedQueueMask(cell_value(actual_encoded_step(b,p),p))

law actual_encoded_blank_mask_image:
  for +image: BoardImage
  for +p: U32
  ActualEncodedBlankMask(image_board(image),p)

law actual_encoded_blank_mask:
  for b: Array<U32>
  for +p: U32
  ActualEncodedBlankMask(b,p)

law word_clip_and_interchange:
  for +n: Nat
  for +clip: Word(n)
  for +a: Word(n)
  for +b: Word(n)
  {Word.and(n,clip,Word.and(n,a,b)) == Word.and(n,Word.and(n,clip,a),b) : Word(n)}

law normalized_word_intersect:
  for +a: U32
  for +b: U32
  for normalized: NormalizedQueueMask(a)
  NormalizedQueueMask(U32.and(a,b))

law peer_mask_keeps_normalized:
  for +old: U32
  for +bit: U32
  for normalized: NormalizedQueueMask(old)
  NormalizedQueueMask(peer_mask(old,bit))

law changed_peer_word_image:
  for +image: BoardImage
  for +p: U32
  for +bit: U32
  for +old: U32
  for shape: Board128(image_board(image))
  for apart: RoutedApart(flag_slot(p),p)
  {cell_value(Q.changed(True{},p,bit,image_board(image),old),p) == peer_mask(old,bit) : U32}

def PeerKeepsNormalized(-b: Array<U32>, +p: U32, +bit: U32) -> Type:
  Board128(b) -> RoutedApart(flag_slot(p),p) -> NormalizedQueueMask(cell_value(b,p)) ->
  NormalizedQueueMask(cell_value(actual_peer(b,p,bit),p))

law peer_keeps_normalized_image:
  for +image: BoardImage
  for +p: U32
  for +bit: U32
  PeerKeepsNormalized(image_board(image),p,bit)

law peer_keeps_normalized:
  for b: Array<U32>
  for +p: U32
  for +bit: U32
  PeerKeepsNormalized(b,p,bit)

law peer_changed_word_keeps_normalized:
  for +image: BoardImage
  for +needed: Bool
  for +p: U32
  for +bit: U32
  for shape: Board128(image_board(image))
  for apart: RoutedApart(flag_slot(p),p)
  for normalized: NormalizedQueueMask(cell_value(image_board(image),p))
  NormalizedQueueMask(cell_value(Q.changed(needed,p,bit,image_board(image),cell_value(image_board(image),p)),p))

# Full actual encoder preserves normalized-mask shape for every input blank.
def EncodeMiddleMask(-b: Array<U32>, +prefix: Nat, +suffix: Nat, +p: U32) -> Type:
  Board128(b) ->
  EncodeApart(prefix,p,walk_position(prefix,p)) ->
  RoutedApart(flag_slot(walk_position(prefix,p)),walk_position(prefix,p)) ->
  EncodeApart(suffix,(walk_position(prefix,p) + 1 : U32),walk_position(prefix,p)) ->
  {cell_value(b,walk_position(prefix,p)) == 0 : U32} ->
  NormalizedQueueMask(cell_value(Q.encode_go(with_center(prefix,suffix),p,b),walk_position(prefix,p)))

def EncodeMiddleMaskProof(+prefix: Nat, +suffix: Nat, +p: U32) -> Type:
  @b:Array<U32> -> EncodeMiddleMask(b,prefix,suffix,p)

law encode_mask_middle_base_image:
  for +image: BoardImage
  for +suffix: Nat
  for +p: U32
  for shapes: (Board128(image_board(image)) & Board128(image_board(image)))
  for safe: RoutedApart(flag_slot(p),p)
  for tail: EncodeApart(suffix,(p + 1 : U32),p)
  for digit: {cell_value(image_board(image),p) == 0 : U32}
  NormalizedQueueMask(cell_value(Q.encode_go(1n+suffix,p,image_board(image)),p))

law encode_mask_middle_base:
  for +image: BoardImage
  for +suffix: Nat
  for +p: U32
  EncodeMiddleMask(image_board(image),0n,suffix,p)

law encode_mask_middle_step_image:
  for +image: BoardImage
  for +k: Nat
  for +suffix: Nat
  for +p: U32
  for shapes: (Board128(image_board(image)) & Board128(image_board(image)))
  for before: EncodeApart(1n+k,p,walk_position(1n+k,p))
  for safe: RoutedApart(flag_slot(walk_position(1n+k,p)),walk_position(1n+k,p))
  for after: EncodeApart(suffix,(walk_position(1n+k,p) + 1 : U32),walk_position(1n+k,p))
  for digit: {cell_value(image_board(image),walk_position(1n+k,p)) == 0 : U32}
  for next: EncodeMiddleMaskProof(k,suffix,(p + 1 : U32))
  NormalizedQueueMask(cell_value(Q.encode_go(with_center(1n+k,suffix),p,image_board(image)),walk_position(1n+k,p)))

law encode_mask_middle_step:
  for +image: BoardImage
  for +k: Nat
  for +suffix: Nat
  for +p: U32
  for next: EncodeMiddleMaskProof(k,suffix,(p + 1 : U32))
  EncodeMiddleMask(image_board(image),1n+k,suffix,p)

law encode_mask_middle_from_image:
  for +prefix: Nat
  for +image: BoardImage
  for +suffix: Nat
  for +p: U32
  EncodeMiddleMask(image_board(image),prefix,suffix,p)

law encode_mask_middle_value:
  for b: Array<U32>
  for +prefix: Nat
  for +suffix: Nat
  for +p: U32
  EncodeMiddleMask(b,prefix,suffix,p)


def Encode81BlankMask(-b: Array<U32>, +before: Nat, +after: Nat) -> Type:
  Board128(b) ->
  RoutedApart(109,walk_position(before,0)) ->
  RoutedApart(110,walk_position(before,0)) ->
  RoutedApart(111,walk_position(before,0)) ->
  EncodeApart(before,0,walk_position(before,0)) ->
  RoutedApart(flag_slot(walk_position(before,0)),walk_position(before,0)) ->
  EncodeApart(after,(walk_position(before,0) + 1 : U32),walk_position(before,0)) ->
  {with_center(before,after) == 81n : Nat} ->
  {cell_value(b,walk_position(before,0)) == 0 : U32} ->
  NormalizedQueueMask(cell_value(Q.encode(b),walk_position(before,0)))

law encode81_blank_mask_step:
  for +image: BoardImage
  for +before: Nat
  for +after: Nat
  for shapes: (Board128(image_board(image)) & Board128(image_board(image)))
  for r9: RoutedApart(109,walk_position(before,0))
  for r10: RoutedApart(110,walk_position(before,0))
  for r11: RoutedApart(111,walk_position(before,0))
  for ep: EncodeApart(before,0,walk_position(before,0))
  for safe: RoutedApart(flag_slot(walk_position(before,0)),walk_position(before,0))
  for es: EncodeApart(after,(walk_position(before,0) + 1 : U32),walk_position(before,0))
  for count: {with_center(before,after) == 81n : Nat}
  for digit: {cell_value(image_board(image),walk_position(before,0)) == 0 : U32}
  NormalizedQueueMask(cell_value(Q.encode(image_board(image)),walk_position(before,0)))

law encode81_blank_mask_image:
  for +image: BoardImage
  for +before: Nat
  for +after: Nat
  Encode81BlankMask(image_board(image),before,after)

law public_queue_encode_blank_mask_at:
  for b: Array<U32>
  for +before: Nat
  for +after: Nat
  Encode81BlankMask(b,before,after)

law public_encode_blank_mask_routes:
  for b: Array<U32>
  for +before: Nat
  for +after: Nat
  for shape: Board128(b)
  for routes: WindowRoutes(before,after,walk_position(before,0),(walk_position(before,0) + 1 : U32))
  for count: {with_center(before,after) == 81n : Nat}
  for digit: {cell_value(b,walk_position(before,0)) == 0 : U32}
  NormalizedQueueMask(cell_value(Q.encode(b),walk_position(before,0)))

law public_encode_blank_mask_checked:
  for b: Array<U32>
  for +before: Nat
  for +after: Nat
  for shape: Board128(b)
  for window: VerifiedWindow(before,after)
  for digit: {cell_value(b,walk_position(before,0)) == 0 : U32}
  NormalizedQueueMask(cell_value(Q.encode(b),walk_position(before,0)))

law any_logical_cell_encode_blank_mask:
  for b: Array<U32>
  for +row: CellCoordinate
  for +col: CellCoordinate
  for shape: Board128(b)
  for digit: {cell_value(b,logical_position(row,col)) == 0 : U32}
  NormalizedQueueMask(cell_value(Q.encode(b),logical_position(row,col)))



law adaptive_activation_blank_is_eligible_image:
  for +image: BoardImage
  for +row: CellCoordinate
  for +col: CellCoordinate
  for shape: Board128(image_board(image))
  for blank: {cell_value(image_board(image),logical_position(row,col)) == 0 : U32}
  QueueEligibleWord(cell_value(Fast.activated(False{},image_board(image)),logical_position(row,col)))

law adaptive_activation_blank_is_eligible:
  for b: Array<U32>
  for +row: CellCoordinate
  for +col: CellCoordinate
  for shape: Board128(b)
  for blank: {cell_value(b,logical_position(row,col)) == 0 : U32}
  QueueEligibleWord(cell_value(Fast.activated(False{},b),logical_position(row,col)))

# The pointwise invariant carries its own distinct flag route for peer self visits.
def SafeNormalizedAt(-b: Array<U32>, +q: U32) -> Type:
  (RoutedApart(flag_slot(q),q) & Board128(b) & NormalizedQueueMask(cell_value(b,q)))

law peer_keeps_normalized_same_parts:
  for +image: BoardImage
  for +q: U32
  for +digit: BoardDigit
  for routes: (RoutedApart(flag_slot(q),q) & RoutedApart(flag_slot(q),q))
  for shapes: (Board128(image_board(image)) & Board128(image_board(image)))
  for prior: NormalizedQueueMask(cell_value(image_board(image),q))
  SafeNormalizedAt(actual_peer(image_board(image),q,B.bit(digit_word(digit))),q)

law peer_keeps_normalized_same:
  for +image: BoardImage
  for +q: U32
  for +digit: BoardDigit
  for prior: SafeNormalizedAt(image_board(image),q)
  SafeNormalizedAt(actual_peer(image_board(image),q,B.bit(digit_word(digit))),q)

law peer_keeps_normalized_separate_step:
  for +image: BoardImage
  for +p: U32
  for +q: U32
  for safe: RoutedApart(flag_slot(q),q)
  for +placed: BoardDigit
  for shapes: (Board128(image_board(image)) & Board128(image_board(image)))
  for given: NormalizedQueueMask(cell_value(image_board(image),q))
  for sep: RoutedApart(p,q)
  for flag: RoutedApart(flag_slot(p),q)
  SafeNormalizedAt(actual_peer(image_board(image),p,B.bit(digit_word(placed))),q)

law peer_keeps_normalized_separate_image:
  for +image: BoardImage
  for +p: U32
  for +q: U32
  for +placed: BoardDigit
  for apart: (RoutedApart(p,q) & RoutedApart(flag_slot(p),q))
  SafeNormalizedAt(image_board(image),q) ->
  SafeNormalizedAt(actual_peer(image_board(image),p,B.bit(digit_word(placed))),q)

def PeerNormalizedTransition(-b: Array<U32>, +p: U32, +q: U32, +placed: BoardDigit) -> Type:
  PeerRoute(p,q) -> SafeNormalizedAt(b,q) ->
  SafeNormalizedAt(actual_peer(b,p,B.bit(digit_word(placed))),q)

law peer_normalized_transition_image:
  for +image: BoardImage
  for +p: U32
  for +q: U32
  for +placed: BoardDigit
  PeerNormalizedTransition(image_board(image),p,q,placed)

law peer_normalized_transition:
  for b: Array<U32>
  for +p: U32
  for +q: U32
  for +placed: BoardDigit
  PeerNormalizedTransition(b,p,q,placed)


def RowNormalizedProof(+n: Nat, +j: U32, +base: U32, +placed: U32, +q: U32, +d: BoardDigit) -> Type:
  @b:Array<U32> -> RowClueRoutes(n,j,base,q) -> SafeNormalizedAt(b,q) ->
  SafeNormalizedAt(Q.row_line(n,j,base,placed,B.bit(digit_word(d)),b),q)

def RowNormalizedStep(-b: Array<U32>, +n: Nat, +j: U32, +base: U32, +placed: U32, +q: U32, +d: BoardDigit) -> Type:
  RowClueRoutes(1n+n,j,base,q) -> SafeNormalizedAt(b,q) ->
  RowNormalizedProof(n,(j + 1 : U32),base,placed,q,d) ->
  SafeNormalizedAt(Q.row_line(1n+n,j,base,placed,B.bit(digit_word(d)),b),q)

law row_normalized_step_image:
  for +image: BoardImage
  for +n: Nat
  for +j: U32
  for +base: U32
  for +placed: U32
  for +q: U32
  for +d: BoardDigit
  RowNormalizedStep(image_board(image),n,j,base,placed,q,d)

law row_normalized_step:
  for b: Array<U32>
  for +n: Nat
  for +j: U32
  for +base: U32
  for +placed: U32
  for +q: U32
  for +d: BoardDigit
  RowNormalizedStep(b,n,j,base,placed,q,d)

law row_normalized_line:
  for +n: Nat
  for +j: U32
  for +base: U32
  for +placed: U32
  for +q: U32
  for +d: BoardDigit
  RowNormalizedProof(n,j,base,placed,q,d)


def ColumnNormalizedProof(+n: Nat, +j: U32, +col: U32, +placed: U32, +q: U32, +d: BoardDigit) -> Type:
  @b:Array<U32> -> ColumnClueRoutes(n,j,col,q) -> SafeNormalizedAt(b,q) ->
  SafeNormalizedAt(Q.column_line(n,j,col,placed,B.bit(digit_word(d)),b),q)

def ColumnNormalizedStep(-b: Array<U32>, +n: Nat, +j: U32, +col: U32, +placed: U32, +q: U32, +d: BoardDigit) -> Type:
  ColumnClueRoutes(1n+n,j,col,q) -> SafeNormalizedAt(b,q) ->
  ColumnNormalizedProof(n,(j + 1 : U32),col,placed,q,d) ->
  SafeNormalizedAt(Q.column_line(1n+n,j,col,placed,B.bit(digit_word(d)),b),q)

law column_normalized_step_image:
  for +image: BoardImage
  for +n: Nat
  for +j: U32
  for +col: U32
  for +placed: U32
  for +q: U32
  for +d: BoardDigit
  ColumnNormalizedStep(image_board(image),n,j,col,placed,q,d)

law column_normalized_step:
  for b: Array<U32>
  for +n: Nat
  for +j: U32
  for +col: U32
  for +placed: U32
  for +q: U32
  for +d: BoardDigit
  ColumnNormalizedStep(b,n,j,col,placed,q,d)

law column_normalized_line:
  for +n: Nat
  for +j: U32
  for +col: U32
  for +placed: U32
  for +q: U32
  for +d: BoardDigit
  ColumnNormalizedProof(n,j,col,placed,q,d)


def NormalizedPeerListProof(-positions: List<&2,U32>, +q: U32, +d: BoardDigit) -> Type:
  @b:Array<U32> -> PeerListRoutes(positions,q) -> SafeNormalizedAt(b,q) ->
  SafeNormalizedAt(run_peer_list(positions,b,B.bit(digit_word(d))),q)

law normalized_peer_list_step_image:
  for +image: BoardImage
  for +p: U32
  for -tail: List<&2,U32>
  for +q: U32
  for +d: BoardDigit
  for routes: PeerListRoutes(p <> tail,q)
  for state: SafeNormalizedAt(image_board(image),q)
  for next: NormalizedPeerListProof(tail,q,d)
  SafeNormalizedAt(run_peer_list(p <> tail,image_board(image),B.bit(digit_word(d))),q)

law normalized_peer_list_step:
  for b: Array<U32>
  for +p: U32
  for -tail: List<&2,U32>
  for +q: U32
  for +d: BoardDigit
  for routes: PeerListRoutes(p <> tail,q)
  for state: SafeNormalizedAt(b,q)
  for next: NormalizedPeerListProof(tail,q,d)
  SafeNormalizedAt(run_peer_list(p <> tail,b,B.bit(digit_word(d))),q)

law peer_list_normalized:
  for positions: List<&2,U32>
  for +q: U32
  for +d: BoardDigit
  NormalizedPeerListProof(positions,q,d)


law box_four_keeps_normalized:
  for b: Array<U32>
  for +base: U32
  for +r1: U32
  for +r2: U32
  for +c1: U32
  for +c2: U32
  for +q: U32
  for +d: BoardDigit
  for routes: PeerListRoutes(box_positions(base,r1,r2,c1,c2),q)
  for state: SafeNormalizedAt(b,q)
  SafeNormalizedAt(Q.box_four(base,r1,r2,c1,c2,B.bit(digit_word(d)),b),q)

law normalized_after_pointer_write:
  for +image: BoardImage
  for -out: Array<U32>
  for +q: U32
  for safe: RoutedApart(flag_slot(q),q)
  for shape: (Board128(image_board(image)) & Board128(image_board(image)))
  for known: NormalizedQueueMask(cell_value(image_board(image),q))
  for apart: RoutedApart(108,q)
  for witness: FirstOnlyWritesPointer(image_board(image),out)
  SafeNormalizedAt(out,q)


law refresh_needed_normalized_image:
  for +image: BoardImage
  for +needed: Bool
  for +start: U32
  for +q: U32
  for apart: RoutedApart(108,q)
  for state: SafeNormalizedAt(image_board(image),q)
  SafeNormalizedAt(Q.refresh_needed(needed,image_board(image),start),q)


def RefreshNormalizedAt(-b: Array<U32>, +p: U32, +q: U32) -> Type:
  RoutedApart(108,q) -> SafeNormalizedAt(b,q) -> SafeNormalizedAt(refresh_actual(b,p),q)

law refresh_keeps_normalized_image:
  for +image: BoardImage
  for +p: U32
  for +q: U32
  RefreshNormalizedAt(image_board(image),p,q)

law refresh_keeps_normalized:
  for b: Array<U32>
  for +p: U32
  for +q: U32
  RefreshNormalizedAt(b,p,q)

law clear_forced_normalized_image_step:
  for +image: BoardImage
  for +p: U32
  for +q: U32
  for safe: RoutedApart(flag_slot(q),q)
  for flag: RoutedApart(flag_slot(p),q)
  for shapes: (Board128(image_board(image)) & Board128(image_board(image)))
  for known: NormalizedQueueMask(cell_value(image_board(image),q))
  SafeNormalizedAt(Q.clear_forced(False{},image_board(image),p),q)

law clear_forced_normalized_image:
  for +image: BoardImage
  for +guess: Bool
  for +p: U32
  for +q: U32
  for flag: RoutedApart(flag_slot(p),q)
  for state: SafeNormalizedAt(image_board(image),q)
  SafeNormalizedAt(Q.clear_forced(guess,image_board(image),p),q)

law clear_forced_normalized:
  for b: Array<U32>
  for +guess: Bool
  for +p: U32
  for +q: U32
  for flag: RoutedApart(flag_slot(p),q)
  for state: SafeNormalizedAt(b,q)
  SafeNormalizedAt(Q.clear_forced(guess,b,p),q)

law write_normalized_other_step:
  for +image: BoardImage
  for +p: U32
  for +value: U32
  for +q: U32
  for safe: RoutedApart(flag_slot(q),q)
  for apart: RoutedApart(p,q)
  for shapes: (Board128(image_board(image)) & Board128(image_board(image)))
  for known: NormalizedQueueMask(cell_value(image_board(image),q))
  SafeNormalizedAt(B.set_cell(image_board(image),p,value),q)

law write_normalized_other_image:
  for +image: BoardImage
  for +p: U32
  for +value: U32
  for +q: U32
  for apart: RoutedApart(p,q)
  for state: SafeNormalizedAt(image_board(image),q)
  SafeNormalizedAt(B.set_cell(image_board(image),p,value),q)

law write_normalized_other:
  for b: Array<U32>
  for +p: U32
  for +value: U32
  for +q: U32
  for apart: RoutedApart(p,q)
  for state: SafeNormalizedAt(b,q)
  SafeNormalizedAt(B.set_cell(b,p,value),q)


def PlacePeersNormalized(-b: Array<U32>, +p: U32, +q: U32, +d: BoardDigit) -> Type:
  PlacePeerRoutes(p,q) -> SafeNormalizedAt(b,q) -> SafeNormalizedAt(refresh_actual(place_boxes(b,p,d),p),q)

law place_normalized_peers_image:
  for +image: BoardImage
  for +p: U32
  for +q: U32
  for +d: BoardDigit
  PlacePeersNormalized(image_board(image),p,q,d)

law place_peers_keep_normalized:
  for b: Array<U32>
  for +p: U32
  for +q: U32
  for +d: BoardDigit
  PlacePeersNormalized(b,p,q,d)

def PlaceKeepsNormalized(-b: Array<U32>, +guess: Bool, +p: U32, +q: U32, +d: BoardDigit) -> Type:
  RoutedApart(p,q) -> RoutedApart(flag_slot(p),q) -> PlacePeerRoutes(p,q) -> SafeNormalizedAt(b,q) ->
  SafeNormalizedAt(Q.place(guess,p,digit_word(d),b),q)

law place_keeps_normalized_image:
  for +image: BoardImage
  for +guess: Bool
  for +p: U32
  for +q: U32
  for +d: BoardDigit
  PlaceKeepsNormalized(image_board(image),guess,p,q,d)

law queued_place_keeps_normalized:
  for b: Array<U32>
  for +guess: Bool
  for +p: U32
  for +q: U32
  for +d: BoardDigit
  PlaceKeepsNormalized(b,guess,p,q,d)


law logical_placement_keeps_other_candidate:
  for b: Array<U32>
  for +guess: Bool
  for +source_row: CellCoordinate
  for +source_col: CellCoordinate
  for +watched_row: CellCoordinate
  for +watched_col: CellCoordinate
  for +digit: BoardDigit
  for distinct: {U32.is_eq(logical_position(source_row,source_col),logical_position(watched_row,watched_col)) == False{} : Bool}
  for state: SafeNormalizedAt(b,logical_position(watched_row,watched_col))
  SafeNormalizedAt(Q.place(guess,logical_position(source_row,source_col),digit_word(digit),b),logical_position(watched_row,watched_col))


law safe_normalized_mask:
  for -b: Array<U32>
  for +q: U32
  for state: SafeNormalizedAt(b,q)
  NormalizedQueueMask(cell_value(b,q))

law logical_placement_preserves_other_candidate_mask:
  for b: Array<U32>
  for +guess: Bool
  for +source_row: CellCoordinate
  for +source_col: CellCoordinate
  for +watched_row: CellCoordinate
  for +watched_col: CellCoordinate
  for +digit: BoardDigit
  for distinct: {U32.is_eq(logical_position(source_row,source_col),logical_position(watched_row,watched_col)) == False{} : Bool}
  for shape: Board128(b)
  for prior: NormalizedQueueMask(cell_value(b,logical_position(watched_row,watched_col)))
  NormalizedQueueMask(cell_value(Q.place(guess,logical_position(source_row,source_col),digit_word(digit),b),logical_position(watched_row,watched_col)))

# Candidate removal never changes the encoded high digit, even for malformed low bits.
def word_ones(+n: Nat) -> Word(n):
  match n:
    case 0n:
      WNil{}
    case 1n+k:
      WCon{True{},word_ones(k)}

law word_and_ones_right:
  for +n: Nat
  for +x: Word(n)
  {Word.and(n,x,word_ones(n)) == x : Word(n)}

law peer_removal_keeps_high_digit:
  for +old: U32
  for +digit: BoardDigit
  {U32.shrn(peer_mask(old,B.bit(digit_word(digit))),10n) == U32.shrn(old,10n) : U32}

law cmp_low_against_zero_ignores_lt:
  for +bit: Bool
  for +higher: Cmp
  {Cmp.is_lt(Word.cmp.fin(bit,False{},higher)) == Cmp.is_lt(higher) : Bool}

def queued_packing(+b0: Bool, +b1: Bool, +b2: Bool, +b3: Bool, +b4: Bool, +b5: Bool, +b6: Bool, +b7: Bool, +b8: Bool, +b9: Bool, +upper: Word(22n)) -> U32:
  U32{WCon{b0,WCon{b1,WCon{b2,WCon{b3,WCon{b4,WCon{b5,WCon{b6,WCon{b7,WCon{b8,WCon{b9,upper}}}}}}}}}}}

law queued_packed_vacancy_from_upper:
  for +b0: Bool
  for +b1: Bool
  for +b2: Bool
  for +b3: Bool
  for +b4: Bool
  for +b5: Bool
  for +b6: Bool
  for +b7: Bool
  for +b8: Bool
  for +b9: Bool
  for +upper: Word(22n)
  {(queued_packing(b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,upper) < 1024 : U32) ==
    Cmp.is_lt(Word.cmp(22n,upper,WCon{True{},Word.zero(21n)})) : Bool}

def vacancy_from_upper(+t: Word(22n)) -> Bool:
  Cmp.is_lt(Word.cmp(22n,t,WCon{True{},Word.zero(21n)}))

law peer_removal_keeps_vacancy:
  for +old: U32
  for +digit: BoardDigit
  {(peer_mask(old,B.bit(digit_word(digit))) < 1024 : U32) == (old < 1024 : U32) : Bool}

def QueuedVacant(+raw: U32) -> Bool:
  (raw < 1024 : U32)

law changed_peer_keeps_vacancy_image:
  for +image: BoardImage
  for +needed: Bool
  for +pos: U32
  for +digit: BoardDigit
  for shape: Board128(image_board(image))
  for apart: RoutedApart(flag_slot(pos),pos)
  {QueuedVacant(cell_value(Q.changed(needed,pos,B.bit(digit_word(digit)),image_board(image),cell_value(image_board(image),pos)),pos))
    == QueuedVacant(cell_value(image_board(image),pos)) : Bool}

def ActualPeerKeepsVacancy(-b: Array<U32>, +pos: U32, +digit: BoardDigit) -> Type:
  Board128(b) -> RoutedApart(flag_slot(pos),pos) ->
  {QueuedVacant(cell_value(actual_peer(b,pos,B.bit(digit_word(digit))),pos)) == QueuedVacant(cell_value(b,pos)) : Bool}

law actual_peer_keeps_vacancy_image:
  for +image: BoardImage
  for +pos: U32
  for +digit: BoardDigit
  ActualPeerKeepsVacancy(image_board(image),pos,digit)

law actual_peer_keeps_vacancy:
  for b: Array<U32>
  for +pos: U32
  for +digit: BoardDigit
  ActualPeerKeepsVacancy(b,pos,digit)

# A read-only observation model for the production first-open pointer walk.
def queue_open_at(+image: BoardImage, +p: U32) -> Bool:
  QueuedVacant(cell_value(image_board(image),p))

def first_open_index(+n: Nat, +p: U32, +open: Bool, +image: BoardImage) -> U32:
  match n open:
    case 0n _:
      81
    case 1n+k True{}:
      p
    case 1n+k False{}:
      first_open_index(k,(p + 1 : U32),queue_open_at(image,(p + 1 : U32)),image)

law first_actual_read_exact_parts:
  for +n: Nat
  for +p: U32
  for -b: Array<U32>
  for -same: Array<U32>
  for +word: U32
  for same_board: {same == b : Array<U32>}
  for observed: {B.get_cell(b,p) == (same,word) : Array<U32> & U32}
  {first_actual(b,n,p) == Q.first_step(n,p,(b,QueuedVacant(cell_value(b,p)))) : Array<U32>}

law first_actual_read_exact:
  for +n: Nat
  for +p: U32
  for -b: Array<U32>
  for read: BoardReadWitness(b,p)
  {first_actual(b,n,p) == Q.first_step(n,p,(b,QueuedVacant(cell_value(b,p)))) : Array<U32>}

law first_open_step_closed_matches_model:
  for +n: Nat
  for +p: U32
  for +image: BoardImage
  for later: {Q.first_step(n,(p + 1 : U32),(image_board(image),queue_open_at(image,(p + 1 : U32)))) ==
    B.set_cell(image_board(image),108,first_open_index(n,(p + 1 : U32),queue_open_at(image,(p + 1 : U32)),image)) : Array<U32>}
  {Q.first_step(1n+n,p,(image_board(image),False{})) ==
    B.set_cell(image_board(image),108,first_open_index(1n+n,p,False{},image)) : Array<U32>}

law first_open_step_matches_model:
  for +n: Nat
  for +p: U32
  for +open: Bool
  for +image: BoardImage
  {Q.first_step(n,p,(image_board(image),open)) ==
    B.set_cell(image_board(image),108,first_open_index(n,p,open,image)) : Array<U32>}

law first_open_scan_writes_exact_pointer:
  for +n: Nat
  for +p: U32
  for +image: BoardImage
  {first_actual(image_board(image),n,p) ==
    B.set_cell(image_board(image),108,first_open_index(n,p,queue_open_at(image,p),image)) : Array<U32>}

law first_open_scan_reads_exact_pointer:
  for +n: Nat
  for +p: U32
  for +image: BoardImage
  {cell_value(first_actual(image_board(image),n,p),108) == first_open_index(n,p,queue_open_at(image,p),image) : U32}

# Scanning past a position requires evidence that its actual word was closed.
# The witness names either a first visited blank or exhaustion at position 81.
def FirstOpenWitness(+n: Nat, +p: U32, +image: BoardImage, -ptr: U32) -> Type:
  match n:
    case 0n:
      {ptr == 81 : U32}
    case 1n+k:
      Either<&1,&1,
        ({queue_open_at(image,p) == True{} : Bool} & {ptr == p : U32}),
        ({queue_open_at(image,p) == False{} : Bool} & FirstOpenWitness(k,(p + 1 : U32),image,ptr))>

law first_open_model_no_skip:
  for +n: Nat
  for +p: U32
  for +open: Bool
  for +image: BoardImage
  for read: {queue_open_at(image,p) == open : Bool}
  FirstOpenWitness(n,p,image,first_open_index(n,p,open,image))

law production_first_open_scan_no_skip:
  for +n: Nat
  for +p: U32
  for +image: BoardImage
  FirstOpenWitness(n,p,image,cell_value(first_actual(image_board(image),n,p),108))

law refreshed_first_open_scan_no_skip:
  for +start: U32
  for +image: BoardImage
  FirstOpenWitness(U32.to_nat((81 - start : U32)),start,image,
    cell_value(Q.refresh_needed(True{},image_board(image),start),108))

law refresh_at_pointer_does_not_skip:
  for +image: BoardImage
  for +placed: U32
  for +start: U32
  for observed: {cell_value(image_board(image),108) == start : U32}
  for hit: {U32.is_eq(placed,start) == True{} : Bool}
  FirstOpenWitness(U32.to_nat((81 - start : U32)),start,image,
    cell_value(refresh_actual(image_board(image),placed),108))

law refresh_away_from_pointer_leaves_board:
  for +image: BoardImage
  for +placed: U32
  for +start: U32
  for observed: {cell_value(image_board(image),108) == start : U32}
  for miss: {U32.is_eq(placed,start) == False{} : Bool}
  {refresh_actual(image_board(image),placed) == image_board(image) : Array<U32>}

law first_open_witness_pointer_valid:
  for +n: Nat
  for +p: U32
  for +image: BoardImage
  for +ptr: U32
  for witness: FirstOpenWitness(n,p,image,ptr)
  for range: QueuedScanRange(n,p)
  QueuedChoicePosition(image_board(image),ptr)

law refreshed_logical_pointer_is_vacant_or_sentinel:
  for +row: CellCoordinate
  for +col: CellCoordinate
  for +image: BoardImage
  QueuedChoicePosition(image_board(image),
    cell_value(Q.refresh_needed(True{},image_board(image),logical_position(row,col)),108))

def VacancyValue(+expect: Bool, +raw: U32) -> Type:
  {QueuedVacant(raw) == expect : Bool}

# The pointwise invariant carries its own distinct flag route for peer self visits.
def SafeVacancyAt(+expect: Bool, -b: Array<U32>, +q: U32) -> Type:
  (RoutedApart(flag_slot(q),q) & Board128(b) & VacancyValue(expect,cell_value(b,q)))

law peer_keeps_vacancy_same_parts:
  for +expect: Bool
  for +image: BoardImage
  for +q: U32
  for +digit: BoardDigit
  for routes: (RoutedApart(flag_slot(q),q) & RoutedApart(flag_slot(q),q))
  for shapes: (Board128(image_board(image)) & Board128(image_board(image)))
  for prior: VacancyValue(expect,cell_value(image_board(image),q))
  SafeVacancyAt(expect,actual_peer(image_board(image),q,B.bit(digit_word(digit))),q)

law peer_keeps_vacancy_same:
  for +expect: Bool
  for +image: BoardImage
  for +q: U32
  for +digit: BoardDigit
  for prior: SafeVacancyAt(expect,image_board(image),q)
  SafeVacancyAt(expect,actual_peer(image_board(image),q,B.bit(digit_word(digit))),q)

law peer_keeps_vacancy_separate_step:
  for +expect: Bool
  for +image: BoardImage
  for +p: U32
  for +q: U32
  for safe: RoutedApart(flag_slot(q),q)
  for +placed: BoardDigit
  for shapes: (Board128(image_board(image)) & Board128(image_board(image)))
  for given: VacancyValue(expect,cell_value(image_board(image),q))
  for sep: RoutedApart(p,q)
  for flag: RoutedApart(flag_slot(p),q)
  SafeVacancyAt(expect,actual_peer(image_board(image),p,B.bit(digit_word(placed))),q)

law peer_keeps_vacancy_separate_image:
  for +expect: Bool
  for +image: BoardImage
  for +p: U32
  for +q: U32
  for +placed: BoardDigit
  for apart: (RoutedApart(p,q) & RoutedApart(flag_slot(p),q))
  SafeVacancyAt(expect,image_board(image),q) ->
  SafeVacancyAt(expect,actual_peer(image_board(image),p,B.bit(digit_word(placed))),q)

def PeerVacancyTransition(+expect: Bool, -b: Array<U32>, +p: U32, +q: U32, +placed: BoardDigit) -> Type:
  PeerRoute(p,q) -> SafeVacancyAt(expect,b,q) ->
  SafeVacancyAt(expect,actual_peer(b,p,B.bit(digit_word(placed))),q)

law peer_vacancy_transition_image:
  for +expect: Bool
  for +image: BoardImage
  for +p: U32
  for +q: U32
  for +placed: BoardDigit
  PeerVacancyTransition(expect,image_board(image),p,q,placed)

law peer_vacancy_transition:
  for +expect: Bool
  for b: Array<U32>
  for +p: U32
  for +q: U32
  for +placed: BoardDigit
  PeerVacancyTransition(expect,b,p,q,placed)


def RowVacancyProof(+expect: Bool, +n: Nat, +j: U32, +base: U32, +placed: U32, +q: U32, +d: BoardDigit) -> Type:
  @b:Array<U32> -> RowClueRoutes(n,j,base,q) -> SafeVacancyAt(expect,b,q) ->
  SafeVacancyAt(expect,Q.row_line(n,j,base,placed,B.bit(digit_word(d)),b),q)

def RowVacancyStep(+expect: Bool, -b: Array<U32>, +n: Nat, +j: U32, +base: U32, +placed: U32, +q: U32, +d: BoardDigit) -> Type:
  RowClueRoutes(1n+n,j,base,q) -> SafeVacancyAt(expect,b,q) ->
  RowVacancyProof(expect,n,(j + 1 : U32),base,placed,q,d) ->
  SafeVacancyAt(expect,Q.row_line(1n+n,j,base,placed,B.bit(digit_word(d)),b),q)

law row_vacancy_step_image:
  for +expect: Bool
  for +image: BoardImage
  for +n: Nat
  for +j: U32
  for +base: U32
  for +placed: U32
  for +q: U32
  for +d: BoardDigit
  RowVacancyStep(expect,image_board(image),n,j,base,placed,q,d)

law row_vacancy_step:
  for +expect: Bool
  for b: Array<U32>
  for +n: Nat
  for +j: U32
  for +base: U32
  for +placed: U32
  for +q: U32
  for +d: BoardDigit
  RowVacancyStep(expect,b,n,j,base,placed,q,d)

law row_vacancy_line:
  for +expect: Bool
  for +n: Nat
  for +j: U32
  for +base: U32
  for +placed: U32
  for +q: U32
  for +d: BoardDigit
  RowVacancyProof(expect,n,j,base,placed,q,d)


def ColumnVacancyProof(+expect: Bool, +n: Nat, +j: U32, +col: U32, +placed: U32, +q: U32, +d: BoardDigit) -> Type:
  @b:Array<U32> -> ColumnClueRoutes(n,j,col,q) -> SafeVacancyAt(expect,b,q) ->
  SafeVacancyAt(expect,Q.column_line(n,j,col,placed,B.bit(digit_word(d)),b),q)

def ColumnVacancyStep(+expect: Bool, -b: Array<U32>, +n: Nat, +j: U32, +col: U32, +placed: U32, +q: U32, +d: BoardDigit) -> Type:
  ColumnClueRoutes(1n+n,j,col,q) -> SafeVacancyAt(expect,b,q) ->
  ColumnVacancyProof(expect,n,(j + 1 : U32),col,placed,q,d) ->
  SafeVacancyAt(expect,Q.column_line(1n+n,j,col,placed,B.bit(digit_word(d)),b),q)

law column_vacancy_step_image:
  for +expect: Bool
  for +image: BoardImage
  for +n: Nat
  for +j: U32
  for +col: U32
  for +placed: U32
  for +q: U32
  for +d: BoardDigit
  ColumnVacancyStep(expect,image_board(image),n,j,col,placed,q,d)

law column_vacancy_step:
  for +expect: Bool
  for b: Array<U32>
  for +n: Nat
  for +j: U32
  for +col: U32
  for +placed: U32
  for +q: U32
  for +d: BoardDigit
  ColumnVacancyStep(expect,b,n,j,col,placed,q,d)

law column_vacancy_line:
  for +expect: Bool
  for +n: Nat
  for +j: U32
  for +col: U32
  for +placed: U32
  for +q: U32
  for +d: BoardDigit
  ColumnVacancyProof(expect,n,j,col,placed,q,d)


def VacancyPeerListProof(+expect: Bool, -positions: List<&2,U32>, +q: U32, +d: BoardDigit) -> Type:
  @b:Array<U32> -> PeerListRoutes(positions,q) -> SafeVacancyAt(expect,b,q) ->
  SafeVacancyAt(expect,run_peer_list(positions,b,B.bit(digit_word(d))),q)

law vacancy_peer_list_step_image:
  for +expect: Bool
  for +image: BoardImage
  for +p: U32
  for -tail: List<&2,U32>
  for +q: U32
  for +d: BoardDigit
  for routes: PeerListRoutes(p <> tail,q)
  for state: SafeVacancyAt(expect,image_board(image),q)
  for next: VacancyPeerListProof(expect,tail,q,d)
  SafeVacancyAt(expect,run_peer_list(p <> tail,image_board(image),B.bit(digit_word(d))),q)

law vacancy_peer_list_step:
  for +expect: Bool
  for b: Array<U32>
  for +p: U32
  for -tail: List<&2,U32>
  for +q: U32
  for +d: BoardDigit
  for routes: PeerListRoutes(p <> tail,q)
  for state: SafeVacancyAt(expect,b,q)
  for next: VacancyPeerListProof(expect,tail,q,d)
  SafeVacancyAt(expect,run_peer_list(p <> tail,b,B.bit(digit_word(d))),q)

law peer_list_vacancy:
  for +expect: Bool
  for positions: List<&2,U32>
  for +q: U32
  for +d: BoardDigit
  VacancyPeerListProof(expect,positions,q,d)


law box_four_keeps_vacancy:
  for +expect: Bool
  for b: Array<U32>
  for +base: U32
  for +r1: U32
  for +r2: U32
  for +c1: U32
  for +c2: U32
  for +q: U32
  for +d: BoardDigit
  for routes: PeerListRoutes(box_positions(base,r1,r2,c1,c2),q)
  for state: SafeVacancyAt(expect,b,q)
  SafeVacancyAt(expect,Q.box_four(base,r1,r2,c1,c2,B.bit(digit_word(d)),b),q)

law vacancy_after_pointer_write:
  for +expect: Bool
  for +image: BoardImage
  for -out: Array<U32>
  for +q: U32
  for safe: RoutedApart(flag_slot(q),q)
  for shape: (Board128(image_board(image)) & Board128(image_board(image)))
  for known: VacancyValue(expect,cell_value(image_board(image),q))
  for apart: RoutedApart(108,q)
  for witness: FirstOnlyWritesPointer(image_board(image),out)
  SafeVacancyAt(expect,out,q)


law refresh_needed_vacancy_image:
  for +expect: Bool
  for +image: BoardImage
  for +needed: Bool
  for +start: U32
  for +q: U32
  for apart: RoutedApart(108,q)
  for state: SafeVacancyAt(expect,image_board(image),q)
  SafeVacancyAt(expect,Q.refresh_needed(needed,image_board(image),start),q)


def RefreshVacancyAt(+expect: Bool, -b: Array<U32>, +p: U32, +q: U32) -> Type:
  RoutedApart(108,q) -> SafeVacancyAt(expect,b,q) -> SafeVacancyAt(expect,refresh_actual(b,p),q)

law refresh_keeps_vacancy_image:
  for +expect: Bool
  for +image: BoardImage
  for +p: U32
  for +q: U32
  RefreshVacancyAt(expect,image_board(image),p,q)

law refresh_keeps_vacancy:
  for +expect: Bool
  for b: Array<U32>
  for +p: U32
  for +q: U32
  RefreshVacancyAt(expect,b,p,q)

law clear_forced_vacancy_image_step:
  for +expect: Bool
  for +image: BoardImage
  for +p: U32
  for +q: U32
  for safe: RoutedApart(flag_slot(q),q)
  for flag: RoutedApart(flag_slot(p),q)
  for shapes: (Board128(image_board(image)) & Board128(image_board(image)))
  for known: VacancyValue(expect,cell_value(image_board(image),q))
  SafeVacancyAt(expect,Q.clear_forced(False{},image_board(image),p),q)

law clear_forced_vacancy_image:
  for +expect: Bool
  for +image: BoardImage
  for +guess: Bool
  for +p: U32
  for +q: U32
  for flag: RoutedApart(flag_slot(p),q)
  for state: SafeVacancyAt(expect,image_board(image),q)
  SafeVacancyAt(expect,Q.clear_forced(guess,image_board(image),p),q)

law clear_forced_vacancy:
  for +expect: Bool
  for b: Array<U32>
  for +guess: Bool
  for +p: U32
  for +q: U32
  for flag: RoutedApart(flag_slot(p),q)
  for state: SafeVacancyAt(expect,b,q)
  SafeVacancyAt(expect,Q.clear_forced(guess,b,p),q)

law write_vacancy_other_step:
  for +expect: Bool
  for +image: BoardImage
  for +p: U32
  for +value: U32
  for +q: U32
  for safe: RoutedApart(flag_slot(q),q)
  for apart: RoutedApart(p,q)
  for shapes: (Board128(image_board(image)) & Board128(image_board(image)))
  for known: VacancyValue(expect,cell_value(image_board(image),q))
  SafeVacancyAt(expect,B.set_cell(image_board(image),p,value),q)

law write_vacancy_other_image:
  for +expect: Bool
  for +image: BoardImage
  for +p: U32
  for +value: U32
  for +q: U32
  for apart: RoutedApart(p,q)
  for state: SafeVacancyAt(expect,image_board(image),q)
  SafeVacancyAt(expect,B.set_cell(image_board(image),p,value),q)

law write_vacancy_other:
  for +expect: Bool
  for b: Array<U32>
  for +p: U32
  for +value: U32
  for +q: U32
  for apart: RoutedApart(p,q)
  for state: SafeVacancyAt(expect,b,q)
  SafeVacancyAt(expect,B.set_cell(b,p,value),q)


def PlacePeersVacancy(+expect: Bool, -b: Array<U32>, +p: U32, +q: U32, +d: BoardDigit) -> Type:
  PlacePeerRoutes(p,q) -> SafeVacancyAt(expect,b,q) -> SafeVacancyAt(expect,refresh_actual(place_boxes(b,p,d),p),q)

law place_vacancy_peers_image:
  for +expect: Bool
  for +image: BoardImage
  for +p: U32
  for +q: U32
  for +d: BoardDigit
  PlacePeersVacancy(expect,image_board(image),p,q,d)

law place_peers_keep_vacancy:
  for +expect: Bool
  for b: Array<U32>
  for +p: U32
  for +q: U32
  for +d: BoardDigit
  PlacePeersVacancy(expect,b,p,q,d)

def PlaceKeepsVacancy(+expect: Bool, -b: Array<U32>, +guess: Bool, +p: U32, +q: U32, +d: BoardDigit) -> Type:
  RoutedApart(p,q) -> RoutedApart(flag_slot(p),q) -> PlacePeerRoutes(p,q) -> SafeVacancyAt(expect,b,q) ->
  SafeVacancyAt(expect,Q.place(guess,p,digit_word(d),b),q)

law place_keeps_vacancy_image:
  for +expect: Bool
  for +image: BoardImage
  for +guess: Bool
  for +p: U32
  for +q: U32
  for +d: BoardDigit
  PlaceKeepsVacancy(expect,image_board(image),guess,p,q,d)

law queued_place_keeps_vacancy:
  for +expect: Bool
  for b: Array<U32>
  for +guess: Bool
  for +p: U32
  for +q: U32
  for +d: BoardDigit
  PlaceKeepsVacancy(expect,b,guess,p,q,d)


law logical_placement_keeps_other_vacancy_state:
  for +expect: Bool
  for b: Array<U32>
  for +guess: Bool
  for +source_row: CellCoordinate
  for +source_col: CellCoordinate
  for +watched_row: CellCoordinate
  for +watched_col: CellCoordinate
  for +digit: BoardDigit
  for distinct: {U32.is_eq(logical_position(source_row,source_col),logical_position(watched_row,watched_col)) == False{} : Bool}
  for state: SafeVacancyAt(expect,b,logical_position(watched_row,watched_col))
  SafeVacancyAt(expect,Q.place(guess,logical_position(source_row,source_col),digit_word(digit),b),logical_position(watched_row,watched_col))


law safe_vacancy_mask:
  for +expect: Bool
  for -b: Array<U32>
  for +q: U32
  for state: SafeVacancyAt(expect,b,q)
  VacancyValue(expect,cell_value(b,q))

law logical_placement_preserves_other_vacancy:
  for +expect: Bool
  for b: Array<U32>
  for +guess: Bool
  for +source_row: CellCoordinate
  for +source_col: CellCoordinate
  for +watched_row: CellCoordinate
  for +watched_col: CellCoordinate
  for +digit: BoardDigit
  for distinct: {U32.is_eq(logical_position(source_row,source_col),logical_position(watched_row,watched_col)) == False{} : Bool}
  for shape: Board128(b)
  for prior: VacancyValue(expect,cell_value(b,logical_position(watched_row,watched_col)))
  VacancyValue(expect,cell_value(Q.place(guess,logical_position(source_row,source_col),digit_word(digit),b),logical_position(watched_row,watched_col)))

law clear_forced_preserves_board128:
  for b: Array<U32>
  for +guess: Bool
  for +p: U32
  for shape: Board128(b)
  Board128(Q.clear_forced(guess,b,p))

law fixed_write_after_clear_image:
  for +image: BoardImage
  for +guess: Bool
  for +p: U32
  for +digit: BoardDigit
  for shape: Board128(image_board(image))
  FixedClue(B.set_cell(Q.clear_forced(guess,image_board(image),p),p,fixed_word(digit)),p,digit)

def PlaceTargetFixed(-b: Array<U32>, +guess: Bool, +p: U32, +d: BoardDigit) -> Type:
  PlacePeerRoutes(p,p) -> Board128(b) -> FixedClue(Q.place(guess,p,digit_word(d),b),p,d)

law queued_place_target_fixed_image:
  for +image: BoardImage
  for +guess: Bool
  for +p: U32
  for +d: BoardDigit
  PlaceTargetFixed(image_board(image),guess,p,d)

law queued_place_target_fixed:
  for b: Array<U32>
  for +guess: Bool
  for +p: U32
  for +d: BoardDigit
  PlaceTargetFixed(b,guess,p,d)

law logical_placement_fixes_target:
  for b: Array<U32>
  for +guess: Bool
  for +row: CellCoordinate
  for +col: CellCoordinate
  for +digit: BoardDigit
  for shape: Board128(b)
  FixedClue(Q.place(guess,logical_position(row,col),digit_word(digit),b),logical_position(row,col),digit)

law fixed_clue_is_closed:
  for -b: Array<U32>
  for +p: U32
  for +d: BoardDigit
  for fixed: FixedClue(b,p,d)
  for nonblank: Nonblank(d)
  {QueuedVacant(cell_value(b,p)) == False{} : Bool}

law encode_routes_from_sweep:
  for +n: Nat
  for +p: U32
  for +q: U32
  for both: SweepWitnesses(n,p,q)
  EncodeApart(n,p,q)

law queued_encode_pointer_routes:
  EncodeApart(81n,0,108)

def QueueEncodeKeepsPointer(-b: Array<U32>) -> Type:
  Board128(b) -> {cell_value(Q.encode(b),108) == cell_value(b,108) : U32}

law queued_encode_keeps_pointer_parts:
  for +image: BoardImage
  for shapes: (Board128(image_board(image)) & Board128(image_board(image)))
  {cell_value(Q.encode(image_board(image)),108) == cell_value(image_board(image),108) : U32}

law queued_encode_keeps_pointer_image:
  for +image: BoardImage
  QueueEncodeKeepsPointer(image_board(image))

law queued_encode_keeps_pointer:
  for b: Array<U32>
  QueueEncodeKeepsPointer(b)

def DistinctPeerRoute(+p: U32, +q: U32) -> Type:
  (RoutedApart(p,q) & RoutedApart(flag_slot(p),q))

def RowDistinctRoutes(+n: Nat, +j: U32, +base: U32, +q: U32) -> Type:
  match n:
    case 0n:
      {True{} == True{} : Bool}
    case 1n+k:
      DistinctPeerRoute((base + j : U32),q) & RowDistinctRoutes(k,(j + 1 : U32),base,q)

def ColumnDistinctRoutes(+n: Nat, +j: U32, +col: U32, +q: U32) -> Type:
  match n:
    case 0n:
      {True{} == True{} : Bool}
    case 1n+k:
      DistinctPeerRoute((j * 9 + col : U32),q) & ColumnDistinctRoutes(k,(j + 1 : U32),col,q)

def DistinctPeerListRoutes(positions: List<&2,U32>, +q: U32) -> Type:
  match positions:
    case Nil{}:
      {True{} == True{} : Bool}
    case +p <> tail:
      DistinctPeerRoute(p,q) & DistinctPeerListRoutes(tail,q)

def PlaceDistinctRoutes(+p: U32, +q: U32) -> Type:
  (RowDistinctRoutes(9n,0,place_row_base(p),q) & ColumnDistinctRoutes(9n,0,M.rem9(p),q)
   & DistinctPeerListRoutes(placed_box_positions(p),q))

def placement_before_refresh(+guess: Bool, b: Array<U32>, +p: U32, +d: BoardDigit) -> Array<U32>:
  place_boxes(B.set_cell(Q.clear_forced(guess,b,p),p,fixed_word(d)),p,d)

def PointerWordValue(+expect: U32, +raw: U32) -> Type:
  {raw == expect : U32}

# The pointwise invariant carries its own distinct flag route for peer self visits.
def SafePointerWordAt(+expect: U32, -b: Array<U32>, +q: U32) -> Type:
  (RoutedApart(flag_slot(q),q) & Board128(b) & PointerWordValue(expect,cell_value(b,q)))

law peer_keeps_pointer_word_separate_step:
  for +expect: U32
  for +image: BoardImage
  for +p: U32
  for +q: U32
  for safe: RoutedApart(flag_slot(q),q)
  for +placed: BoardDigit
  for shapes: (Board128(image_board(image)) & Board128(image_board(image)))
  for given: PointerWordValue(expect,cell_value(image_board(image),q))
  for sep: RoutedApart(p,q)
  for flag: RoutedApart(flag_slot(p),q)
  SafePointerWordAt(expect,actual_peer(image_board(image),p,B.bit(digit_word(placed))),q)

law peer_keeps_pointer_word_separate_image:
  for +expect: U32
  for +image: BoardImage
  for +p: U32
  for +q: U32
  for +placed: BoardDigit
  for apart: (RoutedApart(p,q) & RoutedApart(flag_slot(p),q))
  SafePointerWordAt(expect,image_board(image),q) ->
  SafePointerWordAt(expect,actual_peer(image_board(image),p,B.bit(digit_word(placed))),q)

def PeerPointerWordTransition(+expect: U32, -b: Array<U32>, +p: U32, +q: U32, +placed: BoardDigit) -> Type:
  DistinctPeerRoute(p,q) -> SafePointerWordAt(expect,b,q) ->
  SafePointerWordAt(expect,actual_peer(b,p,B.bit(digit_word(placed))),q)

law peer_pointer_word_transition_image:
  for +expect: U32
  for +image: BoardImage
  for +p: U32
  for +q: U32
  for +placed: BoardDigit
  PeerPointerWordTransition(expect,image_board(image),p,q,placed)

law peer_pointer_word_transition:
  for +expect: U32
  for b: Array<U32>
  for +p: U32
  for +q: U32
  for +placed: BoardDigit
  PeerPointerWordTransition(expect,b,p,q,placed)


def RowPointerWordProof(+expect: U32, +n: Nat, +j: U32, +base: U32, +placed: U32, +q: U32, +d: BoardDigit) -> Type:
  @b:Array<U32> -> RowDistinctRoutes(n,j,base,q) -> SafePointerWordAt(expect,b,q) ->
  SafePointerWordAt(expect,Q.row_line(n,j,base,placed,B.bit(digit_word(d)),b),q)

def RowPointerWordStep(+expect: U32, -b: Array<U32>, +n: Nat, +j: U32, +base: U32, +placed: U32, +q: U32, +d: BoardDigit) -> Type:
  RowDistinctRoutes(1n+n,j,base,q) -> SafePointerWordAt(expect,b,q) ->
  RowPointerWordProof(expect,n,(j + 1 : U32),base,placed,q,d) ->
  SafePointerWordAt(expect,Q.row_line(1n+n,j,base,placed,B.bit(digit_word(d)),b),q)

law row_pointer_word_step_image:
  for +expect: U32
  for +image: BoardImage
  for +n: Nat
  for +j: U32
  for +base: U32
  for +placed: U32
  for +q: U32
  for +d: BoardDigit
  RowPointerWordStep(expect,image_board(image),n,j,base,placed,q,d)

law row_pointer_word_step:
  for +expect: U32
  for b: Array<U32>
  for +n: Nat
  for +j: U32
  for +base: U32
  for +placed: U32
  for +q: U32
  for +d: BoardDigit
  RowPointerWordStep(expect,b,n,j,base,placed,q,d)

law row_pointer_word_line:
  for +expect: U32
  for +n: Nat
  for +j: U32
  for +base: U32
  for +placed: U32
  for +q: U32
  for +d: BoardDigit
  RowPointerWordProof(expect,n,j,base,placed,q,d)


def ColumnPointerWordProof(+expect: U32, +n: Nat, +j: U32, +col: U32, +placed: U32, +q: U32, +d: BoardDigit) -> Type:
  @b:Array<U32> -> ColumnDistinctRoutes(n,j,col,q) -> SafePointerWordAt(expect,b,q) ->
  SafePointerWordAt(expect,Q.column_line(n,j,col,placed,B.bit(digit_word(d)),b),q)

def ColumnPointerWordStep(+expect: U32, -b: Array<U32>, +n: Nat, +j: U32, +col: U32, +placed: U32, +q: U32, +d: BoardDigit) -> Type:
  ColumnDistinctRoutes(1n+n,j,col,q) -> SafePointerWordAt(expect,b,q) ->
  ColumnPointerWordProof(expect,n,(j + 1 : U32),col,placed,q,d) ->
  SafePointerWordAt(expect,Q.column_line(1n+n,j,col,placed,B.bit(digit_word(d)),b),q)

law column_pointer_word_step_image:
  for +expect: U32
  for +image: BoardImage
  for +n: Nat
  for +j: U32
  for +col: U32
  for +placed: U32
  for +q: U32
  for +d: BoardDigit
  ColumnPointerWordStep(expect,image_board(image),n,j,col,placed,q,d)

law column_pointer_word_step:
  for +expect: U32
  for b: Array<U32>
  for +n: Nat
  for +j: U32
  for +col: U32
  for +placed: U32
  for +q: U32
  for +d: BoardDigit
  ColumnPointerWordStep(expect,b,n,j,col,placed,q,d)

law column_pointer_word_line:
  for +expect: U32
  for +n: Nat
  for +j: U32
  for +col: U32
  for +placed: U32
  for +q: U32
  for +d: BoardDigit
  ColumnPointerWordProof(expect,n,j,col,placed,q,d)


def PointerWordPeerListProof(+expect: U32, -positions: List<&2,U32>, +q: U32, +d: BoardDigit) -> Type:
  @b:Array<U32> -> DistinctPeerListRoutes(positions,q) -> SafePointerWordAt(expect,b,q) ->
  SafePointerWordAt(expect,run_peer_list(positions,b,B.bit(digit_word(d))),q)

law pointer_word_peer_list_step_image:
  for +expect: U32
  for +image: BoardImage
  for +p: U32
  for -tail: List<&2,U32>
  for +q: U32
  for +d: BoardDigit
  for routes: DistinctPeerListRoutes(p <> tail,q)
  for state: SafePointerWordAt(expect,image_board(image),q)
  for next: PointerWordPeerListProof(expect,tail,q,d)
  SafePointerWordAt(expect,run_peer_list(p <> tail,image_board(image),B.bit(digit_word(d))),q)

law pointer_word_peer_list_step:
  for +expect: U32
  for b: Array<U32>
  for +p: U32
  for -tail: List<&2,U32>
  for +q: U32
  for +d: BoardDigit
  for routes: DistinctPeerListRoutes(p <> tail,q)
  for state: SafePointerWordAt(expect,b,q)
  for next: PointerWordPeerListProof(expect,tail,q,d)
  SafePointerWordAt(expect,run_peer_list(p <> tail,b,B.bit(digit_word(d))),q)

law peer_list_pointer_word:
  for +expect: U32
  for positions: List<&2,U32>
  for +q: U32
  for +d: BoardDigit
  PointerWordPeerListProof(expect,positions,q,d)


law box_four_keeps_pointer_word:
  for +expect: U32
  for b: Array<U32>
  for +base: U32
  for +r1: U32
  for +r2: U32
  for +c1: U32
  for +c2: U32
  for +q: U32
  for +d: BoardDigit
  for routes: DistinctPeerListRoutes(box_positions(base,r1,r2,c1,c2),q)
  for state: SafePointerWordAt(expect,b,q)
  SafePointerWordAt(expect,Q.box_four(base,r1,r2,c1,c2,B.bit(digit_word(d)),b),q)

law clear_forced_pointer_word_image_step:
  for +expect: U32
  for +image: BoardImage
  for +p: U32
  for +q: U32
  for safe: RoutedApart(flag_slot(q),q)
  for flag: RoutedApart(flag_slot(p),q)
  for shapes: (Board128(image_board(image)) & Board128(image_board(image)))
  for known: PointerWordValue(expect,cell_value(image_board(image),q))
  SafePointerWordAt(expect,Q.clear_forced(False{},image_board(image),p),q)

law clear_forced_pointer_word_image:
  for +expect: U32
  for +image: BoardImage
  for +guess: Bool
  for +p: U32
  for +q: U32
  for flag: RoutedApart(flag_slot(p),q)
  for state: SafePointerWordAt(expect,image_board(image),q)
  SafePointerWordAt(expect,Q.clear_forced(guess,image_board(image),p),q)

law clear_forced_pointer_word:
  for +expect: U32
  for b: Array<U32>
  for +guess: Bool
  for +p: U32
  for +q: U32
  for flag: RoutedApart(flag_slot(p),q)
  for state: SafePointerWordAt(expect,b,q)
  SafePointerWordAt(expect,Q.clear_forced(guess,b,p),q)

law write_pointer_word_other_step:
  for +expect: U32
  for +image: BoardImage
  for +p: U32
  for +value: U32
  for +q: U32
  for safe: RoutedApart(flag_slot(q),q)
  for apart: RoutedApart(p,q)
  for shapes: (Board128(image_board(image)) & Board128(image_board(image)))
  for known: PointerWordValue(expect,cell_value(image_board(image),q))
  SafePointerWordAt(expect,B.set_cell(image_board(image),p,value),q)

law write_pointer_word_other_image:
  for +expect: U32
  for +image: BoardImage
  for +p: U32
  for +value: U32
  for +q: U32
  for apart: RoutedApart(p,q)
  for state: SafePointerWordAt(expect,image_board(image),q)
  SafePointerWordAt(expect,B.set_cell(image_board(image),p,value),q)

law write_pointer_word_other:
  for +expect: U32
  for b: Array<U32>
  for +p: U32
  for +value: U32
  for +q: U32
  for apart: RoutedApart(p,q)
  for state: SafePointerWordAt(expect,b,q)
  SafePointerWordAt(expect,B.set_cell(b,p,value),q)


def PlacePeersPointerWord(+expect: U32, -b: Array<U32>, +p: U32, +q: U32, +d: BoardDigit) -> Type:
  PlaceDistinctRoutes(p,q) -> SafePointerWordAt(expect,b,q) -> SafePointerWordAt(expect,place_boxes(b,p,d),q)

law place_pointer_word_peers_image:
  for +expect: U32
  for +image: BoardImage
  for +p: U32
  for +q: U32
  for +d: BoardDigit
  PlacePeersPointerWord(expect,image_board(image),p,q,d)

law place_peers_keep_pointer_word:
  for +expect: U32
  for b: Array<U32>
  for +p: U32
  for +q: U32
  for +d: BoardDigit
  PlacePeersPointerWord(expect,b,p,q,d)

def PlaceKeepsPointerWord(+expect: U32, -b: Array<U32>, +guess: Bool, +p: U32, +q: U32, +d: BoardDigit) -> Type:
  RoutedApart(p,q) -> RoutedApart(flag_slot(p),q) -> PlaceDistinctRoutes(p,q) -> SafePointerWordAt(expect,b,q) ->
  SafePointerWordAt(expect,placement_before_refresh(guess,b,p,d),q)

law place_keeps_pointer_word_image:
  for +expect: U32
  for +image: BoardImage
  for +guess: Bool
  for +p: U32
  for +q: U32
  for +d: BoardDigit
  PlaceKeepsPointerWord(expect,image_board(image),guess,p,q,d)

law queued_place_keeps_pointer_word:
  for +expect: U32
  for b: Array<U32>
  for +guess: Bool
  for +p: U32
  for +q: U32
  for +d: BoardDigit
  PlaceKeepsPointerWord(expect,b,guess,p,q,d)



law row_routes_to_pointer:
  for +source: CellCoordinate
  RowDistinctRoutes(9n,0,row_origin(source),108)

law column_routes_to_pointer:
  for +source: CellCoordinate
  ColumnDistinctRoutes(9n,0,coord_u32(source),108)

law box_routes_to_pointer:
  for +source_row: CellCoordinate
  for +source_col: CellCoordinate
  DistinctPeerListRoutes(placed_box_positions(logical_position(source_row,source_col)),108)

law logical_target_routes_to_pointer:
  for +row: CellCoordinate
  for +col: CellCoordinate
  DistinctPeerRoute(logical_position(row,col),108)

law placement_routes_to_pointer_with_geometry:
  for +row: CellCoordinate
  for +col: CellCoordinate
  for geometry: PlaceGeometry(row,col)
  PlaceDistinctRoutes(logical_position(row,col),108)

law read_pointer_word_witness:
  for -b: Array<U32>
  for +expect: U32
  for state: SafePointerWordAt(expect,b,108)
  {cell_value(b,108) == expect : U32}

law actual_pre_refresh_keeps_pointer_routes:
  for +image: BoardImage
  for +guess: Bool
  for +p: U32
  for +d: BoardDigit
  for shape: Board128(image_board(image))
  for target: DistinctPeerRoute(p,108)
  for passes: PlaceDistinctRoutes(p,108)
  {cell_value(placement_before_refresh(guess,image_board(image),p,d),108) == cell_value(image_board(image),108) : U32}

def PreRefreshKeepsPointer(-b: Array<U32>, +guess: Bool, +row: CellCoordinate, +col: CellCoordinate, +d: BoardDigit) -> Type:
  Board128(b) -> {cell_value(placement_before_refresh(guess,b,logical_position(row,col),d),108) == cell_value(b,108) : U32}

law actual_pre_refresh_keeps_pointer_image:
  for +image: BoardImage
  for +guess: Bool
  for +row: CellCoordinate
  for +col: CellCoordinate
  for +d: BoardDigit
  PreRefreshKeepsPointer(image_board(image),guess,row,col,d)

law actual_pre_refresh_keeps_pointer:
  for b: Array<U32>
  for +guess: Bool
  for +row: CellCoordinate
  for +col: CellCoordinate
  for +d: BoardDigit
  PreRefreshKeepsPointer(b,guess,row,col,d)

def RefreshKeepsKnownPointer(-b: Array<U32>, +p: U32, +start: U32) -> Type:
  {cell_value(b,108) == start : U32} ->
  {U32.is_eq(p,start) == False{} : Bool} ->
  {cell_value(refresh_actual(b,p),108) == start : U32}

law refresh_keeps_known_pointer_parts:
  for +image: BoardImage
  for +p: U32
  for +start: U32
  for known: ({cell_value(image_board(image),108) == start : U32} & {cell_value(image_board(image),108) == start : U32})
  for miss: {U32.is_eq(p,start) == False{} : Bool}
  {cell_value(refresh_actual(image_board(image),p),108) == start : U32}

law refresh_keeps_known_pointer_image:
  for +image: BoardImage
  for +p: U32
  for +start: U32
  RefreshKeepsKnownPointer(image_board(image),p,start)

law refresh_keeps_known_pointer:
  for b: Array<U32>
  for +p: U32
  for +start: U32
  RefreshKeepsKnownPointer(b,p,start)

def PlaceAwayKeepsPointer(-b: Array<U32>, +guess: Bool, +row: CellCoordinate, +col: CellCoordinate, +d: BoardDigit) -> Type:
  Board128(b) ->
  {U32.is_eq(logical_position(row,col),cell_value(b,108)) == False{} : Bool} ->
  {cell_value(Q.place(guess,logical_position(row,col),digit_word(d),b),108) == cell_value(b,108) : U32}

law queued_place_away_keeps_pointer_image:
  for +image: BoardImage
  for +guess: Bool
  for +row: CellCoordinate
  for +col: CellCoordinate
  for +d: BoardDigit
  PlaceAwayKeepsPointer(image_board(image),guess,row,col,d)

law queued_place_away_keeps_pointer:
  for b: Array<U32>
  for +guess: Bool
  for +row: CellCoordinate
  for +col: CellCoordinate
  for +d: BoardDigit
  PlaceAwayKeepsPointer(b,guess,row,col,d)

def equal_urgency(+a: Bool, +b: Bool) -> Bool:
  Bool.pick(Bool,a,b,Bool.not(b))

def blank_after_peer(+old: U32, +bit: U32) -> U32:
  Bool.pick(U32,U32.is_ne(U32.and(old,bit),0),peer_mask(old,bit),old)

def urgency_after_peer(+old: U32, +bit: U32, +prior: Bool) -> Bool:
  Bool.or(prior,Bool.and(U32.is_ne(U32.and(old,bit),0),peer_reflag(old,bit)))

def urgency_preserved_for_bits(+placed: BoardDigit, +bits: Word(9n)) -> Bool:
  +old = candidate_bits_word(bits)
  +bit = B.bit(digit_word(placed))
  equal_urgency(urgency_after_peer(old,bit,Q.zero_or_single(old)),Q.zero_or_single(blank_after_peer(old,bit)))

def urgency_flag_tree_9(+placed: BoardDigit,+b0: Bool,+b1: Bool,+b2: Bool,+b3: Bool,+b4: Bool,+b5: Bool,+b6: Bool,+b7: Bool,+b8: Bool) -> Bool:
  urgency_preserved_for_bits(placed,WCon{b0,WCon{b1,WCon{b2,WCon{b3,WCon{b4,WCon{b5,WCon{b6,WCon{b7,WCon{b8,WNil{}}}}}}}}}})

def urgency_flag_tree_8(+placed: BoardDigit,+b0: Bool,+b1: Bool,+b2: Bool,+b3: Bool,+b4: Bool,+b5: Bool,+b6: Bool,+b7: Bool) -> Bool:
  Bool.and(urgency_flag_tree_9(placed,b0,b1,b2,b3,b4,b5,b6,b7,False{}),urgency_flag_tree_9(placed,b0,b1,b2,b3,b4,b5,b6,b7,True{}))

def urgency_flag_tree_7(+placed: BoardDigit,+b0: Bool,+b1: Bool,+b2: Bool,+b3: Bool,+b4: Bool,+b5: Bool,+b6: Bool) -> Bool:
  Bool.and(urgency_flag_tree_8(placed,b0,b1,b2,b3,b4,b5,b6,False{}),urgency_flag_tree_8(placed,b0,b1,b2,b3,b4,b5,b6,True{}))

def urgency_flag_tree_6(+placed: BoardDigit,+b0: Bool,+b1: Bool,+b2: Bool,+b3: Bool,+b4: Bool,+b5: Bool) -> Bool:
  Bool.and(urgency_flag_tree_7(placed,b0,b1,b2,b3,b4,b5,False{}),urgency_flag_tree_7(placed,b0,b1,b2,b3,b4,b5,True{}))

def urgency_flag_tree_5(+placed: BoardDigit,+b0: Bool,+b1: Bool,+b2: Bool,+b3: Bool,+b4: Bool) -> Bool:
  Bool.and(urgency_flag_tree_6(placed,b0,b1,b2,b3,b4,False{}),urgency_flag_tree_6(placed,b0,b1,b2,b3,b4,True{}))

def urgency_flag_tree_4(+placed: BoardDigit,+b0: Bool,+b1: Bool,+b2: Bool,+b3: Bool) -> Bool:
  Bool.and(urgency_flag_tree_5(placed,b0,b1,b2,b3,False{}),urgency_flag_tree_5(placed,b0,b1,b2,b3,True{}))

def urgency_flag_tree_3(+placed: BoardDigit,+b0: Bool,+b1: Bool,+b2: Bool) -> Bool:
  Bool.and(urgency_flag_tree_4(placed,b0,b1,b2,False{}),urgency_flag_tree_4(placed,b0,b1,b2,True{}))

def urgency_flag_tree_2(+placed: BoardDigit,+b0: Bool,+b1: Bool) -> Bool:
  Bool.and(urgency_flag_tree_3(placed,b0,b1,False{}),urgency_flag_tree_3(placed,b0,b1,True{}))

def urgency_flag_tree_1(+placed: BoardDigit,+b0: Bool) -> Bool:
  Bool.and(urgency_flag_tree_2(placed,b0,False{}),urgency_flag_tree_2(placed,b0,True{}))

def urgency_flag_tree_0(+placed: BoardDigit) -> Bool:
  Bool.and(urgency_flag_tree_1(placed,False{}),urgency_flag_tree_1(placed,True{}))

law check_urgency_flag_tree_9:
  for +placed: BoardDigit
  for +b0: Bool
  for +b1: Bool
  for +b2: Bool
  for +b3: Bool
  for +b4: Bool
  for +b5: Bool
  for +b6: Bool
  for +b7: Bool
  for +b8: Bool
  for +suffix: Word(0n)
  for checked: {urgency_flag_tree_9(placed,b0,b1,b2,b3,b4,b5,b6,b7,b8) == True{} : Bool}
  {urgency_preserved_for_bits(placed,WCon{b0,WCon{b1,WCon{b2,WCon{b3,WCon{b4,WCon{b5,WCon{b6,WCon{b7,WCon{b8,suffix}}}}}}}}}) == True{} : Bool}

law select_urgency_subtree_8:
  for +placed: BoardDigit
  for +b0: Bool
  for +b1: Bool
  for +b2: Bool
  for +b3: Bool
  for +b4: Bool
  for +b5: Bool
  for +b6: Bool
  for +b7: Bool
  for +bit: Bool
  for both: ({urgency_flag_tree_9(placed,b0,b1,b2,b3,b4,b5,b6,b7,False{}) == True{} : Bool} & {urgency_flag_tree_9(placed,b0,b1,b2,b3,b4,b5,b6,b7,True{}) == True{} : Bool})
  {urgency_flag_tree_9(placed,b0,b1,b2,b3,b4,b5,b6,b7,bit) == True{} : Bool}

law check_urgency_flag_tree_8:
  for +placed: BoardDigit
  for +b0: Bool
  for +b1: Bool
  for +b2: Bool
  for +b3: Bool
  for +b4: Bool
  for +b5: Bool
  for +b6: Bool
  for +b7: Bool
  for +suffix: Word(1n)
  for checked: {urgency_flag_tree_8(placed,b0,b1,b2,b3,b4,b5,b6,b7) == True{} : Bool}
  {urgency_preserved_for_bits(placed,WCon{b0,WCon{b1,WCon{b2,WCon{b3,WCon{b4,WCon{b5,WCon{b6,WCon{b7,suffix}}}}}}}}) == True{} : Bool}

law select_urgency_subtree_7:
  for +placed: BoardDigit
  for +b0: Bool
  for +b1: Bool
  for +b2: Bool
  for +b3: Bool
  for +b4: Bool
  for +b5: Bool
  for +b6: Bool
  for +bit: Bool
  for both: ({urgency_flag_tree_8(placed,b0,b1,b2,b3,b4,b5,b6,False{}) == True{} : Bool} & {urgency_flag_tree_8(placed,b0,b1,b2,b3,b4,b5,b6,True{}) == True{} : Bool})
  {urgency_flag_tree_8(placed,b0,b1,b2,b3,b4,b5,b6,bit) == True{} : Bool}

law check_urgency_flag_tree_7:
  for +placed: BoardDigit
  for +b0: Bool
  for +b1: Bool
  for +b2: Bool
  for +b3: Bool
  for +b4: Bool
  for +b5: Bool
  for +b6: Bool
  for +suffix: Word(2n)
  for checked: {urgency_flag_tree_7(placed,b0,b1,b2,b3,b4,b5,b6) == True{} : Bool}
  {urgency_preserved_for_bits(placed,WCon{b0,WCon{b1,WCon{b2,WCon{b3,WCon{b4,WCon{b5,WCon{b6,suffix}}}}}}}) == True{} : Bool}

law select_urgency_subtree_6:
  for +placed: BoardDigit
  for +b0: Bool
  for +b1: Bool
  for +b2: Bool
  for +b3: Bool
  for +b4: Bool
  for +b5: Bool
  for +bit: Bool
  for both: ({urgency_flag_tree_7(placed,b0,b1,b2,b3,b4,b5,False{}) == True{} : Bool} & {urgency_flag_tree_7(placed,b0,b1,b2,b3,b4,b5,True{}) == True{} : Bool})
  {urgency_flag_tree_7(placed,b0,b1,b2,b3,b4,b5,bit) == True{} : Bool}

law check_urgency_flag_tree_6:
  for +placed: BoardDigit
  for +b0: Bool
  for +b1: Bool
  for +b2: Bool
  for +b3: Bool
  for +b4: Bool
  for +b5: Bool
  for +suffix: Word(3n)
  for checked: {urgency_flag_tree_6(placed,b0,b1,b2,b3,b4,b5) == True{} : Bool}
  {urgency_preserved_for_bits(placed,WCon{b0,WCon{b1,WCon{b2,WCon{b3,WCon{b4,WCon{b5,suffix}}}}}}) == True{} : Bool}

law select_urgency_subtree_5:
  for +placed: BoardDigit
  for +b0: Bool
  for +b1: Bool
  for +b2: Bool
  for +b3: Bool
  for +b4: Bool
  for +bit: Bool
  for both: ({urgency_flag_tree_6(placed,b0,b1,b2,b3,b4,False{}) == True{} : Bool} & {urgency_flag_tree_6(placed,b0,b1,b2,b3,b4,True{}) == True{} : Bool})
  {urgency_flag_tree_6(placed,b0,b1,b2,b3,b4,bit) == True{} : Bool}

law check_urgency_flag_tree_5:
  for +placed: BoardDigit
  for +b0: Bool
  for +b1: Bool
  for +b2: Bool
  for +b3: Bool
  for +b4: Bool
  for +suffix: Word(4n)
  for checked: {urgency_flag_tree_5(placed,b0,b1,b2,b3,b4) == True{} : Bool}
  {urgency_preserved_for_bits(placed,WCon{b0,WCon{b1,WCon{b2,WCon{b3,WCon{b4,suffix}}}}}) == True{} : Bool}

law select_urgency_subtree_4:
  for +placed: BoardDigit
  for +b0: Bool
  for +b1: Bool
  for +b2: Bool
  for +b3: Bool
  for +bit: Bool
  for both: ({urgency_flag_tree_5(placed,b0,b1,b2,b3,False{}) == True{} : Bool} & {urgency_flag_tree_5(placed,b0,b1,b2,b3,True{}) == True{} : Bool})
  {urgency_flag_tree_5(placed,b0,b1,b2,b3,bit) == True{} : Bool}

law check_urgency_flag_tree_4:
  for +placed: BoardDigit
  for +b0: Bool
  for +b1: Bool
  for +b2: Bool
  for +b3: Bool
  for +suffix: Word(5n)
  for checked: {urgency_flag_tree_4(placed,b0,b1,b2,b3) == True{} : Bool}
  {urgency_preserved_for_bits(placed,WCon{b0,WCon{b1,WCon{b2,WCon{b3,suffix}}}}) == True{} : Bool}

law select_urgency_subtree_3:
  for +placed: BoardDigit
  for +b0: Bool
  for +b1: Bool
  for +b2: Bool
  for +bit: Bool
  for both: ({urgency_flag_tree_4(placed,b0,b1,b2,False{}) == True{} : Bool} & {urgency_flag_tree_4(placed,b0,b1,b2,True{}) == True{} : Bool})
  {urgency_flag_tree_4(placed,b0,b1,b2,bit) == True{} : Bool}

law check_urgency_flag_tree_3:
  for +placed: BoardDigit
  for +b0: Bool
  for +b1: Bool
  for +b2: Bool
  for +suffix: Word(6n)
  for checked: {urgency_flag_tree_3(placed,b0,b1,b2) == True{} : Bool}
  {urgency_preserved_for_bits(placed,WCon{b0,WCon{b1,WCon{b2,suffix}}}) == True{} : Bool}

law select_urgency_subtree_2:
  for +placed: BoardDigit
  for +b0: Bool
  for +b1: Bool
  for +bit: Bool
  for both: ({urgency_flag_tree_3(placed,b0,b1,False{}) == True{} : Bool} & {urgency_flag_tree_3(placed,b0,b1,True{}) == True{} : Bool})
  {urgency_flag_tree_3(placed,b0,b1,bit) == True{} : Bool}

law check_urgency_flag_tree_2:
  for +placed: BoardDigit
  for +b0: Bool
  for +b1: Bool
  for +suffix: Word(7n)
  for checked: {urgency_flag_tree_2(placed,b0,b1) == True{} : Bool}
  {urgency_preserved_for_bits(placed,WCon{b0,WCon{b1,suffix}}) == True{} : Bool}

law select_urgency_subtree_1:
  for +placed: BoardDigit
  for +b0: Bool
  for +bit: Bool
  for both: ({urgency_flag_tree_2(placed,b0,False{}) == True{} : Bool} & {urgency_flag_tree_2(placed,b0,True{}) == True{} : Bool})
  {urgency_flag_tree_2(placed,b0,bit) == True{} : Bool}

law check_urgency_flag_tree_1:
  for +placed: BoardDigit
  for +b0: Bool
  for +suffix: Word(8n)
  for checked: {urgency_flag_tree_1(placed,b0) == True{} : Bool}
  {urgency_preserved_for_bits(placed,WCon{b0,suffix}) == True{} : Bool}

law select_urgency_subtree_0:
  for +placed: BoardDigit
  for +bit: Bool
  for both: ({urgency_flag_tree_1(placed,False{}) == True{} : Bool} & {urgency_flag_tree_1(placed,True{}) == True{} : Bool})
  {urgency_flag_tree_1(placed,bit) == True{} : Bool}

law check_urgency_flag_tree_0:
  for +placed: BoardDigit
  for +suffix: Word(9n)
  for checked: {urgency_flag_tree_0(placed) == True{} : Bool}
  {urgency_preserved_for_bits(placed,suffix) == True{} : Bool}

law equal_urgency_sound:
  for +a: Bool
  for +b: Bool
  for yes: {equal_urgency(a,b) == True{} : Bool}
  {a == b : Bool}

law all_masks_keep_urgency:
  for +placed: BoardDigit
  {urgency_flag_tree_0(placed) == True{} : Bool}

law normalized_bits_keep_exact_urgency:
  for +placed: BoardDigit
  for +bits: Word(9n)
  {urgency_after_peer(candidate_bits_word(bits),B.bit(digit_word(placed)),Q.zero_or_single(candidate_bits_word(bits))) ==
    Q.zero_or_single(blank_after_peer(candidate_bits_word(bits),B.bit(digit_word(placed)))) : Bool}

def UrgencyConsistent(+placed: BoardDigit, +old: U32) -> Type:
  {urgency_after_peer(old,B.bit(digit_word(placed)),Q.zero_or_single(old)) ==
    Q.zero_or_single(blank_after_peer(old,B.bit(digit_word(placed)))) : Bool}

law urgency_from_candidate_image:
  for +placed: BoardDigit
  for +old: U32
  for image: CandidateMaskImage(old)
  UrgencyConsistent(placed,U32.and(1022,old))

law normalized_blank_keeps_exact_urgency:
  for +placed: BoardDigit
  for +old: U32
  for normalized: NormalizedQueueMask(old)
  UrgencyConsistent(placed,old)

def FlagWrittenWord(-b: Array<U32>, +p: U32, +on: Bool) -> Type:
  {cell_value(Q.flag(b,p,on),flag_slot(p)) == flag_word(p,on,cell_value(b,flag_slot(p))) : U32}

law flag_writes_slot_word_image:
  for +image: BoardImage
  for +p: U32
  for +on: Bool
  FlagWrittenWord(image_board(image),p,on)

law flag_writes_slot_word:
  for b: Array<U32>
  for +p: U32
  for +on: Bool
  FlagWrittenWord(b,p,on)

def ChangedFlagWord(-b: Array<U32>, +p: U32, +needed: Bool) -> Type:
  {cell_value(Q.changed_flag(needed,b,p),flag_slot(p)) ==
    Bool.pick(U32,needed,flag_word(p,True{},cell_value(b,flag_slot(p))),cell_value(b,flag_slot(p))) : U32}

law changed_flag_slot_word:
  for b: Array<U32>
  for +p: U32
  for +needed: Bool
  ChangedFlagWord(b,p,needed)

def peer_flag_word_model(+p: U32, +old: U32, +bit: U32, +flags: U32) -> U32:
  Bool.pick(U32,Bool.and(U32.is_ne(U32.and(old,bit),0),peer_reflag(old,bit)),flag_word(p,True{},flags),flags)

law pick_flag_word_rewrite:
  for +p: U32
  for +change: Bool
  for +before: U32
  for +after: U32
  for eq: {after == before : U32}
  {Bool.pick(U32,change,flag_word(p,True{},after),after) ==
    Bool.pick(U32,change,flag_word(p,True{},before),before) : U32}

law peer_flag_word_change_step:
  for +image: BoardImage
  for +needed: Bool
  for +p: U32
  for +bit: U32
  for +old: U32
  for shape: Board128(image_board(image))
  for apart: RoutedApart(p,flag_slot(p))
  {cell_value(Q.changed(needed,p,bit,image_board(image),old),flag_slot(p)) ==
    Bool.pick(U32,Bool.and(needed,peer_reflag(old,bit)),
      flag_word(p,True{},cell_value(image_board(image),flag_slot(p))),
      cell_value(image_board(image),flag_slot(p))) : U32}

def PeerFlagWord(-b: Array<U32>, +p: U32, +bit: U32) -> Type:
  Board128(b) -> RoutedApart(p,flag_slot(p)) ->
  {cell_value(actual_peer(b,p,bit),flag_slot(p)) ==
    peer_flag_word_model(p,cell_value(b,p),bit,cell_value(b,flag_slot(p))) : U32}

law actual_peer_flag_word_image:
  for +image: BoardImage
  for +p: U32
  for +bit: U32
  PeerFlagWord(image_board(image),p,bit)

law actual_peer_flag_word:
  for b: Array<U32>
  for +p: U32
  for +bit: U32
  PeerFlagWord(b,p,bit)

law bit_mask_set_is_set:
  for +old: Bool
  for +mask: Bool
  {Bool.and(mask,Bool.or(old,mask)) == mask : Bool}

law bit_mask_clear_is_clear:
  for +old: Bool
  for +mask: Bool
  {Bool.and(mask,Bool.and(old,Bool.not(mask))) == False{} : Bool}

law word_mask_set_is_set:
  for +n: Nat
  for +old: Word(n)
  for +mask: Word(n)
  {Word.and(n,mask,Word.or(n,old,mask)) == mask : Word(n)}

law word_mask_clear_is_clear:
  for +n: Nat
  for +old: Word(n)
  for +mask: Word(n)
  {Word.and(n,mask,Word.and(n,old,Word.not(n,mask))) == Word.zero(n) : Word(n)}

law u32_mask_set_is_set:
  for +old: U32
  for +mask: U32
  {U32.and(mask,U32.or(old,mask)) == mask : U32}

law u32_mask_clear_is_clear:
  for +old: U32
  for +mask: U32
  {U32.and(mask,U32.and(old,U32.not(mask))) == 0 : U32}

def own_queue_flag_mask(+p: U32) -> U32:
  flag_bit_at(U32.and(p,31))

def queue_flag_present(+p: U32, +flags: U32) -> Bool:
  U32.is_ne(U32.and(own_queue_flag_mask(p),flags),0)

law flag_word_set_is_present:
  for +p: U32
  for +flags: U32
  for nonzero: {U32.is_ne(own_queue_flag_mask(p),0) == True{} : Bool}
  {queue_flag_present(p,flag_word(p,True{},flags)) == True{} : Bool}

law flag_word_clear_is_absent:
  for +p: U32
  for +flags: U32
  {queue_flag_present(p,flag_word(p,False{},flags)) == False{} : Bool}

law flag_word_flag_matches_value:
  for +p: U32
  for +on: Bool
  for +flags: U32
  for nonzero: {U32.is_ne(own_queue_flag_mask(p),0) == True{} : Bool}
  {queue_flag_present(p,flag_word(p,on,flags)) == on : Bool}

law bool_or_right_false_at:
  for +value: Bool
  {value == Bool.or(value,False{}) : Bool}

law bool_or_right_true_from:
  for +value: Bool
  {True{} == Bool.or(value,True{}) : Bool}

law actual_peer_flag_model_bits:
  for +p: U32
  for +change: Bool
  for +flags: U32
  for nonzero: {U32.is_ne(own_queue_flag_mask(p),0) == True{} : Bool}
  {queue_flag_present(p,Bool.pick(U32,change,flag_word(p,True{},flags),flags)) ==
    Bool.or(queue_flag_present(p,flags),change) : Bool}

law actual_peer_flag_model_observable:
  for +p: U32
  for +old: U32
  for +bit: U32
  for +flags: U32
  for nonzero: {U32.is_ne(own_queue_flag_mask(p),0) == True{} : Bool}
  {queue_flag_present(p,peer_flag_word_model(p,old,bit,flags)) ==
    urgency_after_peer(old,bit,queue_flag_present(p,flags)) : Bool}

def actual_flag_at(b: Array<U32>, +p: U32) -> Bool:
  queue_flag_present(p,cell_value(b,flag_slot(p)))

law actual_peer_observed_flag_image:
  for +image: BoardImage
  for +p: U32
  for +bit: U32
  for shape: Board128(image_board(image))
  for apart: RoutedApart(p,flag_slot(p))
  for nonzero: {U32.is_ne(own_queue_flag_mask(p),0) == True{} : Bool}
  {actual_flag_at(actual_peer(image_board(image),p,bit),p) ==
    urgency_after_peer(cell_value(image_board(image),p),bit,actual_flag_at(image_board(image),p)) : Bool}

law actual_changed_candidate_image:
  for +image: BoardImage
  for +needed: Bool
  for +p: U32
  for +bit: U32
  for shape: Board128(image_board(image))
  for apart: RoutedApart(flag_slot(p),p)
  {cell_value(Q.changed(needed,p,bit,image_board(image),cell_value(image_board(image),p)),p) ==
    Bool.pick(U32,needed,peer_mask(cell_value(image_board(image),p),bit),cell_value(image_board(image),p)) : U32}

law actual_peer_candidate_image:
  for +image: BoardImage
  for +p: U32
  for +bit: U32
  for shape: Board128(image_board(image))
  for apart: RoutedApart(flag_slot(p),p)
  {cell_value(actual_peer(image_board(image),p,bit),p) ==
    blank_after_peer(cell_value(image_board(image),p),bit) : U32}

law prior_flag_urgency_agrees:
  for +placed: BoardDigit
  for +old: U32
  for +prior: Bool
  for observed: {prior == Q.zero_or_single(old) : Bool}
  for norm: NormalizedQueueMask(old)
  {urgency_after_peer(old,B.bit(digit_word(placed)),prior) ==
    Q.zero_or_single(blank_after_peer(old,B.bit(digit_word(placed)))) : Bool}

law actual_peer_normalized_urgency_parts:
  for +image: BoardImage
  for +p: U32
  for +placed: BoardDigit
  for shapes: (Board128(image_board(image)) & Board128(image_board(image)))
  for flag_route: RoutedApart(p,flag_slot(p))
  for cell_route: RoutedApart(flag_slot(p),p)
  for nonzero: {U32.is_ne(own_queue_flag_mask(p),0) == True{} : Bool}
  for observed: {actual_flag_at(image_board(image),p) == Q.zero_or_single(cell_value(image_board(image),p)) : Bool}
  for norm: NormalizedQueueMask(cell_value(image_board(image),p))
  {actual_flag_at(actual_peer(image_board(image),p,B.bit(digit_word(placed))),p) ==
    Q.zero_or_single(cell_value(actual_peer(image_board(image),p,B.bit(digit_word(placed))),p)) : Bool}

def ActualPeerKeepsUrgency(-b: Array<U32>, +p: U32, +placed: BoardDigit) -> Type:
  Board128(b) -> RoutedApart(p,flag_slot(p)) -> RoutedApart(flag_slot(p),p) ->
  {U32.is_ne(own_queue_flag_mask(p),0) == True{} : Bool} ->
  {actual_flag_at(b,p) == Q.zero_or_single(cell_value(b,p)) : Bool} ->
  NormalizedQueueMask(cell_value(b,p)) ->
  {actual_flag_at(actual_peer(b,p,B.bit(digit_word(placed))),p) ==
    Q.zero_or_single(cell_value(actual_peer(b,p,B.bit(digit_word(placed))),p)) : Bool}

law actual_peer_normalized_urgency_image:
  for +image: BoardImage
  for +p: U32
  for +placed: BoardDigit
  ActualPeerKeepsUrgency(image_board(image),p,placed)

law actual_peer_normalized_urgency:
  for b: Array<U32>
  for +p: U32
  for +placed: BoardDigit
  ActualPeerKeepsUrgency(b,p,placed)

def low_five_word(+b0: Bool,+b1: Bool,+b2: Bool,+b3: Bool,+b4: Bool,+tail: Word(27n)) -> U32:
  U32{WCon{b0,WCon{b1,WCon{b2,WCon{b3,WCon{b4,tail}}}}}}

law low_five_flag_is_nonzero:
  for +b0: Bool
  for +b1: Bool
  for +b2: Bool
  for +b3: Bool
  for +b4: Bool
  {U32.is_ne(flag_bit_at(low_five_word(b0,b1,b2,b3,b4,Word.zero(27n))),0) == True{} : Bool}

law own_queue_flag_mask_is_nonzero:
  for +p: U32
  {U32.is_ne(own_queue_flag_mask(p),0) == True{} : Bool}

law logical_cell_and_flag_are_apart:
  for +row: CellCoordinate
  for +col: CellCoordinate
  RoutedApart(logical_position(row,col),flag_slot(logical_position(row,col)))

law logical_peer_preserves_exact_urgency:
  for b: Array<U32>
  for +row: CellCoordinate
  for +col: CellCoordinate
  for +placed: BoardDigit
  for shape: Board128(b)
  for observed: {actual_flag_at(b,logical_position(row,col)) == Q.zero_or_single(cell_value(b,logical_position(row,col))) : Bool}
  for norm: NormalizedQueueMask(cell_value(b,logical_position(row,col)))
  {actual_flag_at(actual_peer(b,logical_position(row,col),B.bit(digit_word(placed))),logical_position(row,col)) ==
    Q.zero_or_single(cell_value(actual_peer(b,logical_position(row,col),B.bit(digit_word(placed))),logical_position(row,col))) : Bool}

def bit_word_head(+n: Nat, +w: Word(1n+n)) -> Bool:
  match w:
    case WCon{head,tail}:
      head

def bit_word_tail(+n: Nat, +w: Word(1n+n)) -> Word(n):
  match w:
    case WCon{head,tail}:
      tail

def bits_of_u32(+w: U32) -> Word(32n):
  match w:
    case U32{bits}:
      bits

law word_mask_set_keeps_other:
  for +n: Nat
  for +value: Word(n)
  for +watch: Word(n)
  for +edit: Word(n)
  for apart: {Word.and(n,watch,edit) == Word.zero(n) : Word(n)}
  {Word.and(n,watch,Word.or(n,value,edit)) == Word.and(n,watch,value) : Word(n)}

law u32_mask_set_keeps_other:
  for +value: U32
  for +watch: U32
  for +edit: U32
  for apart: {U32.and(watch,edit) == 0 : U32}
  {U32.and(watch,U32.or(value,edit)) == U32.and(watch,value) : U32}

law word_mask_clear_keeps_other:
  for +n: Nat
  for +value: Word(n)
  for +watch: Word(n)
  for +edit: Word(n)
  for apart: {Word.and(n,watch,edit) == Word.zero(n) : Word(n)}
  {Word.and(n,watch,Word.and(n,value,Word.not(n,edit))) == Word.and(n,watch,value) : Word(n)}

law u32_mask_clear_keeps_other:
  for +value: U32
  for +watch: U32
  for +edit: U32
  for apart: {U32.and(watch,edit) == 0 : U32}
  {U32.and(watch,U32.and(value,U32.not(edit))) == U32.and(watch,value) : U32}

law flag_update_keeps_disjoint_watch_mask:
  for +pos: U32
  for +watch: U32
  for +value: U32
  for +on: Bool
  for apart: {U32.and(watch,own_queue_flag_mask(pos)) == 0 : U32}
  {U32.and(watch,flag_word(pos,on,value)) == U32.and(watch,value) : U32}

def FlagPaddingRoute(+p: U32) -> Type:
  Either<&1,&1,RoutedApart(flag_slot(p),111),
    ({flag_slot(p) == 111 : U32} & {U32.and(4294836224,own_queue_flag_mask(p)) == 0 : U32})>

law logical_flag_padding_route:
  for +row: CellCoordinate
  for +col: CellCoordinate
  FlagPaddingRoute(logical_position(row,col))

def FlagKeepsPadding(-b: Array<U32>, +p: U32, +on: Bool) -> Type:
  Board128(b) -> FlagPaddingRoute(p) ->
  {U32.and(4294836224,cell_value(Q.flag(b,p,on),111)) == U32.and(4294836224,cell_value(b,111)) : U32}

law flag_keeps_padding_same_slot:
  for +image: BoardImage
  for +p: U32
  for +on: Bool
  for disjoint: {U32.and(4294836224,own_queue_flag_mask(p)) == 0 : U32}
  {U32.and(4294836224,cell_value(Q.flag(image_board(image),p,on),flag_slot(p))) ==
    U32.and(4294836224,cell_value(image_board(image),flag_slot(p))) : U32}

law flag_keeps_padding_image:
  for +image: BoardImage
  for +p: U32
  for +on: Bool
  FlagKeepsPadding(image_board(image),p,on)

law flag_keeps_padding:
  for b: Array<U32>
  for +p: U32
  for +on: Bool
  FlagKeepsPadding(b,p,on)

law actual_logical_flag_keeps_high_padding:
  for b: Array<U32>
  for +row: CellCoordinate
  for +col: CellCoordinate
  for +on: Bool
  for shape: Board128(b)
  {U32.and(4294836224,cell_value(Q.flag(b,logical_position(row,col),on),111)) ==
    U32.and(4294836224,cell_value(b,111)) : U32}

law queue_seed_zeros_final_flag_slot:
  for b: Array<U32>
  {cell_value(queue_seed(b),111) == 0 : U32}

def high_flag_padding(b: Array<U32>) -> U32:
  U32.and(4294836224,cell_value(b,111))

law logical_write_apart_from_flag_padding:
  for +row: CellCoordinate
  for +col: CellCoordinate
  RoutedApart(logical_position(row,col),111)

def ChangedFlagKeepsPadding(-b: Array<U32>, +p: U32, +needed: Bool) -> Type:
  Board128(b) -> FlagPaddingRoute(p) ->
  {high_flag_padding(Q.changed_flag(needed,b,p)) == high_flag_padding(b) : U32}

law changed_flag_keeps_padding:
  for b: Array<U32>
  for +p: U32
  for +needed: Bool
  ChangedFlagKeepsPadding(b,p,needed)

law changed_write_keeps_padding_yes:
  for +image: BoardImage
  for +p: U32
  for +old: U32
  for +bit: U32
  for shapes: (Board128(image_board(image)) & Board128(image_board(image)))
  for apart: RoutedApart(p,111)
  for route: FlagPaddingRoute(p)
  {high_flag_padding(Q.changed(True{},p,bit,image_board(image),old)) == high_flag_padding(image_board(image)) : U32}

law changed_write_keeps_padding_image:
  for +image: BoardImage
  for +needed: Bool
  for +p: U32
  for +old: U32
  for +bit: U32
  for shape: Board128(image_board(image))
  for apart: RoutedApart(p,111)
  for route: FlagPaddingRoute(p)
  {high_flag_padding(Q.changed(needed,p,bit,image_board(image),old)) == high_flag_padding(image_board(image)) : U32}

def PeerKeepsPadding(-b: Array<U32>, +p: U32, +bit: U32) -> Type:
  Board128(b) -> RoutedApart(p,111) -> FlagPaddingRoute(p) ->
  {high_flag_padding(actual_peer(b,p,bit)) == high_flag_padding(b) : U32}

law actual_peer_keeps_padding_image:
  for +image: BoardImage
  for +p: U32
  for +bit: U32
  PeerKeepsPadding(image_board(image),p,bit)

law actual_peer_keeps_padding:
  for b: Array<U32>
  for +p: U32
  for +bit: U32
  PeerKeepsPadding(b,p,bit)

law logical_peer_keeps_flag_padding:
  for b: Array<U32>
  for +row: CellCoordinate
  for +col: CellCoordinate
  for +bit: U32
  for shape: Board128(b)
  {high_flag_padding(actual_peer(b,logical_position(row,col),bit)) == high_flag_padding(b) : U32}

def OtherFlagRoute(+p: U32, +q: U32) -> Type:
  Either<&1,&1,RoutedApart(flag_slot(p),flag_slot(q)),
    ({flag_slot(p) == flag_slot(q) : U32} &
     {U32.and(own_queue_flag_mask(q),own_queue_flag_mask(p)) == 0 : U32})>

def FlagKeepsOther(-b: Array<U32>, +p: U32, +q: U32, +on: Bool) -> Type:
  Board128(b) -> OtherFlagRoute(p,q) ->
  {actual_flag_at(Q.flag(b,p,on),q) == actual_flag_at(b,q) : Bool}

law flag_keeps_other_shared_slot:
  for +image: BoardImage
  for +p: U32
  for +q: U32
  for +on: Bool
  for disjoint: {U32.and(own_queue_flag_mask(q),own_queue_flag_mask(p)) == 0 : U32}
  {queue_flag_present(q,cell_value(Q.flag(image_board(image),p,on),flag_slot(p))) ==
    queue_flag_present(q,cell_value(image_board(image),flag_slot(p))) : Bool}

law flag_keeps_other_image:
  for +image: BoardImage
  for +p: U32
  for +q: U32
  for +on: Bool
  FlagKeepsOther(image_board(image),p,q,on)

law actual_flag_keeps_other:
  for b: Array<U32>
  for +p: U32
  for +q: U32
  for +on: Bool
  FlagKeepsOther(b,p,q,on)

def ChangedFlagKeepsOther(-b: Array<U32>, +p: U32, +q: U32, +needed: Bool) -> Type:
  Board128(b) -> OtherFlagRoute(p,q) ->
  {actual_flag_at(Q.changed_flag(needed,b,p),q) == actual_flag_at(b,q) : Bool}

law changed_flag_keeps_other:
  for b: Array<U32>
  for +p: U32
  for +q: U32
  for +needed: Bool
  ChangedFlagKeepsOther(b,p,q,needed)

law peer_write_keeps_other_flag_yes:
  for +image: BoardImage
  for +p: U32
  for +q: U32
  for +old: U32
  for +bit: U32
  for shapes: (Board128(image_board(image)) & Board128(image_board(image)))
  for apart: RoutedApart(p,flag_slot(q))
  for route: OtherFlagRoute(p,q)
  {actual_flag_at(Q.changed(True{},p,bit,image_board(image),old),q) == actual_flag_at(image_board(image),q) : Bool}

law peer_write_keeps_other_flag_image:
  for +image: BoardImage
  for +needed: Bool
  for +p: U32
  for +q: U32
  for +old: U32
  for +bit: U32
  for shape: Board128(image_board(image))
  for apart: RoutedApart(p,flag_slot(q))
  for route: OtherFlagRoute(p,q)
  {actual_flag_at(Q.changed(needed,p,bit,image_board(image),old),q) == actual_flag_at(image_board(image),q) : Bool}

def PeerKeepsOtherFlag(-b: Array<U32>, +p: U32, +q: U32, +bit: U32) -> Type:
  Board128(b) -> RoutedApart(p,flag_slot(q)) -> OtherFlagRoute(p,q) ->
  {actual_flag_at(actual_peer(b,p,bit),q) == actual_flag_at(b,q) : Bool}

law actual_peer_keeps_other_flag_image:
  for +image: BoardImage
  for +p: U32
  for +q: U32
  for +bit: U32
  PeerKeepsOtherFlag(image_board(image),p,q,bit)

law actual_peer_keeps_other_flag:
  for b: Array<U32>
  for +p: U32
  for +q: U32
  for +bit: U32
  PeerKeepsOtherFlag(b,p,q,bit)

def ProtectedEncodeRoute(+watched: U32) -> Type:
  (RoutedApart(109,watched) & RoutedApart(110,watched) & RoutedApart(111,watched) & EncodeApart(81n,0,watched))

law occupancy_not_written_routes:
  for +band: CacheGroup
  for +index: CellCoordinate
  ProtectedEncodeRoute(cache_group_slot(band,index))

def EncodeKeepsWord(-b: Array<U32>, +q: U32) -> Type:
  Board128(b) -> ProtectedEncodeRoute(q) -> {cell_value(Q.encode(b),q) == cell_value(b,q) : U32}

law encode_keeps_protected_word_parts:
  for +image: BoardImage
  for +q: U32
  for shapes: (Board128(image_board(image)) & Board128(image_board(image)))
  for routes: ProtectedEncodeRoute(q)
  {cell_value(Q.encode(image_board(image)),q) == cell_value(image_board(image),q) : U32}

law encode_keeps_protected_word_image:
  for +image: BoardImage
  for +q: U32
  EncodeKeepsWord(image_board(image),q)

law encode_keeps_protected_word:
  for b: Array<U32>
  for +q: U32
  EncodeKeepsWord(b,q)

law queued_encode_keeps_ordinary_occupancy:
  for b: Array<U32>
  for +band: CacheGroup
  for +index: CellCoordinate
  for shape: Board128(b)
  {cell_value(Q.encode(b),cache_group_slot(band,index)) == cell_value(b,cache_group_slot(band,index)) : U32}

law encode_routes_prefix:
  for +n: Nat
  for +remaining: Nat
  for +p: U32
  for +q: U32
  for whole: EncodeApart(Nat.add(n,remaining),p,q)
  EncodeApart(n,p,q)

law encoded_prefix_from_seed_keeps_occupancy:
  for b: Array<U32>
  for +n: Nat
  for +remaining: Nat
  for +band: CacheGroup
  for +index: CellCoordinate
  for shape: Board128(b)
  for sweep: {Nat.add(n,remaining) == 81n : Nat}
  {cell_value(Q.encode_go(n,0,queue_seed(b)),cache_group_slot(band,index)) == cell_value(b,cache_group_slot(band,index)) : U32}

law encode_keeps_seeded_prefix_routes:
  for +image: BoardImage
  for +n: Nat
  for +q: U32
  for shapes: (Board128(image_board(image)) & Board128(image_board(image)))
  for r9: RoutedApart(109,q)
  for r10: RoutedApart(110,q)
  for r11: RoutedApart(111,q)
  for prefix: EncodeApart(n,0,q)
  {cell_value(Q.encode_go(n,0,queue_seed(image_board(image))),q) == cell_value(image_board(image),q) : U32}

law encode_routes_prefix_from_total:
  for +n: Nat
  for +remaining: Nat
  for +q: U32
  for sweep: {Nat.add(n,remaining) == 81n : Nat}
  for whole: EncodeApart(81n,0,q)
  EncodeApart(n,0,q)

law encode_protected_prefix_image:
  for +image: BoardImage
  for +n: Nat
  for +remaining: Nat
  for +q: U32
  for shape: Board128(image_board(image))
  for routes: ProtectedEncodeRoute(q)
  for sweep: {Nat.add(n,remaining) == 81n : Nat}
  {cell_value(Q.encode_go(n,0,queue_seed(image_board(image))),q) == cell_value(image_board(image),q) : U32}

law cached_read_exact_parts:
  for -b: Array<U32>
  for +p: U32
  for -same: Array<U32>
  for +value: U32
  for kept: {same == b : Array<U32>}
  for read: {B.get_cell(b,p) == (same,value) : Array<U32> & U32}
  {B.get_cell(b,p) == (b,cell_value(b,p)) : Array<U32> & U32}

law cached_read_exact:
  for b: Array<U32>
  for +p: U32
  for read: BoardReadWitness(b,p)
  {B.get_cell(b,p) == (b,cell_value(b,p)) : Array<U32> & U32}

law cached_add_exact_image:
  for +image: BoardImage
  for +p: U32
  for +used: U32
  {C.cached_add(p,(image_board(image),used)) ==
    (image_board(image),U32.or(used,cell_value(image_board(image),p))) : Array<U32> & U32}

def occupancy_candidate_mask(+row_bits: U32,+col_bits: U32,+box_bits: U32) -> U32:
  U32.and(1022,U32.not(U32.or(U32.or(row_bits,col_bits),box_bits)))

law cached_candidates_are_occupancy_image:
  for +image: BoardImage
  for +p: U32
  {cached_word(image_board(image),p) ==
    occupancy_candidate_mask(cell_value(image_board(image),ordinary_row_slot(p)),
      cell_value(image_board(image),ordinary_col_slot(p)),cell_value(image_board(image),ordinary_box_slot(p))) : U32}

def SameOccupancyAt(-a: Array<U32>,-b: Array<U32>,+p: U32) -> Type:
  ({cell_value(a,ordinary_row_slot(p)) == cell_value(b,ordinary_row_slot(p)) : U32} &
   {cell_value(a,ordinary_col_slot(p)) == cell_value(b,ordinary_col_slot(p)) : U32} &
   {cell_value(a,ordinary_box_slot(p)) == cell_value(b,ordinary_box_slot(p)) : U32})

law cached_word_same_occupancy:
  for +new: BoardImage
  for +old: BoardImage
  for +p: U32
  for same: SameOccupancyAt(image_board(new),image_board(old),p)
  {cached_word(image_board(new),p) == cached_word(image_board(old),p) : U32}

def seeded_encode_prefix(+n: Nat,b: Array<U32>) -> Array<U32>:
  Q.encode_go(n,0,queue_seed(b))

law encode_prefix_holds_cache_read_parts:
  for +image: BoardImage
  for +n: Nat
  for +remaining: Nat
  for +row: CellCoordinate
  for +col: CellCoordinate
  for shapes: (Board128(image_board(image)) & Board128(image_board(image)) & Board128(image_board(image)))
  for sweeps: ({Nat.add(n,remaining) == 81n : Nat} & {Nat.add(n,remaining) == 81n : Nat} & {Nat.add(n,remaining) == 81n : Nat})
  for geometry: OrdinaryGeometry(row,col)
  SameOccupancyAt(seeded_encode_prefix(n,image_board(image)),image_board(image),logical_position(row,col))

law copy_nat_eq:
  for -a: Nat
  for -b: Nat
  for same: {a == b : Nat}
  ({a == b : Nat} & {a == b : Nat} & {a == b : Nat})

law encoded_prefix_keeps_cached_candidate_image:
  for +image: BoardImage
  for +n: Nat
  for +remaining: Nat
  for +row: CellCoordinate
  for +col: CellCoordinate
  for shape: Board128(image_board(image))
  for sweep: {Nat.add(n,remaining) == 81n : Nat}
  {cached_word(seeded_encode_prefix(n,image_board(image)),logical_position(row,col)) ==
    cached_word(image_board(image),logical_position(row,col)) : U32}

def EncodeKeepsCacheSource(-b: Array<U32>, +n: Nat,+remaining: Nat,+row: CellCoordinate,+col: CellCoordinate) -> Type:
  Board128(b) -> {Nat.add(n,remaining) == 81n : Nat} ->
  {cached_word(seeded_encode_prefix(n,b),logical_position(row,col)) == cached_word(b,logical_position(row,col)) : U32}

law actual_encoded_prefix_keeps_cached_candidate:
  for b: Array<U32>
  for +n: Nat
  for +remaining: Nat
  for +row: CellCoordinate
  for +col: CellCoordinate
  EncodeKeepsCacheSource(b,n,remaining,row,col)

law encode_go_split_at_prefix:
  for +prefix: Nat
  for +suffix: Nat
  for +start: U32
  for b: Array<U32>
  {Q.encode_go(Nat.add(prefix,suffix),start,b) ==
    Q.encode_go(suffix,walk_position(prefix,start),Q.encode_go(prefix,start,b)) : Array<U32>}

law encoded_blank_is_exact_cached_word_image:
  for +image: BoardImage
  for +p: U32
  for shape: Board128(image_board(image))
  for apart: RoutedApart(flag_slot(p),p)
  {cell_value(Q.encoded(p,(image_board(image),0)),p) == cached_word(image_board(image),p) : U32}

def EncodeBlankIsExactCache(-b: Array<U32>,+p: U32) -> Type:
  Board128(b) -> RoutedApart(flag_slot(p),p) -> {cell_value(b,p) == 0 : U32} ->
  {cell_value(actual_encoded_step(b,p),p) == cached_word(b,p) : U32}

law actual_encode_blank_exact_cache_image:
  for +image: BoardImage
  for +p: U32
  EncodeBlankIsExactCache(image_board(image),p)

law actual_encode_blank_exact_cache:
  for b: Array<U32>
  for +p: U32
  EncodeBlankIsExactCache(b,p)

law full_queue_encode_as_local_step:
  for +prefix: Nat
  for +suffix: Nat
  for b: Array<U32>
  for total: {Nat.add(prefix,1n+suffix) == 81n : Nat}
  {Q.encode(b) == Q.encode_go(suffix,(walk_position(prefix,0) + 1 : U32),
    actual_encoded_step(seeded_encode_prefix(prefix,b),walk_position(prefix,0))) : Array<U32>}

law with_center_is_add:
  for +prefix: Nat
  for +suffix: Nat
  {with_center(prefix,suffix) == Nat.add(prefix,1n+suffix) : Nat}

law checked_center_total:
  for +prefix: Nat
  for +suffix: Nat
  for count: {with_center(prefix,suffix) == 81n : Nat}
  {Nat.add(prefix,1n+suffix) == 81n : Nat}

def encode_seeded_logical_prefix(+row: CellCoordinate,+col: CellCoordinate,b: Array<U32>) -> Array<U32>:
  seeded_encode_prefix(logical_offset(row,col),b)

law full_queue_encoded_blank_core:
  for +image: BoardImage
  for +row: CellCoordinate
  for +col: CellCoordinate
  for count: {Nat.add(logical_offset(row,col),1n+logical_tail(row,col)) == 81n : Nat}
  for shape: Board128(encode_seeded_logical_prefix(row,col,image_board(image)))
  for safe: RoutedApart(flag_slot(logical_position(row,col)),logical_position(row,col))
  for after: EncodeApart(logical_tail(row,col),(logical_position(row,col) + 1 : U32),logical_position(row,col))
  for blank: {cell_value(encode_seeded_logical_prefix(row,col,image_board(image)),logical_position(row,col)) == 0 : U32}
  for cache: {cached_word(encode_seeded_logical_prefix(row,col,image_board(image)),logical_position(row,col)) ==
    cached_word(image_board(image),logical_position(row,col)) : U32}
  {cell_value(Q.encode(image_board(image)),logical_position(row,col)) == cached_word(image_board(image),logical_position(row,col)) : U32}

law full_queue_encoded_blank_final_reads:
  for +image: BoardImage
  for +row: CellCoordinate
  for +col: CellCoordinate
  for count: {Nat.add(logical_offset(row,col),1n+logical_tail(row,col)) == 81n : Nat}
  for shapes: (Board128(encode_seeded_logical_prefix(row,col,image_board(image))) & Board128(encode_seeded_logical_prefix(row,col,image_board(image))))
  for safe: RoutedApart(flag_slot(logical_position(row,col)),logical_position(row,col))
  for after: EncodeApart(logical_tail(row,col),(logical_position(row,col) + 1 : U32),logical_position(row,col))
  for blank: {cell_value(encode_seeded_logical_prefix(row,col,image_board(image)),logical_position(row,col)) == 0 : U32}
  for cache: {cached_word(encode_seeded_logical_prefix(row,col,image_board(image)),logical_position(row,col)) ==
    cached_word(image_board(image),logical_position(row,col)) : U32}
  {cell_value(Q.encode(image_board(image)),logical_position(row,col)) == cached_word(image_board(image),logical_position(row,col)) : U32}

law full_queue_encoded_blank_with_routes:
  for +image: BoardImage
  for +row: CellCoordinate
  for +col: CellCoordinate
  for shapes: (Board128(image_board(image)) & Board128(image_board(image)) & Board128(image_board(image)) & Board128(image_board(image)))
  for counts: ({Nat.add(logical_offset(row,col),1n+logical_tail(row,col)) == 81n : Nat} &
    {Nat.add(logical_offset(row,col),1n+logical_tail(row,col)) == 81n : Nat} &
    {Nat.add(logical_offset(row,col),1n+logical_tail(row,col)) == 81n : Nat})
  for routes: WindowRoutes(logical_offset(row,col),logical_tail(row,col),logical_position(row,col),(logical_position(row,col) + 1 : U32))
  for blank: {cell_value(image_board(image),logical_position(row,col)) == 0 : U32}
  {cell_value(Q.encode(image_board(image)),logical_position(row,col)) == cached_word(image_board(image),logical_position(row,col)) : U32}

law full_queue_encoded_blank_with_window:
  for +image: BoardImage
  for +row: CellCoordinate
  for +col: CellCoordinate
  for shape: Board128(image_board(image))
  for blank: {cell_value(image_board(image),logical_position(row,col)) == 0 : U32}
  for window: VerifiedWindow(logical_offset(row,col),logical_tail(row,col))
  {cell_value(Q.encode(image_board(image)),logical_position(row,col)) == cached_word(image_board(image),logical_position(row,col)) : U32}

def EncodeBlankOriginalCache(-b: Array<U32>,+row: CellCoordinate,+col: CellCoordinate) -> Type:
  Board128(b) -> {cell_value(b,logical_position(row,col)) == 0 : U32} ->
  {cell_value(Q.encode(b),logical_position(row,col)) == cached_word(b,logical_position(row,col)) : U32}

law encoded_logical_blank_uses_original_cached_mask:
  for b: Array<U32>
  for +row: CellCoordinate
  for +col: CellCoordinate
  EncodeBlankOriginalCache(b,row,col)

law copy_shape_four_from_three:
  for -a: ArrayShape
  for -b: ArrayShape
  for eqs: ({a == b : ArrayShape} & {a == b : ArrayShape} & {a == b : ArrayShape})
  ({a == b : ArrayShape} & {a == b : ArrayShape} & {a == b : ArrayShape} & {a == b : ArrayShape})
