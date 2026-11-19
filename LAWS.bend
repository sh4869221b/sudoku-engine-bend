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
