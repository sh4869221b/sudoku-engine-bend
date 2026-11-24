import ./sudoku/generator.bend as G
import Base
import ./LAWS.bend as L
import ./sudoku/batch.bend as B
import ./sudoku/types.bend as T
import ./sudoku/board.bend as Board
import ./sudoku/arithmetic.bend as M
import ./sudoku/candidates.bend as C
import ./sudoku/parser.bend as P
import ./sudoku/commands.bend as Cmd
import ./sudoku/solver.bend as S
import ./sudoku/search.bend as Search
import ./sudoku/adaptivesearch.bend as Fast
import ./sudoku/validate.bend as V
import ./sudoku/queuedcandidates.bend as Q
import ./sudoku/counter.bend as K

def L.string_append_empty(text):
  match text:
    case SNil{}:
      {==}
    case SCon{h, tail}:
      %L.string_append_empty(tail) : {SCon{h, tail ++ ""} == SCon{h, _} : String}
      {==}

def L.string_append_assoc(a, b, c):
  match a:
    case SNil{}:
      {==}
    case SCon{h, tail}:
      %L.string_append_assoc(tail, b, c) : {SCon{h, (tail ++ b) ++ c} == SCon{h, _} : String}
      {==}

def L.batch_solve_tail(tree, tail):
  match tree:
    case B.JEmpty{}:
      {==}
    case B.JLeaf{job}:
      {==}
    case B.JFork{l, r}:
      %Equal.sym(String, (B.seq_solve(l) ++ B.seq_solve(r)) ++ tail, B.seq_solve(l) ++ (B.seq_solve(r) ++ tail), L.string_append_assoc(B.seq_solve(l), B.seq_solve(r), tail)) : {B.flatten(B.output_solve(l), B.flatten(B.output_solve(r), tail)) == _ : String}
      %L.batch_solve_tail(r, tail) : {B.flatten(B.output_solve(l), B.flatten(B.output_solve(r), tail)) == B.seq_solve(l) ++ _ : String}
      %L.batch_solve_tail(l, B.flatten(B.output_solve(r), tail)) : {B.flatten(B.output_solve(l), B.flatten(B.output_solve(r), tail)) == _ : String}
      {==}

def L.batch_solve_eq_seq(tree):
  %L.string_append_empty(B.seq_solve(tree)) : {B.batch_solve(tree) == _ : String}
  %L.batch_solve_tail(tree, "") : {B.batch_solve(tree) == _ : String}
  {==}

def L.batch_check_tail(tree, tail):
  match tree:
    case B.JEmpty{}:
      {==}
    case B.JLeaf{job}:
      {==}
    case B.JFork{l, r}:
      %Equal.sym(String, (B.seq_check(l) ++ B.seq_check(r)) ++ tail, B.seq_check(l) ++ (B.seq_check(r) ++ tail), L.string_append_assoc(B.seq_check(l), B.seq_check(r), tail)) : {B.flatten(B.output_check(l), B.flatten(B.output_check(r), tail)) == _ : String}
      %L.batch_check_tail(r, tail) : {B.flatten(B.output_check(l), B.flatten(B.output_check(r), tail)) == B.seq_check(l) ++ _ : String}
      %L.batch_check_tail(l, B.flatten(B.output_check(r), tail)) : {B.flatten(B.output_check(l), B.flatten(B.output_check(r), tail)) == _ : String}
      {==}

def L.batch_check_eq_seq(tree):
  %L.string_append_empty(B.seq_check(tree)) : {B.batch_check(tree) == _ : String}
  %L.batch_check_tail(tree, "") : {B.batch_check(tree) == _ : String}
  {==}

def L.batch_count_tail(tree, tail):
  match tree:
    case B.JEmpty{}:
      {==}
    case B.JLeaf{job}:
      {==}
    case B.JFork{l, r}:
      %Equal.sym(String, (B.seq_count(l) ++ B.seq_count(r)) ++ tail, B.seq_count(l) ++ (B.seq_count(r) ++ tail), L.string_append_assoc(B.seq_count(l), B.seq_count(r), tail)) : {B.flatten(B.output_count(l), B.flatten(B.output_count(r), tail)) == _ : String}
      %L.batch_count_tail(r, tail) : {B.flatten(B.output_count(l), B.flatten(B.output_count(r), tail)) == B.seq_count(l) ++ _ : String}
      %L.batch_count_tail(l, B.flatten(B.output_count(r), tail)) : {B.flatten(B.output_count(l), B.flatten(B.output_count(r), tail)) == _ : String}
      {==}

def L.batch_count_eq_seq(tree):
  %L.string_append_empty(B.seq_count(tree)) : {B.batch_count(tree) == _ : String}
  %L.batch_count_tail(tree, "") : {B.batch_count(tree) == _ : String}
  {==}

def L.batch_rate_tail(tree, tail):
  match tree:
    case B.JEmpty{}:
      {==}
    case B.JLeaf{job}:
      {==}
    case B.JFork{l, r}:
      %Equal.sym(String, (B.seq_rate(l) ++ B.seq_rate(r)) ++ tail, B.seq_rate(l) ++ (B.seq_rate(r) ++ tail), L.string_append_assoc(B.seq_rate(l), B.seq_rate(r), tail)) : {B.flatten(B.output_rate(l), B.flatten(B.output_rate(r), tail)) == _ : String}
      %L.batch_rate_tail(r, tail) : {B.flatten(B.output_rate(l), B.flatten(B.output_rate(r), tail)) == B.seq_rate(l) ++ _ : String}
      %L.batch_rate_tail(l, B.flatten(B.output_rate(r), tail)) : {B.flatten(B.output_rate(l), B.flatten(B.output_rate(r), tail)) == _ : String}
      {==}

def L.batch_rate_eq_seq(tree):
  %L.string_append_empty(B.seq_rate(tree)) : {B.batch_rate(tree) == _ : String}
  %L.batch_rate_tail(tree, "") : {B.batch_rate(tree) == _ : String}
  {==}

def L.count_many_absorb(count):
  match count:
    case T.CountZero{}:
      {==}
    case T.CountOne{}:
      {==}
    case T.CountMany{}:
      {==}
    case T.CountFuel{}:
      {==}

def L.subtract_twice(n, base, word, carry):
  match n:
    case 0n:
      match word:
        case WNil{}:
          {==}
    case 1n+k:
      match base word carry:
        case WCon{False{}, x} WCon{False{}, y} False{}:
          Equal.cong(Word(k), Word(1n+k), t => WCon{False{}, t}, Word.adc(k, x, Word.adc(k, x, y, True{}, False{}), True{}, False{}), y, L.subtract_twice(k, x, y, False{}))
        case WCon{False{}, x} WCon{False{}, y} True{}:
          Equal.cong(Word(k), Word(1n+k), t => WCon{False{}, t}, Word.adc(k, x, Word.adc(k, x, y, True{}, True{}), True{}, True{}), y, L.subtract_twice(k, x, y, True{}))
        case WCon{False{}, x} WCon{True{}, y} False{}:
          Equal.cong(Word(k), Word(1n+k), t => WCon{True{}, t}, Word.adc(k, x, Word.adc(k, x, y, True{}, False{}), True{}, False{}), y, L.subtract_twice(k, x, y, False{}))
        case WCon{False{}, x} WCon{True{}, y} True{}:
          Equal.cong(Word(k), Word(1n+k), t => WCon{True{}, t}, Word.adc(k, x, Word.adc(k, x, y, True{}, False{}), True{}, False{}), y, L.subtract_twice(k, x, y, False{}))
        case WCon{True{}, x} WCon{False{}, y} False{}:
          Equal.cong(Word(k), Word(1n+k), t => WCon{False{}, t}, Word.adc(k, x, Word.adc(k, x, y, True{}, True{}), True{}, True{}), y, L.subtract_twice(k, x, y, True{}))
        case WCon{True{}, x} WCon{False{}, y} True{}:
          Equal.cong(Word(k), Word(1n+k), t => WCon{False{}, t}, Word.adc(k, x, Word.adc(k, x, y, True{}, True{}), True{}, True{}), y, L.subtract_twice(k, x, y, True{}))
        case WCon{True{}, x} WCon{True{}, y} False{}:
          Equal.cong(Word(k), Word(1n+k), t => WCon{True{}, t}, Word.adc(k, x, Word.adc(k, x, y, True{}, False{}), True{}, False{}), y, L.subtract_twice(k, x, y, False{}))
        case WCon{True{}, x} WCon{True{}, y} True{}:
          Equal.cong(Word(k), Word(1n+k), t => WCon{True{}, t}, Word.adc(k, x, Word.adc(k, x, y, True{}, True{}), True{}, True{}), y, L.subtract_twice(k, x, y, True{}))

def word_of(u: U32) -> Word(32n):
  match u:
    case U32{bits}:
      bits

def L.mirror_involute(position):
  match position:
    case U32{bits}:
      +base = word_of(80)
      Equal.cong(Word(32n), U32, w => U32{w}, Word.sub(32n, base, Word.sub(32n, base, bits)), bits, L.subtract_twice(32n, base, bits, True{}))

def L.count_add_assoc(a, b, c):
  match a b c:
    case L.DZero{} L.DZero{} L.DZero{}:
      {==}
    case L.DZero{} L.DZero{} L.DOne{}:
      {==}
    case L.DZero{} L.DZero{} L.DMany{}:
      {==}
    case L.DZero{} L.DOne{} L.DZero{}:
      {==}
    case L.DZero{} L.DOne{} L.DOne{}:
      {==}
    case L.DZero{} L.DOne{} L.DMany{}:
      {==}
    case L.DZero{} L.DMany{} L.DZero{}:
      {==}
    case L.DZero{} L.DMany{} L.DOne{}:
      {==}
    case L.DZero{} L.DMany{} L.DMany{}:
      {==}
    case L.DOne{} L.DZero{} L.DZero{}:
      {==}
    case L.DOne{} L.DZero{} L.DOne{}:
      {==}
    case L.DOne{} L.DZero{} L.DMany{}:
      {==}
    case L.DOne{} L.DOne{} L.DZero{}:
      {==}
    case L.DOne{} L.DOne{} L.DOne{}:
      {==}
    case L.DOne{} L.DOne{} L.DMany{}:
      {==}
    case L.DOne{} L.DMany{} L.DZero{}:
      {==}
    case L.DOne{} L.DMany{} L.DOne{}:
      {==}
    case L.DOne{} L.DMany{} L.DMany{}:
      {==}
    case L.DMany{} L.DZero{} L.DZero{}:
      {==}
    case L.DMany{} L.DZero{} L.DOne{}:
      {==}
    case L.DMany{} L.DZero{} L.DMany{}:
      {==}
    case L.DMany{} L.DOne{} L.DZero{}:
      {==}
    case L.DMany{} L.DOne{} L.DOne{}:
      {==}
    case L.DMany{} L.DOne{} L.DMany{}:
      {==}
    case L.DMany{} L.DMany{} L.DZero{}:
      {==}
    case L.DMany{} L.DMany{} L.DOne{}:
      {==}
    case L.DMany{} L.DMany{} L.DMany{}:
      {==}

def L.count_add_spec(a, b):
  match a b:
    case T.CountZero{} T.CountZero{}:
      {==}
    case T.CountZero{} T.CountOne{}:
      {==}
    case T.CountZero{} T.CountMany{}:
      {==}
    case T.CountZero{} T.CountFuel{}:
      {==}
    case T.CountOne{} T.CountZero{}:
      {==}
    case T.CountOne{} T.CountOne{}:
      {==}
    case T.CountOne{} T.CountMany{}:
      {==}
    case T.CountOne{} T.CountFuel{}:
      {==}
    case T.CountMany{} T.CountZero{}:
      {==}
    case T.CountMany{} T.CountOne{}:
      {==}
    case T.CountMany{} T.CountMany{}:
      {==}
    case T.CountMany{} T.CountFuel{}:
      {==}
    case T.CountFuel{} T.CountZero{}:
      {==}
    case T.CountFuel{} T.CountOne{}:
      {==}
    case T.CountFuel{} T.CountMany{}:
      {==}
    case T.CountFuel{} T.CountFuel{}:
      {==}

def L.count_show_spec(count):
  match count:
    case T.CountZero{}:
      {==}
    case T.CountOne{}:
      {==}
    case T.CountMany{}:
      {==}
    case T.CountFuel{}:
      {==}

def L.show_digit_tail(short, digit, rest, tail):
  match short:
    case True{}:
      {==}
    case False{}:
      Equal.sym(String, (U32.show(digit) ++ rest) ++ tail, U32.show(digit) ++ (rest ++ tail), L.string_append_assoc(U32.show(digit), rest, tail))

def L.board_show_tail_go(n, index, cells, tail):
  match n:
    case 0n:
      {==}
    case 1n+k:
      (board, +digit) = cells
      +short = (digit <= 9 : U32)
      +next = (index + 1 : U32)
      %L.show_digit_tail(short, digit, Board.show_go(k, next, Array.get(U32, board, next)), tail) : {Board.show_digit(short, digit, Board.show_tail_go(k, next, Array.get(U32, board, next), tail)) == _ : String}
      %L.board_show_tail_go(k, next, Array.get(U32, board, next), tail) : {Board.show_digit(short, digit, Board.show_tail_go(k, next, Array.get(U32, board, next), tail)) == Board.show_digit(short, digit, _) : String}
      {==}

def L.board_show_tail(board, tail):
  L.board_show_tail_go(81n, 0, Array.get(U32, board, 0), tail)

def L.solved_tail(result, tail):
  match result:
    case T.Solved{board}:
      %L.string_append_assoc("solved:", Board.show(board), tail) : {"solved:" ++ Board.show_tail(board, tail) == _ : String}
      %L.board_show_tail(board, tail) : {"solved:" ++ Board.show_tail(board, tail) == "solved:" ++ _ : String}
      {==}
    case T.Unsolved{}:
      {==}
    case T.OutOfFuel{}:
      {==}

def L.unsolved_tail_text(tail):
  {==}

def L.out_of_fuel_tail_text(tail):
  {==}

def L.prepared_solve_tail(parsed, tail):
  match parsed:
    case P.ParseError{reason}:
      Equal.sym(String, ("error:" ++ reason) ++ tail, "error:" ++ (reason ++ tail), L.string_append_assoc("error:", reason, tail))
    case P.ParsedBoard{board}:
      L.solved_tail(S.solve_prepared(T.solve_fuel(), board), tail)

def L.batch_solve_leaf_tail(puzzle, tail):
  L.prepared_solve_tail(P.prepare81(puzzle), tail)

def L.solve_zero_fuel(board):
  {==}

def L.count_zero_fuel(board):
  {==}

def L.rate_zero_fuel(board):
  {==}

def L.mask_cmp_bit_le(bit, value, higher, le):
  match bit value higher:
    case _ _ GT{}:
      le
    case _ _ LT{}:
      {==}
    case False{} _ EQ{}:
      {==}
    case True{} False{} EQ{}:
      {==}
    case True{} True{} EQ{}:
      {==}

def L.mask_word_le(n, mask, value):
  match n:
    case 0n:
      {==}
    case 1n+k:
      match mask value:
        case WCon{bit, mt} WCon{v, vt}:
          L.mask_cmp_bit_le(bit, v, Word.cmp(k, Word.and(k, mt, vt), mt), L.mask_word_le(k, mt, vt))

def L.word_and_zero(n, value):
  match n:
    case 0n:
      {==}
    case 1n+k:
      match value:
        case WCon{False{}, rest}:
          Equal.cong(Word(k), Word(1n+k), t => WCon{False{}, t}, Word.and(k, rest, Word.zero(k)), Word.zero(k), L.word_and_zero(k, rest))
        case WCon{True{}, rest}:
          Equal.cong(Word(k), Word(1n+k), t => WCon{False{}, t}, Word.and(k, rest, Word.zero(k)), Word.zero(k), L.word_and_zero(k, rest))

def word_tail(w: Word(32n)) -> Word(31n):
  match w:
    case WCon{bit, rest}:
      rest

def L.candidate_low_bit(value):
  match value:
    case U32{WCon{bit, rest}}:
      +trimmed = Word.and(31n, word_tail(word_of(1022)), rest)
      Equal.cong(Word(31n), U32, t => U32{WCon{False{}, t}}, Word.and(31n, trimmed, Word.zero(31n)), Word.zero(31n), L.word_and_zero(31n, trimmed))

def L.candidate_trim_bounds(value):
  match value:
    case U32{bits}:
      +v = {U32{bits} : U32}
      %Equal.sym(U32, U32.and(U32.and(1022, v), 1), 0, L.candidate_low_bit(v)) : {U32.is_eq(_, 0) && (U32.and(1022, v) <= 1022 : U32) == True{} : Bool}
      L.mask_word_le(32n, word_of(1022), bits)

def L.candidate_invert_bounds(cells):
  (board, used) = cells
  L.candidate_trim_bounds(U32.not(used))

def L.candidate_at_bounds(board, position):
  L.candidate_invert_bounds(C.add_unit((18 + Board.box_of(position) : U32), C.add_unit((9 + M.rem9(position) : U32), C.unit_used(board, (M.div9(position) : U32)))))

def L.batch_job_line(mode, index, puzzle):
  match mode:
    case L.SolveMode{}:
      Equal.cong(String, String, out => U32.show(index) ++ " " ++ out, Cmd.batch_solve_tail(puzzle, "\n"), Cmd.only_out(Cmd.eval(1, True{}, T.solve_fuel(), T.rate_fuel(), puzzle)) ++ "\n", L.batch_solve_leaf_tail(puzzle, "\n"))
    case L.CheckMode{}:
      {==}
    case L.CountMode{}:
      {==}
    case L.RateMode{}:
      {==}

def L.legacy_rate_zero_fuel(board):
  {==}

def L.array_swap_left(x, y, n, i, v, w):
  (changed, old, size, (es, eg, en, eo)) = w
  (ANode{changed, y}, old, U32.shl(size), (
    Equal.cong(Array<U32> & U32, Array<U32> & U32, r => Array.swap.lo(U32, y, r), Array.swap.go(U32, x, U32.shr(n), i, v, U32.is_lt(i, U32.shr(U32.shr(n)))), (changed, old), es),
    Equal.cong(Array<U32> & U32, Array<U32> & U32, r => Array.swap.lo(U32, y, r), Array.get.go(U32, changed, U32.shr(n), i, U32.is_lt(i, U32.shr(U32.shr(n)))), (changed, v), eg),
    Equal.cong(Array<U32> & U32, Array<U32> & U32, r => Array.size.node(U32, y, r), Array.size(U32, changed), (changed, size), en),
    Equal.cong(Array<U32> & U32, Array<U32> & U32, r => Array.size.node(U32, y, r), Array.size(U32, x), (x, size), eo)))

def L.array_size_node(x, y, s):
  (same, size, (shape, sized)) = s
  (ANode{same, y}, U32.shl(size), (
    Equal.cong(Array<U32>, Array<U32>, l => ANode{l, y}, same, x, shape),
    Equal.cong(Array<U32> & U32, Array<U32> & U32, r => Array.size.node(U32, y, r), Array.size(U32, x), (same, size), sized)))

def L.array_size_witness(a):
  match a:
    case ALeaf{v}:
      (ALeaf{v}, 1, ({==}, {==}))
    case ANode{x, y}:
      L.array_size_node(x, y, L.array_size_witness(x))

def L.array_right_sizes(x, y, changed, n, e):
  %Equal.sym(Array<U32> & U32, Array.size(U32, x), (x, n), e) : ({Array.size.node(U32, changed, _) == (ANode{x, changed}, U32.shl(n)) : Array<U32> & U32}
    & {Array.size.node(U32, y, _) == (ANode{x, y}, U32.shl(n)) : Array<U32> & U32})
  ({==}, {==})

def L.array_swap_right_at(x, y, size, n, i, v, esize, w):
  (changed, old, ignored, (es, eg, en, eo)) = w
  +j = U32.sub(i, U32.shr(n))
  +z = U32.is_lt(j, U32.shr(U32.shr(n)))
  (ANode{x, changed}, old, U32.shl(size), (
    Equal.cong(Array<U32> & U32, Array<U32> & U32, r => Array.swap.hi(U32, x, r), Array.swap.go(U32, y, U32.shr(n), j, v, z), (changed, old), es),
    Equal.cong(Array<U32> & U32, Array<U32> & U32, r => Array.swap.hi(U32, x, r), Array.get.go(U32, changed, U32.shr(n), j, z), (changed, v), eg),
    L.array_right_sizes(x, y, changed, size, esize)))

def L.array_swap_right(x, y, n, i, v, sized, w):
  (same, size, (shape, eSize)) = sized
  finish : ({Array.size(U32, x) == (same, size) : Array<U32> & U32} -> L.ArrayWriteWitness(ANode{x, y}, n, i, v, False{})) = (
    %shape : ({Array.size(U32, _) == (same, size) : Array<U32> & U32} -> L.ArrayWriteWitness(ANode{_, y}, n, i, v, False{}))
    ee => L.array_swap_right_at(same, y, size, n, i, v, ee, w))
  finish(eSize)

def L.array_swap_witness(a, n, i, v, z):
  match a z:
    case ALeaf{old} _:
      (ALeaf{v}, old, 1, ({==}, {==}, {==}, {==}))
    case ANode{x, y} True{}:
      L.array_swap_left(x, y, n, i, v, L.array_swap_witness(x, U32.shr(n), i, v, U32.is_lt(i, U32.shr(U32.shr(n)))))
    case ANode{x, y} False{}:
      L.array_swap_right(x, y, n, i, v, L.array_size_witness(x), L.array_swap_witness(y, U32.shr(n), U32.sub(i, U32.shr(n)), v, U32.is_lt(U32.sub(i, U32.shr(n)), U32.shr(U32.shr(n)))))

def L.board_set_get_aligned(a, p, v, size, next, old, next_size, es, eg, en, e):
  %Equal.sym(Array<U32> & U32, Array.swap.at(U32, p, v, (a, size)), (next, old), es) : L.read_after_swap(p, v, _)
  %Equal.sym(Array<U32> & U32, Array.size(U32, next), (next, next_size), en) : {Pair.snd(Array<U32>, U32, Array.get.at(U32, p, _)) == v : U32}
  %Equal.cong(Array<U32> & U32, U32, r => Pair.snd(Array<U32>, U32, r), (a, size), (a, next_size), e) : {Pair.snd(Array<U32>, U32, Array.get.at(U32, p, (next, _))) == v : U32}
  Equal.cong(Array<U32> & U32, U32, r => Pair.snd(Array<U32>, U32, r), Array.get.at(U32, p, (next, size)), (next, v), eg)

def L.board_set_get_witness(a, p, v, size, e, w):
  (next, old, next_size, (es, eg, en, eo)) = w
  finish : ({Array.size(U32, a) == (a, next_size) : Array<U32> & U32} -> L.BoardSetGet(a, p, v)) = (
    %Equal.sym(Array<U32> & U32, Array.size(U32, a), (a, size), e) : (
      {_ == (a, next_size) : Array<U32> & U32} -> L.read_after_swap(p, v, Array.swap.at(U32, p, v, _)))
    eq => L.board_set_get_aligned(a, p, v, size, next, old, next_size, es, eg, en, eq))
  finish(eo)

def L.board_set_get_sized(a, p, v, sized):
  (same, +size, (shape, eSize)) = sized
  +j = U32.and(p, U32.sub(size, 1))
  +z = U32.is_lt(j, U32.shr(size))
  finish : ({Array.size(U32, a) == (same, size) : Array<U32> & U32} -> L.BoardSetGet(a, p, v)) = (
    %shape : ({Array.size(U32, _) == (same, size) : Array<U32> & U32} -> L.BoardSetGet(_, p, v))
    ee => L.board_set_get_witness(same, p, v, size, ee, L.array_swap_witness(same, size, j, v, z)))
  finish(eSize)

def L.board_set_get(a, p, v):
  L.board_set_get_sized(a, p, v, L.array_size_witness(a))

def L.cached_candidate_bounds(board, position):
  L.candidate_invert_bounds(C.cached_add((99 + Board.box_of(position) : U32), C.cached_add((90 + M.rem9(position) : U32), Array.get(U32, board, (81 + M.div9(position) : U32)))))

def L.row_candidate_bounds(board, column, boxbase, used):
  L.candidate_invert_bounds(C.cached_add((boxbase + M.div3(column) : U32), C.cached_add((90 + column : U32), (board, used))))

def L.array_read_left(x, y, n, i, w):
  (same, v, (shape, read)) = w
  (ANode{same, y}, v, (
    Equal.cong(Array<U32>, Array<U32>, t => ANode{t, y}, same, x, shape),
    Equal.cong(Array<U32> & U32, Array<U32> & U32, r => Array.swap.lo(U32, y, r), Array.get.go(U32, x, U32.shr(n), i, U32.is_lt(i, U32.shr(U32.shr(n)))), (same, v), read)))

def L.array_read_right(x, y, n, i, w):
  (same, v, (shape, read)) = w
  +j = U32.sub(i, U32.shr(n))
  (ANode{x, same}, v, (
    Equal.cong(Array<U32>, Array<U32>, t => ANode{x, t}, same, y, shape),
    Equal.cong(Array<U32> & U32, Array<U32> & U32, r => Array.swap.hi(U32, x, r), Array.get.go(U32, y, U32.shr(n), j, U32.is_lt(j, U32.shr(U32.shr(n)))), (same, v), read)))

def L.array_get_witness(a, n, i, z):
  match a z:
    case ALeaf{+v} _:
      (ALeaf{v}, v, ({==}, {==}))
    case ANode{x, y} True{}:
      L.array_read_left(x, y, n, i, L.array_get_witness(x, U32.shr(n), i, U32.is_lt(i, U32.shr(U32.shr(n)))))
    case ANode{x, y} False{}:
      +j = U32.sub(i, U32.shr(n))
      L.array_read_right(x, y, n, i, L.array_get_witness(y, U32.shr(n), j, U32.is_lt(j, U32.shr(U32.shr(n)))))

def L.array_read_projection(a, n, i, z, w):
  (same, value, (shape, read)) = w
  Equal.trans(Array<U32>, Pair.fst(Array<U32>, U32, Array.get.go(U32, a, n, i, z)), same, a,
    Equal.cong(Array<U32> & U32, Array<U32>, r => Pair.fst(Array<U32>, U32, r), Array.get.go(U32, a, n, i, z), (same, value), read), shape)

def L.array_get_at_preserves(a, n, i):
  +j = U32.and(i, U32.sub(n, 1))
  +left = U32.is_lt(j, U32.shr(n))
  L.array_read_projection(a, n, j, left, L.array_get_witness(a, n, j, left))

def L.array_get_preserves_sized(a, i, s):
  (same, +size, (shape, sized)) = s
  Equal.trans(Array<U32>, Pair.fst(Array<U32>, U32, Board.get_cell(a, i)), Pair.fst(Array<U32>, U32, Array.get.at(U32, i, (same, size))), a,
    Equal.cong(Array<U32> & U32, Array<U32>, r => Pair.fst(Array<U32>, U32, Array.get.at(U32, i, r)), Array.size(U32, a), (same, size), sized),
    Equal.trans(Array<U32>, Pair.fst(Array<U32>, U32, Array.get.at(U32, i, (same, size))), same, a, L.array_get_at_preserves(same, size, i), shape))

def L.board_get_preserves(a, i):
  L.array_get_preserves_sized(a, i, L.array_size_witness(a))

def L.solve_prepared_zero_fuel(board):
  {==}

def L.count_prepared_zero_fuel(board):
  {==}

def L.search_terminal_done(fuel, limit, found, board):
  match fuel:
    case 0n:
      {==}
    case 1n+k:
      {==}

def L.search_terminal_fuel(fuel, limit):
  match fuel:
    case 0n:
      {==}
    case 1n+k:
      {==}

def L.adaptive_terminal_done(fuel, limit, found, board):
  match fuel:
    case 0n:
      {==}
    case 1n+k:
      {==}

def L.adaptive_terminal_fuel(fuel, limit):
  match fuel:
    case 0n:
      {==}
    case 1n+k:
      {==}

def L.adaptive_restore_empty(pos, remaining, frames, depth, found, active):
  {==}

def L.solve_finish_zero(board):
  {==}

def L.solve_finish_one(board):
  {==}

def L.solve_finish_fuel():
  {==}

def L.parser_bad_length_precedes_character(ok, board):
  match ok:
    case True{}:
      {==}
    case False{}:
      {==}

def L.prepared_bad_length_precedes_character(ok, start, pair):
  match ok:
    case True{}:
      {==}
    case False{}:
      {==}

def L.prepared_bad_character(start, pair):
  {==}

def L.validation_retains_prior(unit, prior, board, ok):
  {==}

def L.validation_first_reason(unit, board):
  {==}

def L.validation_no_reason_if_valid(unit, board):
  {==}

def L.row_indices_0():
  {==}

def L.row_indices_1():
  {==}

def L.row_indices_2():
  {==}

def L.row_indices_3():
  {==}

def L.row_indices_4():
  {==}

def L.row_indices_5():
  {==}

def L.row_indices_6():
  {==}

def L.row_indices_7():
  {==}

def L.row_indices_8():
  {==}

def L.col_indices_0():
  {==}

def L.col_indices_1():
  {==}

def L.col_indices_2():
  {==}

def L.col_indices_3():
  {==}

def L.col_indices_4():
  {==}

def L.col_indices_5():
  {==}

def L.col_indices_6():
  {==}

def L.col_indices_7():
  {==}

def L.col_indices_8():
  {==}

def L.box_indices_0():
  {==}

def L.box_indices_1():
  {==}

def L.box_indices_2():
  {==}

def L.box_indices_3():
  {==}

def L.box_indices_4():
  {==}

def L.box_indices_5():
  {==}

def L.box_indices_6():
  {==}

def L.box_indices_7():
  {==}

def L.box_indices_8():
  {==}

def L.board_read_sized_result(board, same, size, pos, shape, sized, read):
  (after, value, (read_shape, read_value)) = read
  (after, value, (
    Equal.trans(Array<U32>, after, same, board, read_shape, shape),
    Equal.trans(Array<U32> & U32, Board.get_cell(board, pos), Array.get.at(U32, pos, (same, size)), (after, value),
      Equal.cong(Array<U32> & U32, Array<U32> & U32, r => Array.get.at(U32, pos, r), Array.size(U32, board), (same, size), sized),
      read_value)))

def L.board_read_sized(board, pos, s):
  (same, +size, (shape, sized)) = s
  +j = U32.and(pos, U32.sub(size, 1))
  L.board_read_sized_result(board, same, size, pos, shape, sized, L.array_get_witness(same, size, j, U32.is_lt(j, U32.shr(size))))

def L.board_read_witness(board, pos):
  L.board_read_sized(board, pos, L.array_size_witness(board))

def L.validation_unit_join(n, unit, j, board, d, used, ok, next_board, next_d, shape, read, rest):
  (same, +verdict, (unchanged, final)) = rest
  (same, verdict, (
    Equal.trans(Array<U32>, same, next_board, board, unchanged, shape),
    Equal.trans(Array<U32> & Bool,
      V.unit_go(2n+n, unit, j, (board, d), used, ok),
      V.unit_go(1n+n, unit, (j + 1 : U32), (next_board, next_d), U32.or(used, Board.bit(d)), ok && (d <= 9 : U32) && (U32.is_eq(d, 0) || U32.is_eq(U32.and(used, Board.bit(d)), 0))),
      (same, verdict),
      Equal.cong(Array<U32> & U32, Array<U32> & Bool,
        r => V.unit_go(1n+n, unit, (j + 1 : U32), r, U32.or(used, Board.bit(d)), ok && (d <= 9 : U32) && (U32.is_eq(d, 0) || U32.is_eq(U32.and(used, Board.bit(d)), 0))),
        Board.get_cell(board, Board.unit_pos(unit, (j + 1 : U32))), (next_board, next_d), read),
      final)))

def L.validation_unit_step(n, unit, j, board, d, used, ok, read, visit):
  (next_board, next_d, (shape, read_value)) = read
  L.validation_unit_join(n, unit, j, board, d, used, ok, next_board, next_d, shape, read_value, visit((next_board, next_d)))

def L.validation_unit_witness(n, unit, j, input, used, ok):
  match n:
    case 0n:
      (board, +d) = input
      (board, ok, ({==}, {==}))
    case 1n:
      (board, +d) = input
      +bit = Board.bit(d)
      (board, ok && (d <= 9 : U32) && (U32.is_eq(d, 0) || U32.is_eq(U32.and(used, bit), 0)), ({==}, {==}))
    case 2n+k:
      (board, +d) = input
      +next = (j + 1 : U32)
      +bit = Board.bit(d)
      L.validation_unit_step(k, unit, j, board, d, used, ok, L.board_read_witness(board, Board.unit_pos(unit, next)),
        r => L.validation_unit_witness(1n+k, unit, next, r, U32.or(used, bit), ok && (d <= 9 : U32) && (U32.is_eq(d, 0) || U32.is_eq(U32.and(used, bit), 0))))

def L.validation_unit_preserves_from_witness(n, unit, j, input, used, ok, w):
  (same, verdict, (shape, actual)) = w
  Equal.trans(Array<U32>, Pair.fst(Array<U32>, Bool, V.unit_go(n, unit, j, input, used, ok)), same, Pair.fst(Array<U32>, U32, input),
    Equal.cong(Array<U32> & Bool, Array<U32>, r => Pair.fst(Array<U32>, Bool, r), V.unit_go(n, unit, j, input, used, ok), (same, verdict), actual), shape)

def L.validation_unit_preserves(n, unit, j, input, used, ok):
  L.validation_unit_preserves_from_witness(n, unit, j, input, used, ok, L.validation_unit_witness(n, unit, j, input, used, ok))

def L.validation_unit_rejection_sticky(n, unit, j, input, used):
  match n:
    case 0n:
      (board, digit) = input
      {==}
    case 1n:
      (board, digit) = input
      {==}
    case 2n+k:
      (board, digit) = input
      +next = (j + 1 : U32)
      L.validation_unit_rejection_sticky(1n+k, unit, next, Board.get_cell(board, Board.unit_pos(unit, next)), U32.or(used, Board.bit(digit)))

def L.complete_rejection_sticky(n, i, input):
  match n:
    case 0n:
      {==}
    case 1n+k:
      (board, digit) = input
      +next = (i + 1 : U32)
      L.complete_rejection_sticky(k, next, Board.get_cell(board, next))

def L.parse_single_over_capacity(head, tail, i, board, good):
  {==}

def L.prepared_scan_over_capacity(head, tail, good, first, pair):
  {==}

def L.validation_reason_spec(unit, prior, board, ok):
  match prior ok:
    case SNil{} True{}:
      {==}
    case SNil{} False{}:
      {==}
    case SCon{h, t} _:
      {==}

def L.validation_continue(n, unit, board, prior, next_board, reason, shape, step, rest):
  (same, final_reason, (unchanged, final)) = rest
  (same, final_reason, (
    Equal.trans(Array<U32>, same, next_board, board, unchanged, shape),
    Equal.trans(Array<U32> & String,
      V.go(1n+n, unit, (board, prior)),
      V.go(n, (unit + 1 : U32), (next_board, reason)),
      (same, final_reason),
      Equal.cong(Array<U32> & String, Array<U32> & String,
        r => V.go(n, (unit + 1 : U32), r),
        V.next_reason(unit, prior, V.unit_go(9n, unit, 0, Board.get_cell(board, Board.unit_pos(unit, 0)), 0, True{})),
        (next_board, reason), step), final)))

def L.validation_continue_with_unit(n, unit, board, prior, read_board, digit, same, read, unit_result, visit):
  (next_board, +ok, (unit_same, unit_actual)) = unit_result
  +reason = L.next_reason_spec(prior, unit, ok)
  L.validation_continue(n, unit, board, prior, next_board, reason,
    Equal.trans(Array<U32>, next_board, read_board, board, unit_same, same),
    Equal.trans(Array<U32> & String,
      V.next_reason(unit, prior, V.unit_go(9n, unit, 0, Board.get_cell(board, Board.unit_pos(unit, 0)), 0, True{})),
      V.next_reason(unit, prior, V.unit_go(9n, unit, 0, (read_board, digit), 0, True{})),
      (next_board, reason),
      Equal.cong(Array<U32> & U32, Array<U32> & String,
        r => V.next_reason(unit, prior, V.unit_go(9n, unit, 0, r, 0, True{})),
        Board.get_cell(board, Board.unit_pos(unit, 0)), (read_board, digit), read),
      Equal.trans(Array<U32> & String,
        V.next_reason(unit, prior, V.unit_go(9n, unit, 0, (read_board, digit), 0, True{})),
        V.next_reason(unit, prior, (next_board, ok)),
        (next_board, reason),
        Equal.cong(Array<U32> & Bool, Array<U32> & String,
          r => V.next_reason(unit, prior, r),
          V.unit_go(9n, unit, 0, (read_board, digit), 0, True{}), (next_board, ok), unit_actual),
        L.validation_reason_spec(unit, prior, next_board, ok))),
    visit((next_board, reason)))

def L.validation_read_unit(n, unit, board, prior, read, visit):
  (read_board, digit, (shape, actual)) = read
  L.validation_continue_with_unit(n, unit, board, prior, read_board, digit, shape, actual,
    L.validation_unit_witness(9n, unit, 0, (read_board, digit), 0, True{}), visit)

def L.validation_go_witness(n, unit, input):
  match n:
    case 0n:
      (board, reason) = input
      (board, reason, ({==}, {==}))
    case 1n+k:
      (board, +prior) = input
      L.validation_read_unit(k, unit, board, prior, L.board_read_witness(board, Board.unit_pos(unit, 0)),
        r => L.validation_go_witness(k, (unit + 1 : U32), r))

def L.validation_preserves_from_witness(board, w):
  (same, reason, (shape, actual)) = w
  Equal.trans(Array<U32>, Pair.fst(Array<U32>, String, V.validate(board)), same, board,
    Equal.cong(Array<U32> & String, Array<U32>, r => Pair.fst(Array<U32>, String, r), V.validate(board), (same, reason), actual), shape)

def L.validation_preserves_board(board):
  L.validation_preserves_from_witness(board, L.validation_go_witness(27n, 0, (board, "")))

def L.word_compare_reflexive(n, w):
  match n:
    case 0n:
      {==}
    case 1n+k:
      match w:
        case WCon{True{}, t}:
          Equal.cong(Cmp, Cmp, x => Word.cmp.fin(True{}, True{}, x), Word.cmp(k, t, t), EQ{}, L.word_compare_reflexive(k, t))
        case WCon{False{}, t}:
          Equal.cong(Cmp, Cmp, x => Word.cmp.fin(False{}, False{}, x), Word.cmp(k, t, t), EQ{}, L.word_compare_reflexive(k, t))

def L.u32_compare_reflexive(p):
  match p:
    case U32{bits}:
      L.word_compare_reflexive(32n, bits)

def L.peers_never_self(p):
  Equal.cong(Cmp, Bool,
    cmp => Bool.not(Cmp.is_eq(cmp)) && (U32.is_eq((M.div9(p) : U32), (M.div9(p) : U32)) || U32.is_eq((M.rem9(p) : U32), (M.rem9(p) : U32)) || U32.is_eq(Board.box_of(p), Board.box_of(p))),
    U32.cmp(p, p), EQ{}, L.u32_compare_reflexive(p))

def L.mask_counts_0000():
  {==}

def L.mask_counts_0032():
  {==}

def L.mask_counts_0064():
  {==}

def L.mask_counts_0096():
  {==}

def L.mask_counts_0128():
  {==}

def L.mask_counts_0160():
  {==}

def L.mask_counts_0192():
  {==}

def L.mask_counts_0224():
  {==}

def L.mask_counts_0256():
  {==}

def L.mask_counts_0288():
  {==}

def L.mask_counts_0320():
  {==}

def L.mask_counts_0352():
  {==}

def L.mask_counts_0384():
  {==}

def L.mask_counts_0416():
  {==}

def L.mask_counts_0448():
  {==}

def L.mask_counts_0480():
  {==}

def L.mask_counts_0512():
  {==}

def L.mask_counts_0544():
  {==}

def L.mask_counts_0576():
  {==}

def L.mask_counts_0608():
  {==}

def L.mask_counts_0640():
  {==}

def L.mask_counts_0672():
  {==}

def L.mask_counts_0704():
  {==}

def L.mask_counts_0736():
  {==}

def L.mask_counts_0768():
  {==}

def L.mask_counts_0800():
  {==}

def L.mask_counts_0832():
  {==}

def L.mask_counts_0864():
  {==}

def L.mask_counts_0896():
  {==}

def L.mask_counts_0928():
  {==}

def L.mask_counts_0960():
  {==}

def L.mask_counts_0992():
  {==}

def L.mask_lists_0000():
  {==}

def L.mask_lists_0032():
  {==}

def L.mask_lists_0064():
  {==}

def L.mask_lists_0096():
  {==}

def L.mask_lists_0128():
  {==}

def L.mask_lists_0160():
  {==}

def L.mask_lists_0192():
  {==}

def L.mask_lists_0224():
  {==}

def L.mask_lists_0256():
  {==}

def L.mask_lists_0288():
  {==}

def L.mask_lists_0320():
  {==}

def L.mask_lists_0352():
  {==}

def L.mask_lists_0384():
  {==}

def L.mask_lists_0416():
  {==}

def L.mask_lists_0448():
  {==}

def L.mask_lists_0480():
  {==}

def L.mask_lists_0512():
  {==}

def L.mask_lists_0544():
  {==}

def L.mask_lists_0576():
  {==}

def L.mask_lists_0608():
  {==}

def L.mask_lists_0640():
  {==}

def L.mask_lists_0672():
  {==}

def L.mask_lists_0704():
  {==}

def L.mask_lists_0736():
  {==}

def L.mask_lists_0768():
  {==}

def L.mask_lists_0800():
  {==}

def L.mask_lists_0832():
  {==}

def L.mask_lists_0864():
  {==}

def L.mask_lists_0896():
  {==}

def L.mask_lists_0928():
  {==}

def L.mask_lists_0960():
  {==}

def L.mask_lists_0992():
  {==}

def L.fixed_word_roundtrip():
  {==}

def L.decode_cell_written(board, pos, word):
  L.board_set_get(board, pos, U32.shrn(word, 10n))

def L.decode_zero_steps(pos, board):
  {==}


def L.word_and_repeat(n, mask, word):
  match n:
    case 0n:
      {==}
    case 1n+k:
      match mask word:
        case WCon{False{}, mt} WCon{False{}, wt}:
          Equal.cong(Word(k), Word(1n+k), t => WCon{False{}, t}, Word.and(k, Word.and(k, wt, mt), mt), Word.and(k, wt, mt), L.word_and_repeat(k, mt, wt))
        case WCon{True{}, mt} WCon{False{}, wt}:
          Equal.cong(Word(k), Word(1n+k), t => WCon{False{}, t}, Word.and(k, Word.and(k, wt, mt), mt), Word.and(k, wt, mt), L.word_and_repeat(k, mt, wt))
        case WCon{False{}, mt} WCon{True{}, wt}:
          Equal.cong(Word(k), Word(1n+k), t => WCon{False{}, t}, Word.and(k, Word.and(k, wt, mt), mt), Word.and(k, wt, mt), L.word_and_repeat(k, mt, wt))
        case WCon{True{}, mt} WCon{True{}, wt}:
          Equal.cong(Word(k), Word(1n+k), t => WCon{True{}, t}, Word.and(k, Word.and(k, wt, mt), mt), Word.and(k, wt, mt), L.word_and_repeat(k, mt, wt))

def L.mask_digits_normalize(mask):
  match mask:
    case U32{word}:
      Equal.cong(Word(32n), List<&2, U32>, t => C.digits_bits(9n, U32{t}), Word.and(32n, Word.and(32n, word, word_of(1022)), word_of(1022)), Word.and(32n, word, word_of(1022)), L.word_and_repeat(32n, word_of(1022), word))

def L.mask_count_normalize(mask):
  match mask:
    case U32{word}:
      Equal.cong(Word(32n), U32, t => C.count_index(U32{t}), Word.and(32n, Word.and(32n, word, word_of(1023)), word_of(1023)), Word.and(32n, word, word_of(1023)), L.word_and_repeat(32n, word_of(1023), word))

def L.encode_fixed_cell_1(board, pos):
  L.board_set_get(board, pos, 1024)

def L.encode_fixed_cell_2(board, pos):
  L.board_set_get(board, pos, 2048)

def L.encode_fixed_cell_3(board, pos):
  L.board_set_get(board, pos, 3072)

def L.encode_fixed_cell_4(board, pos):
  L.board_set_get(board, pos, 4096)

def L.encode_fixed_cell_5(board, pos):
  L.board_set_get(board, pos, 5120)

def L.encode_fixed_cell_6(board, pos):
  L.board_set_get(board, pos, 6144)

def L.encode_fixed_cell_7(board, pos):
  L.board_set_get(board, pos, 7168)

def L.encode_fixed_cell_8(board, pos):
  L.board_set_get(board, pos, 8192)

def L.encode_fixed_cell_9(board, pos):
  L.board_set_get(board, pos, 9216)

def L.word_zero_and(n, word):
  match n:
    case 0n:
      {==}
    case 1n+k:
      match word:
        case WCon{bit, rest}:
          Equal.cong(Word(k), Word(1n+k), t => WCon{False{}, t}, Word.and(k, Word.zero(k), rest), Word.zero(k), L.word_zero_and(k, rest))

def L.candidate_word_decodes_blank(word):
  match word:
    case U32{WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WCon{b8, WCon{b9, rest}}}}}}}}}}}:
      Equal.cong(Word(22n), U32, t => U32{Word.shr.pad(31n, Word.shr.pad(30n, Word.shr.pad(29n, Word.shr.pad(28n, Word.shr.pad(27n, Word.shr.pad(26n, Word.shr.pad(25n, Word.shr.pad(24n, Word.shr.pad(23n, Word.shr.pad(22n, t))))))))))}, Word.and(22n, Word.zero(22n), rest), Word.zero(22n), L.word_zero_and(22n, rest))

def L.inverted_candidate_decodes_blank(cells):
  (board, used) = cells
  L.candidate_word_decodes_blank(U32.not(used))

def L.urgent_flag_positions():
  {==}

def L.queued_occupied_not_a_candidate(board, pos, prior_pos, prior_mask, prior_size, word):
  {==}

def L.queued_urgent_zero(board, pos):
  {==}

def L.adaptive_alternative_exhausted(pos, frames, depth, found, snapshots, active, board):
  {==}

def L.adaptive_empty_alternatives_restore_snapshot(pos, frames, depth, found, saved, snapshots, active):
  {==}

def L.cross_left_read_projection(before, after, read_result):
  (same, data) = read_result
  {==}

def L.cross_left_write_result(written, read_tree, n, j, write_result):
  (next, old) = write_result
  +i = U32.sub(j, U32.shr(n))
  L.cross_left_read_projection(written, next, Array.get.go(U32, read_tree, U32.shr(n), i, U32.is_lt(i, U32.shr(U32.shr(n)))))

def L.array_write_left_preserves_other(written, read_tree, n, i, j, value):
  +p = i
  L.cross_left_write_result(written, read_tree, n, j, Array.swap.go(U32, written, U32.shr(n), p, value, U32.is_lt(p, U32.shr(U32.shr(n)))))

def L.cross_right_read_projection(before, after, read_result):
  (same, data) = read_result
  {==}

def L.cross_right_write_result(written, read_tree, n, j, write_result):
  (next, old) = write_result
  +i = j
  L.cross_right_read_projection(written, next, Array.get.go(U32, read_tree, U32.shr(n), i, U32.is_lt(i, U32.shr(U32.shr(n)))))

def L.array_write_right_preserves_other(written, read_tree, n, i, j, value):
  +p = U32.sub(i, U32.shr(n))
  L.cross_right_write_result(written, read_tree, n, j, Array.swap.go(U32, written, U32.shr(n), p, value, U32.is_lt(p, U32.shr(U32.shr(n)))))

def L.array_clone_join(left, right, ea, eb):
  Equal.trans(Array<U32> & Array<U32>,
    Array.clone.node(U32, Array.clone(U32, left), Array.clone(U32, right)),
    Array.clone.node(U32, (left, left), Array.clone(U32, right)),
    (ANode{left, right}, ANode{left, right}),
    Equal.cong(Array<U32> & Array<U32>, Array<U32> & Array<U32>,
      pair => Array.clone.node(U32, pair, Array.clone(U32, right)),
      Array.clone(U32, left), (left, left), ea),
    Equal.cong(Array<U32> & Array<U32>, Array<U32> & Array<U32>,
      pair => Array.clone.node(U32, (left, left), pair),
      Array.clone(U32, right), (right, right), eb))

def L.array_clone_exact(a):
  match a:
    case ALeaf{x}:
      {==}
    case ANode{l, r}:
      L.array_clone_join(l, r, L.array_clone_exact(l), L.array_clone_exact(r))

def L.adaptive_guess_saves_activated_board(pos, digit, remaining, frames, depth, found, snapshots, active, board):
  Equal.cong(Array<U32> & Array<U32>, Fast.State,
    pair => Fast.guessed(pos, digit, remaining, frames, depth, found, snapshots, active, pair),
    Array.clone(U32, Fast.activated(active, board)),
    (Fast.activated(active, board), Fast.activated(active, board)),
    L.array_clone_exact(Fast.activated(active, board)))

def L.separate_descend_left(child, other, n, i, j, value, descent):
  (next, +old, +seen, (write, before, after)) = descent
  +wi = i
  +ri = j
  +wz = U32.is_lt(wi, U32.shr(U32.shr(n)))
  +rz = U32.is_lt(ri, U32.shr(U32.shr(n)))
  (ANode{next, other}, old, seen, (
    Equal.cong(Array<U32> & U32, Array<U32> & U32, p => Array.swap.lo(U32, other, p),
      Array.swap.go(U32, child, U32.shr(n), wi, value, wz), (next, old), write),
    Equal.cong(Array<U32> & U32, Array<U32> & U32, p => Array.swap.lo(U32, other, p),
      Array.get.go(U32, child, U32.shr(n), ri, rz), (child, seen), before),
    Equal.cong(Array<U32> & U32, Array<U32> & U32, p => Array.swap.lo(U32, other, p),
      Array.get.go(U32, next, U32.shr(n), ri, rz), (next, seen), after)))

def L.separate_observations_left(child, next, other, half, j, z, seen, read):
  %Equal.sym(Array<U32> & U32, Array.get.go(U32, other, half, j, z), (other, seen), read) :
    ({Array.swap.hi(U32, child, _) == (ANode{child, other}, seen) : Array<U32> & U32} & {Array.swap.hi(U32, next, _) == (ANode{next, other}, seen) : Array<U32> & U32})
  ({==}, {==})

def L.separate_at_left_shape(child, other, n, i, j, value, seen, written, read):
  (next, +old, cap, (eq, unused_read, after_size, before_size)) = written
  +wi = i
  +ri = U32.sub(j, U32.shr(n))
  +wz = U32.is_lt(wi, U32.shr(U32.shr(n)))
  +rz = U32.is_lt(ri, U32.shr(U32.shr(n)))
  # Both observations only traverse the other subtree.
  (ANode{next, other}, old, seen, (
    Equal.cong(Array<U32> & U32, Array<U32> & U32, p => Array.swap.lo(U32, other, p),
      Array.swap.go(U32, child, U32.shr(n), wi, value, wz), (next, old), eq),
    L.separate_observations_left(child, next, other, U32.shr(n), ri, rz, seen, read)))

def L.separate_at_left(child, other, n, i, j, value, written, observed):
  (same, +seen, (shape, read)) = observed
  +ri = U32.sub(j, U32.shr(n))
  +rz = U32.is_lt(ri, U32.shr(U32.shr(n)))
  finish : ({Array.get.go(U32, other, U32.shr(n), ri, rz) == (same, seen) : Array<U32> & U32} -> L.SeparateRead(ANode{child, other}, n, i, j, value, True{}, False{})) = (
    %shape : ({Array.get.go(U32, _, U32.shr(n), ri, rz) == (same, seen) : Array<U32> & U32} -> L.SeparateRead(ANode{child, _}, n, i, j, value, True{}, False{}))
    premise => L.separate_at_left_shape(child, same, n, i, j, value, seen, written, premise))
  finish(read)


def L.separate_descend_right(child, other, n, i, j, value, descent):
  (next, +old, +seen, (write, before, after)) = descent
  +wi = U32.sub(i, U32.shr(n))
  +ri = U32.sub(j, U32.shr(n))
  +wz = U32.is_lt(wi, U32.shr(U32.shr(n)))
  +rz = U32.is_lt(ri, U32.shr(U32.shr(n)))
  (ANode{other, next}, old, seen, (
    Equal.cong(Array<U32> & U32, Array<U32> & U32, p => Array.swap.hi(U32, other, p),
      Array.swap.go(U32, child, U32.shr(n), wi, value, wz), (next, old), write),
    Equal.cong(Array<U32> & U32, Array<U32> & U32, p => Array.swap.hi(U32, other, p),
      Array.get.go(U32, child, U32.shr(n), ri, rz), (child, seen), before),
    Equal.cong(Array<U32> & U32, Array<U32> & U32, p => Array.swap.hi(U32, other, p),
      Array.get.go(U32, next, U32.shr(n), ri, rz), (next, seen), after)))

def L.separate_observations_right(child, next, other, half, j, z, seen, read):
  %Equal.sym(Array<U32> & U32, Array.get.go(U32, other, half, j, z), (other, seen), read) :
    ({Array.swap.lo(U32, child, _) == (ANode{other, child}, seen) : Array<U32> & U32} & {Array.swap.lo(U32, next, _) == (ANode{other, next}, seen) : Array<U32> & U32})
  ({==}, {==})

def L.separate_at_right_shape(child, other, n, i, j, value, seen, written, read):
  (next, +old, cap, (eq, unused_read, after_size, before_size)) = written
  +wi = U32.sub(i, U32.shr(n))
  +ri = j
  +wz = U32.is_lt(wi, U32.shr(U32.shr(n)))
  +rz = U32.is_lt(ri, U32.shr(U32.shr(n)))
  # Both observations only traverse the other subtree.
  (ANode{other, next}, old, seen, (
    Equal.cong(Array<U32> & U32, Array<U32> & U32, p => Array.swap.hi(U32, other, p),
      Array.swap.go(U32, child, U32.shr(n), wi, value, wz), (next, old), eq),
    L.separate_observations_right(child, next, other, U32.shr(n), ri, rz, seen, read)))

def L.separate_at_right(child, other, n, i, j, value, written, observed):
  (same, +seen, (shape, read)) = observed
  +ri = j
  +rz = U32.is_lt(ri, U32.shr(U32.shr(n)))
  finish : ({Array.get.go(U32, other, U32.shr(n), ri, rz) == (same, seen) : Array<U32> & U32} -> L.SeparateRead(ANode{other, child}, n, i, j, value, False{}, True{})) = (
    %shape : ({Array.get.go(U32, _, U32.shr(n), ri, rz) == (same, seen) : Array<U32> & U32} -> L.SeparateRead(ANode{_, child}, n, i, j, value, False{}, True{}))
    premise => L.separate_at_right_shape(child, same, n, i, j, value, seen, written, premise))
  finish(read)


def L.separate_read_projection(tree, n, i, j, value, wz, rz, proof):
  (next, +old, +seen, (write, before, after)) = proof
  %Equal.sym(Array<U32> & U32, Array.swap.go(U32, tree, n, i, value, wz), (next, old), write) : {Pair.snd(Array<U32>, U32, Array.get.go(U32, Array.set.fin(U32, _), n, j, rz)) == Pair.snd(Array<U32>, U32, Array.get.go(U32, tree, n, j, rz)) : U32}
  %Equal.sym(Array<U32> & U32, Array.get.go(U32, next, n, j, rz), (next, seen), after) : {Pair.snd(Array<U32>, U32, _) == Pair.snd(Array<U32>, U32, Array.get.go(U32, tree, n, j, rz)) : U32}
  %Equal.sym(Array<U32> & U32, Array.get.go(U32, tree, n, j, rz), (tree, seen), before) : {seen == Pair.snd(Array<U32>, U32, _) : U32}
  {==}

def L.false_is_not_true(e):
  %Equal.sym(Bool, False{}, True{}, e) : L.TrueOnly(_)
  Unit{}

def L.array_swap_preserves_separate_read(tree, n, i, j, value, wz, rz, distinct):
  match tree wz rz:
    case ALeaf{x} _ _:
      Empty.absurd(L.SeparateRead(ALeaf{x}, n, i, j, value, wz, rz), L.false_is_not_true(distinct))
    case ANode{left, right} True{} False{}:
      +h = U32.shr(n)
      +k = U32.shr(h)
      +r = U32.sub(j, h)
      L.separate_at_left(left, right, n, i, j, value,
        L.array_swap_witness(left, h, i, value, U32.is_lt(i, k)),
        L.array_get_witness(right, h, r, U32.is_lt(r, k)))
    case ANode{left, right} False{} True{}:
      +h = U32.shr(n)
      +k = U32.shr(h)
      +w = U32.sub(i, h)
      L.separate_at_right(right, left, n, i, j, value,
        L.array_swap_witness(right, h, w, value, U32.is_lt(w, k)),
        L.array_get_witness(left, h, j, U32.is_lt(j, k)))
    case ANode{left, right} True{} True{}:
      +h = U32.shr(n)
      +k = U32.shr(h)
      L.separate_descend_left(left, right, n, i, j, value,
        L.array_swap_preserves_separate_read(left, h, i, j, value, U32.is_lt(i, k), U32.is_lt(j, k), distinct))
    case ANode{left, right} False{} False{}:
      +h = U32.shr(n)
      +k = U32.shr(h)
      +w = U32.sub(i, h)
      +r = U32.sub(j, h)
      L.separate_descend_right(right, left, n, i, j, value,
        L.array_swap_preserves_separate_read(right, h, w, r, value, U32.is_lt(w, k), U32.is_lt(r, k), distinct))

def L.capacity_aligned(a, n, i, v, next, old, cap, write, after, eq):
  %Equal.sym(Array<U32> & U32, Array.swap.at(U32, i, v, (a, n)), (next, old), write) : {Pair.snd(Array<U32>, U32, Array.size(U32, Array.set.fin(U32, _))) == n : U32}
  %Equal.sym(Array<U32> & U32, Array.size(U32, next), (next, cap), after) : {Pair.snd(Array<U32>, U32, _) == n : U32}
  Equal.cong(Array<U32> & U32, U32, p => Pair.snd(Array<U32>, U32, p), (a, cap), (a, n), eq)

def L.capacity_from_write_witness(a, n, i, v, size, w):
  (next, +old, +cap, (write, read, after, before)) = w
  finish : ({Array.size(U32, a) == (a, cap) : Array<U32> & U32} -> L.SameCapacity(a, i, v)) = (
    %Equal.sym(Array<U32> & U32, Array.size(U32, a), (a, n), size) :
      ({_ == (a, cap) : Array<U32> & U32} -> {Pair.snd(Array<U32>, U32, Array.size(U32, Array.set.fin(U32, Array.swap.at(U32, i, v, _)))) == Pair.snd(Array<U32>, U32, _) : U32})
    eq => L.capacity_aligned(a, n, i, v, next, old, cap, write, after,
      Equal.sym(Array<U32> & U32, (a, n), (a, cap), eq)))
  finish(before)

def L.capacity_from_size_witness(a, i, v, size):
  (same, +n, (shape, measured)) = size
  +j = U32.and(i, U32.sub(n, 1))
  finish : ({Array.size(U32, a) == (same, n) : Array<U32> & U32} -> L.SameCapacity(a, i, v)) = (
    %shape : ({Array.size(U32, _) == (same, n) : Array<U32> & U32} -> L.SameCapacity(_, i, v))
    eq => L.capacity_from_write_witness(same, n, i, v, eq, L.array_swap_witness(same, n, j, v, U32.is_lt(j, U32.shr(n)))))
  finish(measured)

def L.board_set_keeps_capacity(a, i, v):
  L.capacity_from_size_witness(a, i, v, L.array_size_witness(a))

def L.board_isolation_aligned(a, n, p, q, v, before, after, observed):
  %Equal.sym(Array<U32> & U32, Array.size(U32, Board.set_cell(a, p, v)), (Board.set_cell(a, p, v), n), after) :
    {Pair.snd(Array<U32>, U32, Array.get.at(U32, q, _)) == Pair.snd(Array<U32>, U32, Board.get_cell(a, q)) : U32}
  %Equal.sym(Array<U32> & U32, Array.size(U32, a), (a, n), before) :
    {Pair.snd(Array<U32>, U32, Array.get.go(U32, Array.set.fin(U32, Array.swap.at(U32, p, v, _)), n, U32.and(q, U32.sub(n, 1)), U32.is_lt(U32.and(q, U32.sub(n, 1)), U32.shr(n)))) == Pair.snd(Array<U32>, U32, Array.get.at(U32, q, _)) : U32}
  observed

def L.board_write_preserves_separate_read(a, n, p, q, v, before, after, disjoint):
  +wi = U32.and(p, U32.sub(n, 1))
  +ri = U32.and(q, U32.sub(n, 1))
  +wz = U32.is_lt(wi, U32.shr(n))
  +rz = U32.is_lt(ri, U32.shr(n))
  L.board_isolation_aligned(a, n, p, q, v, before, after,
    L.separate_read_projection(a, n, wi, ri, v, wz, rz,
      L.array_swap_preserves_separate_read(a, n, wi, ri, v, wz, rz, disjoint)))

def L.raw_128_aliases_zero(value):
  {==}

def L.queued_flag_slot_is_padding():
  {==}

def L.queued_flagged_keeps_separate_cell(a, pos, read_pos, present, old, n, before, after, separate):
  L.board_write_preserves_separate_read(a, n, L.flag_slot(pos), read_pos, L.flag_word(pos, present, old), before, after, separate)

def L.candidate_at_decodes_blank(board, pos):
  L.inverted_candidate_decodes_blank(C.add_unit((18 + Board.box_of(pos) : U32), C.add_unit((9 + M.rem9(pos) : U32), C.unit_used(board, (M.div9(pos) : U32)))))

def L.cached_at_decodes_blank(board, pos):
  L.inverted_candidate_decodes_blank(C.cached_add((99 + Board.box_of(pos) : U32), C.cached_add((90 + M.rem9(pos) : U32), Array.get(U32, board, (81 + M.div9(pos) : U32)))))

def L.irregular_board_size():
  {==}

def L.irregular_board_alias(value):
  {==}

def L.irregular_board_does_not_separate():
  {==}

def L.shape_write_left(x, y, n, i, v, w):
  (next, +old, (written, same)) = w
  (ANode{next,y}, old, (
    Equal.cong(Array<U32> & U32, Array<U32> & U32, r => Array.swap.lo(U32, y, r),
      Array.swap.go(U32, x, U32.shr(n), i, v, U32.is_lt(i, U32.shr(U32.shr(n)))), (next,old), written),
    Equal.cong(L.ArrayShape, L.ArrayShape, t => L.ShapeNode{t,L.array_shape(y)}, L.array_shape(next), L.array_shape(x), same)))

def L.shape_write_right(x, y, n, i, v, w):
  (next, +old, (written, same)) = w
  +j = U32.sub(i, U32.shr(n))
  (ANode{x,next}, old, (
    Equal.cong(Array<U32> & U32, Array<U32> & U32, r => Array.swap.hi(U32, x, r),
      Array.swap.go(U32, y, U32.shr(n), j, v, U32.is_lt(j, U32.shr(U32.shr(n)))), (next,old), written),
    Equal.cong(L.ArrayShape, L.ArrayShape, t => L.ShapeNode{L.array_shape(x),t}, L.array_shape(next), L.array_shape(y), same)))

def L.shape_write_witness(a,n,i,v,z):
  match a z:
    case ALeaf{x} _:
      (ALeaf{v}, x, ({==},{==}))
    case ANode{x,y} True{}:
      L.shape_write_left(x,y,n,i,v,L.shape_write_witness(x,U32.shr(n),i,v,U32.is_lt(i,U32.shr(U32.shr(n)))))
    case ANode{x,y} False{}:
      +j = U32.sub(i,U32.shr(n))
      L.shape_write_right(x,y,n,i,v,L.shape_write_witness(y,U32.shr(n),j,v,U32.is_lt(j,U32.shr(U32.shr(n)))))

def L.shape_aligned(a,n,i,v,w):
  (next, +old, (written, same)) = w
  %Equal.sym(Array<U32> & U32, Array.swap.at(U32,i,v,(a,n)), (next,old), written) :
    {L.array_shape(Array.set.fin(U32,_)) == L.array_shape(a) : L.ArrayShape}
  same

def L.shape_from_size(a,i,v,s):
  (same, +n, (shape, measured)) = s
  +j = U32.and(i,U32.sub(n,1))
  finish : ({Array.size(U32, a) == (same,n) : Array<U32> & U32} -> L.SameShape(a,i,v)) = (
    %shape : ({Array.size(U32, _) == (same,n) : Array<U32> & U32} -> L.SameShape(_,i,v))
    eq =>
      %Equal.sym(Array<U32> & U32, Array.size(U32,same), (same,n), eq) :
        {L.array_shape(Array.set.fin(U32,Array.swap.at(U32,i,v,_))) == L.array_shape(same) : L.ArrayShape}
      L.shape_aligned(same,n,i,v,L.shape_write_witness(same,n,j,v,U32.is_lt(j,U32.shr(n)))))
  finish(measured)

def L.board_set_keeps_shape(a,i,v):
  L.shape_from_size(a,i,v,L.array_size_witness(a))

def L.empty_board_depth_seven():
  {==}

def L.board_set_keeps_perfect(a,i,v,height,perfect):
  Equal.trans(L.ArrayShape,L.array_shape(Board.set_cell(a,i,v)),L.array_shape(a),L.perfect_shape(height),L.board_set_keeps_shape(a,i,v),perfect)

def L.routes_depend_on_shape(tree,n,i,j,wz,rz):
  match tree wz rz:
    case ALeaf{v} _ _:
      {==}
    case ANode{left,right} True{} False{}:
      {==}
    case ANode{left,right} False{} True{}:
      {==}
    case ANode{left,right} True{} True{}:
      +h = U32.shr(n)
      L.routes_depend_on_shape(left,h,i,j,U32.is_lt(i,U32.shr(h)),U32.is_lt(j,U32.shr(h)))
    case ANode{left,right} False{} False{}:
      +h = U32.shr(n)
      +wi = U32.sub(i,h)
      +ri = U32.sub(j,h)
      L.routes_depend_on_shape(right,h,wi,ri,U32.is_lt(wi,U32.shr(h)),U32.is_lt(ri,U32.shr(h)))

def L.routes_from_perfect_shape(tree,n,i,j,wz,rz,height,perfect):
  Equal.trans(Bool,
    L.routes_separate(tree,n,i,j,wz,rz), L.shape_routes(L.array_shape(tree),n,i,j,wz,rz),
    L.shape_routes(L.perfect_shape(height),n,i,j,wz,rz),
    L.routes_depend_on_shape(tree,n,i,j,wz,rz),
    Equal.cong(L.ArrayShape,Bool,s => L.shape_routes(s,n,i,j,wz,rz),L.array_shape(tree),L.perfect_shape(height),perfect))

def L.logical_metadata_routes_00():
  {==}

def L.logical_metadata_routes_09():
  {==}

def L.logical_metadata_routes_18():
  {==}

def L.logical_metadata_routes_27():
  {==}

def L.logical_metadata_routes_36():
  {==}

def L.logical_metadata_routes_45():
  {==}

def L.logical_metadata_routes_54():
  {==}

def L.logical_metadata_routes_63():
  {==}

def L.logical_metadata_routes_72():
  {==}

def L.logical_routes_00():
  {==}

def L.logical_routes_09():
  {==}

def L.logical_routes_18():
  {==}

def L.logical_routes_27():
  {==}

def L.logical_routes_36():
  {==}

def L.logical_routes_45():
  {==}

def L.logical_routes_54():
  {==}

def L.logical_routes_63():
  {==}

def L.logical_routes_72():
  {==}

def L.shape_measure_lift(x,y,measured):
  Equal.cong(Array<U32> & U32,Array<U32> & U32,t => Array.size.node(U32,y,t),
    Array.size(U32,x),(x,L.shape_capacity(L.array_shape(x))),measured)

def L.array_size_follows_shape(a):
  match a:
    case ALeaf{v}:
      {==}
    case ANode{x,y}:
      L.shape_measure_lift(x,y,L.array_size_follows_shape(x))

def L.perfect_board_has_128_slots(a,perfect):
  Equal.trans(Array<U32> & U32,Array.size(U32,a),(a,L.shape_capacity(L.array_shape(a))),(a,128),
    L.array_size_follows_shape(a),
    Equal.cong(L.ArrayShape,Array<U32> & U32,s => (a,L.shape_capacity(s)),L.array_shape(a),L.perfect_shape(7n),perfect))

def L.set_shape_write_aligned(a,n,i,v,actual,witness):
  (next, +old, (written, same)) = witness
  (next, (
    Equal.trans(Array<U32>, Board.set_cell(a,i,v), Array.set.fin(U32,Array.swap.at(U32,i,v,(a,n))), next,
      Equal.cong(Array<U32> & U32, Array<U32>, p => Array.set.fin(U32,Array.swap.at(U32,i,v,p)), Array.size(U32,a), (a,n), actual),
      Equal.cong(Array<U32> & U32, Array<U32>, p => Array.set.fin(U32,p), Array.swap.at(U32,i,v,(a,n)), (next,old), written)),
    same))

def L.set_shape_write_sized(a,i,v,s):
  (same,+n,(shape,measured)) = s
  +j = U32.and(i,U32.sub(n,1))
  finish : ({Array.size(U32,a) == (same,n) : Array<U32> & U32} -> L.PublicShapeWrite(a,i,v)) = (
    %shape : ({Array.size(U32,_) == (same,n) : Array<U32> & U32} -> L.PublicShapeWrite(_,i,v))
    eq => L.set_shape_write_aligned(same,n,i,v,eq,L.shape_write_witness(same,n,j,v,U32.is_lt(j,U32.shr(n)))))
  finish(measured)

def L.set_shape_write(a,i,v):
  L.set_shape_write_sized(a,i,v,L.array_size_witness(a))

def L.decode_shape_join(n,pos,board,read_board,word,next,unchanged,rd,write,next_shape,later):
  %Equal.sym(Array<U32> & U32,Array.get(U32,board,pos),(read_board,word),rd) :
    {L.array_shape(Q.decode(n,(pos + 1 : U32),Q.decoded(pos,_))) == L.array_shape(board) : L.ArrayShape}
  %Equal.sym(Array<U32>,Board.set_cell(read_board,pos,U32.shrn(word,10n)),next,write) :
    {L.array_shape(Q.decode(n,(pos + 1 : U32),_)) == L.array_shape(board) : L.ArrayShape}
  Equal.trans(L.ArrayShape,L.array_shape(Q.decode(n,(pos + 1 : U32),next)),L.array_shape(next),L.array_shape(board),later,
    Equal.trans(L.ArrayShape,L.array_shape(next),L.array_shape(read_board),L.array_shape(board),next_shape,
      Equal.cong(Array<U32>,L.ArrayShape,b => L.array_shape(b),read_board,board,unchanged)))

def L.decode_shape_written(n,pos,board,read_board,word,unchanged,read,w,prove):
  (next,(write,shape)) = w
  L.decode_shape_join(n,pos,board,read_board,word,next,unchanged,read,write,shape,prove(next))

def L.decode_shape_read(n,pos,board,rd,prove):
  (read_board,+word,(unchanged,read)) = rd
  L.decode_shape_written(n,pos,board,read_board,word,unchanged,read,L.set_shape_write(read_board,pos,U32.shrn(word,10n)),prove)

def L.queued_decode_preserves_shape(n,pos,board):
  match n:
    case 0n:
      {==}
    case 1n+k:
      L.decode_shape_read(k,pos,board,L.board_read_witness(board,pos), b => L.queued_decode_preserves_shape(k,(pos + 1 : U32),b))

def L.cached_merge_observed(board,expr,used,r):
  (same,+value,(shape,read)) = r
  (same,U32.or(used,value),(shape,
    Equal.cong(Array<U32> & U32,Array<U32> & U32,p => C.cached_merge(used,p),expr,(same,value),read)))

def L.cached_add_observed_step(board,expr,read_board,pos,used,out,kept,r):
  (same,+value,(shape,read)) = r
  (same,value,(
    Equal.trans(Array<U32>,same,read_board,board,shape,kept),
    Equal.trans(Array<U32> & U32,C.cached_add(pos,expr),C.cached_merge(used,Array.get(U32,read_board,pos)),(same,value),
      Equal.cong(Array<U32> & U32,Array<U32> & U32,p => C.cached_add(pos,p),expr,(read_board,used),out),read)))

def L.cached_add_observed(board,expr,pos,r):
  (same,+used,(shape,read)) = r
  L.cached_add_observed_step(board,expr,same,pos,used,read,shape,
    L.cached_merge_observed(same,Array.get(U32,same,pos),used,L.board_read_witness(same,pos)))

def L.invert_observed(board,expr,r):
  (same,+value,(shape,read)) = r
  (same,U32.and(1022,U32.not(value)),(shape,
    Equal.cong(Array<U32> & U32,Array<U32> & U32,p => C.invert(p),expr,(same,value),read)))

def L.cached_at_observed(board,pos):
  +row = (81 + M.div9(pos) : U32)
  +col = (90 + M.rem9(pos) : U32)
  +box = (99 + Board.box_of(pos) : U32)
  L.invert_observed(board,C.cached_add(box,C.cached_add(col,Array.get(U32,board,row))),
    L.cached_add_observed(board,C.cached_add(col,Array.get(U32,board,row)),box,
      L.cached_add_observed(board,Array.get(U32,board,row),col,L.board_read_witness(board,row))))

def L.shape_transition_compose_finish(a,b,x,f,ex,es,step):
  (end,(result,shape)) = step
  (end,(
    Equal.trans(Array<U32>,f(x),f(b),end,Equal.cong(Array<U32>,Array<U32>,f,x,b,ex),result),
    Equal.trans(L.ArrayShape,L.array_shape(end),L.array_shape(b),L.array_shape(a),shape,es)))

def L.shape_transition_compose(a,x,f,first,next):
  (b,(step,same)) = first
  L.shape_transition_compose_finish(a,b,x,f,step,same,next(b))

def L.flag_from_observed(board,pos,present,same,old,unchanged,read,step):
  (end,(write,shape)) = step
  (end,(
    Equal.trans(Array<U32>,Q.flag(board,pos,present),Q.flagged(pos,present,(same,old)),end,
      Equal.cong(Array<U32> & U32,Array<U32>,p => Q.flagged(pos,present,p),Board.get_cell(board,L.flag_slot(pos)),(same,old),read),
      write),
    Equal.trans(L.ArrayShape,L.array_shape(end),L.array_shape(same),L.array_shape(board),shape,
      Equal.cong(Array<U32>,L.ArrayShape,b => L.array_shape(b),same,board,unchanged))))

def L.flag_shape_read(board,pos,present,read):
  (same,+old,(unchanged,actual)) = read
  L.flag_from_observed(board,pos,present,same,old,unchanged,actual,
    L.set_shape_write(same,L.flag_slot(pos),L.flag_word(pos,present,old)))

def L.flag_shape(board,pos,present):
  L.flag_shape_read(board,pos,present,L.board_read_witness(board,L.flag_slot(pos)))

def L.encoded_mask_shape(pos,cells):
  (b,+mask) = cells
  +urgent = Q.zero_or_single(mask)
  L.shape_transition_compose(b,Board.set_cell(b,pos,mask),a => Q.flag(a,pos,urgent),
    L.set_shape_write(b,pos,mask),a => L.flag_shape(a,pos,urgent))

def L.encoded_blank_shape_observed(board,pos,obs):
  (same,+mask,(shape,read)) = obs
  %Equal.sym(Array<U32> & U32,C.cached_at(board,pos),(same,mask),read) :
    L.ShapeTransition(board,Q.encoded_mask(pos,_))
  %shape : L.ShapeTransition(_,Q.encoded_mask(pos,(same,mask)))
  L.encoded_mask_shape(pos,(same,mask))

def L.encoded_digit_shape(board,pos,digit):
  match digit:
    case U32{WCon{True{}, rest}}:
      L.set_shape_write(board,pos,U32.shln(U32{WCon{True{}, rest}},10n))
    case U32{WCon{False{}, WCon{True{}, rest}}}:
      L.set_shape_write(board,pos,U32.shln(U32{WCon{False{}, WCon{True{}, rest}}},10n))
    case U32{WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}:
      L.set_shape_write(board,pos,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{True{}, rest}}}},10n))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}:
      L.set_shape_write(board,pos,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}},10n))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}:
      L.set_shape_write(board,pos,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}},10n))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}:
      L.set_shape_write(board,pos,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}},10n))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}:
      L.set_shape_write(board,pos,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}},10n))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}:
      L.set_shape_write(board,pos,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}},10n))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}:
      L.set_shape_write(board,pos,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}},10n))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}:
      L.set_shape_write(board,pos,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}},10n))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}:
      L.set_shape_write(board,pos,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}},10n))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}:
      L.set_shape_write(board,pos,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}},10n))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}:
      L.set_shape_write(board,pos,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}},10n))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}:
      L.set_shape_write(board,pos,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}},10n))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}:
      L.set_shape_write(board,pos,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}},10n))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}:
      L.set_shape_write(board,pos,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}},10n))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}:
      L.set_shape_write(board,pos,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}},10n))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}:
      L.set_shape_write(board,pos,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}},10n))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}:
      L.set_shape_write(board,pos,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}},10n))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}:
      L.set_shape_write(board,pos,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}},10n))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}:
      L.set_shape_write(board,pos,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}},10n))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}:
      L.set_shape_write(board,pos,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}},10n))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}:
      L.set_shape_write(board,pos,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}},10n))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.set_shape_write(board,pos,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}},10n))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.set_shape_write(board,pos,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}},10n))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.set_shape_write(board,pos,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}},10n))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.set_shape_write(board,pos,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}},10n))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.set_shape_write(board,pos,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}},10n))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.set_shape_write(board,pos,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}},10n))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.set_shape_write(board,pos,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}},10n))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.set_shape_write(board,pos,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}},10n))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.set_shape_write(board,pos,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}},10n))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.encoded_blank_shape_observed(board,pos,L.cached_at_observed(board,pos))

def L.encoded_shape(pos,cells):
  (board,+digit) = cells
  L.encoded_digit_shape(board,pos,digit)

def L.encode_go_shape_step(n,pos,board,same,digit,shape,rd,result):
  %Equal.sym(Array<U32> & U32,Array.get(U32,board,pos),(same,digit),rd) :
    L.ShapeTransition(board,Q.encode_go(n,(pos + 1 : U32),Q.encoded(pos,_)))
  %shape : L.ShapeTransition(_,Q.encode_go(n,(pos + 1 : U32),Q.encoded(pos,(same,digit))))
  result

def L.encode_go_shape_read(n,pos,board,obs,recurse):
  (same,+digit,(shape,read)) = obs
  L.encode_go_shape_step(n,pos,board,same,digit,shape,read,
    L.shape_transition_compose(same,Q.encoded(pos,(same,digit)),x => Q.encode_go(n,(pos + 1 : U32),x),
      L.encoded_shape(pos,(same,digit)),recurse))

def L.encode_loop_shape(n,pos,board):
  match n:
    case 0n:
      (board,({==},{==}))
    case 1n+k:
      L.encode_go_shape_read(k,pos,board,L.board_read_witness(board,pos),x => L.encode_loop_shape(k,(pos + 1 : U32),x))

def L.queue_seed_shape(board):
  L.shape_transition_compose(board,Board.set_cell(Board.set_cell(board,109,0),110,0),a => Board.set_cell(a,111,0),
    L.shape_transition_compose(board,Board.set_cell(board,109,0),a => Board.set_cell(a,110,0),
      L.set_shape_write(board,109,0),a => L.set_shape_write(a,110,0)),
    a => L.set_shape_write(a,111,0))

def L.encoded_full_shape_witness(board):
  L.shape_transition_compose(board,Board.set_cell(Board.set_cell(Board.set_cell(board,109,0),110,0),111,0),
    a => Q.encode_go(81n,0,a),L.queue_seed_shape(board),a => L.encode_loop_shape(81n,0,a))

def L.project_shape_transition(board,result,proof):
  (next,(same,shape)) = proof
  %Equal.sym(Array<U32>,result,next,same) : {L.array_shape(_) == L.array_shape(board) : L.ArrayShape}
  shape

def L.queued_encode_preserves_shape(board):
  L.project_shape_transition(board,Q.encode(board),L.encoded_full_shape_witness(board))

def L.copy_shape_proof(a,b,eq):
  %eq : ({a == _ : L.ArrayShape} & {a == _ : L.ArrayShape})
  ({==},{==})

def L.copy_shape_three(a,b,eq):
  %eq : ({a == _ : L.ArrayShape} & {a == _ : L.ArrayShape} & {a == _ : L.ArrayShape})
  ({==},({==},{==}))

def L.reify_board_join(left,right,e0,e1):
  (+a,ea) = e0
  (+b,eb) = e1
  (L.ImageNode{a,b},
    Equal.trans(Array<U32>,ANode{L.image_board(a),L.image_board(b)},ANode{left,L.image_board(b)},ANode{left,right},
      Equal.cong(Array<U32>,Array<U32>,x => ANode{x,L.image_board(b)},L.image_board(a),left,ea),
      Equal.cong(Array<U32>,Array<U32>,x => ANode{left,x},L.image_board(b),right,eb)))

def L.reify_board(board):
  match board:
    case ALeaf{+value}:
      (L.ImageLeaf{value},{==})
    case ANode{left,right}:
      L.reify_board_join(left,right,L.reify_board(left),L.reify_board(right))

def L.on_reified_board(board,P,witness,prove):
  (+image,eq) = witness
  %eq : P(_)
  prove(image)

def L.perfect_write_keeps_cell_from(image,written,watched,value,shapes,apart):
  (s0,(s1,s2)) = shapes
  +i = L.normalized_route(written)
  +j = L.normalized_route(watched)
  new = Board.set_cell(L.image_board(image),written,value)
  L.board_write_preserves_separate_read(L.image_board(image),128,written,watched,value,
    L.perfect_board_has_128_slots(L.image_board(image),s0),
    L.perfect_board_has_128_slots(new,L.board_set_keeps_perfect(L.image_board(image),written,value,7n,s1)),
    Equal.trans(Bool,
      L.routes_separate(L.image_board(image),128,i,j,(i < 64 : U32),(j < 64 : U32)),
      L.regular_routes(i,j),True{},
      L.routes_from_perfect_shape(L.image_board(image),128,i,j,(i < 64 : U32),(j < 64 : U32),7n,s2),
      apart))

def L.perfect_write_keeps_cell(board,written,watched,value,shape,apart):
  proof : (L.Board128(board) -> L.RoutedApart(written,watched) ->
    {L.cell_value(Board.set_cell(board,written,value),watched) == L.cell_value(board,watched) : U32}) =
    L.on_reified_board(board,
      b => (L.Board128(b) -> L.RoutedApart(written,watched) ->
        {L.cell_value(Board.set_cell(b,written,value),watched) == L.cell_value(b,watched) : U32}),
      L.reify_board(board),
      image => s => sep => L.perfect_write_keeps_cell_from(image,written,watched,value,
        L.copy_shape_three(L.array_shape(L.image_board(image)),L.perfect_shape(7n),s),sep))
  proof(shape,apart)

def L.observed_word(board,pos,same,word,observed):
  Equal.cong(Array<U32> & U32,U32,p => Pair.snd(Array<U32>,U32,p),
    Array.get(U32,board,pos),(same,word),observed)

def L.decode_step_update(board,pos,same,word,untouched,observed):
  %Equal.sym(Array<U32> & U32,Array.get(U32,board,pos),(same,word),observed) :
    {Q.decoded(pos,_) == Board.set_cell(board,pos,U32.shrn(Pair.snd(Array<U32>,U32,_),10n)) : Array<U32>}
  %Equal.sym(Array<U32>,same,board,untouched) :
    {Board.set_cell(_,pos,U32.shrn(word,10n)) == Board.set_cell(board,pos,U32.shrn(word,10n)) : Array<U32>}
  {==}

def L.decode_step_normalized(board,pos,read):
  (same,+word,(untouched,observed)) = read
  L.decode_step_update(board,pos,same,word,untouched,observed)

def L.decode_step_keeps_cell_image(image,pos,watched,shape,apart):
  %Equal.sym(Array<U32>,Q.decoded(pos,Array.get(U32,L.image_board(image),pos)),Board.set_cell(L.image_board(image),pos,U32.shrn(L.cell_value(L.image_board(image),pos),10n)),L.decode_step_normalized(L.image_board(image),pos,L.board_read_witness(L.image_board(image),pos))) :
    {L.cell_value(_,watched) == L.cell_value(L.image_board(image),watched) : U32}
  L.perfect_write_keeps_cell(L.image_board(image),pos,watched,U32.shrn(L.cell_value(L.image_board(image),pos),10n),shape,apart)

def L.decode_step_keeps_cell(board,pos,watched,shape,apart):
  proof : (L.Board128(board) -> L.RoutedApart(pos,watched) -> {L.cell_value(Q.decoded(pos,Array.get(U32,board,pos)),watched) == L.cell_value(board,watched) : U32}) =
    L.on_reified_board(board, b => (L.Board128(b) -> L.RoutedApart(pos,watched) -> {L.cell_value(Q.decoded(pos,Array.get(U32,b,pos)),watched) == L.cell_value(b,watched) : U32}),
      L.reify_board(board), image => L.decode_step_keeps_cell_image(image, pos, watched))
  proof(shape, apart)

def L.decode_step_reads_cell_image(image,pos):
  %Equal.sym(Array<U32>,Q.decoded(pos,Array.get(U32,L.image_board(image),pos)),Board.set_cell(L.image_board(image),pos,U32.shrn(L.cell_value(L.image_board(image),pos),10n)),L.decode_step_normalized(L.image_board(image),pos,L.board_read_witness(L.image_board(image),pos))) :
    {L.cell_value(_,pos) == U32.shrn(L.cell_value(L.image_board(image),pos),10n) : U32}
  L.board_set_get(L.image_board(image),pos,U32.shrn(L.cell_value(L.image_board(image),pos),10n))

def L.decode_step_reads_cell(board,pos):
  L.on_reified_board(board, b => ({L.cell_value(Q.decoded(pos,Array.get(U32,b,pos)),pos) == U32.shrn(L.cell_value(b,pos),10n) : U32}),
    L.reify_board(board), image => L.decode_step_reads_cell_image(image, pos))

def L.decode_step_keeps_perfect_image(image,pos,shape):
  %Equal.sym(Array<U32>,Q.decoded(pos,Array.get(U32,L.image_board(image),pos)),Board.set_cell(L.image_board(image),pos,U32.shrn(L.cell_value(L.image_board(image),pos),10n)),L.decode_step_normalized(L.image_board(image),pos,L.board_read_witness(L.image_board(image),pos))) : L.Board128(_)
  L.board_set_keeps_perfect(L.image_board(image),pos,U32.shrn(L.cell_value(L.image_board(image),pos),10n),7n,shape)

def L.decode_step_keeps_perfect(board,pos,shape):
  proof : (L.Board128(board) -> L.Board128(Q.decoded(pos,Array.get(U32,board,pos)))) =
    L.on_reified_board(board, b => (L.Board128(b) -> L.Board128(Q.decoded(pos,Array.get(U32,b,pos)))),
      L.reify_board(board), image => L.decode_step_keeps_perfect_image(image, pos))
  proof(shape)

def L.decode_sweep_keep_step_image(n,pos,image,watched,shapes,head,tail,recurse):
  (s0,s1) = shapes
  next = Q.decoded(pos,Array.get(U32,L.image_board(image),pos))
  +p = (pos + 1 : U32)
  Equal.trans(U32,L.cell_value(Q.decode(n,p,next),watched),L.cell_value(next,watched),L.cell_value(L.image_board(image),watched),
    recurse(next,L.decode_step_keeps_perfect(L.image_board(image),pos,s0),tail),
    L.decode_step_keeps_cell(L.image_board(image),pos,watched,s1,head))

def L.decode_sweep_keep_step(n,pos,board,watched,shapes,head,tail,recurse):
  proof : ((L.Board128(board) & L.Board128(board)) -> L.RoutedApart(pos,watched) -> L.DecodeApart(n,(pos + 1 : U32),watched) -> L.DecodeTailProof(n,(pos + 1 : U32),watched) -> {L.cell_value(Q.decode(1n+n,pos,board),watched) == L.cell_value(board,watched) : U32}) =
    L.on_reified_board(board, b => ((L.Board128(b) & L.Board128(b)) -> L.RoutedApart(pos,watched) -> L.DecodeApart(n,(pos + 1 : U32),watched) -> L.DecodeTailProof(n,(pos + 1 : U32),watched) -> {L.cell_value(Q.decode(1n+n,pos,b),watched) == L.cell_value(b,watched) : U32}),
      L.reify_board(board), image => L.decode_sweep_keep_step_image(n, pos, image, watched))
  proof(shapes, head, tail, recurse)

def L.decode_sweep_keeps_apart(n,pos,board,watched,shape,apart):
  match n:
    case 0n:
      {==}
    case 1n+k:
      (head,tail) = apart
      L.decode_sweep_keep_step(k,pos,board,watched,
        L.copy_shape_proof(L.array_shape(board),L.perfect_shape(7n),shape),head,tail,
        sub => sub_shape => sep => L.decode_sweep_keeps_apart(k,(pos + 1 : U32),sub,watched,sub_shape,sep))

def L.decode_head_value_image(n,pos,image,shape,apart):
  next = Q.decoded(pos,Array.get(U32,L.image_board(image),pos))
  +p = (pos + 1 : U32)
  Equal.trans(U32,L.cell_value(Q.decode(n,p,next),pos),L.cell_value(next,pos),U32.shrn(L.cell_value(L.image_board(image),pos),10n),
    L.decode_sweep_keeps_apart(n,p,next,pos,L.decode_step_keeps_perfect(L.image_board(image),pos,shape),apart),
    L.decode_step_reads_cell(L.image_board(image),pos))

def L.decode_head_value(n,pos,board,shape,apart):
  proof : (L.Board128(board) -> L.DecodeApart(n,(pos + 1 : U32),pos) -> {L.cell_value(Q.decode(1n+n,pos,board),pos) == U32.shrn(L.cell_value(board,pos),10n) : U32}) =
    L.on_reified_board(board, b => (L.Board128(b) -> L.DecodeApart(n,(pos + 1 : U32),pos) -> {L.cell_value(Q.decode(1n+n,pos,b),pos) == U32.shrn(L.cell_value(b,pos),10n) : U32}),
      L.reify_board(board), image => L.decode_head_value_image(n, pos, image))
  proof(shape, apart)

def L.decode_middle_value_step_image(k,suffix,start,image,shapes,prior,later,recurse):
  (s0,s1) = shapes
  (head,rest) = prior
  next = Q.decoded(start,Array.get(U32,L.image_board(image),start))
  +start1 = (start + 1 : U32)
  +p = L.walk_position(k,start1)
  Equal.trans(U32,
    L.cell_value(Q.decode(L.with_center(k,suffix),start1,next),p),
    U32.shrn(L.cell_value(next,p),10n),
    U32.shrn(L.cell_value(L.image_board(image),p),10n),
    recurse(next,L.decode_step_keeps_perfect(L.image_board(image),start,s0),rest,later),
    Equal.cong(U32,U32,x => U32.shrn(x,10n),L.cell_value(next,p),L.cell_value(L.image_board(image),p),
      L.decode_step_keeps_cell(L.image_board(image),start,p,s1,head)))

def L.decode_middle_value_step(k,suffix,start,board,shapes,prior,later,recurse):
  proof : ((L.Board128(board) & L.Board128(board)) -> L.DecodeApart(1n+k,start,L.walk_position(1n+k,start)) -> L.DecodeApart(suffix,(L.walk_position(1n+k,start) + 1 : U32),L.walk_position(1n+k,start)) -> L.DecodeMiddleProof(k,suffix,(start + 1 : U32)) -> {L.cell_value(Q.decode(L.with_center(1n+k,suffix),start,board),L.walk_position(1n+k,start)) == U32.shrn(L.cell_value(board,L.walk_position(1n+k,start)),10n) : U32}) =
    L.on_reified_board(board, b => ((L.Board128(b) & L.Board128(b)) -> L.DecodeApart(1n+k,start,L.walk_position(1n+k,start)) -> L.DecodeApart(suffix,(L.walk_position(1n+k,start) + 1 : U32),L.walk_position(1n+k,start)) -> L.DecodeMiddleProof(k,suffix,(start + 1 : U32)) -> {L.cell_value(Q.decode(L.with_center(1n+k,suffix),start,b),L.walk_position(1n+k,start)) == U32.shrn(L.cell_value(b,L.walk_position(1n+k,start)),10n) : U32}),
      L.reify_board(board), image => L.decode_middle_value_step_image(k, suffix, start, image))
  proof(shapes, prior, later, recurse)

def L.decode_middle_value(prefix,suffix,start,board,shape,prior,later):
  match prefix:
    case 0n:
      L.decode_head_value(suffix,start,board,shape,later)
    case 1n+k:
      L.decode_middle_value_step(k,suffix,start,board,
        L.copy_shape_proof(L.array_shape(board),L.perfect_shape(7n),shape),prior,later,
        sub => sub_shape => before => after => L.decode_middle_value(k,suffix,(start + 1 : U32),sub,sub_shape,before,after))

def L.flag_normalized_read(b,p,on,same,old,untouched,observed):
  %Equal.sym(Array<U32> & U32,Board.get_cell(b,L.flag_slot(p)),(same,old),observed) :
    {Q.flagged(p,on,_) == Board.set_cell(b,L.flag_slot(p),L.flag_word(p,on,Pair.snd(Array<U32>,U32,_))) : Array<U32>}
  %Equal.sym(Array<U32>,same,b,untouched) :
    {Board.set_cell(_,L.flag_slot(p),L.flag_word(p,on,old)) == Board.set_cell(b,L.flag_slot(p),L.flag_word(p,on,old)) : Array<U32>}
  {==}

def L.flag_normalized(b,p,on,read):
  (same,+old,(untouched,observed)) = read
  L.flag_normalized_read(b,p,on,same,old,untouched,observed)

def L.flag_keeps_cell_image(image,p,on,q,shape,apart):
  b = L.image_board(image)
  +slot = L.flag_slot(p)
  +word = L.flag_word(p,on,L.cell_value(L.image_board(image),slot))
  %Equal.sym(Array<U32>,Q.flag(b,p,on),Board.set_cell(b,slot,word),
    L.flag_normalized(b,p,on,L.board_read_witness(L.image_board(image),slot))) :
    {L.cell_value(_,q) == L.cell_value(b,q) : U32}
  L.perfect_write_keeps_cell(L.image_board(image),slot,q,word,shape,apart)

def L.flag_keeps_cell(b,p,on,q):
  L.on_reified_board(b,x => L.FlagKeeps(x,p,on,q),
    L.reify_board(b),image => L.flag_keeps_cell_image(image,p,on,q))

def L.encoded_mask_keeps_step(image,p,mask,q,shapes,distinct,flags):
  (s0,s1) = shapes
  b = L.image_board(image)
  written = Board.set_cell(L.image_board(image),p,mask)
  +on = Q.zero_or_single(mask)
  Equal.trans(U32,
    L.cell_value(Q.encoded_mask(p,(b,mask)),q), L.cell_value(written,q), L.cell_value(b,q),
    L.flag_keeps_cell(written,p,on,q)(L.board_set_keeps_perfect(L.image_board(image),p,mask,7n,s0),flags),
    L.perfect_write_keeps_cell(L.image_board(image),p,q,mask,s1,distinct))

def L.encoded_mask_keeps_image(image,p,mask,q,shape,distinct,flags):
  L.encoded_mask_keeps_step(image,p,mask,q,
    L.copy_shape_proof(L.array_shape(L.image_board(image)),L.perfect_shape(7n),shape),distinct,flags)

def L.encoded_mask_keeps_cell(b,p,mask,q):
  L.on_reified_board(b,x => L.MaskKeeps(x,p,mask,q),
    L.reify_board(b),image => L.encoded_mask_keeps_image(image,p,mask,q))

def L.encoded_mask_writes_image(image,p,mask,shape,apart):
  b = L.image_board(image)
  written = Board.set_cell(L.image_board(image),p,mask)
  Equal.trans(U32,L.cell_value(Q.encoded_mask(p,(b,mask)),p),L.cell_value(written,p),mask,
    L.flag_keeps_cell(written,p,Q.zero_or_single(mask),p)(L.board_set_keeps_perfect(L.image_board(image),p,mask,7n,shape),apart),
    L.board_set_get(L.image_board(image),p,mask))

def L.encoded_mask_writes_cell(b,p,mask):
  L.on_reified_board(b,x => L.MaskWrites(x,p,mask),
    L.reify_board(b),image => L.encoded_mask_writes_image(image,p,mask))

def L.encoded_blank_normalized_read(b,p,same,mask,unchanged,observed):
  %Equal.sym(Array<U32> & U32,C.cached_at(b,p),(same,mask),observed) :
    {Q.encoded_mask(p,_) == Q.encoded_mask(p,(b,Pair.snd(Array<U32>,U32,_))) : Array<U32>}
  %Equal.sym(Array<U32>,same,b,unchanged) :
    {Q.encoded_mask(p,(_,mask)) == Q.encoded_mask(p,(b,mask)) : Array<U32>}
  {==}

def L.encoded_blank_normalized(b,p,read):
  (same,+mask,(unchanged,observed)) = read
  L.encoded_blank_normalized_read(b,p,same,mask,unchanged,observed)

def L.encoded_blank_keeps_image(image,p,q,shape,apart,flags):
  b = L.image_board(image)
  +mask = L.cached_word(L.image_board(image),p)
  %Equal.sym(Array<U32>,Q.encoded(p,(b,0)),Q.encoded_mask(p,(b,mask)),
    L.encoded_blank_normalized(b,p,L.cached_at_observed(L.image_board(image),p))) :
    {L.cell_value(_,q) == L.cell_value(b,q) : U32}
  L.encoded_mask_keeps_cell(L.image_board(image),p,mask,q)(shape,apart,flags)

def L.encoded_blank_keeps(b,p,q):
  L.on_reified_board(b,x => L.EncodedKeeps(x,p,0,q),
    L.reify_board(b),image => L.encoded_blank_keeps_image(image,p,q))

def L.encoded_blank_restores_image(image,p,shape,apart):
  b = L.image_board(image)
  +mask = L.cached_word(L.image_board(image),p)
  %Equal.sym(Array<U32>,Q.encoded(p,(b,0)),Q.encoded_mask(p,(b,mask)),
    L.encoded_blank_normalized(b,p,L.cached_at_observed(L.image_board(image),p))) :
    {U32.shrn(L.cell_value(_,p),10n) == 0 : U32}
  Equal.trans(U32,U32.shrn(L.cell_value(Q.encoded_mask(p,(b,mask)),p),10n),U32.shrn(mask,10n),0,
    Equal.cong(U32,U32,x => U32.shrn(x,10n),L.cell_value(Q.encoded_mask(p,(b,mask)),p),mask,
      L.encoded_mask_writes_cell(L.image_board(image),p,mask)(shape,apart)),
    L.cached_at_decodes_blank(L.image_board(image),p))

def L.encoded_blank_restores(b,p):
  L.on_reified_board(b,x => L.EncodedRestores(x,p,0),
    L.reify_board(b),image => L.encoded_blank_restores_image(image,p))

def L.encoded_digit_keeps(d,b,p,q,shape,apart,flags):
  match d:
    case L.D0{}:
      L.encoded_blank_keeps(b,p,q)(shape,apart,flags)
    case L.D1{}:
      L.perfect_write_keeps_cell(b,p,q,1024,shape,apart)
    case L.D2{}:
      L.perfect_write_keeps_cell(b,p,q,2048,shape,apart)
    case L.D3{}:
      L.perfect_write_keeps_cell(b,p,q,3072,shape,apart)
    case L.D4{}:
      L.perfect_write_keeps_cell(b,p,q,4096,shape,apart)
    case L.D5{}:
      L.perfect_write_keeps_cell(b,p,q,5120,shape,apart)
    case L.D6{}:
      L.perfect_write_keeps_cell(b,p,q,6144,shape,apart)
    case L.D7{}:
      L.perfect_write_keeps_cell(b,p,q,7168,shape,apart)
    case L.D8{}:
      L.perfect_write_keeps_cell(b,p,q,8192,shape,apart)
    case L.D9{}:
      L.perfect_write_keeps_cell(b,p,q,9216,shape,apart)

def L.encoded_digit_restores(d,b,p,shape,apart):
  match d:
    case L.D0{}:
      L.encoded_blank_restores(b,p)(shape,apart)
    case L.D1{}:
      Equal.cong(U32,U32,x => U32.shrn(x,10n),L.cell_value(Q.encoded(p,(b,1)),p),1024,L.encode_fixed_cell_1(b,p))
    case L.D2{}:
      Equal.cong(U32,U32,x => U32.shrn(x,10n),L.cell_value(Q.encoded(p,(b,2)),p),2048,L.encode_fixed_cell_2(b,p))
    case L.D3{}:
      Equal.cong(U32,U32,x => U32.shrn(x,10n),L.cell_value(Q.encoded(p,(b,3)),p),3072,L.encode_fixed_cell_3(b,p))
    case L.D4{}:
      Equal.cong(U32,U32,x => U32.shrn(x,10n),L.cell_value(Q.encoded(p,(b,4)),p),4096,L.encode_fixed_cell_4(b,p))
    case L.D5{}:
      Equal.cong(U32,U32,x => U32.shrn(x,10n),L.cell_value(Q.encoded(p,(b,5)),p),5120,L.encode_fixed_cell_5(b,p))
    case L.D6{}:
      Equal.cong(U32,U32,x => U32.shrn(x,10n),L.cell_value(Q.encoded(p,(b,6)),p),6144,L.encode_fixed_cell_6(b,p))
    case L.D7{}:
      Equal.cong(U32,U32,x => U32.shrn(x,10n),L.cell_value(Q.encoded(p,(b,7)),p),7168,L.encode_fixed_cell_7(b,p))
    case L.D8{}:
      Equal.cong(U32,U32,x => U32.shrn(x,10n),L.cell_value(Q.encoded(p,(b,8)),p),8192,L.encode_fixed_cell_8(b,p))
    case L.D9{}:
      Equal.cong(U32,U32,x => U32.shrn(x,10n),L.cell_value(Q.encoded(p,(b,9)),p),9216,L.encode_fixed_cell_9(b,p))

def L.encoded_any_keeps(d,b,p,q,shape,apart,flags):
  match d:
    case U32{WCon{True{}, rest}}:
      L.perfect_write_keeps_cell(b,p,q,U32.shln(U32{WCon{True{}, rest}},10n),shape,apart)
    case U32{WCon{False{}, WCon{True{}, rest}}}:
      L.perfect_write_keeps_cell(b,p,q,U32.shln(U32{WCon{False{}, WCon{True{}, rest}}},10n),shape,apart)
    case U32{WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}:
      L.perfect_write_keeps_cell(b,p,q,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{True{}, rest}}}},10n),shape,apart)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}:
      L.perfect_write_keeps_cell(b,p,q,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}},10n),shape,apart)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}:
      L.perfect_write_keeps_cell(b,p,q,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}},10n),shape,apart)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}:
      L.perfect_write_keeps_cell(b,p,q,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}},10n),shape,apart)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}:
      L.perfect_write_keeps_cell(b,p,q,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}},10n),shape,apart)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}:
      L.perfect_write_keeps_cell(b,p,q,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}},10n),shape,apart)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}:
      L.perfect_write_keeps_cell(b,p,q,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}},10n),shape,apart)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}:
      L.perfect_write_keeps_cell(b,p,q,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}},10n),shape,apart)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}:
      L.perfect_write_keeps_cell(b,p,q,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}},10n),shape,apart)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}:
      L.perfect_write_keeps_cell(b,p,q,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}},10n),shape,apart)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}:
      L.perfect_write_keeps_cell(b,p,q,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}},10n),shape,apart)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}:
      L.perfect_write_keeps_cell(b,p,q,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}},10n),shape,apart)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}:
      L.perfect_write_keeps_cell(b,p,q,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}},10n),shape,apart)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}:
      L.perfect_write_keeps_cell(b,p,q,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}},10n),shape,apart)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}:
      L.perfect_write_keeps_cell(b,p,q,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}},10n),shape,apart)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}:
      L.perfect_write_keeps_cell(b,p,q,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}},10n),shape,apart)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}:
      L.perfect_write_keeps_cell(b,p,q,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}},10n),shape,apart)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}:
      L.perfect_write_keeps_cell(b,p,q,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}},10n),shape,apart)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}:
      L.perfect_write_keeps_cell(b,p,q,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}},10n),shape,apart)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}:
      L.perfect_write_keeps_cell(b,p,q,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}},10n),shape,apart)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}:
      L.perfect_write_keeps_cell(b,p,q,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}},10n),shape,apart)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.perfect_write_keeps_cell(b,p,q,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}},10n),shape,apart)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.perfect_write_keeps_cell(b,p,q,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}},10n),shape,apart)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.perfect_write_keeps_cell(b,p,q,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}},10n),shape,apart)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.perfect_write_keeps_cell(b,p,q,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}},10n),shape,apart)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.perfect_write_keeps_cell(b,p,q,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}},10n),shape,apart)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.perfect_write_keeps_cell(b,p,q,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}},10n),shape,apart)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.perfect_write_keeps_cell(b,p,q,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}},10n),shape,apart)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.perfect_write_keeps_cell(b,p,q,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}},10n),shape,apart)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.perfect_write_keeps_cell(b,p,q,U32.shln(U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}},10n),shape,apart)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.encoded_blank_keeps(b,p,q)(shape,apart,flags)

def L.encode_step_normalized_read(b,p,same,word,untouched,observed):
  %Equal.sym(Array<U32> & U32,Board.get_cell(b,p),(same,word),observed) :
    {Q.encoded(p,_) == Q.encoded(p,(b,Pair.snd(Array<U32>,U32,_))) : Array<U32>}
  %Equal.sym(Array<U32>,same,b,untouched) :
    {Q.encoded(p,(_,word)) == Q.encoded(p,(b,word)) : Array<U32>}
  {==}

def L.encode_step_normalized(b,p,read):
  (same,+word,(untouched,observed)) = read
  L.encode_step_normalized_read(b,p,same,word,untouched,observed)

def L.encode_step_keeps_image(image,p,q,shape,apart,flags):
  b = L.image_board(image)
  +word = L.cell_value(L.image_board(image),p)
  %Equal.sym(Array<U32>,L.actual_encoded_step(b,p),Q.encoded(p,(b,word)),
    L.encode_step_normalized(b,p,L.board_read_witness(L.image_board(image),p))) :
    {L.cell_value(_,q) == L.cell_value(b,q) : U32}
  L.encoded_any_keeps(word,L.image_board(image),p,q,shape,apart,flags)

def L.encode_step_keeps(b,p,q):
  L.on_reified_board(b,x => L.EncodeStepKeeps(x,p,q),
    L.reify_board(b),image => L.encode_step_keeps_image(image,p,q))

def L.encode_step_restores_image(image,p,d,shape,apart,word_is):
  b = L.image_board(image)
  +word = L.cell_value(L.image_board(image),p)
  +digit = L.digit_word(d)
  %Equal.sym(Array<U32>,L.actual_encoded_step(b,p),Q.encoded(p,(b,word)),
    L.encode_step_normalized(b,p,L.board_read_witness(L.image_board(image),p))) :
    {U32.shrn(L.cell_value(_,p),10n) == digit : U32}
  %Equal.sym(U32,word,digit,word_is) :
    {U32.shrn(L.cell_value(Q.encoded(p,(b,_)),p),10n) == digit : U32}
  L.encoded_digit_restores(d,L.image_board(image),p,shape,apart)

def L.encode_step_restores(b,p,d):
  L.on_reified_board(b,x => L.EncodeStepRestores(x,p,d),
    L.reify_board(b),image => L.encode_step_restores_image(image,p,d))

def L.actual_encode_step_keeps_perfect(b,p,shape):
  Equal.trans(L.ArrayShape,L.array_shape(L.actual_encoded_step(b,p)),L.array_shape(b),L.perfect_shape(7n),
    L.project_shape_transition(b,L.actual_encoded_step(b,p),L.encode_loop_shape(1n,p,b)),
    shape)

def L.encode_sweep_keep_image_step(image,n,p,q,shapes,apart,next):
  (s0,s1) = shapes
  (cell,(flag,tail)) = apart
  b = L.image_board(image)
  step = L.actual_encoded_step(L.image_board(image),p)
  +p1 = (p + 1 : U32)
  Equal.trans(U32,L.cell_value(Q.encode_go(n,p1,step),q),L.cell_value(step,q),L.cell_value(b,q),
    next(step,L.actual_encode_step_keeps_perfect(L.image_board(image),p,s0),tail),
    L.encode_step_keeps(L.image_board(image),p,q)(s1,cell,flag))

def L.encode_sweep_keep_image(image,n,p,q,shape,apart,next):
  L.encode_sweep_keep_image_step(image,n,p,q,
    L.copy_shape_proof(L.array_shape(L.image_board(image)),L.perfect_shape(7n),shape),apart,next)

def L.encode_sweep_keep_step(b,n,p,q):
  L.on_reified_board(b,x => L.EncodeKeepStep(x,n,p,q),
    L.reify_board(b),image => L.encode_sweep_keep_image(image,n,p,q))

def L.encode_sweep_keeps(n,p,q,b,shape,apart):
  match n:
    case 0n:
      {==}
    case 1n+k:
      L.encode_sweep_keep_step(b,k,p,q)(shape,apart,
        sub => sub_shape => sep => L.encode_sweep_keeps(k,(p + 1 : U32),q,sub,sub_shape,sep))

def L.encode_middle_base_image(image,suffix,p,d,shapes,safe,tail,digit):
  (s0,s1) = shapes
  step = L.actual_encoded_step(L.image_board(image),p)
  +p1 = (p + 1 : U32)
  +final = L.cell_value(Q.encode_go(suffix,p1,L.actual_encoded_step(L.image_board(image),p)),p)
  +current = L.cell_value(L.actual_encoded_step(L.image_board(image),p),p)
  Equal.trans(U32,U32.shrn(final,10n),U32.shrn(current,10n),L.digit_word(d),
    Equal.cong(U32,U32,x => U32.shrn(x,10n),final,current,
      L.encode_sweep_keeps(suffix,p1,p,step,L.actual_encode_step_keeps_perfect(L.image_board(image),p,s0),tail)),
    L.encode_step_restores(L.image_board(image),p,d)(s1,safe,digit))

def L.encode_middle_base(image,suffix,p,d,shape,before,safe,after,digit):
  L.encode_middle_base_image(image,suffix,p,d,
    L.copy_shape_proof(L.array_shape(L.image_board(image)),L.perfect_shape(7n),shape),safe,after,digit)

def L.encode_middle_step_image(image,k,suffix,p,d,shapes,before,safe,after,digit,next):
  (s0,s1) = shapes
  (cell,(flag,tail)) = before
  step = L.actual_encoded_step(L.image_board(image),p)
  +p1 = (p + 1 : U32)
  +q = L.walk_position(k,p1)
  next(step,L.actual_encode_step_keeps_perfect(L.image_board(image),p,s0),tail,safe,after,
    Equal.trans(U32,L.cell_value(step,q),L.cell_value(L.image_board(image),q),L.digit_word(d),
      L.encode_step_keeps(L.image_board(image),p,q)(s1,cell,flag),digit))

def L.encode_middle_step(image,k,suffix,p,d,next,shape,before,safe,after,digit):
  L.encode_middle_step_image(image,k,suffix,p,d,
    L.copy_shape_proof(L.array_shape(L.image_board(image)),L.perfect_shape(7n),shape),before,safe,after,digit,next)

def L.encode_middle_from_image(prefix,image,suffix,p,d,shape,before,safe,after,digit):
  match prefix:
    case 0n:
      L.encode_middle_base(image,suffix,p,d,shape,before,safe,after,digit)
    case 1n+k:
      L.encode_middle_step(image,k,suffix,p,d,
        sub => L.on_reified_board(sub,x => L.EncodeMiddleValue(x,k,suffix,(p + 1 : U32),d),
          L.reify_board(sub),im => L.encode_middle_from_image(k,im,suffix,(p + 1 : U32),d)),
        shape,before,safe,after,digit)

def L.encode_middle_value(b,prefix,suffix,p,d):
  L.on_reified_board(b,x => L.EncodeMiddleValue(x,prefix,suffix,p,d),
    L.reify_board(b),image => L.encode_middle_from_image(prefix,image,suffix,p,d))

def L.encode_sweep_keeps_perfect(b,n,p,shape):
  Equal.trans(L.ArrayShape,L.array_shape(Q.encode_go(n,p,b)),L.array_shape(b),L.perfect_shape(7n),
    L.project_shape_transition(b,Q.encode_go(n,p,b),L.encode_loop_shape(n,p,b)),
    shape)

def L.roundtrip_at_image_step(image,before,after,p,d,shapes,ep,safe,es,dp,ds,digit):
  (s0,s1) = shapes
  +n = L.with_center(before,after)
  +q = L.walk_position(before,p)
  encoded = Q.encode_go(n,p,L.image_board(image))
  Equal.trans(U32,L.cell_value(Q.decode(n,p,encoded),q),U32.shrn(L.cell_value(encoded,q),10n),L.digit_word(d),
    L.decode_middle_value(before,after,p,encoded,L.encode_sweep_keeps_perfect(L.image_board(image),n,p,s0),dp,ds),
    L.encode_middle_value(L.image_board(image),before,after,p,d)(s1,ep,safe,es,digit))

def L.roundtrip_at_image(image,before,after,p,d,shape,ep,safe,es,dp,ds,digit):
  L.roundtrip_at_image_step(image,before,after,p,d,
    L.copy_shape_proof(L.array_shape(L.image_board(image)),L.perfect_shape(7n),shape),ep,safe,es,dp,ds,digit)

def L.queued_roundtrip_at(b,before,after,p,d):
  L.on_reified_board(b,x => L.RoundTripAt(x,before,after,p,d),
    L.reify_board(b),image => L.roundtrip_at_image(image,before,after,p,d))

def L.queue_seed_perfect(b,shape):
  Equal.trans(L.ArrayShape,L.array_shape(L.queue_seed(b)),L.array_shape(b),L.perfect_shape(7n),
    L.project_shape_transition(b,L.queue_seed(b),L.queue_seed_shape(b)),shape)

def L.queue_seed_keeps_step(image,q,shapes,r9,r10,r11):
  (s0,(s1,s2)) = shapes
  b = L.image_board(image)
  first = Board.set_cell(L.image_board(image),109,0)
  second = Board.set_cell(Board.set_cell(L.image_board(image),109,0),110,0)
  Equal.trans(U32,L.cell_value(L.queue_seed(b),q),L.cell_value(second,q),L.cell_value(b,q),
    L.perfect_write_keeps_cell(second,111,q,0,
      L.board_set_keeps_perfect(Board.set_cell(L.image_board(image),109,0),110,0,7n,
        L.board_set_keeps_perfect(L.image_board(image),109,0,7n,s0)),r11),
    Equal.trans(U32,L.cell_value(second,q),L.cell_value(first,q),L.cell_value(b,q),
      L.perfect_write_keeps_cell(first,110,q,0,L.board_set_keeps_perfect(L.image_board(image),109,0,7n,s1),r10),
      L.perfect_write_keeps_cell(L.image_board(image),109,q,0,s2,r9)))

def L.queue_seed_keeps_image(image,q,shape,r9,r10,r11):
  L.queue_seed_keeps_step(image,q,
    L.copy_shape_three(L.array_shape(L.image_board(image)),L.perfect_shape(7n),shape),r9,r10,r11)

def L.queue_seed_keeps_cell(b,q):
  L.on_reified_board(b,x => L.QueueSeedKeeps(x,q),
    L.reify_board(b),image => L.queue_seed_keeps_image(image,q))

def L.roundtrip81_at_step(image,before,after,d,shapes,r9,r10,r11,ep,safe,es,dp,ds,count,digit):
  (s0,s1) = shapes
  b = L.image_board(image)
  seed = L.queue_seed(L.image_board(image))
  +q = L.walk_position(before,0)
  %count :
    {L.cell_value(Q.decode(_,0,Q.encode_go(_,0,L.queue_seed(b))),q) == L.digit_word(d) : U32}
  L.queued_roundtrip_at(seed,before,after,0,d)(
    L.queue_seed_perfect(L.image_board(image),s0),ep,safe,es,dp,ds,
    Equal.trans(U32,L.cell_value(seed,q),L.cell_value(b,q),L.digit_word(d),
      L.queue_seed_keeps_cell(L.image_board(image),q)(s1,r9,r10,r11),digit))

def L.roundtrip81_at_image(image,before,after,d,shape,r9,r10,r11,ep,safe,es,dp,ds,count,digit):
  L.roundtrip81_at_step(image,before,after,d,
    L.copy_shape_proof(L.array_shape(L.image_board(image)),L.perfect_shape(7n),shape),
    r9,r10,r11,ep,safe,es,dp,ds,count,digit)

def L.public_queue_roundtrip_at(b,before,after,d):
  L.on_reified_board(b,x => L.RoundTrip81At(x,before,after,d),
    L.reify_board(b),image => L.roundtrip81_at_image(image,before,after,d))

def L.both_true(a,b,combined):
  match a:
    case True{}:
      ({==},combined)
    case False{}:
      Empty.absurd(({False{} == True{} : Bool} & {b == True{} : Bool}),L.false_is_not_true(combined))

def L.copy_true(a,valid):
  %valid : ({a == _ : Bool} & {a == _ : Bool})
  ({==},{==})

def L.sweep_witness_combine(n,p,q,logical,flag,later):
  (for_encode,for_decode) = logical
  (enc,dec) = later
  ((for_encode,(flag,enc)),(for_decode,dec))

def L.sweep_witness_parts(n,p,q,first,right,recurse):
  (flag,more) = right
  L.sweep_witness_combine(n,p,q,L.copy_true(L.apart_guard(p,q),first),flag,recurse(more))

def L.sweep_witness_head(n,p,q,parts,recurse):
  (first,tail) = parts
  L.sweep_witness_parts(n,p,q,first,
    L.both_true(L.apart_guard(L.flag_slot(p),q),L.sweep_guard(n,(p + 1 : U32),q),tail),
    recurse)

def L.sweep_witnesses(n,p,q,valid):
  match n:
    case 0n:
      ({==},{==})
    case 1n+k:
      L.sweep_witness_head(k,p,q,
        L.both_true(L.apart_guard(p,q),Bool.and(L.apart_guard(L.flag_slot(p),q),L.sweep_guard(k,(p + 1 : U32),q)),valid),
        proof => L.sweep_witnesses(k,(p + 1 : U32),q,proof))

def L.window_routes_split_4(before,after,q,next,r9,r10,r11,safe,parts):
  (prior,rest) = parts
  (r9,(r10,(r11,(safe,(L.sweep_witnesses(before,0,q,prior),L.sweep_witnesses(after,next,q,rest))))))

def L.window_routes_split_3(before,after,q,next,r9,r10,r11,parts):
  (safe,rest) = parts
  L.window_routes_split_4(before,after,q,next,r9,r10,r11,safe,
    L.both_true(L.sweep_guard(before,0,q),L.sweep_guard(after,next,q),rest))

def L.window_routes_split_2(before,after,q,next,r9,r10,parts):
  (r11,rest) = parts
  L.window_routes_split_3(before,after,q,next,r9,r10,r11,
    L.both_true(L.apart_guard(L.flag_slot(q),q),Bool.and(L.sweep_guard(before,0,q),L.sweep_guard(after,next,q)),rest))

def L.window_routes_split_1(before,after,q,next,r9,parts):
  (r10,rest) = parts
  L.window_routes_split_2(before,after,q,next,r9,r10,
    L.both_true(L.apart_guard(111,q),Bool.and(L.apart_guard(L.flag_slot(q),q),Bool.and(L.sweep_guard(before,0,q),L.sweep_guard(after,next,q))),rest))

def L.window_routes_split_0(before,after,q,next,parts):
  (r9,rest) = parts
  L.window_routes_split_1(before,after,q,next,r9,
    L.both_true(L.apart_guard(110,q),Bool.and(L.apart_guard(111,q),Bool.and(L.apart_guard(L.flag_slot(q),q),Bool.and(L.sweep_guard(before,0,q),L.sweep_guard(after,next,q)))),rest))

def L.window_routes(before,after,q,next,e):
  L.window_routes_split_0(before,after,q,next,
    L.both_true(L.apart_guard(109,q),Bool.and(L.apart_guard(110,q),Bool.and(L.apart_guard(111,q),Bool.and(L.apart_guard(L.flag_slot(q),q),Bool.and(L.sweep_guard(before,0,q),L.sweep_guard(after,next,q))))),e))

def L.public_roundtrip_routes(b,before,after,d,shape,routes,count,digit):
  (r9,(r10,(r11,(safe,((ep,dp),(es,ds)))))) = routes
  L.public_queue_roundtrip_at(b,before,after,d)(shape,r9,r10,r11,ep,safe,es,dp,ds,count,digit)

def L.public_roundtrip_checked(b,before,after,d,shape,window,digit):
  (guard,count) = window
  +q = L.walk_position(before,0)
  L.public_roundtrip_routes(b,before,after,d,shape,
    L.window_routes(before,after,q,(q + 1 : U32),guard),count,digit)

def L.row_window_0(col):
  match col:
    case L.Coordinate0{}:
      ({==},{==})
    case L.Coordinate1{}:
      ({==},{==})
    case L.Coordinate2{}:
      ({==},{==})
    case L.Coordinate3{}:
      ({==},{==})
    case L.Coordinate4{}:
      ({==},{==})
    case L.Coordinate5{}:
      ({==},{==})
    case L.Coordinate6{}:
      ({==},{==})
    case L.Coordinate7{}:
      ({==},{==})
    case L.Coordinate8{}:
      ({==},{==})

def L.row_window_1(col):
  match col:
    case L.Coordinate0{}:
      ({==},{==})
    case L.Coordinate1{}:
      ({==},{==})
    case L.Coordinate2{}:
      ({==},{==})
    case L.Coordinate3{}:
      ({==},{==})
    case L.Coordinate4{}:
      ({==},{==})
    case L.Coordinate5{}:
      ({==},{==})
    case L.Coordinate6{}:
      ({==},{==})
    case L.Coordinate7{}:
      ({==},{==})
    case L.Coordinate8{}:
      ({==},{==})

def L.row_window_2(col):
  match col:
    case L.Coordinate0{}:
      ({==},{==})
    case L.Coordinate1{}:
      ({==},{==})
    case L.Coordinate2{}:
      ({==},{==})
    case L.Coordinate3{}:
      ({==},{==})
    case L.Coordinate4{}:
      ({==},{==})
    case L.Coordinate5{}:
      ({==},{==})
    case L.Coordinate6{}:
      ({==},{==})
    case L.Coordinate7{}:
      ({==},{==})
    case L.Coordinate8{}:
      ({==},{==})

def L.row_window_3(col):
  match col:
    case L.Coordinate0{}:
      ({==},{==})
    case L.Coordinate1{}:
      ({==},{==})
    case L.Coordinate2{}:
      ({==},{==})
    case L.Coordinate3{}:
      ({==},{==})
    case L.Coordinate4{}:
      ({==},{==})
    case L.Coordinate5{}:
      ({==},{==})
    case L.Coordinate6{}:
      ({==},{==})
    case L.Coordinate7{}:
      ({==},{==})
    case L.Coordinate8{}:
      ({==},{==})

def L.row_window_4(col):
  match col:
    case L.Coordinate0{}:
      ({==},{==})
    case L.Coordinate1{}:
      ({==},{==})
    case L.Coordinate2{}:
      ({==},{==})
    case L.Coordinate3{}:
      ({==},{==})
    case L.Coordinate4{}:
      ({==},{==})
    case L.Coordinate5{}:
      ({==},{==})
    case L.Coordinate6{}:
      ({==},{==})
    case L.Coordinate7{}:
      ({==},{==})
    case L.Coordinate8{}:
      ({==},{==})

def L.row_window_5(col):
  match col:
    case L.Coordinate0{}:
      ({==},{==})
    case L.Coordinate1{}:
      ({==},{==})
    case L.Coordinate2{}:
      ({==},{==})
    case L.Coordinate3{}:
      ({==},{==})
    case L.Coordinate4{}:
      ({==},{==})
    case L.Coordinate5{}:
      ({==},{==})
    case L.Coordinate6{}:
      ({==},{==})
    case L.Coordinate7{}:
      ({==},{==})
    case L.Coordinate8{}:
      ({==},{==})

def L.row_window_6(col):
  match col:
    case L.Coordinate0{}:
      ({==},{==})
    case L.Coordinate1{}:
      ({==},{==})
    case L.Coordinate2{}:
      ({==},{==})
    case L.Coordinate3{}:
      ({==},{==})
    case L.Coordinate4{}:
      ({==},{==})
    case L.Coordinate5{}:
      ({==},{==})
    case L.Coordinate6{}:
      ({==},{==})
    case L.Coordinate7{}:
      ({==},{==})
    case L.Coordinate8{}:
      ({==},{==})

def L.row_window_7(col):
  match col:
    case L.Coordinate0{}:
      ({==},{==})
    case L.Coordinate1{}:
      ({==},{==})
    case L.Coordinate2{}:
      ({==},{==})
    case L.Coordinate3{}:
      ({==},{==})
    case L.Coordinate4{}:
      ({==},{==})
    case L.Coordinate5{}:
      ({==},{==})
    case L.Coordinate6{}:
      ({==},{==})
    case L.Coordinate7{}:
      ({==},{==})
    case L.Coordinate8{}:
      ({==},{==})

def L.row_window_8(col):
  match col:
    case L.Coordinate0{}:
      ({==},{==})
    case L.Coordinate1{}:
      ({==},{==})
    case L.Coordinate2{}:
      ({==},{==})
    case L.Coordinate3{}:
      ({==},{==})
    case L.Coordinate4{}:
      ({==},{==})
    case L.Coordinate5{}:
      ({==},{==})
    case L.Coordinate6{}:
      ({==},{==})
    case L.Coordinate7{}:
      ({==},{==})
    case L.Coordinate8{}:
      ({==},{==})

def L.every_cell_window(row,col):
  match row:
    case L.Coordinate0{}:
      L.row_window_0(col)
    case L.Coordinate1{}:
      L.row_window_1(col)
    case L.Coordinate2{}:
      L.row_window_2(col)
    case L.Coordinate3{}:
      L.row_window_3(col)
    case L.Coordinate4{}:
      L.row_window_4(col)
    case L.Coordinate5{}:
      L.row_window_5(col)
    case L.Coordinate6{}:
      L.row_window_6(col)
    case L.Coordinate7{}:
      L.row_window_7(col)
    case L.Coordinate8{}:
      L.row_window_8(col)

def L.any_logical_cell_roundtrip(b,row,col,d,shape,digit):
  L.public_roundtrip_checked(b,L.logical_offset(row,col),L.logical_tail(row,col),d,shape,L.every_cell_window(row,col),digit)

def L.adaptive_activation_finish(b,row,col,d,shape,given):
  L.any_logical_cell_roundtrip(b,row,col,d,shape,given)

def L.adaptive_new_mode_record(b,frames,depth,found,snapshots,row,col,d,shape,given):
  L.adaptive_activation_finish(b,row,col,d,shape,given)

def L.adaptive_active_clear_keeps_clue(b,written,clue,shape,separate):
  Equal.cong(U32,U32,x => U32.shrn(x,10n),
    L.cell_value(Fast.cleared(True{},b,written),clue),L.cell_value(b,clue),
    L.perfect_write_keeps_cell(b,written,clue,0,shape,separate))

def L.adaptive_active_clear_keeps_shape(b,written,shape):
  L.board_set_keeps_perfect(b,written,0,7n,shape)

def L.adaptive_active_unwind_keeps_clue(b,written,clue,frames,depth,found,snapshots,shape,separate):
  L.adaptive_active_clear_keeps_clue(b,written,clue,shape,separate)

def L.adaptive_restore_reads_saved_clue(saved,pos,clue,frames,depth,found,snapshots,active):
  {==}

def L.queue_peer_without_bit(b,p,bit,word,clear):
  %Equal.sym(U32,U32.and(word,bit),0,clear) :
    {Q.changed(U32.is_ne(_,0),p,bit,b,word) == b : Array<U32>}
  {==}

def L.queue_peer_reads_fixed(b,p,bit,same,word,unchanged,observed,clear):
  %Equal.sym(Array<U32> & U32,Board.get_cell(b,p),(same,word),observed) :
    {Q.peer(p,bit,_) == b : Array<U32>}
  %Equal.sym(Array<U32>,same,b,unchanged) :
    {Q.peer(p,bit,(_,word)) == b : Array<U32>}
  L.queue_peer_without_bit(b,p,bit,word,clear)

def L.word_fixed_high_ignores_trimmed(hi,tail):
  %Equal.sym(Word(22n),Word.and(22n,Word.zero(22n),tail),Word.zero(22n),L.word_zero_and(22n,tail)) :
    {Word.and(22n,hi,_) == Word.zero(22n) : Word(22n)}
  L.word_and_zero(22n,hi)

def L.fixed_high_ignores_trimmed(hi,mask):
  match mask:
    case U32{WCon{m0, WCon{m1, WCon{m2, WCon{m3, WCon{m4, WCon{m5, WCon{m6, WCon{m7, WCon{m8, WCon{m9, tail}}}}}}}}}}}:
      Equal.cong(Word(22n),U32,x => L.fixed_hi_word(x),
        Word.and(22n,hi,Word.and(22n,Word.zero(22n),tail)),Word.zero(22n),
        L.word_fixed_high_ignores_trimmed(hi,tail))

def L.shifted_digit_ignores_trimmed(fixed,mask):
  match fixed:
    case L.D0{}:
      L.fixed_high_ignores_trimmed(Word.zero(22n),mask)
    case L.D1{}:
      L.fixed_high_ignores_trimmed(WCon{True{}, WCon{False{}, WCon{False{}, WCon{False{}, Word.zero(18n)}}}},mask)
    case L.D2{}:
      L.fixed_high_ignores_trimmed(WCon{False{}, WCon{True{}, WCon{False{}, WCon{False{}, Word.zero(18n)}}}},mask)
    case L.D3{}:
      L.fixed_high_ignores_trimmed(WCon{True{}, WCon{True{}, WCon{False{}, WCon{False{}, Word.zero(18n)}}}},mask)
    case L.D4{}:
      L.fixed_high_ignores_trimmed(WCon{False{}, WCon{False{}, WCon{True{}, WCon{False{}, Word.zero(18n)}}}},mask)
    case L.D5{}:
      L.fixed_high_ignores_trimmed(WCon{True{}, WCon{False{}, WCon{True{}, WCon{False{}, Word.zero(18n)}}}},mask)
    case L.D6{}:
      L.fixed_high_ignores_trimmed(WCon{False{}, WCon{True{}, WCon{True{}, WCon{False{}, Word.zero(18n)}}}},mask)
    case L.D7{}:
      L.fixed_high_ignores_trimmed(WCon{True{}, WCon{True{}, WCon{True{}, WCon{False{}, Word.zero(18n)}}}},mask)
    case L.D8{}:
      L.fixed_high_ignores_trimmed(WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, Word.zero(18n)}}}},mask)
    case L.D9{}:
      L.fixed_high_ignores_trimmed(WCon{True{}, WCon{False{}, WCon{False{}, WCon{True{}, Word.zero(18n)}}}},mask)

def L.placement_bit_fits_low(d):
  match d:
    case L.D0{}:
      {==}
    case L.D1{}:
      {==}
    case L.D2{}:
      {==}
    case L.D3{}:
      {==}
    case L.D4{}:
      {==}
    case L.D5{}:
      {==}
    case L.D6{}:
      {==}
    case L.D7{}:
      {==}
    case L.D8{}:
      {==}
    case L.D9{}:
      {==}

def L.queued_placement_bit_excludes_fixed(fixed,placed):
  %Equal.sym(U32,Board.bit(L.digit_word(placed)),U32.and(1023,Board.bit(L.digit_word(placed))),L.placement_bit_fits_low(placed)) :
    {U32.and(U32.shln(L.digit_word(fixed),10n),_) == 0 : U32}
  L.shifted_digit_ignores_trimmed(fixed,Board.bit(L.digit_word(placed)))

def L.queued_peer_on_fixed_digit(b,p,fixed,placed):
  L.queue_peer_without_bit(b,p,Board.bit(L.digit_word(placed)),U32.shln(L.digit_word(fixed),10n),
    L.queued_placement_bit_excludes_fixed(fixed,placed))

def L.queue_peer_fixed_observed(b,p,fixed,placed,same,word,kept,read,given):
  +bit = Board.bit(L.digit_word(placed))
  +expected = U32.shln(L.digit_word(fixed),10n)
  finish : ({L.cell_value(b,p) == expected : U32} ->
    {Q.peer(p,bit,Board.get_cell(b,p)) == b : Array<U32>}) = (
    %Equal.sym(Array<U32> & U32,Board.get_cell(b,p),(same,word),read) :
      ({Pair.snd(Array<U32>,U32,_) == expected : U32} -> {Q.peer(p,bit,_) == b : Array<U32>})
    old_is =>
      %Equal.sym(Array<U32>,same,b,kept) :
        {Q.peer(p,bit,(_,word)) == b : Array<U32>}
      %Equal.sym(U32,word,expected,old_is) :
        {Q.peer(p,bit,(b,_)) == b : Array<U32>}
      L.queued_peer_on_fixed_digit(b,p,fixed,placed))
  finish(given)

def L.queue_peer_fixed_read(b,p,fixed,placed,rd,given):
  (same,+word,(kept,read)) = rd
  L.queue_peer_fixed_observed(b,p,fixed,placed,same,word,kept,read,given)

def L.queue_actual_peer_fixed_image(image,p,fixed,placed,given):
  L.queue_peer_fixed_read(L.image_board(image),p,fixed,placed,L.board_read_witness(L.image_board(image),p),given)

def L.queue_actual_peer_fixed(b,p,fixed,placed):
  L.on_reified_board(b,x => L.PeerFixed(x,p,fixed,placed),
    L.reify_board(b),image => L.queue_actual_peer_fixed_image(image,p,fixed,placed))

def L.queued_first_pointer_from_read(n,p,b,same,word,kept,actual,later):
  %Equal.sym(Array<U32> & U32,Board.get_cell(b,(p + 1 : U32)),(same,word),actual) :
    L.FirstOnlyWritesPointer(b,Q.first_step(n,(p + 1 : U32),Q.first_read(_)))
  %kept :
    L.FirstOnlyWritesPointer(_,Q.first_step(n,(p + 1 : U32),(same,(word < 1024 : U32))))
  later

def L.queued_first_pointer_read(n,p,b,read,recurse):
  (same,+word,(kept,actual)) = read
  L.queued_first_pointer_from_read(n,p,b,same,word,kept,actual,recurse(same,(word < 1024 : U32)))

def L.queued_first_pointer_live(n,p,b,open,recurse):
  match open:
    case True{}:
      (p,{==})
    case False{}:
      L.queued_first_pointer_read(n,p,b,L.board_read_witness(b,(p + 1 : U32)),recurse)

def L.queued_first_pointer(n,p,b,open):
  match n open:
    case 0n True{}:
      (81,{==})
    case 0n False{}:
      (81,{==})
    case 1n+k flag:
      L.queued_first_pointer_live(k,p,b,flag,sub => more => L.queued_first_pointer(k,(p + 1 : U32),sub,more))

def L.pointer_keeps_logical_witness(b,out,q,shape,separate,witness):
  (+ptr,actual) = witness
  %Equal.sym(Array<U32>,out,Board.set_cell(b,108,ptr),actual) :
    {L.cell_value(_,q) == L.cell_value(b,q) : U32}
  L.perfect_write_keeps_cell(b,108,q,ptr,shape,separate)

def L.queue_first_pointer_keeps_clue_image(image,n,p,q,open,shape,separate):
  L.pointer_keeps_logical_witness(L.image_board(image),Q.first_step(n,p,(L.image_board(image),open)),q,shape,separate,
    L.queued_first_pointer(n,p,L.image_board(image),open))

def L.queue_first_pointer_keeps_clue(b,n,p,q,open):
  L.on_reified_board(b,x => (L.Board128(x) -> L.RoutedApart(108,q) ->
      {L.cell_value(Q.first_step(n,p,(x,open)),q) == L.cell_value(x,q) : U32}),
    L.reify_board(b),image => L.queue_first_pointer_keeps_clue_image(image,n,p,q,open))

def L.queue_flag_perfect(b,p,present,shape):
  Equal.trans(L.ArrayShape,L.array_shape(Q.flag(b,p,present)),L.array_shape(b),L.perfect_shape(7n),
    L.project_shape_transition(b,Q.flag(b,p,present),L.flag_shape(b,p,present)),shape)

def L.queue_changed_flag_perfect(b,p,needed,shape):
  match needed:
    case False{}:
      shape
    case True{}:
      L.queue_flag_perfect(b,p,True{},shape)

def L.queue_changed_flag_keeps(b,needed,p,q,sep,shape):
  match needed:
    case False{}:
      {==}
    case True{}:
      L.flag_keeps_cell(b,p,True{},q)(shape,sep)

def L.queue_changed_perfect_image(image,needed,p,bit,old,shape):
  match needed:
    case False{}:
      shape
    case True{}:
      L.queue_changed_flag_perfect(Board.set_cell(L.image_board(image),p,L.peer_mask(old,bit)),p,L.peer_reflag(old,bit),
        L.board_set_keeps_perfect(L.image_board(image),p,L.peer_mask(old,bit),7n,shape))

def L.queue_changed_perfect(b,needed,p,bit,old,shape):
  proof : (L.Board128(b) -> L.Board128(Q.changed(needed,p,bit,b,old))) =
    L.on_reified_board(b,x => (L.Board128(x) -> L.Board128(Q.changed(needed,p,bit,x,old))),
      L.reify_board(b),image => L.queue_changed_perfect_image(image,needed,p,bit,old))
  proof(shape)

def L.queue_changed_keeps_yes(image,p,bit,old,q,shapes,apart,flag):
  (s0,s1) = shapes
  b = L.image_board(image)
  +mask = L.peer_mask(old,bit)
  changed = Board.set_cell(L.image_board(image),p,mask)
  Equal.trans(U32,L.cell_value(Q.changed(True{},p,bit,b,old),q),L.cell_value(changed,q),L.cell_value(b,q),
    L.queue_changed_flag_keeps(changed,L.peer_reflag(old,bit),p,q,flag,L.board_set_keeps_perfect(L.image_board(image),p,mask,7n,s0)),
    L.perfect_write_keeps_cell(L.image_board(image),p,q,mask,s1,apart))

def L.queue_changed_keeps_image(image,needed,p,bit,old,q,shape,apart,flag):
  match needed:
    case False{}:
      {==}
    case True{}:
      L.queue_changed_keeps_yes(image,p,bit,old,q,
        L.copy_shape_proof(L.array_shape(L.image_board(image)),L.perfect_shape(7n),shape),apart,flag)

def L.queue_changed_keeps(b,needed,p,bit,old,q):
  L.on_reified_board(b,x => L.ChangedKeeps(x,needed,p,bit,old,q),
    L.reify_board(b),image => L.queue_changed_keeps_image(image,needed,p,bit,old,q))

def L.peer_normalized_observed(b,p,bit,same,old,kept,read):
  %Equal.sym(Array<U32> & U32,Board.get_cell(b,p),(same,old),read) :
    {Q.peer(p,bit,_) == Q.changed(U32.is_ne(U32.and(Pair.snd(Array<U32>,U32,_),bit),0),p,bit,b,Pair.snd(Array<U32>,U32,_)) : Array<U32>}
  %Equal.sym(Array<U32>,same,b,kept) :
    {Q.changed(U32.is_ne(U32.and(old,bit),0),p,bit,_,old) == Q.changed(U32.is_ne(U32.and(old,bit),0),p,bit,b,old) : Array<U32>}
  {==}

def L.peer_normalized(b,p,bit,rd):
  (same,+old,(kept,read)) = rd
  L.peer_normalized_observed(b,p,bit,same,old,kept,read)

def L.peer_keeps_image(image,p,bit,q,shape,apart,flag):
  b = L.image_board(image)
  +old = L.cell_value(L.image_board(image),p)
  +needed = U32.is_ne(U32.and(old,bit),0)
  %Equal.sym(Array<U32>,L.actual_peer(b,p,bit),Q.changed(needed,p,bit,b,old),
    L.peer_normalized(b,p,bit,L.board_read_witness(L.image_board(image),p))) :
    {L.cell_value(_,q) == L.cell_value(b,q) : U32}
  L.queue_changed_keeps(L.image_board(image),needed,p,bit,old,q)(shape,apart,flag)

def L.peer_keeps(b,p,bit,q):
  L.on_reified_board(b,x => L.PeerKeeps(x,p,bit,q),
    L.reify_board(b),image => L.peer_keeps_image(image,p,bit,q))

def L.peer_perfect_image(image,p,bit,shape):
  b = L.image_board(image)
  +old = L.cell_value(L.image_board(image),p)
  +needed = U32.is_ne(U32.and(old,bit),0)
  %Equal.sym(Array<U32>,L.actual_peer(b,p,bit),Q.changed(needed,p,bit,b,old),
    L.peer_normalized(b,p,bit,L.board_read_witness(L.image_board(image),p))) :
    L.Board128(_)
  L.queue_changed_perfect(L.image_board(image),needed,p,bit,old,shape)

def L.peer_perfect(b,p,bit):
  L.on_reified_board(b,x => (L.Board128(x) -> L.Board128(L.actual_peer(x,p,bit))),
    L.reify_board(b),image => L.peer_perfect_image(image,p,bit))

def L.copy_word_eq(word,expected,known):
  %known : ({word == _ : U32} & {word == _ : U32})
  ({==},{==})

def L.peer_keeps_same_step(image,q,fixed,placed,shape,given):
  (g0,g1) = given
  b = L.image_board(image)
  +bit = Board.bit(L.digit_word(placed))
  %Equal.sym(Array<U32>,L.actual_peer(b,q,bit),b,L.queue_actual_peer_fixed(L.image_board(image),q,fixed,placed)(g0)) :
    L.FixedClue(_,q,fixed)
  (shape,g1)

def L.peer_keeps_same_image(image,q,fixed,placed,state):
  (shape,given) = state
  L.peer_keeps_same_step(image,q,fixed,placed,shape,
    L.copy_word_eq(L.cell_value(L.image_board(image),q),L.fixed_word(fixed),given))

def L.peer_keeps_separate_step(image,p,q,fixed,placed,shapes,given,sep,flag):
  (s0,s1) = shapes
  +bit = Board.bit(L.digit_word(placed))
  (L.peer_perfect(L.image_board(image),p,bit)(s0),
    Equal.trans(U32,L.cell_value(L.actual_peer(L.image_board(image),p,bit),q),L.cell_value(L.image_board(image),q),L.fixed_word(fixed),
      L.peer_keeps(L.image_board(image),p,bit,q)(s1,sep,flag),given))

def L.peer_keeps_separate_image(image,p,q,fixed,placed,apart,state):
  (sep,flag) = apart
  (shape,given) = state
  L.peer_keeps_separate_step(image,p,q,fixed,placed,
    L.copy_shape_proof(L.array_shape(L.image_board(image)),L.perfect_shape(7n),shape),given,sep,flag)

def L.peer_clue_transition_image(image,p,q,fixed,placed,route,state):
  match route:
    case Inl{same}:
      %Equal.sym(U32,p,q,same) :
        L.FixedClue(L.actual_peer(L.image_board(image),_,Board.bit(L.digit_word(placed))),q,fixed)
      L.peer_keeps_same_image(image,q,fixed,placed,state)
    case Inr{apart}:
      L.peer_keeps_separate_image(image,p,q,fixed,placed,apart,state)

def L.peer_clue_transition(b,p,q,fixed,placed):
  L.on_reified_board(b,x => L.PeerClueTransition(x,p,q,fixed,placed),
    L.reify_board(b),image => L.peer_clue_transition_image(image,p,q,fixed,placed))

def L.row_clue_step_image(image,n,j,base,placed,q,fixed,d,routes,state,next):
  (here,tail) = routes
  +p = (base + j : U32)
  next(L.actual_peer(L.image_board(image),p,Board.bit(L.digit_word(d))),tail,
    L.peer_clue_transition(L.image_board(image),p,q,fixed,d)(here,state))

def L.row_clue_step(b,n,j,base,placed,q,fixed,d):
  L.on_reified_board(b,x => L.RowClueStep(x,n,j,base,placed,q,fixed,d),
    L.reify_board(b),image => L.row_clue_step_image(image,n,j,base,placed,q,fixed,d))

def L.row_clue_line(n,j,base,placed,q,fixed,d,b,routes,state):
  match n:
    case 0n:
      state
    case 1n+k:
      L.row_clue_step(b,k,j,base,placed,q,fixed,d)(routes,state,
        sub => rest => witness => L.row_clue_line(k,(j + 1 : U32),base,placed,q,fixed,d,sub,rest,witness))

def L.column_clue_step_image(image,n,j,col,placed,q,fixed,d,routes,state,next):
  (here,tail) = routes
  +p = (j * 9 + col : U32)
  next(L.actual_peer(L.image_board(image),p,Board.bit(L.digit_word(d))),tail,
    L.peer_clue_transition(L.image_board(image),p,q,fixed,d)(here,state))

def L.column_clue_step(b,n,j,col,placed,q,fixed,d):
  L.on_reified_board(b,x => L.ColumnClueStep(x,n,j,col,placed,q,fixed,d),
    L.reify_board(b),image => L.column_clue_step_image(image,n,j,col,placed,q,fixed,d))

def L.column_clue_line(n,j,col,placed,q,fixed,d,b,routes,state):
  match n:
    case 0n:
      state
    case 1n+k:
      L.column_clue_step(b,k,j,col,placed,q,fixed,d)(routes,state,
        sub => rest => witness => L.column_clue_line(k,(j + 1 : U32),col,placed,q,fixed,d,sub,rest,witness))

def L.peer_list_step_image(image,p,tail,q,fixed,d,routes,state,next):
  (here,later) = routes
  next(L.actual_peer(L.image_board(image),p,Board.bit(L.digit_word(d))),later,
    L.peer_clue_transition(L.image_board(image),p,q,fixed,d)(here,state))

def L.peer_list_step(b,p,tail,q,fixed,d,routes,state,next):
  proof : (L.PeerListRoutes(p <> tail,q) -> L.FixedClue(b,q,fixed) ->
    L.PeerListProof(tail,q,fixed,d) -> L.FixedClue(L.run_peer_list(p <> tail,b,Board.bit(L.digit_word(d))),q,fixed)) =
    L.on_reified_board(b,x => (L.PeerListRoutes(p <> tail,q) -> L.FixedClue(x,q,fixed) ->
      L.PeerListProof(tail,q,fixed,d) -> L.FixedClue(L.run_peer_list(p <> tail,x,Board.bit(L.digit_word(d))),q,fixed)),
      L.reify_board(b),image => L.peer_list_step_image(image,p,tail,q,fixed,d))
  proof(routes,state,next)

def L.peer_list_clue(positions,q,fixed,d,b,routes,state):
  match positions:
    case Nil{}:
      state
    case +p <> tail:
      L.peer_list_step(b,p,tail,q,fixed,d,routes,state,sub => rest => witness => L.peer_list_clue(tail,q,fixed,d,sub,rest,witness))

def L.box_four_keeps_clue(b,base,r1,r2,c1,c2,q,fixed,d,routes,state):
  L.peer_list_clue(L.box_positions(base,r1,r2,c1,c2),q,fixed,d,b,routes,state)

def L.fixed_after_pointer_write(image,out,q,d,shapes,known,apart,witness):
  (s0,s1) = shapes
  (+ptr,actual) = witness
  b = L.image_board(image)
  %Equal.sym(Array<U32>,out,Board.set_cell(b,108,ptr),actual) :
    L.FixedClue(_,q,d)
  (L.board_set_keeps_perfect(L.image_board(image),108,ptr,7n,s0),
    Equal.trans(U32,L.cell_value(Board.set_cell(b,108,ptr),q),L.cell_value(b,q),L.fixed_word(d),
      L.perfect_write_keeps_cell(L.image_board(image),108,q,ptr,s1,apart),known))

def L.first_step_keeps_fixed_image(image,n,p,open,q,d,apart,state):
  (shape,known) = state
  L.fixed_after_pointer_write(image,Q.first_step(n,p,(L.image_board(image),open)),q,d,
    L.copy_shape_proof(L.array_shape(L.image_board(image)),L.perfect_shape(7n),shape),known,apart,
    L.queued_first_pointer(n,p,L.image_board(image),open))

def L.first_actual_from_read(n,p,b,same,word,kept,observed,recurse):
  %Equal.sym(Array<U32> & U32,Board.get_cell(b,p),(same,word),observed) :
    L.FirstOnlyWritesPointer(b,Q.first_step(n,p,Q.first_read(_)))
  %kept :
    L.FirstOnlyWritesPointer(_,Q.first_step(n,p,(same,(word < 1024 : U32))))
  recurse(same,(word < 1024 : U32))

def L.first_actual_pointer(n,p,b,read):
  (same,+word,(kept,observed)) = read
  L.first_actual_from_read(n,p,b,same,word,kept,observed,sub => open => L.queued_first_pointer(n,p,sub,open))

def L.refresh_needed_clue_image(image,needed,start,q,d,apart,state):
  match needed:
    case False{}:
      state
    case True{}:
      (shape,known) = state
      +n = U32.to_nat((81 - start : U32))
      L.fixed_after_pointer_write(image,L.first_actual(L.image_board(image),n,start),q,d,
        L.copy_shape_proof(L.array_shape(L.image_board(image)),L.perfect_shape(7n),shape),known,apart,
        L.first_actual_pointer(n,start,L.image_board(image),L.board_read_witness(L.image_board(image),start)))

def L.refresh_normalized_read(b,p,same,start,kept,observed):
  %Equal.sym(Array<U32> & U32,Board.get_cell(b,108),(same,start),observed) :
    {Q.refresh(p,_) == Q.refresh_needed(U32.is_eq(p,Pair.snd(Array<U32>,U32,_)),b,Pair.snd(Array<U32>,U32,_)) : Array<U32>}
  %Equal.sym(Array<U32>,same,b,kept) :
    {Q.refresh_needed(U32.is_eq(p,start),_,start) == Q.refresh_needed(U32.is_eq(p,start),b,start) : Array<U32>}
  {==}

def L.refresh_normalized(b,p,read):
  (same,+start,(kept,observed)) = read
  L.refresh_normalized_read(b,p,same,start,kept,observed)

def L.refresh_keeps_clue_image(image,p,q,d,apart,state):
  b = L.image_board(image)
  +start = L.cell_value(L.image_board(image),108)
  +needed = U32.is_eq(p,start)
  %Equal.sym(Array<U32>,L.refresh_actual(b,p),Q.refresh_needed(needed,b,start),
    L.refresh_normalized(b,p,L.board_read_witness(L.image_board(image),108))) :
    L.FixedClue(_,q,d)
  L.refresh_needed_clue_image(image,needed,start,q,d,apart,state)

def L.refresh_keeps_clue(b,p,q,d):
  L.on_reified_board(b,x => L.RefreshClue(x,p,q,d),
    L.reify_board(b),image => L.refresh_keeps_clue_image(image,p,q,d))

def L.clear_forced_clue_image_step(image,p,q,d,flag,shapes,known):
  (s0,s1) = shapes
  b = L.image_board(image)
  (L.queue_flag_perfect(L.image_board(image),p,False{},s0),
    Equal.trans(U32,L.cell_value(Q.flag(b,p,False{}),q),L.cell_value(b,q),L.fixed_word(d),
      L.flag_keeps_cell(L.image_board(image),p,False{},q)(s1,flag),known))

def L.clear_forced_clue_image(image,guess,p,q,d,flag,state):
  match guess:
    case True{}:
      state
    case False{}:
      (shape,known) = state
      L.clear_forced_clue_image_step(image,p,q,d,flag,
        L.copy_shape_proof(L.array_shape(L.image_board(image)),L.perfect_shape(7n),shape),known)

def L.clear_forced_clue(b,guess,p,q,d,flag,state):
  proof : (L.RoutedApart(L.flag_slot(p),q) -> L.FixedClue(b,q,d) ->
    L.FixedClue(Q.clear_forced(guess,b,p),q,d)) =
    L.on_reified_board(b,x => (L.RoutedApart(L.flag_slot(p),q) -> L.FixedClue(x,q,d) ->
      L.FixedClue(Q.clear_forced(guess,x,p),q,d)),L.reify_board(b),
      image => L.clear_forced_clue_image(image,guess,p,q,d))
  proof(flag,state)

def L.write_fixed_other_step(image,p,value,q,fixed,apart,shapes,known):
  (s0,s1) = shapes
  b = L.image_board(image)
  (L.board_set_keeps_perfect(L.image_board(image),p,value,7n,s0),
    Equal.trans(U32,L.cell_value(Board.set_cell(b,p,value),q),L.cell_value(b,q),L.fixed_word(fixed),
      L.perfect_write_keeps_cell(L.image_board(image),p,q,value,s1,apart),known))

def L.write_fixed_other_image(image,p,value,q,fixed,apart,state):
  (shape,known) = state
  L.write_fixed_other_step(image,p,value,q,fixed,apart,
    L.copy_shape_proof(L.array_shape(L.image_board(image)),L.perfect_shape(7n),shape),known)

def L.write_fixed_other(b,p,value,q,fixed,apart,state):
  proof : (L.RoutedApart(p,q) -> L.FixedClue(b,q,fixed) ->
    L.FixedClue(Board.set_cell(b,p,value),q,fixed)) =
    L.on_reified_board(b,x => (L.RoutedApart(p,q) -> L.FixedClue(x,q,fixed) ->
      L.FixedClue(Board.set_cell(x,p,value),q,fixed)),L.reify_board(b),
      image => L.write_fixed_other_image(image,p,value,q,fixed))
  proof(apart,state)

def L.place_peers_image(image,p,q,fixed,d,routes,state):
  (row,(col,(box,ptr))) = routes
  L.refresh_keeps_clue(L.place_boxes(L.image_board(image),p,d),p,q,fixed)(ptr,
    L.box_four_keeps_clue(L.place_columns(L.image_board(image),p,d),L.place_box_base(p),L.place_box_r1(p),L.place_box_r2(p),L.place_box_c1(p),L.place_box_c2(p),q,fixed,d,box,
      L.column_clue_line(9n,0,M.rem9(p),p,q,fixed,d,L.place_rows(L.image_board(image),p,d),col,
        L.row_clue_line(9n,0,L.place_row_base(p),p,q,fixed,d,L.image_board(image),row,state))))

def L.place_peers_keeps(b,p,q,fixed,d):
  L.on_reified_board(b,x => L.PlacePeersKeeps(x,p,q,fixed,d),
    L.reify_board(b),image => L.place_peers_image(image,p,q,fixed,d))

def L.place_keeps_clue_image(image,guess,p,q,fixed,d,apart,flag,routes,state):
  after_clear = Q.clear_forced(guess,L.image_board(image),p)
  after_write = Board.set_cell(Q.clear_forced(guess,L.image_board(image),p),p,L.fixed_word(d))
  L.place_peers_keeps(after_write,p,q,fixed,d)(routes,
    L.write_fixed_other(after_clear,p,L.fixed_word(d),q,fixed,apart,
      L.clear_forced_clue(L.image_board(image),guess,p,q,fixed,flag,state)))

def L.queued_place_keeps_clue(b,guess,p,q,fixed,d):
  L.on_reified_board(b,x => L.PlaceClueKeeps(x,guess,p,q,fixed,d),
    L.reify_board(b),image => L.place_keeps_clue_image(image,guess,p,q,fixed,d))

def L.cmp_is_eq_sound(c,yes):
  match c:
    case EQ{}:
      {==}
    case LT{}:
      Empty.absurd(L.IsEqCmp(LT{}),L.false_is_not_true(yes))
    case GT{}:
      Empty.absurd(L.IsEqCmp(GT{}),L.false_is_not_true(yes))

def L.word_cmp_fin_head_tail(tail,a,b,yes):
  match tail a b:
    case EQ{} True{} True{}:
      ({==},{==})
    case EQ{} False{} False{}:
      ({==},{==})
    case EQ{} True{} False{}:
      Empty.absurd(({True{} == False{} : Bool} & {EQ{} == EQ{} : Cmp}),
        L.false_is_not_true(Equal.cong(Cmp,Bool,c => Cmp.is_eq(c),GT{},EQ{},yes)))
    case EQ{} False{} True{}:
      Empty.absurd(({False{} == True{} : Bool} & {EQ{} == EQ{} : Cmp}),
        L.false_is_not_true(Equal.cong(Cmp,Bool,c => Cmp.is_eq(c),LT{},EQ{},yes)))
    case LT{} _ _:
      Empty.absurd(({a == b : Bool} & {LT{} == EQ{} : Cmp}),
        L.false_is_not_true(Equal.cong(Cmp,Bool,c => Cmp.is_eq(c),LT{},EQ{},yes)))
    case GT{} _ _:
      Empty.absurd(({a == b : Bool} & {GT{} == EQ{} : Cmp}),
        L.false_is_not_true(Equal.cong(Cmp,Bool,c => Cmp.is_eq(c),GT{},EQ{},yes)))

def L.word_cmp_fin_lift(n,a,b,left,right,pair,sub):
  (same,tail) = pair
  %Equal.sym(Bool,a,b,same) :
    {WCon{_,left} == WCon{b,right} : Word(1n+n)}
  Equal.cong(Word(n),Word(1n+n),t => WCon{b,t},left,right,sub(tail))

def L.word_cmp_equal(n,a,b,proof):
  match n a b:
    case 0n WNil{} WNil{}:
      {==}
    case 1n+k WCon{ab,at} WCon{bb,bt}:
      L.word_cmp_fin_lift(k,ab,bb,at,bt,L.word_cmp_fin_head_tail(Word.cmp(k,at,bt),ab,bb,proof),
        tail => L.word_cmp_equal(k,at,bt,tail))

def L.u32_equals_sound(a,b,yes):
  match a b:
    case U32{x} U32{y}:
      Equal.cong(Word(32n),U32,t => U32{t},x,y,
        L.word_cmp_equal(32n,x,y,L.cmp_is_eq_sound(Word.cmp(32n,x,y),yes)))

def L.row_entry_first(tail,i,j,both):
  (first,rest) = both
  first

def L.row_entry_tail(before,after,i,start,both,next):
  (first,rest) = both
  next(rest)

def L.row_entry_at(before,after,i,start,all):
  match before:
    case 0n:
      +start1 = (start + 1 : U32)
      L.row_entry_first(after,i,start,L.both_true(L.route_matrix_entry(i,start),L.logical_row(after,i,start1),all))
    case 1n+k:
      +start1 = (start + 1 : U32)
      L.row_entry_tail(k,after,i,start,L.both_true(L.route_matrix_entry(i,start),L.logical_row(L.with_center(k,after),i,start1),all),
        more => L.row_entry_at(k,after,i,start1,more))

def L.matrix_row_first(after,i,both):
  (first,rest) = both
  first

def L.matrix_row_tail(before,after,start,both,next):
  (first,rest) = both
  next(rest)

def L.matrix_row_at(before,after,start,all):
  match before:
    case 0n:
      +start1 = (start + 1 : U32)
      L.matrix_row_first(after,start,L.both_true(L.logical_row(81n,start,0),L.logical_rows(after,start1),all))
    case 1n+k:
      +start1 = (start + 1 : U32)
      L.matrix_row_tail(k,after,start,L.both_true(L.logical_row(81n,start,0),L.logical_rows(L.with_center(k,after),start1),all),
        more => L.matrix_row_at(k,after,start1,more))

def L.column_count_nine(col):
  match col:
    case L.Coordinate0{}:
      {==}
    case L.Coordinate1{}:
      {==}
    case L.Coordinate2{}:
      {==}
    case L.Coordinate3{}:
      {==}
    case L.Coordinate4{}:
      {==}
    case L.Coordinate5{}:
      {==}
    case L.Coordinate6{}:
      {==}
    case L.Coordinate7{}:
      {==}
    case L.Coordinate8{}:
      {==}

def L.matrix_row_checked(col,start,all):
  +before = L.coordinate_nat(col)
  +after = L.column_tail(col)
  proof : ({L.logical_rows(9n,start) == True{} : Bool} -> {L.logical_row(81n,L.walk_position(before,start),0) == True{} : Bool}) = (
    %L.column_count_nine(col) : ({L.logical_rows(_,start) == True{} : Bool} -> {L.logical_row(81n,L.walk_position(before,start),0) == True{} : Bool})
    evidence => L.matrix_row_at(before,after,start,evidence))
  proof(all)

def L.logical_origin(row,col):
  match row col:
    case L.Coordinate0{} L.Coordinate0{}:
      {==}
    case L.Coordinate0{} L.Coordinate1{}:
      {==}
    case L.Coordinate0{} L.Coordinate2{}:
      {==}
    case L.Coordinate0{} L.Coordinate3{}:
      {==}
    case L.Coordinate0{} L.Coordinate4{}:
      {==}
    case L.Coordinate0{} L.Coordinate5{}:
      {==}
    case L.Coordinate0{} L.Coordinate6{}:
      {==}
    case L.Coordinate0{} L.Coordinate7{}:
      {==}
    case L.Coordinate0{} L.Coordinate8{}:
      {==}
    case L.Coordinate1{} L.Coordinate0{}:
      {==}
    case L.Coordinate1{} L.Coordinate1{}:
      {==}
    case L.Coordinate1{} L.Coordinate2{}:
      {==}
    case L.Coordinate1{} L.Coordinate3{}:
      {==}
    case L.Coordinate1{} L.Coordinate4{}:
      {==}
    case L.Coordinate1{} L.Coordinate5{}:
      {==}
    case L.Coordinate1{} L.Coordinate6{}:
      {==}
    case L.Coordinate1{} L.Coordinate7{}:
      {==}
    case L.Coordinate1{} L.Coordinate8{}:
      {==}
    case L.Coordinate2{} L.Coordinate0{}:
      {==}
    case L.Coordinate2{} L.Coordinate1{}:
      {==}
    case L.Coordinate2{} L.Coordinate2{}:
      {==}
    case L.Coordinate2{} L.Coordinate3{}:
      {==}
    case L.Coordinate2{} L.Coordinate4{}:
      {==}
    case L.Coordinate2{} L.Coordinate5{}:
      {==}
    case L.Coordinate2{} L.Coordinate6{}:
      {==}
    case L.Coordinate2{} L.Coordinate7{}:
      {==}
    case L.Coordinate2{} L.Coordinate8{}:
      {==}
    case L.Coordinate3{} L.Coordinate0{}:
      {==}
    case L.Coordinate3{} L.Coordinate1{}:
      {==}
    case L.Coordinate3{} L.Coordinate2{}:
      {==}
    case L.Coordinate3{} L.Coordinate3{}:
      {==}
    case L.Coordinate3{} L.Coordinate4{}:
      {==}
    case L.Coordinate3{} L.Coordinate5{}:
      {==}
    case L.Coordinate3{} L.Coordinate6{}:
      {==}
    case L.Coordinate3{} L.Coordinate7{}:
      {==}
    case L.Coordinate3{} L.Coordinate8{}:
      {==}
    case L.Coordinate4{} L.Coordinate0{}:
      {==}
    case L.Coordinate4{} L.Coordinate1{}:
      {==}
    case L.Coordinate4{} L.Coordinate2{}:
      {==}
    case L.Coordinate4{} L.Coordinate3{}:
      {==}
    case L.Coordinate4{} L.Coordinate4{}:
      {==}
    case L.Coordinate4{} L.Coordinate5{}:
      {==}
    case L.Coordinate4{} L.Coordinate6{}:
      {==}
    case L.Coordinate4{} L.Coordinate7{}:
      {==}
    case L.Coordinate4{} L.Coordinate8{}:
      {==}
    case L.Coordinate5{} L.Coordinate0{}:
      {==}
    case L.Coordinate5{} L.Coordinate1{}:
      {==}
    case L.Coordinate5{} L.Coordinate2{}:
      {==}
    case L.Coordinate5{} L.Coordinate3{}:
      {==}
    case L.Coordinate5{} L.Coordinate4{}:
      {==}
    case L.Coordinate5{} L.Coordinate5{}:
      {==}
    case L.Coordinate5{} L.Coordinate6{}:
      {==}
    case L.Coordinate5{} L.Coordinate7{}:
      {==}
    case L.Coordinate5{} L.Coordinate8{}:
      {==}
    case L.Coordinate6{} L.Coordinate0{}:
      {==}
    case L.Coordinate6{} L.Coordinate1{}:
      {==}
    case L.Coordinate6{} L.Coordinate2{}:
      {==}
    case L.Coordinate6{} L.Coordinate3{}:
      {==}
    case L.Coordinate6{} L.Coordinate4{}:
      {==}
    case L.Coordinate6{} L.Coordinate5{}:
      {==}
    case L.Coordinate6{} L.Coordinate6{}:
      {==}
    case L.Coordinate6{} L.Coordinate7{}:
      {==}
    case L.Coordinate6{} L.Coordinate8{}:
      {==}
    case L.Coordinate7{} L.Coordinate0{}:
      {==}
    case L.Coordinate7{} L.Coordinate1{}:
      {==}
    case L.Coordinate7{} L.Coordinate2{}:
      {==}
    case L.Coordinate7{} L.Coordinate3{}:
      {==}
    case L.Coordinate7{} L.Coordinate4{}:
      {==}
    case L.Coordinate7{} L.Coordinate5{}:
      {==}
    case L.Coordinate7{} L.Coordinate6{}:
      {==}
    case L.Coordinate7{} L.Coordinate7{}:
      {==}
    case L.Coordinate7{} L.Coordinate8{}:
      {==}
    case L.Coordinate8{} L.Coordinate0{}:
      {==}
    case L.Coordinate8{} L.Coordinate1{}:
      {==}
    case L.Coordinate8{} L.Coordinate2{}:
      {==}
    case L.Coordinate8{} L.Coordinate3{}:
      {==}
    case L.Coordinate8{} L.Coordinate4{}:
      {==}
    case L.Coordinate8{} L.Coordinate5{}:
      {==}
    case L.Coordinate8{} L.Coordinate6{}:
      {==}
    case L.Coordinate8{} L.Coordinate7{}:
      {==}
    case L.Coordinate8{} L.Coordinate8{}:
      {==}

def L.matrix_start_guard(row):
  match row:
    case L.Coordinate0{}:
      L.logical_routes_00()
    case L.Coordinate1{}:
      L.logical_routes_09()
    case L.Coordinate2{}:
      L.logical_routes_18()
    case L.Coordinate3{}:
      L.logical_routes_27()
    case L.Coordinate4{}:
      L.logical_routes_36()
    case L.Coordinate5{}:
      L.logical_routes_45()
    case L.Coordinate6{}:
      L.logical_routes_54()
    case L.Coordinate7{}:
      L.logical_routes_63()
    case L.Coordinate8{}:
      L.logical_routes_72()

def L.matrix_logical_row(row,col):
  %L.logical_origin(row,col) : {L.logical_row(81n,_,0) == True{} : Bool}
  L.matrix_row_checked(col,L.row_origin(row),L.matrix_start_guard(row))

def L.matrix_logical_entry_checked(i,row,col,all,window):
  (guard,count) = window
  +before = L.logical_offset(row,col)
  +after = L.logical_tail(row,col)
  proof : ({L.logical_row(81n,i,0) == True{} : Bool} -> {L.route_matrix_entry(i,L.logical_position(row,col)) == True{} : Bool}) = (
    %count : ({L.logical_row(_,i,0) == True{} : Bool} -> {L.route_matrix_entry(i,L.logical_position(row,col)) == True{} : Bool})
    evidence => L.row_entry_at(before,after,i,0,evidence))
  proof(all)

def L.matrix_logical_entry(row1,col1,row2,col2):
  L.matrix_logical_entry_checked(L.logical_position(row1,col1),row2,col2,L.matrix_logical_row(row1,col1),L.every_cell_window(row2,col2))

def L.logical_address_row_0(col):
  match col:
    case L.Coordinate0{}:
      ({==},(Inl{{==}},({==},({==},({==},{==})))))
    case L.Coordinate1{}:
      ({==},(Inl{{==}},({==},({==},({==},{==})))))
    case L.Coordinate2{}:
      ({==},(Inl{{==}},({==},({==},({==},{==})))))
    case L.Coordinate3{}:
      ({==},(Inl{{==}},({==},({==},({==},{==})))))
    case L.Coordinate4{}:
      ({==},(Inl{{==}},({==},({==},({==},{==})))))
    case L.Coordinate5{}:
      ({==},(Inl{{==}},({==},({==},({==},{==})))))
    case L.Coordinate6{}:
      ({==},(Inl{{==}},({==},({==},({==},{==})))))
    case L.Coordinate7{}:
      ({==},(Inl{{==}},({==},({==},({==},{==})))))
    case L.Coordinate8{}:
      ({==},(Inl{{==}},({==},({==},({==},{==})))))

def L.logical_address_row_1(col):
  match col:
    case L.Coordinate0{}:
      ({==},(Inl{{==}},({==},({==},({==},{==})))))
    case L.Coordinate1{}:
      ({==},(Inl{{==}},({==},({==},({==},{==})))))
    case L.Coordinate2{}:
      ({==},(Inl{{==}},({==},({==},({==},{==})))))
    case L.Coordinate3{}:
      ({==},(Inl{{==}},({==},({==},({==},{==})))))
    case L.Coordinate4{}:
      ({==},(Inl{{==}},({==},({==},({==},{==})))))
    case L.Coordinate5{}:
      ({==},(Inl{{==}},({==},({==},({==},{==})))))
    case L.Coordinate6{}:
      ({==},(Inl{{==}},({==},({==},({==},{==})))))
    case L.Coordinate7{}:
      ({==},(Inl{{==}},({==},({==},({==},{==})))))
    case L.Coordinate8{}:
      ({==},(Inl{{==}},({==},({==},({==},{==})))))

def L.logical_address_row_2(col):
  match col:
    case L.Coordinate0{}:
      ({==},(Inl{{==}},({==},({==},({==},{==})))))
    case L.Coordinate1{}:
      ({==},(Inl{{==}},({==},({==},({==},{==})))))
    case L.Coordinate2{}:
      ({==},(Inl{{==}},({==},({==},({==},{==})))))
    case L.Coordinate3{}:
      ({==},(Inl{{==}},({==},({==},({==},{==})))))
    case L.Coordinate4{}:
      ({==},(Inl{{==}},({==},({==},({==},{==})))))
    case L.Coordinate5{}:
      ({==},(Inl{{==}},({==},({==},({==},{==})))))
    case L.Coordinate6{}:
      ({==},(Inl{{==}},({==},({==},({==},{==})))))
    case L.Coordinate7{}:
      ({==},(Inl{{==}},({==},({==},({==},{==})))))
    case L.Coordinate8{}:
      ({==},(Inl{{==}},({==},({==},({==},{==})))))

def L.logical_address_row_3(col):
  match col:
    case L.Coordinate0{}:
      ({==},(Inl{{==}},({==},({==},({==},{==})))))
    case L.Coordinate1{}:
      ({==},(Inl{{==}},({==},({==},({==},{==})))))
    case L.Coordinate2{}:
      ({==},(Inl{{==}},({==},({==},({==},{==})))))
    case L.Coordinate3{}:
      ({==},(Inl{{==}},({==},({==},({==},{==})))))
    case L.Coordinate4{}:
      ({==},(Inl{{==}},({==},({==},({==},{==})))))
    case L.Coordinate5{}:
      ({==},(Inr{Inl{{==}}},({==},({==},({==},{==})))))
    case L.Coordinate6{}:
      ({==},(Inr{Inl{{==}}},({==},({==},({==},{==})))))
    case L.Coordinate7{}:
      ({==},(Inr{Inl{{==}}},({==},({==},({==},{==})))))
    case L.Coordinate8{}:
      ({==},(Inr{Inl{{==}}},({==},({==},({==},{==})))))

def L.logical_address_row_4(col):
  match col:
    case L.Coordinate0{}:
      ({==},(Inr{Inl{{==}}},({==},({==},({==},{==})))))
    case L.Coordinate1{}:
      ({==},(Inr{Inl{{==}}},({==},({==},({==},{==})))))
    case L.Coordinate2{}:
      ({==},(Inr{Inl{{==}}},({==},({==},({==},{==})))))
    case L.Coordinate3{}:
      ({==},(Inr{Inl{{==}}},({==},({==},({==},{==})))))
    case L.Coordinate4{}:
      ({==},(Inr{Inl{{==}}},({==},({==},({==},{==})))))
    case L.Coordinate5{}:
      ({==},(Inr{Inl{{==}}},({==},({==},({==},{==})))))
    case L.Coordinate6{}:
      ({==},(Inr{Inl{{==}}},({==},({==},({==},{==})))))
    case L.Coordinate7{}:
      ({==},(Inr{Inl{{==}}},({==},({==},({==},{==})))))
    case L.Coordinate8{}:
      ({==},(Inr{Inl{{==}}},({==},({==},({==},{==})))))

def L.logical_address_row_5(col):
  match col:
    case L.Coordinate0{}:
      ({==},(Inr{Inl{{==}}},({==},({==},({==},{==})))))
    case L.Coordinate1{}:
      ({==},(Inr{Inl{{==}}},({==},({==},({==},{==})))))
    case L.Coordinate2{}:
      ({==},(Inr{Inl{{==}}},({==},({==},({==},{==})))))
    case L.Coordinate3{}:
      ({==},(Inr{Inl{{==}}},({==},({==},({==},{==})))))
    case L.Coordinate4{}:
      ({==},(Inr{Inl{{==}}},({==},({==},({==},{==})))))
    case L.Coordinate5{}:
      ({==},(Inr{Inl{{==}}},({==},({==},({==},{==})))))
    case L.Coordinate6{}:
      ({==},(Inr{Inl{{==}}},({==},({==},({==},{==})))))
    case L.Coordinate7{}:
      ({==},(Inr{Inl{{==}}},({==},({==},({==},{==})))))
    case L.Coordinate8{}:
      ({==},(Inr{Inl{{==}}},({==},({==},({==},{==})))))

def L.logical_address_row_6(col):
  match col:
    case L.Coordinate0{}:
      ({==},(Inr{Inl{{==}}},({==},({==},({==},{==})))))
    case L.Coordinate1{}:
      ({==},(Inr{Inl{{==}}},({==},({==},({==},{==})))))
    case L.Coordinate2{}:
      ({==},(Inr{Inl{{==}}},({==},({==},({==},{==})))))
    case L.Coordinate3{}:
      ({==},(Inr{Inl{{==}}},({==},({==},({==},{==})))))
    case L.Coordinate4{}:
      ({==},(Inr{Inl{{==}}},({==},({==},({==},{==})))))
    case L.Coordinate5{}:
      ({==},(Inr{Inl{{==}}},({==},({==},({==},{==})))))
    case L.Coordinate6{}:
      ({==},(Inr{Inl{{==}}},({==},({==},({==},{==})))))
    case L.Coordinate7{}:
      ({==},(Inr{Inl{{==}}},({==},({==},({==},{==})))))
    case L.Coordinate8{}:
      ({==},(Inr{Inl{{==}}},({==},({==},({==},{==})))))

def L.logical_address_row_7(col):
  match col:
    case L.Coordinate0{}:
      ({==},(Inr{Inl{{==}}},({==},({==},({==},{==})))))
    case L.Coordinate1{}:
      ({==},(Inr{Inr{{==}}},({==},({==},({==},{==})))))
    case L.Coordinate2{}:
      ({==},(Inr{Inr{{==}}},({==},({==},({==},{==})))))
    case L.Coordinate3{}:
      ({==},(Inr{Inr{{==}}},({==},({==},({==},{==})))))
    case L.Coordinate4{}:
      ({==},(Inr{Inr{{==}}},({==},({==},({==},{==})))))
    case L.Coordinate5{}:
      ({==},(Inr{Inr{{==}}},({==},({==},({==},{==})))))
    case L.Coordinate6{}:
      ({==},(Inr{Inr{{==}}},({==},({==},({==},{==})))))
    case L.Coordinate7{}:
      ({==},(Inr{Inr{{==}}},({==},({==},({==},{==})))))
    case L.Coordinate8{}:
      ({==},(Inr{Inr{{==}}},({==},({==},({==},{==})))))

def L.logical_address_row_8(col):
  match col:
    case L.Coordinate0{}:
      ({==},(Inr{Inr{{==}}},({==},({==},({==},{==})))))
    case L.Coordinate1{}:
      ({==},(Inr{Inr{{==}}},({==},({==},({==},{==})))))
    case L.Coordinate2{}:
      ({==},(Inr{Inr{{==}}},({==},({==},({==},{==})))))
    case L.Coordinate3{}:
      ({==},(Inr{Inr{{==}}},({==},({==},({==},{==})))))
    case L.Coordinate4{}:
      ({==},(Inr{Inr{{==}}},({==},({==},({==},{==})))))
    case L.Coordinate5{}:
      ({==},(Inr{Inr{{==}}},({==},({==},({==},{==})))))
    case L.Coordinate6{}:
      ({==},(Inr{Inr{{==}}},({==},({==},({==},{==})))))
    case L.Coordinate7{}:
      ({==},(Inr{Inr{{==}}},({==},({==},({==},{==})))))
    case L.Coordinate8{}:
      ({==},(Inr{Inr{{==}}},({==},({==},({==},{==})))))

def L.logical_address_facts(row,col):
  match row:
    case L.Coordinate0{}:
      L.logical_address_row_0(col)
    case L.Coordinate1{}:
      L.logical_address_row_1(col)
    case L.Coordinate2{}:
      L.logical_address_row_2(col)
    case L.Coordinate3{}:
      L.logical_address_row_3(col)
    case L.Coordinate4{}:
      L.logical_address_row_4(col)
    case L.Coordinate5{}:
      L.logical_address_row_5(col)
    case L.Coordinate6{}:
      L.logical_address_row_6(col)
    case L.Coordinate7{}:
      L.logical_address_row_7(col)
    case L.Coordinate8{}:
      L.logical_address_row_8(col)

def L.route_for_flag_choice(p,q,fact,a,b,c):
  match fact:
    case Inl{at109}:
      %Equal.sym(U32,L.flag_slot(p),109,at109) : L.RoutedApart(_,q)
      a
    case Inr{Inl{at110}}:
      %Equal.sym(U32,L.flag_slot(p),110,at110) : L.RoutedApart(_,q)
      b
    case Inr{Inr{at111}}:
      %Equal.sym(U32,L.flag_slot(p),111,at111) : L.RoutedApart(_,q)
      c

def L.flag_slot_peer_route(p,q,facts,slot):
  (norm,(flags,(ptr,(a,(b,c))))) = facts
  L.route_for_flag_choice(p,q,slot,a,b,c)

def L.extract_logical_flag_slot(p,facts):
  (norm,(flag,meta)) = facts
  flag

def L.any_logical_flag_route(row1,col1,row2,col2):
  L.flag_slot_peer_route(L.logical_position(row1,col1),L.logical_position(row2,col2),L.logical_address_facts(row2,col2),
    L.extract_logical_flag_slot(L.logical_position(row1,col1),L.logical_address_facts(row1,col1)))

def L.apart_from_raw(p,q,p_norm,q_norm,good):
  %Equal.sym(U32,L.normalized_route(p),p,p_norm) :
    {L.regular_routes(_,L.normalized_route(q)) == True{} : Bool}
  %Equal.sym(U32,L.normalized_route(q),q,q_norm) :
    {L.regular_routes(p,_) == True{} : Bool}
  good

def L.apart_from_logical_facts(p,q,pf,qf,good):
  (p_norm,p_rest) = pf
  (q_norm,q_rest) = qf
  L.apart_from_raw(p,q,p_norm,q_norm,good)

def L.pair_route_decide(p,q,same,equality,check,apart,flag):
  match same:
    case True{}:
      Inl{L.u32_equals_sound(p,q,equality)}
    case False{}:
      Inr{(apart(check),flag)}

def L.pair_route_checked(p,q,check,apart,flag):
  L.pair_route_decide(p,q,U32.is_eq(p,q),{==},check,apart,flag)

def L.logical_pair_peer_route(row1,col1,row2,col2):
  +p = L.logical_position(row1,col1)
  +q = L.logical_position(row2,col2)
  L.pair_route_checked(p,q,L.matrix_logical_entry(row1,col1,row2,col2),
    good => L.apart_from_logical_facts(p,q,L.logical_address_facts(row1,col1),L.logical_address_facts(row2,col2),good),
    L.any_logical_flag_route(row1,col1,row2,col2))

def L.row_routes_from_coordinates(source,wr,wc):
  match source:
    case L.Coordinate0{}:
      (L.logical_pair_peer_route(L.Coordinate0{},L.Coordinate0{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate0{},L.Coordinate1{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate0{},L.Coordinate2{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate0{},L.Coordinate3{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate0{},L.Coordinate4{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate0{},L.Coordinate5{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate0{},L.Coordinate6{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate0{},L.Coordinate7{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate0{},L.Coordinate8{},wr,wc),
        {==})))))))))
    case L.Coordinate1{}:
      (L.logical_pair_peer_route(L.Coordinate1{},L.Coordinate0{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate1{},L.Coordinate1{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate1{},L.Coordinate2{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate1{},L.Coordinate3{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate1{},L.Coordinate4{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate1{},L.Coordinate5{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate1{},L.Coordinate6{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate1{},L.Coordinate7{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate1{},L.Coordinate8{},wr,wc),
        {==})))))))))
    case L.Coordinate2{}:
      (L.logical_pair_peer_route(L.Coordinate2{},L.Coordinate0{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate2{},L.Coordinate1{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate2{},L.Coordinate2{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate2{},L.Coordinate3{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate2{},L.Coordinate4{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate2{},L.Coordinate5{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate2{},L.Coordinate6{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate2{},L.Coordinate7{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate2{},L.Coordinate8{},wr,wc),
        {==})))))))))
    case L.Coordinate3{}:
      (L.logical_pair_peer_route(L.Coordinate3{},L.Coordinate0{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate3{},L.Coordinate1{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate3{},L.Coordinate2{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate3{},L.Coordinate3{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate3{},L.Coordinate4{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate3{},L.Coordinate5{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate3{},L.Coordinate6{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate3{},L.Coordinate7{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate3{},L.Coordinate8{},wr,wc),
        {==})))))))))
    case L.Coordinate4{}:
      (L.logical_pair_peer_route(L.Coordinate4{},L.Coordinate0{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate4{},L.Coordinate1{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate4{},L.Coordinate2{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate4{},L.Coordinate3{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate4{},L.Coordinate4{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate4{},L.Coordinate5{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate4{},L.Coordinate6{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate4{},L.Coordinate7{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate4{},L.Coordinate8{},wr,wc),
        {==})))))))))
    case L.Coordinate5{}:
      (L.logical_pair_peer_route(L.Coordinate5{},L.Coordinate0{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate5{},L.Coordinate1{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate5{},L.Coordinate2{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate5{},L.Coordinate3{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate5{},L.Coordinate4{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate5{},L.Coordinate5{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate5{},L.Coordinate6{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate5{},L.Coordinate7{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate5{},L.Coordinate8{},wr,wc),
        {==})))))))))
    case L.Coordinate6{}:
      (L.logical_pair_peer_route(L.Coordinate6{},L.Coordinate0{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate6{},L.Coordinate1{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate6{},L.Coordinate2{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate6{},L.Coordinate3{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate6{},L.Coordinate4{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate6{},L.Coordinate5{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate6{},L.Coordinate6{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate6{},L.Coordinate7{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate6{},L.Coordinate8{},wr,wc),
        {==})))))))))
    case L.Coordinate7{}:
      (L.logical_pair_peer_route(L.Coordinate7{},L.Coordinate0{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate7{},L.Coordinate1{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate7{},L.Coordinate2{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate7{},L.Coordinate3{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate7{},L.Coordinate4{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate7{},L.Coordinate5{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate7{},L.Coordinate6{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate7{},L.Coordinate7{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate7{},L.Coordinate8{},wr,wc),
        {==})))))))))
    case L.Coordinate8{}:
      (L.logical_pair_peer_route(L.Coordinate8{},L.Coordinate0{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate8{},L.Coordinate1{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate8{},L.Coordinate2{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate8{},L.Coordinate3{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate8{},L.Coordinate4{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate8{},L.Coordinate5{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate8{},L.Coordinate6{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate8{},L.Coordinate7{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate8{},L.Coordinate8{},wr,wc),
        {==})))))))))

def L.column_routes_from_coordinates(source,wr,wc):
  match source:
    case L.Coordinate0{}:
      (L.logical_pair_peer_route(L.Coordinate0{},L.Coordinate0{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate1{},L.Coordinate0{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate2{},L.Coordinate0{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate3{},L.Coordinate0{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate4{},L.Coordinate0{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate5{},L.Coordinate0{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate6{},L.Coordinate0{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate7{},L.Coordinate0{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate8{},L.Coordinate0{},wr,wc),
        {==})))))))))
    case L.Coordinate1{}:
      (L.logical_pair_peer_route(L.Coordinate0{},L.Coordinate1{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate1{},L.Coordinate1{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate2{},L.Coordinate1{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate3{},L.Coordinate1{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate4{},L.Coordinate1{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate5{},L.Coordinate1{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate6{},L.Coordinate1{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate7{},L.Coordinate1{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate8{},L.Coordinate1{},wr,wc),
        {==})))))))))
    case L.Coordinate2{}:
      (L.logical_pair_peer_route(L.Coordinate0{},L.Coordinate2{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate1{},L.Coordinate2{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate2{},L.Coordinate2{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate3{},L.Coordinate2{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate4{},L.Coordinate2{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate5{},L.Coordinate2{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate6{},L.Coordinate2{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate7{},L.Coordinate2{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate8{},L.Coordinate2{},wr,wc),
        {==})))))))))
    case L.Coordinate3{}:
      (L.logical_pair_peer_route(L.Coordinate0{},L.Coordinate3{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate1{},L.Coordinate3{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate2{},L.Coordinate3{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate3{},L.Coordinate3{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate4{},L.Coordinate3{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate5{},L.Coordinate3{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate6{},L.Coordinate3{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate7{},L.Coordinate3{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate8{},L.Coordinate3{},wr,wc),
        {==})))))))))
    case L.Coordinate4{}:
      (L.logical_pair_peer_route(L.Coordinate0{},L.Coordinate4{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate1{},L.Coordinate4{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate2{},L.Coordinate4{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate3{},L.Coordinate4{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate4{},L.Coordinate4{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate5{},L.Coordinate4{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate6{},L.Coordinate4{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate7{},L.Coordinate4{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate8{},L.Coordinate4{},wr,wc),
        {==})))))))))
    case L.Coordinate5{}:
      (L.logical_pair_peer_route(L.Coordinate0{},L.Coordinate5{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate1{},L.Coordinate5{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate2{},L.Coordinate5{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate3{},L.Coordinate5{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate4{},L.Coordinate5{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate5{},L.Coordinate5{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate6{},L.Coordinate5{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate7{},L.Coordinate5{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate8{},L.Coordinate5{},wr,wc),
        {==})))))))))
    case L.Coordinate6{}:
      (L.logical_pair_peer_route(L.Coordinate0{},L.Coordinate6{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate1{},L.Coordinate6{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate2{},L.Coordinate6{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate3{},L.Coordinate6{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate4{},L.Coordinate6{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate5{},L.Coordinate6{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate6{},L.Coordinate6{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate7{},L.Coordinate6{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate8{},L.Coordinate6{},wr,wc),
        {==})))))))))
    case L.Coordinate7{}:
      (L.logical_pair_peer_route(L.Coordinate0{},L.Coordinate7{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate1{},L.Coordinate7{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate2{},L.Coordinate7{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate3{},L.Coordinate7{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate4{},L.Coordinate7{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate5{},L.Coordinate7{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate6{},L.Coordinate7{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate7{},L.Coordinate7{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate8{},L.Coordinate7{},wr,wc),
        {==})))))))))
    case L.Coordinate8{}:
      (L.logical_pair_peer_route(L.Coordinate0{},L.Coordinate8{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate1{},L.Coordinate8{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate2{},L.Coordinate8{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate3{},L.Coordinate8{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate4{},L.Coordinate8{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate5{},L.Coordinate8{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate6{},L.Coordinate8{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate7{},L.Coordinate8{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate8{},L.Coordinate8{},wr,wc),
        {==})))))))))

def L.source_place_geometry(row,col):
  match row col:
    case L.Coordinate0{} L.Coordinate0{}:
      ({==},{==})
    case L.Coordinate0{} L.Coordinate1{}:
      ({==},{==})
    case L.Coordinate0{} L.Coordinate2{}:
      ({==},{==})
    case L.Coordinate0{} L.Coordinate3{}:
      ({==},{==})
    case L.Coordinate0{} L.Coordinate4{}:
      ({==},{==})
    case L.Coordinate0{} L.Coordinate5{}:
      ({==},{==})
    case L.Coordinate0{} L.Coordinate6{}:
      ({==},{==})
    case L.Coordinate0{} L.Coordinate7{}:
      ({==},{==})
    case L.Coordinate0{} L.Coordinate8{}:
      ({==},{==})
    case L.Coordinate1{} L.Coordinate0{}:
      ({==},{==})
    case L.Coordinate1{} L.Coordinate1{}:
      ({==},{==})
    case L.Coordinate1{} L.Coordinate2{}:
      ({==},{==})
    case L.Coordinate1{} L.Coordinate3{}:
      ({==},{==})
    case L.Coordinate1{} L.Coordinate4{}:
      ({==},{==})
    case L.Coordinate1{} L.Coordinate5{}:
      ({==},{==})
    case L.Coordinate1{} L.Coordinate6{}:
      ({==},{==})
    case L.Coordinate1{} L.Coordinate7{}:
      ({==},{==})
    case L.Coordinate1{} L.Coordinate8{}:
      ({==},{==})
    case L.Coordinate2{} L.Coordinate0{}:
      ({==},{==})
    case L.Coordinate2{} L.Coordinate1{}:
      ({==},{==})
    case L.Coordinate2{} L.Coordinate2{}:
      ({==},{==})
    case L.Coordinate2{} L.Coordinate3{}:
      ({==},{==})
    case L.Coordinate2{} L.Coordinate4{}:
      ({==},{==})
    case L.Coordinate2{} L.Coordinate5{}:
      ({==},{==})
    case L.Coordinate2{} L.Coordinate6{}:
      ({==},{==})
    case L.Coordinate2{} L.Coordinate7{}:
      ({==},{==})
    case L.Coordinate2{} L.Coordinate8{}:
      ({==},{==})
    case L.Coordinate3{} L.Coordinate0{}:
      ({==},{==})
    case L.Coordinate3{} L.Coordinate1{}:
      ({==},{==})
    case L.Coordinate3{} L.Coordinate2{}:
      ({==},{==})
    case L.Coordinate3{} L.Coordinate3{}:
      ({==},{==})
    case L.Coordinate3{} L.Coordinate4{}:
      ({==},{==})
    case L.Coordinate3{} L.Coordinate5{}:
      ({==},{==})
    case L.Coordinate3{} L.Coordinate6{}:
      ({==},{==})
    case L.Coordinate3{} L.Coordinate7{}:
      ({==},{==})
    case L.Coordinate3{} L.Coordinate8{}:
      ({==},{==})
    case L.Coordinate4{} L.Coordinate0{}:
      ({==},{==})
    case L.Coordinate4{} L.Coordinate1{}:
      ({==},{==})
    case L.Coordinate4{} L.Coordinate2{}:
      ({==},{==})
    case L.Coordinate4{} L.Coordinate3{}:
      ({==},{==})
    case L.Coordinate4{} L.Coordinate4{}:
      ({==},{==})
    case L.Coordinate4{} L.Coordinate5{}:
      ({==},{==})
    case L.Coordinate4{} L.Coordinate6{}:
      ({==},{==})
    case L.Coordinate4{} L.Coordinate7{}:
      ({==},{==})
    case L.Coordinate4{} L.Coordinate8{}:
      ({==},{==})
    case L.Coordinate5{} L.Coordinate0{}:
      ({==},{==})
    case L.Coordinate5{} L.Coordinate1{}:
      ({==},{==})
    case L.Coordinate5{} L.Coordinate2{}:
      ({==},{==})
    case L.Coordinate5{} L.Coordinate3{}:
      ({==},{==})
    case L.Coordinate5{} L.Coordinate4{}:
      ({==},{==})
    case L.Coordinate5{} L.Coordinate5{}:
      ({==},{==})
    case L.Coordinate5{} L.Coordinate6{}:
      ({==},{==})
    case L.Coordinate5{} L.Coordinate7{}:
      ({==},{==})
    case L.Coordinate5{} L.Coordinate8{}:
      ({==},{==})
    case L.Coordinate6{} L.Coordinate0{}:
      ({==},{==})
    case L.Coordinate6{} L.Coordinate1{}:
      ({==},{==})
    case L.Coordinate6{} L.Coordinate2{}:
      ({==},{==})
    case L.Coordinate6{} L.Coordinate3{}:
      ({==},{==})
    case L.Coordinate6{} L.Coordinate4{}:
      ({==},{==})
    case L.Coordinate6{} L.Coordinate5{}:
      ({==},{==})
    case L.Coordinate6{} L.Coordinate6{}:
      ({==},{==})
    case L.Coordinate6{} L.Coordinate7{}:
      ({==},{==})
    case L.Coordinate6{} L.Coordinate8{}:
      ({==},{==})
    case L.Coordinate7{} L.Coordinate0{}:
      ({==},{==})
    case L.Coordinate7{} L.Coordinate1{}:
      ({==},{==})
    case L.Coordinate7{} L.Coordinate2{}:
      ({==},{==})
    case L.Coordinate7{} L.Coordinate3{}:
      ({==},{==})
    case L.Coordinate7{} L.Coordinate4{}:
      ({==},{==})
    case L.Coordinate7{} L.Coordinate5{}:
      ({==},{==})
    case L.Coordinate7{} L.Coordinate6{}:
      ({==},{==})
    case L.Coordinate7{} L.Coordinate7{}:
      ({==},{==})
    case L.Coordinate7{} L.Coordinate8{}:
      ({==},{==})
    case L.Coordinate8{} L.Coordinate0{}:
      ({==},{==})
    case L.Coordinate8{} L.Coordinate1{}:
      ({==},{==})
    case L.Coordinate8{} L.Coordinate2{}:
      ({==},{==})
    case L.Coordinate8{} L.Coordinate3{}:
      ({==},{==})
    case L.Coordinate8{} L.Coordinate4{}:
      ({==},{==})
    case L.Coordinate8{} L.Coordinate5{}:
      ({==},{==})
    case L.Coordinate8{} L.Coordinate6{}:
      ({==},{==})
    case L.Coordinate8{} L.Coordinate7{}:
      ({==},{==})
    case L.Coordinate8{} L.Coordinate8{}:
      ({==},{==})

def L.box_routes_from_coordinates(sr,sc,wr,wc):
  match sr sc:
    case L.Coordinate0{} L.Coordinate0{}:
      (L.logical_pair_peer_route(L.Coordinate1{},L.Coordinate1{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate1{},L.Coordinate2{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate2{},L.Coordinate1{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate2{},L.Coordinate2{},wr,wc),
        {==}))))
    case L.Coordinate0{} L.Coordinate1{}:
      (L.logical_pair_peer_route(L.Coordinate1{},L.Coordinate2{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate1{},L.Coordinate0{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate2{},L.Coordinate2{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate2{},L.Coordinate0{},wr,wc),
        {==}))))
    case L.Coordinate0{} L.Coordinate2{}:
      (L.logical_pair_peer_route(L.Coordinate1{},L.Coordinate0{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate1{},L.Coordinate1{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate2{},L.Coordinate0{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate2{},L.Coordinate1{},wr,wc),
        {==}))))
    case L.Coordinate0{} L.Coordinate3{}:
      (L.logical_pair_peer_route(L.Coordinate1{},L.Coordinate4{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate1{},L.Coordinate5{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate2{},L.Coordinate4{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate2{},L.Coordinate5{},wr,wc),
        {==}))))
    case L.Coordinate0{} L.Coordinate4{}:
      (L.logical_pair_peer_route(L.Coordinate1{},L.Coordinate5{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate1{},L.Coordinate3{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate2{},L.Coordinate5{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate2{},L.Coordinate3{},wr,wc),
        {==}))))
    case L.Coordinate0{} L.Coordinate5{}:
      (L.logical_pair_peer_route(L.Coordinate1{},L.Coordinate3{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate1{},L.Coordinate4{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate2{},L.Coordinate3{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate2{},L.Coordinate4{},wr,wc),
        {==}))))
    case L.Coordinate0{} L.Coordinate6{}:
      (L.logical_pair_peer_route(L.Coordinate1{},L.Coordinate7{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate1{},L.Coordinate8{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate2{},L.Coordinate7{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate2{},L.Coordinate8{},wr,wc),
        {==}))))
    case L.Coordinate0{} L.Coordinate7{}:
      (L.logical_pair_peer_route(L.Coordinate1{},L.Coordinate8{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate1{},L.Coordinate6{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate2{},L.Coordinate8{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate2{},L.Coordinate6{},wr,wc),
        {==}))))
    case L.Coordinate0{} L.Coordinate8{}:
      (L.logical_pair_peer_route(L.Coordinate1{},L.Coordinate6{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate1{},L.Coordinate7{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate2{},L.Coordinate6{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate2{},L.Coordinate7{},wr,wc),
        {==}))))
    case L.Coordinate1{} L.Coordinate0{}:
      (L.logical_pair_peer_route(L.Coordinate2{},L.Coordinate1{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate2{},L.Coordinate2{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate0{},L.Coordinate1{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate0{},L.Coordinate2{},wr,wc),
        {==}))))
    case L.Coordinate1{} L.Coordinate1{}:
      (L.logical_pair_peer_route(L.Coordinate2{},L.Coordinate2{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate2{},L.Coordinate0{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate0{},L.Coordinate2{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate0{},L.Coordinate0{},wr,wc),
        {==}))))
    case L.Coordinate1{} L.Coordinate2{}:
      (L.logical_pair_peer_route(L.Coordinate2{},L.Coordinate0{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate2{},L.Coordinate1{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate0{},L.Coordinate0{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate0{},L.Coordinate1{},wr,wc),
        {==}))))
    case L.Coordinate1{} L.Coordinate3{}:
      (L.logical_pair_peer_route(L.Coordinate2{},L.Coordinate4{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate2{},L.Coordinate5{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate0{},L.Coordinate4{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate0{},L.Coordinate5{},wr,wc),
        {==}))))
    case L.Coordinate1{} L.Coordinate4{}:
      (L.logical_pair_peer_route(L.Coordinate2{},L.Coordinate5{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate2{},L.Coordinate3{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate0{},L.Coordinate5{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate0{},L.Coordinate3{},wr,wc),
        {==}))))
    case L.Coordinate1{} L.Coordinate5{}:
      (L.logical_pair_peer_route(L.Coordinate2{},L.Coordinate3{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate2{},L.Coordinate4{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate0{},L.Coordinate3{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate0{},L.Coordinate4{},wr,wc),
        {==}))))
    case L.Coordinate1{} L.Coordinate6{}:
      (L.logical_pair_peer_route(L.Coordinate2{},L.Coordinate7{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate2{},L.Coordinate8{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate0{},L.Coordinate7{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate0{},L.Coordinate8{},wr,wc),
        {==}))))
    case L.Coordinate1{} L.Coordinate7{}:
      (L.logical_pair_peer_route(L.Coordinate2{},L.Coordinate8{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate2{},L.Coordinate6{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate0{},L.Coordinate8{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate0{},L.Coordinate6{},wr,wc),
        {==}))))
    case L.Coordinate1{} L.Coordinate8{}:
      (L.logical_pair_peer_route(L.Coordinate2{},L.Coordinate6{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate2{},L.Coordinate7{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate0{},L.Coordinate6{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate0{},L.Coordinate7{},wr,wc),
        {==}))))
    case L.Coordinate2{} L.Coordinate0{}:
      (L.logical_pair_peer_route(L.Coordinate0{},L.Coordinate1{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate0{},L.Coordinate2{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate1{},L.Coordinate1{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate1{},L.Coordinate2{},wr,wc),
        {==}))))
    case L.Coordinate2{} L.Coordinate1{}:
      (L.logical_pair_peer_route(L.Coordinate0{},L.Coordinate2{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate0{},L.Coordinate0{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate1{},L.Coordinate2{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate1{},L.Coordinate0{},wr,wc),
        {==}))))
    case L.Coordinate2{} L.Coordinate2{}:
      (L.logical_pair_peer_route(L.Coordinate0{},L.Coordinate0{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate0{},L.Coordinate1{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate1{},L.Coordinate0{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate1{},L.Coordinate1{},wr,wc),
        {==}))))
    case L.Coordinate2{} L.Coordinate3{}:
      (L.logical_pair_peer_route(L.Coordinate0{},L.Coordinate4{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate0{},L.Coordinate5{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate1{},L.Coordinate4{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate1{},L.Coordinate5{},wr,wc),
        {==}))))
    case L.Coordinate2{} L.Coordinate4{}:
      (L.logical_pair_peer_route(L.Coordinate0{},L.Coordinate5{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate0{},L.Coordinate3{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate1{},L.Coordinate5{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate1{},L.Coordinate3{},wr,wc),
        {==}))))
    case L.Coordinate2{} L.Coordinate5{}:
      (L.logical_pair_peer_route(L.Coordinate0{},L.Coordinate3{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate0{},L.Coordinate4{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate1{},L.Coordinate3{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate1{},L.Coordinate4{},wr,wc),
        {==}))))
    case L.Coordinate2{} L.Coordinate6{}:
      (L.logical_pair_peer_route(L.Coordinate0{},L.Coordinate7{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate0{},L.Coordinate8{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate1{},L.Coordinate7{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate1{},L.Coordinate8{},wr,wc),
        {==}))))
    case L.Coordinate2{} L.Coordinate7{}:
      (L.logical_pair_peer_route(L.Coordinate0{},L.Coordinate8{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate0{},L.Coordinate6{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate1{},L.Coordinate8{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate1{},L.Coordinate6{},wr,wc),
        {==}))))
    case L.Coordinate2{} L.Coordinate8{}:
      (L.logical_pair_peer_route(L.Coordinate0{},L.Coordinate6{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate0{},L.Coordinate7{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate1{},L.Coordinate6{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate1{},L.Coordinate7{},wr,wc),
        {==}))))
    case L.Coordinate3{} L.Coordinate0{}:
      (L.logical_pair_peer_route(L.Coordinate4{},L.Coordinate1{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate4{},L.Coordinate2{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate5{},L.Coordinate1{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate5{},L.Coordinate2{},wr,wc),
        {==}))))
    case L.Coordinate3{} L.Coordinate1{}:
      (L.logical_pair_peer_route(L.Coordinate4{},L.Coordinate2{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate4{},L.Coordinate0{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate5{},L.Coordinate2{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate5{},L.Coordinate0{},wr,wc),
        {==}))))
    case L.Coordinate3{} L.Coordinate2{}:
      (L.logical_pair_peer_route(L.Coordinate4{},L.Coordinate0{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate4{},L.Coordinate1{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate5{},L.Coordinate0{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate5{},L.Coordinate1{},wr,wc),
        {==}))))
    case L.Coordinate3{} L.Coordinate3{}:
      (L.logical_pair_peer_route(L.Coordinate4{},L.Coordinate4{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate4{},L.Coordinate5{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate5{},L.Coordinate4{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate5{},L.Coordinate5{},wr,wc),
        {==}))))
    case L.Coordinate3{} L.Coordinate4{}:
      (L.logical_pair_peer_route(L.Coordinate4{},L.Coordinate5{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate4{},L.Coordinate3{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate5{},L.Coordinate5{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate5{},L.Coordinate3{},wr,wc),
        {==}))))
    case L.Coordinate3{} L.Coordinate5{}:
      (L.logical_pair_peer_route(L.Coordinate4{},L.Coordinate3{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate4{},L.Coordinate4{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate5{},L.Coordinate3{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate5{},L.Coordinate4{},wr,wc),
        {==}))))
    case L.Coordinate3{} L.Coordinate6{}:
      (L.logical_pair_peer_route(L.Coordinate4{},L.Coordinate7{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate4{},L.Coordinate8{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate5{},L.Coordinate7{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate5{},L.Coordinate8{},wr,wc),
        {==}))))
    case L.Coordinate3{} L.Coordinate7{}:
      (L.logical_pair_peer_route(L.Coordinate4{},L.Coordinate8{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate4{},L.Coordinate6{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate5{},L.Coordinate8{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate5{},L.Coordinate6{},wr,wc),
        {==}))))
    case L.Coordinate3{} L.Coordinate8{}:
      (L.logical_pair_peer_route(L.Coordinate4{},L.Coordinate6{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate4{},L.Coordinate7{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate5{},L.Coordinate6{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate5{},L.Coordinate7{},wr,wc),
        {==}))))
    case L.Coordinate4{} L.Coordinate0{}:
      (L.logical_pair_peer_route(L.Coordinate5{},L.Coordinate1{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate5{},L.Coordinate2{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate3{},L.Coordinate1{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate3{},L.Coordinate2{},wr,wc),
        {==}))))
    case L.Coordinate4{} L.Coordinate1{}:
      (L.logical_pair_peer_route(L.Coordinate5{},L.Coordinate2{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate5{},L.Coordinate0{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate3{},L.Coordinate2{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate3{},L.Coordinate0{},wr,wc),
        {==}))))
    case L.Coordinate4{} L.Coordinate2{}:
      (L.logical_pair_peer_route(L.Coordinate5{},L.Coordinate0{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate5{},L.Coordinate1{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate3{},L.Coordinate0{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate3{},L.Coordinate1{},wr,wc),
        {==}))))
    case L.Coordinate4{} L.Coordinate3{}:
      (L.logical_pair_peer_route(L.Coordinate5{},L.Coordinate4{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate5{},L.Coordinate5{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate3{},L.Coordinate4{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate3{},L.Coordinate5{},wr,wc),
        {==}))))
    case L.Coordinate4{} L.Coordinate4{}:
      (L.logical_pair_peer_route(L.Coordinate5{},L.Coordinate5{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate5{},L.Coordinate3{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate3{},L.Coordinate5{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate3{},L.Coordinate3{},wr,wc),
        {==}))))
    case L.Coordinate4{} L.Coordinate5{}:
      (L.logical_pair_peer_route(L.Coordinate5{},L.Coordinate3{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate5{},L.Coordinate4{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate3{},L.Coordinate3{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate3{},L.Coordinate4{},wr,wc),
        {==}))))
    case L.Coordinate4{} L.Coordinate6{}:
      (L.logical_pair_peer_route(L.Coordinate5{},L.Coordinate7{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate5{},L.Coordinate8{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate3{},L.Coordinate7{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate3{},L.Coordinate8{},wr,wc),
        {==}))))
    case L.Coordinate4{} L.Coordinate7{}:
      (L.logical_pair_peer_route(L.Coordinate5{},L.Coordinate8{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate5{},L.Coordinate6{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate3{},L.Coordinate8{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate3{},L.Coordinate6{},wr,wc),
        {==}))))
    case L.Coordinate4{} L.Coordinate8{}:
      (L.logical_pair_peer_route(L.Coordinate5{},L.Coordinate6{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate5{},L.Coordinate7{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate3{},L.Coordinate6{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate3{},L.Coordinate7{},wr,wc),
        {==}))))
    case L.Coordinate5{} L.Coordinate0{}:
      (L.logical_pair_peer_route(L.Coordinate3{},L.Coordinate1{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate3{},L.Coordinate2{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate4{},L.Coordinate1{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate4{},L.Coordinate2{},wr,wc),
        {==}))))
    case L.Coordinate5{} L.Coordinate1{}:
      (L.logical_pair_peer_route(L.Coordinate3{},L.Coordinate2{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate3{},L.Coordinate0{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate4{},L.Coordinate2{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate4{},L.Coordinate0{},wr,wc),
        {==}))))
    case L.Coordinate5{} L.Coordinate2{}:
      (L.logical_pair_peer_route(L.Coordinate3{},L.Coordinate0{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate3{},L.Coordinate1{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate4{},L.Coordinate0{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate4{},L.Coordinate1{},wr,wc),
        {==}))))
    case L.Coordinate5{} L.Coordinate3{}:
      (L.logical_pair_peer_route(L.Coordinate3{},L.Coordinate4{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate3{},L.Coordinate5{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate4{},L.Coordinate4{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate4{},L.Coordinate5{},wr,wc),
        {==}))))
    case L.Coordinate5{} L.Coordinate4{}:
      (L.logical_pair_peer_route(L.Coordinate3{},L.Coordinate5{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate3{},L.Coordinate3{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate4{},L.Coordinate5{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate4{},L.Coordinate3{},wr,wc),
        {==}))))
    case L.Coordinate5{} L.Coordinate5{}:
      (L.logical_pair_peer_route(L.Coordinate3{},L.Coordinate3{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate3{},L.Coordinate4{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate4{},L.Coordinate3{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate4{},L.Coordinate4{},wr,wc),
        {==}))))
    case L.Coordinate5{} L.Coordinate6{}:
      (L.logical_pair_peer_route(L.Coordinate3{},L.Coordinate7{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate3{},L.Coordinate8{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate4{},L.Coordinate7{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate4{},L.Coordinate8{},wr,wc),
        {==}))))
    case L.Coordinate5{} L.Coordinate7{}:
      (L.logical_pair_peer_route(L.Coordinate3{},L.Coordinate8{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate3{},L.Coordinate6{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate4{},L.Coordinate8{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate4{},L.Coordinate6{},wr,wc),
        {==}))))
    case L.Coordinate5{} L.Coordinate8{}:
      (L.logical_pair_peer_route(L.Coordinate3{},L.Coordinate6{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate3{},L.Coordinate7{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate4{},L.Coordinate6{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate4{},L.Coordinate7{},wr,wc),
        {==}))))
    case L.Coordinate6{} L.Coordinate0{}:
      (L.logical_pair_peer_route(L.Coordinate7{},L.Coordinate1{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate7{},L.Coordinate2{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate8{},L.Coordinate1{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate8{},L.Coordinate2{},wr,wc),
        {==}))))
    case L.Coordinate6{} L.Coordinate1{}:
      (L.logical_pair_peer_route(L.Coordinate7{},L.Coordinate2{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate7{},L.Coordinate0{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate8{},L.Coordinate2{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate8{},L.Coordinate0{},wr,wc),
        {==}))))
    case L.Coordinate6{} L.Coordinate2{}:
      (L.logical_pair_peer_route(L.Coordinate7{},L.Coordinate0{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate7{},L.Coordinate1{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate8{},L.Coordinate0{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate8{},L.Coordinate1{},wr,wc),
        {==}))))
    case L.Coordinate6{} L.Coordinate3{}:
      (L.logical_pair_peer_route(L.Coordinate7{},L.Coordinate4{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate7{},L.Coordinate5{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate8{},L.Coordinate4{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate8{},L.Coordinate5{},wr,wc),
        {==}))))
    case L.Coordinate6{} L.Coordinate4{}:
      (L.logical_pair_peer_route(L.Coordinate7{},L.Coordinate5{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate7{},L.Coordinate3{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate8{},L.Coordinate5{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate8{},L.Coordinate3{},wr,wc),
        {==}))))
    case L.Coordinate6{} L.Coordinate5{}:
      (L.logical_pair_peer_route(L.Coordinate7{},L.Coordinate3{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate7{},L.Coordinate4{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate8{},L.Coordinate3{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate8{},L.Coordinate4{},wr,wc),
        {==}))))
    case L.Coordinate6{} L.Coordinate6{}:
      (L.logical_pair_peer_route(L.Coordinate7{},L.Coordinate7{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate7{},L.Coordinate8{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate8{},L.Coordinate7{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate8{},L.Coordinate8{},wr,wc),
        {==}))))
    case L.Coordinate6{} L.Coordinate7{}:
      (L.logical_pair_peer_route(L.Coordinate7{},L.Coordinate8{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate7{},L.Coordinate6{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate8{},L.Coordinate8{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate8{},L.Coordinate6{},wr,wc),
        {==}))))
    case L.Coordinate6{} L.Coordinate8{}:
      (L.logical_pair_peer_route(L.Coordinate7{},L.Coordinate6{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate7{},L.Coordinate7{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate8{},L.Coordinate6{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate8{},L.Coordinate7{},wr,wc),
        {==}))))
    case L.Coordinate7{} L.Coordinate0{}:
      (L.logical_pair_peer_route(L.Coordinate8{},L.Coordinate1{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate8{},L.Coordinate2{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate6{},L.Coordinate1{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate6{},L.Coordinate2{},wr,wc),
        {==}))))
    case L.Coordinate7{} L.Coordinate1{}:
      (L.logical_pair_peer_route(L.Coordinate8{},L.Coordinate2{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate8{},L.Coordinate0{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate6{},L.Coordinate2{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate6{},L.Coordinate0{},wr,wc),
        {==}))))
    case L.Coordinate7{} L.Coordinate2{}:
      (L.logical_pair_peer_route(L.Coordinate8{},L.Coordinate0{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate8{},L.Coordinate1{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate6{},L.Coordinate0{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate6{},L.Coordinate1{},wr,wc),
        {==}))))
    case L.Coordinate7{} L.Coordinate3{}:
      (L.logical_pair_peer_route(L.Coordinate8{},L.Coordinate4{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate8{},L.Coordinate5{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate6{},L.Coordinate4{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate6{},L.Coordinate5{},wr,wc),
        {==}))))
    case L.Coordinate7{} L.Coordinate4{}:
      (L.logical_pair_peer_route(L.Coordinate8{},L.Coordinate5{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate8{},L.Coordinate3{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate6{},L.Coordinate5{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate6{},L.Coordinate3{},wr,wc),
        {==}))))
    case L.Coordinate7{} L.Coordinate5{}:
      (L.logical_pair_peer_route(L.Coordinate8{},L.Coordinate3{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate8{},L.Coordinate4{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate6{},L.Coordinate3{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate6{},L.Coordinate4{},wr,wc),
        {==}))))
    case L.Coordinate7{} L.Coordinate6{}:
      (L.logical_pair_peer_route(L.Coordinate8{},L.Coordinate7{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate8{},L.Coordinate8{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate6{},L.Coordinate7{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate6{},L.Coordinate8{},wr,wc),
        {==}))))
    case L.Coordinate7{} L.Coordinate7{}:
      (L.logical_pair_peer_route(L.Coordinate8{},L.Coordinate8{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate8{},L.Coordinate6{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate6{},L.Coordinate8{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate6{},L.Coordinate6{},wr,wc),
        {==}))))
    case L.Coordinate7{} L.Coordinate8{}:
      (L.logical_pair_peer_route(L.Coordinate8{},L.Coordinate6{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate8{},L.Coordinate7{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate6{},L.Coordinate6{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate6{},L.Coordinate7{},wr,wc),
        {==}))))
    case L.Coordinate8{} L.Coordinate0{}:
      (L.logical_pair_peer_route(L.Coordinate6{},L.Coordinate1{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate6{},L.Coordinate2{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate7{},L.Coordinate1{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate7{},L.Coordinate2{},wr,wc),
        {==}))))
    case L.Coordinate8{} L.Coordinate1{}:
      (L.logical_pair_peer_route(L.Coordinate6{},L.Coordinate2{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate6{},L.Coordinate0{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate7{},L.Coordinate2{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate7{},L.Coordinate0{},wr,wc),
        {==}))))
    case L.Coordinate8{} L.Coordinate2{}:
      (L.logical_pair_peer_route(L.Coordinate6{},L.Coordinate0{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate6{},L.Coordinate1{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate7{},L.Coordinate0{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate7{},L.Coordinate1{},wr,wc),
        {==}))))
    case L.Coordinate8{} L.Coordinate3{}:
      (L.logical_pair_peer_route(L.Coordinate6{},L.Coordinate4{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate6{},L.Coordinate5{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate7{},L.Coordinate4{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate7{},L.Coordinate5{},wr,wc),
        {==}))))
    case L.Coordinate8{} L.Coordinate4{}:
      (L.logical_pair_peer_route(L.Coordinate6{},L.Coordinate5{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate6{},L.Coordinate3{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate7{},L.Coordinate5{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate7{},L.Coordinate3{},wr,wc),
        {==}))))
    case L.Coordinate8{} L.Coordinate5{}:
      (L.logical_pair_peer_route(L.Coordinate6{},L.Coordinate3{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate6{},L.Coordinate4{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate7{},L.Coordinate3{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate7{},L.Coordinate4{},wr,wc),
        {==}))))
    case L.Coordinate8{} L.Coordinate6{}:
      (L.logical_pair_peer_route(L.Coordinate6{},L.Coordinate7{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate6{},L.Coordinate8{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate7{},L.Coordinate7{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate7{},L.Coordinate8{},wr,wc),
        {==}))))
    case L.Coordinate8{} L.Coordinate7{}:
      (L.logical_pair_peer_route(L.Coordinate6{},L.Coordinate8{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate6{},L.Coordinate6{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate7{},L.Coordinate8{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate7{},L.Coordinate6{},wr,wc),
        {==}))))
    case L.Coordinate8{} L.Coordinate8{}:
      (L.logical_pair_peer_route(L.Coordinate6{},L.Coordinate6{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate6{},L.Coordinate7{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate7{},L.Coordinate6{},wr,wc),
        (L.logical_pair_peer_route(L.Coordinate7{},L.Coordinate7{},wr,wc),
        {==}))))

def L.pointer_route_from_logical(p,facts):
  (norm,(slot,(ptr,rest))) = facts
  ptr

def L.placement_routes_from_geometry(sr,sc,wr,wc,geometry):
  (row_eq,col_eq) = geometry
  +p = L.logical_position(sr,sc)
  +q = L.logical_position(wr,wc)
  %Equal.sym(U32,L.place_row_base(p),L.row_origin(sr),row_eq) :
    (L.RowClueRoutes(9n,0,_,q) & L.ColumnClueRoutes(9n,0,M.rem9(p),q)
     & L.PeerListRoutes(L.placed_box_positions(p),q) & L.RoutedApart(108,q))
  %Equal.sym(U32,M.rem9(p),L.coord_u32(sc),col_eq) :
    (L.RowClueRoutes(9n,0,L.row_origin(sr),q) & L.ColumnClueRoutes(9n,0,_,q)
     & L.PeerListRoutes(L.placed_box_positions(p),q) & L.RoutedApart(108,q))
  (L.row_routes_from_coordinates(sr,wr,wc),
    (L.column_routes_from_coordinates(sc,wr,wc),
      (L.box_routes_from_coordinates(sr,sc,wr,wc), L.pointer_route_from_logical(q,L.logical_address_facts(wr,wc)))))

def L.placement_routes_from_coordinates(sr,sc,wr,wc):
  L.placement_routes_from_geometry(sr,sc,wr,wc,L.source_place_geometry(sr,sc))

def L.logical_distinct_apart(p,q,distinct,checked,pf,qf):
  proof : ({L.route_matrix_entry(p,q) == True{} : Bool} -> L.RoutedApart(p,q)) = (
    %Equal.sym(Bool,U32.is_eq(p,q),False{},distinct) :
      ({Bool.pick(Bool,_,Bool.not(L.regular_routes(p,q)),L.regular_routes(p,q)) == True{} : Bool} -> L.RoutedApart(p,q))
    valid => L.apart_from_logical_facts(p,q,pf,qf,valid))
  proof(checked)

def L.logical_placement_keeps_other_clue(b,guess,sr,sc,wr,wc,fixed,digit,distinct,state):
  +p = L.logical_position(sr,sc)
  +q = L.logical_position(wr,wc)
  L.queued_place_keeps_clue(b,guess,p,q,fixed,digit)(
    L.logical_distinct_apart(p,q,distinct,L.matrix_logical_entry(sr,sc,wr,wc),
      L.logical_address_facts(sr,sc),L.logical_address_facts(wr,wc)),
    L.any_logical_flag_route(sr,sc,wr,wc),
    L.placement_routes_from_coordinates(sr,sc,wr,wc),state)

def L.fixed_clue_word(b,p,d,inherited):
  (shape,word) = inherited
  word

def L.adaptive_active_forced_place_keeps_clue(b,frames,depth,found,snapshots,sr,sc,qr,qc,fixed,digit,distinct,state):
  +p = L.logical_position(sr,sc)
  +q = L.logical_position(qr,qc)
  L.fixed_clue_word(Q.place(False{},p,L.digit_word(digit),b),q,fixed,
    L.logical_placement_keeps_other_clue(b,False{},sr,sc,qr,qc,fixed,digit,distinct,state))

def L.plain_write_step(image,p,value,q,clue,apart,shapes,known):
  (s0,s1) = shapes
  b = L.image_board(image)
  (L.board_set_keeps_perfect(L.image_board(image),p,value,7n,s0),
    Equal.trans(U32,L.cell_value(Board.set_cell(b,p,value),q),L.cell_value(b,q),clue,
      L.perfect_write_keeps_cell(L.image_board(image),p,q,value,s1,apart),known))

def L.plain_write_image(image,p,value,q,clue,apart,state):
  (shape,known) = state
  L.plain_write_step(image,p,value,q,clue,apart,L.copy_shape_proof(L.array_shape(L.image_board(image)),L.perfect_shape(7n),shape),known)

def L.plain_write(b,p,value,q,clue,apart,state):
  proof : (L.RoutedApart(p,q) -> L.PlainWord(b,q,clue) -> L.PlainWord(Board.set_cell(b,p,value),q,clue)) =
    L.on_reified_board(b,x => (L.RoutedApart(p,q) -> L.PlainWord(x,q,clue) -> L.PlainWord(Board.set_cell(x,p,value),q,clue)),
      L.reify_board(b),image => L.plain_write_image(image,p,value,q,clue))
  proof(apart,state)

def L.plain_one_write(b,out,slot,q,clue,apart,state,write):
  (+value,eq) = write
  %Equal.sym(Array<U32>,out,Board.set_cell(b,slot,value),eq) :
    L.PlainWord(_,q,clue)
  L.plain_write(b,slot,value,q,clue,apart,state)

def L.ordinary_unit_single_from_read(b,slot,old,value,same,used,kept,actual):
  %Equal.sym(Array<U32> & U32,Board.get_cell(b,slot),(same,used),actual) :
    L.OneWrite(b,C.update_done(slot,old,value,_),slot)
  %Equal.sym(Array<U32>,same,b,kept) :
    L.OneWrite(b,C.update_done(slot,old,value,(_,used)),slot)
  (L.ordinary_unit_word(old,value,used),{==})

def L.ordinary_unit_single(b,slot,old,value,read):
  (same,+used,(kept,actual)) = read
  L.ordinary_unit_single_from_read(b,slot,old,value,same,used,kept,actual)

def L.ordinary_row_single_from_read(b,p,old,value,same,used,kept,actual):
  +slot = L.ordinary_row_slot(p)
  +empty = L.ordinary_empty_bit(p)
  %Equal.sym(Array<U32> & U32,Board.get_cell(b,slot),(same,used),actual) :
    L.OneWrite(b,C.row_updated(slot,old,value,empty,_),slot)
  %Equal.sym(Array<U32>,same,b,kept) :
    L.OneWrite(b,C.row_updated(slot,old,value,empty,(_,used)),slot)
  (L.ordinary_row_word(old,value,empty,used),{==})

def L.ordinary_row_single(b,p,old,value,read):
  (same,+used,(kept,actual)) = read
  L.ordinary_row_single_from_read(b,p,old,value,same,used,kept,actual)

def L.ordinary_unit_keeps_image(image,slot,old,value,q,clue,apart,state):
  L.plain_one_write(L.image_board(image),C.update_unit(slot,old,value,L.image_board(image)),slot,q,clue,apart,state,
    L.ordinary_unit_single(L.image_board(image),slot,old,value,L.board_read_witness(L.image_board(image),slot)))

def L.ordinary_unit_keeps(b,slot,old,value,q,clue):
  L.on_reified_board(b,x => L.MetaUpdatesKeeps(x,C.update_unit(slot,old,value,x),slot,q,clue),
    L.reify_board(b),image => L.ordinary_unit_keeps_image(image,slot,old,value,q,clue))

def L.ordinary_row_keeps_image(image,p,old,value,q,clue,apart,state):
  +slot = L.ordinary_row_slot(p)
  L.plain_one_write(L.image_board(image),C.update_row(p,old,value,L.image_board(image)),slot,q,clue,apart,state,
    L.ordinary_row_single(L.image_board(image),p,old,value,L.board_read_witness(L.image_board(image),slot)))

def L.ordinary_row_keeps(b,p,old,value,q,clue):
  L.on_reified_board(b,x => L.MetaUpdatesKeeps(x,C.update_row(p,old,value,x),L.ordinary_row_slot(p),q,clue),
    L.reify_board(b),image => L.ordinary_row_keeps_image(image,p,old,value,q,clue))

def L.plain_first_observed(n,p,b,same,word,kept,observed,next):
  %Equal.sym(Array<U32> & U32,Board.get_cell(b,p),(same,word),observed) :
    L.FirstOnlyWritesPointer(b,C.first_empty(n,p,_))
  %kept :
    L.FirstOnlyWritesPointer(_,C.first_empty(n,p,(same,word)))
  next(same,word)

def L.plain_first_from_read(n,p,b,read,next):
  (same,+word,(kept,observed)) = read
  L.plain_first_observed(n,p,b,same,word,kept,observed,next)

def L.plain_first_branch(word,n,p,b,later):
  match word:
    case U32{WCon{True{}, rest}}:
      later
    case U32{WCon{False{}, WCon{True{}, rest}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      (p,{==})

def L.plain_first_live(n,p,b,word,next):
  +at = (p + 1 : U32)
  L.plain_first_branch(word,n,p,b,L.plain_first_from_read(n,at,b,L.board_read_witness(b,at),next))

def L.plain_first_pointer(n,p,b,word):
  match n:
    case 0n:
      (81,{==})
    case 1n+k:
      L.plain_first_live(k,p,b,word,sub => d => L.plain_first_pointer(k,(p + 1 : U32),sub,d))

def L.ordinary_refresh_pointer(b,p):
  +n = U32.to_nat((81 - p : U32))
  L.plain_first_from_read(n,p,b,L.board_read_witness(b,p),sub => word => L.plain_first_pointer(n,p,sub,word))

def L.plain_pointer_keeps(b,out,q,clue,apart,state,write):
  (+value,eq) = write
  %Equal.sym(Array<U32>,out,Board.set_cell(b,108,value),eq) :
    L.PlainWord(_,q,clue)
  L.plain_write(b,108,value,q,clue,apart,state)

def L.ordinary_refresh_keeps_image(image,which,p,q,clue,apart,state):
  match which:
    case False{}:
      state
    case True{}:
      L.plain_pointer_keeps(L.image_board(image),C.refresh_start(L.image_board(image),p),q,clue,apart,state,
        L.ordinary_refresh_pointer(L.image_board(image),p))

def L.ordinary_refresh_keeps(b,which,p,q,clue):
  L.on_reified_board(b,x => L.OrdinaryRefreshKeeps(x,which,p,q,clue),
    L.reify_board(b),image => L.ordinary_refresh_keeps_image(image,which,p,q,clue))

def L.ordinary_start_pair_keeps(blank,b,p,start,q,clue,apart,state):
  match blank:
    case True{}:
      L.plain_write(b,108,U32.min(start,p),q,clue,apart,state)
    case False{}:
      L.ordinary_refresh_keeps(b,U32.is_eq(p,start),start,q,clue)(apart,state)

def L.ordinary_start_keeps_observed(blank,b,p,q,clue,same,start,kept,read,apart,state):
  %Equal.sym(Array<U32> & U32,Board.get_cell(b,108),(same,start),read) :
    L.PlainWord(C.start_after_set(blank,p,_),q,clue)
  %Equal.sym(Array<U32>,same,b,kept) :
    L.PlainWord(C.start_after_set(blank,p,(_,start)),q,clue)
  L.ordinary_start_pair_keeps(blank,b,p,start,q,clue,apart,state)

def L.ordinary_start_keeps_read(blank,b,p,q,clue,read,apart,state):
  (same,+start,(kept,observed)) = read
  L.ordinary_start_keeps_observed(blank,b,p,q,clue,same,start,kept,observed,apart,state)

def L.ordinary_start_keeps_image(image,blank,p,q,clue,apart,state):
  L.ordinary_start_keeps_read(blank,L.image_board(image),p,q,clue,L.board_read_witness(L.image_board(image),108),apart,state)

def L.ordinary_start_keeps(b,blank,p,q,clue):
  L.on_reified_board(b,x => L.PlainStartKeeps(x,blank,p,q,clue),
    L.reify_board(b),image => L.ordinary_start_keeps_image(image,blank,p,q,clue))

def L.ordinary_after_write_image(image,p,old,value,q,clue,routes,state):
  (row,(col,(box,ptr))) = routes
  L.ordinary_start_keeps(L.ordinary_from_box(L.image_board(image),p,old,value),U32.is_eq(value,0),p,q,clue)(ptr,
    L.ordinary_unit_keeps(L.ordinary_from_col(L.image_board(image),p,old,value),L.ordinary_box_slot(p),old,value,q,clue)(box,
      L.ordinary_unit_keeps(L.ordinary_from_row(L.image_board(image),p,old,value),L.ordinary_col_slot(p),old,value,q,clue)(col,
        L.ordinary_row_keeps(L.image_board(image),p,old,value,q,clue)(row,state))))

def L.ordinary_after_write_keeps(b,p,old,value,q,clue):
  L.on_reified_board(b,x => L.OrdinaryAfterWriteKeeps(x,p,old,value,q,clue),
    L.reify_board(b),image => L.ordinary_after_write_image(image,p,old,value,q,clue))

def L.ordinary_swapped_keeps(p,value,q,clue,edited,routes,state):
  (b,+old) = edited
  L.ordinary_after_write_keeps(b,p,old,value,q,clue)(routes,state)

def L.swap_pair_first_is_set_fin(r):
  (b,word) = r
  {==}

def L.use_swap_pair_first(r,q,clue,eq,settled):
  %Equal.sym(Array<U32>,Pair.fst(Array<U32>,U32,r),Array.set.fin(U32,r),eq) :
    L.PlainWord(_,q,clue)
  settled

def L.ordinary_swap_keeps_image(image,p,value,q,clue,apart,routes,state):
  L.ordinary_swapped_keeps(p,value,q,clue,Array.swap(U32,L.image_board(image),p,value),routes,
    L.use_swap_pair_first(Array.swap(U32,L.image_board(image),p,value),q,clue,
      L.swap_pair_first_is_set_fin(Array.swap(U32,L.image_board(image),p,value)),
      L.plain_write(L.image_board(image),p,value,q,clue,apart,state)))

def L.ordinary_swap_keeps(b,p,value,q,clue):
  L.on_reified_board(b,x => L.OrdinarySwapKeeps(x,p,value,q,clue),
    L.reify_board(b),image => L.ordinary_swap_keeps_image(image,p,value,q,clue))

def L.meta_guard_first(n,p,q,both):
  (here,tail) = both
  here

def L.meta_guard_tail(before,after,p,q,both,next):
  (here,tail) = both
  next(tail)

def L.meta_guard_at(before,after,p,q,guard):
  match before:
    case 0n:
      L.meta_guard_first(after,p,q,L.both_true(L.apart_guard(p,q),L.meta_guard(after,(p + 1 : U32),q),guard))
    case 1n+k:
      +next = (p + 1 : U32)
      L.meta_guard_tail(k,after,p,q,L.both_true(L.apart_guard(p,q),L.meta_guard(L.with_center(k,after),next,q),guard),
        more => L.meta_guard_at(k,after,next,q,more))

def L.cache_meta_at(group,index,q,guard):
  +p = L.cache_group_base(group)
  +before = L.coordinate_nat(index)
  +after = L.column_tail(index)
  proof : ({L.meta_guard(9n,p,q) == True{} : Bool} -> L.RoutedApart(L.cache_group_slot(group,index),q)) = (
    %L.column_count_nine(index) :
      ({L.meta_guard(_,p,q) == True{} : Bool} -> L.RoutedApart(L.cache_group_slot(group,index),q))
    valid => L.meta_guard_at(before,after,p,q,valid))
  proof(guard)

def L.cache_meta_facts_row_0(col):
  match col:
    case L.Coordinate0{}:
      ({==},({==},{==}))
    case L.Coordinate1{}:
      ({==},({==},{==}))
    case L.Coordinate2{}:
      ({==},({==},{==}))
    case L.Coordinate3{}:
      ({==},({==},{==}))
    case L.Coordinate4{}:
      ({==},({==},{==}))
    case L.Coordinate5{}:
      ({==},({==},{==}))
    case L.Coordinate6{}:
      ({==},({==},{==}))
    case L.Coordinate7{}:
      ({==},({==},{==}))
    case L.Coordinate8{}:
      ({==},({==},{==}))

def L.cache_meta_facts_row_1(col):
  match col:
    case L.Coordinate0{}:
      ({==},({==},{==}))
    case L.Coordinate1{}:
      ({==},({==},{==}))
    case L.Coordinate2{}:
      ({==},({==},{==}))
    case L.Coordinate3{}:
      ({==},({==},{==}))
    case L.Coordinate4{}:
      ({==},({==},{==}))
    case L.Coordinate5{}:
      ({==},({==},{==}))
    case L.Coordinate6{}:
      ({==},({==},{==}))
    case L.Coordinate7{}:
      ({==},({==},{==}))
    case L.Coordinate8{}:
      ({==},({==},{==}))

def L.cache_meta_facts_row_2(col):
  match col:
    case L.Coordinate0{}:
      ({==},({==},{==}))
    case L.Coordinate1{}:
      ({==},({==},{==}))
    case L.Coordinate2{}:
      ({==},({==},{==}))
    case L.Coordinate3{}:
      ({==},({==},{==}))
    case L.Coordinate4{}:
      ({==},({==},{==}))
    case L.Coordinate5{}:
      ({==},({==},{==}))
    case L.Coordinate6{}:
      ({==},({==},{==}))
    case L.Coordinate7{}:
      ({==},({==},{==}))
    case L.Coordinate8{}:
      ({==},({==},{==}))

def L.cache_meta_facts_row_3(col):
  match col:
    case L.Coordinate0{}:
      ({==},({==},{==}))
    case L.Coordinate1{}:
      ({==},({==},{==}))
    case L.Coordinate2{}:
      ({==},({==},{==}))
    case L.Coordinate3{}:
      ({==},({==},{==}))
    case L.Coordinate4{}:
      ({==},({==},{==}))
    case L.Coordinate5{}:
      ({==},({==},{==}))
    case L.Coordinate6{}:
      ({==},({==},{==}))
    case L.Coordinate7{}:
      ({==},({==},{==}))
    case L.Coordinate8{}:
      ({==},({==},{==}))

def L.cache_meta_facts_row_4(col):
  match col:
    case L.Coordinate0{}:
      ({==},({==},{==}))
    case L.Coordinate1{}:
      ({==},({==},{==}))
    case L.Coordinate2{}:
      ({==},({==},{==}))
    case L.Coordinate3{}:
      ({==},({==},{==}))
    case L.Coordinate4{}:
      ({==},({==},{==}))
    case L.Coordinate5{}:
      ({==},({==},{==}))
    case L.Coordinate6{}:
      ({==},({==},{==}))
    case L.Coordinate7{}:
      ({==},({==},{==}))
    case L.Coordinate8{}:
      ({==},({==},{==}))

def L.cache_meta_facts_row_5(col):
  match col:
    case L.Coordinate0{}:
      ({==},({==},{==}))
    case L.Coordinate1{}:
      ({==},({==},{==}))
    case L.Coordinate2{}:
      ({==},({==},{==}))
    case L.Coordinate3{}:
      ({==},({==},{==}))
    case L.Coordinate4{}:
      ({==},({==},{==}))
    case L.Coordinate5{}:
      ({==},({==},{==}))
    case L.Coordinate6{}:
      ({==},({==},{==}))
    case L.Coordinate7{}:
      ({==},({==},{==}))
    case L.Coordinate8{}:
      ({==},({==},{==}))

def L.cache_meta_facts_row_6(col):
  match col:
    case L.Coordinate0{}:
      ({==},({==},{==}))
    case L.Coordinate1{}:
      ({==},({==},{==}))
    case L.Coordinate2{}:
      ({==},({==},{==}))
    case L.Coordinate3{}:
      ({==},({==},{==}))
    case L.Coordinate4{}:
      ({==},({==},{==}))
    case L.Coordinate5{}:
      ({==},({==},{==}))
    case L.Coordinate6{}:
      ({==},({==},{==}))
    case L.Coordinate7{}:
      ({==},({==},{==}))
    case L.Coordinate8{}:
      ({==},({==},{==}))

def L.cache_meta_facts_row_7(col):
  match col:
    case L.Coordinate0{}:
      ({==},({==},{==}))
    case L.Coordinate1{}:
      ({==},({==},{==}))
    case L.Coordinate2{}:
      ({==},({==},{==}))
    case L.Coordinate3{}:
      ({==},({==},{==}))
    case L.Coordinate4{}:
      ({==},({==},{==}))
    case L.Coordinate5{}:
      ({==},({==},{==}))
    case L.Coordinate6{}:
      ({==},({==},{==}))
    case L.Coordinate7{}:
      ({==},({==},{==}))
    case L.Coordinate8{}:
      ({==},({==},{==}))

def L.cache_meta_facts_row_8(col):
  match col:
    case L.Coordinate0{}:
      ({==},({==},{==}))
    case L.Coordinate1{}:
      ({==},({==},{==}))
    case L.Coordinate2{}:
      ({==},({==},{==}))
    case L.Coordinate3{}:
      ({==},({==},{==}))
    case L.Coordinate4{}:
      ({==},({==},{==}))
    case L.Coordinate5{}:
      ({==},({==},{==}))
    case L.Coordinate6{}:
      ({==},({==},{==}))
    case L.Coordinate7{}:
      ({==},({==},{==}))
    case L.Coordinate8{}:
      ({==},({==},{==}))

def L.cache_meta_facts(row,col):
  match row:
    case L.Coordinate0{}:
      L.cache_meta_facts_row_0(col)
    case L.Coordinate1{}:
      L.cache_meta_facts_row_1(col)
    case L.Coordinate2{}:
      L.cache_meta_facts_row_2(col)
    case L.Coordinate3{}:
      L.cache_meta_facts_row_3(col)
    case L.Coordinate4{}:
      L.cache_meta_facts_row_4(col)
    case L.Coordinate5{}:
      L.cache_meta_facts_row_5(col)
    case L.Coordinate6{}:
      L.cache_meta_facts_row_6(col)
    case L.Coordinate7{}:
      L.cache_meta_facts_row_7(col)
    case L.Coordinate8{}:
      L.cache_meta_facts_row_8(col)

def L.checked_ordinary_geometry(row,col):
  match row col:
    case L.Coordinate0{} L.Coordinate0{}:
      ({==},({==},{==}))
    case L.Coordinate0{} L.Coordinate1{}:
      ({==},({==},{==}))
    case L.Coordinate0{} L.Coordinate2{}:
      ({==},({==},{==}))
    case L.Coordinate0{} L.Coordinate3{}:
      ({==},({==},{==}))
    case L.Coordinate0{} L.Coordinate4{}:
      ({==},({==},{==}))
    case L.Coordinate0{} L.Coordinate5{}:
      ({==},({==},{==}))
    case L.Coordinate0{} L.Coordinate6{}:
      ({==},({==},{==}))
    case L.Coordinate0{} L.Coordinate7{}:
      ({==},({==},{==}))
    case L.Coordinate0{} L.Coordinate8{}:
      ({==},({==},{==}))
    case L.Coordinate1{} L.Coordinate0{}:
      ({==},({==},{==}))
    case L.Coordinate1{} L.Coordinate1{}:
      ({==},({==},{==}))
    case L.Coordinate1{} L.Coordinate2{}:
      ({==},({==},{==}))
    case L.Coordinate1{} L.Coordinate3{}:
      ({==},({==},{==}))
    case L.Coordinate1{} L.Coordinate4{}:
      ({==},({==},{==}))
    case L.Coordinate1{} L.Coordinate5{}:
      ({==},({==},{==}))
    case L.Coordinate1{} L.Coordinate6{}:
      ({==},({==},{==}))
    case L.Coordinate1{} L.Coordinate7{}:
      ({==},({==},{==}))
    case L.Coordinate1{} L.Coordinate8{}:
      ({==},({==},{==}))
    case L.Coordinate2{} L.Coordinate0{}:
      ({==},({==},{==}))
    case L.Coordinate2{} L.Coordinate1{}:
      ({==},({==},{==}))
    case L.Coordinate2{} L.Coordinate2{}:
      ({==},({==},{==}))
    case L.Coordinate2{} L.Coordinate3{}:
      ({==},({==},{==}))
    case L.Coordinate2{} L.Coordinate4{}:
      ({==},({==},{==}))
    case L.Coordinate2{} L.Coordinate5{}:
      ({==},({==},{==}))
    case L.Coordinate2{} L.Coordinate6{}:
      ({==},({==},{==}))
    case L.Coordinate2{} L.Coordinate7{}:
      ({==},({==},{==}))
    case L.Coordinate2{} L.Coordinate8{}:
      ({==},({==},{==}))
    case L.Coordinate3{} L.Coordinate0{}:
      ({==},({==},{==}))
    case L.Coordinate3{} L.Coordinate1{}:
      ({==},({==},{==}))
    case L.Coordinate3{} L.Coordinate2{}:
      ({==},({==},{==}))
    case L.Coordinate3{} L.Coordinate3{}:
      ({==},({==},{==}))
    case L.Coordinate3{} L.Coordinate4{}:
      ({==},({==},{==}))
    case L.Coordinate3{} L.Coordinate5{}:
      ({==},({==},{==}))
    case L.Coordinate3{} L.Coordinate6{}:
      ({==},({==},{==}))
    case L.Coordinate3{} L.Coordinate7{}:
      ({==},({==},{==}))
    case L.Coordinate3{} L.Coordinate8{}:
      ({==},({==},{==}))
    case L.Coordinate4{} L.Coordinate0{}:
      ({==},({==},{==}))
    case L.Coordinate4{} L.Coordinate1{}:
      ({==},({==},{==}))
    case L.Coordinate4{} L.Coordinate2{}:
      ({==},({==},{==}))
    case L.Coordinate4{} L.Coordinate3{}:
      ({==},({==},{==}))
    case L.Coordinate4{} L.Coordinate4{}:
      ({==},({==},{==}))
    case L.Coordinate4{} L.Coordinate5{}:
      ({==},({==},{==}))
    case L.Coordinate4{} L.Coordinate6{}:
      ({==},({==},{==}))
    case L.Coordinate4{} L.Coordinate7{}:
      ({==},({==},{==}))
    case L.Coordinate4{} L.Coordinate8{}:
      ({==},({==},{==}))
    case L.Coordinate5{} L.Coordinate0{}:
      ({==},({==},{==}))
    case L.Coordinate5{} L.Coordinate1{}:
      ({==},({==},{==}))
    case L.Coordinate5{} L.Coordinate2{}:
      ({==},({==},{==}))
    case L.Coordinate5{} L.Coordinate3{}:
      ({==},({==},{==}))
    case L.Coordinate5{} L.Coordinate4{}:
      ({==},({==},{==}))
    case L.Coordinate5{} L.Coordinate5{}:
      ({==},({==},{==}))
    case L.Coordinate5{} L.Coordinate6{}:
      ({==},({==},{==}))
    case L.Coordinate5{} L.Coordinate7{}:
      ({==},({==},{==}))
    case L.Coordinate5{} L.Coordinate8{}:
      ({==},({==},{==}))
    case L.Coordinate6{} L.Coordinate0{}:
      ({==},({==},{==}))
    case L.Coordinate6{} L.Coordinate1{}:
      ({==},({==},{==}))
    case L.Coordinate6{} L.Coordinate2{}:
      ({==},({==},{==}))
    case L.Coordinate6{} L.Coordinate3{}:
      ({==},({==},{==}))
    case L.Coordinate6{} L.Coordinate4{}:
      ({==},({==},{==}))
    case L.Coordinate6{} L.Coordinate5{}:
      ({==},({==},{==}))
    case L.Coordinate6{} L.Coordinate6{}:
      ({==},({==},{==}))
    case L.Coordinate6{} L.Coordinate7{}:
      ({==},({==},{==}))
    case L.Coordinate6{} L.Coordinate8{}:
      ({==},({==},{==}))
    case L.Coordinate7{} L.Coordinate0{}:
      ({==},({==},{==}))
    case L.Coordinate7{} L.Coordinate1{}:
      ({==},({==},{==}))
    case L.Coordinate7{} L.Coordinate2{}:
      ({==},({==},{==}))
    case L.Coordinate7{} L.Coordinate3{}:
      ({==},({==},{==}))
    case L.Coordinate7{} L.Coordinate4{}:
      ({==},({==},{==}))
    case L.Coordinate7{} L.Coordinate5{}:
      ({==},({==},{==}))
    case L.Coordinate7{} L.Coordinate6{}:
      ({==},({==},{==}))
    case L.Coordinate7{} L.Coordinate7{}:
      ({==},({==},{==}))
    case L.Coordinate7{} L.Coordinate8{}:
      ({==},({==},{==}))
    case L.Coordinate8{} L.Coordinate0{}:
      ({==},({==},{==}))
    case L.Coordinate8{} L.Coordinate1{}:
      ({==},({==},{==}))
    case L.Coordinate8{} L.Coordinate2{}:
      ({==},({==},{==}))
    case L.Coordinate8{} L.Coordinate3{}:
      ({==},({==},{==}))
    case L.Coordinate8{} L.Coordinate4{}:
      ({==},({==},{==}))
    case L.Coordinate8{} L.Coordinate5{}:
      ({==},({==},{==}))
    case L.Coordinate8{} L.Coordinate6{}:
      ({==},({==},{==}))
    case L.Coordinate8{} L.Coordinate7{}:
      ({==},({==},{==}))
    case L.Coordinate8{} L.Coordinate8{}:
      ({==},({==},{==}))

def L.ordinary_routes_from_geometry(sr,sc,qr,qc,geometry,facts):
  (row_eq,(col_eq,box_eq)) = geometry
  (row,(col,box)) = facts
  +p = L.logical_position(sr,sc)
  +q = L.logical_position(qr,qc)
  +rs = L.cache_group_slot(L.CacheRows{},sr)
  +cs = L.cache_group_slot(L.CacheColumns{},sc)
  +bs = L.cache_group_slot(L.CacheBoxes{},L.box_coordinate(sr,sc))
  %Equal.sym(U32,L.ordinary_row_slot(p),rs,row_eq) :
    (L.RoutedApart(_,q) & L.RoutedApart(L.ordinary_col_slot(p),q) & L.RoutedApart(L.ordinary_box_slot(p),q) & L.RoutedApart(108,q))
  %Equal.sym(U32,L.ordinary_col_slot(p),cs,col_eq) :
    (L.RoutedApart(rs,q) & L.RoutedApart(_,q) & L.RoutedApart(L.ordinary_box_slot(p),q) & L.RoutedApart(108,q))
  %Equal.sym(U32,L.ordinary_box_slot(p),bs,box_eq) :
    (L.RoutedApart(rs,q) & L.RoutedApart(cs,q) & L.RoutedApart(_,q) & L.RoutedApart(108,q))
  (L.cache_meta_at(L.CacheRows{},sr,q,row),(L.cache_meta_at(L.CacheColumns{},sc,q,col),
    (L.cache_meta_at(L.CacheBoxes{},L.box_coordinate(sr,sc),q,box),L.pointer_route_from_logical(q,L.logical_address_facts(qr,qc)))))

def L.ordinary_routes_from_coordinates(sr,sc,qr,qc):
  L.ordinary_routes_from_geometry(sr,sc,qr,qc,L.checked_ordinary_geometry(sr,sc),L.cache_meta_facts(qr,qc))

def L.logical_ordinary_swap_keeps_clue(b,sr,sc,qr,qc,value,clue,distinct,state):
  +p = L.logical_position(sr,sc)
  +q = L.logical_position(qr,qc)
  L.ordinary_swap_keeps(b,p,value,q,clue)(
    L.logical_distinct_apart(p,q,distinct,L.matrix_logical_entry(sr,sc,qr,qc),L.logical_address_facts(sr,sc),L.logical_address_facts(qr,qc)),
    L.ordinary_routes_from_coordinates(sr,sc,qr,qc),state)

def L.inactive_clear_keeps_clue(b,sr,sc,qr,qc,clue,distinct,state):
  L.logical_ordinary_swap_keeps_clue(b,sr,sc,qr,qc,0,clue,distinct,state)

def L.inactive_swap_keeps_clue(b,sr,sc,qr,qc,value,clue,distinct,state):
  L.logical_ordinary_swap_keeps_clue(b,sr,sc,qr,qc,value,clue,distinct,state)

def L.adaptive_guess_snapshot_word(b,frames,depth,found,snapshots,p,q,digit,remaining,active):
  Equal.cong(Fast.State,U32,state => L.searching_snapshot_word(state,q),
    Fast.place(True{},p,digit,remaining,frames,depth,found,snapshots,active,b),
    Fast.guessed(p,digit,remaining,frames,depth,found,snapshots,active,
      (Fast.activated(active,b),Fast.activated(active,b))),
    L.adaptive_guess_saves_activated_board(p,digit,remaining,frames,depth,found,snapshots,active,b))

def L.adaptive_active_guess_keeps_clue_image(image,frames,depth,found,snapshots,sr,sc,qr,qc,fixed,digit,remaining,distinct,state):
  +p = L.logical_position(sr,sc)
  +q = L.logical_position(qr,qc)
  +d = L.digit_word(digit)
  Equal.trans(U32,L.searching_word(Fast.place(True{},p,d,remaining,frames,depth,found,snapshots,True{},L.image_board(image)),q),
    L.cell_value(Q.place(True{},p,d,L.image_board(image)),q),L.fixed_word(fixed),
    Equal.cong(Fast.State,U32,out => L.searching_word(out,q),
      Fast.place(True{},p,d,remaining,frames,depth,found,snapshots,True{},L.image_board(image)),
      Fast.guessed(p,d,remaining,frames,depth,found,snapshots,True{},(L.image_board(image),L.image_board(image))),
      L.adaptive_guess_saves_activated_board(p,d,remaining,frames,depth,found,snapshots,True{},L.image_board(image))),
    L.fixed_clue_word(Q.place(True{},p,d,L.image_board(image)),q,fixed,
      L.logical_placement_keeps_other_clue(L.image_board(image),True{},sr,sc,qr,qc,fixed,digit,distinct,state)))

def L.adaptive_active_guess_keeps_clue(b,frames,depth,found,snapshots,sr,sc,qr,qc,fixed,digit,remaining,distinct,state):
  +p = L.logical_position(sr,sc)
  +q = L.logical_position(qr,qc)
  proof : (L.FixedClue(b,q,fixed) -> {L.searching_word(Fast.place(True{},p,L.digit_word(digit),remaining,frames,depth,found,snapshots,True{},b),q) == L.fixed_word(fixed) : U32}) =
    L.on_reified_board(b,x => (L.FixedClue(x,q,fixed) -> {L.searching_word(Fast.place(True{},p,L.digit_word(digit),remaining,frames,depth,found,snapshots,True{},x),q) == L.fixed_word(fixed) : U32}),
      L.reify_board(b),image => L.adaptive_active_guess_keeps_clue_image(image,frames,depth,found,snapshots,sr,sc,qr,qc,fixed,digit,remaining,distinct))
  proof(state)

def L.adaptive_active_guess_snapshot_keeps_clue_image(image,frames,depth,found,snapshots,p,q,fixed,digit,remaining,state):
  Equal.trans(U32,L.searching_snapshot_word(Fast.place(True{},p,digit,remaining,frames,depth,found,snapshots,True{},L.image_board(image)),q),
    L.cell_value(L.image_board(image),q),L.fixed_word(fixed),
    L.adaptive_guess_snapshot_word(L.image_board(image),frames,depth,found,snapshots,p,q,digit,remaining,True{}),
    L.fixed_clue_word(L.image_board(image),q,fixed,state))

def L.adaptive_active_guess_snapshot_keeps_clue(b,frames,depth,found,snapshots,p,q,fixed,digit,remaining,state):
  proof : (L.FixedClue(b,q,fixed) -> {L.searching_snapshot_word(Fast.place(True{},p,digit,remaining,frames,depth,found,snapshots,True{},b),q) == L.fixed_word(fixed) : U32}) =
    L.on_reified_board(b,x => (L.FixedClue(x,q,fixed) -> {L.searching_snapshot_word(Fast.place(True{},p,digit,remaining,frames,depth,found,snapshots,True{},x),q) == L.fixed_word(fixed) : U32}),
      L.reify_board(b),image => L.adaptive_active_guess_snapshot_keeps_clue_image(image,frames,depth,found,snapshots,p,q,fixed,digit,remaining))
  proof(state)

def L.encoded_nonblank_word(d,b,p,nonblank):
  match d:
    case L.D0{}:
      Empty.absurd({L.cell_value(Q.encoded(p,(b,0)),p) == 0 : U32},
        L.false_is_not_true(Equal.sym(Bool,True{},False{},nonblank)))
    case L.D1{}:
      L.encode_fixed_cell_1(b,p)
    case L.D2{}:
      L.encode_fixed_cell_2(b,p)
    case L.D3{}:
      L.encode_fixed_cell_3(b,p)
    case L.D4{}:
      L.encode_fixed_cell_4(b,p)
    case L.D5{}:
      L.encode_fixed_cell_5(b,p)
    case L.D6{}:
      L.encode_fixed_cell_6(b,p)
    case L.D7{}:
      L.encode_fixed_cell_7(b,p)
    case L.D8{}:
      L.encode_fixed_cell_8(b,p)
    case L.D9{}:
      L.encode_fixed_cell_9(b,p)

def L.actual_encode_nonblank_word(image,p,d,nonblank,word_is):
  b = L.image_board(image)
  +word = L.cell_value(L.image_board(image),p)
  +digit = L.digit_word(d)
  %Equal.sym(Array<U32>,L.actual_encoded_step(b,p),Q.encoded(p,(b,word)),
    L.encode_step_normalized(b,p,L.board_read_witness(L.image_board(image),p))) :
    {L.cell_value(_,p) == L.fixed_word(d) : U32}
  %Equal.sym(U32,word,digit,word_is) :
    {L.cell_value(Q.encoded(p,(b,_)),p) == L.fixed_word(d) : U32}
  L.encoded_nonblank_word(d,L.image_board(image),p,nonblank)

def L.encode_raw_middle_base_image(image,suffix,p,d,shapes,safe,tail,nonblank,digit):
  (s0,s1) = shapes
  step = L.actual_encoded_step(L.image_board(image),p)
  +p1 = (p + 1 : U32)
  +final = L.cell_value(Q.encode_go(suffix,p1,L.actual_encoded_step(L.image_board(image),p)),p)
  +current = L.cell_value(L.actual_encoded_step(L.image_board(image),p),p)
  Equal.trans(U32,final,current,L.fixed_word(d),
    L.encode_sweep_keeps(suffix,p1,p,step,L.actual_encode_step_keeps_perfect(L.image_board(image),p,s0),tail),
    L.actual_encode_nonblank_word(image,p,d,nonblank,digit))

def L.encode_raw_middle_base(image,suffix,p,d,shape,before,safe,after,nonblank,digit):
  L.encode_raw_middle_base_image(image,suffix,p,d,
    L.copy_shape_proof(L.array_shape(L.image_board(image)),L.perfect_shape(7n),shape),safe,after,nonblank,digit)

def L.encode_raw_middle_step_image(image,k,suffix,p,d,shapes,before,safe,after,nonblank,digit,next):
  (s0,s1) = shapes
  (cell,(flag,tail)) = before
  step = L.actual_encoded_step(L.image_board(image),p)
  +p1 = (p + 1 : U32)
  +q = L.walk_position(k,p1)
  next(step,L.actual_encode_step_keeps_perfect(L.image_board(image),p,s0),tail,safe,after,nonblank,
    Equal.trans(U32,L.cell_value(step,q),L.cell_value(L.image_board(image),q),L.digit_word(d),
      L.encode_step_keeps(L.image_board(image),p,q)(s1,cell,flag),digit))

def L.encode_raw_middle_step(image,k,suffix,p,d,next,shape,before,safe,after,nonblank,digit):
  L.encode_raw_middle_step_image(image,k,suffix,p,d,
    L.copy_shape_proof(L.array_shape(L.image_board(image)),L.perfect_shape(7n),shape),before,safe,after,nonblank,digit,next)

def L.encode_raw_middle_from_image(prefix,image,suffix,p,d,shape,before,safe,after,nonblank,digit):
  match prefix:
    case 0n:
      L.encode_raw_middle_base(image,suffix,p,d,shape,before,safe,after,nonblank,digit)
    case 1n+k:
      L.encode_raw_middle_step(image,k,suffix,p,d,
        sub => L.on_reified_board(sub,x => L.EncodeMiddleRaw(x,k,suffix,(p + 1 : U32),d),
          L.reify_board(sub),im => L.encode_raw_middle_from_image(k,im,suffix,(p + 1 : U32),d)),
        shape,before,safe,after,nonblank,digit)

def L.encode_raw_middle_value(b,prefix,suffix,p,d):
  L.on_reified_board(b,x => L.EncodeMiddleRaw(x,prefix,suffix,p,d),
    L.reify_board(b),image => L.encode_raw_middle_from_image(prefix,image,suffix,p,d))


def L.encode81_at_step(image,before,after,d,shapes,r9,r10,r11,ep,safe,es,count,nonblank,digit):
  (s0,s1) = shapes
  b = L.image_board(image)
  seed = L.queue_seed(L.image_board(image))
  +q = L.walk_position(before,0)
  %count :
    {L.cell_value(Q.encode_go(_,0,L.queue_seed(b)),q) == L.fixed_word(d) : U32}
  L.encode_raw_middle_value(seed,before,after,0,d)(
    L.queue_seed_perfect(L.image_board(image),s0),ep,safe,es,nonblank,
    Equal.trans(U32,L.cell_value(seed,q),L.cell_value(b,q),L.digit_word(d),
      L.queue_seed_keeps_cell(L.image_board(image),q)(s1,r9,r10,r11),digit))

def L.encode81_at_image(image,before,after,d,shape,r9,r10,r11,ep,safe,es,count,nonblank,digit):
  L.encode81_at_step(image,before,after,d,
    L.copy_shape_proof(L.array_shape(L.image_board(image)),L.perfect_shape(7n),shape),
    r9,r10,r11,ep,safe,es,count,nonblank,digit)

def L.public_queue_encode_nonblank_at(b,before,after,d):
  L.on_reified_board(b,x => L.Encode81At(x,before,after,d),
    L.reify_board(b),image => L.encode81_at_image(image,before,after,d))

def L.public_encode_nonblank_routes(b,before,after,d,shape,routes,count,nonblank,digit):
  (r9,(r10,(r11,(safe,((ep,dp),(es,ds)))))) = routes
  L.public_queue_encode_nonblank_at(b,before,after,d)(shape,r9,r10,r11,ep,safe,es,count,nonblank,digit)

def L.public_encode_nonblank_checked(b,before,after,d,shape,window,nonblank,digit):
  (guard,count) = window
  +q = L.walk_position(before,0)
  L.public_encode_nonblank_routes(b,before,after,d,shape,
    L.window_routes(before,after,q,(q + 1 : U32),guard),count,nonblank,digit)

def L.any_logical_cell_encode_nonblank(b,row,col,d,shape,nonblank,digit):
  L.public_encode_nonblank_checked(b,L.logical_offset(row,col),L.logical_tail(row,col),d,shape,L.every_cell_window(row,col),nonblank,digit)


def L.activation_shape_and_word_parts(image,row,col,d,nonblank,shapes,word):
  (s0,s1) = shapes
  (Equal.trans(L.ArrayShape,L.array_shape(Q.encode(L.image_board(image))),L.array_shape(L.image_board(image)),L.perfect_shape(7n),
      L.queued_encode_preserves_shape(L.image_board(image)),s0),
    L.any_logical_cell_encode_nonblank(L.image_board(image),row,col,d,s1,nonblank,word))

def L.activation_shape_and_word_image(image,row,col,d,nonblank,clue):
  (shape,word) = clue
  L.activation_shape_and_word_parts(image,row,col,d,nonblank,
    L.copy_shape_proof(L.array_shape(L.image_board(image)),L.perfect_shape(7n),shape),word)

def L.adaptive_activation_fixed_clue(b,row,col,d,nonblank,clue):
  +q = L.logical_position(row,col)
  proof : (L.PlainWord(b,q,L.digit_word(d)) -> L.FixedClue(Fast.activated(False{},b),q,d)) =
    L.on_reified_board(b,x => (L.PlainWord(x,q,L.digit_word(d)) -> L.FixedClue(Fast.activated(False{},x),q,d)),
      L.reify_board(b),image => L.activation_shape_and_word_image(image,row,col,d,nonblank))
  proof(clue)

def L.guessed_ignores_supplied_mode(frames,depth,found,snapshots,p,digit,remaining,pair):
  (saved,working) = pair
  {==}

def L.adaptive_first_guess_matches_queued(b,frames,depth,found,snapshots,p,digit,remaining):
  L.guessed_ignores_supplied_mode(frames,depth,found,snapshots,p,digit,remaining,Array.clone(U32,Q.encode(b)))

def L.adaptive_first_guess_live_keeps_clue_image(image,frames,depth,found,snapshots,sr,sc,qr,qc,fixed,digit,remaining,nonblank,distinct,clue):
  +p = L.logical_position(sr,sc)
  +q = L.logical_position(qr,qc)
  +d = L.digit_word(digit)
  Equal.trans(U32,L.searching_word(Fast.place(True{},p,d,remaining,frames,depth,found,snapshots,False{},L.image_board(image)),q),
    L.searching_word(Fast.place(True{},p,d,remaining,frames,depth,found,snapshots,True{},Q.encode(L.image_board(image))),q),L.fixed_word(fixed),
    Equal.cong(Fast.State,U32,out => L.searching_word(out,q),
      Fast.place(True{},p,d,remaining,frames,depth,found,snapshots,False{},L.image_board(image)),
      Fast.place(True{},p,d,remaining,frames,depth,found,snapshots,True{},Q.encode(L.image_board(image))),
      L.adaptive_first_guess_matches_queued(L.image_board(image),frames,depth,found,snapshots,p,d,remaining)),
    L.adaptive_active_guess_keeps_clue(Q.encode(L.image_board(image)),frames,depth,found,snapshots,sr,sc,qr,qc,fixed,digit,remaining,distinct,
      L.adaptive_activation_fixed_clue(L.image_board(image),qr,qc,fixed,nonblank,clue)))

def L.adaptive_first_guess_live_keeps_clue(b,frames,depth,found,snapshots,sr,sc,qr,qc,fixed,digit,remaining,nonblank,distinct,clue):
  +p = L.logical_position(sr,sc)
  +q = L.logical_position(qr,qc)
  proof : (L.PlainWord(b,q,L.digit_word(fixed)) -> {L.searching_word(Fast.place(True{},p,L.digit_word(digit),remaining,frames,depth,found,snapshots,False{},b),q) == L.fixed_word(fixed) : U32}) =
    L.on_reified_board(b,x => (L.PlainWord(x,q,L.digit_word(fixed)) -> {L.searching_word(Fast.place(True{},p,L.digit_word(digit),remaining,frames,depth,found,snapshots,False{},x),q) == L.fixed_word(fixed) : U32}),
      L.reify_board(b),image => L.adaptive_first_guess_live_keeps_clue_image(image,frames,depth,found,snapshots,sr,sc,qr,qc,fixed,digit,remaining,nonblank,distinct))
  proof(clue)

def L.adaptive_first_guess_snapshot_keeps_clue_image(image,frames,depth,found,snapshots,sr,sc,qr,qc,fixed,digit,remaining,nonblank,clue):
  +p = L.logical_position(sr,sc)
  +q = L.logical_position(qr,qc)
  +d = L.digit_word(digit)
  Equal.trans(U32,L.searching_snapshot_word(Fast.place(True{},p,d,remaining,frames,depth,found,snapshots,False{},L.image_board(image)),q),
    L.searching_snapshot_word(Fast.place(True{},p,d,remaining,frames,depth,found,snapshots,True{},Q.encode(L.image_board(image))),q),L.fixed_word(fixed),
    Equal.cong(Fast.State,U32,out => L.searching_snapshot_word(out,q),
      Fast.place(True{},p,d,remaining,frames,depth,found,snapshots,False{},L.image_board(image)),
      Fast.place(True{},p,d,remaining,frames,depth,found,snapshots,True{},Q.encode(L.image_board(image))),
      L.adaptive_first_guess_matches_queued(L.image_board(image),frames,depth,found,snapshots,p,d,remaining)),
    L.adaptive_active_guess_snapshot_keeps_clue(Q.encode(L.image_board(image)),frames,depth,found,snapshots,p,q,fixed,d,remaining,
      L.adaptive_activation_fixed_clue(L.image_board(image),qr,qc,fixed,nonblank,clue)))

def L.adaptive_first_guess_snapshot_keeps_clue(b,frames,depth,found,snapshots,sr,sc,qr,qc,fixed,digit,remaining,nonblank,clue):
  +p = L.logical_position(sr,sc)
  +q = L.logical_position(qr,qc)
  proof : (L.PlainWord(b,q,L.digit_word(fixed)) -> {L.searching_snapshot_word(Fast.place(True{},p,L.digit_word(digit),remaining,frames,depth,found,snapshots,False{},b),q) == L.fixed_word(fixed) : U32}) =
    L.on_reified_board(b,x => (L.PlainWord(x,q,L.digit_word(fixed)) -> {L.searching_snapshot_word(Fast.place(True{},p,L.digit_word(digit),remaining,frames,depth,found,snapshots,False{},x),q) == L.fixed_word(fixed) : U32}),
      L.reify_board(b),image => L.adaptive_first_guess_snapshot_keeps_clue_image(image,frames,depth,found,snapshots,sr,sc,qr,qc,fixed,digit,remaining,nonblank))
  proof(clue)

def L.queued_stale_flag_can_select_clue():
  ({==},{==})

def L.ordinary_stale_bitmap_can_select_clue():
  ({==},{==})

def L.adaptive_nonzero_alternative_replays_guess(mask,p,frames,depth,found,snapshots,saved,present):
  match mask:
    case 0:
      Empty.absurd({Fast.alternative(0,p,frames,depth,found,snapshots,True{},saved) ==
        Fast.place(True{},p,L.alternative_digit(0),L.alternatives_after(0),frames,depth,found,snapshots,True{},saved) : Fast.State},
        L.false_is_not_true(Equal.sym(Bool,True{},False{},present)))
    case U32{WCon{True{}, rest}}:
      {==}
    case U32{WCon{False{}, WCon{True{}, rest}}}:
      {==}
    case U32{WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}:
      {==}
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}:
      {==}
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}:
      {==}
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}:
      {==}
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}:
      {==}
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}:
      {==}
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}:
      {==}
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}:
      {==}
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      {==}

def L.adaptive_nonzero_restore_replays_guess(mask,p,frames,depth,found,snapshots,saved,present):
  L.adaptive_nonzero_alternative_replays_guess(mask,p,frames,depth,found,snapshots,saved,present)

def L.zero_subtract_no_carry_is_not(n,w):
  match n w:
    case 0n WNil{}:
      {==}
    case 1n+k WCon{True{},tail}:
      Equal.cong(Word(k),Word(1n+k),r => WCon{False{},r},
        Word.adc(k,Word.zero(k),tail,True{},False{}),Word.not(k,tail),
        L.zero_subtract_no_carry_is_not(k,tail))
    case 1n+k WCon{False{},tail}:
      Equal.cong(Word(k),Word(1n+k),r => WCon{True{},r},
        Word.adc(k,Word.zero(k),tail,True{},False{}),Word.not(k,tail),
        L.zero_subtract_no_carry_is_not(k,tail))

def L.word_and_complement_zero(n,w):
  match n w:
    case 0n WNil{}:
      {==}
    case 1n+k WCon{True{},tail}:
      Equal.cong(Word(k),Word(1n+k),r => WCon{False{},r},
        Word.and(k,tail,Word.not(k,tail)),Word.zero(k),L.word_and_complement_zero(k,tail))
    case 1n+k WCon{False{},tail}:
      Equal.cong(Word(k),Word(1n+k),r => WCon{False{},r},
        Word.and(k,tail,Word.not(k,tail)),Word.zero(k),L.word_and_complement_zero(k,tail))

def L.word_first_one_is_lowest_bit(n,w):
  match n w:
    case 0n WNil{}:
      {==}
    case 1n+k WCon{True{},tail}:
      Equal.cong(Word(k),Word(1n+k),r => WCon{True{},r},
        Word.and(k,tail,Word.adc(k,Word.zero(k),tail,True{},False{})),Word.zero(k),
        Equal.trans(Word(k),
          Word.and(k,tail,Word.adc(k,Word.zero(k),tail,True{},False{})),Word.and(k,tail,Word.not(k,tail)),Word.zero(k),
          Equal.cong(Word(k),Word(k),r => Word.and(k,tail,r),
            Word.adc(k,Word.zero(k),tail,True{},False{}),Word.not(k,tail),
            L.zero_subtract_no_carry_is_not(k,tail)),
          L.word_and_complement_zero(k,tail)))
    case 1n+k WCon{False{},tail}:
      Equal.cong(Word(k),Word(1n+k),r => WCon{False{},r},
        Word.and(k,tail,Word.sub(k,Word.zero(k),tail)),L.first_one_word(k,tail),
        L.word_first_one_is_lowest_bit(k,tail))

def L.u32_first_one_is_lowest_bit(w):
  Equal.cong(Word(32n),U32,r => U32{r},Word.and(32n,w,Word.sub(32n,Word.zero(32n),w)),
    L.first_one_word(32n,w),L.word_first_one_is_lowest_bit(32n,w))

def L.first_one_word_is_present(n,w):
  match n w:
    case 0n WNil{}:
      {==}
    case 1n+k WCon{True{},tail}:
      Equal.cong(Word(k),Word(1n+k),r => WCon{True{},r},
        Word.and(k,Word.zero(k),tail),Word.zero(k),L.word_zero_and(k,tail))
    case 1n+k WCon{False{},tail}:
      Equal.cong(Word(k),Word(1n+k),r => WCon{False{},r},
        Word.and(k,L.first_one_word(k,tail),tail),L.first_one_word(k,tail),
        L.first_one_word_is_present(k,tail))

def L.lowest_bit_is_present(w):
  %Equal.sym(U32,L.lowest_bit(U32{w}),U32{L.first_one_word(32n,w)},L.u32_first_one_is_lowest_bit(w)) :
    {U32.and(_,U32{w}) == _ : U32}
  Equal.cong(Word(32n),U32,r => U32{r},Word.and(32n,L.first_one_word(32n,w),w),
    L.first_one_word(32n,w),L.first_one_word_is_present(32n,w))

def L.word_xor_zero_right(n,w):
  match n w:
    case 0n WNil{}:
      {==}
    case 1n+k WCon{True{},tail}:
      Equal.cong(Word(k),Word(1n+k),r => WCon{True{},r},
        Word.xor(k,tail,Word.zero(k)),tail,L.word_xor_zero_right(k,tail))
    case 1n+k WCon{False{},tail}:
      Equal.cong(Word(k),Word(1n+k),r => WCon{False{},r},
        Word.xor(k,tail,Word.zero(k)),tail,L.word_xor_zero_right(k,tail))

def L.word_xor_first_one_removes_only_first(n,w):
  match n w:
    case 0n WNil{}:
      {==}
    case 1n+k WCon{True{},tail}:
      Equal.cong(Word(k),Word(1n+k),r => WCon{False{},r},
        Word.xor(k,tail,Word.zero(k)),tail,L.word_xor_zero_right(k,tail))
    case 1n+k WCon{False{},tail}:
      Equal.cong(Word(k),Word(1n+k),r => WCon{False{},r},
        Word.xor(k,tail,L.first_one_word(k,tail)),L.remove_first_one_word(k,tail),
        L.word_xor_first_one_removes_only_first(k,tail))

def L.alternatives_after_removes_only_first(w):
  %Equal.sym(U32,L.lowest_bit(U32{w}),U32{L.first_one_word(32n,w)},L.u32_first_one_is_lowest_bit(w)) :
    {U32.xor(U32{w},_) == U32{L.remove_first_one_word(32n,w)} : U32}
  Equal.cong(Word(32n),U32,r => U32{r},Word.xor(32n,w,L.first_one_word(32n,w)),
    L.remove_first_one_word(32n,w),L.word_xor_first_one_removes_only_first(32n,w))

def L.chosen_alternative_pack(w,d,nonblank,count,eq):
  %Equal.sym(U32,L.lowest_bit(U32{w}),Board.bit(L.digit_word(d)),eq) : Sigma<&2,&1,L.BoardDigit,x => (L.Nonblank(x) & {C.mask_count((_ - 1 : U32)) == L.digit_word(x) : U32} & {_ == Board.bit(L.digit_word(x)) : U32})>
  (d,(nonblank,(count,{==})))

def L.chosen_alternative_from_first_one(w,d,nonblank,found,count):
  L.chosen_alternative_pack(w,d,nonblank,count,
    Equal.trans(U32,L.lowest_bit(U32{w}),U32{L.first_one_word(32n,w)},Board.bit(L.digit_word(d)),
      L.u32_first_one_is_lowest_bit(w),found))


def L.candidate_bits_select_digit(bits,nonempty):
  match bits:
    case WCon{True{}, tail}:
      L.chosen_alternative_from_first_one(WCon{False{},L.pad_candidate(9n,WCon{True{}, tail})},L.D1{},{==},{==},{==})
    case WCon{False{}, WCon{True{}, tail}}:
      L.chosen_alternative_from_first_one(WCon{False{},L.pad_candidate(9n,WCon{False{}, WCon{True{}, tail}})},L.D2{},{==},{==},{==})
    case WCon{False{}, WCon{False{}, WCon{True{}, tail}}}:
      L.chosen_alternative_from_first_one(WCon{False{},L.pad_candidate(9n,WCon{False{}, WCon{False{}, WCon{True{}, tail}}})},L.D3{},{==},{==},{==})
    case WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, tail}}}}:
      L.chosen_alternative_from_first_one(WCon{False{},L.pad_candidate(9n,WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, tail}}}})},L.D4{},{==},{==},{==})
    case WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, tail}}}}}:
      L.chosen_alternative_from_first_one(WCon{False{},L.pad_candidate(9n,WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, tail}}}}})},L.D5{},{==},{==},{==})
    case WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, tail}}}}}}:
      L.chosen_alternative_from_first_one(WCon{False{},L.pad_candidate(9n,WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, tail}}}}}})},L.D6{},{==},{==},{==})
    case WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, tail}}}}}}}:
      L.chosen_alternative_from_first_one(WCon{False{},L.pad_candidate(9n,WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, tail}}}}}}})},L.D7{},{==},{==},{==})
    case WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, tail}}}}}}}}:
      L.chosen_alternative_from_first_one(WCon{False{},L.pad_candidate(9n,WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, tail}}}}}}}})},L.D8{},{==},{==},{==})
    case WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}}:
      L.chosen_alternative_from_first_one(WCon{False{},L.pad_candidate(9n,WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}})},L.D9{},{==},{==},{==})
    case WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WNil{}}}}}}}}}}:
      Empty.absurd(L.ChosenAlternative(0),L.false_is_not_true(Equal.sym(Bool,True{},False{},nonempty)))

def L.low_candidate_mask_image(word):
  match word:
    case U32{WCon{b0, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WCon{b8, WCon{b9, upper}}}}}}}}}}}:
      (WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WCon{b8, WCon{b9, WNil{}}}}}}}}}},
       Equal.cong(Word(22n),U32,pad => U32{WCon{False{}, WCon{b1, WCon{b2, WCon{b3, WCon{b4, WCon{b5, WCon{b6, WCon{b7, WCon{b8, WCon{b9, pad}}}}}}}}}}},Word.and(22n,Word.zero(22n),upper),
         Word.zero(22n),L.word_zero_and(22n,upper)))

def L.clipped_candidate_selects_digit_image(word,image,nonempty):
  (+bits,match_bits) = image
  result : ({U32.is_eq(U32.and(1022,word),0) == False{} : Bool} -> L.ChosenAlternative(U32.and(1022,word))) =
    %Equal.sym(U32,U32.and(1022,word),L.candidate_bits_word(bits),match_bits) :
      ({U32.is_eq(_,0) == False{} : Bool} -> L.ChosenAlternative(_))
    premise => L.candidate_bits_select_digit(bits,premise)
  result(nonempty)

def L.clipped_candidate_selects_digit(word,nonempty):
  L.clipped_candidate_selects_digit_image(word,L.low_candidate_mask_image(word),nonempty)

def L.normalized_candidate_selects_digit(mask,clipped,nonempty):
  result : ({U32.is_eq(mask,0) == False{} : Bool} -> L.ChosenAlternative(mask)) =
    %clipped : ({U32.is_eq(_,0) == False{} : Bool} -> L.ChosenAlternative(_))
    premise => L.clipped_candidate_selects_digit(mask,premise)
  result(nonempty)

def L.adaptive_restore_replays_chosen_digit(mask,p,frames,depth,found,snapshots,saved,d,present,digit_is):
  %digit_is :
    {Fast.restore(p,mask,frames,depth,found,saved <> snapshots,True{}) ==
      Fast.place(True{},p,_,L.alternatives_after(mask),frames,depth,found,snapshots,True{},saved) : Fast.State}
  L.adaptive_nonzero_restore_replays_guess(mask,p,frames,depth,found,snapshots,saved,present)

def L.adaptive_restored_working_keeps_clue_image(image,frames,depth,found,snapshots,sr,sc,qr,qc,fixed,digit,mask,present,digit_is,distinct,clue):
  +p = L.logical_position(sr,sc)
  +q = L.logical_position(qr,qc)
  Equal.trans(U32,L.searching_word(Fast.restore(p,mask,frames,depth,found,L.image_board(image) <> snapshots,True{}),q),
    L.searching_word(Fast.place(True{},p,L.digit_word(digit),L.alternatives_after(mask),frames,depth,found,snapshots,True{},L.image_board(image)),q),L.fixed_word(fixed),
    Equal.cong(Fast.State,U32,out => L.searching_word(out,q),
      Fast.restore(p,mask,frames,depth,found,L.image_board(image) <> snapshots,True{}),
      Fast.place(True{},p,L.digit_word(digit),L.alternatives_after(mask),frames,depth,found,snapshots,True{},L.image_board(image)),
      L.adaptive_restore_replays_chosen_digit(mask,p,frames,depth,found,snapshots,L.image_board(image),digit,present,digit_is)),
    L.adaptive_active_guess_keeps_clue(L.image_board(image),frames,depth,found,snapshots,sr,sc,qr,qc,fixed,digit,L.alternatives_after(mask),distinct,clue))

def L.adaptive_restored_working_keeps_clue(saved,frames,depth,found,snapshots,sr,sc,qr,qc,fixed,digit,mask,present,digit_is,distinct,clue):
  +p = L.logical_position(sr,sc)
  +q = L.logical_position(qr,qc)
  pkeep : (L.FixedClue(saved,q,fixed) -> {L.searching_word(Fast.restore(p,mask,frames,depth,found,saved <> snapshots,True{}),q) == L.fixed_word(fixed) : U32}) =
    L.on_reified_board(saved,x =>
      (L.FixedClue(x,q,fixed) -> {L.searching_word(Fast.restore(p,mask,frames,depth,found,x <> snapshots,True{}),q) == L.fixed_word(fixed) : U32}),
      L.reify_board(saved),image => L.adaptive_restored_working_keeps_clue_image(image,frames,depth,found,snapshots,sr,sc,qr,qc,fixed,digit,mask,present,digit_is,distinct))
  pkeep(clue)

def L.adaptive_restored_snapshot_keeps_clue_image(image,frames,depth,found,snapshots,p,q,fixed,digit,mask,present,digit_is,clue):
  Equal.trans(U32,L.searching_snapshot_word(Fast.restore(p,mask,frames,depth,found,L.image_board(image) <> snapshots,True{}),q),
    L.searching_snapshot_word(Fast.place(True{},p,L.digit_word(digit),L.alternatives_after(mask),frames,depth,found,snapshots,True{},L.image_board(image)),q),L.fixed_word(fixed),
    Equal.cong(Fast.State,U32,out => L.searching_snapshot_word(out,q),
      Fast.restore(p,mask,frames,depth,found,L.image_board(image) <> snapshots,True{}),
      Fast.place(True{},p,L.digit_word(digit),L.alternatives_after(mask),frames,depth,found,snapshots,True{},L.image_board(image)),
      L.adaptive_restore_replays_chosen_digit(mask,p,frames,depth,found,snapshots,L.image_board(image),digit,present,digit_is)),
    L.adaptive_active_guess_snapshot_keeps_clue(L.image_board(image),frames,depth,found,snapshots,p,q,fixed,L.digit_word(digit),L.alternatives_after(mask),clue))

def L.adaptive_restored_snapshot_keeps_clue(saved,frames,depth,found,snapshots,p,q,fixed,digit,mask,present,digit_is,clue):
  pkeep : (L.FixedClue(saved,q,fixed) -> {L.searching_snapshot_word(Fast.restore(p,mask,frames,depth,found,saved <> snapshots,True{}),q) == L.fixed_word(fixed) : U32}) =
    L.on_reified_board(saved,x =>
      (L.FixedClue(x,q,fixed) -> {L.searching_snapshot_word(Fast.restore(p,mask,frames,depth,found,x <> snapshots,True{}),q) == L.fixed_word(fixed) : U32}),
      L.reify_board(saved),image => L.adaptive_restored_snapshot_keeps_clue_image(image,frames,depth,found,snapshots,p,q,fixed,digit,mask,present,digit_is))
  pkeep(clue)

def L.copy_mask_nonempty(mask,known):
  %known : ({U32.is_eq(mask,0) == _ : Bool} & {U32.is_eq(mask,0) == _ : Bool})
  ({==},{==})

def L.adaptive_normalized_restore_working_keeps_clue_take(saved,frames,depth,found,snapshots,sr,sc,qr,qc,fixed,mask,present,choice,distinct,clue):
  (+digit,(nonblank,(is_digit,bit))) = choice
  L.adaptive_restored_working_keeps_clue(saved,frames,depth,found,snapshots,sr,sc,qr,qc,fixed,digit,mask,present,is_digit,distinct,clue)

def L.adaptive_normalized_restore_working_keeps_clue_split(saved,frames,depth,found,snapshots,sr,sc,qr,qc,fixed,mask,both,clipped,distinct,clue):
  (branch,select) = both
  L.adaptive_normalized_restore_working_keeps_clue_take(saved,frames,depth,found,snapshots,sr,sc,qr,qc,fixed,mask,branch,L.normalized_candidate_selects_digit(mask,clipped,select),distinct,clue)

def L.adaptive_normalized_restore_working_keeps_clue(saved,frames,depth,found,snapshots,sr,sc,qr,qc,fixed,mask,present,clipped,distinct,clue):
  L.adaptive_normalized_restore_working_keeps_clue_split(saved,frames,depth,found,snapshots,sr,sc,qr,qc,fixed,mask,L.copy_mask_nonempty(mask,present),clipped,distinct,clue)

def L.adaptive_normalized_restore_snapshot_keeps_clue_take(saved,frames,depth,found,snapshots,p,q,fixed,mask,present,choice,clue):
  (+digit,(nonblank,(is_digit,bit))) = choice
  L.adaptive_restored_snapshot_keeps_clue(saved,frames,depth,found,snapshots,p,q,fixed,digit,mask,present,is_digit,clue)

def L.adaptive_normalized_restore_snapshot_keeps_clue_split(saved,frames,depth,found,snapshots,p,q,fixed,mask,both,clipped,clue):
  (branch,select) = both
  L.adaptive_normalized_restore_snapshot_keeps_clue_take(saved,frames,depth,found,snapshots,p,q,fixed,mask,branch,L.normalized_candidate_selects_digit(mask,clipped,select),clue)

def L.adaptive_normalized_restore_snapshot_keeps_clue(saved,frames,depth,found,snapshots,p,q,fixed,mask,present,clipped,clue):
  L.adaptive_normalized_restore_snapshot_keeps_clue_split(saved,frames,depth,found,snapshots,p,q,fixed,mask,L.copy_mask_nonempty(mask,present),clipped,clue)

def L.generator_accept_gate(old,candidate,clues,size,count):
  match count:
    case T.CountOne{}:
      {==}
    case T.CountZero{}:
      {==}
    case T.CountMany{}:
      {==}
    case T.CountFuel{}:
      {==}

def L.generator_count_gate(fuel,old,clues,size,candidate,test):
  L.generator_accept_gate(old,candidate,clues,size,K.count2(fuel,test))

def L.generator_attempt_counts_exact_removed_board(fuel,pos,symmetry,clues,size,old,candidate):
  Equal.cong(Array<U32> & Array<U32>,G.DigResult,
    pair => G.count_candidate(fuel,old,clues,size,pair),
    Array.clone(U32,G.remove_unit(candidate,pos,symmetry)),
    (G.remove_unit(candidate,pos,symmetry),G.remove_unit(candidate,pos,symmetry)),
    L.array_clone_exact(G.remove_unit(candidate,pos,symmetry)))

def L.generator_count_zero_fuel_rejects(old,clues,size,candidate,test):
  {==}

def L.generator_fuel_stays_terminal(units,fuel,target,symmetry):
  match units:
    case Nil{}:
      {==}
    case unit <> tail:
      {==}

def L.generator_skips_disallowed_removal(fuel,pos,symmetry,clues,size,board):
  {==}

def L.row_mask_reads_board(b,col,boxbase,used):
  +a = (90 + col : U32)
  +z = (boxbase + M.div3(col) : U32)
  L.on_reified_board(b,x => L.SameBoardRead(x,C.row_mask(x,col,boxbase,used)),
    L.reify_board(b),image =>
      L.invert_observed(L.image_board(image),
        C.cached_add(z,C.cached_add(a,(L.image_board(image),used))),
        L.cached_add_observed(L.image_board(image),C.cached_add(a,(L.image_board(image),used)),z,
          L.cached_add_observed(L.image_board(image),(L.image_board(image),used),a,
            (L.image_board(image),used,({==},{==}))))))

def L.row_scan_open_reads_board(b,open,row,p,m,size,word):
  match open:
    case True{}:
      {==}
    case False{}:
      {==}

def L.row_scan_start_reads_board(b,r,row,p,m,size,read):
  (same,+word,(kept,observed)) = read
  %Equal.sym(Array<U32> & U32,r,(same,word),observed) :
    {L.row_state_board(C.row_scan_start(row,p,m,size,_)) == b : Array<U32>}
  Equal.trans(Array<U32>,L.row_state_board(C.row_scan_start(row,p,m,size,(same,word))),same,b,
    L.row_scan_open_reads_board(same,(row < 9 : U32),row,p,m,size,word),kept)

def L.row_scan_result_keeps_board(b,urgent,row,bits,used,boxbase,pos,mask,count,p,m,size):
  match urgent:
    case True{}:
      {==}
    case False{}:
      {==}

def L.row_scan_take_reads_board(b,r,row,bits,used,boxbase,pos,p,m,size,read):
  (same,+mask,(kept,observed)) = read
  +count = C.mask_count(mask)
  %Equal.sym(Array<U32> & U32,r,(same,mask),observed) :
    {L.row_state_board(C.row_scan_take(row,bits,used,boxbase,pos,p,m,size,_)) == b : Array<U32>}
  Equal.trans(Array<U32>,L.row_state_board(C.row_scan_take(row,bits,used,boxbase,pos,p,m,size,(same,mask))),same,b,
    L.row_scan_result_keeps_board(same,(count <= 1 : U32),row,bits,used,boxbase,pos,mask,count,p,m,size),kept)

def L.ordinary_row_take_normalized_keeps(image,row,bits,used,boxbase,p,m,size):
  +col = L.alternative_digit(bits)
  L.row_scan_take_reads_board(L.image_board(image),C.row_mask(L.image_board(image),col,boxbase,used),
    row,L.alternatives_after(bits),used,boxbase,(row * 9 + col : U32),p,m,size,
    L.row_mask_reads_board(L.image_board(image),col,boxbase,used))

def L.ordinary_row_step_preserves_board_image(image,row,bits,used,boxbase,p,m,size):
  match bits:
    case 0:
      L.row_scan_start_reads_board(L.image_board(image),Array.get(U32,L.image_board(image),(82 + row : U32)),
        (row + 1 : U32),p,m,size,L.board_read_witness(L.image_board(image),(82 + row : U32)))
    case U32{WCon{True{}, rest}}:
      L.ordinary_row_take_normalized_keeps(image,row,U32{WCon{True{}, rest}},used,boxbase,p,m,size)
    case U32{WCon{False{}, WCon{True{}, rest}}}:
      L.ordinary_row_take_normalized_keeps(image,row,U32{WCon{False{}, WCon{True{}, rest}}},used,boxbase,p,m,size)
    case U32{WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}:
      L.ordinary_row_take_normalized_keeps(image,row,U32{WCon{False{}, WCon{False{}, WCon{True{}, rest}}}},used,boxbase,p,m,size)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}:
      L.ordinary_row_take_normalized_keeps(image,row,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}},used,boxbase,p,m,size)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}:
      L.ordinary_row_take_normalized_keeps(image,row,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}},used,boxbase,p,m,size)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}:
      L.ordinary_row_take_normalized_keeps(image,row,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}},used,boxbase,p,m,size)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}:
      L.ordinary_row_take_normalized_keeps(image,row,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}},used,boxbase,p,m,size)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}:
      L.ordinary_row_take_normalized_keeps(image,row,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}},used,boxbase,p,m,size)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}:
      L.ordinary_row_take_normalized_keeps(image,row,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}},used,boxbase,p,m,size)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}:
      L.ordinary_row_take_normalized_keeps(image,row,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}},used,boxbase,p,m,size)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}:
      L.ordinary_row_take_normalized_keeps(image,row,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}},used,boxbase,p,m,size)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}:
      L.ordinary_row_take_normalized_keeps(image,row,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}},used,boxbase,p,m,size)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}:
      L.ordinary_row_take_normalized_keeps(image,row,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}},used,boxbase,p,m,size)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}:
      L.ordinary_row_take_normalized_keeps(image,row,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}},used,boxbase,p,m,size)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}:
      L.ordinary_row_take_normalized_keeps(image,row,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}},used,boxbase,p,m,size)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}:
      L.ordinary_row_take_normalized_keeps(image,row,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}},used,boxbase,p,m,size)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}:
      L.ordinary_row_take_normalized_keeps(image,row,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}},used,boxbase,p,m,size)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}:
      L.ordinary_row_take_normalized_keeps(image,row,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}},used,boxbase,p,m,size)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}:
      L.ordinary_row_take_normalized_keeps(image,row,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}},used,boxbase,p,m,size)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}:
      L.ordinary_row_take_normalized_keeps(image,row,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}},used,boxbase,p,m,size)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}:
      L.ordinary_row_take_normalized_keeps(image,row,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}},used,boxbase,p,m,size)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}:
      L.ordinary_row_take_normalized_keeps(image,row,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}},used,boxbase,p,m,size)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}:
      L.ordinary_row_take_normalized_keeps(image,row,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}},used,boxbase,p,m,size)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.ordinary_row_take_normalized_keeps(image,row,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}},used,boxbase,p,m,size)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.ordinary_row_take_normalized_keeps(image,row,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}},used,boxbase,p,m,size)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.ordinary_row_take_normalized_keeps(image,row,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}},used,boxbase,p,m,size)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.ordinary_row_take_normalized_keeps(image,row,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}},used,boxbase,p,m,size)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.ordinary_row_take_normalized_keeps(image,row,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}},used,boxbase,p,m,size)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.ordinary_row_take_normalized_keeps(image,row,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}},used,boxbase,p,m,size)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.ordinary_row_take_normalized_keeps(image,row,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}},used,boxbase,p,m,size)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.ordinary_row_take_normalized_keeps(image,row,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}},used,boxbase,p,m,size)
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.ordinary_row_take_normalized_keeps(image,row,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}},used,boxbase,p,m,size)

def L.ordinary_row_step_preserves_board(b,row,bits,used,boxbase,p,m,size):
  L.on_reified_board(b,x => {L.row_state_board(C.row_scan_step(row,bits,used,boxbase,p,m,size,x)) == x : Array<U32>},
    L.reify_board(b),image => L.ordinary_row_step_preserves_board_image(image,row,bits,used,boxbase,p,m,size))

def L.ordinary_row_scan_join(fuel,b,next,next_keeps,later):
  Equal.trans(Array<U32>,Pair.fst(Array<U32>,C.Choice,C.row_scan(fuel,next)),L.row_state_board(next),b,later,next_keeps)

def L.ordinary_row_scan_continue_image(fuel,image,row,bits,used,boxbase,p,m,size,later):
  L.ordinary_row_scan_join(fuel,L.image_board(image),
    C.row_scan_step(row,bits,used,boxbase,p,m,size,L.image_board(image)),
    L.ordinary_row_step_preserves_board(L.image_board(image),row,bits,used,boxbase,p,m,size),
    later(C.row_scan_step(row,bits,used,boxbase,p,m,size,L.image_board(image))))

def L.ordinary_row_scan_continue(fuel,b,row,bits,used,boxbase,p,m,size,later):
  L.on_reified_board(b,x =>
    {Pair.fst(Array<U32>,C.Choice,C.row_scan(1n+fuel,C.RowLive{x,row,bits,used,boxbase,p,m,size})) == x : Array<U32>},
    L.reify_board(b),image => L.ordinary_row_scan_continue_image(fuel,image,row,bits,used,boxbase,p,m,size,later))

def L.ordinary_row_scan_preserves_board(fuel,state):
  match fuel state:
    case _ C.RowDone{b,p,m,size}:
      {==}
    case 0n C.RowLive{b,row,bits,used,boxbase,p,m,size}:
      {==}
    case 1n+k C.RowLive{b,+row,+bits,+used,+boxbase,+p,+m,+size}:
      L.ordinary_row_scan_continue(k,b,row,bits,used,boxbase,p,m,size,next => L.ordinary_row_scan_preserves_board(k,next))

def L.ordinary_row_begin_from_image(row,index,fuel,image):
  L.ordinary_row_scan_join(fuel,L.image_board(image),
    C.row_scan_start(row,81,0,10,Array.get(U32,L.image_board(image),index)),
    L.row_scan_start_reads_board(L.image_board(image),Array.get(U32,L.image_board(image),index),row,81,0,10,
      L.board_read_witness(L.image_board(image),index)),
    L.ordinary_row_scan_preserves_board(fuel,C.row_scan_start(row,81,0,10,Array.get(U32,L.image_board(image),index))))

def L.ordinary_row_begin_reads_board(b,r,read):
  (same,+start,(kept,observed)) = read
  +row = M.div9(start)
  +index = (81 + row : U32)
  +fuel = U32.to_nat((90 - row : U32))
  %Equal.sym(Array<U32> & U32,r,(same,start),observed) :
    {Pair.fst(Array<U32>,C.Choice,C.row_scan_begin(_)) == b : Array<U32>}
  Equal.trans(Array<U32>,Pair.fst(Array<U32>,C.Choice,C.row_scan_begin((same,start))),same,b,
    L.on_reified_board(same,x => {Pair.fst(Array<U32>,C.Choice,C.row_scan_begin((x,start))) == x : Array<U32>},
      L.reify_board(same),image => L.ordinary_row_begin_from_image(row,index,fuel,image)),kept)

def L.ordinary_production_selector_does_not_write(b):
  L.ordinary_row_begin_reads_board(b,Array.get(U32,b,108),L.board_read_witness(b,108))

def L.queued_advance_keeps_board(b,open,pos,p,m,size,word):
  match open:
    case True{}:
      {==}
    case False{}:
      {==}

def L.queued_inspected_reads_board(b,r,pos,p,m,size,read):
  (same,+word,(kept,observed)) = read
  %Equal.sym(Array<U32> & U32,r,(same,word),observed) :
    {L.scalar_board(Q.inspected(pos,p,m,size,_)) == b : Array<U32>}
  Equal.trans(Array<U32>,L.scalar_board(Q.inspected(pos,p,m,size,(same,word))),same,b,
    L.queued_advance_keeps_board(same,(word < 1024 : U32),pos,p,m,size,word),kept)

def L.queued_urgent_reads_board(b,r,pos,read):
  (same,+word,(kept,observed)) = read
  %Equal.sym(Array<U32> & U32,r,(same,word),observed) :
    {Pair.fst(Array<U32>,C.Choice,Q.urgent(pos,_)) == b : Array<U32>}
  kept

def L.queue_fixed_raw_word_is_closed(d,nonblank):
  match d:
    case L.D0{}:
      Empty.absurd({(L.fixed_word(L.D0{}) < 1024 : U32) == False{} : Bool},
        L.false_is_not_true(Equal.sym(Bool,True{},False{},nonblank)))
    case L.D1{}:
      {==}
    case L.D2{}:
      {==}
    case L.D3{}:
      {==}
    case L.D4{}:
      {==}
    case L.D5{}:
      {==}
    case L.D6{}:
      {==}
    case L.D7{}:
      {==}
    case L.D8{}:
      {==}
    case L.D9{}:
      {==}

def L.queued_scan_skips_fixed_word(b,pos,p,m,size,d,nonblank):
  %Equal.sym(Bool,(L.fixed_word(d) < 1024 : U32),False{},L.queue_fixed_raw_word_is_closed(d,nonblank)) :
    {Q.advance(_,pos,p,m,size,b,L.fixed_word(d)) == (b,(p,(m,size))) : Array<U32> & U32 & U32 & U32}
  {==}

def L.queued_scan_step_preserves_from_image(n,pos,p,m,size,image,later):
  got = Q.inspected(pos,p,m,size,Array.get(U32,L.image_board(image),pos))
  Equal.trans(Array<U32>,L.selector_board(Q.scan(n,(pos + 1 : U32),got)),L.scalar_board(got),L.image_board(image),
    later(got),
    L.queued_inspected_reads_board(L.image_board(image),Array.get(U32,L.image_board(image),pos),pos,p,m,size,
      L.board_read_witness(L.image_board(image),pos)))

def L.queued_scan_step_preserves(n,pos,p,m,size,b,later):
  L.on_reified_board(b,x =>
    {L.selector_board(Q.scan(n,(pos + 1 : U32),Q.inspected(pos,p,m,size,Array.get(U32,x,pos)))) == x : Array<U32>},
    L.reify_board(b),image => L.queued_scan_step_preserves_from_image(n,pos,p,m,size,image,later))

# Match the scan's three literal terminal sizes. Every other word either
# has both low bits set or has a first set bit somewhere above bit 1.
def L.queued_scan_zero_keeps(pos,b,p,m,size):
  match size:
    case 0:
      {==}
    case 1:
      {==}
    case 2:
      {==}
    case U32{WCon{True{},WCon{True{},rest}}}:
      {==}
    case U32{WCon{False{},WCon{False{},WCon{True{}, rest}}}}:
      {==}
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{True{}, rest}}}}}:
      {==}
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}:
      {==}
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}:
      {==}
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}:
      {==}
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}:
      {==}
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}:
      {==}
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}:
      {==}
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{True{},WCon{False{},WCon{True{}, rest}}}}:
      {==}
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{True{}, rest}}}}}:
      {==}
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}:
      {==}
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}:
      {==}
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}:
      {==}
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}:
      {==}
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}:
      {==}
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}:
      {==}
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}:
      {==}
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}:
      {==}
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{},WCon{True{},WCon{True{}, rest}}}}:
      {==}
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{True{}, rest}}}}}:
      {==}
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}:
      {==}
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}:
      {==}
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}:
      {==}
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}:
      {==}
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}:
      {==}
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}:
      {==}
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      {==}
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      {==}

def L.queued_scan_succ_keeps(n,pos,p,m,size,b,later):
  match size:
    case 0:
      {==}
    case 1:
      {==}
    case 2:
      {==}
    case U32{WCon{True{},WCon{True{},rest}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{True{},WCon{True{},rest}}},b,later)
    case U32{WCon{False{},WCon{False{},WCon{True{}, rest}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{True{}, rest}}}},b,later)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{True{}, rest}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{True{}, rest}}}}},b,later)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}},b,later)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}},b,later)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}},b,later)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}},b,later)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}},b,later)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}},b,later)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}},b,later)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}},b,later)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}},b,later)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}},b,later)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}},b,later)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}},b,later)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}},b,later)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}},b,later)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}},b,later)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}},b,later)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}},b,later)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}},b,later)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}},b,later)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}},b,later)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}},b,later)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}},b,later)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}},b,later)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}},b,later)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}},b,later)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}},b,later)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}},b,later)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}},b,later)
    case U32{WCon{True{},WCon{False{},WCon{True{}, rest}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{True{}, rest}}}},b,later)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{True{}, rest}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{True{}, rest}}}}},b,later)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}},b,later)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}},b,later)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}},b,later)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}},b,later)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}},b,later)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}},b,later)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}},b,later)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}},b,later)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}},b,later)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}},b,later)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}},b,later)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}},b,later)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}},b,later)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}},b,later)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}},b,later)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}},b,later)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}},b,later)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}},b,later)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}},b,later)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}},b,later)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}},b,later)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}},b,later)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}},b,later)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}},b,later)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}},b,later)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}},b,later)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}},b,later)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}},b,later)
    case U32{WCon{False{},WCon{True{},WCon{True{}, rest}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{True{}, rest}}}},b,later)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{True{}, rest}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{True{}, rest}}}}},b,later)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}},b,later)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}},b,later)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}},b,later)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}},b,later)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}},b,later)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}},b,later)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}},b,later)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}},b,later)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}},b,later)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}},b,later)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}},b,later)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}},b,later)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}},b,later)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}},b,later)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}},b,later)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}},b,later)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}},b,later)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}},b,later)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}},b,later)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}},b,later)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}},b,later)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}},b,later)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}},b,later)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}},b,later)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}},b,later)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}},b,later)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}},b,later)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_scan_step_preserves(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}},b,later)

def L.queued_scan_last_zero(pos,b,p,rest):
  (+m,+size) = rest
  L.queued_scan_zero_keeps(pos,b,p,m,size)

def L.queued_scan_tail_zero(pos,b,tail):
  (+p,rest) = tail
  L.queued_scan_last_zero(pos,b,p,rest)

def L.queued_scan_last_succ(n,pos,b,p,rest,later):
  (+m,+size) = rest
  L.queued_scan_succ_keeps(n,pos,p,m,size,b,later)

def L.queued_scan_tail_succ(n,pos,b,tail,later):
  (+p,rest) = tail
  L.queued_scan_last_succ(n,pos,b,p,rest,later)

def L.queued_scan_tuple_zero(pos,r):
  (b,tail) = r
  L.queued_scan_tail_zero(pos,b,tail)

def L.queued_scan_tuple_succ(n,pos,r,later):
  (b,tail) = r
  L.queued_scan_tail_succ(n,pos,b,tail,later)

def L.queued_scan_reads_board(n,pos,r):
  match n:
    case 0n:
      L.queued_scan_tuple_zero(pos,r)
    case 1n+k:
      L.queued_scan_tuple_succ(k,pos,r,next => L.queued_scan_reads_board(k,(pos + 1 : U32),next))

def L.queued_start_reads_board(b,r,read):
  (same,+pos,(kept,observed)) = read
  %Equal.sym(Array<U32> & U32,r,(same,pos),observed) :
    {L.selector_board(Q.start(_)) == b : Array<U32>}
  Equal.trans(Array<U32>,L.selector_board(Q.start((same,pos))),same,b,
    L.queued_scan_reads_board(U32.to_nat((81 - pos : U32)),pos,(same,(81,(0,10)))),kept)

def L.queued_urgent_from_board(b,p):
  L.queued_urgent_reads_board(b,Array.get(U32,b,p),p,L.board_read_witness(b,p))

def L.queued_flags_empty_reads_start(b,base,r,read):
  (same,+bits,(kept,seen)) = read
  %Equal.sym(Array<U32> & U32,r,(same,bits),seen) :
    {L.selector_board(Q.flags(0n,base,_)) == b : Array<U32>}
  Equal.trans(Array<U32>,L.selector_board(Q.flags(0n,base,(same,bits))),same,b,
    L.queued_start_reads_board(same,Array.get(U32,same,108),L.board_read_witness(same,108)),kept)

def L.queued_flag_word_keeps_board(n,base,b,bits,next):
  match bits:
    case 0:
      next(b)
    case U32{WCon{True{}, rest}}:
      L.queued_urgent_from_board(b,L.urgent_pos(base,U32{WCon{True{}, rest}}))
    case U32{WCon{False{}, WCon{True{}, rest}}}:
      L.queued_urgent_from_board(b,L.urgent_pos(base,U32{WCon{False{}, WCon{True{}, rest}}}))
    case U32{WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}:
      L.queued_urgent_from_board(b,L.urgent_pos(base,U32{WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}:
      L.queued_urgent_from_board(b,L.urgent_pos(base,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}:
      L.queued_urgent_from_board(b,L.urgent_pos(base,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}:
      L.queued_urgent_from_board(b,L.urgent_pos(base,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}:
      L.queued_urgent_from_board(b,L.urgent_pos(base,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}:
      L.queued_urgent_from_board(b,L.urgent_pos(base,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}:
      L.queued_urgent_from_board(b,L.urgent_pos(base,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}:
      L.queued_urgent_from_board(b,L.urgent_pos(base,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}:
      L.queued_urgent_from_board(b,L.urgent_pos(base,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}:
      L.queued_urgent_from_board(b,L.urgent_pos(base,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}:
      L.queued_urgent_from_board(b,L.urgent_pos(base,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}:
      L.queued_urgent_from_board(b,L.urgent_pos(base,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}:
      L.queued_urgent_from_board(b,L.urgent_pos(base,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}:
      L.queued_urgent_from_board(b,L.urgent_pos(base,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}:
      L.queued_urgent_from_board(b,L.urgent_pos(base,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}:
      L.queued_urgent_from_board(b,L.urgent_pos(base,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}:
      L.queued_urgent_from_board(b,L.urgent_pos(base,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}:
      L.queued_urgent_from_board(b,L.urgent_pos(base,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_urgent_from_board(b,L.urgent_pos(base,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_urgent_from_board(b,L.urgent_pos(base,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_urgent_from_board(b,L.urgent_pos(base,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_urgent_from_board(b,L.urgent_pos(base,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_urgent_from_board(b,L.urgent_pos(base,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_urgent_from_board(b,L.urgent_pos(base,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_urgent_from_board(b,L.urgent_pos(base,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_urgent_from_board(b,L.urgent_pos(base,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_urgent_from_board(b,L.urgent_pos(base,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_urgent_from_board(b,L.urgent_pos(base,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_urgent_from_board(b,L.urgent_pos(base,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}))
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_urgent_from_board(b,L.urgent_pos(base,U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}))

def L.queued_flags_step_reads_board(n,base,b,r,read,next):
  (same,+bits,(kept,seen)) = read
  %Equal.sym(Array<U32> & U32,r,(same,bits),seen) :
    {L.selector_board(Q.flags(1n+n,base,_)) == b : Array<U32>}
  Equal.trans(Array<U32>,L.selector_board(Q.flags(1n+n,base,(same,bits))),same,b,
    L.queued_flag_word_keeps_board(n,base,same,bits,next),kept)

def L.queued_flags_reads_board(n,base,b,r,read):
  match n:
    case 0n:
      L.queued_flags_empty_reads_start(b,base,r,read)
    case 1n+k:
      L.queued_flags_step_reads_board(k,base,b,r,read,
        x => L.queued_flags_reads_board(k,(base + 32 : U32),x,
          Array.get(U32,x,(110 + U32.shrn(base,5n) : U32)),
          L.board_read_witness(x,(110 + U32.shrn(base,5n) : U32))))

def L.queued_production_selector_does_not_write(b):
  L.queued_flags_reads_board(3n,0,b,Array.get(U32,b,109),L.board_read_witness(b,109))

def L.adaptive_selector_does_not_write(active,b):
  match active:
    case False{}:
      L.ordinary_production_selector_does_not_write(b)
    case True{}:
      L.queued_production_selector_does_not_write(b)

def L.queued_urgent_mask_zero_reports_zero(b,p):
  {==}

def L.queued_urgent_singleton_reports_exact_count(b,p,mask,nonempty,one):
  %Equal.sym(Bool,U32.is_eq(mask,0),False{},nonempty) :
    {C.Choice{p,mask,Bool.pick(U32,_,0,1)} == C.Choice{p,mask,C.mask_count(mask)} : C.Choice}
  %Equal.sym(U32,C.mask_count(mask),1,one) :
    {C.Choice{p,mask,1} == C.Choice{p,mask,_} : C.Choice}
  {==}

def L.queued_late_pointer_hides_existing_blank():
  ({==},{==})

def L.queued_valid_start_finds_pair():
  {==}

def L.queued_false_urgent_flag_underreports_pair():
  ({==},{==})

def L.flag_present_at_known_lowest(w,index,seen):
  %seen : {U32.and(_,U32{w}) == _ : U32}
  L.lowest_bit_is_present(w)

def L.first_flag_pack(w,index,bound,offset,seen):
  (index,(bound,(offset,L.flag_present_at_known_lowest(w,index,seen))))

def L.first_flag_from_lowest_pair(w,index,bound,seen,math):
  (for_offset,for_presence) = seen
  L.first_flag_pack(w,index,bound,
    Equal.trans(U32,L.flag_offset(U32{w}),Q.trailing(U32.shrn((L.flag_bit_at(index) * 125613361 : U32),27n)),index,
      Equal.cong(U32,U32,one => Q.trailing(U32.shrn((one * 125613361 : U32),27n)),L.lowest_bit(U32{w}),L.flag_bit_at(index),for_offset),math),
    for_presence)

def L.first_flag_at_known_index(w,index,bound,first,math):
  L.first_flag_from_lowest_pair(w,index,bound,
    L.copy_word_eq(L.lowest_bit(U32{w}),L.flag_bit_at(index),
      Equal.trans(U32,L.lowest_bit(U32{w}),U32{L.first_one_word(32n,w)},L.flag_bit_at(index),
        L.u32_first_one_is_lowest_bit(w),first)),math)

def L.queued_urgent_math_selects_present_flag(bits,nonzero):
  match bits:
    case 0:
      Empty.absurd(L.FirstFlag(0),L.false_is_not_true(Equal.sym(Bool,True{},False{},nonzero)))
    case U32{WCon{True{}, rest}}:
      L.first_flag_at_known_index(WCon{True{}, rest},0,{==},{==},{==})
    case U32{WCon{False{}, WCon{True{}, rest}}}:
      L.first_flag_at_known_index(WCon{False{}, WCon{True{}, rest}},1,{==},{==},{==})
    case U32{WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}:
      L.first_flag_at_known_index(WCon{False{}, WCon{False{}, WCon{True{}, rest}}},2,{==},{==},{==})
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}:
      L.first_flag_at_known_index(WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}},3,{==},{==},{==})
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}:
      L.first_flag_at_known_index(WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}},4,{==},{==},{==})
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}:
      L.first_flag_at_known_index(WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}},5,{==},{==},{==})
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}:
      L.first_flag_at_known_index(WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}},6,{==},{==},{==})
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}:
      L.first_flag_at_known_index(WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}},7,{==},{==},{==})
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}:
      L.first_flag_at_known_index(WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}},8,{==},{==},{==})
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}:
      L.first_flag_at_known_index(WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}},9,{==},{==},{==})
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}:
      L.first_flag_at_known_index(WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}},10,{==},{==},{==})
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}:
      L.first_flag_at_known_index(WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}},11,{==},{==},{==})
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}:
      L.first_flag_at_known_index(WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}},12,{==},{==},{==})
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}:
      L.first_flag_at_known_index(WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}},13,{==},{==},{==})
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}:
      L.first_flag_at_known_index(WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}},14,{==},{==},{==})
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}:
      L.first_flag_at_known_index(WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}},15,{==},{==},{==})
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}:
      L.first_flag_at_known_index(WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}},16,{==},{==},{==})
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}:
      L.first_flag_at_known_index(WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}},17,{==},{==},{==})
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}:
      L.first_flag_at_known_index(WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}},18,{==},{==},{==})
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}:
      L.first_flag_at_known_index(WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}},19,{==},{==},{==})
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}:
      L.first_flag_at_known_index(WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}},20,{==},{==},{==})
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}:
      L.first_flag_at_known_index(WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}},21,{==},{==},{==})
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}:
      L.first_flag_at_known_index(WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}},22,{==},{==},{==})
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.first_flag_at_known_index(WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}},23,{==},{==},{==})
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.first_flag_at_known_index(WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}},24,{==},{==},{==})
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.first_flag_at_known_index(WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}},25,{==},{==},{==})
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.first_flag_at_known_index(WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}},26,{==},{==},{==})
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.first_flag_at_known_index(WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}},27,{==},{==},{==})
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.first_flag_at_known_index(WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}},28,{==},{==},{==})
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.first_flag_at_known_index(WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}},29,{==},{==},{==})
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.first_flag_at_known_index(WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}},30,{==},{==},{==})
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.first_flag_at_known_index(WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}},31,{==},{==},{==})

def L.urgent_position_from_flag_witness(board,base,bits,flags,chosen):
  (+index,(bound,(offset,present))) = chosen
  %Equal.sym(U32,L.flag_offset(bits),index,offset) :
    L.QueuedVacantAt(board,(base + _ : U32))
  flags(index,bound,present)

def L.sound_flags_point_to_vacancy(board,base,bits,flags,nonempty):
  L.urgent_position_from_flag_witness(board,base,bits,flags,L.queued_urgent_math_selects_present_flag(bits,nonempty))

def L.queued_choose_between_valid_positions(b,take,pos,best,current,prior):
  match take:
    case True{}:
      current
    case False{}:
      prior

def L.queued_advance_position_is_valid(b,open,pos,p,mask,size,word,current,prior):
  match open:
    case False{}:
      prior
    case True{}:
      L.queued_choose_between_valid_positions(b,(C.scalar_size(word) < size : U32),pos,p,Inr{current({==})},prior)

def L.queued_vacancy_from_read_word(b,pos,word,pos_ok,observe,open):
  (pos_ok,Equal.trans(Bool,(L.cell_value(b,pos) < 1024 : U32),(word < 1024 : U32),True{},
    Equal.cong(U32,Bool,w => (w < 1024 : U32),L.cell_value(b,pos),word,observe),open))

def L.duplicate_queued_read_equality(lhs,rhs,same):
  %same : ({lhs == _ : Array<U32> & U32} & {lhs == _ : Array<U32> & U32})
  ({==},{==})

def L.queued_inspected_with_real_word(b,pos,p,mask,size,word,pos_ok,observed,prior):
  (for_read,for_cell) = observed
  %Equal.sym(Array<U32> & U32,Array.get(U32,b,pos),(b,word),for_read) :
    L.QueuedChoicePosition(b,L.scalar_choice_position(Q.inspected(pos,p,mask,size,_)))
  L.queued_advance_position_is_valid(b,(word < 1024 : U32),pos,p,mask,size,word,
    open => L.queued_vacancy_from_read_word(b,pos,word,pos_ok,
      Equal.cong(Array<U32> & U32,U32,r => Pair.snd(Array<U32>,U32,r),Array.get(U32,b,pos),(b,word),for_cell),open),prior)

def L.queued_inspect_from_same_board(b,pos,p,mask,size,same,word,pos_ok,same_board,observed,prior):
  next : ({Array.get(U32,b,pos) == (same,word) : Array<U32> & U32} ->
    L.QueuedChoicePosition(b,L.scalar_choice_position(Q.inspected(pos,p,mask,size,Array.get(U32,b,pos))))) =
    %Equal.sym(Array<U32>,same,b,same_board) :
      ({Array.get(U32,b,pos) == (_,word) : Array<U32> & U32} ->
        L.QueuedChoicePosition(b,L.scalar_choice_position(Q.inspected(pos,p,mask,size,Array.get(U32,b,pos)))))
    eq => L.queued_inspected_with_real_word(b,pos,p,mask,size,word,pos_ok,
      L.duplicate_queued_read_equality(Array.get(U32,b,pos),(b,word),eq),prior)
  next(observed)

def L.queued_inspect_from_witness(b,pos,p,mask,size,pos_ok,observed,prior):
  (same,+word,(same_board,read)) = observed
  L.queued_inspect_from_same_board(b,pos,p,mask,size,same,word,pos_ok,same_board,read,prior)

def L.queued_inspection_preserves_valid_position(b,pos,p,mask,size,pos_ok,prior):
  L.queued_inspect_from_witness(b,pos,p,mask,size,pos_ok,L.board_read_witness(b,pos),prior)

def L.queued_out_of_contract_full_mask_can_leave_sentinel():
  ({==},({==},{==}))

def L.queued_safe_scan_transport(n,pos,b,next,same,safe,range,continue):
  lift : (L.QueuedChoicePosition(b,L.scalar_choice_position(next)) ->
    L.QueuedChoicePosition(b,L.selector_position(Q.scan(n,(pos + 1 : U32),next)))) =
    %same :
      (L.QueuedChoicePosition(_,L.scalar_choice_position(next)) ->
       L.QueuedChoicePosition(_,L.selector_position(Q.scan(n,(pos + 1 : U32),next))))
    proof => continue(next,range,proof)
  lift(safe)

def L.queued_safe_scan_step_image(n,pos,p,mask,size,image,range,prior,continue):
  (pos_ok,tail) = range
  L.queued_safe_scan_transport(n,pos,L.image_board(image),
    Q.inspected(pos,p,mask,size,Array.get(U32,L.image_board(image),pos)),
    L.queued_inspected_reads_board(L.image_board(image),Array.get(U32,L.image_board(image),pos),pos,p,mask,size,
      L.board_read_witness(L.image_board(image),pos)),
    L.queued_inspection_preserves_valid_position(L.image_board(image),pos,p,mask,size,pos_ok,prior),tail,continue)

def L.queued_safe_scan_step(n,pos,p,mask,size,b,range,prior,continue):
  proof : (L.QueuedScanRange(1n+n,pos) -> L.QueuedChoicePosition(b,p) -> L.QueuedNextSafe(n,pos) ->
    L.QueuedChoicePosition(b,L.selector_position(Q.scan(n,(pos + 1 : U32),Q.inspected(pos,p,mask,size,Array.get(U32,b,pos)))))) =
    L.on_reified_board(b,x =>
      (L.QueuedScanRange(1n+n,pos) -> L.QueuedChoicePosition(x,p) -> L.QueuedNextSafe(n,pos) ->
        L.QueuedChoicePosition(x,L.selector_position(Q.scan(n,(pos + 1 : U32),Q.inspected(pos,p,mask,size,Array.get(U32,x,pos)))))),
      L.reify_board(b),image => L.queued_safe_scan_step_image(n,pos,p,mask,size,image))
  proof(range,prior,continue)

def L.queued_safe_zero(pos,b,p,m,size,prior):
  match size:
    case 0:
      prior
    case 1:
      prior
    case 2:
      prior
    case U32{WCon{True{},WCon{True{},rest}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{True{}, rest}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{True{}, rest}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{True{}, rest}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{True{}, rest}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{True{}, rest}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{True{}, rest}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      prior

def L.queued_safe_succ(n,pos,p,m,size,b,range,prior,continue):
  match size:
    case 0:
      prior
    case 1:
      prior
    case 2:
      prior
    case U32{WCon{True{},WCon{True{},rest}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{True{},WCon{True{},rest}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{True{}, rest}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{True{}, rest}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{True{}, rest}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{True{}, rest}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{True{}, rest}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{True{}, rest}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{True{}, rest}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{True{}, rest}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{True{}, rest}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{True{}, rest}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{True{}, rest}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{True{}, rest}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_safe_scan_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)


def L.queued_safe_last_zero(pos,b,p,rest):
  (+m,+size) = rest
  range => prior => L.queued_safe_zero(pos,b,p,m,size,prior)

def L.queued_safe_tail_zero(pos,b,tail):
  (+p,rest) = tail
  L.queued_safe_last_zero(pos,b,p,rest)

def L.queued_safe_tuple_zero(pos,r):
  (b,tail) = r
  L.queued_safe_tail_zero(pos,b,tail)

def L.queued_safe_last_succ(n,pos,b,p,rest,continue):
  (+m,+size) = rest
  range => prior => L.queued_safe_succ(n,pos,p,m,size,b,range,prior,continue)

def L.queued_safe_tail_succ(n,pos,b,tail,continue):
  (+p,rest) = tail
  L.queued_safe_last_succ(n,pos,b,p,rest,continue)

def L.queued_safe_tuple_succ(n,pos,r,continue):
  (b,tail) = r
  L.queued_safe_tail_succ(n,pos,b,tail,continue)

def L.queued_safe_scan(n,pos,r):
  match n:
    case 0n:
      L.queued_safe_tuple_zero(pos,r)
    case 1n+k:
      L.queued_safe_tuple_succ(k,pos,r,next => L.queued_safe_scan(k,(pos + 1 : U32),next))

def L.queued_safe_start(b,pos,range):
  L.queued_safe_scan(U32.to_nat((81 - pos : U32)),pos,(b,(81,(0,10))))(range,Inl{{==}})

def L.queued_guard_step(n,pos,tail,next):
  (pos_ok,range_ok) = tail
  (pos_ok,next(range_ok))

def L.queued_range_guard_sound(n,pos,checked):
  match n:
    case 0n:
      Unit{}
    case 1n+k:
      L.queued_guard_step(k,pos,L.both_true((pos < 81 : U32),L.queued_range_guard(k,(pos + 1 : U32)),checked),
        tail => L.queued_range_guard_sound(k,(pos + 1 : U32),tail))

def L.queued_start_guard_row_0(col):
  match col:
    case L.Coordinate0{}:
      {==}
    case L.Coordinate1{}:
      {==}
    case L.Coordinate2{}:
      {==}
    case L.Coordinate3{}:
      {==}
    case L.Coordinate4{}:
      {==}
    case L.Coordinate5{}:
      {==}
    case L.Coordinate6{}:
      {==}
    case L.Coordinate7{}:
      {==}
    case L.Coordinate8{}:
      {==}

def L.queued_start_guard_row_1(col):
  match col:
    case L.Coordinate0{}:
      {==}
    case L.Coordinate1{}:
      {==}
    case L.Coordinate2{}:
      {==}
    case L.Coordinate3{}:
      {==}
    case L.Coordinate4{}:
      {==}
    case L.Coordinate5{}:
      {==}
    case L.Coordinate6{}:
      {==}
    case L.Coordinate7{}:
      {==}
    case L.Coordinate8{}:
      {==}

def L.queued_start_guard_row_2(col):
  match col:
    case L.Coordinate0{}:
      {==}
    case L.Coordinate1{}:
      {==}
    case L.Coordinate2{}:
      {==}
    case L.Coordinate3{}:
      {==}
    case L.Coordinate4{}:
      {==}
    case L.Coordinate5{}:
      {==}
    case L.Coordinate6{}:
      {==}
    case L.Coordinate7{}:
      {==}
    case L.Coordinate8{}:
      {==}

def L.queued_start_guard_row_3(col):
  match col:
    case L.Coordinate0{}:
      {==}
    case L.Coordinate1{}:
      {==}
    case L.Coordinate2{}:
      {==}
    case L.Coordinate3{}:
      {==}
    case L.Coordinate4{}:
      {==}
    case L.Coordinate5{}:
      {==}
    case L.Coordinate6{}:
      {==}
    case L.Coordinate7{}:
      {==}
    case L.Coordinate8{}:
      {==}

def L.queued_start_guard_row_4(col):
  match col:
    case L.Coordinate0{}:
      {==}
    case L.Coordinate1{}:
      {==}
    case L.Coordinate2{}:
      {==}
    case L.Coordinate3{}:
      {==}
    case L.Coordinate4{}:
      {==}
    case L.Coordinate5{}:
      {==}
    case L.Coordinate6{}:
      {==}
    case L.Coordinate7{}:
      {==}
    case L.Coordinate8{}:
      {==}

def L.queued_start_guard_row_5(col):
  match col:
    case L.Coordinate0{}:
      {==}
    case L.Coordinate1{}:
      {==}
    case L.Coordinate2{}:
      {==}
    case L.Coordinate3{}:
      {==}
    case L.Coordinate4{}:
      {==}
    case L.Coordinate5{}:
      {==}
    case L.Coordinate6{}:
      {==}
    case L.Coordinate7{}:
      {==}
    case L.Coordinate8{}:
      {==}

def L.queued_start_guard_row_6(col):
  match col:
    case L.Coordinate0{}:
      {==}
    case L.Coordinate1{}:
      {==}
    case L.Coordinate2{}:
      {==}
    case L.Coordinate3{}:
      {==}
    case L.Coordinate4{}:
      {==}
    case L.Coordinate5{}:
      {==}
    case L.Coordinate6{}:
      {==}
    case L.Coordinate7{}:
      {==}
    case L.Coordinate8{}:
      {==}

def L.queued_start_guard_row_7(col):
  match col:
    case L.Coordinate0{}:
      {==}
    case L.Coordinate1{}:
      {==}
    case L.Coordinate2{}:
      {==}
    case L.Coordinate3{}:
      {==}
    case L.Coordinate4{}:
      {==}
    case L.Coordinate5{}:
      {==}
    case L.Coordinate6{}:
      {==}
    case L.Coordinate7{}:
      {==}
    case L.Coordinate8{}:
      {==}

def L.queued_start_guard_row_8(col):
  match col:
    case L.Coordinate0{}:
      {==}
    case L.Coordinate1{}:
      {==}
    case L.Coordinate2{}:
      {==}
    case L.Coordinate3{}:
      {==}
    case L.Coordinate4{}:
      {==}
    case L.Coordinate5{}:
      {==}
    case L.Coordinate6{}:
      {==}
    case L.Coordinate7{}:
      {==}
    case L.Coordinate8{}:
      {==}

def L.queued_start_guard_every_cell(row,col):
  match row:
    case L.Coordinate0{}:
      L.queued_start_guard_row_0(col)
    case L.Coordinate1{}:
      L.queued_start_guard_row_1(col)
    case L.Coordinate2{}:
      L.queued_start_guard_row_2(col)
    case L.Coordinate3{}:
      L.queued_start_guard_row_3(col)
    case L.Coordinate4{}:
      L.queued_start_guard_row_4(col)
    case L.Coordinate5{}:
      L.queued_start_guard_row_5(col)
    case L.Coordinate6{}:
      L.queued_start_guard_row_6(col)
    case L.Coordinate7{}:
      L.queued_start_guard_row_7(col)
    case L.Coordinate8{}:
      L.queued_start_guard_row_8(col)

def L.queued_logical_start_range(row,col):
  +pos = L.logical_position(row,col)
  L.queued_range_guard_sound(U32.to_nat((81 - pos : U32)),pos,L.queued_start_guard_every_cell(row,col))

def L.queued_logical_start_selects_only_vacancy_or_sentinel(b,row,col):
  L.queued_safe_start(b,L.logical_position(row,col),L.queued_logical_start_range(row,col))

def L.queued_end_start_returns_completion_marker(b):
  {==}

def L.queued_in_range_not_completed(pos,good):
  no : ({pos == 81 : U32} -> {(pos < 81 : U32) == True{} : Bool} -> Empty) =
    same =>
      %Equal.sym(U32,pos,81,same) : ({(_ < 81 : U32) == True{} : Bool} -> Empty)
      bad => L.false_is_not_true(bad)
  same => no(same,good)

def L.queued_pick_keeps_non_sentinel(take,pos,best,now,old):
  match take:
    case True{}:
      now
    case False{}:
      old

def L.queued_advance_keeps_non_sentinel(b,open,pos,p,m,size,word,now,old):
  match open:
    case True{}:
      L.queued_pick_keeps_non_sentinel((C.scalar_size(word) < size : U32),pos,p,now,old)
    case False{}:
      old

def L.queued_inspected_keeps_non_sentinel(b,r,pos,p,m,size,now,old,read):
  (same,+word,(unchanged,seen)) = read
  %Equal.sym(Array<U32> & U32,r,(same,word),seen) :
    L.NotCompleted(L.scalar_choice_position(Q.inspected(pos,p,m,size,_)))
  L.queued_advance_keeps_non_sentinel(same,(word < 1024 : U32),pos,p,m,size,word,now,old)

def L.queued_read_keeps_non_sentinel(b,pos,p,m,size,in_range,old):
  L.queued_inspected_keeps_non_sentinel(b,Array.get(U32,b,pos),pos,p,m,size,
    L.queued_in_range_not_completed(pos,in_range),old,L.board_read_witness(b,pos))

def L.queued_eligible_raw_beats_no_candidate(b,pos,word,open,better):
  %Equal.sym(Bool,(word < 1024 : U32),True{},open) :
    {L.scalar_choice_position(Q.advance(_,pos,81,0,10,b,word)) == pos : U32}
  %Equal.sym(Bool,(C.scalar_size(word) < 10 : U32),True{},better) :
    {Bool.pick(U32,_,pos,81) == pos : U32}
  {==}

def L.queued_seen_step_image(n,pos,p,m,size,image,range,old,later):
  (in_range,tail) = range
  later(Q.inspected(pos,p,m,size,Array.get(U32,L.image_board(image),pos)),tail,
    L.queued_read_keeps_non_sentinel(L.image_board(image),pos,p,m,size,in_range,old))

def L.queued_seen_step(n,pos,p,m,size,b,range,old,later):
  carry : (L.QueuedScanRange(1n+n,pos) -> L.NotCompleted(p) -> L.QueuedNextSeen(n,pos) ->
    L.NotCompleted(L.selector_position(Q.scan(n,(pos + 1 : U32),Q.inspected(pos,p,m,size,Array.get(U32,b,pos)))))) =
    L.on_reified_board(b,x =>
      (L.QueuedScanRange(1n+n,pos) -> L.NotCompleted(p) -> L.QueuedNextSeen(n,pos) ->
        L.NotCompleted(L.selector_position(Q.scan(n,(pos + 1 : U32),Q.inspected(pos,p,m,size,Array.get(U32,x,pos)))))),
      L.reify_board(b),image => L.queued_seen_step_image(n,pos,p,m,size,image))
  carry(range,old,later)

def L.queued_seen_zero(pos,b,p,m,size,prior):
  match size:
    case 0:
      prior
    case 1:
      prior
    case 2:
      prior
    case U32{WCon{True{},WCon{True{},rest}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{True{}, rest}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{True{}, rest}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{True{}, rest}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{True{}, rest}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{True{}, rest}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{True{}, rest}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      prior
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      prior

def L.queued_seen_succ(n,pos,p,m,size,b,range,prior,continue):
  match size:
    case 0:
      prior
    case 1:
      prior
    case 2:
      prior
    case U32{WCon{True{},WCon{True{},rest}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{True{},WCon{True{},rest}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{True{}, rest}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{True{}, rest}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{True{}, rest}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{True{}, rest}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{True{}, rest}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{True{}, rest}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{True{}, rest}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{True{}, rest}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{True{},WCon{False{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{True{}, rest}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{True{}, rest}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{True{}, rest}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{True{}, rest}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)
    case U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      L.queued_seen_step(n,pos,p,m,U32{WCon{False{},WCon{True{},WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, WNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}},b,range,prior,continue)


def L.queued_seen_last_zero(pos,b,p,rest):
  (+m,+size) = rest
  range => prior => L.queued_seen_zero(pos,b,p,m,size,prior)

def L.queued_seen_tail_zero(pos,b,tail):
  (+p,rest) = tail
  L.queued_seen_last_zero(pos,b,p,rest)

def L.queued_seen_tuple_zero(pos,r):
  (b,tail) = r
  L.queued_seen_tail_zero(pos,b,tail)

def L.queued_seen_last_succ(n,pos,b,p,rest,continue):
  (+m,+size) = rest
  range => prior => L.queued_seen_succ(n,pos,p,m,size,b,range,prior,continue)

def L.queued_seen_tail_succ(n,pos,b,tail,continue):
  (+p,rest) = tail
  L.queued_seen_last_succ(n,pos,b,p,rest,continue)

def L.queued_seen_tuple_succ(n,pos,r,continue):
  (b,tail) = r
  L.queued_seen_tail_succ(n,pos,b,tail,continue)

def L.queued_seen_scan(n,pos,r):
  match n:
    case 0n:
      L.queued_seen_tuple_zero(pos,r)
    case 1n+k:
      L.queued_seen_tuple_succ(k,pos,r,next => L.queued_seen_scan(k,(pos + 1 : U32),next))


def L.queued_eligible_actual_initial_non_sentinel(b,pos,word,range,yes):
  (open,better) = yes
  %Equal.sym(U32,L.scalar_choice_position(Q.inspected(pos,81,0,10,(b,word))),pos,
    L.queued_eligible_raw_beats_no_candidate(b,pos,word,open,better)) :
    L.NotCompleted(_)
  L.queued_in_range_not_completed(pos,range)

def L.queued_initial_closed_keeps_tuple(b,pos,word,closed):
  %Equal.sym(Bool,(word < 1024 : U32),False{},closed) :
    {Q.advance(_,pos,81,0,10,b,word) == L.QueueInitial(b) : L.QueuedScanTuple()}
  {==}

def L.queued_initial_not_better_keeps_tuple(b,pos,word,open,size):
  %Equal.sym(Bool,(word < 1024 : U32),True{},open) :
    {Q.advance(_,pos,81,0,10,b,word) == L.QueueInitial(b) : L.QueuedScanTuple()}
  %Equal.sym(Bool,(C.scalar_size(word) < 10 : U32),False{},size) :
    {(b,(Bool.pick(U32,_,pos,81),(Bool.pick(U32,_,word,0),Bool.pick(U32,_,C.scalar_size(word),10)))) ==
      L.QueueInitial(b) : L.QueuedScanTuple()}
  {==}

def L.queued_initial_step_size(b,pos,word,small,range,open,size):
  match small:
    case True{}:
      Inl{L.queued_eligible_actual_initial_non_sentinel(b,pos,word,range,(open,size))}
    case False{}:
      Inr{L.queued_initial_not_better_keeps_tuple(b,pos,word,open,size)}

def L.queued_initial_step_open(b,pos,word,open,range,observed):
  match open:
    case False{}:
      Inr{L.queued_initial_closed_keeps_tuple(b,pos,word,observed)}
    case True{}:
      L.queued_initial_step_size(b,pos,word,(C.scalar_size(word) < 10 : U32),range,observed,{==})

def L.queued_initial_step_classifies(b,pos,word,range):
  L.queued_initial_step_open(b,pos,word,(word < 1024 : U32),range,{==})

def L.queued_eligible_word_from_read(b,pos,word,observe,proof):
  %observe : L.QueueEligibleWord(_)
  proof

def L.queued_progress_decision(image,n,pos,word,range,tail,step,later):
  match step:
    case Inl{chosen}:
      L.queued_seen_scan(n,(pos + 1 : U32),Q.inspected(pos,81,0,10,(L.image_board(image),word)))(range,chosen)
    case Inr{same}:
      %Equal.sym(L.QueuedScanTuple(),Q.inspected(pos,81,0,10,(L.image_board(image),word)),L.QueueInitial(L.image_board(image)),same) :
        L.NotCompleted(L.selector_position(Q.scan(n,(pos + 1 : U32),_)))
      later(L.image_board(image),range,tail)

def L.queued_progress_use_witness(image,n,pos,word,real,in_range,range,has_one,later):
  match has_one:
    case Inl{first}:
      L.queued_seen_scan(n,(pos + 1 : U32),Q.inspected(pos,81,0,10,(L.image_board(image),word)))(range,
        L.queued_eligible_actual_initial_non_sentinel(L.image_board(image),pos,word,in_range,
          L.queued_eligible_word_from_read(L.image_board(image),pos,word,real,first)))
    case Inr{tail}:
      L.queued_progress_decision(image,n,pos,word,range,tail,L.queued_initial_step_classifies(L.image_board(image),pos,word,in_range),later)

def L.queued_progress_real_word(image,n,pos,word,interval,has_one,observed,later):
  (pos_ok,range) = interval
  (for_step,for_value) = observed
  %Equal.sym(Array<U32> & U32,Array.get(U32,L.image_board(image),pos),(L.image_board(image),word),for_step) :
    L.NotCompleted(L.selector_position(Q.scan(n,(pos + 1 : U32),Q.inspected(pos,81,0,10,_))))
  L.queued_progress_use_witness(image,n,pos,word,
    Equal.cong(Array<U32> & U32,U32,r => Pair.snd(Array<U32>,U32,r),Array.get(U32,L.image_board(image),pos),
      (L.image_board(image),word),for_value),pos_ok,range,has_one,later)

def L.queued_progress_observed(image,n,pos,interval,has_one,observed,later):
  (same,+word,(same_board,read)) = observed
  use : ({Array.get(U32,L.image_board(image),pos) == (same,word) : Array<U32> & U32} ->
    L.NotCompleted(L.selector_position(Q.scan(1n+n,pos,L.QueueInitial(L.image_board(image)))))) =
    %Equal.sym(Array<U32>,same,L.image_board(image),same_board) :
      ({Array.get(U32,L.image_board(image),pos) == (_,word) : Array<U32> & U32} ->
        L.NotCompleted(L.selector_position(Q.scan(1n+n,pos,L.QueueInitial(L.image_board(image))))))
    read_eq => L.queued_progress_real_word(image,n,pos,word,interval,has_one,
      L.duplicate_queued_read_equality(Array.get(U32,L.image_board(image),pos),(L.image_board(image),word),read_eq),later)
  use(read)

def L.queued_initial_progress_image(image,n,pos,later):
  interval => has_one => L.queued_progress_observed(image,n,pos,interval,has_one,L.board_read_witness(L.image_board(image),pos),later)

def L.queued_initial_progress_step(b,n,pos,later):
  L.on_reified_board(b,x => L.QueuedInitialScanProgress(x,1n+n,pos),
    L.reify_board(b),image => L.queued_initial_progress_image(image,n,pos,later))

def L.queued_scan_cannot_hide_eligible(n,pos,b):
  match n:
    case 0n:
      range => has_one => Empty.absurd(L.NotCompleted(L.selector_position(Q.scan(0n,pos,L.QueueInitial(b)))),has_one)
    case 1n+k:
      L.queued_initial_progress_step(b,k,pos,next => L.queued_scan_cannot_hide_eligible(k,(pos + 1 : U32),next))

def L.queued_logical_start_cannot_hide_eligible(b,row,col,exists):
  +pos = L.logical_position(row,col)
  L.queued_scan_cannot_hide_eligible(U32.to_nat((81 - pos : U32)),pos,b)(L.queued_logical_start_range(row,col),exists)

def L.queued_eligible_at_window_middle(before,b,start,after,witness):
  match before:
    case 0n:
      Inl{witness}
    case 1n+k:
      Inr{L.queued_eligible_at_window_middle(k,b,(start + 1 : U32),after,witness)}

def L.queued_scanned_eligible_prevents_completion(b,start,before,after,range,witness):
  L.queued_scan_cannot_hide_eligible(L.with_center(before,after),start,b)(range,
    L.queued_eligible_at_window_middle(before,b,start,after,witness))

def L.queued_completion_conflicts_with_eligible(b,row,col,exists,completed):
  L.queued_logical_start_cannot_hide_eligible(b,row,col,exists)(completed)

def L.check_candidate_eligibility_tree_9(b0,b1,b2,b3,b4,b5,b6,b7,b8,suffix,checked):
  match suffix:
    case WNil{}:
      checked

def L.select_eligibility_subtree_8(b0,b1,b2,b3,b4,b5,b6,b7,bit,both):
  match bit:
    case False{}:
      Pair.fst({L.candidate_eligibility_tree_9(b0,b1,b2,b3,b4,b5,b6,b7,False{}) == True{} : Bool},{L.candidate_eligibility_tree_9(b0,b1,b2,b3,b4,b5,b6,b7,True{}) == True{} : Bool},both)
    case True{}:
      Pair.snd({L.candidate_eligibility_tree_9(b0,b1,b2,b3,b4,b5,b6,b7,False{}) == True{} : Bool},{L.candidate_eligibility_tree_9(b0,b1,b2,b3,b4,b5,b6,b7,True{}) == True{} : Bool},both)

def L.check_candidate_eligibility_tree_8(b0,b1,b2,b3,b4,b5,b6,b7,suffix,checked):
  match suffix:
    case WCon{+bit,+rest}:
      L.check_candidate_eligibility_tree_9(b0,b1,b2,b3,b4,b5,b6,b7,bit,rest,
        L.select_eligibility_subtree_8(b0,b1,b2,b3,b4,b5,b6,b7,bit,
          L.both_true(L.candidate_eligibility_tree_9(b0,b1,b2,b3,b4,b5,b6,b7,False{}),L.candidate_eligibility_tree_9(b0,b1,b2,b3,b4,b5,b6,b7,True{}),checked)))

def L.select_eligibility_subtree_7(b0,b1,b2,b3,b4,b5,b6,bit,both):
  match bit:
    case False{}:
      Pair.fst({L.candidate_eligibility_tree_8(b0,b1,b2,b3,b4,b5,b6,False{}) == True{} : Bool},{L.candidate_eligibility_tree_8(b0,b1,b2,b3,b4,b5,b6,True{}) == True{} : Bool},both)
    case True{}:
      Pair.snd({L.candidate_eligibility_tree_8(b0,b1,b2,b3,b4,b5,b6,False{}) == True{} : Bool},{L.candidate_eligibility_tree_8(b0,b1,b2,b3,b4,b5,b6,True{}) == True{} : Bool},both)

def L.check_candidate_eligibility_tree_7(b0,b1,b2,b3,b4,b5,b6,suffix,checked):
  match suffix:
    case WCon{+bit,+rest}:
      L.check_candidate_eligibility_tree_8(b0,b1,b2,b3,b4,b5,b6,bit,rest,
        L.select_eligibility_subtree_7(b0,b1,b2,b3,b4,b5,b6,bit,
          L.both_true(L.candidate_eligibility_tree_8(b0,b1,b2,b3,b4,b5,b6,False{}),L.candidate_eligibility_tree_8(b0,b1,b2,b3,b4,b5,b6,True{}),checked)))

def L.select_eligibility_subtree_6(b0,b1,b2,b3,b4,b5,bit,both):
  match bit:
    case False{}:
      Pair.fst({L.candidate_eligibility_tree_7(b0,b1,b2,b3,b4,b5,False{}) == True{} : Bool},{L.candidate_eligibility_tree_7(b0,b1,b2,b3,b4,b5,True{}) == True{} : Bool},both)
    case True{}:
      Pair.snd({L.candidate_eligibility_tree_7(b0,b1,b2,b3,b4,b5,False{}) == True{} : Bool},{L.candidate_eligibility_tree_7(b0,b1,b2,b3,b4,b5,True{}) == True{} : Bool},both)

def L.check_candidate_eligibility_tree_6(b0,b1,b2,b3,b4,b5,suffix,checked):
  match suffix:
    case WCon{+bit,+rest}:
      L.check_candidate_eligibility_tree_7(b0,b1,b2,b3,b4,b5,bit,rest,
        L.select_eligibility_subtree_6(b0,b1,b2,b3,b4,b5,bit,
          L.both_true(L.candidate_eligibility_tree_7(b0,b1,b2,b3,b4,b5,False{}),L.candidate_eligibility_tree_7(b0,b1,b2,b3,b4,b5,True{}),checked)))

def L.select_eligibility_subtree_5(b0,b1,b2,b3,b4,bit,both):
  match bit:
    case False{}:
      Pair.fst({L.candidate_eligibility_tree_6(b0,b1,b2,b3,b4,False{}) == True{} : Bool},{L.candidate_eligibility_tree_6(b0,b1,b2,b3,b4,True{}) == True{} : Bool},both)
    case True{}:
      Pair.snd({L.candidate_eligibility_tree_6(b0,b1,b2,b3,b4,False{}) == True{} : Bool},{L.candidate_eligibility_tree_6(b0,b1,b2,b3,b4,True{}) == True{} : Bool},both)

def L.check_candidate_eligibility_tree_5(b0,b1,b2,b3,b4,suffix,checked):
  match suffix:
    case WCon{+bit,+rest}:
      L.check_candidate_eligibility_tree_6(b0,b1,b2,b3,b4,bit,rest,
        L.select_eligibility_subtree_5(b0,b1,b2,b3,b4,bit,
          L.both_true(L.candidate_eligibility_tree_6(b0,b1,b2,b3,b4,False{}),L.candidate_eligibility_tree_6(b0,b1,b2,b3,b4,True{}),checked)))

def L.select_eligibility_subtree_4(b0,b1,b2,b3,bit,both):
  match bit:
    case False{}:
      Pair.fst({L.candidate_eligibility_tree_5(b0,b1,b2,b3,False{}) == True{} : Bool},{L.candidate_eligibility_tree_5(b0,b1,b2,b3,True{}) == True{} : Bool},both)
    case True{}:
      Pair.snd({L.candidate_eligibility_tree_5(b0,b1,b2,b3,False{}) == True{} : Bool},{L.candidate_eligibility_tree_5(b0,b1,b2,b3,True{}) == True{} : Bool},both)

def L.check_candidate_eligibility_tree_4(b0,b1,b2,b3,suffix,checked):
  match suffix:
    case WCon{+bit,+rest}:
      L.check_candidate_eligibility_tree_5(b0,b1,b2,b3,bit,rest,
        L.select_eligibility_subtree_4(b0,b1,b2,b3,bit,
          L.both_true(L.candidate_eligibility_tree_5(b0,b1,b2,b3,False{}),L.candidate_eligibility_tree_5(b0,b1,b2,b3,True{}),checked)))

def L.select_eligibility_subtree_3(b0,b1,b2,bit,both):
  match bit:
    case False{}:
      Pair.fst({L.candidate_eligibility_tree_4(b0,b1,b2,False{}) == True{} : Bool},{L.candidate_eligibility_tree_4(b0,b1,b2,True{}) == True{} : Bool},both)
    case True{}:
      Pair.snd({L.candidate_eligibility_tree_4(b0,b1,b2,False{}) == True{} : Bool},{L.candidate_eligibility_tree_4(b0,b1,b2,True{}) == True{} : Bool},both)

def L.check_candidate_eligibility_tree_3(b0,b1,b2,suffix,checked):
  match suffix:
    case WCon{+bit,+rest}:
      L.check_candidate_eligibility_tree_4(b0,b1,b2,bit,rest,
        L.select_eligibility_subtree_3(b0,b1,b2,bit,
          L.both_true(L.candidate_eligibility_tree_4(b0,b1,b2,False{}),L.candidate_eligibility_tree_4(b0,b1,b2,True{}),checked)))

def L.select_eligibility_subtree_2(b0,b1,bit,both):
  match bit:
    case False{}:
      Pair.fst({L.candidate_eligibility_tree_3(b0,b1,False{}) == True{} : Bool},{L.candidate_eligibility_tree_3(b0,b1,True{}) == True{} : Bool},both)
    case True{}:
      Pair.snd({L.candidate_eligibility_tree_3(b0,b1,False{}) == True{} : Bool},{L.candidate_eligibility_tree_3(b0,b1,True{}) == True{} : Bool},both)

def L.check_candidate_eligibility_tree_2(b0,b1,suffix,checked):
  match suffix:
    case WCon{+bit,+rest}:
      L.check_candidate_eligibility_tree_3(b0,b1,bit,rest,
        L.select_eligibility_subtree_2(b0,b1,bit,
          L.both_true(L.candidate_eligibility_tree_3(b0,b1,False{}),L.candidate_eligibility_tree_3(b0,b1,True{}),checked)))

def L.select_eligibility_subtree_1(b0,bit,both):
  match bit:
    case False{}:
      Pair.fst({L.candidate_eligibility_tree_2(b0,False{}) == True{} : Bool},{L.candidate_eligibility_tree_2(b0,True{}) == True{} : Bool},both)
    case True{}:
      Pair.snd({L.candidate_eligibility_tree_2(b0,False{}) == True{} : Bool},{L.candidate_eligibility_tree_2(b0,True{}) == True{} : Bool},both)

def L.check_candidate_eligibility_tree_1(b0,suffix,checked):
  match suffix:
    case WCon{+bit,+rest}:
      L.check_candidate_eligibility_tree_2(b0,bit,rest,
        L.select_eligibility_subtree_1(b0,bit,
          L.both_true(L.candidate_eligibility_tree_2(b0,False{}),L.candidate_eligibility_tree_2(b0,True{}),checked)))

def L.select_eligibility_subtree_0(bit,both):
  match bit:
    case False{}:
      Pair.fst({L.candidate_eligibility_tree_1(False{}) == True{} : Bool},{L.candidate_eligibility_tree_1(True{}) == True{} : Bool},both)
    case True{}:
      Pair.snd({L.candidate_eligibility_tree_1(False{}) == True{} : Bool},{L.candidate_eligibility_tree_1(True{}) == True{} : Bool},both)

def L.check_candidate_eligibility_tree_0(suffix,checked):
  match suffix:
    case WCon{+bit,+rest}:
      L.check_candidate_eligibility_tree_1(bit,rest,
        L.select_eligibility_subtree_0(bit,
          L.both_true(L.candidate_eligibility_tree_1(False{}),L.candidate_eligibility_tree_1(True{}),checked)))

def L.check_all_normalized_candidate_masks():
  {==}

def L.normalized_candidate_bits_are_eligible(bits):
  +mask = L.candidate_bits_word(bits)
  L.both_true((mask < 1024 : U32),(C.scalar_size(mask) < 10 : U32),
    L.check_candidate_eligibility_tree_0(bits,L.check_all_normalized_candidate_masks()))

def L.normalized_word_eligibility_from_bits(raw,image):
  (+bits,form) = image
  %Equal.sym(U32,U32.and(1022,raw),L.candidate_bits_word(bits),form) : L.QueueEligibleWord(_)
  L.normalized_candidate_bits_are_eligible(bits)

def L.normalized_masks_are_eligible(mask,normalized):
  %normalized : L.QueueEligibleWord(_)
  L.normalized_word_eligibility_from_bits(mask,L.low_candidate_mask_image(mask))

def L.queued_visible_normalized_word_board_image(image,start,before,after,interval,normalized):
  +cell = L.walk_position(before,start)
  L.queued_scanned_eligible_prevents_completion(L.image_board(image),start,before,after,interval,
    L.normalized_masks_are_eligible(L.cell_value(L.image_board(image),cell),normalized))

def L.queued_visible_normalized_word_prevents_completion(b,start,before,after,interval,normalized):
  +cell = L.walk_position(before,start)
  proof : ({U32.and(1022,L.cell_value(b,cell)) == L.cell_value(b,cell) : U32} ->
    L.NotCompleted(L.selector_position(Q.scan(L.with_center(before,after),start,L.QueueInitial(b))))) =
    L.on_reified_board(b,x =>
      ({U32.and(1022,L.cell_value(x,cell)) == L.cell_value(x,cell) : U32} ->
        L.NotCompleted(L.selector_position(Q.scan(L.with_center(before,after),start,L.QueueInitial(x))))),
      L.reify_board(b),image => L.queued_visible_normalized_word_board_image(image,start,before,after,interval))
  proof(normalized)
def queue_word_bits(+u: U32) -> Word(32n):
  match u:
    case U32{bits}:
      bits


def L.word_clip_repeat(n,clip,word):
  match n:
    case 0n:
      {==}
    case 1n+k:
      match clip word:
        case WCon{False{},ct} WCon{False{},wt}:
          Equal.cong(Word(k),Word(1n+k),t => WCon{False{},t},Word.and(k,ct,Word.and(k,ct,wt)),Word.and(k,ct,wt),L.word_clip_repeat(k,ct,wt))
        case WCon{False{},ct} WCon{True{},wt}:
          Equal.cong(Word(k),Word(1n+k),t => WCon{False{},t},Word.and(k,ct,Word.and(k,ct,wt)),Word.and(k,ct,wt),L.word_clip_repeat(k,ct,wt))
        case WCon{True{},ct} WCon{False{},wt}:
          Equal.cong(Word(k),Word(1n+k),t => WCon{False{},t},Word.and(k,ct,Word.and(k,ct,wt)),Word.and(k,ct,wt),L.word_clip_repeat(k,ct,wt))
        case WCon{True{},ct} WCon{True{},wt}:
          Equal.cong(Word(k),Word(1n+k),t => WCon{True{},t},Word.and(k,ct,Word.and(k,ct,wt)),Word.and(k,ct,wt),L.word_clip_repeat(k,ct,wt))

def L.trim_is_normalized(raw):
  match raw:
    case U32{bits}:
      Equal.cong(Word(32n),U32,t => U32{t},
        Word.and(32n,queue_word_bits(1022),Word.and(32n,queue_word_bits(1022),bits)),
        Word.and(32n,queue_word_bits(1022),bits),L.word_clip_repeat(32n,queue_word_bits(1022),bits))

def L.inverted_mask_is_normalized(cells):
  (b,+used) = cells
  L.trim_is_normalized(U32.not(used))

def L.cached_mask_is_normalized(b,p):
  L.inverted_mask_is_normalized(C.cached_add((99 + Board.box_of(p) : U32),C.cached_add((90 + M.rem9(p) : U32),Array.get(U32,b,(81 + M.div9(p) : U32)))))

def L.encoded_blank_mask_image(image,p,shape,apart):
  b = L.image_board(image)
  +mask = L.cached_word(L.image_board(image),p)
  %Equal.sym(Array<U32>,Q.encoded(p,(b,0)),Q.encoded_mask(p,(b,mask)),
    L.encoded_blank_normalized(b,p,L.cached_at_observed(L.image_board(image),p))) :
    L.NormalizedQueueMask(L.cell_value(_,p))
  %Equal.sym(U32,L.cell_value(Q.encoded_mask(p,(b,mask)),p),mask,
    L.encoded_mask_writes_cell(L.image_board(image),p,mask)(shape,apart)) :
    L.NormalizedQueueMask(_)
  L.cached_mask_is_normalized(L.image_board(image),p)

def L.encoded_blank_mask(b,p):
  L.on_reified_board(b,x => L.EncodedBlankMask(x,p),L.reify_board(b),image => L.encoded_blank_mask_image(image,p))

def L.actual_encoded_blank_mask_image(image,p,shape,apart,is_blank):
  b = L.image_board(image)
  +raw = L.cell_value(L.image_board(image),p)
  %Equal.sym(Array<U32>,L.actual_encoded_step(b,p),Q.encoded(p,(b,raw)),
    L.encode_step_normalized(b,p,L.board_read_witness(L.image_board(image),p))) :
    L.NormalizedQueueMask(L.cell_value(_,p))
  %Equal.sym(U32,raw,0,is_blank) :
    L.NormalizedQueueMask(L.cell_value(Q.encoded(p,(b,_)),p))
  L.encoded_blank_mask(L.image_board(image),p)(shape,apart)

def L.actual_encoded_blank_mask(b,p):
  L.on_reified_board(b,x => L.ActualEncodedBlankMask(x,p),L.reify_board(b),image => L.actual_encoded_blank_mask_image(image,p))

def L.word_clip_and_interchange(n,clip,a,b):
  match n:
    case 0n:
      {==}
    case 1n+k:
      match clip a b:
        case WCon{False{},ct} WCon{False{},at} WCon{False{},bt}:
          Equal.cong(Word(k),Word(1n+k),w => WCon{False{},w},
            Word.and(k,ct,Word.and(k,at,bt)),Word.and(k,Word.and(k,ct,at),bt),L.word_clip_and_interchange(k,ct,at,bt))
        case WCon{False{},ct} WCon{False{},at} WCon{True{},bt}:
          Equal.cong(Word(k),Word(1n+k),w => WCon{False{},w},
            Word.and(k,ct,Word.and(k,at,bt)),Word.and(k,Word.and(k,ct,at),bt),L.word_clip_and_interchange(k,ct,at,bt))
        case WCon{False{},ct} WCon{True{},at} WCon{False{},bt}:
          Equal.cong(Word(k),Word(1n+k),w => WCon{False{},w},
            Word.and(k,ct,Word.and(k,at,bt)),Word.and(k,Word.and(k,ct,at),bt),L.word_clip_and_interchange(k,ct,at,bt))
        case WCon{False{},ct} WCon{True{},at} WCon{True{},bt}:
          Equal.cong(Word(k),Word(1n+k),w => WCon{False{},w},
            Word.and(k,ct,Word.and(k,at,bt)),Word.and(k,Word.and(k,ct,at),bt),L.word_clip_and_interchange(k,ct,at,bt))
        case WCon{True{},ct} WCon{False{},at} WCon{False{},bt}:
          Equal.cong(Word(k),Word(1n+k),w => WCon{False{},w},
            Word.and(k,ct,Word.and(k,at,bt)),Word.and(k,Word.and(k,ct,at),bt),L.word_clip_and_interchange(k,ct,at,bt))
        case WCon{True{},ct} WCon{False{},at} WCon{True{},bt}:
          Equal.cong(Word(k),Word(1n+k),w => WCon{False{},w},
            Word.and(k,ct,Word.and(k,at,bt)),Word.and(k,Word.and(k,ct,at),bt),L.word_clip_and_interchange(k,ct,at,bt))
        case WCon{True{},ct} WCon{True{},at} WCon{False{},bt}:
          Equal.cong(Word(k),Word(1n+k),w => WCon{False{},w},
            Word.and(k,ct,Word.and(k,at,bt)),Word.and(k,Word.and(k,ct,at),bt),L.word_clip_and_interchange(k,ct,at,bt))
        case WCon{True{},ct} WCon{True{},at} WCon{True{},bt}:
          Equal.cong(Word(k),Word(1n+k),w => WCon{True{},w},
            Word.and(k,ct,Word.and(k,at,bt)),Word.and(k,Word.and(k,ct,at),bt),L.word_clip_and_interchange(k,ct,at,bt))

def L.normalized_word_intersect(old,other,normalized):
  match old other:
    case U32{a} U32{b}:
      +clip = queue_word_bits(1022)
      Equal.trans(U32,U32{Word.and(32n,clip,Word.and(32n,a,b))},U32{Word.and(32n,Word.and(32n,clip,a),b)},U32{Word.and(32n,a,b)},
        Equal.cong(Word(32n),U32,w => U32{w},Word.and(32n,clip,Word.and(32n,a,b)),Word.and(32n,Word.and(32n,clip,a),b),L.word_clip_and_interchange(32n,clip,a,b)),
        Equal.cong(U32,U32,w => U32.and(w,U32{b}),U32{Word.and(32n,clip,a)},U32{a},normalized))

def L.peer_mask_keeps_normalized(old,bit,normalized):
  L.normalized_word_intersect(old,U32.not(bit),normalized)

def L.changed_peer_word_image(image,p,bit,old,shape,apart):
  b = L.image_board(image)
  +mask = L.peer_mask(old,bit)
  changed = Board.set_cell(L.image_board(image),p,mask)
  Equal.trans(U32,L.cell_value(Q.changed(True{},p,bit,b,old),p),L.cell_value(changed,p),mask,
    L.queue_changed_flag_keeps(changed,L.peer_reflag(old,bit),p,p,apart,L.board_set_keeps_perfect(L.image_board(image),p,mask,7n,shape)),
    L.board_set_get(L.image_board(image),p,mask))

def L.peer_changed_word_keeps_normalized(image,needed,p,bit,shape,apart,normalized):
  match needed:
    case False{}:
      normalized
    case True{}:
      b = L.image_board(image)
      +old = L.cell_value(L.image_board(image),p)
      +mask = L.peer_mask(old,bit)
      %Equal.sym(U32,L.cell_value(Q.changed(True{},p,bit,b,old),p),mask,
        L.changed_peer_word_image(image,p,bit,old,shape,apart)) :
        L.NormalizedQueueMask(_)
      L.peer_mask_keeps_normalized(old,bit,normalized)

def L.peer_keeps_normalized_image(image,p,bit,shape,apart,normalized):
  b = L.image_board(image)
  +old = L.cell_value(L.image_board(image),p)
  +needed = U32.is_ne(U32.and(old,bit),0)
  %Equal.sym(Array<U32>,L.actual_peer(b,p,bit),Q.changed(needed,p,bit,b,old),
    L.peer_normalized(b,p,bit,L.board_read_witness(L.image_board(image),p))) :
    L.NormalizedQueueMask(L.cell_value(_,p))
  L.peer_changed_word_keeps_normalized(image,needed,p,bit,shape,apart,normalized)

def L.peer_keeps_normalized(b,p,bit):
  L.on_reified_board(b,x => L.PeerKeepsNormalized(x,p,bit),L.reify_board(b),image => L.peer_keeps_normalized_image(image,p,bit))

def L.encode_mask_middle_base_image(image,suffix,p,shapes,safe,tail,digit):
  (s0,s1) = shapes
  step = L.actual_encoded_step(L.image_board(image),p)
  +p1 = (p + 1 : U32)
  +final = L.cell_value(Q.encode_go(suffix,p1,L.actual_encoded_step(L.image_board(image),p)),p)
  +current = L.cell_value(L.actual_encoded_step(L.image_board(image),p),p)
  %Equal.sym(U32,final,current,
    L.encode_sweep_keeps(suffix,p1,p,step,L.actual_encode_step_keeps_perfect(L.image_board(image),p,s0),tail)) :
    L.NormalizedQueueMask(_)
  L.actual_encoded_blank_mask(L.image_board(image),p)(s1,safe,digit)

def L.encode_mask_middle_base(image,suffix,p,shape,before,safe,after,digit):
  L.encode_mask_middle_base_image(image,suffix,p,
    L.copy_shape_proof(L.array_shape(L.image_board(image)),L.perfect_shape(7n),shape),safe,after,digit)

def L.encode_mask_middle_step_image(image,k,suffix,p,shapes,before,safe,after,digit,next):
  (s0,s1) = shapes
  (cell,(flag,tail)) = before
  step = L.actual_encoded_step(L.image_board(image),p)
  +p1 = (p + 1 : U32)
  +q = L.walk_position(k,p1)
  next(step,L.actual_encode_step_keeps_perfect(L.image_board(image),p,s0),tail,safe,after,
    Equal.trans(U32,L.cell_value(step,q),L.cell_value(L.image_board(image),q),0,
      L.encode_step_keeps(L.image_board(image),p,q)(s1,cell,flag),digit))

def L.encode_mask_middle_step(image,k,suffix,p,next,shape,before,safe,after,digit):
  L.encode_mask_middle_step_image(image,k,suffix,p,
    L.copy_shape_proof(L.array_shape(L.image_board(image)),L.perfect_shape(7n),shape),before,safe,after,digit,next)

def L.encode_mask_middle_from_image(prefix,image,suffix,p,shape,before,safe,after,digit):
  match prefix:
    case 0n:
      L.encode_mask_middle_base(image,suffix,p,shape,before,safe,after,digit)
    case 1n+k:
      L.encode_mask_middle_step(image,k,suffix,p,
        sub => L.on_reified_board(sub,x => L.EncodeMiddleMask(x,k,suffix,(p + 1 : U32)),
          L.reify_board(sub),im => L.encode_mask_middle_from_image(k,im,suffix,(p + 1 : U32))),
        shape,before,safe,after,digit)

def L.encode_mask_middle_value(b,prefix,suffix,p):
  L.on_reified_board(b,x => L.EncodeMiddleMask(x,prefix,suffix,p),
    L.reify_board(b),image => L.encode_mask_middle_from_image(prefix,image,suffix,p))


def L.encode81_blank_mask_step(image,before,after,shapes,r9,r10,r11,ep,safe,es,count,digit):
  (s0,s1) = shapes
  b = L.image_board(image)
  seed = L.queue_seed(L.image_board(image))
  +q = L.walk_position(before,0)
  %count :
    L.NormalizedQueueMask(L.cell_value(Q.encode_go(_,0,L.queue_seed(b)),q))
  L.encode_mask_middle_value(seed,before,after,0)(
    L.queue_seed_perfect(L.image_board(image),s0),ep,safe,es,
    Equal.trans(U32,L.cell_value(seed,q),L.cell_value(b,q),0,
      L.queue_seed_keeps_cell(L.image_board(image),q)(s1,r9,r10,r11),digit))

def L.encode81_blank_mask_image(image,before,after,shape,r9,r10,r11,ep,safe,es,count,digit):
  L.encode81_blank_mask_step(image,before,after,
    L.copy_shape_proof(L.array_shape(L.image_board(image)),L.perfect_shape(7n),shape),
    r9,r10,r11,ep,safe,es,count,digit)

def L.public_queue_encode_blank_mask_at(b,before,after):
  L.on_reified_board(b,x => L.Encode81BlankMask(x,before,after),
    L.reify_board(b),image => L.encode81_blank_mask_image(image,before,after))

def L.public_encode_blank_mask_routes(b,before,after,shape,routes,count,digit):
  (r9,(r10,(r11,(safe,((ep,dp),(es,ds)))))) = routes
  L.public_queue_encode_blank_mask_at(b,before,after)(shape,r9,r10,r11,ep,safe,es,count,digit)

def L.public_encode_blank_mask_checked(b,before,after,shape,window,digit):
  (guard,count) = window
  +q = L.walk_position(before,0)
  L.public_encode_blank_mask_routes(b,before,after,shape,
    L.window_routes(before,after,q,(q + 1 : U32),guard),count,digit)

def L.any_logical_cell_encode_blank_mask(b,row,col,shape,digit):
  L.public_encode_blank_mask_checked(b,L.logical_offset(row,col),L.logical_tail(row,col),shape,L.every_cell_window(row,col),digit)



def L.adaptive_activation_blank_is_eligible_image(image,row,col,shape,blank):
  +p = L.logical_position(row,col)
  L.normalized_masks_are_eligible(L.cell_value(Q.encode(L.image_board(image)),p),
    L.any_logical_cell_encode_blank_mask(L.image_board(image),row,col,shape,blank))

def L.adaptive_activation_blank_is_eligible(b,row,col,shape,blank):
  +p = L.logical_position(row,col)
  proof : (L.Board128(b) -> {L.cell_value(b,p) == 0 : U32} ->
    L.QueueEligibleWord(L.cell_value(Fast.activated(False{},b),p))) =
    L.on_reified_board(b,x => (L.Board128(x) -> {L.cell_value(x,p) == 0 : U32} ->
      L.QueueEligibleWord(L.cell_value(Fast.activated(False{},x),p))),
      L.reify_board(b),image => L.adaptive_activation_blank_is_eligible_image(image,row,col))
  proof(shape,blank)

def L.peer_keeps_normalized_same_parts(image,q,digit,routes,shapes,prior):
  (keep,use) = routes
  (s0,s1) = shapes
  +bit = Board.bit(L.digit_word(digit))
  (keep,(L.peer_perfect(L.image_board(image),q,bit)(s0),
    L.peer_keeps_normalized(L.image_board(image),q,bit)(s1,use,prior)))

def L.peer_keeps_normalized_same(image,q,digit,prior):
  (safe,(shape,mask)) = prior
  L.peer_keeps_normalized_same_parts(image,q,digit,
    L.copy_true(L.apart_guard(L.flag_slot(q),q),safe),
    L.copy_shape_proof(L.array_shape(L.image_board(image)),L.perfect_shape(7n),shape),mask)

def L.peer_keeps_normalized_separate_step(image,p,q,safe,placed,shapes,given,sep,flag):
  (s0,s1) = shapes
  +bit = Board.bit(L.digit_word(placed))
  normalized : L.NormalizedQueueMask(L.cell_value(L.actual_peer(L.image_board(image),p,bit),q)) =
    %Equal.sym(U32,L.cell_value(L.actual_peer(L.image_board(image),p,bit),q),L.cell_value(L.image_board(image),q),
      L.peer_keeps(L.image_board(image),p,bit,q)(s1,sep,flag)) :
      L.NormalizedQueueMask(_)
    given
  (safe,(L.peer_perfect(L.image_board(image),p,bit)(s0),normalized))

def L.peer_keeps_normalized_separate_image(image,p,q,placed,apart,state):
  (sep,flag) = apart
  (safe,(shape,given)) = state
  L.peer_keeps_normalized_separate_step(image,p,q,safe,placed,
    L.copy_shape_proof(L.array_shape(L.image_board(image)),L.perfect_shape(7n),shape),given,sep,flag)

def L.peer_normalized_transition_image(image,p,q,placed,route,state):
  match route:
    case Inl{same}:
      %Equal.sym(U32,p,q,same) :
        L.SafeNormalizedAt(L.actual_peer(L.image_board(image),_,Board.bit(L.digit_word(placed))),q)
      L.peer_keeps_normalized_same(image,q,placed,state)
    case Inr{apart}:
      L.peer_keeps_normalized_separate_image(image,p,q,placed,apart,state)

def L.peer_normalized_transition(b,p,q,placed):
  L.on_reified_board(b,x => L.PeerNormalizedTransition(x,p,q,placed),
    L.reify_board(b),image => L.peer_normalized_transition_image(image,p,q,placed))

def L.row_normalized_step_image(image,n,j,base,placed,q,d,routes,state,next):
  (here,tail) = routes
  +p = (base + j : U32)
  next(L.actual_peer(L.image_board(image),p,Board.bit(L.digit_word(d))),tail,
    L.peer_normalized_transition(L.image_board(image),p,q,d)(here,state))

def L.row_normalized_step(b,n,j,base,placed,q,d):
  L.on_reified_board(b,x => L.RowNormalizedStep(x,n,j,base,placed,q,d),
    L.reify_board(b),image => L.row_normalized_step_image(image,n,j,base,placed,q,d))

def L.row_normalized_line(n,j,base,placed,q,d,b,routes,state):
  match n:
    case 0n:
      state
    case 1n+k:
      L.row_normalized_step(b,k,j,base,placed,q,d)(routes,state,
        sub => rest => witness => L.row_normalized_line(k,(j + 1 : U32),base,placed,q,d,sub,rest,witness))

def L.column_normalized_step_image(image,n,j,col,placed,q,d,routes,state,next):
  (here,tail) = routes
  +p = (j * 9 + col : U32)
  next(L.actual_peer(L.image_board(image),p,Board.bit(L.digit_word(d))),tail,
    L.peer_normalized_transition(L.image_board(image),p,q,d)(here,state))

def L.column_normalized_step(b,n,j,col,placed,q,d):
  L.on_reified_board(b,x => L.ColumnNormalizedStep(x,n,j,col,placed,q,d),
    L.reify_board(b),image => L.column_normalized_step_image(image,n,j,col,placed,q,d))

def L.column_normalized_line(n,j,col,placed,q,d,b,routes,state):
  match n:
    case 0n:
      state
    case 1n+k:
      L.column_normalized_step(b,k,j,col,placed,q,d)(routes,state,
        sub => rest => witness => L.column_normalized_line(k,(j + 1 : U32),col,placed,q,d,sub,rest,witness))

def L.normalized_peer_list_step_image(image,p,tail,q,d,routes,state,next):
  (here,later) = routes
  next(L.actual_peer(L.image_board(image),p,Board.bit(L.digit_word(d))),later,
    L.peer_normalized_transition(L.image_board(image),p,q,d)(here,state))

def L.normalized_peer_list_step(b,p,tail,q,d,routes,state,next):
  proof : (L.PeerListRoutes(p <> tail,q) -> L.SafeNormalizedAt(b,q) ->
    L.NormalizedPeerListProof(tail,q,d) -> L.SafeNormalizedAt(L.run_peer_list(p <> tail,b,Board.bit(L.digit_word(d))),q)) =
    L.on_reified_board(b,x => (L.PeerListRoutes(p <> tail,q) -> L.SafeNormalizedAt(x,q) ->
      L.NormalizedPeerListProof(tail,q,d) -> L.SafeNormalizedAt(L.run_peer_list(p <> tail,x,Board.bit(L.digit_word(d))),q)),
      L.reify_board(b),image => L.normalized_peer_list_step_image(image,p,tail,q,d))
  proof(routes,state,next)

def L.peer_list_normalized(positions,q,d,b,routes,state):
  match positions:
    case Nil{}:
      state
    case +p <> tail:
      L.normalized_peer_list_step(b,p,tail,q,d,routes,state,sub => rest => witness => L.peer_list_normalized(tail,q,d,sub,rest,witness))

def L.box_four_keeps_normalized(b,base,r1,r2,c1,c2,q,d,routes,state):
  L.peer_list_normalized(L.box_positions(base,r1,r2,c1,c2),q,d,b,routes,state)

def L.normalized_after_pointer_write(image,out,q,safe,shapes,known,apart,witness):
  (s0,s1) = shapes
  (+ptr,actual) = witness
  b = L.image_board(image)
  %Equal.sym(Array<U32>,out,Board.set_cell(b,108,ptr),actual) :
    L.SafeNormalizedAt(_,q)
  normalized : L.NormalizedQueueMask(L.cell_value(Board.set_cell(b,108,ptr),q)) =
    %Equal.sym(U32,L.cell_value(Board.set_cell(b,108,ptr),q),L.cell_value(b,q),
      L.perfect_write_keeps_cell(L.image_board(image),108,q,ptr,s1,apart)) :
      L.NormalizedQueueMask(_)
    known
  (safe,(L.board_set_keeps_perfect(L.image_board(image),108,ptr,7n,s0),normalized))


def L.refresh_needed_normalized_image(image,needed,start,q,apart,state):
  match needed:
    case False{}:
      state
    case True{}:
      (safe,(shape,known)) = state
      +n = U32.to_nat((81 - start : U32))
      L.normalized_after_pointer_write(image,L.first_actual(L.image_board(image),n,start),q,safe,
        L.copy_shape_proof(L.array_shape(L.image_board(image)),L.perfect_shape(7n),shape),known,apart,
        L.first_actual_pointer(n,start,L.image_board(image),L.board_read_witness(L.image_board(image),start)))


def L.refresh_keeps_normalized_image(image,p,q,apart,state):
  b = L.image_board(image)
  +start = L.cell_value(L.image_board(image),108)
  +needed = U32.is_eq(p,start)
  %Equal.sym(Array<U32>,L.refresh_actual(b,p),Q.refresh_needed(needed,b,start),
    L.refresh_normalized(b,p,L.board_read_witness(L.image_board(image),108))) :
    L.SafeNormalizedAt(_,q)
  L.refresh_needed_normalized_image(image,needed,start,q,apart,state)

def L.refresh_keeps_normalized(b,p,q):
  L.on_reified_board(b,x => L.RefreshNormalizedAt(x,p,q),
    L.reify_board(b),image => L.refresh_keeps_normalized_image(image,p,q))

def L.clear_forced_normalized_image_step(image,p,q,safe,flag,shapes,known):
  (s0,s1) = shapes
  b = L.image_board(image)
  normalized : L.NormalizedQueueMask(L.cell_value(Q.flag(b,p,False{}),q)) =
    %Equal.sym(U32,L.cell_value(Q.flag(b,p,False{}),q),L.cell_value(b,q),
      L.flag_keeps_cell(L.image_board(image),p,False{},q)(s1,flag)) :
      L.NormalizedQueueMask(_)
    known
  (safe,(L.queue_flag_perfect(L.image_board(image),p,False{},s0),normalized))

def L.clear_forced_normalized_image(image,guess,p,q,flag,state):
  match guess:
    case True{}:
      state
    case False{}:
      (safe,(shape,known)) = state
      L.clear_forced_normalized_image_step(image,p,q,safe,flag,
        L.copy_shape_proof(L.array_shape(L.image_board(image)),L.perfect_shape(7n),shape),known)

def L.clear_forced_normalized(b,guess,p,q,flag,state):
  proof : (L.RoutedApart(L.flag_slot(p),q) -> L.SafeNormalizedAt(b,q) ->
    L.SafeNormalizedAt(Q.clear_forced(guess,b,p),q)) =
    L.on_reified_board(b,x => (L.RoutedApart(L.flag_slot(p),q) -> L.SafeNormalizedAt(x,q) ->
      L.SafeNormalizedAt(Q.clear_forced(guess,x,p),q)),L.reify_board(b),
      image => L.clear_forced_normalized_image(image,guess,p,q))
  proof(flag,state)

def L.write_normalized_other_step(image,p,value,q,safe,apart,shapes,known):
  (s0,s1) = shapes
  b = L.image_board(image)
  normalized : L.NormalizedQueueMask(L.cell_value(Board.set_cell(b,p,value),q)) =
    %Equal.sym(U32,L.cell_value(Board.set_cell(b,p,value),q),L.cell_value(b,q),
      L.perfect_write_keeps_cell(L.image_board(image),p,q,value,s1,apart)) :
      L.NormalizedQueueMask(_)
    known
  (safe,(L.board_set_keeps_perfect(L.image_board(image),p,value,7n,s0),normalized))

def L.write_normalized_other_image(image,p,value,q,apart,state):
  (safe,(shape,known)) = state
  L.write_normalized_other_step(image,p,value,q,safe,apart,
    L.copy_shape_proof(L.array_shape(L.image_board(image)),L.perfect_shape(7n),shape),known)

def L.write_normalized_other(b,p,value,q,apart,state):
  proof : (L.RoutedApart(p,q) -> L.SafeNormalizedAt(b,q) ->
    L.SafeNormalizedAt(Board.set_cell(b,p,value),q)) =
    L.on_reified_board(b,x => (L.RoutedApart(p,q) -> L.SafeNormalizedAt(x,q) ->
      L.SafeNormalizedAt(Board.set_cell(x,p,value),q)),L.reify_board(b),
      image => L.write_normalized_other_image(image,p,value,q))
  proof(apart,state)

def L.place_normalized_peers_image(image,p,q,d,routes,state):
  (row,(col,(box,ptr))) = routes
  L.refresh_keeps_normalized(L.place_boxes(L.image_board(image),p,d),p,q)(ptr,
    L.box_four_keeps_normalized(L.place_columns(L.image_board(image),p,d),L.place_box_base(p),L.place_box_r1(p),L.place_box_r2(p),L.place_box_c1(p),L.place_box_c2(p),q,d,box,
      L.column_normalized_line(9n,0,M.rem9(p),p,q,d,L.place_rows(L.image_board(image),p,d),col,
        L.row_normalized_line(9n,0,L.place_row_base(p),p,q,d,L.image_board(image),row,state))))

def L.place_peers_keep_normalized(b,p,q,d):
  L.on_reified_board(b,x => L.PlacePeersNormalized(x,p,q,d),
    L.reify_board(b),image => L.place_normalized_peers_image(image,p,q,d))

def L.place_keeps_normalized_image(image,guess,p,q,d,apart,flag,routes,state):
  after_clear = Q.clear_forced(guess,L.image_board(image),p)
  after_write = Board.set_cell(Q.clear_forced(guess,L.image_board(image),p),p,L.fixed_word(d))
  L.place_peers_keep_normalized(after_write,p,q,d)(routes,
    L.write_normalized_other(after_clear,p,L.fixed_word(d),q,apart,
      L.clear_forced_normalized(L.image_board(image),guess,p,q,flag,state)))

def L.queued_place_keeps_normalized(b,guess,p,q,d):
  L.on_reified_board(b,x => L.PlaceKeepsNormalized(x,guess,p,q,d),
    L.reify_board(b),image => L.place_keeps_normalized_image(image,guess,p,q,d))


def L.logical_placement_keeps_other_candidate(b,guess,sr,sc,wr,wc,digit,distinct,state):
  +p = L.logical_position(sr,sc)
  +q = L.logical_position(wr,wc)
  L.queued_place_keeps_normalized(b,guess,p,q,digit)(
    L.logical_distinct_apart(p,q,distinct,L.matrix_logical_entry(sr,sc,wr,wc),
      L.logical_address_facts(sr,sc),L.logical_address_facts(wr,wc)),
    L.any_logical_flag_route(sr,sc,wr,wc),
    L.placement_routes_from_coordinates(sr,sc,wr,wc),state)


def L.safe_normalized_mask(b,q,state):
  (safe,(shape,prior)) = state
  prior

def L.logical_placement_preserves_other_candidate_mask(b,guess,sr,sc,wr,wc,digit,distinct,shape,prior):
  +p = L.logical_position(sr,sc)
  +q = L.logical_position(wr,wc)
  L.safe_normalized_mask(Q.place(guess,p,L.digit_word(digit),b),q,
    L.logical_placement_keeps_other_candidate(b,guess,sr,sc,wr,wc,digit,distinct,
      (L.any_logical_flag_route(wr,wc,wr,wc),(shape,prior))))

def L.word_and_ones_right(n,x):
  match n:
    case 0n:
      match x:
        case WNil{}:
          {==}
    case 1n+k:
      match x:
        case WCon{False{},tail}:
          Equal.cong(Word(k),Word(1n+k),w => WCon{False{},w},
            Word.and(k,tail,L.word_ones(k)),tail,L.word_and_ones_right(k,tail))
        case WCon{True{},tail}:
          Equal.cong(Word(k),Word(1n+k),w => WCon{True{},w},
            Word.and(k,tail,L.word_ones(k)),tail,L.word_and_ones_right(k,tail))

def L.peer_removal_keeps_high_digit(old,digit):
  match old digit:
    case U32{WCon{b0,WCon{b1,WCon{b2,WCon{b3,WCon{b4,WCon{b5,WCon{b6,WCon{b7,WCon{b8,WCon{b9,upper}}}}}}}}}}} L.D0{}:
      Equal.cong(Word(22n),U32,t => U32{Word.shr.pad(31n,Word.shr.pad(30n,Word.shr.pad(29n,Word.shr.pad(28n,Word.shr.pad(27n,Word.shr.pad(26n,Word.shr.pad(25n,Word.shr.pad(24n,Word.shr.pad(23n,Word.shr.pad(22n,t))))))))))},
        Word.and(22n,upper,L.word_ones(22n)),upper,L.word_and_ones_right(22n,upper))
    case U32{WCon{b0,WCon{b1,WCon{b2,WCon{b3,WCon{b4,WCon{b5,WCon{b6,WCon{b7,WCon{b8,WCon{b9,upper}}}}}}}}}}} L.D1{}:
      Equal.cong(Word(22n),U32,t => U32{Word.shr.pad(31n,Word.shr.pad(30n,Word.shr.pad(29n,Word.shr.pad(28n,Word.shr.pad(27n,Word.shr.pad(26n,Word.shr.pad(25n,Word.shr.pad(24n,Word.shr.pad(23n,Word.shr.pad(22n,t))))))))))},
        Word.and(22n,upper,L.word_ones(22n)),upper,L.word_and_ones_right(22n,upper))
    case U32{WCon{b0,WCon{b1,WCon{b2,WCon{b3,WCon{b4,WCon{b5,WCon{b6,WCon{b7,WCon{b8,WCon{b9,upper}}}}}}}}}}} L.D2{}:
      Equal.cong(Word(22n),U32,t => U32{Word.shr.pad(31n,Word.shr.pad(30n,Word.shr.pad(29n,Word.shr.pad(28n,Word.shr.pad(27n,Word.shr.pad(26n,Word.shr.pad(25n,Word.shr.pad(24n,Word.shr.pad(23n,Word.shr.pad(22n,t))))))))))},
        Word.and(22n,upper,L.word_ones(22n)),upper,L.word_and_ones_right(22n,upper))
    case U32{WCon{b0,WCon{b1,WCon{b2,WCon{b3,WCon{b4,WCon{b5,WCon{b6,WCon{b7,WCon{b8,WCon{b9,upper}}}}}}}}}}} L.D3{}:
      Equal.cong(Word(22n),U32,t => U32{Word.shr.pad(31n,Word.shr.pad(30n,Word.shr.pad(29n,Word.shr.pad(28n,Word.shr.pad(27n,Word.shr.pad(26n,Word.shr.pad(25n,Word.shr.pad(24n,Word.shr.pad(23n,Word.shr.pad(22n,t))))))))))},
        Word.and(22n,upper,L.word_ones(22n)),upper,L.word_and_ones_right(22n,upper))
    case U32{WCon{b0,WCon{b1,WCon{b2,WCon{b3,WCon{b4,WCon{b5,WCon{b6,WCon{b7,WCon{b8,WCon{b9,upper}}}}}}}}}}} L.D4{}:
      Equal.cong(Word(22n),U32,t => U32{Word.shr.pad(31n,Word.shr.pad(30n,Word.shr.pad(29n,Word.shr.pad(28n,Word.shr.pad(27n,Word.shr.pad(26n,Word.shr.pad(25n,Word.shr.pad(24n,Word.shr.pad(23n,Word.shr.pad(22n,t))))))))))},
        Word.and(22n,upper,L.word_ones(22n)),upper,L.word_and_ones_right(22n,upper))
    case U32{WCon{b0,WCon{b1,WCon{b2,WCon{b3,WCon{b4,WCon{b5,WCon{b6,WCon{b7,WCon{b8,WCon{b9,upper}}}}}}}}}}} L.D5{}:
      Equal.cong(Word(22n),U32,t => U32{Word.shr.pad(31n,Word.shr.pad(30n,Word.shr.pad(29n,Word.shr.pad(28n,Word.shr.pad(27n,Word.shr.pad(26n,Word.shr.pad(25n,Word.shr.pad(24n,Word.shr.pad(23n,Word.shr.pad(22n,t))))))))))},
        Word.and(22n,upper,L.word_ones(22n)),upper,L.word_and_ones_right(22n,upper))
    case U32{WCon{b0,WCon{b1,WCon{b2,WCon{b3,WCon{b4,WCon{b5,WCon{b6,WCon{b7,WCon{b8,WCon{b9,upper}}}}}}}}}}} L.D6{}:
      Equal.cong(Word(22n),U32,t => U32{Word.shr.pad(31n,Word.shr.pad(30n,Word.shr.pad(29n,Word.shr.pad(28n,Word.shr.pad(27n,Word.shr.pad(26n,Word.shr.pad(25n,Word.shr.pad(24n,Word.shr.pad(23n,Word.shr.pad(22n,t))))))))))},
        Word.and(22n,upper,L.word_ones(22n)),upper,L.word_and_ones_right(22n,upper))
    case U32{WCon{b0,WCon{b1,WCon{b2,WCon{b3,WCon{b4,WCon{b5,WCon{b6,WCon{b7,WCon{b8,WCon{b9,upper}}}}}}}}}}} L.D7{}:
      Equal.cong(Word(22n),U32,t => U32{Word.shr.pad(31n,Word.shr.pad(30n,Word.shr.pad(29n,Word.shr.pad(28n,Word.shr.pad(27n,Word.shr.pad(26n,Word.shr.pad(25n,Word.shr.pad(24n,Word.shr.pad(23n,Word.shr.pad(22n,t))))))))))},
        Word.and(22n,upper,L.word_ones(22n)),upper,L.word_and_ones_right(22n,upper))
    case U32{WCon{b0,WCon{b1,WCon{b2,WCon{b3,WCon{b4,WCon{b5,WCon{b6,WCon{b7,WCon{b8,WCon{b9,upper}}}}}}}}}}} L.D8{}:
      Equal.cong(Word(22n),U32,t => U32{Word.shr.pad(31n,Word.shr.pad(30n,Word.shr.pad(29n,Word.shr.pad(28n,Word.shr.pad(27n,Word.shr.pad(26n,Word.shr.pad(25n,Word.shr.pad(24n,Word.shr.pad(23n,Word.shr.pad(22n,t))))))))))},
        Word.and(22n,upper,L.word_ones(22n)),upper,L.word_and_ones_right(22n,upper))
    case U32{WCon{b0,WCon{b1,WCon{b2,WCon{b3,WCon{b4,WCon{b5,WCon{b6,WCon{b7,WCon{b8,WCon{b9,upper}}}}}}}}}}} L.D9{}:
      Equal.cong(Word(22n),U32,t => U32{Word.shr.pad(31n,Word.shr.pad(30n,Word.shr.pad(29n,Word.shr.pad(28n,Word.shr.pad(27n,Word.shr.pad(26n,Word.shr.pad(25n,Word.shr.pad(24n,Word.shr.pad(23n,Word.shr.pad(22n,t))))))))))},
        Word.and(22n,upper,L.word_ones(22n)),upper,L.word_and_ones_right(22n,upper))

def L.cmp_low_against_zero_ignores_lt(bit,higher):
  match bit higher:
    case _ LT{}:
      {==}
    case _ GT{}:
      {==}
    case False{} EQ{}:
      {==}
    case True{} EQ{}:
      {==}

def L.queued_packed_vacancy_from_upper(b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,upper):
  +high = Word.cmp(22n,upper,WCon{True{},Word.zero(21n)})
  %Equal.sym(Bool,Cmp.is_lt(Word.cmp.fin(b0,False{},Word.cmp.fin(b1,False{},Word.cmp.fin(b2,False{},Word.cmp.fin(b3,False{},Word.cmp.fin(b4,False{},Word.cmp.fin(b5,False{},Word.cmp.fin(b6,False{},Word.cmp.fin(b7,False{},Word.cmp.fin(b8,False{},Word.cmp.fin(b9,False{},high))))))))))),Cmp.is_lt(Word.cmp.fin(b1,False{},Word.cmp.fin(b2,False{},Word.cmp.fin(b3,False{},Word.cmp.fin(b4,False{},Word.cmp.fin(b5,False{},Word.cmp.fin(b6,False{},Word.cmp.fin(b7,False{},Word.cmp.fin(b8,False{},Word.cmp.fin(b9,False{},high)))))))))),L.cmp_low_against_zero_ignores_lt(b0,Word.cmp.fin(b1,False{},Word.cmp.fin(b2,False{},Word.cmp.fin(b3,False{},Word.cmp.fin(b4,False{},Word.cmp.fin(b5,False{},Word.cmp.fin(b6,False{},Word.cmp.fin(b7,False{},Word.cmp.fin(b8,False{},Word.cmp.fin(b9,False{},high))))))))))) :
    {_ == Cmp.is_lt(high) : Bool}
  %Equal.sym(Bool,Cmp.is_lt(Word.cmp.fin(b1,False{},Word.cmp.fin(b2,False{},Word.cmp.fin(b3,False{},Word.cmp.fin(b4,False{},Word.cmp.fin(b5,False{},Word.cmp.fin(b6,False{},Word.cmp.fin(b7,False{},Word.cmp.fin(b8,False{},Word.cmp.fin(b9,False{},high)))))))))),Cmp.is_lt(Word.cmp.fin(b2,False{},Word.cmp.fin(b3,False{},Word.cmp.fin(b4,False{},Word.cmp.fin(b5,False{},Word.cmp.fin(b6,False{},Word.cmp.fin(b7,False{},Word.cmp.fin(b8,False{},Word.cmp.fin(b9,False{},high))))))))),L.cmp_low_against_zero_ignores_lt(b1,Word.cmp.fin(b2,False{},Word.cmp.fin(b3,False{},Word.cmp.fin(b4,False{},Word.cmp.fin(b5,False{},Word.cmp.fin(b6,False{},Word.cmp.fin(b7,False{},Word.cmp.fin(b8,False{},Word.cmp.fin(b9,False{},high)))))))))) :
    {_ == Cmp.is_lt(high) : Bool}
  %Equal.sym(Bool,Cmp.is_lt(Word.cmp.fin(b2,False{},Word.cmp.fin(b3,False{},Word.cmp.fin(b4,False{},Word.cmp.fin(b5,False{},Word.cmp.fin(b6,False{},Word.cmp.fin(b7,False{},Word.cmp.fin(b8,False{},Word.cmp.fin(b9,False{},high))))))))),Cmp.is_lt(Word.cmp.fin(b3,False{},Word.cmp.fin(b4,False{},Word.cmp.fin(b5,False{},Word.cmp.fin(b6,False{},Word.cmp.fin(b7,False{},Word.cmp.fin(b8,False{},Word.cmp.fin(b9,False{},high)))))))),L.cmp_low_against_zero_ignores_lt(b2,Word.cmp.fin(b3,False{},Word.cmp.fin(b4,False{},Word.cmp.fin(b5,False{},Word.cmp.fin(b6,False{},Word.cmp.fin(b7,False{},Word.cmp.fin(b8,False{},Word.cmp.fin(b9,False{},high))))))))) :
    {_ == Cmp.is_lt(high) : Bool}
  %Equal.sym(Bool,Cmp.is_lt(Word.cmp.fin(b3,False{},Word.cmp.fin(b4,False{},Word.cmp.fin(b5,False{},Word.cmp.fin(b6,False{},Word.cmp.fin(b7,False{},Word.cmp.fin(b8,False{},Word.cmp.fin(b9,False{},high)))))))),Cmp.is_lt(Word.cmp.fin(b4,False{},Word.cmp.fin(b5,False{},Word.cmp.fin(b6,False{},Word.cmp.fin(b7,False{},Word.cmp.fin(b8,False{},Word.cmp.fin(b9,False{},high))))))),L.cmp_low_against_zero_ignores_lt(b3,Word.cmp.fin(b4,False{},Word.cmp.fin(b5,False{},Word.cmp.fin(b6,False{},Word.cmp.fin(b7,False{},Word.cmp.fin(b8,False{},Word.cmp.fin(b9,False{},high)))))))) :
    {_ == Cmp.is_lt(high) : Bool}
  %Equal.sym(Bool,Cmp.is_lt(Word.cmp.fin(b4,False{},Word.cmp.fin(b5,False{},Word.cmp.fin(b6,False{},Word.cmp.fin(b7,False{},Word.cmp.fin(b8,False{},Word.cmp.fin(b9,False{},high))))))),Cmp.is_lt(Word.cmp.fin(b5,False{},Word.cmp.fin(b6,False{},Word.cmp.fin(b7,False{},Word.cmp.fin(b8,False{},Word.cmp.fin(b9,False{},high)))))),L.cmp_low_against_zero_ignores_lt(b4,Word.cmp.fin(b5,False{},Word.cmp.fin(b6,False{},Word.cmp.fin(b7,False{},Word.cmp.fin(b8,False{},Word.cmp.fin(b9,False{},high))))))) :
    {_ == Cmp.is_lt(high) : Bool}
  %Equal.sym(Bool,Cmp.is_lt(Word.cmp.fin(b5,False{},Word.cmp.fin(b6,False{},Word.cmp.fin(b7,False{},Word.cmp.fin(b8,False{},Word.cmp.fin(b9,False{},high)))))),Cmp.is_lt(Word.cmp.fin(b6,False{},Word.cmp.fin(b7,False{},Word.cmp.fin(b8,False{},Word.cmp.fin(b9,False{},high))))),L.cmp_low_against_zero_ignores_lt(b5,Word.cmp.fin(b6,False{},Word.cmp.fin(b7,False{},Word.cmp.fin(b8,False{},Word.cmp.fin(b9,False{},high)))))) :
    {_ == Cmp.is_lt(high) : Bool}
  %Equal.sym(Bool,Cmp.is_lt(Word.cmp.fin(b6,False{},Word.cmp.fin(b7,False{},Word.cmp.fin(b8,False{},Word.cmp.fin(b9,False{},high))))),Cmp.is_lt(Word.cmp.fin(b7,False{},Word.cmp.fin(b8,False{},Word.cmp.fin(b9,False{},high)))),L.cmp_low_against_zero_ignores_lt(b6,Word.cmp.fin(b7,False{},Word.cmp.fin(b8,False{},Word.cmp.fin(b9,False{},high))))) :
    {_ == Cmp.is_lt(high) : Bool}
  %Equal.sym(Bool,Cmp.is_lt(Word.cmp.fin(b7,False{},Word.cmp.fin(b8,False{},Word.cmp.fin(b9,False{},high)))),Cmp.is_lt(Word.cmp.fin(b8,False{},Word.cmp.fin(b9,False{},high))),L.cmp_low_against_zero_ignores_lt(b7,Word.cmp.fin(b8,False{},Word.cmp.fin(b9,False{},high)))) :
    {_ == Cmp.is_lt(high) : Bool}
  %Equal.sym(Bool,Cmp.is_lt(Word.cmp.fin(b8,False{},Word.cmp.fin(b9,False{},high))),Cmp.is_lt(Word.cmp.fin(b9,False{},high)),L.cmp_low_against_zero_ignores_lt(b8,Word.cmp.fin(b9,False{},high))) :
    {_ == Cmp.is_lt(high) : Bool}
  %Equal.sym(Bool,Cmp.is_lt(Word.cmp.fin(b9,False{},high)),Cmp.is_lt(high),L.cmp_low_against_zero_ignores_lt(b9,high)) :
    {_ == Cmp.is_lt(high) : Bool}
  {==}

def L.peer_removal_keeps_vacancy(old,digit):
  match old digit:
    case U32{WCon{b0,WCon{b1,WCon{b2,WCon{b3,WCon{b4,WCon{b5,WCon{b6,WCon{b7,WCon{b8,WCon{b9,upper}}}}}}}}}}} L.D0{}:
      +old_lt = (L.queued_packing(b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,upper) < 1024 : U32)
      +new_upper = Word.and(22n,upper,L.word_ones(22n))
      +new_lt = (L.queued_packing(Bool.and(b0,False{}),Bool.and(b1,True{}),Bool.and(b2,True{}),Bool.and(b3,True{}),Bool.and(b4,True{}),Bool.and(b5,True{}),Bool.and(b6,True{}),Bool.and(b7,True{}),Bool.and(b8,True{}),Bool.and(b9,True{}),new_upper) < 1024 : U32)
      Equal.trans(Bool,new_lt,L.vacancy_from_upper(new_upper),old_lt,
        L.queued_packed_vacancy_from_upper(Bool.and(b0,False{}),Bool.and(b1,True{}),Bool.and(b2,True{}),Bool.and(b3,True{}),Bool.and(b4,True{}),Bool.and(b5,True{}),Bool.and(b6,True{}),Bool.and(b7,True{}),Bool.and(b8,True{}),Bool.and(b9,True{}),new_upper),
        Equal.trans(Bool,L.vacancy_from_upper(new_upper),L.vacancy_from_upper(upper),old_lt,
          Equal.cong(Word(22n),Bool,t => L.vacancy_from_upper(t),new_upper,upper,L.word_and_ones_right(22n,upper)),
          Equal.sym(Bool,old_lt,L.vacancy_from_upper(upper),L.queued_packed_vacancy_from_upper(b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,upper))))
    case U32{WCon{b0,WCon{b1,WCon{b2,WCon{b3,WCon{b4,WCon{b5,WCon{b6,WCon{b7,WCon{b8,WCon{b9,upper}}}}}}}}}}} L.D1{}:
      +old_lt = (L.queued_packing(b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,upper) < 1024 : U32)
      +new_upper = Word.and(22n,upper,L.word_ones(22n))
      +new_lt = (L.queued_packing(Bool.and(b0,True{}),Bool.and(b1,False{}),Bool.and(b2,True{}),Bool.and(b3,True{}),Bool.and(b4,True{}),Bool.and(b5,True{}),Bool.and(b6,True{}),Bool.and(b7,True{}),Bool.and(b8,True{}),Bool.and(b9,True{}),new_upper) < 1024 : U32)
      Equal.trans(Bool,new_lt,L.vacancy_from_upper(new_upper),old_lt,
        L.queued_packed_vacancy_from_upper(Bool.and(b0,True{}),Bool.and(b1,False{}),Bool.and(b2,True{}),Bool.and(b3,True{}),Bool.and(b4,True{}),Bool.and(b5,True{}),Bool.and(b6,True{}),Bool.and(b7,True{}),Bool.and(b8,True{}),Bool.and(b9,True{}),new_upper),
        Equal.trans(Bool,L.vacancy_from_upper(new_upper),L.vacancy_from_upper(upper),old_lt,
          Equal.cong(Word(22n),Bool,t => L.vacancy_from_upper(t),new_upper,upper,L.word_and_ones_right(22n,upper)),
          Equal.sym(Bool,old_lt,L.vacancy_from_upper(upper),L.queued_packed_vacancy_from_upper(b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,upper))))
    case U32{WCon{b0,WCon{b1,WCon{b2,WCon{b3,WCon{b4,WCon{b5,WCon{b6,WCon{b7,WCon{b8,WCon{b9,upper}}}}}}}}}}} L.D2{}:
      +old_lt = (L.queued_packing(b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,upper) < 1024 : U32)
      +new_upper = Word.and(22n,upper,L.word_ones(22n))
      +new_lt = (L.queued_packing(Bool.and(b0,True{}),Bool.and(b1,True{}),Bool.and(b2,False{}),Bool.and(b3,True{}),Bool.and(b4,True{}),Bool.and(b5,True{}),Bool.and(b6,True{}),Bool.and(b7,True{}),Bool.and(b8,True{}),Bool.and(b9,True{}),new_upper) < 1024 : U32)
      Equal.trans(Bool,new_lt,L.vacancy_from_upper(new_upper),old_lt,
        L.queued_packed_vacancy_from_upper(Bool.and(b0,True{}),Bool.and(b1,True{}),Bool.and(b2,False{}),Bool.and(b3,True{}),Bool.and(b4,True{}),Bool.and(b5,True{}),Bool.and(b6,True{}),Bool.and(b7,True{}),Bool.and(b8,True{}),Bool.and(b9,True{}),new_upper),
        Equal.trans(Bool,L.vacancy_from_upper(new_upper),L.vacancy_from_upper(upper),old_lt,
          Equal.cong(Word(22n),Bool,t => L.vacancy_from_upper(t),new_upper,upper,L.word_and_ones_right(22n,upper)),
          Equal.sym(Bool,old_lt,L.vacancy_from_upper(upper),L.queued_packed_vacancy_from_upper(b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,upper))))
    case U32{WCon{b0,WCon{b1,WCon{b2,WCon{b3,WCon{b4,WCon{b5,WCon{b6,WCon{b7,WCon{b8,WCon{b9,upper}}}}}}}}}}} L.D3{}:
      +old_lt = (L.queued_packing(b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,upper) < 1024 : U32)
      +new_upper = Word.and(22n,upper,L.word_ones(22n))
      +new_lt = (L.queued_packing(Bool.and(b0,True{}),Bool.and(b1,True{}),Bool.and(b2,True{}),Bool.and(b3,False{}),Bool.and(b4,True{}),Bool.and(b5,True{}),Bool.and(b6,True{}),Bool.and(b7,True{}),Bool.and(b8,True{}),Bool.and(b9,True{}),new_upper) < 1024 : U32)
      Equal.trans(Bool,new_lt,L.vacancy_from_upper(new_upper),old_lt,
        L.queued_packed_vacancy_from_upper(Bool.and(b0,True{}),Bool.and(b1,True{}),Bool.and(b2,True{}),Bool.and(b3,False{}),Bool.and(b4,True{}),Bool.and(b5,True{}),Bool.and(b6,True{}),Bool.and(b7,True{}),Bool.and(b8,True{}),Bool.and(b9,True{}),new_upper),
        Equal.trans(Bool,L.vacancy_from_upper(new_upper),L.vacancy_from_upper(upper),old_lt,
          Equal.cong(Word(22n),Bool,t => L.vacancy_from_upper(t),new_upper,upper,L.word_and_ones_right(22n,upper)),
          Equal.sym(Bool,old_lt,L.vacancy_from_upper(upper),L.queued_packed_vacancy_from_upper(b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,upper))))
    case U32{WCon{b0,WCon{b1,WCon{b2,WCon{b3,WCon{b4,WCon{b5,WCon{b6,WCon{b7,WCon{b8,WCon{b9,upper}}}}}}}}}}} L.D4{}:
      +old_lt = (L.queued_packing(b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,upper) < 1024 : U32)
      +new_upper = Word.and(22n,upper,L.word_ones(22n))
      +new_lt = (L.queued_packing(Bool.and(b0,True{}),Bool.and(b1,True{}),Bool.and(b2,True{}),Bool.and(b3,True{}),Bool.and(b4,False{}),Bool.and(b5,True{}),Bool.and(b6,True{}),Bool.and(b7,True{}),Bool.and(b8,True{}),Bool.and(b9,True{}),new_upper) < 1024 : U32)
      Equal.trans(Bool,new_lt,L.vacancy_from_upper(new_upper),old_lt,
        L.queued_packed_vacancy_from_upper(Bool.and(b0,True{}),Bool.and(b1,True{}),Bool.and(b2,True{}),Bool.and(b3,True{}),Bool.and(b4,False{}),Bool.and(b5,True{}),Bool.and(b6,True{}),Bool.and(b7,True{}),Bool.and(b8,True{}),Bool.and(b9,True{}),new_upper),
        Equal.trans(Bool,L.vacancy_from_upper(new_upper),L.vacancy_from_upper(upper),old_lt,
          Equal.cong(Word(22n),Bool,t => L.vacancy_from_upper(t),new_upper,upper,L.word_and_ones_right(22n,upper)),
          Equal.sym(Bool,old_lt,L.vacancy_from_upper(upper),L.queued_packed_vacancy_from_upper(b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,upper))))
    case U32{WCon{b0,WCon{b1,WCon{b2,WCon{b3,WCon{b4,WCon{b5,WCon{b6,WCon{b7,WCon{b8,WCon{b9,upper}}}}}}}}}}} L.D5{}:
      +old_lt = (L.queued_packing(b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,upper) < 1024 : U32)
      +new_upper = Word.and(22n,upper,L.word_ones(22n))
      +new_lt = (L.queued_packing(Bool.and(b0,True{}),Bool.and(b1,True{}),Bool.and(b2,True{}),Bool.and(b3,True{}),Bool.and(b4,True{}),Bool.and(b5,False{}),Bool.and(b6,True{}),Bool.and(b7,True{}),Bool.and(b8,True{}),Bool.and(b9,True{}),new_upper) < 1024 : U32)
      Equal.trans(Bool,new_lt,L.vacancy_from_upper(new_upper),old_lt,
        L.queued_packed_vacancy_from_upper(Bool.and(b0,True{}),Bool.and(b1,True{}),Bool.and(b2,True{}),Bool.and(b3,True{}),Bool.and(b4,True{}),Bool.and(b5,False{}),Bool.and(b6,True{}),Bool.and(b7,True{}),Bool.and(b8,True{}),Bool.and(b9,True{}),new_upper),
        Equal.trans(Bool,L.vacancy_from_upper(new_upper),L.vacancy_from_upper(upper),old_lt,
          Equal.cong(Word(22n),Bool,t => L.vacancy_from_upper(t),new_upper,upper,L.word_and_ones_right(22n,upper)),
          Equal.sym(Bool,old_lt,L.vacancy_from_upper(upper),L.queued_packed_vacancy_from_upper(b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,upper))))
    case U32{WCon{b0,WCon{b1,WCon{b2,WCon{b3,WCon{b4,WCon{b5,WCon{b6,WCon{b7,WCon{b8,WCon{b9,upper}}}}}}}}}}} L.D6{}:
      +old_lt = (L.queued_packing(b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,upper) < 1024 : U32)
      +new_upper = Word.and(22n,upper,L.word_ones(22n))
      +new_lt = (L.queued_packing(Bool.and(b0,True{}),Bool.and(b1,True{}),Bool.and(b2,True{}),Bool.and(b3,True{}),Bool.and(b4,True{}),Bool.and(b5,True{}),Bool.and(b6,False{}),Bool.and(b7,True{}),Bool.and(b8,True{}),Bool.and(b9,True{}),new_upper) < 1024 : U32)
      Equal.trans(Bool,new_lt,L.vacancy_from_upper(new_upper),old_lt,
        L.queued_packed_vacancy_from_upper(Bool.and(b0,True{}),Bool.and(b1,True{}),Bool.and(b2,True{}),Bool.and(b3,True{}),Bool.and(b4,True{}),Bool.and(b5,True{}),Bool.and(b6,False{}),Bool.and(b7,True{}),Bool.and(b8,True{}),Bool.and(b9,True{}),new_upper),
        Equal.trans(Bool,L.vacancy_from_upper(new_upper),L.vacancy_from_upper(upper),old_lt,
          Equal.cong(Word(22n),Bool,t => L.vacancy_from_upper(t),new_upper,upper,L.word_and_ones_right(22n,upper)),
          Equal.sym(Bool,old_lt,L.vacancy_from_upper(upper),L.queued_packed_vacancy_from_upper(b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,upper))))
    case U32{WCon{b0,WCon{b1,WCon{b2,WCon{b3,WCon{b4,WCon{b5,WCon{b6,WCon{b7,WCon{b8,WCon{b9,upper}}}}}}}}}}} L.D7{}:
      +old_lt = (L.queued_packing(b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,upper) < 1024 : U32)
      +new_upper = Word.and(22n,upper,L.word_ones(22n))
      +new_lt = (L.queued_packing(Bool.and(b0,True{}),Bool.and(b1,True{}),Bool.and(b2,True{}),Bool.and(b3,True{}),Bool.and(b4,True{}),Bool.and(b5,True{}),Bool.and(b6,True{}),Bool.and(b7,False{}),Bool.and(b8,True{}),Bool.and(b9,True{}),new_upper) < 1024 : U32)
      Equal.trans(Bool,new_lt,L.vacancy_from_upper(new_upper),old_lt,
        L.queued_packed_vacancy_from_upper(Bool.and(b0,True{}),Bool.and(b1,True{}),Bool.and(b2,True{}),Bool.and(b3,True{}),Bool.and(b4,True{}),Bool.and(b5,True{}),Bool.and(b6,True{}),Bool.and(b7,False{}),Bool.and(b8,True{}),Bool.and(b9,True{}),new_upper),
        Equal.trans(Bool,L.vacancy_from_upper(new_upper),L.vacancy_from_upper(upper),old_lt,
          Equal.cong(Word(22n),Bool,t => L.vacancy_from_upper(t),new_upper,upper,L.word_and_ones_right(22n,upper)),
          Equal.sym(Bool,old_lt,L.vacancy_from_upper(upper),L.queued_packed_vacancy_from_upper(b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,upper))))
    case U32{WCon{b0,WCon{b1,WCon{b2,WCon{b3,WCon{b4,WCon{b5,WCon{b6,WCon{b7,WCon{b8,WCon{b9,upper}}}}}}}}}}} L.D8{}:
      +old_lt = (L.queued_packing(b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,upper) < 1024 : U32)
      +new_upper = Word.and(22n,upper,L.word_ones(22n))
      +new_lt = (L.queued_packing(Bool.and(b0,True{}),Bool.and(b1,True{}),Bool.and(b2,True{}),Bool.and(b3,True{}),Bool.and(b4,True{}),Bool.and(b5,True{}),Bool.and(b6,True{}),Bool.and(b7,True{}),Bool.and(b8,False{}),Bool.and(b9,True{}),new_upper) < 1024 : U32)
      Equal.trans(Bool,new_lt,L.vacancy_from_upper(new_upper),old_lt,
        L.queued_packed_vacancy_from_upper(Bool.and(b0,True{}),Bool.and(b1,True{}),Bool.and(b2,True{}),Bool.and(b3,True{}),Bool.and(b4,True{}),Bool.and(b5,True{}),Bool.and(b6,True{}),Bool.and(b7,True{}),Bool.and(b8,False{}),Bool.and(b9,True{}),new_upper),
        Equal.trans(Bool,L.vacancy_from_upper(new_upper),L.vacancy_from_upper(upper),old_lt,
          Equal.cong(Word(22n),Bool,t => L.vacancy_from_upper(t),new_upper,upper,L.word_and_ones_right(22n,upper)),
          Equal.sym(Bool,old_lt,L.vacancy_from_upper(upper),L.queued_packed_vacancy_from_upper(b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,upper))))
    case U32{WCon{b0,WCon{b1,WCon{b2,WCon{b3,WCon{b4,WCon{b5,WCon{b6,WCon{b7,WCon{b8,WCon{b9,upper}}}}}}}}}}} L.D9{}:
      +old_lt = (L.queued_packing(b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,upper) < 1024 : U32)
      +new_upper = Word.and(22n,upper,L.word_ones(22n))
      +new_lt = (L.queued_packing(Bool.and(b0,True{}),Bool.and(b1,True{}),Bool.and(b2,True{}),Bool.and(b3,True{}),Bool.and(b4,True{}),Bool.and(b5,True{}),Bool.and(b6,True{}),Bool.and(b7,True{}),Bool.and(b8,True{}),Bool.and(b9,False{}),new_upper) < 1024 : U32)
      Equal.trans(Bool,new_lt,L.vacancy_from_upper(new_upper),old_lt,
        L.queued_packed_vacancy_from_upper(Bool.and(b0,True{}),Bool.and(b1,True{}),Bool.and(b2,True{}),Bool.and(b3,True{}),Bool.and(b4,True{}),Bool.and(b5,True{}),Bool.and(b6,True{}),Bool.and(b7,True{}),Bool.and(b8,True{}),Bool.and(b9,False{}),new_upper),
        Equal.trans(Bool,L.vacancy_from_upper(new_upper),L.vacancy_from_upper(upper),old_lt,
          Equal.cong(Word(22n),Bool,t => L.vacancy_from_upper(t),new_upper,upper,L.word_and_ones_right(22n,upper)),
          Equal.sym(Bool,old_lt,L.vacancy_from_upper(upper),L.queued_packed_vacancy_from_upper(b0,b1,b2,b3,b4,b5,b6,b7,b8,b9,upper))))

def L.changed_peer_keeps_vacancy_image(image,needed,pos,digit,shape,apart):
  match needed:
    case False{}:
      {==}
    case True{}:
      b = L.image_board(image)
      +raw = L.cell_value(L.image_board(image),pos)
      +bit = Board.bit(L.digit_word(digit))
      %Equal.sym(U32,L.cell_value(Q.changed(True{},pos,bit,b,raw),pos),L.peer_mask(raw,bit),
        L.changed_peer_word_image(image,pos,bit,raw,shape,apart)) :
        {L.QueuedVacant(_) == L.QueuedVacant(raw) : Bool}
      L.peer_removal_keeps_vacancy(raw,digit)

def L.actual_peer_keeps_vacancy_image(image,pos,digit,shape,apart):
  b = L.image_board(image)
  +raw = L.cell_value(L.image_board(image),pos)
  +bit = Board.bit(L.digit_word(digit))
  +needed = U32.is_ne(U32.and(raw,bit),0)
  %Equal.sym(Array<U32>,L.actual_peer(b,pos,bit),Q.changed(needed,pos,bit,b,raw),
    L.peer_normalized(b,pos,bit,L.board_read_witness(L.image_board(image),pos))) :
    {L.QueuedVacant(L.cell_value(_,pos)) == L.QueuedVacant(raw) : Bool}
  L.changed_peer_keeps_vacancy_image(image,needed,pos,digit,shape,apart)

def L.actual_peer_keeps_vacancy(b,pos,digit):
  L.on_reified_board(b,x => L.ActualPeerKeepsVacancy(x,pos,digit),L.reify_board(b),image => L.actual_peer_keeps_vacancy_image(image,pos,digit))

def L.first_actual_read_exact_parts(n,p,b,same,word,same_board,observed):
  %Equal.sym(Array<U32> & U32,Board.get_cell(b,p),(same,word),observed) :
    {Q.first_step(n,p,Q.first_read(_)) == Q.first_step(n,p,(b,L.QueuedVacant(Pair.snd(Array<U32>,U32,_)))) : Array<U32>}
  %Equal.sym(Array<U32>,same,b,same_board) :
    {Q.first_step(n,p,(_,L.QueuedVacant(word))) == Q.first_step(n,p,(b,L.QueuedVacant(word))) : Array<U32>}
  {==}

def L.first_actual_read_exact(n,p,b,read):
  (same,+word,(same_board,observed)) = read
  L.first_actual_read_exact_parts(n,p,b,same,word,same_board,observed)

def L.first_open_step_closed_matches_model(n,p,image,later):
  b = L.image_board(image)
  +p1 = (p + 1 : U32)
  %Equal.sym(Array<U32>,L.first_actual(b,n,p1),Q.first_step(n,p1,(b,L.queue_open_at(image,p1))),
    L.first_actual_read_exact(n,p1,b,L.board_read_witness(L.image_board(image),p1))) :
    {_ == Board.set_cell(b,108,L.first_open_index(n,p1,L.queue_open_at(image,p1),image)) : Array<U32>}
  later

def L.first_open_step_matches_model(n,p,open,image):
  match n open:
    case 0n True{}:
      {==}
    case 0n False{}:
      {==}
    case 1n+k True{}:
      {==}
    case 1n+k False{}:
      +p1 = (p + 1 : U32)
      L.first_open_step_closed_matches_model(k,p,image,L.first_open_step_matches_model(k,p1,L.queue_open_at(image,p1),image))

def L.first_open_scan_writes_exact_pointer(n,p,image):
  b = L.image_board(image)
  %Equal.sym(Array<U32>,L.first_actual(b,n,p),Q.first_step(n,p,(b,L.queue_open_at(image,p))),
    L.first_actual_read_exact(n,p,b,L.board_read_witness(L.image_board(image),p))) :
    {_ == Board.set_cell(b,108,L.first_open_index(n,p,L.queue_open_at(image,p),image)) : Array<U32>}
  L.first_open_step_matches_model(n,p,L.queue_open_at(image,p),image)

def L.first_open_scan_reads_exact_pointer(n,p,image):
  b = L.image_board(image)
  +index = L.first_open_index(n,p,L.queue_open_at(image,p),image)
  %Equal.sym(Array<U32>,L.first_actual(b,n,p),Board.set_cell(b,108,index),
    L.first_open_scan_writes_exact_pointer(n,p,image)) :
    {L.cell_value(_,108) == index : U32}
  L.board_set_get(L.image_board(image),108,index)

def L.first_open_model_no_skip(n,p,open,image,read):
  match n open:
    case 0n True{}:
      {==}
    case 0n False{}:
      {==}
    case 1n+k True{}:
      Inl{(read,{==})}
    case 1n+k False{}:
      +p1 = (p + 1 : U32)
      Inr{(read,L.first_open_model_no_skip(k,p1,L.queue_open_at(image,p1),image,{==}))}

def L.production_first_open_scan_no_skip(n,p,image):
  b = L.image_board(image)
  +index = L.first_open_index(n,p,L.queue_open_at(image,p),image)
  %Equal.sym(U32,L.cell_value(L.first_actual(b,n,p),108),index,L.first_open_scan_reads_exact_pointer(n,p,image)) :
    L.FirstOpenWitness(n,p,image,_)
  L.first_open_model_no_skip(n,p,L.queue_open_at(image,p),image,{==})

def L.refreshed_first_open_scan_no_skip(start,image):
  L.production_first_open_scan_no_skip(U32.to_nat((81 - start : U32)),start,image)

def L.refresh_at_pointer_does_not_skip(image,placed,start,observed,hit):
  b = L.image_board(image)
  +actual = L.cell_value(L.image_board(image),108)
  +n = U32.to_nat((81 - start : U32))
  %Equal.sym(Array<U32>,L.refresh_actual(b,placed),Q.refresh_needed(U32.is_eq(placed,actual),b,actual),
    L.refresh_normalized(b,placed,L.board_read_witness(L.image_board(image),108))) :
    L.FirstOpenWitness(n,start,image,L.cell_value(_,108))
  %Equal.sym(U32,actual,start,observed) :
    L.FirstOpenWitness(n,start,image,L.cell_value(Q.refresh_needed(U32.is_eq(placed,_),b,_),108))
  %Equal.sym(Bool,U32.is_eq(placed,start),True{},hit) :
    L.FirstOpenWitness(n,start,image,L.cell_value(Q.refresh_needed(_,b,start),108))
  L.refreshed_first_open_scan_no_skip(start,image)

def L.refresh_away_from_pointer_leaves_board(image,placed,start,observed,miss):
  b = L.image_board(image)
  +actual = L.cell_value(L.image_board(image),108)
  %Equal.sym(Array<U32>,L.refresh_actual(b,placed),Q.refresh_needed(U32.is_eq(placed,actual),b,actual),
    L.refresh_normalized(b,placed,L.board_read_witness(L.image_board(image),108))) :
    {_ == b : Array<U32>}
  %Equal.sym(U32,actual,start,observed) :
    {Q.refresh_needed(U32.is_eq(placed,_),b,_) == b : Array<U32>}
  %Equal.sym(Bool,U32.is_eq(placed,start),False{},miss) :
    {Q.refresh_needed(_,b,start) == b : Array<U32>}
  {==}

def L.first_open_witness_pointer_valid(n,p,image,ptr,witness,range):
  match n:
    case 0n:
      Inl{witness}
    case 1n+k:
      match witness:
        case Inl{here}:
          (open,chosen) = here
          (valid,rest) = range
          %Equal.sym(U32,ptr,p,chosen) : L.QueuedChoicePosition(L.image_board(image),_)
          Inr{(valid,open)}
        case Inr{later}:
          (closed,sub) = later
          (valid,rest) = range
          L.first_open_witness_pointer_valid(k,(p + 1 : U32),image,ptr,sub,rest)

def L.refreshed_logical_pointer_is_vacant_or_sentinel(row,col,image):
  +start = L.logical_position(row,col)
  L.first_open_witness_pointer_valid(U32.to_nat((81 - start : U32)),start,image,
    L.cell_value(Q.refresh_needed(True{},L.image_board(image),start),108),
    L.refreshed_first_open_scan_no_skip(start,image),L.queued_logical_start_range(row,col))

def L.peer_keeps_vacancy_same_parts(expect,image,q,digit,routes,shapes,prior):
  (keep,use) = routes
  (s0,s1) = shapes
  +bit = Board.bit(L.digit_word(digit))
  (keep,(L.peer_perfect(L.image_board(image),q,bit)(s0),
    Equal.trans(Bool,L.QueuedVacant(L.cell_value(L.actual_peer(L.image_board(image),q,bit),q)),
      L.QueuedVacant(L.cell_value(L.image_board(image),q)),expect,
      L.actual_peer_keeps_vacancy(L.image_board(image),q,digit)(s1,use),prior)))

def L.peer_keeps_vacancy_same(expect,image,q,digit,prior):
  (safe,(shape,mask)) = prior
  L.peer_keeps_vacancy_same_parts(expect,image,q,digit,
    L.copy_true(L.apart_guard(L.flag_slot(q),q),safe),
    L.copy_shape_proof(L.array_shape(L.image_board(image)),L.perfect_shape(7n),shape),mask)

def L.peer_keeps_vacancy_separate_step(expect,image,p,q,safe,placed,shapes,given,sep,flag):
  (s0,s1) = shapes
  +bit = Board.bit(L.digit_word(placed))
  preserved : L.VacancyValue(expect,L.cell_value(L.actual_peer(L.image_board(image),p,bit),q)) =
    %Equal.sym(U32,L.cell_value(L.actual_peer(L.image_board(image),p,bit),q),L.cell_value(L.image_board(image),q),
      L.peer_keeps(L.image_board(image),p,bit,q)(s1,sep,flag)) :
      L.VacancyValue(expect,_)
    given
  (safe,(L.peer_perfect(L.image_board(image),p,bit)(s0),preserved))

def L.peer_keeps_vacancy_separate_image(expect,image,p,q,placed,apart,state):
  (sep,flag) = apart
  (safe,(shape,given)) = state
  L.peer_keeps_vacancy_separate_step(expect,image,p,q,safe,placed,
    L.copy_shape_proof(L.array_shape(L.image_board(image)),L.perfect_shape(7n),shape),given,sep,flag)

def L.peer_vacancy_transition_image(expect,image,p,q,placed,route,state):
  match route:
    case Inl{same}:
      %Equal.sym(U32,p,q,same) :
        L.SafeVacancyAt(expect,L.actual_peer(L.image_board(image),_,Board.bit(L.digit_word(placed))),q)
      L.peer_keeps_vacancy_same(expect,image,q,placed,state)
    case Inr{apart}:
      L.peer_keeps_vacancy_separate_image(expect,image,p,q,placed,apart,state)

def L.peer_vacancy_transition(expect,b,p,q,placed):
  L.on_reified_board(b,x => L.PeerVacancyTransition(expect,x,p,q,placed),
    L.reify_board(b),image => L.peer_vacancy_transition_image(expect,image,p,q,placed))

def L.row_vacancy_step_image(expect,image,n,j,base,placed,q,d,routes,state,next):
  (here,tail) = routes
  +p = (base + j : U32)
  next(L.actual_peer(L.image_board(image),p,Board.bit(L.digit_word(d))),tail,
    L.peer_vacancy_transition(expect,L.image_board(image),p,q,d)(here,state))

def L.row_vacancy_step(expect,b,n,j,base,placed,q,d):
  L.on_reified_board(b,x => L.RowVacancyStep(expect,x,n,j,base,placed,q,d),
    L.reify_board(b),image => L.row_vacancy_step_image(expect,image,n,j,base,placed,q,d))

def L.row_vacancy_line(expect,n,j,base,placed,q,d,b,routes,state):
  match n:
    case 0n:
      state
    case 1n+k:
      L.row_vacancy_step(expect,b,k,j,base,placed,q,d)(routes,state,
        sub => rest => witness => L.row_vacancy_line(expect,k,(j + 1 : U32),base,placed,q,d,sub,rest,witness))

def L.column_vacancy_step_image(expect,image,n,j,col,placed,q,d,routes,state,next):
  (here,tail) = routes
  +p = (j * 9 + col : U32)
  next(L.actual_peer(L.image_board(image),p,Board.bit(L.digit_word(d))),tail,
    L.peer_vacancy_transition(expect,L.image_board(image),p,q,d)(here,state))

def L.column_vacancy_step(expect,b,n,j,col,placed,q,d):
  L.on_reified_board(b,x => L.ColumnVacancyStep(expect,x,n,j,col,placed,q,d),
    L.reify_board(b),image => L.column_vacancy_step_image(expect,image,n,j,col,placed,q,d))

def L.column_vacancy_line(expect,n,j,col,placed,q,d,b,routes,state):
  match n:
    case 0n:
      state
    case 1n+k:
      L.column_vacancy_step(expect,b,k,j,col,placed,q,d)(routes,state,
        sub => rest => witness => L.column_vacancy_line(expect,k,(j + 1 : U32),col,placed,q,d,sub,rest,witness))

def L.vacancy_peer_list_step_image(expect,image,p,tail,q,d,routes,state,next):
  (here,later) = routes
  next(L.actual_peer(L.image_board(image),p,Board.bit(L.digit_word(d))),later,
    L.peer_vacancy_transition(expect,L.image_board(image),p,q,d)(here,state))

def L.vacancy_peer_list_step(expect,b,p,tail,q,d,routes,state,next):
  proof : (L.PeerListRoutes(p <> tail,q) -> L.SafeVacancyAt(expect,b,q) ->
    L.VacancyPeerListProof(expect,tail,q,d) -> L.SafeVacancyAt(expect,L.run_peer_list(p <> tail,b,Board.bit(L.digit_word(d))),q)) =
    L.on_reified_board(b,x => (L.PeerListRoutes(p <> tail,q) -> L.SafeVacancyAt(expect,x,q) ->
      L.VacancyPeerListProof(expect,tail,q,d) -> L.SafeVacancyAt(expect,L.run_peer_list(p <> tail,x,Board.bit(L.digit_word(d))),q)),
      L.reify_board(b),image => L.vacancy_peer_list_step_image(expect,image,p,tail,q,d))
  proof(routes,state,next)

def L.peer_list_vacancy(expect,positions,q,d,b,routes,state):
  match positions:
    case Nil{}:
      state
    case +p <> tail:
      L.vacancy_peer_list_step(expect,b,p,tail,q,d,routes,state,sub => rest => witness => L.peer_list_vacancy(expect,tail,q,d,sub,rest,witness))

def L.box_four_keeps_vacancy(expect,b,base,r1,r2,c1,c2,q,d,routes,state):
  L.peer_list_vacancy(expect,L.box_positions(base,r1,r2,c1,c2),q,d,b,routes,state)

def L.vacancy_after_pointer_write(expect,image,out,q,safe,shapes,known,apart,witness):
  (s0,s1) = shapes
  (+ptr,actual) = witness
  b = L.image_board(image)
  %Equal.sym(Array<U32>,out,Board.set_cell(b,108,ptr),actual) :
    L.SafeVacancyAt(expect,_,q)
  preserved : L.VacancyValue(expect,L.cell_value(Board.set_cell(b,108,ptr),q)) =
    %Equal.sym(U32,L.cell_value(Board.set_cell(b,108,ptr),q),L.cell_value(b,q),
      L.perfect_write_keeps_cell(L.image_board(image),108,q,ptr,s1,apart)) :
      L.VacancyValue(expect,_)
    known
  (safe,(L.board_set_keeps_perfect(L.image_board(image),108,ptr,7n,s0),preserved))


def L.refresh_needed_vacancy_image(expect,image,needed,start,q,apart,state):
  match needed:
    case False{}:
      state
    case True{}:
      (safe,(shape,known)) = state
      +n = U32.to_nat((81 - start : U32))
      L.vacancy_after_pointer_write(expect,image,L.first_actual(L.image_board(image),n,start),q,safe,
        L.copy_shape_proof(L.array_shape(L.image_board(image)),L.perfect_shape(7n),shape),known,apart,
        L.first_actual_pointer(n,start,L.image_board(image),L.board_read_witness(L.image_board(image),start)))


def L.refresh_keeps_vacancy_image(expect,image,p,q,apart,state):
  b = L.image_board(image)
  +start = L.cell_value(L.image_board(image),108)
  +needed = U32.is_eq(p,start)
  %Equal.sym(Array<U32>,L.refresh_actual(b,p),Q.refresh_needed(needed,b,start),
    L.refresh_normalized(b,p,L.board_read_witness(L.image_board(image),108))) :
    L.SafeVacancyAt(expect,_,q)
  L.refresh_needed_vacancy_image(expect,image,needed,start,q,apart,state)

def L.refresh_keeps_vacancy(expect,b,p,q):
  L.on_reified_board(b,x => L.RefreshVacancyAt(expect,x,p,q),
    L.reify_board(b),image => L.refresh_keeps_vacancy_image(expect,image,p,q))

def L.clear_forced_vacancy_image_step(expect,image,p,q,safe,flag,shapes,known):
  (s0,s1) = shapes
  b = L.image_board(image)
  preserved : L.VacancyValue(expect,L.cell_value(Q.flag(b,p,False{}),q)) =
    %Equal.sym(U32,L.cell_value(Q.flag(b,p,False{}),q),L.cell_value(b,q),
      L.flag_keeps_cell(L.image_board(image),p,False{},q)(s1,flag)) :
      L.VacancyValue(expect,_)
    known
  (safe,(L.queue_flag_perfect(L.image_board(image),p,False{},s0),preserved))

def L.clear_forced_vacancy_image(expect,image,guess,p,q,flag,state):
  match guess:
    case True{}:
      state
    case False{}:
      (safe,(shape,known)) = state
      L.clear_forced_vacancy_image_step(expect,image,p,q,safe,flag,
        L.copy_shape_proof(L.array_shape(L.image_board(image)),L.perfect_shape(7n),shape),known)

def L.clear_forced_vacancy(expect,b,guess,p,q,flag,state):
  proof : (L.RoutedApart(L.flag_slot(p),q) -> L.SafeVacancyAt(expect,b,q) ->
    L.SafeVacancyAt(expect,Q.clear_forced(guess,b,p),q)) =
    L.on_reified_board(b,x => (L.RoutedApart(L.flag_slot(p),q) -> L.SafeVacancyAt(expect,x,q) ->
      L.SafeVacancyAt(expect,Q.clear_forced(guess,x,p),q)),L.reify_board(b),
      image => L.clear_forced_vacancy_image(expect,image,guess,p,q))
  proof(flag,state)

def L.write_vacancy_other_step(expect,image,p,value,q,safe,apart,shapes,known):
  (s0,s1) = shapes
  b = L.image_board(image)
  preserved : L.VacancyValue(expect,L.cell_value(Board.set_cell(b,p,value),q)) =
    %Equal.sym(U32,L.cell_value(Board.set_cell(b,p,value),q),L.cell_value(b,q),
      L.perfect_write_keeps_cell(L.image_board(image),p,q,value,s1,apart)) :
      L.VacancyValue(expect,_)
    known
  (safe,(L.board_set_keeps_perfect(L.image_board(image),p,value,7n,s0),preserved))

def L.write_vacancy_other_image(expect,image,p,value,q,apart,state):
  (safe,(shape,known)) = state
  L.write_vacancy_other_step(expect,image,p,value,q,safe,apart,
    L.copy_shape_proof(L.array_shape(L.image_board(image)),L.perfect_shape(7n),shape),known)

def L.write_vacancy_other(expect,b,p,value,q,apart,state):
  proof : (L.RoutedApart(p,q) -> L.SafeVacancyAt(expect,b,q) ->
    L.SafeVacancyAt(expect,Board.set_cell(b,p,value),q)) =
    L.on_reified_board(b,x => (L.RoutedApart(p,q) -> L.SafeVacancyAt(expect,x,q) ->
      L.SafeVacancyAt(expect,Board.set_cell(x,p,value),q)),L.reify_board(b),
      image => L.write_vacancy_other_image(expect,image,p,value,q))
  proof(apart,state)

def L.place_vacancy_peers_image(expect,image,p,q,d,routes,state):
  (row,(col,(box,ptr))) = routes
  L.refresh_keeps_vacancy(expect,L.place_boxes(L.image_board(image),p,d),p,q)(ptr,
    L.box_four_keeps_vacancy(expect,L.place_columns(L.image_board(image),p,d),L.place_box_base(p),L.place_box_r1(p),L.place_box_r2(p),L.place_box_c1(p),L.place_box_c2(p),q,d,box,
      L.column_vacancy_line(expect,9n,0,M.rem9(p),p,q,d,L.place_rows(L.image_board(image),p,d),col,
        L.row_vacancy_line(expect,9n,0,L.place_row_base(p),p,q,d,L.image_board(image),row,state))))

def L.place_peers_keep_vacancy(expect,b,p,q,d):
  L.on_reified_board(b,x => L.PlacePeersVacancy(expect,x,p,q,d),
    L.reify_board(b),image => L.place_vacancy_peers_image(expect,image,p,q,d))

def L.place_keeps_vacancy_image(expect,image,guess,p,q,d,apart,flag,routes,state):
  after_clear = Q.clear_forced(guess,L.image_board(image),p)
  after_write = Board.set_cell(Q.clear_forced(guess,L.image_board(image),p),p,L.fixed_word(d))
  L.place_peers_keep_vacancy(expect,after_write,p,q,d)(routes,
    L.write_vacancy_other(expect,after_clear,p,L.fixed_word(d),q,apart,
      L.clear_forced_vacancy(expect,L.image_board(image),guess,p,q,flag,state)))

def L.queued_place_keeps_vacancy(expect,b,guess,p,q,d):
  L.on_reified_board(b,x => L.PlaceKeepsVacancy(expect,x,guess,p,q,d),
    L.reify_board(b),image => L.place_keeps_vacancy_image(expect,image,guess,p,q,d))


def L.logical_placement_keeps_other_vacancy_state(expect,b,guess,sr,sc,wr,wc,digit,distinct,state):
  +p = L.logical_position(sr,sc)
  +q = L.logical_position(wr,wc)
  L.queued_place_keeps_vacancy(expect,b,guess,p,q,digit)(
    L.logical_distinct_apart(p,q,distinct,L.matrix_logical_entry(sr,sc,wr,wc),
      L.logical_address_facts(sr,sc),L.logical_address_facts(wr,wc)),
    L.any_logical_flag_route(sr,sc,wr,wc),
    L.placement_routes_from_coordinates(sr,sc,wr,wc),state)


def L.safe_vacancy_mask(expect,b,q,state):
  (safe,(shape,prior)) = state
  prior

def L.logical_placement_preserves_other_vacancy(expect,b,guess,sr,sc,wr,wc,digit,distinct,shape,prior):
  +p = L.logical_position(sr,sc)
  +q = L.logical_position(wr,wc)
  L.safe_vacancy_mask(expect,Q.place(guess,p,L.digit_word(digit),b),q,
    L.logical_placement_keeps_other_vacancy_state(expect,b,guess,sr,sc,wr,wc,digit,distinct,
      (L.any_logical_flag_route(wr,wc,wr,wc),(shape,prior))))

def L.clear_forced_preserves_board128(b,guess,p,shape):
  match guess:
    case False{}:
      L.queue_flag_perfect(b,p,False{},shape)
    case True{}:
      shape

def L.fixed_write_after_clear_image(image,guess,p,digit,shape):
  +word = L.fixed_word(digit)
  (L.board_set_keeps_perfect(Q.clear_forced(guess,L.image_board(image),p),p,word,7n,
    L.clear_forced_preserves_board128(L.image_board(image),guess,p,shape)),
    L.board_set_get(Q.clear_forced(guess,L.image_board(image),p),p,word))

def L.queued_place_target_fixed_image(image,guess,p,d,routes,shape):
  after_write = Board.set_cell(Q.clear_forced(guess,L.image_board(image),p),p,L.fixed_word(d))
  L.place_peers_keeps(after_write,p,p,d,d)(routes,L.fixed_write_after_clear_image(image,guess,p,d,shape))

def L.queued_place_target_fixed(b,guess,p,d):
  L.on_reified_board(b,x => L.PlaceTargetFixed(x,guess,p,d),
    L.reify_board(b),image => L.queued_place_target_fixed_image(image,guess,p,d))

def L.logical_placement_fixes_target(b,guess,row,col,digit,shape):
  +p = L.logical_position(row,col)
  L.queued_place_target_fixed(b,guess,p,digit)(L.placement_routes_from_coordinates(row,col,row,col),shape)

def L.fixed_clue_is_closed(b,p,d,fixed,nonblank):
  %Equal.sym(U32,L.cell_value(b,p),L.fixed_word(d),L.fixed_clue_word(b,p,d,fixed)) :
    {L.QueuedVacant(_) == False{} : Bool}
  L.queue_fixed_raw_word_is_closed(d,nonblank)

def L.encode_routes_from_sweep(n,p,q,both):
  (route,unused) = both
  route

def L.queued_encode_pointer_routes():
  L.encode_routes_from_sweep(81n,0,108,L.sweep_witnesses(81n,0,108,{==}))

def L.queued_encode_keeps_pointer_parts(image,shapes):
  (s0,s1) = shapes
  Equal.trans(U32,L.cell_value(Q.encode(L.image_board(image)),108),
    L.cell_value(L.queue_seed(L.image_board(image)),108),L.cell_value(L.image_board(image),108),
    L.encode_sweep_keeps(81n,0,108,L.queue_seed(L.image_board(image)),
      L.queue_seed_perfect(L.image_board(image),s0),L.queued_encode_pointer_routes()),
    L.queue_seed_keeps_cell(L.image_board(image),108)(s1,{==},{==},{==}))

def L.queued_encode_keeps_pointer_image(image,shape):
  L.queued_encode_keeps_pointer_parts(image,
    L.copy_shape_proof(L.array_shape(L.image_board(image)),L.perfect_shape(7n),shape))

def L.queued_encode_keeps_pointer(b):
  L.on_reified_board(b,x => L.QueueEncodeKeepsPointer(x),
    L.reify_board(b),image => L.queued_encode_keeps_pointer_image(image))
def L.peer_keeps_pointer_word_separate_step(expect,image,p,q,safe,placed,shapes,given,sep,flag):
  (s0,s1) = shapes
  +bit = Board.bit(L.digit_word(placed))
  preserved : L.PointerWordValue(expect,L.cell_value(L.actual_peer(L.image_board(image),p,bit),q)) =
    %Equal.sym(U32,L.cell_value(L.actual_peer(L.image_board(image),p,bit),q),L.cell_value(L.image_board(image),q),
      L.peer_keeps(L.image_board(image),p,bit,q)(s1,sep,flag)) :
      L.PointerWordValue(expect,_)
    given
  (safe,(L.peer_perfect(L.image_board(image),p,bit)(s0),preserved))

def L.peer_keeps_pointer_word_separate_image(expect,image,p,q,placed,apart,state):
  (sep,flag) = apart
  (safe,(shape,given)) = state
  L.peer_keeps_pointer_word_separate_step(expect,image,p,q,safe,placed,
    L.copy_shape_proof(L.array_shape(L.image_board(image)),L.perfect_shape(7n),shape),given,sep,flag)

def L.peer_pointer_word_transition_image(expect,image,p,q,placed,route,state):
  L.peer_keeps_pointer_word_separate_image(expect,image,p,q,placed,route,state)

def L.peer_pointer_word_transition(expect,b,p,q,placed):
  L.on_reified_board(b,x => L.PeerPointerWordTransition(expect,x,p,q,placed),
    L.reify_board(b),image => L.peer_pointer_word_transition_image(expect,image,p,q,placed))

def L.row_pointer_word_step_image(expect,image,n,j,base,placed,q,d,routes,state,next):
  (here,tail) = routes
  +p = (base + j : U32)
  next(L.actual_peer(L.image_board(image),p,Board.bit(L.digit_word(d))),tail,
    L.peer_pointer_word_transition(expect,L.image_board(image),p,q,d)(here,state))

def L.row_pointer_word_step(expect,b,n,j,base,placed,q,d):
  L.on_reified_board(b,x => L.RowPointerWordStep(expect,x,n,j,base,placed,q,d),
    L.reify_board(b),image => L.row_pointer_word_step_image(expect,image,n,j,base,placed,q,d))

def L.row_pointer_word_line(expect,n,j,base,placed,q,d,b,routes,state):
  match n:
    case 0n:
      state
    case 1n+k:
      L.row_pointer_word_step(expect,b,k,j,base,placed,q,d)(routes,state,
        sub => rest => witness => L.row_pointer_word_line(expect,k,(j + 1 : U32),base,placed,q,d,sub,rest,witness))

def L.column_pointer_word_step_image(expect,image,n,j,col,placed,q,d,routes,state,next):
  (here,tail) = routes
  +p = (j * 9 + col : U32)
  next(L.actual_peer(L.image_board(image),p,Board.bit(L.digit_word(d))),tail,
    L.peer_pointer_word_transition(expect,L.image_board(image),p,q,d)(here,state))

def L.column_pointer_word_step(expect,b,n,j,col,placed,q,d):
  L.on_reified_board(b,x => L.ColumnPointerWordStep(expect,x,n,j,col,placed,q,d),
    L.reify_board(b),image => L.column_pointer_word_step_image(expect,image,n,j,col,placed,q,d))

def L.column_pointer_word_line(expect,n,j,col,placed,q,d,b,routes,state):
  match n:
    case 0n:
      state
    case 1n+k:
      L.column_pointer_word_step(expect,b,k,j,col,placed,q,d)(routes,state,
        sub => rest => witness => L.column_pointer_word_line(expect,k,(j + 1 : U32),col,placed,q,d,sub,rest,witness))

def L.pointer_word_peer_list_step_image(expect,image,p,tail,q,d,routes,state,next):
  (here,later) = routes
  next(L.actual_peer(L.image_board(image),p,Board.bit(L.digit_word(d))),later,
    L.peer_pointer_word_transition(expect,L.image_board(image),p,q,d)(here,state))

def L.pointer_word_peer_list_step(expect,b,p,tail,q,d,routes,state,next):
  proof : (L.DistinctPeerListRoutes(p <> tail,q) -> L.SafePointerWordAt(expect,b,q) ->
    L.PointerWordPeerListProof(expect,tail,q,d) -> L.SafePointerWordAt(expect,L.run_peer_list(p <> tail,b,Board.bit(L.digit_word(d))),q)) =
    L.on_reified_board(b,x => (L.DistinctPeerListRoutes(p <> tail,q) -> L.SafePointerWordAt(expect,x,q) ->
      L.PointerWordPeerListProof(expect,tail,q,d) -> L.SafePointerWordAt(expect,L.run_peer_list(p <> tail,x,Board.bit(L.digit_word(d))),q)),
      L.reify_board(b),image => L.pointer_word_peer_list_step_image(expect,image,p,tail,q,d))
  proof(routes,state,next)

def L.peer_list_pointer_word(expect,positions,q,d,b,routes,state):
  match positions:
    case Nil{}:
      state
    case +p <> tail:
      L.pointer_word_peer_list_step(expect,b,p,tail,q,d,routes,state,sub => rest => witness => L.peer_list_pointer_word(expect,tail,q,d,sub,rest,witness))

def L.box_four_keeps_pointer_word(expect,b,base,r1,r2,c1,c2,q,d,routes,state):
  L.peer_list_pointer_word(expect,L.box_positions(base,r1,r2,c1,c2),q,d,b,routes,state)

def L.clear_forced_pointer_word_image_step(expect,image,p,q,safe,flag,shapes,known):
  (s0,s1) = shapes
  b = L.image_board(image)
  preserved : L.PointerWordValue(expect,L.cell_value(Q.flag(b,p,False{}),q)) =
    %Equal.sym(U32,L.cell_value(Q.flag(b,p,False{}),q),L.cell_value(b,q),
      L.flag_keeps_cell(L.image_board(image),p,False{},q)(s1,flag)) :
      L.PointerWordValue(expect,_)
    known
  (safe,(L.queue_flag_perfect(L.image_board(image),p,False{},s0),preserved))

def L.clear_forced_pointer_word_image(expect,image,guess,p,q,flag,state):
  match guess:
    case True{}:
      state
    case False{}:
      (safe,(shape,known)) = state
      L.clear_forced_pointer_word_image_step(expect,image,p,q,safe,flag,
        L.copy_shape_proof(L.array_shape(L.image_board(image)),L.perfect_shape(7n),shape),known)

def L.clear_forced_pointer_word(expect,b,guess,p,q,flag,state):
  proof : (L.RoutedApart(L.flag_slot(p),q) -> L.SafePointerWordAt(expect,b,q) ->
    L.SafePointerWordAt(expect,Q.clear_forced(guess,b,p),q)) =
    L.on_reified_board(b,x => (L.RoutedApart(L.flag_slot(p),q) -> L.SafePointerWordAt(expect,x,q) ->
      L.SafePointerWordAt(expect,Q.clear_forced(guess,x,p),q)),L.reify_board(b),
      image => L.clear_forced_pointer_word_image(expect,image,guess,p,q))
  proof(flag,state)

def L.write_pointer_word_other_step(expect,image,p,value,q,safe,apart,shapes,known):
  (s0,s1) = shapes
  b = L.image_board(image)
  preserved : L.PointerWordValue(expect,L.cell_value(Board.set_cell(b,p,value),q)) =
    %Equal.sym(U32,L.cell_value(Board.set_cell(b,p,value),q),L.cell_value(b,q),
      L.perfect_write_keeps_cell(L.image_board(image),p,q,value,s1,apart)) :
      L.PointerWordValue(expect,_)
    known
  (safe,(L.board_set_keeps_perfect(L.image_board(image),p,value,7n,s0),preserved))

def L.write_pointer_word_other_image(expect,image,p,value,q,apart,state):
  (safe,(shape,known)) = state
  L.write_pointer_word_other_step(expect,image,p,value,q,safe,apart,
    L.copy_shape_proof(L.array_shape(L.image_board(image)),L.perfect_shape(7n),shape),known)

def L.write_pointer_word_other(expect,b,p,value,q,apart,state):
  proof : (L.RoutedApart(p,q) -> L.SafePointerWordAt(expect,b,q) ->
    L.SafePointerWordAt(expect,Board.set_cell(b,p,value),q)) =
    L.on_reified_board(b,x => (L.RoutedApart(p,q) -> L.SafePointerWordAt(expect,x,q) ->
      L.SafePointerWordAt(expect,Board.set_cell(x,p,value),q)),L.reify_board(b),
      image => L.write_pointer_word_other_image(expect,image,p,value,q))
  proof(apart,state)

def L.place_pointer_word_peers_image(expect,image,p,q,d,routes,state):
  (row,(col,box)) = routes
  L.box_four_keeps_pointer_word(expect,L.place_columns(L.image_board(image),p,d),L.place_box_base(p),L.place_box_r1(p),L.place_box_r2(p),L.place_box_c1(p),L.place_box_c2(p),q,d,box,
    L.column_pointer_word_line(expect,9n,0,M.rem9(p),p,q,d,L.place_rows(L.image_board(image),p,d),col,
      L.row_pointer_word_line(expect,9n,0,L.place_row_base(p),p,q,d,L.image_board(image),row,state)))

def L.place_peers_keep_pointer_word(expect,b,p,q,d):
  L.on_reified_board(b,x => L.PlacePeersPointerWord(expect,x,p,q,d),
    L.reify_board(b),image => L.place_pointer_word_peers_image(expect,image,p,q,d))

def L.place_keeps_pointer_word_image(expect,image,guess,p,q,d,apart,flag,routes,state):
  after_clear = Q.clear_forced(guess,L.image_board(image),p)
  after_write = Board.set_cell(Q.clear_forced(guess,L.image_board(image),p),p,L.fixed_word(d))
  L.place_peers_keep_pointer_word(expect,after_write,p,q,d)(routes,
    L.write_pointer_word_other(expect,after_clear,p,L.fixed_word(d),q,apart,
      L.clear_forced_pointer_word(expect,L.image_board(image),guess,p,q,flag,state)))

def L.queued_place_keeps_pointer_word(expect,b,guess,p,q,d):
  L.on_reified_board(b,x => L.PlaceKeepsPointerWord(expect,x,guess,p,q,d),
    L.reify_board(b),image => L.place_keeps_pointer_word_image(expect,image,guess,p,q,d))



def L.logical_target_routes_to_pointer(row,col):
  match row col:
    case L.Coordinate0{} L.Coordinate0{}:
      ({==},{==})
    case L.Coordinate0{} L.Coordinate1{}:
      ({==},{==})
    case L.Coordinate0{} L.Coordinate2{}:
      ({==},{==})
    case L.Coordinate0{} L.Coordinate3{}:
      ({==},{==})
    case L.Coordinate0{} L.Coordinate4{}:
      ({==},{==})
    case L.Coordinate0{} L.Coordinate5{}:
      ({==},{==})
    case L.Coordinate0{} L.Coordinate6{}:
      ({==},{==})
    case L.Coordinate0{} L.Coordinate7{}:
      ({==},{==})
    case L.Coordinate0{} L.Coordinate8{}:
      ({==},{==})
    case L.Coordinate1{} L.Coordinate0{}:
      ({==},{==})
    case L.Coordinate1{} L.Coordinate1{}:
      ({==},{==})
    case L.Coordinate1{} L.Coordinate2{}:
      ({==},{==})
    case L.Coordinate1{} L.Coordinate3{}:
      ({==},{==})
    case L.Coordinate1{} L.Coordinate4{}:
      ({==},{==})
    case L.Coordinate1{} L.Coordinate5{}:
      ({==},{==})
    case L.Coordinate1{} L.Coordinate6{}:
      ({==},{==})
    case L.Coordinate1{} L.Coordinate7{}:
      ({==},{==})
    case L.Coordinate1{} L.Coordinate8{}:
      ({==},{==})
    case L.Coordinate2{} L.Coordinate0{}:
      ({==},{==})
    case L.Coordinate2{} L.Coordinate1{}:
      ({==},{==})
    case L.Coordinate2{} L.Coordinate2{}:
      ({==},{==})
    case L.Coordinate2{} L.Coordinate3{}:
      ({==},{==})
    case L.Coordinate2{} L.Coordinate4{}:
      ({==},{==})
    case L.Coordinate2{} L.Coordinate5{}:
      ({==},{==})
    case L.Coordinate2{} L.Coordinate6{}:
      ({==},{==})
    case L.Coordinate2{} L.Coordinate7{}:
      ({==},{==})
    case L.Coordinate2{} L.Coordinate8{}:
      ({==},{==})
    case L.Coordinate3{} L.Coordinate0{}:
      ({==},{==})
    case L.Coordinate3{} L.Coordinate1{}:
      ({==},{==})
    case L.Coordinate3{} L.Coordinate2{}:
      ({==},{==})
    case L.Coordinate3{} L.Coordinate3{}:
      ({==},{==})
    case L.Coordinate3{} L.Coordinate4{}:
      ({==},{==})
    case L.Coordinate3{} L.Coordinate5{}:
      ({==},{==})
    case L.Coordinate3{} L.Coordinate6{}:
      ({==},{==})
    case L.Coordinate3{} L.Coordinate7{}:
      ({==},{==})
    case L.Coordinate3{} L.Coordinate8{}:
      ({==},{==})
    case L.Coordinate4{} L.Coordinate0{}:
      ({==},{==})
    case L.Coordinate4{} L.Coordinate1{}:
      ({==},{==})
    case L.Coordinate4{} L.Coordinate2{}:
      ({==},{==})
    case L.Coordinate4{} L.Coordinate3{}:
      ({==},{==})
    case L.Coordinate4{} L.Coordinate4{}:
      ({==},{==})
    case L.Coordinate4{} L.Coordinate5{}:
      ({==},{==})
    case L.Coordinate4{} L.Coordinate6{}:
      ({==},{==})
    case L.Coordinate4{} L.Coordinate7{}:
      ({==},{==})
    case L.Coordinate4{} L.Coordinate8{}:
      ({==},{==})
    case L.Coordinate5{} L.Coordinate0{}:
      ({==},{==})
    case L.Coordinate5{} L.Coordinate1{}:
      ({==},{==})
    case L.Coordinate5{} L.Coordinate2{}:
      ({==},{==})
    case L.Coordinate5{} L.Coordinate3{}:
      ({==},{==})
    case L.Coordinate5{} L.Coordinate4{}:
      ({==},{==})
    case L.Coordinate5{} L.Coordinate5{}:
      ({==},{==})
    case L.Coordinate5{} L.Coordinate6{}:
      ({==},{==})
    case L.Coordinate5{} L.Coordinate7{}:
      ({==},{==})
    case L.Coordinate5{} L.Coordinate8{}:
      ({==},{==})
    case L.Coordinate6{} L.Coordinate0{}:
      ({==},{==})
    case L.Coordinate6{} L.Coordinate1{}:
      ({==},{==})
    case L.Coordinate6{} L.Coordinate2{}:
      ({==},{==})
    case L.Coordinate6{} L.Coordinate3{}:
      ({==},{==})
    case L.Coordinate6{} L.Coordinate4{}:
      ({==},{==})
    case L.Coordinate6{} L.Coordinate5{}:
      ({==},{==})
    case L.Coordinate6{} L.Coordinate6{}:
      ({==},{==})
    case L.Coordinate6{} L.Coordinate7{}:
      ({==},{==})
    case L.Coordinate6{} L.Coordinate8{}:
      ({==},{==})
    case L.Coordinate7{} L.Coordinate0{}:
      ({==},{==})
    case L.Coordinate7{} L.Coordinate1{}:
      ({==},{==})
    case L.Coordinate7{} L.Coordinate2{}:
      ({==},{==})
    case L.Coordinate7{} L.Coordinate3{}:
      ({==},{==})
    case L.Coordinate7{} L.Coordinate4{}:
      ({==},{==})
    case L.Coordinate7{} L.Coordinate5{}:
      ({==},{==})
    case L.Coordinate7{} L.Coordinate6{}:
      ({==},{==})
    case L.Coordinate7{} L.Coordinate7{}:
      ({==},{==})
    case L.Coordinate7{} L.Coordinate8{}:
      ({==},{==})
    case L.Coordinate8{} L.Coordinate0{}:
      ({==},{==})
    case L.Coordinate8{} L.Coordinate1{}:
      ({==},{==})
    case L.Coordinate8{} L.Coordinate2{}:
      ({==},{==})
    case L.Coordinate8{} L.Coordinate3{}:
      ({==},{==})
    case L.Coordinate8{} L.Coordinate4{}:
      ({==},{==})
    case L.Coordinate8{} L.Coordinate5{}:
      ({==},{==})
    case L.Coordinate8{} L.Coordinate6{}:
      ({==},{==})
    case L.Coordinate8{} L.Coordinate7{}:
      ({==},{==})
    case L.Coordinate8{} L.Coordinate8{}:
      ({==},{==})

def L.row_routes_to_pointer(source):
  match source:
    case L.Coordinate0{}:
      (L.logical_target_routes_to_pointer(L.Coordinate0{},L.Coordinate0{}),
        (L.logical_target_routes_to_pointer(L.Coordinate0{},L.Coordinate1{}),
        (L.logical_target_routes_to_pointer(L.Coordinate0{},L.Coordinate2{}),
        (L.logical_target_routes_to_pointer(L.Coordinate0{},L.Coordinate3{}),
        (L.logical_target_routes_to_pointer(L.Coordinate0{},L.Coordinate4{}),
        (L.logical_target_routes_to_pointer(L.Coordinate0{},L.Coordinate5{}),
        (L.logical_target_routes_to_pointer(L.Coordinate0{},L.Coordinate6{}),
        (L.logical_target_routes_to_pointer(L.Coordinate0{},L.Coordinate7{}),
        (L.logical_target_routes_to_pointer(L.Coordinate0{},L.Coordinate8{}),
        {==})))))))))
    case L.Coordinate1{}:
      (L.logical_target_routes_to_pointer(L.Coordinate1{},L.Coordinate0{}),
        (L.logical_target_routes_to_pointer(L.Coordinate1{},L.Coordinate1{}),
        (L.logical_target_routes_to_pointer(L.Coordinate1{},L.Coordinate2{}),
        (L.logical_target_routes_to_pointer(L.Coordinate1{},L.Coordinate3{}),
        (L.logical_target_routes_to_pointer(L.Coordinate1{},L.Coordinate4{}),
        (L.logical_target_routes_to_pointer(L.Coordinate1{},L.Coordinate5{}),
        (L.logical_target_routes_to_pointer(L.Coordinate1{},L.Coordinate6{}),
        (L.logical_target_routes_to_pointer(L.Coordinate1{},L.Coordinate7{}),
        (L.logical_target_routes_to_pointer(L.Coordinate1{},L.Coordinate8{}),
        {==})))))))))
    case L.Coordinate2{}:
      (L.logical_target_routes_to_pointer(L.Coordinate2{},L.Coordinate0{}),
        (L.logical_target_routes_to_pointer(L.Coordinate2{},L.Coordinate1{}),
        (L.logical_target_routes_to_pointer(L.Coordinate2{},L.Coordinate2{}),
        (L.logical_target_routes_to_pointer(L.Coordinate2{},L.Coordinate3{}),
        (L.logical_target_routes_to_pointer(L.Coordinate2{},L.Coordinate4{}),
        (L.logical_target_routes_to_pointer(L.Coordinate2{},L.Coordinate5{}),
        (L.logical_target_routes_to_pointer(L.Coordinate2{},L.Coordinate6{}),
        (L.logical_target_routes_to_pointer(L.Coordinate2{},L.Coordinate7{}),
        (L.logical_target_routes_to_pointer(L.Coordinate2{},L.Coordinate8{}),
        {==})))))))))
    case L.Coordinate3{}:
      (L.logical_target_routes_to_pointer(L.Coordinate3{},L.Coordinate0{}),
        (L.logical_target_routes_to_pointer(L.Coordinate3{},L.Coordinate1{}),
        (L.logical_target_routes_to_pointer(L.Coordinate3{},L.Coordinate2{}),
        (L.logical_target_routes_to_pointer(L.Coordinate3{},L.Coordinate3{}),
        (L.logical_target_routes_to_pointer(L.Coordinate3{},L.Coordinate4{}),
        (L.logical_target_routes_to_pointer(L.Coordinate3{},L.Coordinate5{}),
        (L.logical_target_routes_to_pointer(L.Coordinate3{},L.Coordinate6{}),
        (L.logical_target_routes_to_pointer(L.Coordinate3{},L.Coordinate7{}),
        (L.logical_target_routes_to_pointer(L.Coordinate3{},L.Coordinate8{}),
        {==})))))))))
    case L.Coordinate4{}:
      (L.logical_target_routes_to_pointer(L.Coordinate4{},L.Coordinate0{}),
        (L.logical_target_routes_to_pointer(L.Coordinate4{},L.Coordinate1{}),
        (L.logical_target_routes_to_pointer(L.Coordinate4{},L.Coordinate2{}),
        (L.logical_target_routes_to_pointer(L.Coordinate4{},L.Coordinate3{}),
        (L.logical_target_routes_to_pointer(L.Coordinate4{},L.Coordinate4{}),
        (L.logical_target_routes_to_pointer(L.Coordinate4{},L.Coordinate5{}),
        (L.logical_target_routes_to_pointer(L.Coordinate4{},L.Coordinate6{}),
        (L.logical_target_routes_to_pointer(L.Coordinate4{},L.Coordinate7{}),
        (L.logical_target_routes_to_pointer(L.Coordinate4{},L.Coordinate8{}),
        {==})))))))))
    case L.Coordinate5{}:
      (L.logical_target_routes_to_pointer(L.Coordinate5{},L.Coordinate0{}),
        (L.logical_target_routes_to_pointer(L.Coordinate5{},L.Coordinate1{}),
        (L.logical_target_routes_to_pointer(L.Coordinate5{},L.Coordinate2{}),
        (L.logical_target_routes_to_pointer(L.Coordinate5{},L.Coordinate3{}),
        (L.logical_target_routes_to_pointer(L.Coordinate5{},L.Coordinate4{}),
        (L.logical_target_routes_to_pointer(L.Coordinate5{},L.Coordinate5{}),
        (L.logical_target_routes_to_pointer(L.Coordinate5{},L.Coordinate6{}),
        (L.logical_target_routes_to_pointer(L.Coordinate5{},L.Coordinate7{}),
        (L.logical_target_routes_to_pointer(L.Coordinate5{},L.Coordinate8{}),
        {==})))))))))
    case L.Coordinate6{}:
      (L.logical_target_routes_to_pointer(L.Coordinate6{},L.Coordinate0{}),
        (L.logical_target_routes_to_pointer(L.Coordinate6{},L.Coordinate1{}),
        (L.logical_target_routes_to_pointer(L.Coordinate6{},L.Coordinate2{}),
        (L.logical_target_routes_to_pointer(L.Coordinate6{},L.Coordinate3{}),
        (L.logical_target_routes_to_pointer(L.Coordinate6{},L.Coordinate4{}),
        (L.logical_target_routes_to_pointer(L.Coordinate6{},L.Coordinate5{}),
        (L.logical_target_routes_to_pointer(L.Coordinate6{},L.Coordinate6{}),
        (L.logical_target_routes_to_pointer(L.Coordinate6{},L.Coordinate7{}),
        (L.logical_target_routes_to_pointer(L.Coordinate6{},L.Coordinate8{}),
        {==})))))))))
    case L.Coordinate7{}:
      (L.logical_target_routes_to_pointer(L.Coordinate7{},L.Coordinate0{}),
        (L.logical_target_routes_to_pointer(L.Coordinate7{},L.Coordinate1{}),
        (L.logical_target_routes_to_pointer(L.Coordinate7{},L.Coordinate2{}),
        (L.logical_target_routes_to_pointer(L.Coordinate7{},L.Coordinate3{}),
        (L.logical_target_routes_to_pointer(L.Coordinate7{},L.Coordinate4{}),
        (L.logical_target_routes_to_pointer(L.Coordinate7{},L.Coordinate5{}),
        (L.logical_target_routes_to_pointer(L.Coordinate7{},L.Coordinate6{}),
        (L.logical_target_routes_to_pointer(L.Coordinate7{},L.Coordinate7{}),
        (L.logical_target_routes_to_pointer(L.Coordinate7{},L.Coordinate8{}),
        {==})))))))))
    case L.Coordinate8{}:
      (L.logical_target_routes_to_pointer(L.Coordinate8{},L.Coordinate0{}),
        (L.logical_target_routes_to_pointer(L.Coordinate8{},L.Coordinate1{}),
        (L.logical_target_routes_to_pointer(L.Coordinate8{},L.Coordinate2{}),
        (L.logical_target_routes_to_pointer(L.Coordinate8{},L.Coordinate3{}),
        (L.logical_target_routes_to_pointer(L.Coordinate8{},L.Coordinate4{}),
        (L.logical_target_routes_to_pointer(L.Coordinate8{},L.Coordinate5{}),
        (L.logical_target_routes_to_pointer(L.Coordinate8{},L.Coordinate6{}),
        (L.logical_target_routes_to_pointer(L.Coordinate8{},L.Coordinate7{}),
        (L.logical_target_routes_to_pointer(L.Coordinate8{},L.Coordinate8{}),
        {==})))))))))

def L.column_routes_to_pointer(source):
  match source:
    case L.Coordinate0{}:
      (L.logical_target_routes_to_pointer(L.Coordinate0{},L.Coordinate0{}),
        (L.logical_target_routes_to_pointer(L.Coordinate1{},L.Coordinate0{}),
        (L.logical_target_routes_to_pointer(L.Coordinate2{},L.Coordinate0{}),
        (L.logical_target_routes_to_pointer(L.Coordinate3{},L.Coordinate0{}),
        (L.logical_target_routes_to_pointer(L.Coordinate4{},L.Coordinate0{}),
        (L.logical_target_routes_to_pointer(L.Coordinate5{},L.Coordinate0{}),
        (L.logical_target_routes_to_pointer(L.Coordinate6{},L.Coordinate0{}),
        (L.logical_target_routes_to_pointer(L.Coordinate7{},L.Coordinate0{}),
        (L.logical_target_routes_to_pointer(L.Coordinate8{},L.Coordinate0{}),
        {==})))))))))
    case L.Coordinate1{}:
      (L.logical_target_routes_to_pointer(L.Coordinate0{},L.Coordinate1{}),
        (L.logical_target_routes_to_pointer(L.Coordinate1{},L.Coordinate1{}),
        (L.logical_target_routes_to_pointer(L.Coordinate2{},L.Coordinate1{}),
        (L.logical_target_routes_to_pointer(L.Coordinate3{},L.Coordinate1{}),
        (L.logical_target_routes_to_pointer(L.Coordinate4{},L.Coordinate1{}),
        (L.logical_target_routes_to_pointer(L.Coordinate5{},L.Coordinate1{}),
        (L.logical_target_routes_to_pointer(L.Coordinate6{},L.Coordinate1{}),
        (L.logical_target_routes_to_pointer(L.Coordinate7{},L.Coordinate1{}),
        (L.logical_target_routes_to_pointer(L.Coordinate8{},L.Coordinate1{}),
        {==})))))))))
    case L.Coordinate2{}:
      (L.logical_target_routes_to_pointer(L.Coordinate0{},L.Coordinate2{}),
        (L.logical_target_routes_to_pointer(L.Coordinate1{},L.Coordinate2{}),
        (L.logical_target_routes_to_pointer(L.Coordinate2{},L.Coordinate2{}),
        (L.logical_target_routes_to_pointer(L.Coordinate3{},L.Coordinate2{}),
        (L.logical_target_routes_to_pointer(L.Coordinate4{},L.Coordinate2{}),
        (L.logical_target_routes_to_pointer(L.Coordinate5{},L.Coordinate2{}),
        (L.logical_target_routes_to_pointer(L.Coordinate6{},L.Coordinate2{}),
        (L.logical_target_routes_to_pointer(L.Coordinate7{},L.Coordinate2{}),
        (L.logical_target_routes_to_pointer(L.Coordinate8{},L.Coordinate2{}),
        {==})))))))))
    case L.Coordinate3{}:
      (L.logical_target_routes_to_pointer(L.Coordinate0{},L.Coordinate3{}),
        (L.logical_target_routes_to_pointer(L.Coordinate1{},L.Coordinate3{}),
        (L.logical_target_routes_to_pointer(L.Coordinate2{},L.Coordinate3{}),
        (L.logical_target_routes_to_pointer(L.Coordinate3{},L.Coordinate3{}),
        (L.logical_target_routes_to_pointer(L.Coordinate4{},L.Coordinate3{}),
        (L.logical_target_routes_to_pointer(L.Coordinate5{},L.Coordinate3{}),
        (L.logical_target_routes_to_pointer(L.Coordinate6{},L.Coordinate3{}),
        (L.logical_target_routes_to_pointer(L.Coordinate7{},L.Coordinate3{}),
        (L.logical_target_routes_to_pointer(L.Coordinate8{},L.Coordinate3{}),
        {==})))))))))
    case L.Coordinate4{}:
      (L.logical_target_routes_to_pointer(L.Coordinate0{},L.Coordinate4{}),
        (L.logical_target_routes_to_pointer(L.Coordinate1{},L.Coordinate4{}),
        (L.logical_target_routes_to_pointer(L.Coordinate2{},L.Coordinate4{}),
        (L.logical_target_routes_to_pointer(L.Coordinate3{},L.Coordinate4{}),
        (L.logical_target_routes_to_pointer(L.Coordinate4{},L.Coordinate4{}),
        (L.logical_target_routes_to_pointer(L.Coordinate5{},L.Coordinate4{}),
        (L.logical_target_routes_to_pointer(L.Coordinate6{},L.Coordinate4{}),
        (L.logical_target_routes_to_pointer(L.Coordinate7{},L.Coordinate4{}),
        (L.logical_target_routes_to_pointer(L.Coordinate8{},L.Coordinate4{}),
        {==})))))))))
    case L.Coordinate5{}:
      (L.logical_target_routes_to_pointer(L.Coordinate0{},L.Coordinate5{}),
        (L.logical_target_routes_to_pointer(L.Coordinate1{},L.Coordinate5{}),
        (L.logical_target_routes_to_pointer(L.Coordinate2{},L.Coordinate5{}),
        (L.logical_target_routes_to_pointer(L.Coordinate3{},L.Coordinate5{}),
        (L.logical_target_routes_to_pointer(L.Coordinate4{},L.Coordinate5{}),
        (L.logical_target_routes_to_pointer(L.Coordinate5{},L.Coordinate5{}),
        (L.logical_target_routes_to_pointer(L.Coordinate6{},L.Coordinate5{}),
        (L.logical_target_routes_to_pointer(L.Coordinate7{},L.Coordinate5{}),
        (L.logical_target_routes_to_pointer(L.Coordinate8{},L.Coordinate5{}),
        {==})))))))))
    case L.Coordinate6{}:
      (L.logical_target_routes_to_pointer(L.Coordinate0{},L.Coordinate6{}),
        (L.logical_target_routes_to_pointer(L.Coordinate1{},L.Coordinate6{}),
        (L.logical_target_routes_to_pointer(L.Coordinate2{},L.Coordinate6{}),
        (L.logical_target_routes_to_pointer(L.Coordinate3{},L.Coordinate6{}),
        (L.logical_target_routes_to_pointer(L.Coordinate4{},L.Coordinate6{}),
        (L.logical_target_routes_to_pointer(L.Coordinate5{},L.Coordinate6{}),
        (L.logical_target_routes_to_pointer(L.Coordinate6{},L.Coordinate6{}),
        (L.logical_target_routes_to_pointer(L.Coordinate7{},L.Coordinate6{}),
        (L.logical_target_routes_to_pointer(L.Coordinate8{},L.Coordinate6{}),
        {==})))))))))
    case L.Coordinate7{}:
      (L.logical_target_routes_to_pointer(L.Coordinate0{},L.Coordinate7{}),
        (L.logical_target_routes_to_pointer(L.Coordinate1{},L.Coordinate7{}),
        (L.logical_target_routes_to_pointer(L.Coordinate2{},L.Coordinate7{}),
        (L.logical_target_routes_to_pointer(L.Coordinate3{},L.Coordinate7{}),
        (L.logical_target_routes_to_pointer(L.Coordinate4{},L.Coordinate7{}),
        (L.logical_target_routes_to_pointer(L.Coordinate5{},L.Coordinate7{}),
        (L.logical_target_routes_to_pointer(L.Coordinate6{},L.Coordinate7{}),
        (L.logical_target_routes_to_pointer(L.Coordinate7{},L.Coordinate7{}),
        (L.logical_target_routes_to_pointer(L.Coordinate8{},L.Coordinate7{}),
        {==})))))))))
    case L.Coordinate8{}:
      (L.logical_target_routes_to_pointer(L.Coordinate0{},L.Coordinate8{}),
        (L.logical_target_routes_to_pointer(L.Coordinate1{},L.Coordinate8{}),
        (L.logical_target_routes_to_pointer(L.Coordinate2{},L.Coordinate8{}),
        (L.logical_target_routes_to_pointer(L.Coordinate3{},L.Coordinate8{}),
        (L.logical_target_routes_to_pointer(L.Coordinate4{},L.Coordinate8{}),
        (L.logical_target_routes_to_pointer(L.Coordinate5{},L.Coordinate8{}),
        (L.logical_target_routes_to_pointer(L.Coordinate6{},L.Coordinate8{}),
        (L.logical_target_routes_to_pointer(L.Coordinate7{},L.Coordinate8{}),
        (L.logical_target_routes_to_pointer(L.Coordinate8{},L.Coordinate8{}),
        {==})))))))))

def L.box_routes_to_pointer(sr,sc):
  match sr sc:
    case L.Coordinate0{} L.Coordinate0{}:
      (L.logical_target_routes_to_pointer(L.Coordinate1{},L.Coordinate1{}),
        (L.logical_target_routes_to_pointer(L.Coordinate1{},L.Coordinate2{}),
        (L.logical_target_routes_to_pointer(L.Coordinate2{},L.Coordinate1{}),
        (L.logical_target_routes_to_pointer(L.Coordinate2{},L.Coordinate2{}),
        {==}))))
    case L.Coordinate0{} L.Coordinate1{}:
      (L.logical_target_routes_to_pointer(L.Coordinate1{},L.Coordinate2{}),
        (L.logical_target_routes_to_pointer(L.Coordinate1{},L.Coordinate0{}),
        (L.logical_target_routes_to_pointer(L.Coordinate2{},L.Coordinate2{}),
        (L.logical_target_routes_to_pointer(L.Coordinate2{},L.Coordinate0{}),
        {==}))))
    case L.Coordinate0{} L.Coordinate2{}:
      (L.logical_target_routes_to_pointer(L.Coordinate1{},L.Coordinate0{}),
        (L.logical_target_routes_to_pointer(L.Coordinate1{},L.Coordinate1{}),
        (L.logical_target_routes_to_pointer(L.Coordinate2{},L.Coordinate0{}),
        (L.logical_target_routes_to_pointer(L.Coordinate2{},L.Coordinate1{}),
        {==}))))
    case L.Coordinate0{} L.Coordinate3{}:
      (L.logical_target_routes_to_pointer(L.Coordinate1{},L.Coordinate4{}),
        (L.logical_target_routes_to_pointer(L.Coordinate1{},L.Coordinate5{}),
        (L.logical_target_routes_to_pointer(L.Coordinate2{},L.Coordinate4{}),
        (L.logical_target_routes_to_pointer(L.Coordinate2{},L.Coordinate5{}),
        {==}))))
    case L.Coordinate0{} L.Coordinate4{}:
      (L.logical_target_routes_to_pointer(L.Coordinate1{},L.Coordinate5{}),
        (L.logical_target_routes_to_pointer(L.Coordinate1{},L.Coordinate3{}),
        (L.logical_target_routes_to_pointer(L.Coordinate2{},L.Coordinate5{}),
        (L.logical_target_routes_to_pointer(L.Coordinate2{},L.Coordinate3{}),
        {==}))))
    case L.Coordinate0{} L.Coordinate5{}:
      (L.logical_target_routes_to_pointer(L.Coordinate1{},L.Coordinate3{}),
        (L.logical_target_routes_to_pointer(L.Coordinate1{},L.Coordinate4{}),
        (L.logical_target_routes_to_pointer(L.Coordinate2{},L.Coordinate3{}),
        (L.logical_target_routes_to_pointer(L.Coordinate2{},L.Coordinate4{}),
        {==}))))
    case L.Coordinate0{} L.Coordinate6{}:
      (L.logical_target_routes_to_pointer(L.Coordinate1{},L.Coordinate7{}),
        (L.logical_target_routes_to_pointer(L.Coordinate1{},L.Coordinate8{}),
        (L.logical_target_routes_to_pointer(L.Coordinate2{},L.Coordinate7{}),
        (L.logical_target_routes_to_pointer(L.Coordinate2{},L.Coordinate8{}),
        {==}))))
    case L.Coordinate0{} L.Coordinate7{}:
      (L.logical_target_routes_to_pointer(L.Coordinate1{},L.Coordinate8{}),
        (L.logical_target_routes_to_pointer(L.Coordinate1{},L.Coordinate6{}),
        (L.logical_target_routes_to_pointer(L.Coordinate2{},L.Coordinate8{}),
        (L.logical_target_routes_to_pointer(L.Coordinate2{},L.Coordinate6{}),
        {==}))))
    case L.Coordinate0{} L.Coordinate8{}:
      (L.logical_target_routes_to_pointer(L.Coordinate1{},L.Coordinate6{}),
        (L.logical_target_routes_to_pointer(L.Coordinate1{},L.Coordinate7{}),
        (L.logical_target_routes_to_pointer(L.Coordinate2{},L.Coordinate6{}),
        (L.logical_target_routes_to_pointer(L.Coordinate2{},L.Coordinate7{}),
        {==}))))
    case L.Coordinate1{} L.Coordinate0{}:
      (L.logical_target_routes_to_pointer(L.Coordinate2{},L.Coordinate1{}),
        (L.logical_target_routes_to_pointer(L.Coordinate2{},L.Coordinate2{}),
        (L.logical_target_routes_to_pointer(L.Coordinate0{},L.Coordinate1{}),
        (L.logical_target_routes_to_pointer(L.Coordinate0{},L.Coordinate2{}),
        {==}))))
    case L.Coordinate1{} L.Coordinate1{}:
      (L.logical_target_routes_to_pointer(L.Coordinate2{},L.Coordinate2{}),
        (L.logical_target_routes_to_pointer(L.Coordinate2{},L.Coordinate0{}),
        (L.logical_target_routes_to_pointer(L.Coordinate0{},L.Coordinate2{}),
        (L.logical_target_routes_to_pointer(L.Coordinate0{},L.Coordinate0{}),
        {==}))))
    case L.Coordinate1{} L.Coordinate2{}:
      (L.logical_target_routes_to_pointer(L.Coordinate2{},L.Coordinate0{}),
        (L.logical_target_routes_to_pointer(L.Coordinate2{},L.Coordinate1{}),
        (L.logical_target_routes_to_pointer(L.Coordinate0{},L.Coordinate0{}),
        (L.logical_target_routes_to_pointer(L.Coordinate0{},L.Coordinate1{}),
        {==}))))
    case L.Coordinate1{} L.Coordinate3{}:
      (L.logical_target_routes_to_pointer(L.Coordinate2{},L.Coordinate4{}),
        (L.logical_target_routes_to_pointer(L.Coordinate2{},L.Coordinate5{}),
        (L.logical_target_routes_to_pointer(L.Coordinate0{},L.Coordinate4{}),
        (L.logical_target_routes_to_pointer(L.Coordinate0{},L.Coordinate5{}),
        {==}))))
    case L.Coordinate1{} L.Coordinate4{}:
      (L.logical_target_routes_to_pointer(L.Coordinate2{},L.Coordinate5{}),
        (L.logical_target_routes_to_pointer(L.Coordinate2{},L.Coordinate3{}),
        (L.logical_target_routes_to_pointer(L.Coordinate0{},L.Coordinate5{}),
        (L.logical_target_routes_to_pointer(L.Coordinate0{},L.Coordinate3{}),
        {==}))))
    case L.Coordinate1{} L.Coordinate5{}:
      (L.logical_target_routes_to_pointer(L.Coordinate2{},L.Coordinate3{}),
        (L.logical_target_routes_to_pointer(L.Coordinate2{},L.Coordinate4{}),
        (L.logical_target_routes_to_pointer(L.Coordinate0{},L.Coordinate3{}),
        (L.logical_target_routes_to_pointer(L.Coordinate0{},L.Coordinate4{}),
        {==}))))
    case L.Coordinate1{} L.Coordinate6{}:
      (L.logical_target_routes_to_pointer(L.Coordinate2{},L.Coordinate7{}),
        (L.logical_target_routes_to_pointer(L.Coordinate2{},L.Coordinate8{}),
        (L.logical_target_routes_to_pointer(L.Coordinate0{},L.Coordinate7{}),
        (L.logical_target_routes_to_pointer(L.Coordinate0{},L.Coordinate8{}),
        {==}))))
    case L.Coordinate1{} L.Coordinate7{}:
      (L.logical_target_routes_to_pointer(L.Coordinate2{},L.Coordinate8{}),
        (L.logical_target_routes_to_pointer(L.Coordinate2{},L.Coordinate6{}),
        (L.logical_target_routes_to_pointer(L.Coordinate0{},L.Coordinate8{}),
        (L.logical_target_routes_to_pointer(L.Coordinate0{},L.Coordinate6{}),
        {==}))))
    case L.Coordinate1{} L.Coordinate8{}:
      (L.logical_target_routes_to_pointer(L.Coordinate2{},L.Coordinate6{}),
        (L.logical_target_routes_to_pointer(L.Coordinate2{},L.Coordinate7{}),
        (L.logical_target_routes_to_pointer(L.Coordinate0{},L.Coordinate6{}),
        (L.logical_target_routes_to_pointer(L.Coordinate0{},L.Coordinate7{}),
        {==}))))
    case L.Coordinate2{} L.Coordinate0{}:
      (L.logical_target_routes_to_pointer(L.Coordinate0{},L.Coordinate1{}),
        (L.logical_target_routes_to_pointer(L.Coordinate0{},L.Coordinate2{}),
        (L.logical_target_routes_to_pointer(L.Coordinate1{},L.Coordinate1{}),
        (L.logical_target_routes_to_pointer(L.Coordinate1{},L.Coordinate2{}),
        {==}))))
    case L.Coordinate2{} L.Coordinate1{}:
      (L.logical_target_routes_to_pointer(L.Coordinate0{},L.Coordinate2{}),
        (L.logical_target_routes_to_pointer(L.Coordinate0{},L.Coordinate0{}),
        (L.logical_target_routes_to_pointer(L.Coordinate1{},L.Coordinate2{}),
        (L.logical_target_routes_to_pointer(L.Coordinate1{},L.Coordinate0{}),
        {==}))))
    case L.Coordinate2{} L.Coordinate2{}:
      (L.logical_target_routes_to_pointer(L.Coordinate0{},L.Coordinate0{}),
        (L.logical_target_routes_to_pointer(L.Coordinate0{},L.Coordinate1{}),
        (L.logical_target_routes_to_pointer(L.Coordinate1{},L.Coordinate0{}),
        (L.logical_target_routes_to_pointer(L.Coordinate1{},L.Coordinate1{}),
        {==}))))
    case L.Coordinate2{} L.Coordinate3{}:
      (L.logical_target_routes_to_pointer(L.Coordinate0{},L.Coordinate4{}),
        (L.logical_target_routes_to_pointer(L.Coordinate0{},L.Coordinate5{}),
        (L.logical_target_routes_to_pointer(L.Coordinate1{},L.Coordinate4{}),
        (L.logical_target_routes_to_pointer(L.Coordinate1{},L.Coordinate5{}),
        {==}))))
    case L.Coordinate2{} L.Coordinate4{}:
      (L.logical_target_routes_to_pointer(L.Coordinate0{},L.Coordinate5{}),
        (L.logical_target_routes_to_pointer(L.Coordinate0{},L.Coordinate3{}),
        (L.logical_target_routes_to_pointer(L.Coordinate1{},L.Coordinate5{}),
        (L.logical_target_routes_to_pointer(L.Coordinate1{},L.Coordinate3{}),
        {==}))))
    case L.Coordinate2{} L.Coordinate5{}:
      (L.logical_target_routes_to_pointer(L.Coordinate0{},L.Coordinate3{}),
        (L.logical_target_routes_to_pointer(L.Coordinate0{},L.Coordinate4{}),
        (L.logical_target_routes_to_pointer(L.Coordinate1{},L.Coordinate3{}),
        (L.logical_target_routes_to_pointer(L.Coordinate1{},L.Coordinate4{}),
        {==}))))
    case L.Coordinate2{} L.Coordinate6{}:
      (L.logical_target_routes_to_pointer(L.Coordinate0{},L.Coordinate7{}),
        (L.logical_target_routes_to_pointer(L.Coordinate0{},L.Coordinate8{}),
        (L.logical_target_routes_to_pointer(L.Coordinate1{},L.Coordinate7{}),
        (L.logical_target_routes_to_pointer(L.Coordinate1{},L.Coordinate8{}),
        {==}))))
    case L.Coordinate2{} L.Coordinate7{}:
      (L.logical_target_routes_to_pointer(L.Coordinate0{},L.Coordinate8{}),
        (L.logical_target_routes_to_pointer(L.Coordinate0{},L.Coordinate6{}),
        (L.logical_target_routes_to_pointer(L.Coordinate1{},L.Coordinate8{}),
        (L.logical_target_routes_to_pointer(L.Coordinate1{},L.Coordinate6{}),
        {==}))))
    case L.Coordinate2{} L.Coordinate8{}:
      (L.logical_target_routes_to_pointer(L.Coordinate0{},L.Coordinate6{}),
        (L.logical_target_routes_to_pointer(L.Coordinate0{},L.Coordinate7{}),
        (L.logical_target_routes_to_pointer(L.Coordinate1{},L.Coordinate6{}),
        (L.logical_target_routes_to_pointer(L.Coordinate1{},L.Coordinate7{}),
        {==}))))
    case L.Coordinate3{} L.Coordinate0{}:
      (L.logical_target_routes_to_pointer(L.Coordinate4{},L.Coordinate1{}),
        (L.logical_target_routes_to_pointer(L.Coordinate4{},L.Coordinate2{}),
        (L.logical_target_routes_to_pointer(L.Coordinate5{},L.Coordinate1{}),
        (L.logical_target_routes_to_pointer(L.Coordinate5{},L.Coordinate2{}),
        {==}))))
    case L.Coordinate3{} L.Coordinate1{}:
      (L.logical_target_routes_to_pointer(L.Coordinate4{},L.Coordinate2{}),
        (L.logical_target_routes_to_pointer(L.Coordinate4{},L.Coordinate0{}),
        (L.logical_target_routes_to_pointer(L.Coordinate5{},L.Coordinate2{}),
        (L.logical_target_routes_to_pointer(L.Coordinate5{},L.Coordinate0{}),
        {==}))))
    case L.Coordinate3{} L.Coordinate2{}:
      (L.logical_target_routes_to_pointer(L.Coordinate4{},L.Coordinate0{}),
        (L.logical_target_routes_to_pointer(L.Coordinate4{},L.Coordinate1{}),
        (L.logical_target_routes_to_pointer(L.Coordinate5{},L.Coordinate0{}),
        (L.logical_target_routes_to_pointer(L.Coordinate5{},L.Coordinate1{}),
        {==}))))
    case L.Coordinate3{} L.Coordinate3{}:
      (L.logical_target_routes_to_pointer(L.Coordinate4{},L.Coordinate4{}),
        (L.logical_target_routes_to_pointer(L.Coordinate4{},L.Coordinate5{}),
        (L.logical_target_routes_to_pointer(L.Coordinate5{},L.Coordinate4{}),
        (L.logical_target_routes_to_pointer(L.Coordinate5{},L.Coordinate5{}),
        {==}))))
    case L.Coordinate3{} L.Coordinate4{}:
      (L.logical_target_routes_to_pointer(L.Coordinate4{},L.Coordinate5{}),
        (L.logical_target_routes_to_pointer(L.Coordinate4{},L.Coordinate3{}),
        (L.logical_target_routes_to_pointer(L.Coordinate5{},L.Coordinate5{}),
        (L.logical_target_routes_to_pointer(L.Coordinate5{},L.Coordinate3{}),
        {==}))))
    case L.Coordinate3{} L.Coordinate5{}:
      (L.logical_target_routes_to_pointer(L.Coordinate4{},L.Coordinate3{}),
        (L.logical_target_routes_to_pointer(L.Coordinate4{},L.Coordinate4{}),
        (L.logical_target_routes_to_pointer(L.Coordinate5{},L.Coordinate3{}),
        (L.logical_target_routes_to_pointer(L.Coordinate5{},L.Coordinate4{}),
        {==}))))
    case L.Coordinate3{} L.Coordinate6{}:
      (L.logical_target_routes_to_pointer(L.Coordinate4{},L.Coordinate7{}),
        (L.logical_target_routes_to_pointer(L.Coordinate4{},L.Coordinate8{}),
        (L.logical_target_routes_to_pointer(L.Coordinate5{},L.Coordinate7{}),
        (L.logical_target_routes_to_pointer(L.Coordinate5{},L.Coordinate8{}),
        {==}))))
    case L.Coordinate3{} L.Coordinate7{}:
      (L.logical_target_routes_to_pointer(L.Coordinate4{},L.Coordinate8{}),
        (L.logical_target_routes_to_pointer(L.Coordinate4{},L.Coordinate6{}),
        (L.logical_target_routes_to_pointer(L.Coordinate5{},L.Coordinate8{}),
        (L.logical_target_routes_to_pointer(L.Coordinate5{},L.Coordinate6{}),
        {==}))))
    case L.Coordinate3{} L.Coordinate8{}:
      (L.logical_target_routes_to_pointer(L.Coordinate4{},L.Coordinate6{}),
        (L.logical_target_routes_to_pointer(L.Coordinate4{},L.Coordinate7{}),
        (L.logical_target_routes_to_pointer(L.Coordinate5{},L.Coordinate6{}),
        (L.logical_target_routes_to_pointer(L.Coordinate5{},L.Coordinate7{}),
        {==}))))
    case L.Coordinate4{} L.Coordinate0{}:
      (L.logical_target_routes_to_pointer(L.Coordinate5{},L.Coordinate1{}),
        (L.logical_target_routes_to_pointer(L.Coordinate5{},L.Coordinate2{}),
        (L.logical_target_routes_to_pointer(L.Coordinate3{},L.Coordinate1{}),
        (L.logical_target_routes_to_pointer(L.Coordinate3{},L.Coordinate2{}),
        {==}))))
    case L.Coordinate4{} L.Coordinate1{}:
      (L.logical_target_routes_to_pointer(L.Coordinate5{},L.Coordinate2{}),
        (L.logical_target_routes_to_pointer(L.Coordinate5{},L.Coordinate0{}),
        (L.logical_target_routes_to_pointer(L.Coordinate3{},L.Coordinate2{}),
        (L.logical_target_routes_to_pointer(L.Coordinate3{},L.Coordinate0{}),
        {==}))))
    case L.Coordinate4{} L.Coordinate2{}:
      (L.logical_target_routes_to_pointer(L.Coordinate5{},L.Coordinate0{}),
        (L.logical_target_routes_to_pointer(L.Coordinate5{},L.Coordinate1{}),
        (L.logical_target_routes_to_pointer(L.Coordinate3{},L.Coordinate0{}),
        (L.logical_target_routes_to_pointer(L.Coordinate3{},L.Coordinate1{}),
        {==}))))
    case L.Coordinate4{} L.Coordinate3{}:
      (L.logical_target_routes_to_pointer(L.Coordinate5{},L.Coordinate4{}),
        (L.logical_target_routes_to_pointer(L.Coordinate5{},L.Coordinate5{}),
        (L.logical_target_routes_to_pointer(L.Coordinate3{},L.Coordinate4{}),
        (L.logical_target_routes_to_pointer(L.Coordinate3{},L.Coordinate5{}),
        {==}))))
    case L.Coordinate4{} L.Coordinate4{}:
      (L.logical_target_routes_to_pointer(L.Coordinate5{},L.Coordinate5{}),
        (L.logical_target_routes_to_pointer(L.Coordinate5{},L.Coordinate3{}),
        (L.logical_target_routes_to_pointer(L.Coordinate3{},L.Coordinate5{}),
        (L.logical_target_routes_to_pointer(L.Coordinate3{},L.Coordinate3{}),
        {==}))))
    case L.Coordinate4{} L.Coordinate5{}:
      (L.logical_target_routes_to_pointer(L.Coordinate5{},L.Coordinate3{}),
        (L.logical_target_routes_to_pointer(L.Coordinate5{},L.Coordinate4{}),
        (L.logical_target_routes_to_pointer(L.Coordinate3{},L.Coordinate3{}),
        (L.logical_target_routes_to_pointer(L.Coordinate3{},L.Coordinate4{}),
        {==}))))
    case L.Coordinate4{} L.Coordinate6{}:
      (L.logical_target_routes_to_pointer(L.Coordinate5{},L.Coordinate7{}),
        (L.logical_target_routes_to_pointer(L.Coordinate5{},L.Coordinate8{}),
        (L.logical_target_routes_to_pointer(L.Coordinate3{},L.Coordinate7{}),
        (L.logical_target_routes_to_pointer(L.Coordinate3{},L.Coordinate8{}),
        {==}))))
    case L.Coordinate4{} L.Coordinate7{}:
      (L.logical_target_routes_to_pointer(L.Coordinate5{},L.Coordinate8{}),
        (L.logical_target_routes_to_pointer(L.Coordinate5{},L.Coordinate6{}),
        (L.logical_target_routes_to_pointer(L.Coordinate3{},L.Coordinate8{}),
        (L.logical_target_routes_to_pointer(L.Coordinate3{},L.Coordinate6{}),
        {==}))))
    case L.Coordinate4{} L.Coordinate8{}:
      (L.logical_target_routes_to_pointer(L.Coordinate5{},L.Coordinate6{}),
        (L.logical_target_routes_to_pointer(L.Coordinate5{},L.Coordinate7{}),
        (L.logical_target_routes_to_pointer(L.Coordinate3{},L.Coordinate6{}),
        (L.logical_target_routes_to_pointer(L.Coordinate3{},L.Coordinate7{}),
        {==}))))
    case L.Coordinate5{} L.Coordinate0{}:
      (L.logical_target_routes_to_pointer(L.Coordinate3{},L.Coordinate1{}),
        (L.logical_target_routes_to_pointer(L.Coordinate3{},L.Coordinate2{}),
        (L.logical_target_routes_to_pointer(L.Coordinate4{},L.Coordinate1{}),
        (L.logical_target_routes_to_pointer(L.Coordinate4{},L.Coordinate2{}),
        {==}))))
    case L.Coordinate5{} L.Coordinate1{}:
      (L.logical_target_routes_to_pointer(L.Coordinate3{},L.Coordinate2{}),
        (L.logical_target_routes_to_pointer(L.Coordinate3{},L.Coordinate0{}),
        (L.logical_target_routes_to_pointer(L.Coordinate4{},L.Coordinate2{}),
        (L.logical_target_routes_to_pointer(L.Coordinate4{},L.Coordinate0{}),
        {==}))))
    case L.Coordinate5{} L.Coordinate2{}:
      (L.logical_target_routes_to_pointer(L.Coordinate3{},L.Coordinate0{}),
        (L.logical_target_routes_to_pointer(L.Coordinate3{},L.Coordinate1{}),
        (L.logical_target_routes_to_pointer(L.Coordinate4{},L.Coordinate0{}),
        (L.logical_target_routes_to_pointer(L.Coordinate4{},L.Coordinate1{}),
        {==}))))
    case L.Coordinate5{} L.Coordinate3{}:
      (L.logical_target_routes_to_pointer(L.Coordinate3{},L.Coordinate4{}),
        (L.logical_target_routes_to_pointer(L.Coordinate3{},L.Coordinate5{}),
        (L.logical_target_routes_to_pointer(L.Coordinate4{},L.Coordinate4{}),
        (L.logical_target_routes_to_pointer(L.Coordinate4{},L.Coordinate5{}),
        {==}))))
    case L.Coordinate5{} L.Coordinate4{}:
      (L.logical_target_routes_to_pointer(L.Coordinate3{},L.Coordinate5{}),
        (L.logical_target_routes_to_pointer(L.Coordinate3{},L.Coordinate3{}),
        (L.logical_target_routes_to_pointer(L.Coordinate4{},L.Coordinate5{}),
        (L.logical_target_routes_to_pointer(L.Coordinate4{},L.Coordinate3{}),
        {==}))))
    case L.Coordinate5{} L.Coordinate5{}:
      (L.logical_target_routes_to_pointer(L.Coordinate3{},L.Coordinate3{}),
        (L.logical_target_routes_to_pointer(L.Coordinate3{},L.Coordinate4{}),
        (L.logical_target_routes_to_pointer(L.Coordinate4{},L.Coordinate3{}),
        (L.logical_target_routes_to_pointer(L.Coordinate4{},L.Coordinate4{}),
        {==}))))
    case L.Coordinate5{} L.Coordinate6{}:
      (L.logical_target_routes_to_pointer(L.Coordinate3{},L.Coordinate7{}),
        (L.logical_target_routes_to_pointer(L.Coordinate3{},L.Coordinate8{}),
        (L.logical_target_routes_to_pointer(L.Coordinate4{},L.Coordinate7{}),
        (L.logical_target_routes_to_pointer(L.Coordinate4{},L.Coordinate8{}),
        {==}))))
    case L.Coordinate5{} L.Coordinate7{}:
      (L.logical_target_routes_to_pointer(L.Coordinate3{},L.Coordinate8{}),
        (L.logical_target_routes_to_pointer(L.Coordinate3{},L.Coordinate6{}),
        (L.logical_target_routes_to_pointer(L.Coordinate4{},L.Coordinate8{}),
        (L.logical_target_routes_to_pointer(L.Coordinate4{},L.Coordinate6{}),
        {==}))))
    case L.Coordinate5{} L.Coordinate8{}:
      (L.logical_target_routes_to_pointer(L.Coordinate3{},L.Coordinate6{}),
        (L.logical_target_routes_to_pointer(L.Coordinate3{},L.Coordinate7{}),
        (L.logical_target_routes_to_pointer(L.Coordinate4{},L.Coordinate6{}),
        (L.logical_target_routes_to_pointer(L.Coordinate4{},L.Coordinate7{}),
        {==}))))
    case L.Coordinate6{} L.Coordinate0{}:
      (L.logical_target_routes_to_pointer(L.Coordinate7{},L.Coordinate1{}),
        (L.logical_target_routes_to_pointer(L.Coordinate7{},L.Coordinate2{}),
        (L.logical_target_routes_to_pointer(L.Coordinate8{},L.Coordinate1{}),
        (L.logical_target_routes_to_pointer(L.Coordinate8{},L.Coordinate2{}),
        {==}))))
    case L.Coordinate6{} L.Coordinate1{}:
      (L.logical_target_routes_to_pointer(L.Coordinate7{},L.Coordinate2{}),
        (L.logical_target_routes_to_pointer(L.Coordinate7{},L.Coordinate0{}),
        (L.logical_target_routes_to_pointer(L.Coordinate8{},L.Coordinate2{}),
        (L.logical_target_routes_to_pointer(L.Coordinate8{},L.Coordinate0{}),
        {==}))))
    case L.Coordinate6{} L.Coordinate2{}:
      (L.logical_target_routes_to_pointer(L.Coordinate7{},L.Coordinate0{}),
        (L.logical_target_routes_to_pointer(L.Coordinate7{},L.Coordinate1{}),
        (L.logical_target_routes_to_pointer(L.Coordinate8{},L.Coordinate0{}),
        (L.logical_target_routes_to_pointer(L.Coordinate8{},L.Coordinate1{}),
        {==}))))
    case L.Coordinate6{} L.Coordinate3{}:
      (L.logical_target_routes_to_pointer(L.Coordinate7{},L.Coordinate4{}),
        (L.logical_target_routes_to_pointer(L.Coordinate7{},L.Coordinate5{}),
        (L.logical_target_routes_to_pointer(L.Coordinate8{},L.Coordinate4{}),
        (L.logical_target_routes_to_pointer(L.Coordinate8{},L.Coordinate5{}),
        {==}))))
    case L.Coordinate6{} L.Coordinate4{}:
      (L.logical_target_routes_to_pointer(L.Coordinate7{},L.Coordinate5{}),
        (L.logical_target_routes_to_pointer(L.Coordinate7{},L.Coordinate3{}),
        (L.logical_target_routes_to_pointer(L.Coordinate8{},L.Coordinate5{}),
        (L.logical_target_routes_to_pointer(L.Coordinate8{},L.Coordinate3{}),
        {==}))))
    case L.Coordinate6{} L.Coordinate5{}:
      (L.logical_target_routes_to_pointer(L.Coordinate7{},L.Coordinate3{}),
        (L.logical_target_routes_to_pointer(L.Coordinate7{},L.Coordinate4{}),
        (L.logical_target_routes_to_pointer(L.Coordinate8{},L.Coordinate3{}),
        (L.logical_target_routes_to_pointer(L.Coordinate8{},L.Coordinate4{}),
        {==}))))
    case L.Coordinate6{} L.Coordinate6{}:
      (L.logical_target_routes_to_pointer(L.Coordinate7{},L.Coordinate7{}),
        (L.logical_target_routes_to_pointer(L.Coordinate7{},L.Coordinate8{}),
        (L.logical_target_routes_to_pointer(L.Coordinate8{},L.Coordinate7{}),
        (L.logical_target_routes_to_pointer(L.Coordinate8{},L.Coordinate8{}),
        {==}))))
    case L.Coordinate6{} L.Coordinate7{}:
      (L.logical_target_routes_to_pointer(L.Coordinate7{},L.Coordinate8{}),
        (L.logical_target_routes_to_pointer(L.Coordinate7{},L.Coordinate6{}),
        (L.logical_target_routes_to_pointer(L.Coordinate8{},L.Coordinate8{}),
        (L.logical_target_routes_to_pointer(L.Coordinate8{},L.Coordinate6{}),
        {==}))))
    case L.Coordinate6{} L.Coordinate8{}:
      (L.logical_target_routes_to_pointer(L.Coordinate7{},L.Coordinate6{}),
        (L.logical_target_routes_to_pointer(L.Coordinate7{},L.Coordinate7{}),
        (L.logical_target_routes_to_pointer(L.Coordinate8{},L.Coordinate6{}),
        (L.logical_target_routes_to_pointer(L.Coordinate8{},L.Coordinate7{}),
        {==}))))
    case L.Coordinate7{} L.Coordinate0{}:
      (L.logical_target_routes_to_pointer(L.Coordinate8{},L.Coordinate1{}),
        (L.logical_target_routes_to_pointer(L.Coordinate8{},L.Coordinate2{}),
        (L.logical_target_routes_to_pointer(L.Coordinate6{},L.Coordinate1{}),
        (L.logical_target_routes_to_pointer(L.Coordinate6{},L.Coordinate2{}),
        {==}))))
    case L.Coordinate7{} L.Coordinate1{}:
      (L.logical_target_routes_to_pointer(L.Coordinate8{},L.Coordinate2{}),
        (L.logical_target_routes_to_pointer(L.Coordinate8{},L.Coordinate0{}),
        (L.logical_target_routes_to_pointer(L.Coordinate6{},L.Coordinate2{}),
        (L.logical_target_routes_to_pointer(L.Coordinate6{},L.Coordinate0{}),
        {==}))))
    case L.Coordinate7{} L.Coordinate2{}:
      (L.logical_target_routes_to_pointer(L.Coordinate8{},L.Coordinate0{}),
        (L.logical_target_routes_to_pointer(L.Coordinate8{},L.Coordinate1{}),
        (L.logical_target_routes_to_pointer(L.Coordinate6{},L.Coordinate0{}),
        (L.logical_target_routes_to_pointer(L.Coordinate6{},L.Coordinate1{}),
        {==}))))
    case L.Coordinate7{} L.Coordinate3{}:
      (L.logical_target_routes_to_pointer(L.Coordinate8{},L.Coordinate4{}),
        (L.logical_target_routes_to_pointer(L.Coordinate8{},L.Coordinate5{}),
        (L.logical_target_routes_to_pointer(L.Coordinate6{},L.Coordinate4{}),
        (L.logical_target_routes_to_pointer(L.Coordinate6{},L.Coordinate5{}),
        {==}))))
    case L.Coordinate7{} L.Coordinate4{}:
      (L.logical_target_routes_to_pointer(L.Coordinate8{},L.Coordinate5{}),
        (L.logical_target_routes_to_pointer(L.Coordinate8{},L.Coordinate3{}),
        (L.logical_target_routes_to_pointer(L.Coordinate6{},L.Coordinate5{}),
        (L.logical_target_routes_to_pointer(L.Coordinate6{},L.Coordinate3{}),
        {==}))))
    case L.Coordinate7{} L.Coordinate5{}:
      (L.logical_target_routes_to_pointer(L.Coordinate8{},L.Coordinate3{}),
        (L.logical_target_routes_to_pointer(L.Coordinate8{},L.Coordinate4{}),
        (L.logical_target_routes_to_pointer(L.Coordinate6{},L.Coordinate3{}),
        (L.logical_target_routes_to_pointer(L.Coordinate6{},L.Coordinate4{}),
        {==}))))
    case L.Coordinate7{} L.Coordinate6{}:
      (L.logical_target_routes_to_pointer(L.Coordinate8{},L.Coordinate7{}),
        (L.logical_target_routes_to_pointer(L.Coordinate8{},L.Coordinate8{}),
        (L.logical_target_routes_to_pointer(L.Coordinate6{},L.Coordinate7{}),
        (L.logical_target_routes_to_pointer(L.Coordinate6{},L.Coordinate8{}),
        {==}))))
    case L.Coordinate7{} L.Coordinate7{}:
      (L.logical_target_routes_to_pointer(L.Coordinate8{},L.Coordinate8{}),
        (L.logical_target_routes_to_pointer(L.Coordinate8{},L.Coordinate6{}),
        (L.logical_target_routes_to_pointer(L.Coordinate6{},L.Coordinate8{}),
        (L.logical_target_routes_to_pointer(L.Coordinate6{},L.Coordinate6{}),
        {==}))))
    case L.Coordinate7{} L.Coordinate8{}:
      (L.logical_target_routes_to_pointer(L.Coordinate8{},L.Coordinate6{}),
        (L.logical_target_routes_to_pointer(L.Coordinate8{},L.Coordinate7{}),
        (L.logical_target_routes_to_pointer(L.Coordinate6{},L.Coordinate6{}),
        (L.logical_target_routes_to_pointer(L.Coordinate6{},L.Coordinate7{}),
        {==}))))
    case L.Coordinate8{} L.Coordinate0{}:
      (L.logical_target_routes_to_pointer(L.Coordinate6{},L.Coordinate1{}),
        (L.logical_target_routes_to_pointer(L.Coordinate6{},L.Coordinate2{}),
        (L.logical_target_routes_to_pointer(L.Coordinate7{},L.Coordinate1{}),
        (L.logical_target_routes_to_pointer(L.Coordinate7{},L.Coordinate2{}),
        {==}))))
    case L.Coordinate8{} L.Coordinate1{}:
      (L.logical_target_routes_to_pointer(L.Coordinate6{},L.Coordinate2{}),
        (L.logical_target_routes_to_pointer(L.Coordinate6{},L.Coordinate0{}),
        (L.logical_target_routes_to_pointer(L.Coordinate7{},L.Coordinate2{}),
        (L.logical_target_routes_to_pointer(L.Coordinate7{},L.Coordinate0{}),
        {==}))))
    case L.Coordinate8{} L.Coordinate2{}:
      (L.logical_target_routes_to_pointer(L.Coordinate6{},L.Coordinate0{}),
        (L.logical_target_routes_to_pointer(L.Coordinate6{},L.Coordinate1{}),
        (L.logical_target_routes_to_pointer(L.Coordinate7{},L.Coordinate0{}),
        (L.logical_target_routes_to_pointer(L.Coordinate7{},L.Coordinate1{}),
        {==}))))
    case L.Coordinate8{} L.Coordinate3{}:
      (L.logical_target_routes_to_pointer(L.Coordinate6{},L.Coordinate4{}),
        (L.logical_target_routes_to_pointer(L.Coordinate6{},L.Coordinate5{}),
        (L.logical_target_routes_to_pointer(L.Coordinate7{},L.Coordinate4{}),
        (L.logical_target_routes_to_pointer(L.Coordinate7{},L.Coordinate5{}),
        {==}))))
    case L.Coordinate8{} L.Coordinate4{}:
      (L.logical_target_routes_to_pointer(L.Coordinate6{},L.Coordinate5{}),
        (L.logical_target_routes_to_pointer(L.Coordinate6{},L.Coordinate3{}),
        (L.logical_target_routes_to_pointer(L.Coordinate7{},L.Coordinate5{}),
        (L.logical_target_routes_to_pointer(L.Coordinate7{},L.Coordinate3{}),
        {==}))))
    case L.Coordinate8{} L.Coordinate5{}:
      (L.logical_target_routes_to_pointer(L.Coordinate6{},L.Coordinate3{}),
        (L.logical_target_routes_to_pointer(L.Coordinate6{},L.Coordinate4{}),
        (L.logical_target_routes_to_pointer(L.Coordinate7{},L.Coordinate3{}),
        (L.logical_target_routes_to_pointer(L.Coordinate7{},L.Coordinate4{}),
        {==}))))
    case L.Coordinate8{} L.Coordinate6{}:
      (L.logical_target_routes_to_pointer(L.Coordinate6{},L.Coordinate7{}),
        (L.logical_target_routes_to_pointer(L.Coordinate6{},L.Coordinate8{}),
        (L.logical_target_routes_to_pointer(L.Coordinate7{},L.Coordinate7{}),
        (L.logical_target_routes_to_pointer(L.Coordinate7{},L.Coordinate8{}),
        {==}))))
    case L.Coordinate8{} L.Coordinate7{}:
      (L.logical_target_routes_to_pointer(L.Coordinate6{},L.Coordinate8{}),
        (L.logical_target_routes_to_pointer(L.Coordinate6{},L.Coordinate6{}),
        (L.logical_target_routes_to_pointer(L.Coordinate7{},L.Coordinate8{}),
        (L.logical_target_routes_to_pointer(L.Coordinate7{},L.Coordinate6{}),
        {==}))))
    case L.Coordinate8{} L.Coordinate8{}:
      (L.logical_target_routes_to_pointer(L.Coordinate6{},L.Coordinate6{}),
        (L.logical_target_routes_to_pointer(L.Coordinate6{},L.Coordinate7{}),
        (L.logical_target_routes_to_pointer(L.Coordinate7{},L.Coordinate6{}),
        (L.logical_target_routes_to_pointer(L.Coordinate7{},L.Coordinate7{}),
        {==}))))

def L.placement_routes_to_pointer_with_geometry(sr,sc,geometry):
  (row_eq,col_eq) = geometry
  +p = L.logical_position(sr,sc)
  +q : U32 = 108
  %Equal.sym(U32,L.place_row_base(p),L.row_origin(sr),row_eq) :
    (L.RowDistinctRoutes(9n,0,_,q) & L.ColumnDistinctRoutes(9n,0,M.rem9(p),q)
     & L.DistinctPeerListRoutes(L.placed_box_positions(p),q))
  %Equal.sym(U32,M.rem9(p),L.coord_u32(sc),col_eq) :
    (L.RowDistinctRoutes(9n,0,L.row_origin(sr),q) & L.ColumnDistinctRoutes(9n,0,_,q)
     & L.DistinctPeerListRoutes(L.placed_box_positions(p),q))
  (L.row_routes_to_pointer(sr),
    (L.column_routes_to_pointer(sc),
      L.box_routes_to_pointer(sr,sc)))


def L.read_pointer_word_witness(b,expect,state):
  (unused,(unused_shape,word)) = state
  word

def L.actual_pre_refresh_keeps_pointer_routes(image,guess,p,d,shape,target,passes):
  (target_apart,flag_apart) = target
  +expect = L.cell_value(L.image_board(image),108)
  L.read_pointer_word_witness(L.placement_before_refresh(guess,L.image_board(image),p,d),expect,
    L.queued_place_keeps_pointer_word(expect,L.image_board(image),guess,p,108,d)(target_apart,flag_apart,passes,({==},(shape,{==}))))

def L.actual_pre_refresh_keeps_pointer_image(image,guess,row,col,d,shape):
  +p = L.logical_position(row,col)
  L.actual_pre_refresh_keeps_pointer_routes(image,guess,p,d,shape,L.logical_target_routes_to_pointer(row,col),
    L.placement_routes_to_pointer_with_geometry(row,col,L.source_place_geometry(row,col)))

def L.actual_pre_refresh_keeps_pointer(b,guess,row,col,d):
  L.on_reified_board(b,x => L.PreRefreshKeepsPointer(x,guess,row,col,d),
    L.reify_board(b),image => L.actual_pre_refresh_keeps_pointer_image(image,guess,row,col,d))

def L.refresh_keeps_known_pointer_parts(image,p,start,known,miss):
  (for_refresh,for_trans) = known
  +old = L.cell_value(L.image_board(image),108)
  Equal.trans(U32,L.cell_value(L.refresh_actual(L.image_board(image),p),108),old,start,
    Equal.cong(Array<U32>,U32,a => L.cell_value(a,108),L.refresh_actual(L.image_board(image),p),L.image_board(image),
      L.refresh_away_from_pointer_leaves_board(image,p,start,for_refresh,miss)),for_trans)

def L.refresh_keeps_known_pointer_image(image,p,start,known,miss):
  L.refresh_keeps_known_pointer_parts(image,p,start,L.copy_word_eq(L.cell_value(L.image_board(image),108),start,known),miss)

def L.refresh_keeps_known_pointer(b,p,start):
  L.on_reified_board(b,x => L.RefreshKeepsKnownPointer(x,p,start),
    L.reify_board(b),image => L.refresh_keeps_known_pointer_image(image,p,start))

def L.queued_place_away_keeps_pointer_image(image,guess,row,col,d,shape,miss):
  +p = L.logical_position(row,col)
  +start = L.cell_value(L.image_board(image),108)
  L.refresh_keeps_known_pointer(L.placement_before_refresh(guess,L.image_board(image),p,d),p,start)(
    L.actual_pre_refresh_keeps_pointer(L.image_board(image),guess,row,col,d)(shape),miss)

def L.queued_place_away_keeps_pointer(b,guess,row,col,d):
  L.on_reified_board(b,x => L.PlaceAwayKeepsPointer(x,guess,row,col,d),
    L.reify_board(b),image => L.queued_place_away_keeps_pointer_image(image,guess,row,col,d))

def L.check_urgency_flag_tree_9(placed,b0,b1,b2,b3,b4,b5,b6,b7,b8,suffix,checked):
  match suffix:
    case WNil{}:
      checked

def L.select_urgency_subtree_8(placed,b0,b1,b2,b3,b4,b5,b6,b7,bit,both):
  match bit:
    case False{}:
      Pair.fst({L.urgency_flag_tree_9(placed,b0,b1,b2,b3,b4,b5,b6,b7,False{}) == True{} : Bool},{L.urgency_flag_tree_9(placed,b0,b1,b2,b3,b4,b5,b6,b7,True{}) == True{} : Bool},both)
    case True{}:
      Pair.snd({L.urgency_flag_tree_9(placed,b0,b1,b2,b3,b4,b5,b6,b7,False{}) == True{} : Bool},{L.urgency_flag_tree_9(placed,b0,b1,b2,b3,b4,b5,b6,b7,True{}) == True{} : Bool},both)

def L.check_urgency_flag_tree_8(placed,b0,b1,b2,b3,b4,b5,b6,b7,suffix,checked):
  match suffix:
    case WCon{+bit,+rest}:
      L.check_urgency_flag_tree_9(placed,b0,b1,b2,b3,b4,b5,b6,b7,bit,rest,
        L.select_urgency_subtree_8(placed,b0,b1,b2,b3,b4,b5,b6,b7,bit,
          L.both_true(L.urgency_flag_tree_9(placed,b0,b1,b2,b3,b4,b5,b6,b7,False{}),L.urgency_flag_tree_9(placed,b0,b1,b2,b3,b4,b5,b6,b7,True{}),checked)))

def L.select_urgency_subtree_7(placed,b0,b1,b2,b3,b4,b5,b6,bit,both):
  match bit:
    case False{}:
      Pair.fst({L.urgency_flag_tree_8(placed,b0,b1,b2,b3,b4,b5,b6,False{}) == True{} : Bool},{L.urgency_flag_tree_8(placed,b0,b1,b2,b3,b4,b5,b6,True{}) == True{} : Bool},both)
    case True{}:
      Pair.snd({L.urgency_flag_tree_8(placed,b0,b1,b2,b3,b4,b5,b6,False{}) == True{} : Bool},{L.urgency_flag_tree_8(placed,b0,b1,b2,b3,b4,b5,b6,True{}) == True{} : Bool},both)

def L.check_urgency_flag_tree_7(placed,b0,b1,b2,b3,b4,b5,b6,suffix,checked):
  match suffix:
    case WCon{+bit,+rest}:
      L.check_urgency_flag_tree_8(placed,b0,b1,b2,b3,b4,b5,b6,bit,rest,
        L.select_urgency_subtree_7(placed,b0,b1,b2,b3,b4,b5,b6,bit,
          L.both_true(L.urgency_flag_tree_8(placed,b0,b1,b2,b3,b4,b5,b6,False{}),L.urgency_flag_tree_8(placed,b0,b1,b2,b3,b4,b5,b6,True{}),checked)))

def L.select_urgency_subtree_6(placed,b0,b1,b2,b3,b4,b5,bit,both):
  match bit:
    case False{}:
      Pair.fst({L.urgency_flag_tree_7(placed,b0,b1,b2,b3,b4,b5,False{}) == True{} : Bool},{L.urgency_flag_tree_7(placed,b0,b1,b2,b3,b4,b5,True{}) == True{} : Bool},both)
    case True{}:
      Pair.snd({L.urgency_flag_tree_7(placed,b0,b1,b2,b3,b4,b5,False{}) == True{} : Bool},{L.urgency_flag_tree_7(placed,b0,b1,b2,b3,b4,b5,True{}) == True{} : Bool},both)

def L.check_urgency_flag_tree_6(placed,b0,b1,b2,b3,b4,b5,suffix,checked):
  match suffix:
    case WCon{+bit,+rest}:
      L.check_urgency_flag_tree_7(placed,b0,b1,b2,b3,b4,b5,bit,rest,
        L.select_urgency_subtree_6(placed,b0,b1,b2,b3,b4,b5,bit,
          L.both_true(L.urgency_flag_tree_7(placed,b0,b1,b2,b3,b4,b5,False{}),L.urgency_flag_tree_7(placed,b0,b1,b2,b3,b4,b5,True{}),checked)))

def L.select_urgency_subtree_5(placed,b0,b1,b2,b3,b4,bit,both):
  match bit:
    case False{}:
      Pair.fst({L.urgency_flag_tree_6(placed,b0,b1,b2,b3,b4,False{}) == True{} : Bool},{L.urgency_flag_tree_6(placed,b0,b1,b2,b3,b4,True{}) == True{} : Bool},both)
    case True{}:
      Pair.snd({L.urgency_flag_tree_6(placed,b0,b1,b2,b3,b4,False{}) == True{} : Bool},{L.urgency_flag_tree_6(placed,b0,b1,b2,b3,b4,True{}) == True{} : Bool},both)

def L.check_urgency_flag_tree_5(placed,b0,b1,b2,b3,b4,suffix,checked):
  match suffix:
    case WCon{+bit,+rest}:
      L.check_urgency_flag_tree_6(placed,b0,b1,b2,b3,b4,bit,rest,
        L.select_urgency_subtree_5(placed,b0,b1,b2,b3,b4,bit,
          L.both_true(L.urgency_flag_tree_6(placed,b0,b1,b2,b3,b4,False{}),L.urgency_flag_tree_6(placed,b0,b1,b2,b3,b4,True{}),checked)))

def L.select_urgency_subtree_4(placed,b0,b1,b2,b3,bit,both):
  match bit:
    case False{}:
      Pair.fst({L.urgency_flag_tree_5(placed,b0,b1,b2,b3,False{}) == True{} : Bool},{L.urgency_flag_tree_5(placed,b0,b1,b2,b3,True{}) == True{} : Bool},both)
    case True{}:
      Pair.snd({L.urgency_flag_tree_5(placed,b0,b1,b2,b3,False{}) == True{} : Bool},{L.urgency_flag_tree_5(placed,b0,b1,b2,b3,True{}) == True{} : Bool},both)

def L.check_urgency_flag_tree_4(placed,b0,b1,b2,b3,suffix,checked):
  match suffix:
    case WCon{+bit,+rest}:
      L.check_urgency_flag_tree_5(placed,b0,b1,b2,b3,bit,rest,
        L.select_urgency_subtree_4(placed,b0,b1,b2,b3,bit,
          L.both_true(L.urgency_flag_tree_5(placed,b0,b1,b2,b3,False{}),L.urgency_flag_tree_5(placed,b0,b1,b2,b3,True{}),checked)))

def L.select_urgency_subtree_3(placed,b0,b1,b2,bit,both):
  match bit:
    case False{}:
      Pair.fst({L.urgency_flag_tree_4(placed,b0,b1,b2,False{}) == True{} : Bool},{L.urgency_flag_tree_4(placed,b0,b1,b2,True{}) == True{} : Bool},both)
    case True{}:
      Pair.snd({L.urgency_flag_tree_4(placed,b0,b1,b2,False{}) == True{} : Bool},{L.urgency_flag_tree_4(placed,b0,b1,b2,True{}) == True{} : Bool},both)

def L.check_urgency_flag_tree_3(placed,b0,b1,b2,suffix,checked):
  match suffix:
    case WCon{+bit,+rest}:
      L.check_urgency_flag_tree_4(placed,b0,b1,b2,bit,rest,
        L.select_urgency_subtree_3(placed,b0,b1,b2,bit,
          L.both_true(L.urgency_flag_tree_4(placed,b0,b1,b2,False{}),L.urgency_flag_tree_4(placed,b0,b1,b2,True{}),checked)))

def L.select_urgency_subtree_2(placed,b0,b1,bit,both):
  match bit:
    case False{}:
      Pair.fst({L.urgency_flag_tree_3(placed,b0,b1,False{}) == True{} : Bool},{L.urgency_flag_tree_3(placed,b0,b1,True{}) == True{} : Bool},both)
    case True{}:
      Pair.snd({L.urgency_flag_tree_3(placed,b0,b1,False{}) == True{} : Bool},{L.urgency_flag_tree_3(placed,b0,b1,True{}) == True{} : Bool},both)

def L.check_urgency_flag_tree_2(placed,b0,b1,suffix,checked):
  match suffix:
    case WCon{+bit,+rest}:
      L.check_urgency_flag_tree_3(placed,b0,b1,bit,rest,
        L.select_urgency_subtree_2(placed,b0,b1,bit,
          L.both_true(L.urgency_flag_tree_3(placed,b0,b1,False{}),L.urgency_flag_tree_3(placed,b0,b1,True{}),checked)))

def L.select_urgency_subtree_1(placed,b0,bit,both):
  match bit:
    case False{}:
      Pair.fst({L.urgency_flag_tree_2(placed,b0,False{}) == True{} : Bool},{L.urgency_flag_tree_2(placed,b0,True{}) == True{} : Bool},both)
    case True{}:
      Pair.snd({L.urgency_flag_tree_2(placed,b0,False{}) == True{} : Bool},{L.urgency_flag_tree_2(placed,b0,True{}) == True{} : Bool},both)

def L.check_urgency_flag_tree_1(placed,b0,suffix,checked):
  match suffix:
    case WCon{+bit,+rest}:
      L.check_urgency_flag_tree_2(placed,b0,bit,rest,
        L.select_urgency_subtree_1(placed,b0,bit,
          L.both_true(L.urgency_flag_tree_2(placed,b0,False{}),L.urgency_flag_tree_2(placed,b0,True{}),checked)))

def L.select_urgency_subtree_0(placed,bit,both):
  match bit:
    case False{}:
      Pair.fst({L.urgency_flag_tree_1(placed,False{}) == True{} : Bool},{L.urgency_flag_tree_1(placed,True{}) == True{} : Bool},both)
    case True{}:
      Pair.snd({L.urgency_flag_tree_1(placed,False{}) == True{} : Bool},{L.urgency_flag_tree_1(placed,True{}) == True{} : Bool},both)

def L.check_urgency_flag_tree_0(placed,suffix,checked):
  match suffix:
    case WCon{+bit,+rest}:
      L.check_urgency_flag_tree_1(placed,bit,rest,
        L.select_urgency_subtree_0(placed,bit,
          L.both_true(L.urgency_flag_tree_1(placed,False{}),L.urgency_flag_tree_1(placed,True{}),checked)))

def L.equal_urgency_sound(a,b,yes):
  match a b:
    case False{} False{}:
      {==}
    case False{} True{}:
      Empty.absurd({False{} == True{} : Bool},L.false_is_not_true(yes))
    case True{} False{}:
      Empty.absurd({True{} == False{} : Bool},L.false_is_not_true(yes))
    case True{} True{}:
      {==}

def L.all_masks_keep_urgency(placed):
  match placed:
    case L.D0{}:
      {==}
    case L.D1{}:
      {==}
    case L.D2{}:
      {==}
    case L.D3{}:
      {==}
    case L.D4{}:
      {==}
    case L.D5{}:
      {==}
    case L.D6{}:
      {==}
    case L.D7{}:
      {==}
    case L.D8{}:
      {==}
    case L.D9{}:
      {==}

def L.normalized_bits_keep_exact_urgency(placed,bits):
  +old = L.candidate_bits_word(bits)
  +bit = Board.bit(L.digit_word(placed))
  L.equal_urgency_sound(L.urgency_after_peer(old,bit,Q.zero_or_single(old)),
    Q.zero_or_single(L.blank_after_peer(old,bit)),
    L.check_urgency_flag_tree_0(placed,bits,L.all_masks_keep_urgency(placed)))

def L.urgency_from_candidate_image(placed,old,image):
  (+bits,form) = image
  %Equal.sym(U32,U32.and(1022,old),L.candidate_bits_word(bits),form) : L.UrgencyConsistent(placed,_)
  L.normalized_bits_keep_exact_urgency(placed,bits)

def L.normalized_blank_keeps_exact_urgency(placed,old,normalized):
  %normalized : L.UrgencyConsistent(placed,_)
  L.urgency_from_candidate_image(placed,old,L.low_candidate_mask_image(old))

def L.flag_writes_slot_word_image(image,p,on):
  b = L.image_board(image)
  +slot = L.flag_slot(p)
  +word = L.flag_word(p,on,L.cell_value(L.image_board(image),slot))
  %Equal.sym(Array<U32>,Q.flag(b,p,on),Board.set_cell(b,slot,word),
    L.flag_normalized(b,p,on,L.board_read_witness(L.image_board(image),slot))) :
    {L.cell_value(_,slot) == word : U32}
  L.board_set_get(L.image_board(image),slot,word)

def L.flag_writes_slot_word(b,p,on):
  L.on_reified_board(b,x => L.FlagWrittenWord(x,p,on),
    L.reify_board(b),image => L.flag_writes_slot_word_image(image,p,on))

def L.changed_flag_slot_word(b,p,needed):
  match needed:
    case False{}:
      {==}
    case True{}:
      L.flag_writes_slot_word(b,p,True{})

def L.pick_flag_word_rewrite(p,change,before,after,eq):
  %Equal.sym(U32,after,before,eq) :
    {Bool.pick(U32,change,L.flag_word(p,True{},_),_) ==
     Bool.pick(U32,change,L.flag_word(p,True{},before),before) : U32}
  {==}

def L.peer_flag_word_change_step(image,needed,p,bit,old,shape,apart):
  match needed:
    case False{}:
      {==}
    case True{}:
      +slot = L.flag_slot(p)
      +candidate = L.peer_mask(old,bit)
      +update = L.peer_reflag(old,bit)
      written = Board.set_cell(L.image_board(image),p,candidate)
      +word_after_write = L.cell_value(Board.set_cell(L.image_board(image),p,candidate),slot)
      +word_before_write = L.cell_value(L.image_board(image),slot)
      Equal.trans(U32,L.cell_value(Q.changed(True{},p,bit,L.image_board(image),old),slot),
        Bool.pick(U32,update,L.flag_word(p,True{},word_after_write),word_after_write),
        Bool.pick(U32,update,L.flag_word(p,True{},word_before_write),word_before_write),
        L.changed_flag_slot_word(written,p,update),
        L.pick_flag_word_rewrite(p,update,word_before_write,word_after_write,
          L.perfect_write_keeps_cell(L.image_board(image),p,slot,candidate,shape,apart)))

def L.actual_peer_flag_word_image(image,p,bit,shape,apart):
  b = L.image_board(image)
  +old = L.cell_value(L.image_board(image),p)
  +needed = U32.is_ne(U32.and(old,bit),0)
  +slot = L.flag_slot(p)
  %Equal.sym(Array<U32>,L.actual_peer(b,p,bit),Q.changed(needed,p,bit,b,old),
    L.peer_normalized(b,p,bit,L.board_read_witness(L.image_board(image),p))) :
    {L.cell_value(_,slot) == L.peer_flag_word_model(p,old,bit,L.cell_value(b,slot)) : U32}
  L.peer_flag_word_change_step(image,needed,p,bit,old,shape,apart)

def L.actual_peer_flag_word(b,p,bit):
  L.on_reified_board(b,x => L.PeerFlagWord(x,p,bit),
    L.reify_board(b),image => L.actual_peer_flag_word_image(image,p,bit))

def L.bit_mask_set_is_set(old,mask):
  match old mask:
    case False{} False{}:
      {==}
    case False{} True{}:
      {==}
    case True{} False{}:
      {==}
    case True{} True{}:
      {==}

def L.bit_mask_clear_is_clear(old,mask):
  match old mask:
    case False{} False{}:
      {==}
    case False{} True{}:
      {==}
    case True{} False{}:
      {==}
    case True{} True{}:
      {==}

def L.word_mask_set_is_set(n,old,mask):
  match n old mask:
    case 0n WNil{} WNil{}:
      {==}
    case 1n+k WCon{+a,+tail_a} WCon{+b,+tail_b}:
      %Equal.sym(Bool,Bool.and(b,Bool.or(a,b)),b,L.bit_mask_set_is_set(a,b)) :
        {WCon{_,Word.and(k,tail_b,Word.or(k,tail_a,tail_b))} == WCon{b,tail_b} : Word(1n+k)}
      Equal.cong(Word(k),Word(1n+k),r => WCon{b,r},
        Word.and(k,tail_b,Word.or(k,tail_a,tail_b)),tail_b,L.word_mask_set_is_set(k,tail_a,tail_b))

def L.word_mask_clear_is_clear(n,old,mask):
  match n old mask:
    case 0n WNil{} WNil{}:
      {==}
    case 1n+k WCon{+a,+tail_a} WCon{+b,+tail_b}:
      %Equal.sym(Bool,Bool.and(b,Bool.and(a,Bool.not(b))),False{},L.bit_mask_clear_is_clear(a,b)) :
        {WCon{_,Word.and(k,tail_b,Word.and(k,tail_a,Word.not(k,tail_b)))} == Word.zero(1n+k) : Word(1n+k)}
      Equal.cong(Word(k),Word(1n+k),r => WCon{False{},r},
        Word.and(k,tail_b,Word.and(k,tail_a,Word.not(k,tail_b))),Word.zero(k),L.word_mask_clear_is_clear(k,tail_a,tail_b))

def L.u32_mask_set_is_set(old,mask):
  match old mask:
    case U32{+a} U32{+b}:
      Equal.cong(Word(32n),U32,w => U32{w},Word.and(32n,b,Word.or(32n,a,b)),b,L.word_mask_set_is_set(32n,a,b))

def L.u32_mask_clear_is_clear(old,mask):
  match old mask:
    case U32{+a} U32{+b}:
      Equal.cong(Word(32n),U32,w => U32{w},Word.and(32n,b,Word.and(32n,a,Word.not(32n,b))),Word.zero(32n),
        L.word_mask_clear_is_clear(32n,a,b))

def L.flag_word_set_is_present(p,flags,nonzero):
  +mask = L.own_queue_flag_mask(p)
  %Equal.sym(U32,U32.and(mask,U32.or(flags,mask)),mask,L.u32_mask_set_is_set(flags,mask)) :
    {U32.is_ne(_,0) == True{} : Bool}
  nonzero

def L.flag_word_clear_is_absent(p,flags):
  +mask = L.own_queue_flag_mask(p)
  %Equal.sym(U32,U32.and(mask,U32.and(flags,U32.not(mask))),0,L.u32_mask_clear_is_clear(flags,mask)) :
    {U32.is_ne(_,0) == False{} : Bool}
  {==}

def L.flag_word_flag_matches_value(p,on,flags,nonzero):
  match on:
    case False{}:
      L.flag_word_clear_is_absent(p,flags)
    case True{}:
      L.flag_word_set_is_present(p,flags,nonzero)

def L.bool_or_right_false_at(value):
  match value:
    case False{}:
      {==}
    case True{}:
      {==}

def L.bool_or_right_true_from(value):
  match value:
    case False{}:
      {==}
    case True{}:
      {==}

def L.actual_peer_flag_model_bits(p,change,flags,nonzero):
  match change:
    case False{}:
      L.bool_or_right_false_at(L.queue_flag_present(p,flags))
    case True{}:
      Equal.trans(Bool,L.queue_flag_present(p,L.flag_word(p,True{},flags)),True{},Bool.or(L.queue_flag_present(p,flags),True{}),
        L.flag_word_set_is_present(p,flags,nonzero),L.bool_or_right_true_from(L.queue_flag_present(p,flags)))

def L.actual_peer_flag_model_observable(p,old,bit,flags,nonzero):
  L.actual_peer_flag_model_bits(p,Bool.and(U32.is_ne(U32.and(old,bit),0),L.peer_reflag(old,bit)),flags,nonzero)

def L.actual_peer_observed_flag_image(image,p,bit,shape,apart,nonzero):
  b = L.image_board(image)
  +slot = L.flag_slot(p)
  +old = L.cell_value(L.image_board(image),p)
  +flags = L.cell_value(L.image_board(image),slot)
  +model = L.peer_flag_word_model(p,old,bit,flags)
  %Equal.sym(U32,L.cell_value(L.actual_peer(b,p,bit),slot),model,L.actual_peer_flag_word(L.image_board(image),p,bit)(shape,apart)) :
    {L.queue_flag_present(p,_) == L.urgency_after_peer(old,bit,L.queue_flag_present(p,flags)) : Bool}
  L.actual_peer_flag_model_observable(p,old,bit,flags,nonzero)

def L.actual_changed_candidate_image(image,needed,p,bit,shape,apart):
  match needed:
    case False{}:
      {==}
    case True{}:
      L.changed_peer_word_image(image,p,bit,L.cell_value(L.image_board(image),p),shape,apart)

def L.actual_peer_candidate_image(image,p,bit,shape,apart):
  b = L.image_board(image)
  +old = L.cell_value(L.image_board(image),p)
  +needed = U32.is_ne(U32.and(old,bit),0)
  %Equal.sym(Array<U32>,L.actual_peer(b,p,bit),Q.changed(needed,p,bit,b,old),
    L.peer_normalized(b,p,bit,L.board_read_witness(L.image_board(image),p))) :
    {L.cell_value(_,p) == L.blank_after_peer(old,bit) : U32}
  L.actual_changed_candidate_image(image,needed,p,bit,shape,apart)

def L.prior_flag_urgency_agrees(placed,old,prior,observed,norm):
  +bit = Board.bit(L.digit_word(placed))
  %Equal.sym(Bool,prior,Q.zero_or_single(old),observed) :
    {L.urgency_after_peer(old,bit,_) == Q.zero_or_single(L.blank_after_peer(old,bit)) : Bool}
  L.normalized_blank_keeps_exact_urgency(placed,old,norm)

def L.actual_peer_normalized_urgency_parts(image,p,placed,shapes,flag_route,cell_route,nonzero,observed,norm):
  (s0,s1) = shapes
  +bit = Board.bit(L.digit_word(placed))
  +old = L.cell_value(L.image_board(image),p)
  +prior = L.actual_flag_at(L.image_board(image),p)
  result = L.actual_peer(L.image_board(image),p,bit)
  %Equal.sym(U32,L.cell_value(result,p),L.blank_after_peer(old,bit),L.actual_peer_candidate_image(image,p,bit,s0,cell_route)) :
    {L.actual_flag_at(result,p) == Q.zero_or_single(_) : Bool}
  Equal.trans(Bool,L.actual_flag_at(result,p),L.urgency_after_peer(old,bit,prior),Q.zero_or_single(L.blank_after_peer(old,bit)),
    L.actual_peer_observed_flag_image(image,p,bit,s1,flag_route,nonzero),
    L.prior_flag_urgency_agrees(placed,old,prior,observed,norm))

def L.actual_peer_normalized_urgency_image(image,p,placed,shape):
  L.actual_peer_normalized_urgency_parts(image,p,placed,
    L.copy_shape_proof(L.array_shape(L.image_board(image)),L.perfect_shape(7n),shape))

def L.actual_peer_normalized_urgency(b,p,placed):
  L.on_reified_board(b,x => L.ActualPeerKeepsUrgency(x,p,placed),
    L.reify_board(b),image => L.actual_peer_normalized_urgency_image(image,p,placed))

def L.low_five_flag_is_nonzero(b0,b1,b2,b3,b4):
  match b0 b1 b2 b3 b4:
    case False{} False{} False{} False{} False{}:
      {==}
    case False{} False{} False{} False{} True{}:
      {==}
    case False{} False{} False{} True{} False{}:
      {==}
    case False{} False{} False{} True{} True{}:
      {==}
    case False{} False{} True{} False{} False{}:
      {==}
    case False{} False{} True{} False{} True{}:
      {==}
    case False{} False{} True{} True{} False{}:
      {==}
    case False{} False{} True{} True{} True{}:
      {==}
    case False{} True{} False{} False{} False{}:
      {==}
    case False{} True{} False{} False{} True{}:
      {==}
    case False{} True{} False{} True{} False{}:
      {==}
    case False{} True{} False{} True{} True{}:
      {==}
    case False{} True{} True{} False{} False{}:
      {==}
    case False{} True{} True{} False{} True{}:
      {==}
    case False{} True{} True{} True{} False{}:
      {==}
    case False{} True{} True{} True{} True{}:
      {==}
    case True{} False{} False{} False{} False{}:
      {==}
    case True{} False{} False{} False{} True{}:
      {==}
    case True{} False{} False{} True{} False{}:
      {==}
    case True{} False{} False{} True{} True{}:
      {==}
    case True{} False{} True{} False{} False{}:
      {==}
    case True{} False{} True{} False{} True{}:
      {==}
    case True{} False{} True{} True{} False{}:
      {==}
    case True{} False{} True{} True{} True{}:
      {==}
    case True{} True{} False{} False{} False{}:
      {==}
    case True{} True{} False{} False{} True{}:
      {==}
    case True{} True{} False{} True{} False{}:
      {==}
    case True{} True{} False{} True{} True{}:
      {==}
    case True{} True{} True{} False{} False{}:
      {==}
    case True{} True{} True{} False{} True{}:
      {==}
    case True{} True{} True{} True{} False{}:
      {==}
    case True{} True{} True{} True{} True{}:
      {==}

def L.own_queue_flag_mask_is_nonzero(p):
  match p:
    case U32{WCon{b0,WCon{b1,WCon{b2,WCon{b3,WCon{b4,tail}}}}}}:
      %Equal.sym(Word(27n),Word.and(27n,tail,Word.zero(27n)),Word.zero(27n),L.word_and_zero(27n,tail)) :
        {U32.is_ne(L.flag_bit_at(L.low_five_word(Bool.and(b0,True{}),Bool.and(b1,True{}),Bool.and(b2,True{}),Bool.and(b3,True{}),Bool.and(b4,True{}),_)),0) == True{} : Bool}
      L.low_five_flag_is_nonzero(Bool.and(b0,True{}),Bool.and(b1,True{}),Bool.and(b2,True{}),Bool.and(b3,True{}),Bool.and(b4,True{}))

def L.logical_cell_and_flag_are_apart(row,col):
  match row col:
    case L.Coordinate0{} L.Coordinate0{}:
      {==}
    case L.Coordinate0{} L.Coordinate1{}:
      {==}
    case L.Coordinate0{} L.Coordinate2{}:
      {==}
    case L.Coordinate0{} L.Coordinate3{}:
      {==}
    case L.Coordinate0{} L.Coordinate4{}:
      {==}
    case L.Coordinate0{} L.Coordinate5{}:
      {==}
    case L.Coordinate0{} L.Coordinate6{}:
      {==}
    case L.Coordinate0{} L.Coordinate7{}:
      {==}
    case L.Coordinate0{} L.Coordinate8{}:
      {==}
    case L.Coordinate1{} L.Coordinate0{}:
      {==}
    case L.Coordinate1{} L.Coordinate1{}:
      {==}
    case L.Coordinate1{} L.Coordinate2{}:
      {==}
    case L.Coordinate1{} L.Coordinate3{}:
      {==}
    case L.Coordinate1{} L.Coordinate4{}:
      {==}
    case L.Coordinate1{} L.Coordinate5{}:
      {==}
    case L.Coordinate1{} L.Coordinate6{}:
      {==}
    case L.Coordinate1{} L.Coordinate7{}:
      {==}
    case L.Coordinate1{} L.Coordinate8{}:
      {==}
    case L.Coordinate2{} L.Coordinate0{}:
      {==}
    case L.Coordinate2{} L.Coordinate1{}:
      {==}
    case L.Coordinate2{} L.Coordinate2{}:
      {==}
    case L.Coordinate2{} L.Coordinate3{}:
      {==}
    case L.Coordinate2{} L.Coordinate4{}:
      {==}
    case L.Coordinate2{} L.Coordinate5{}:
      {==}
    case L.Coordinate2{} L.Coordinate6{}:
      {==}
    case L.Coordinate2{} L.Coordinate7{}:
      {==}
    case L.Coordinate2{} L.Coordinate8{}:
      {==}
    case L.Coordinate3{} L.Coordinate0{}:
      {==}
    case L.Coordinate3{} L.Coordinate1{}:
      {==}
    case L.Coordinate3{} L.Coordinate2{}:
      {==}
    case L.Coordinate3{} L.Coordinate3{}:
      {==}
    case L.Coordinate3{} L.Coordinate4{}:
      {==}
    case L.Coordinate3{} L.Coordinate5{}:
      {==}
    case L.Coordinate3{} L.Coordinate6{}:
      {==}
    case L.Coordinate3{} L.Coordinate7{}:
      {==}
    case L.Coordinate3{} L.Coordinate8{}:
      {==}
    case L.Coordinate4{} L.Coordinate0{}:
      {==}
    case L.Coordinate4{} L.Coordinate1{}:
      {==}
    case L.Coordinate4{} L.Coordinate2{}:
      {==}
    case L.Coordinate4{} L.Coordinate3{}:
      {==}
    case L.Coordinate4{} L.Coordinate4{}:
      {==}
    case L.Coordinate4{} L.Coordinate5{}:
      {==}
    case L.Coordinate4{} L.Coordinate6{}:
      {==}
    case L.Coordinate4{} L.Coordinate7{}:
      {==}
    case L.Coordinate4{} L.Coordinate8{}:
      {==}
    case L.Coordinate5{} L.Coordinate0{}:
      {==}
    case L.Coordinate5{} L.Coordinate1{}:
      {==}
    case L.Coordinate5{} L.Coordinate2{}:
      {==}
    case L.Coordinate5{} L.Coordinate3{}:
      {==}
    case L.Coordinate5{} L.Coordinate4{}:
      {==}
    case L.Coordinate5{} L.Coordinate5{}:
      {==}
    case L.Coordinate5{} L.Coordinate6{}:
      {==}
    case L.Coordinate5{} L.Coordinate7{}:
      {==}
    case L.Coordinate5{} L.Coordinate8{}:
      {==}
    case L.Coordinate6{} L.Coordinate0{}:
      {==}
    case L.Coordinate6{} L.Coordinate1{}:
      {==}
    case L.Coordinate6{} L.Coordinate2{}:
      {==}
    case L.Coordinate6{} L.Coordinate3{}:
      {==}
    case L.Coordinate6{} L.Coordinate4{}:
      {==}
    case L.Coordinate6{} L.Coordinate5{}:
      {==}
    case L.Coordinate6{} L.Coordinate6{}:
      {==}
    case L.Coordinate6{} L.Coordinate7{}:
      {==}
    case L.Coordinate6{} L.Coordinate8{}:
      {==}
    case L.Coordinate7{} L.Coordinate0{}:
      {==}
    case L.Coordinate7{} L.Coordinate1{}:
      {==}
    case L.Coordinate7{} L.Coordinate2{}:
      {==}
    case L.Coordinate7{} L.Coordinate3{}:
      {==}
    case L.Coordinate7{} L.Coordinate4{}:
      {==}
    case L.Coordinate7{} L.Coordinate5{}:
      {==}
    case L.Coordinate7{} L.Coordinate6{}:
      {==}
    case L.Coordinate7{} L.Coordinate7{}:
      {==}
    case L.Coordinate7{} L.Coordinate8{}:
      {==}
    case L.Coordinate8{} L.Coordinate0{}:
      {==}
    case L.Coordinate8{} L.Coordinate1{}:
      {==}
    case L.Coordinate8{} L.Coordinate2{}:
      {==}
    case L.Coordinate8{} L.Coordinate3{}:
      {==}
    case L.Coordinate8{} L.Coordinate4{}:
      {==}
    case L.Coordinate8{} L.Coordinate5{}:
      {==}
    case L.Coordinate8{} L.Coordinate6{}:
      {==}
    case L.Coordinate8{} L.Coordinate7{}:
      {==}
    case L.Coordinate8{} L.Coordinate8{}:
      {==}

def L.logical_peer_preserves_exact_urgency(b,row,col,placed,shape,observed,norm):
  +p = L.logical_position(row,col)
  L.actual_peer_normalized_urgency(b,p,placed)(shape,L.logical_cell_and_flag_are_apart(row,col),
    L.any_logical_flag_route(row,col,row,col),L.own_queue_flag_mask_is_nonzero(p),observed,norm)

def L.word_mask_set_keeps_other(n,value,watch,edit,apart):
  match n value watch edit:
    case 0n WNil{} WNil{} WNil{}:
      {==}
    case 1n+k WCon{False{},+at} WCon{False{},+bt} WCon{False{},+ct}:
      Equal.cong(Word(k),Word(1n+k),w => WCon{False{},w},Word.and(k,bt,Word.or(k,at,ct)),Word.and(k,bt,at),
        L.word_mask_set_keeps_other(k,at,bt,ct,
          Equal.cong(Word(1n+k),Word(k),w => L.bit_word_tail(k,w),WCon{False{},Word.and(k,bt,ct)},Word.zero(1n+k),apart)))
    case 1n+k WCon{False{},+at} WCon{False{},+bt} WCon{True{},+ct}:
      Equal.cong(Word(k),Word(1n+k),w => WCon{False{},w},Word.and(k,bt,Word.or(k,at,ct)),Word.and(k,bt,at),
        L.word_mask_set_keeps_other(k,at,bt,ct,
          Equal.cong(Word(1n+k),Word(k),w => L.bit_word_tail(k,w),WCon{False{},Word.and(k,bt,ct)},Word.zero(1n+k),apart)))
    case 1n+k WCon{False{},+at} WCon{True{},+bt} WCon{False{},+ct}:
      Equal.cong(Word(k),Word(1n+k),w => WCon{False{},w},Word.and(k,bt,Word.or(k,at,ct)),Word.and(k,bt,at),
        L.word_mask_set_keeps_other(k,at,bt,ct,
          Equal.cong(Word(1n+k),Word(k),w => L.bit_word_tail(k,w),WCon{False{},Word.and(k,bt,ct)},Word.zero(1n+k),apart)))
    case 1n+k WCon{False{},+at} WCon{True{},+bt} WCon{True{},+ct}:
      Empty.absurd({WCon{True{},Word.and(k,bt,Word.or(k,at,ct))} == WCon{False{},Word.and(k,bt,at)} : Word(1n+k)},
        L.false_is_not_true(Equal.sym(Bool,True{},False{},
          Equal.cong(Word(1n+k),Bool,w => L.bit_word_head(k,w),WCon{True{},Word.and(k,bt,ct)},Word.zero(1n+k),apart))))
    case 1n+k WCon{True{},+at} WCon{False{},+bt} WCon{False{},+ct}:
      Equal.cong(Word(k),Word(1n+k),w => WCon{False{},w},Word.and(k,bt,Word.or(k,at,ct)),Word.and(k,bt,at),
        L.word_mask_set_keeps_other(k,at,bt,ct,
          Equal.cong(Word(1n+k),Word(k),w => L.bit_word_tail(k,w),WCon{False{},Word.and(k,bt,ct)},Word.zero(1n+k),apart)))
    case 1n+k WCon{True{},+at} WCon{False{},+bt} WCon{True{},+ct}:
      Equal.cong(Word(k),Word(1n+k),w => WCon{False{},w},Word.and(k,bt,Word.or(k,at,ct)),Word.and(k,bt,at),
        L.word_mask_set_keeps_other(k,at,bt,ct,
          Equal.cong(Word(1n+k),Word(k),w => L.bit_word_tail(k,w),WCon{False{},Word.and(k,bt,ct)},Word.zero(1n+k),apart)))
    case 1n+k WCon{True{},+at} WCon{True{},+bt} WCon{False{},+ct}:
      Equal.cong(Word(k),Word(1n+k),w => WCon{True{},w},Word.and(k,bt,Word.or(k,at,ct)),Word.and(k,bt,at),
        L.word_mask_set_keeps_other(k,at,bt,ct,
          Equal.cong(Word(1n+k),Word(k),w => L.bit_word_tail(k,w),WCon{False{},Word.and(k,bt,ct)},Word.zero(1n+k),apart)))
    case 1n+k WCon{True{},+at} WCon{True{},+bt} WCon{True{},+ct}:
      Empty.absurd({WCon{True{},Word.and(k,bt,Word.or(k,at,ct))} == WCon{True{},Word.and(k,bt,at)} : Word(1n+k)},
        L.false_is_not_true(Equal.sym(Bool,True{},False{},
          Equal.cong(Word(1n+k),Bool,w => L.bit_word_head(k,w),WCon{True{},Word.and(k,bt,ct)},Word.zero(1n+k),apart))))

def L.u32_mask_set_keeps_other(value,watch,edit,apart):
  match value watch edit:
    case U32{+a} U32{+b} U32{+c}:
      Equal.cong(Word(32n),U32,w => U32{w},Word.and(32n,b,Word.or(32n,a,c)),Word.and(32n,b,a),
        L.word_mask_set_keeps_other(32n,a,b,c,
          Equal.cong(U32,Word(32n),w => L.bits_of_u32(w),U32{Word.and(32n,b,c)},0,apart)))

def L.word_mask_clear_keeps_other(n,value,watch,edit,apart):
  match n value watch edit:
    case 0n WNil{} WNil{} WNil{}:
      {==}
    case 1n+k WCon{False{},+at} WCon{False{},+bt} WCon{False{},+ct}:
      Equal.cong(Word(k),Word(1n+k),w => WCon{False{},w},Word.and(k,bt,Word.and(k,at,Word.not(k,ct))),Word.and(k,bt,at),
        L.word_mask_clear_keeps_other(k,at,bt,ct,
          Equal.cong(Word(1n+k),Word(k),w => L.bit_word_tail(k,w),WCon{False{},Word.and(k,bt,ct)},Word.zero(1n+k),apart)))
    case 1n+k WCon{False{},+at} WCon{False{},+bt} WCon{True{},+ct}:
      Equal.cong(Word(k),Word(1n+k),w => WCon{False{},w},Word.and(k,bt,Word.and(k,at,Word.not(k,ct))),Word.and(k,bt,at),
        L.word_mask_clear_keeps_other(k,at,bt,ct,
          Equal.cong(Word(1n+k),Word(k),w => L.bit_word_tail(k,w),WCon{False{},Word.and(k,bt,ct)},Word.zero(1n+k),apart)))
    case 1n+k WCon{False{},+at} WCon{True{},+bt} WCon{False{},+ct}:
      Equal.cong(Word(k),Word(1n+k),w => WCon{False{},w},Word.and(k,bt,Word.and(k,at,Word.not(k,ct))),Word.and(k,bt,at),
        L.word_mask_clear_keeps_other(k,at,bt,ct,
          Equal.cong(Word(1n+k),Word(k),w => L.bit_word_tail(k,w),WCon{False{},Word.and(k,bt,ct)},Word.zero(1n+k),apart)))
    case 1n+k WCon{False{},+at} WCon{True{},+bt} WCon{True{},+ct}:
      Empty.absurd({WCon{False{},Word.and(k,bt,Word.and(k,at,Word.not(k,ct)))} == WCon{False{},Word.and(k,bt,at)} : Word(1n+k)},
        L.false_is_not_true(Equal.sym(Bool,True{},False{},
          Equal.cong(Word(1n+k),Bool,w => L.bit_word_head(k,w),WCon{True{},Word.and(k,bt,ct)},Word.zero(1n+k),apart))))
    case 1n+k WCon{True{},+at} WCon{False{},+bt} WCon{False{},+ct}:
      Equal.cong(Word(k),Word(1n+k),w => WCon{False{},w},Word.and(k,bt,Word.and(k,at,Word.not(k,ct))),Word.and(k,bt,at),
        L.word_mask_clear_keeps_other(k,at,bt,ct,
          Equal.cong(Word(1n+k),Word(k),w => L.bit_word_tail(k,w),WCon{False{},Word.and(k,bt,ct)},Word.zero(1n+k),apart)))
    case 1n+k WCon{True{},+at} WCon{False{},+bt} WCon{True{},+ct}:
      Equal.cong(Word(k),Word(1n+k),w => WCon{False{},w},Word.and(k,bt,Word.and(k,at,Word.not(k,ct))),Word.and(k,bt,at),
        L.word_mask_clear_keeps_other(k,at,bt,ct,
          Equal.cong(Word(1n+k),Word(k),w => L.bit_word_tail(k,w),WCon{False{},Word.and(k,bt,ct)},Word.zero(1n+k),apart)))
    case 1n+k WCon{True{},+at} WCon{True{},+bt} WCon{False{},+ct}:
      Equal.cong(Word(k),Word(1n+k),w => WCon{True{},w},Word.and(k,bt,Word.and(k,at,Word.not(k,ct))),Word.and(k,bt,at),
        L.word_mask_clear_keeps_other(k,at,bt,ct,
          Equal.cong(Word(1n+k),Word(k),w => L.bit_word_tail(k,w),WCon{False{},Word.and(k,bt,ct)},Word.zero(1n+k),apart)))
    case 1n+k WCon{True{},+at} WCon{True{},+bt} WCon{True{},+ct}:
      Empty.absurd({WCon{False{},Word.and(k,bt,Word.and(k,at,Word.not(k,ct)))} == WCon{True{},Word.and(k,bt,at)} : Word(1n+k)},
        L.false_is_not_true(Equal.sym(Bool,True{},False{},
          Equal.cong(Word(1n+k),Bool,w => L.bit_word_head(k,w),WCon{True{},Word.and(k,bt,ct)},Word.zero(1n+k),apart))))

def L.u32_mask_clear_keeps_other(value,watch,edit,apart):
  match value watch edit:
    case U32{+a} U32{+b} U32{+c}:
      Equal.cong(Word(32n),U32,w => U32{w},Word.and(32n,b,Word.and(32n,a,Word.not(32n,c))),Word.and(32n,b,a),
        L.word_mask_clear_keeps_other(32n,a,b,c,
          Equal.cong(U32,Word(32n),w => L.bits_of_u32(w),U32{Word.and(32n,b,c)},0,apart)))

def L.flag_update_keeps_disjoint_watch_mask(pos,watch,value,on,apart):
  match on:
    case False{}:
      L.u32_mask_clear_keeps_other(value,watch,L.own_queue_flag_mask(pos),apart)
    case True{}:
      L.u32_mask_set_keeps_other(value,watch,L.own_queue_flag_mask(pos),apart)

def L.logical_flag_padding_route(row,col):
  match row col:
    case L.Coordinate0{} L.Coordinate0{}:
      Inl{{==}}
    case L.Coordinate0{} L.Coordinate1{}:
      Inl{{==}}
    case L.Coordinate0{} L.Coordinate2{}:
      Inl{{==}}
    case L.Coordinate0{} L.Coordinate3{}:
      Inl{{==}}
    case L.Coordinate0{} L.Coordinate4{}:
      Inl{{==}}
    case L.Coordinate0{} L.Coordinate5{}:
      Inl{{==}}
    case L.Coordinate0{} L.Coordinate6{}:
      Inl{{==}}
    case L.Coordinate0{} L.Coordinate7{}:
      Inl{{==}}
    case L.Coordinate0{} L.Coordinate8{}:
      Inl{{==}}
    case L.Coordinate1{} L.Coordinate0{}:
      Inl{{==}}
    case L.Coordinate1{} L.Coordinate1{}:
      Inl{{==}}
    case L.Coordinate1{} L.Coordinate2{}:
      Inl{{==}}
    case L.Coordinate1{} L.Coordinate3{}:
      Inl{{==}}
    case L.Coordinate1{} L.Coordinate4{}:
      Inl{{==}}
    case L.Coordinate1{} L.Coordinate5{}:
      Inl{{==}}
    case L.Coordinate1{} L.Coordinate6{}:
      Inl{{==}}
    case L.Coordinate1{} L.Coordinate7{}:
      Inl{{==}}
    case L.Coordinate1{} L.Coordinate8{}:
      Inl{{==}}
    case L.Coordinate2{} L.Coordinate0{}:
      Inl{{==}}
    case L.Coordinate2{} L.Coordinate1{}:
      Inl{{==}}
    case L.Coordinate2{} L.Coordinate2{}:
      Inl{{==}}
    case L.Coordinate2{} L.Coordinate3{}:
      Inl{{==}}
    case L.Coordinate2{} L.Coordinate4{}:
      Inl{{==}}
    case L.Coordinate2{} L.Coordinate5{}:
      Inl{{==}}
    case L.Coordinate2{} L.Coordinate6{}:
      Inl{{==}}
    case L.Coordinate2{} L.Coordinate7{}:
      Inl{{==}}
    case L.Coordinate2{} L.Coordinate8{}:
      Inl{{==}}
    case L.Coordinate3{} L.Coordinate0{}:
      Inl{{==}}
    case L.Coordinate3{} L.Coordinate1{}:
      Inl{{==}}
    case L.Coordinate3{} L.Coordinate2{}:
      Inl{{==}}
    case L.Coordinate3{} L.Coordinate3{}:
      Inl{{==}}
    case L.Coordinate3{} L.Coordinate4{}:
      Inl{{==}}
    case L.Coordinate3{} L.Coordinate5{}:
      Inl{{==}}
    case L.Coordinate3{} L.Coordinate6{}:
      Inl{{==}}
    case L.Coordinate3{} L.Coordinate7{}:
      Inl{{==}}
    case L.Coordinate3{} L.Coordinate8{}:
      Inl{{==}}
    case L.Coordinate4{} L.Coordinate0{}:
      Inl{{==}}
    case L.Coordinate4{} L.Coordinate1{}:
      Inl{{==}}
    case L.Coordinate4{} L.Coordinate2{}:
      Inl{{==}}
    case L.Coordinate4{} L.Coordinate3{}:
      Inl{{==}}
    case L.Coordinate4{} L.Coordinate4{}:
      Inl{{==}}
    case L.Coordinate4{} L.Coordinate5{}:
      Inl{{==}}
    case L.Coordinate4{} L.Coordinate6{}:
      Inl{{==}}
    case L.Coordinate4{} L.Coordinate7{}:
      Inl{{==}}
    case L.Coordinate4{} L.Coordinate8{}:
      Inl{{==}}
    case L.Coordinate5{} L.Coordinate0{}:
      Inl{{==}}
    case L.Coordinate5{} L.Coordinate1{}:
      Inl{{==}}
    case L.Coordinate5{} L.Coordinate2{}:
      Inl{{==}}
    case L.Coordinate5{} L.Coordinate3{}:
      Inl{{==}}
    case L.Coordinate5{} L.Coordinate4{}:
      Inl{{==}}
    case L.Coordinate5{} L.Coordinate5{}:
      Inl{{==}}
    case L.Coordinate5{} L.Coordinate6{}:
      Inl{{==}}
    case L.Coordinate5{} L.Coordinate7{}:
      Inl{{==}}
    case L.Coordinate5{} L.Coordinate8{}:
      Inl{{==}}
    case L.Coordinate6{} L.Coordinate0{}:
      Inl{{==}}
    case L.Coordinate6{} L.Coordinate1{}:
      Inl{{==}}
    case L.Coordinate6{} L.Coordinate2{}:
      Inl{{==}}
    case L.Coordinate6{} L.Coordinate3{}:
      Inl{{==}}
    case L.Coordinate6{} L.Coordinate4{}:
      Inl{{==}}
    case L.Coordinate6{} L.Coordinate5{}:
      Inl{{==}}
    case L.Coordinate6{} L.Coordinate6{}:
      Inl{{==}}
    case L.Coordinate6{} L.Coordinate7{}:
      Inl{{==}}
    case L.Coordinate6{} L.Coordinate8{}:
      Inl{{==}}
    case L.Coordinate7{} L.Coordinate0{}:
      Inl{{==}}
    case L.Coordinate7{} L.Coordinate1{}:
      Inr{({==},{==})}
    case L.Coordinate7{} L.Coordinate2{}:
      Inr{({==},{==})}
    case L.Coordinate7{} L.Coordinate3{}:
      Inr{({==},{==})}
    case L.Coordinate7{} L.Coordinate4{}:
      Inr{({==},{==})}
    case L.Coordinate7{} L.Coordinate5{}:
      Inr{({==},{==})}
    case L.Coordinate7{} L.Coordinate6{}:
      Inr{({==},{==})}
    case L.Coordinate7{} L.Coordinate7{}:
      Inr{({==},{==})}
    case L.Coordinate7{} L.Coordinate8{}:
      Inr{({==},{==})}
    case L.Coordinate8{} L.Coordinate0{}:
      Inr{({==},{==})}
    case L.Coordinate8{} L.Coordinate1{}:
      Inr{({==},{==})}
    case L.Coordinate8{} L.Coordinate2{}:
      Inr{({==},{==})}
    case L.Coordinate8{} L.Coordinate3{}:
      Inr{({==},{==})}
    case L.Coordinate8{} L.Coordinate4{}:
      Inr{({==},{==})}
    case L.Coordinate8{} L.Coordinate5{}:
      Inr{({==},{==})}
    case L.Coordinate8{} L.Coordinate6{}:
      Inr{({==},{==})}
    case L.Coordinate8{} L.Coordinate7{}:
      Inr{({==},{==})}
    case L.Coordinate8{} L.Coordinate8{}:
      Inr{({==},{==})}

def L.flag_keeps_padding_same_slot(image,p,on,disjoint):
  +slot = L.flag_slot(p)
  +word = L.cell_value(L.image_board(image),slot)
  after = Q.flag(L.image_board(image),p,on)
  %Equal.sym(U32,L.cell_value(after,slot),L.flag_word(p,on,word),L.flag_writes_slot_word_image(image,p,on)) :
    {U32.and(4294836224,_) == U32.and(4294836224,word) : U32}
  L.flag_update_keeps_disjoint_watch_mask(p,4294836224,word,on,disjoint)

def L.flag_keeps_padding_image(image,p,on,shape,route):
  match route:
    case Inl{apart}:
      b = L.image_board(image)
      Equal.cong(U32,U32,x => U32.and(4294836224,x),L.cell_value(Q.flag(b,p,on),111),L.cell_value(b,111),
        L.flag_keeps_cell_image(image,p,on,111,shape,apart))
    case Inr{both}:
      (at_slot,disjoint) = both
      b = L.image_board(image)
      %at_slot :
        {U32.and(4294836224,L.cell_value(Q.flag(b,p,on),_)) == U32.and(4294836224,L.cell_value(b,_)) : U32}
      L.flag_keeps_padding_same_slot(image,p,on,disjoint)

def L.flag_keeps_padding(b,p,on):
  L.on_reified_board(b,x => L.FlagKeepsPadding(x,p,on),
    L.reify_board(b),image => L.flag_keeps_padding_image(image,p,on))

def L.actual_logical_flag_keeps_high_padding(b,row,col,on,shape):
  L.flag_keeps_padding(b,L.logical_position(row,col),on)(shape,L.logical_flag_padding_route(row,col))

def L.queue_seed_zeros_final_flag_slot(b):
  L.board_set_get(Board.set_cell(Board.set_cell(b,109,0),110,0),111,0)

def L.logical_write_apart_from_flag_padding(row,col):
  match row col:
    case L.Coordinate0{} L.Coordinate0{}:
      {==}
    case L.Coordinate0{} L.Coordinate1{}:
      {==}
    case L.Coordinate0{} L.Coordinate2{}:
      {==}
    case L.Coordinate0{} L.Coordinate3{}:
      {==}
    case L.Coordinate0{} L.Coordinate4{}:
      {==}
    case L.Coordinate0{} L.Coordinate5{}:
      {==}
    case L.Coordinate0{} L.Coordinate6{}:
      {==}
    case L.Coordinate0{} L.Coordinate7{}:
      {==}
    case L.Coordinate0{} L.Coordinate8{}:
      {==}
    case L.Coordinate1{} L.Coordinate0{}:
      {==}
    case L.Coordinate1{} L.Coordinate1{}:
      {==}
    case L.Coordinate1{} L.Coordinate2{}:
      {==}
    case L.Coordinate1{} L.Coordinate3{}:
      {==}
    case L.Coordinate1{} L.Coordinate4{}:
      {==}
    case L.Coordinate1{} L.Coordinate5{}:
      {==}
    case L.Coordinate1{} L.Coordinate6{}:
      {==}
    case L.Coordinate1{} L.Coordinate7{}:
      {==}
    case L.Coordinate1{} L.Coordinate8{}:
      {==}
    case L.Coordinate2{} L.Coordinate0{}:
      {==}
    case L.Coordinate2{} L.Coordinate1{}:
      {==}
    case L.Coordinate2{} L.Coordinate2{}:
      {==}
    case L.Coordinate2{} L.Coordinate3{}:
      {==}
    case L.Coordinate2{} L.Coordinate4{}:
      {==}
    case L.Coordinate2{} L.Coordinate5{}:
      {==}
    case L.Coordinate2{} L.Coordinate6{}:
      {==}
    case L.Coordinate2{} L.Coordinate7{}:
      {==}
    case L.Coordinate2{} L.Coordinate8{}:
      {==}
    case L.Coordinate3{} L.Coordinate0{}:
      {==}
    case L.Coordinate3{} L.Coordinate1{}:
      {==}
    case L.Coordinate3{} L.Coordinate2{}:
      {==}
    case L.Coordinate3{} L.Coordinate3{}:
      {==}
    case L.Coordinate3{} L.Coordinate4{}:
      {==}
    case L.Coordinate3{} L.Coordinate5{}:
      {==}
    case L.Coordinate3{} L.Coordinate6{}:
      {==}
    case L.Coordinate3{} L.Coordinate7{}:
      {==}
    case L.Coordinate3{} L.Coordinate8{}:
      {==}
    case L.Coordinate4{} L.Coordinate0{}:
      {==}
    case L.Coordinate4{} L.Coordinate1{}:
      {==}
    case L.Coordinate4{} L.Coordinate2{}:
      {==}
    case L.Coordinate4{} L.Coordinate3{}:
      {==}
    case L.Coordinate4{} L.Coordinate4{}:
      {==}
    case L.Coordinate4{} L.Coordinate5{}:
      {==}
    case L.Coordinate4{} L.Coordinate6{}:
      {==}
    case L.Coordinate4{} L.Coordinate7{}:
      {==}
    case L.Coordinate4{} L.Coordinate8{}:
      {==}
    case L.Coordinate5{} L.Coordinate0{}:
      {==}
    case L.Coordinate5{} L.Coordinate1{}:
      {==}
    case L.Coordinate5{} L.Coordinate2{}:
      {==}
    case L.Coordinate5{} L.Coordinate3{}:
      {==}
    case L.Coordinate5{} L.Coordinate4{}:
      {==}
    case L.Coordinate5{} L.Coordinate5{}:
      {==}
    case L.Coordinate5{} L.Coordinate6{}:
      {==}
    case L.Coordinate5{} L.Coordinate7{}:
      {==}
    case L.Coordinate5{} L.Coordinate8{}:
      {==}
    case L.Coordinate6{} L.Coordinate0{}:
      {==}
    case L.Coordinate6{} L.Coordinate1{}:
      {==}
    case L.Coordinate6{} L.Coordinate2{}:
      {==}
    case L.Coordinate6{} L.Coordinate3{}:
      {==}
    case L.Coordinate6{} L.Coordinate4{}:
      {==}
    case L.Coordinate6{} L.Coordinate5{}:
      {==}
    case L.Coordinate6{} L.Coordinate6{}:
      {==}
    case L.Coordinate6{} L.Coordinate7{}:
      {==}
    case L.Coordinate6{} L.Coordinate8{}:
      {==}
    case L.Coordinate7{} L.Coordinate0{}:
      {==}
    case L.Coordinate7{} L.Coordinate1{}:
      {==}
    case L.Coordinate7{} L.Coordinate2{}:
      {==}
    case L.Coordinate7{} L.Coordinate3{}:
      {==}
    case L.Coordinate7{} L.Coordinate4{}:
      {==}
    case L.Coordinate7{} L.Coordinate5{}:
      {==}
    case L.Coordinate7{} L.Coordinate6{}:
      {==}
    case L.Coordinate7{} L.Coordinate7{}:
      {==}
    case L.Coordinate7{} L.Coordinate8{}:
      {==}
    case L.Coordinate8{} L.Coordinate0{}:
      {==}
    case L.Coordinate8{} L.Coordinate1{}:
      {==}
    case L.Coordinate8{} L.Coordinate2{}:
      {==}
    case L.Coordinate8{} L.Coordinate3{}:
      {==}
    case L.Coordinate8{} L.Coordinate4{}:
      {==}
    case L.Coordinate8{} L.Coordinate5{}:
      {==}
    case L.Coordinate8{} L.Coordinate6{}:
      {==}
    case L.Coordinate8{} L.Coordinate7{}:
      {==}
    case L.Coordinate8{} L.Coordinate8{}:
      {==}

def L.changed_flag_keeps_padding(b,p,needed):
  match needed:
    case False{}:
      shape => route => {==}
    case True{}:
      L.flag_keeps_padding(b,p,True{})

def L.changed_write_keeps_padding_yes(image,p,old,bit,shapes,apart,route):
  (s0,s1) = shapes
  +candidate = L.peer_mask(old,bit)
  b = L.image_board(image)
  written = Board.set_cell(L.image_board(image),p,candidate)
  Equal.trans(U32,L.high_flag_padding(Q.changed(True{},p,bit,b,old)),L.high_flag_padding(written),L.high_flag_padding(b),
    L.changed_flag_keeps_padding(written,p,L.peer_reflag(old,bit))(
      L.board_set_keeps_perfect(L.image_board(image),p,candidate,7n,s0),route),
    Equal.cong(U32,U32,x => U32.and(4294836224,x),L.cell_value(written,111),L.cell_value(b,111),
      L.perfect_write_keeps_cell(L.image_board(image),p,111,candidate,s1,apart)))

def L.changed_write_keeps_padding_image(image,needed,p,old,bit,shape,apart,route):
  match needed:
    case False{}:
      {==}
    case True{}:
      L.changed_write_keeps_padding_yes(image,p,old,bit,
        L.copy_shape_proof(L.array_shape(L.image_board(image)),L.perfect_shape(7n),shape),apart,route)

def L.actual_peer_keeps_padding_image(image,p,bit,shape,apart,route):
  b = L.image_board(image)
  +old = L.cell_value(L.image_board(image),p)
  +needed = U32.is_ne(U32.and(old,bit),0)
  %Equal.sym(Array<U32>,L.actual_peer(b,p,bit),Q.changed(needed,p,bit,b,old),
    L.peer_normalized(b,p,bit,L.board_read_witness(L.image_board(image),p))) :
    {L.high_flag_padding(_) == L.high_flag_padding(b) : U32}
  L.changed_write_keeps_padding_image(image,needed,p,old,bit,shape,apart,route)

def L.actual_peer_keeps_padding(b,p,bit):
  L.on_reified_board(b,x => L.PeerKeepsPadding(x,p,bit),
    L.reify_board(b),image => L.actual_peer_keeps_padding_image(image,p,bit))

def L.logical_peer_keeps_flag_padding(b,row,col,bit,shape):
  L.actual_peer_keeps_padding(b,L.logical_position(row,col),bit)(
    shape,L.logical_write_apart_from_flag_padding(row,col),L.logical_flag_padding_route(row,col))

def L.flag_keeps_other_shared_slot(image,p,q,on,disjoint):
  +slot = L.flag_slot(p)
  +word = L.cell_value(L.image_board(image),slot)
  +watch = L.own_queue_flag_mask(q)
  after = Q.flag(L.image_board(image),p,on)
  %Equal.sym(U32,L.cell_value(after,slot),L.flag_word(p,on,word),L.flag_writes_slot_word_image(image,p,on)) :
    {L.queue_flag_present(q,_) == L.queue_flag_present(q,word) : Bool}
  Equal.cong(U32,Bool,w => U32.is_ne(w,0),U32.and(watch,L.flag_word(p,on,word)),U32.and(watch,word),
    L.flag_update_keeps_disjoint_watch_mask(p,watch,word,on,disjoint))

def L.flag_keeps_other_image(image,p,q,on,shape,route):
  match route:
    case Inl{apart}:
      b = L.image_board(image)
      +slot = L.flag_slot(q)
      Equal.cong(U32,Bool,w => L.queue_flag_present(q,w),L.cell_value(Q.flag(b,p,on),slot),L.cell_value(b,slot),
        L.flag_keeps_cell_image(image,p,on,slot,shape,apart))
    case Inr{both}:
      (same,disjoint) = both
      b = L.image_board(image)
      %same :
        {L.queue_flag_present(q,L.cell_value(Q.flag(b,p,on),_)) == L.queue_flag_present(q,L.cell_value(b,_)) : Bool}
      L.flag_keeps_other_shared_slot(image,p,q,on,disjoint)

def L.actual_flag_keeps_other(b,p,q,on):
  L.on_reified_board(b,x => L.FlagKeepsOther(x,p,q,on),
    L.reify_board(b),image => L.flag_keeps_other_image(image,p,q,on))

def L.changed_flag_keeps_other(b,p,q,needed):
  match needed:
    case False{}:
      shape => route => {==}
    case True{}:
      L.actual_flag_keeps_other(b,p,q,True{})

def L.peer_write_keeps_other_flag_yes(image,p,q,old,bit,shapes,apart,route):
  (s0,s1) = shapes
  +slot = L.flag_slot(q)
  +candidate = L.peer_mask(old,bit)
  b = L.image_board(image)
  written = Board.set_cell(L.image_board(image),p,candidate)
  Equal.trans(Bool,L.actual_flag_at(Q.changed(True{},p,bit,b,old),q),L.actual_flag_at(written,q),L.actual_flag_at(b,q),
    L.changed_flag_keeps_other(written,p,q,L.peer_reflag(old,bit))(
      L.board_set_keeps_perfect(L.image_board(image),p,candidate,7n,s0),route),
    Equal.cong(U32,Bool,w => L.queue_flag_present(q,w),L.cell_value(written,slot),L.cell_value(b,slot),
      L.perfect_write_keeps_cell(L.image_board(image),p,slot,candidate,s1,apart)))

def L.peer_write_keeps_other_flag_image(image,needed,p,q,old,bit,shape,apart,route):
  match needed:
    case False{}:
      {==}
    case True{}:
      L.peer_write_keeps_other_flag_yes(image,p,q,old,bit,
        L.copy_shape_proof(L.array_shape(L.image_board(image)),L.perfect_shape(7n),shape),apart,route)

def L.actual_peer_keeps_other_flag_image(image,p,q,bit,shape,apart,route):
  b = L.image_board(image)
  +old = L.cell_value(L.image_board(image),p)
  +needed = U32.is_ne(U32.and(old,bit),0)
  %Equal.sym(Array<U32>,L.actual_peer(b,p,bit),Q.changed(needed,p,bit,b,old),
    L.peer_normalized(b,p,bit,L.board_read_witness(L.image_board(image),p))) :
    {L.actual_flag_at(_,q) == L.actual_flag_at(b,q) : Bool}
  L.peer_write_keeps_other_flag_image(image,needed,p,q,old,bit,shape,apart,route)

def L.actual_peer_keeps_other_flag(b,p,q,bit):
  L.on_reified_board(b,x => L.PeerKeepsOtherFlag(x,p,q,bit),
    L.reify_board(b),image => L.actual_peer_keeps_other_flag_image(image,p,q,bit))

def L.occupancy_not_written_routes(band,index):
  match band index:
    case L.CacheRows{} L.Coordinate0{}:
      ({==},({==},({==},L.encode_routes_from_sweep(81n,0,L.cache_group_slot(L.CacheRows{},L.Coordinate0{}),L.sweep_witnesses(81n,0,L.cache_group_slot(L.CacheRows{},L.Coordinate0{}),{==})))))
    case L.CacheRows{} L.Coordinate1{}:
      ({==},({==},({==},L.encode_routes_from_sweep(81n,0,L.cache_group_slot(L.CacheRows{},L.Coordinate1{}),L.sweep_witnesses(81n,0,L.cache_group_slot(L.CacheRows{},L.Coordinate1{}),{==})))))
    case L.CacheRows{} L.Coordinate2{}:
      ({==},({==},({==},L.encode_routes_from_sweep(81n,0,L.cache_group_slot(L.CacheRows{},L.Coordinate2{}),L.sweep_witnesses(81n,0,L.cache_group_slot(L.CacheRows{},L.Coordinate2{}),{==})))))
    case L.CacheRows{} L.Coordinate3{}:
      ({==},({==},({==},L.encode_routes_from_sweep(81n,0,L.cache_group_slot(L.CacheRows{},L.Coordinate3{}),L.sweep_witnesses(81n,0,L.cache_group_slot(L.CacheRows{},L.Coordinate3{}),{==})))))
    case L.CacheRows{} L.Coordinate4{}:
      ({==},({==},({==},L.encode_routes_from_sweep(81n,0,L.cache_group_slot(L.CacheRows{},L.Coordinate4{}),L.sweep_witnesses(81n,0,L.cache_group_slot(L.CacheRows{},L.Coordinate4{}),{==})))))
    case L.CacheRows{} L.Coordinate5{}:
      ({==},({==},({==},L.encode_routes_from_sweep(81n,0,L.cache_group_slot(L.CacheRows{},L.Coordinate5{}),L.sweep_witnesses(81n,0,L.cache_group_slot(L.CacheRows{},L.Coordinate5{}),{==})))))
    case L.CacheRows{} L.Coordinate6{}:
      ({==},({==},({==},L.encode_routes_from_sweep(81n,0,L.cache_group_slot(L.CacheRows{},L.Coordinate6{}),L.sweep_witnesses(81n,0,L.cache_group_slot(L.CacheRows{},L.Coordinate6{}),{==})))))
    case L.CacheRows{} L.Coordinate7{}:
      ({==},({==},({==},L.encode_routes_from_sweep(81n,0,L.cache_group_slot(L.CacheRows{},L.Coordinate7{}),L.sweep_witnesses(81n,0,L.cache_group_slot(L.CacheRows{},L.Coordinate7{}),{==})))))
    case L.CacheRows{} L.Coordinate8{}:
      ({==},({==},({==},L.encode_routes_from_sweep(81n,0,L.cache_group_slot(L.CacheRows{},L.Coordinate8{}),L.sweep_witnesses(81n,0,L.cache_group_slot(L.CacheRows{},L.Coordinate8{}),{==})))))
    case L.CacheColumns{} L.Coordinate0{}:
      ({==},({==},({==},L.encode_routes_from_sweep(81n,0,L.cache_group_slot(L.CacheColumns{},L.Coordinate0{}),L.sweep_witnesses(81n,0,L.cache_group_slot(L.CacheColumns{},L.Coordinate0{}),{==})))))
    case L.CacheColumns{} L.Coordinate1{}:
      ({==},({==},({==},L.encode_routes_from_sweep(81n,0,L.cache_group_slot(L.CacheColumns{},L.Coordinate1{}),L.sweep_witnesses(81n,0,L.cache_group_slot(L.CacheColumns{},L.Coordinate1{}),{==})))))
    case L.CacheColumns{} L.Coordinate2{}:
      ({==},({==},({==},L.encode_routes_from_sweep(81n,0,L.cache_group_slot(L.CacheColumns{},L.Coordinate2{}),L.sweep_witnesses(81n,0,L.cache_group_slot(L.CacheColumns{},L.Coordinate2{}),{==})))))
    case L.CacheColumns{} L.Coordinate3{}:
      ({==},({==},({==},L.encode_routes_from_sweep(81n,0,L.cache_group_slot(L.CacheColumns{},L.Coordinate3{}),L.sweep_witnesses(81n,0,L.cache_group_slot(L.CacheColumns{},L.Coordinate3{}),{==})))))
    case L.CacheColumns{} L.Coordinate4{}:
      ({==},({==},({==},L.encode_routes_from_sweep(81n,0,L.cache_group_slot(L.CacheColumns{},L.Coordinate4{}),L.sweep_witnesses(81n,0,L.cache_group_slot(L.CacheColumns{},L.Coordinate4{}),{==})))))
    case L.CacheColumns{} L.Coordinate5{}:
      ({==},({==},({==},L.encode_routes_from_sweep(81n,0,L.cache_group_slot(L.CacheColumns{},L.Coordinate5{}),L.sweep_witnesses(81n,0,L.cache_group_slot(L.CacheColumns{},L.Coordinate5{}),{==})))))
    case L.CacheColumns{} L.Coordinate6{}:
      ({==},({==},({==},L.encode_routes_from_sweep(81n,0,L.cache_group_slot(L.CacheColumns{},L.Coordinate6{}),L.sweep_witnesses(81n,0,L.cache_group_slot(L.CacheColumns{},L.Coordinate6{}),{==})))))
    case L.CacheColumns{} L.Coordinate7{}:
      ({==},({==},({==},L.encode_routes_from_sweep(81n,0,L.cache_group_slot(L.CacheColumns{},L.Coordinate7{}),L.sweep_witnesses(81n,0,L.cache_group_slot(L.CacheColumns{},L.Coordinate7{}),{==})))))
    case L.CacheColumns{} L.Coordinate8{}:
      ({==},({==},({==},L.encode_routes_from_sweep(81n,0,L.cache_group_slot(L.CacheColumns{},L.Coordinate8{}),L.sweep_witnesses(81n,0,L.cache_group_slot(L.CacheColumns{},L.Coordinate8{}),{==})))))
    case L.CacheBoxes{} L.Coordinate0{}:
      ({==},({==},({==},L.encode_routes_from_sweep(81n,0,L.cache_group_slot(L.CacheBoxes{},L.Coordinate0{}),L.sweep_witnesses(81n,0,L.cache_group_slot(L.CacheBoxes{},L.Coordinate0{}),{==})))))
    case L.CacheBoxes{} L.Coordinate1{}:
      ({==},({==},({==},L.encode_routes_from_sweep(81n,0,L.cache_group_slot(L.CacheBoxes{},L.Coordinate1{}),L.sweep_witnesses(81n,0,L.cache_group_slot(L.CacheBoxes{},L.Coordinate1{}),{==})))))
    case L.CacheBoxes{} L.Coordinate2{}:
      ({==},({==},({==},L.encode_routes_from_sweep(81n,0,L.cache_group_slot(L.CacheBoxes{},L.Coordinate2{}),L.sweep_witnesses(81n,0,L.cache_group_slot(L.CacheBoxes{},L.Coordinate2{}),{==})))))
    case L.CacheBoxes{} L.Coordinate3{}:
      ({==},({==},({==},L.encode_routes_from_sweep(81n,0,L.cache_group_slot(L.CacheBoxes{},L.Coordinate3{}),L.sweep_witnesses(81n,0,L.cache_group_slot(L.CacheBoxes{},L.Coordinate3{}),{==})))))
    case L.CacheBoxes{} L.Coordinate4{}:
      ({==},({==},({==},L.encode_routes_from_sweep(81n,0,L.cache_group_slot(L.CacheBoxes{},L.Coordinate4{}),L.sweep_witnesses(81n,0,L.cache_group_slot(L.CacheBoxes{},L.Coordinate4{}),{==})))))
    case L.CacheBoxes{} L.Coordinate5{}:
      ({==},({==},({==},L.encode_routes_from_sweep(81n,0,L.cache_group_slot(L.CacheBoxes{},L.Coordinate5{}),L.sweep_witnesses(81n,0,L.cache_group_slot(L.CacheBoxes{},L.Coordinate5{}),{==})))))
    case L.CacheBoxes{} L.Coordinate6{}:
      ({==},({==},({==},L.encode_routes_from_sweep(81n,0,L.cache_group_slot(L.CacheBoxes{},L.Coordinate6{}),L.sweep_witnesses(81n,0,L.cache_group_slot(L.CacheBoxes{},L.Coordinate6{}),{==})))))
    case L.CacheBoxes{} L.Coordinate7{}:
      ({==},({==},({==},L.encode_routes_from_sweep(81n,0,L.cache_group_slot(L.CacheBoxes{},L.Coordinate7{}),L.sweep_witnesses(81n,0,L.cache_group_slot(L.CacheBoxes{},L.Coordinate7{}),{==})))))
    case L.CacheBoxes{} L.Coordinate8{}:
      ({==},({==},({==},L.encode_routes_from_sweep(81n,0,L.cache_group_slot(L.CacheBoxes{},L.Coordinate8{}),L.sweep_witnesses(81n,0,L.cache_group_slot(L.CacheBoxes{},L.Coordinate8{}),{==})))))

def L.encode_keeps_protected_word_parts(image,q,shapes,routes):
  (s0,s1) = shapes
  (r9,(r10,(r11,walk))) = routes
  Equal.trans(U32,L.cell_value(Q.encode(L.image_board(image)),q),
    L.cell_value(L.queue_seed(L.image_board(image)),q),L.cell_value(L.image_board(image),q),
    L.encode_sweep_keeps(81n,0,q,L.queue_seed(L.image_board(image)),
      L.queue_seed_perfect(L.image_board(image),s0),walk),
    L.queue_seed_keeps_cell(L.image_board(image),q)(s1,r9,r10,r11))

def L.encode_keeps_protected_word_image(image,q,shape):
  L.encode_keeps_protected_word_parts(image,q,
    L.copy_shape_proof(L.array_shape(L.image_board(image)),L.perfect_shape(7n),shape))

def L.encode_keeps_protected_word(b,q):
  L.on_reified_board(b,x => L.EncodeKeepsWord(x,q),
    L.reify_board(b),image => L.encode_keeps_protected_word_image(image,q))

def L.queued_encode_keeps_ordinary_occupancy(b,band,index,shape):
  L.encode_keeps_protected_word(b,L.cache_group_slot(band,index))(shape,L.occupancy_not_written_routes(band,index))

def L.encode_routes_prefix(n,remaining,p,q,whole):
  match n:
    case 0n:
      {==}
    case 1n+k:
      (cell,(flag,tail)) = whole
      (cell,(flag,L.encode_routes_prefix(k,remaining,(p + 1 : U32),q,tail)))

def L.encode_keeps_seeded_prefix_routes(image,n,q,shapes,r9,r10,r11,prefix):
  (s0,s1) = shapes
  Equal.trans(U32,L.cell_value(Q.encode_go(n,0,L.queue_seed(L.image_board(image))),q),
    L.cell_value(L.queue_seed(L.image_board(image)),q),L.cell_value(L.image_board(image),q),
    L.encode_sweep_keeps(n,0,q,L.queue_seed(L.image_board(image)),
      L.queue_seed_perfect(L.image_board(image),s0),prefix),
    L.queue_seed_keeps_cell(L.image_board(image),q)(s1,r9,r10,r11))

def L.encode_routes_prefix_from_total(n,remaining,q,sweep,whole):
  f : (L.EncodeApart(81n,0,q) -> L.EncodeApart(n,0,q)) =
    %sweep : (L.EncodeApart(_,0,q) -> L.EncodeApart(n,0,q))
    full => L.encode_routes_prefix(n,remaining,0,q,full)
  f(whole)

def L.encode_protected_prefix_image(image,n,remaining,q,shape,routes,sweep):
  (r9,(r10,(r11,walk))) = routes
  L.encode_keeps_seeded_prefix_routes(image,n,q,
    L.copy_shape_proof(L.array_shape(L.image_board(image)),L.perfect_shape(7n),shape),
    r9,r10,r11,L.encode_routes_prefix_from_total(n,remaining,q,sweep,walk))

def L.encoded_prefix_from_seed_keeps_occupancy(b,n,remaining,band,index,shape,sweep):
  +q = L.cache_group_slot(band,index)
  f : (L.Board128(b) -> {Nat.add(n,remaining) == 81n : Nat} ->
    {L.cell_value(Q.encode_go(n,0,L.queue_seed(b)),q) == L.cell_value(b,q) : U32}) =
    L.on_reified_board(b,x => (L.Board128(x) -> {Nat.add(n,remaining) == 81n : Nat} ->
      {L.cell_value(Q.encode_go(n,0,L.queue_seed(x)),q) == L.cell_value(x,q) : U32}),
      L.reify_board(b),image => s => eq => L.encode_protected_prefix_image(image,n,remaining,q,s,
        L.occupancy_not_written_routes(band,index),eq))
  f(shape,sweep)

def L.cached_read_exact_parts(b,p,same,value,kept,read):
  %Equal.sym(Array<U32> & U32,Board.get_cell(b,p),(same,value),read) :
    {_ == (b,Pair.snd(Array<U32>,U32,_)) : Array<U32> & U32}
  %Equal.sym(Array<U32>,same,b,kept) :
    {(_,value) == (b,value) : Array<U32> & U32}
  {==}

def L.cached_read_exact(b,p,read):
  (same,+value,(kept,seen)) = read
  L.cached_read_exact_parts(b,p,same,value,kept,seen)

def L.cached_add_exact_image(image,p,used):
  b = L.image_board(image)
  +value = L.cell_value(L.image_board(image),p)
  %Equal.sym(Array<U32> & U32,Board.get_cell(b,p),(b,value),
    L.cached_read_exact(L.image_board(image),p,L.board_read_witness(L.image_board(image),p))) :
    {C.cached_merge(used,_) == (b,U32.or(used,value)) : Array<U32> & U32}
  {==}

def L.cached_candidates_are_occupancy_image(image,p):
  b = L.image_board(image)
  +r = L.ordinary_row_slot(p)
  +c = L.ordinary_col_slot(p)
  +k = L.ordinary_box_slot(p)
  +row_bits = L.cell_value(L.image_board(image),r)
  +col_bits = L.cell_value(L.image_board(image),c)
  +box_bits = L.cell_value(L.image_board(image),k)
  %Equal.sym(Array<U32> & U32,Board.get_cell(b,r),(b,row_bits),
    L.cached_read_exact(L.image_board(image),r,L.board_read_witness(L.image_board(image),r))) :
    {Pair.snd(Array<U32>,U32,C.invert(C.cached_add(k,C.cached_add(c,_)))) ==
      L.occupancy_candidate_mask(row_bits,col_bits,box_bits) : U32}
  %Equal.sym(Array<U32> & U32,C.cached_add(c,(b,row_bits)),(b,U32.or(row_bits,col_bits)),
    L.cached_add_exact_image(image,c,row_bits)) :
    {Pair.snd(Array<U32>,U32,C.invert(C.cached_add(k,_))) == L.occupancy_candidate_mask(row_bits,col_bits,box_bits) : U32}
  %Equal.sym(Array<U32> & U32,C.cached_add(k,(b,U32.or(row_bits,col_bits))),(b,U32.or(U32.or(row_bits,col_bits),box_bits)),
    L.cached_add_exact_image(image,k,U32.or(row_bits,col_bits))) :
    {Pair.snd(Array<U32>,U32,C.invert(_)) == L.occupancy_candidate_mask(row_bits,col_bits,box_bits) : U32}
  {==}

def L.cached_word_same_occupancy(new,old,p,same):
  (er,(ec,eb)) = same
  a = L.image_board(new)
  b = L.image_board(old)
  +rp = L.ordinary_row_slot(p)
  +cp = L.ordinary_col_slot(p)
  +bp = L.ordinary_box_slot(p)
  +ar = L.cell_value(L.image_board(new),rp)
  +ac = L.cell_value(L.image_board(new),cp)
  +ab = L.cell_value(L.image_board(new),bp)
  +br = L.cell_value(L.image_board(old),rp)
  +bc = L.cell_value(L.image_board(old),cp)
  +bb = L.cell_value(L.image_board(old),bp)
  %Equal.sym(U32,L.cached_word(a,p),L.occupancy_candidate_mask(ar,ac,ab),L.cached_candidates_are_occupancy_image(new,p)) :
    {_ == L.cached_word(b,p) : U32}
  %Equal.sym(U32,L.cached_word(b,p),L.occupancy_candidate_mask(br,bc,bb),L.cached_candidates_are_occupancy_image(old,p)) :
    {L.occupancy_candidate_mask(ar,ac,ab) == _ : U32}
  %Equal.sym(U32,ar,br,er) :
    {L.occupancy_candidate_mask(_,ac,ab) == L.occupancy_candidate_mask(br,bc,bb) : U32}
  %Equal.sym(U32,ac,bc,ec) :
    {L.occupancy_candidate_mask(br,_,ab) == L.occupancy_candidate_mask(br,bc,bb) : U32}
  %Equal.sym(U32,ab,bb,eb) :
    {L.occupancy_candidate_mask(br,bc,_) == L.occupancy_candidate_mask(br,bc,bb) : U32}
  {==}

def L.encode_prefix_holds_cache_read_parts(image,n,remaining,row,col,shapes,sweeps,geometry):
  (s0,(s1,s2)) = shapes
  (e0,(e1,e2)) = sweeps
  (gr,(gc,gb)) = geometry
  b = L.image_board(image)
  out = L.seeded_encode_prefix(n,L.image_board(image))
  +p = L.logical_position(row,col)
  +rr = L.cache_group_slot(L.CacheRows{},row)
  +cc = L.cache_group_slot(L.CacheColumns{},col)
  +bx = L.box_coordinate(row,col)
  +kk = L.cache_group_slot(L.CacheBoxes{},bx)
  %Equal.sym(U32,L.ordinary_row_slot(p),rr,gr) :
    ({L.cell_value(out,_) == L.cell_value(b,_) : U32} & {L.cell_value(out,L.ordinary_col_slot(p)) == L.cell_value(b,L.ordinary_col_slot(p)) : U32} &
     {L.cell_value(out,L.ordinary_box_slot(p)) == L.cell_value(b,L.ordinary_box_slot(p)) : U32})
  %Equal.sym(U32,L.ordinary_col_slot(p),cc,gc) :
    ({L.cell_value(out,rr) == L.cell_value(b,rr) : U32} & {L.cell_value(out,_) == L.cell_value(b,_) : U32} &
     {L.cell_value(out,L.ordinary_box_slot(p)) == L.cell_value(b,L.ordinary_box_slot(p)) : U32})
  %Equal.sym(U32,L.ordinary_box_slot(p),kk,gb) :
    ({L.cell_value(out,rr) == L.cell_value(b,rr) : U32} & {L.cell_value(out,cc) == L.cell_value(b,cc) : U32} &
     {L.cell_value(out,_) == L.cell_value(b,_) : U32})
  (L.encoded_prefix_from_seed_keeps_occupancy(L.image_board(image),n,remaining,L.CacheRows{},row,s0,e0),
   (L.encoded_prefix_from_seed_keeps_occupancy(L.image_board(image),n,remaining,L.CacheColumns{},col,s1,e1),
    L.encoded_prefix_from_seed_keeps_occupancy(L.image_board(image),n,remaining,L.CacheBoxes{},bx,s2,e2)))

def L.copy_nat_eq(a,b,same):
  %same : ({a == _ : Nat} & {a == _ : Nat} & {a == _ : Nat})
  ({==},({==},{==}))

def L.encoded_prefix_keeps_cached_candidate_image(image,n,remaining,row,col,shape,sweep):
  +p = L.logical_position(row,col)
  b = L.image_board(image)
  out = L.seeded_encode_prefix(n,L.image_board(image))
  f : (L.SameOccupancyAt(out,b,p) -> {L.cached_word(out,p) == L.cached_word(b,p) : U32}) =
    L.on_reified_board(out,x => (L.SameOccupancyAt(x,b,p) -> {L.cached_word(x,p) == L.cached_word(b,p) : U32}),
      L.reify_board(L.seeded_encode_prefix(n,L.image_board(image))),next => inp => L.cached_word_same_occupancy(next,image,p,inp))
  f(L.encode_prefix_holds_cache_read_parts(image,n,remaining,row,col,
    L.copy_shape_three(L.array_shape(L.image_board(image)),L.perfect_shape(7n),shape),
    L.copy_nat_eq(Nat.add(n,remaining),81n,sweep),L.checked_ordinary_geometry(row,col)))

def L.actual_encoded_prefix_keeps_cached_candidate(b,n,remaining,row,col):
  L.on_reified_board(b,x => L.EncodeKeepsCacheSource(x,n,remaining,row,col),
    L.reify_board(b),image => L.encoded_prefix_keeps_cached_candidate_image(image,n,remaining,row,col))

def L.encode_go_split_at_prefix(prefix,suffix,start,b):
  match prefix:
    case 0n:
      {==}
    case 1n+k:
      L.encode_go_split_at_prefix(k,suffix,(start + 1 : U32),L.actual_encoded_step(b,start))

def L.encoded_blank_is_exact_cached_word_image(image,p,shape,apart):
  b = L.image_board(image)
  +word = L.cached_word(L.image_board(image),p)
  %Equal.sym(Array<U32>,Q.encoded(p,(b,0)),Q.encoded_mask(p,(b,word)),
    L.encoded_blank_normalized(b,p,L.cached_at_observed(L.image_board(image),p))) :
    {L.cell_value(_,p) == word : U32}
  L.encoded_mask_writes_cell(L.image_board(image),p,word)(shape,apart)

def L.actual_encode_blank_exact_cache_image(image,p,shape,apart,zero):
  b = L.image_board(image)
  +word = L.cell_value(L.image_board(image),p)
  %Equal.sym(Array<U32>,L.actual_encoded_step(b,p),Q.encoded(p,(b,word)),
    L.encode_step_normalized(b,p,L.board_read_witness(L.image_board(image),p))) :
    {L.cell_value(_,p) == L.cached_word(b,p) : U32}
  %Equal.sym(U32,word,0,zero) :
    {L.cell_value(Q.encoded(p,(b,_)),p) == L.cached_word(b,p) : U32}
  L.encoded_blank_is_exact_cached_word_image(image,p,shape,apart)

def L.actual_encode_blank_exact_cache(b,p):
  L.on_reified_board(b,x => L.EncodeBlankIsExactCache(x,p),
    L.reify_board(b),image => L.actual_encode_blank_exact_cache_image(image,p))

def L.full_queue_encode_as_local_step(prefix,suffix,b,total):
  %total : {Q.encode_go(_,0,L.queue_seed(b)) == Q.encode_go(suffix,(L.walk_position(prefix,0) + 1 : U32),
    L.actual_encoded_step(L.seeded_encode_prefix(prefix,b),L.walk_position(prefix,0))) : Array<U32>}
  L.encode_go_split_at_prefix(prefix,1n+suffix,0,L.queue_seed(b))

def L.with_center_is_add(prefix,suffix):
  match prefix:
    case 0n:
      {==}
    case 1n+k:
      Equal.cong(Nat,Nat,n => 1n+n,L.with_center(k,suffix),Nat.add(k,1n+suffix),L.with_center_is_add(k,suffix))

def L.checked_center_total(prefix,suffix,count):
  Equal.trans(Nat,Nat.add(prefix,1n+suffix),L.with_center(prefix,suffix),81n,
    Equal.sym(Nat,L.with_center(prefix,suffix),Nat.add(prefix,1n+suffix),L.with_center_is_add(prefix,suffix)),count)

def L.full_queue_encoded_blank_final_reads(image,row,col,count,shapes,safe,after,blank,cache):
  (s0,s1) = shapes
  +n = L.logical_offset(row,col)
  +m = L.logical_tail(row,col)
  +p = L.logical_position(row,col)
  b = L.image_board(image)
  mid = L.encode_seeded_logical_prefix(row,col,L.image_board(image))
  one = L.actual_encoded_step(L.encode_seeded_logical_prefix(row,col,L.image_board(image)),p)
  final = Q.encode_go(m,(p + 1 : U32),one)
  %Equal.sym(Array<U32>,Q.encode(b),final,L.full_queue_encode_as_local_step(n,m,L.image_board(image),count)) :
    {L.cell_value(_,p) == L.cached_word(b,p) : U32}
  Equal.trans(U32,L.cell_value(final,p),L.cell_value(one,p),L.cached_word(b,p),
    L.encode_sweep_keeps(m,(p + 1 : U32),p,L.actual_encoded_step(L.encode_seeded_logical_prefix(row,col,L.image_board(image)),p),
      L.actual_encode_step_keeps_perfect(L.encode_seeded_logical_prefix(row,col,L.image_board(image)),p,s0),after),
    Equal.trans(U32,L.cell_value(one,p),L.cached_word(mid,p),L.cached_word(b,p),
      L.actual_encode_blank_exact_cache(L.encode_seeded_logical_prefix(row,col,L.image_board(image)),p)(s1,safe,blank),cache))

def L.full_queue_encoded_blank_core(image,row,col,count,shape,safe,after,blank,cache):
  L.full_queue_encoded_blank_final_reads(image,row,col,count,
    L.copy_shape_proof(L.array_shape(L.encode_seeded_logical_prefix(row,col,L.image_board(image))),L.perfect_shape(7n),shape),
    safe,after,blank,cache)

def L.full_queue_encoded_blank_with_routes(image,row,col,shapes,counts,routes,blank):
  (s0,(s1,(s2,s3))) = shapes
  (c0,(c1,c2)) = counts
  (r9,(r10,(r11,(safe,((ep,dp),(es,ds)))))) = routes
  +n = L.logical_offset(row,col)
  +m = L.logical_tail(row,col)
  +p = L.logical_position(row,col)
  L.full_queue_encoded_blank_core(image,row,col,c0,
    L.encode_sweep_keeps_perfect(L.queue_seed(L.image_board(image)),n,0,L.queue_seed_perfect(L.image_board(image),s0)),safe,es,
    Equal.trans(U32,L.cell_value(L.encode_seeded_logical_prefix(row,col,L.image_board(image)),p),L.cell_value(L.image_board(image),p),0,
      L.encode_keeps_seeded_prefix_routes(image,n,p,(s1,s2),r9,r10,r11,ep),blank),
    L.actual_encoded_prefix_keeps_cached_candidate(L.image_board(image),n,1n+m,row,col)(s3,c1))

def L.copy_shape_four_from_three(a,b,eqs):
  (s0,(s1,s2)) = eqs
  (s0,(s1,L.copy_shape_proof(a,b,s2)))

def L.full_queue_encoded_blank_with_window(image,row,col,shape,blank,window):
  (guard,total) = window
  +n = L.logical_offset(row,col)
  +m = L.logical_tail(row,col)
  +p = L.logical_position(row,col)
  L.full_queue_encoded_blank_with_routes(image,row,col,
    L.copy_shape_four_from_three(L.array_shape(L.image_board(image)),L.perfect_shape(7n),
      L.copy_shape_three(L.array_shape(L.image_board(image)),L.perfect_shape(7n),shape)),
    L.copy_nat_eq(Nat.add(n,1n+m),81n,L.checked_center_total(n,m,total)),
    L.window_routes(n,m,p,(p + 1 : U32),guard),blank)

def L.encoded_logical_blank_uses_original_cached_mask(b,row,col):
  L.on_reified_board(b,x => L.EncodeBlankOriginalCache(x,row,col),
    L.reify_board(b),image => shape => blank => L.full_queue_encoded_blank_with_window(image,row,col,shape,blank,L.every_cell_window(row,col)))

def L.direct_unit_fold_actual(n,unit,j,image,used):
  match n:
    case 0n:
      {==}
    case 1n+k:
      +next = (j + 1 : U32)
      +p = Board.unit_pos(unit,next)
      b = L.image_board(image)
      +d = L.cell_value(L.image_board(image),Board.unit_pos(unit,j))
      +folded = U32.or(used,Board.bit(d))
      +next_value = L.cell_value(L.image_board(image),p)
      %Equal.sym(Array<U32> & U32,Board.get_cell(b,p),(b,next_value),
        L.cached_read_exact(L.image_board(image),p,L.board_read_witness(L.image_board(image),p))) :
        {C.used_go(k,unit,next,_,folded) == (b,L.direct_unit_fold(k,unit,next,image,folded)) : Array<U32> & U32}
      L.direct_unit_fold_actual(k,unit,next,image,folded)

def L.direct_unit_used_image(image,unit):
  b = L.image_board(image)
  +p = Board.unit_pos(unit,0)
  +value = L.cell_value(L.image_board(image),p)
  %Equal.sym(Array<U32> & U32,Board.get_cell(b,p),(b,value),
    L.cached_read_exact(L.image_board(image),p,L.board_read_witness(L.image_board(image),p))) :
    {C.used_go(9n,unit,0,_,0) == (b,L.direct_unit_fold(9n,unit,0,image,0)) : Array<U32> & U32}
  L.direct_unit_fold_actual(9n,unit,0,image,0)

def L.direct_add_unit_image(image,unit,used):
  b = L.image_board(image)
  +p = Board.unit_pos(unit,0)
  +value = L.cell_value(L.image_board(image),p)
  %Equal.sym(Array<U32> & U32,Board.get_cell(b,p),(b,value),
    L.cached_read_exact(L.image_board(image),p,L.board_read_witness(L.image_board(image),p))) :
    {C.used_go(9n,unit,0,_,used) == (b,L.direct_unit_fold(9n,unit,0,image,used)) : Array<U32> & U32}
  L.direct_unit_fold_actual(9n,unit,0,image,used)

def L.actual_direct_candidates_image(image,p):
  b = L.image_board(image)
  +r = M.div9(p)
  +c = (9 + M.rem9(p) : U32)
  +k = (18 + Board.box_of(p) : U32)
  +rv = L.direct_unit_fold(9n,r,0,image,0)
  +cv = L.direct_unit_fold(9n,c,0,image,rv)
  +kv = L.direct_unit_fold(9n,k,0,image,cv)
  %Equal.sym(Array<U32> & U32,C.unit_used(b,r),(b,rv),L.direct_unit_used_image(image,r)) :
    {C.invert(C.add_unit(k,C.add_unit(c,_))) == (b,L.direct_candidate_word(image,p)) : Array<U32> & U32}
  %Equal.sym(Array<U32> & U32,C.add_unit(c,(b,rv)),(b,cv),L.direct_add_unit_image(image,c,rv)) :
    {C.invert(C.add_unit(k,_)) == (b,L.direct_candidate_word(image,p)) : Array<U32> & U32}
  %Equal.sym(Array<U32> & U32,C.add_unit(k,(b,cv)),(b,kv),L.direct_add_unit_image(image,k,cv)) :
    {C.invert(_) == (b,L.direct_candidate_word(image,p)) : Array<U32> & U32}
  {==}

def L.bool_or_assoc(a,b,c):
  match a b c:
    case False{} False{} False{}:
      {==}
    case False{} False{} True{}:
      {==}
    case False{} True{} False{}:
      {==}
    case False{} True{} True{}:
      {==}
    case True{} False{} False{}:
      {==}
    case True{} False{} True{}:
      {==}
    case True{} True{} False{}:
      {==}
    case True{} True{} True{}:
      {==}

def L.word_or_assoc(n,a,b,c):
  match n a b c:
    case 0n WNil{} WNil{} WNil{}:
      {==}
    case 1n+k WCon{+aa,+at} WCon{+ba,+bt} WCon{+ca,+ct}:
      +head = Bool.or(aa,Bool.or(ba,ca))
      %Equal.sym(Bool,Bool.or(Bool.or(aa,ba),ca),head,L.bool_or_assoc(aa,ba,ca)) :
        {WCon{_,Word.or(k,Word.or(k,at,bt),ct)} == WCon{head,Word.or(k,at,Word.or(k,bt,ct))} : Word(1n+k)}
      Equal.cong(Word(k),Word(1n+k),w => WCon{head,w},Word.or(k,Word.or(k,at,bt),ct),Word.or(k,at,Word.or(k,bt,ct)),
        L.word_or_assoc(k,at,bt,ct))

def L.u32_or_assoc(a,b,c):
  match a b c:
    case U32{+x} U32{+y} U32{+z}:
      Equal.cong(Word(32n),U32,w => U32{w},Word.or(32n,Word.or(32n,x,y),z),Word.or(32n,x,Word.or(32n,y,z)),
        L.word_or_assoc(32n,x,y,z))

def L.word_or_zero_right(n,a):
  match n a:
    case 0n WNil{}:
      {==}
    case 1n+k WCon{False{},+t}:
      Equal.cong(Word(k),Word(1n+k),w => WCon{False{},w},Word.or(k,t,Word.zero(k)),t,L.word_or_zero_right(k,t))
    case 1n+k WCon{True{},+t}:
      Equal.cong(Word(k),Word(1n+k),w => WCon{True{},w},Word.or(k,t,Word.zero(k)),t,L.word_or_zero_right(k,t))

def L.u32_or_zero_right(a):
  match a:
    case U32{+w}:
      Equal.cong(Word(32n),U32,x => U32{x},Word.or(32n,w,Word.zero(32n)),w,L.word_or_zero_right(32n,w))

def L.direct_fold_accumulator_or(n,unit,j,image,extra,acc):
  match n:
    case 0n:
      {==}
    case 1n+k:
      +next = (j + 1 : U32)
      +added = Board.bit(L.cell_value(L.image_board(image),Board.unit_pos(unit,j)))
      %Equal.sym(U32,U32.or(U32.or(extra,acc),added),U32.or(extra,U32.or(acc,added)),L.u32_or_assoc(extra,acc,added)) :
        {L.direct_unit_fold(k,unit,next,image,_) == U32.or(extra,L.direct_unit_fold(k,unit,next,image,U32.or(acc,added))) : U32}
      L.direct_fold_accumulator_or(k,unit,next,image,extra,U32.or(acc,added))

def L.direct_fold_accumulator_base(n,unit,j,image,extra):
  %L.u32_or_zero_right(extra) :
    {L.direct_unit_fold(n,unit,j,image,_) == U32.or(extra,L.direct_unit_fold(n,unit,j,image,0)) : U32}
  L.direct_fold_accumulator_or(n,unit,j,image,extra,0)

def L.direct_candidate_is_three_unit_union(image,p):
  +ru = M.div9(p)
  +cu = (9 + M.rem9(p) : U32)
  +bu = (18 + Board.box_of(p) : U32)
  +r = L.direct_row_word(image,p)
  +c = L.direct_col_word(image,p)
  +b = L.direct_box_word(image,p)
  +old_col = L.direct_unit_fold(9n,cu,0,image,r)
  +old_box = L.direct_unit_fold(9n,bu,0,image,old_col)
  %Equal.sym(U32,old_box,U32.or(old_col,b),L.direct_fold_accumulator_base(9n,bu,0,image,old_col)) :
    {U32.and(1022,U32.not(_)) == L.occupancy_candidate_mask(r,c,b) : U32}
  %Equal.sym(U32,old_col,U32.or(r,c),L.direct_fold_accumulator_base(9n,cu,0,image,r)) :
    {U32.and(1022,U32.not(U32.or(_,b))) == L.occupancy_candidate_mask(r,c,b) : U32}
  {==}

def L.word_unseen_union_trim(n,mask,a,b,c):
  match n mask a b c:
    case 0n WNil{} WNil{} WNil{} WNil{}:
      {==}
    case 1n+k WCon{False{},+mt} WCon{+x,+xt} WCon{+y,+yt} WCon{+z,+zt}:
      Equal.cong(Word(k),Word(1n+k),v => WCon{False{},v},L.word_unseen_in_union(k,mt,xt,yt,zt),
        L.word_unseen_in_union(k,mt,Word.and(k,mt,xt),Word.and(k,mt,yt),Word.and(k,mt,zt)),
        L.word_unseen_union_trim(k,mt,xt,yt,zt))
    case 1n+k WCon{True{},+mt} WCon{+x,+xt} WCon{+y,+yt} WCon{+z,+zt}:
      +head = Bool.not(Bool.or(Bool.or(x,y),z))
      Equal.cong(Word(k),Word(1n+k),v => WCon{head,v},L.word_unseen_in_union(k,mt,xt,yt,zt),
        L.word_unseen_in_union(k,mt,Word.and(k,mt,xt),Word.and(k,mt,yt),Word.and(k,mt,zt)),
        L.word_unseen_union_trim(k,mt,xt,yt,zt))

def L.u32_unseen_union_trim(mask,a,b,c):
  match mask a b c:
    case U32{+m} U32{+x} U32{+y} U32{+z}:
      Equal.cong(Word(32n),U32,v => U32{v},L.word_unseen_in_union(32n,m,x,y,z),
        L.word_unseen_in_union(32n,m,Word.and(32n,m,x),Word.and(32n,m,y),Word.and(32n,m,z)),
        L.word_unseen_union_trim(32n,m,x,y,z))

def L.occupancy_masks_same_if_digits_same(ar,ac,ab,br,bc,bb,same):
  (row,(col,box)) = same
  +ar1 = U32.and(1022,ar)
  +ac1 = U32.and(1022,ac)
  +ab1 = U32.and(1022,ab)
  +br1 = U32.and(1022,br)
  +bc1 = U32.and(1022,bc)
  +bb1 = U32.and(1022,bb)
  %Equal.sym(U32,L.occupancy_candidate_mask(ar,ac,ab),L.occupancy_candidate_mask(ar1,ac1,ab1),L.u32_unseen_union_trim(1022,ar,ac,ab)) :
    {_ == L.occupancy_candidate_mask(br,bc,bb) : U32}
  %Equal.sym(U32,L.occupancy_candidate_mask(br,bc,bb),L.occupancy_candidate_mask(br1,bc1,bb1),L.u32_unseen_union_trim(1022,br,bc,bb)) :
    {L.occupancy_candidate_mask(ar1,ac1,ab1) == _ : U32}
  %Equal.sym(U32,ar1,br1,row) :
    {L.occupancy_candidate_mask(_,ac1,ab1) == L.occupancy_candidate_mask(br1,bc1,bb1) : U32}
  %Equal.sym(U32,ac1,bc1,col) :
    {L.occupancy_candidate_mask(br1,_,ab1) == L.occupancy_candidate_mask(br1,bc1,bb1) : U32}
  %Equal.sym(U32,ab1,bb1,box) :
    {L.occupancy_candidate_mask(br1,bc1,_) == L.occupancy_candidate_mask(br1,bc1,bb1) : U32}
  {==}

def L.cached_candidates_match_direct_if_unit_bits_agree(image,p,valid):
  b = L.image_board(image)
  +r = L.cell_value(L.image_board(image),L.ordinary_row_slot(p))
  +c = L.cell_value(L.image_board(image),L.ordinary_col_slot(p))
  +k = L.cell_value(L.image_board(image),L.ordinary_box_slot(p))
  +dr = L.direct_row_word(image,p)
  +dc = L.direct_col_word(image,p)
  +db = L.direct_box_word(image,p)
  %Equal.sym(U32,L.cached_word(b,p),L.occupancy_candidate_mask(r,c,k),L.cached_candidates_are_occupancy_image(image,p)) :
    {_ == Pair.snd(Array<U32>,U32,C.at(b,p)) : U32}
  %Equal.sym(Array<U32> & U32,C.at(b,p),(b,L.direct_candidate_word(image,p)),L.actual_direct_candidates_image(image,p)) :
    {L.occupancy_candidate_mask(r,c,k) == Pair.snd(Array<U32>,U32,_) : U32}
  %Equal.sym(U32,L.direct_candidate_word(image,p),L.occupancy_candidate_mask(dr,dc,db),L.direct_candidate_is_three_unit_union(image,p)) :
    {L.occupancy_candidate_mask(r,c,k) == _ : U32}
  L.occupancy_masks_same_if_digits_same(r,c,k,dr,dc,db,valid)

def L.encoded_blank_matches_direct_given_sound_cache(image,row,col,shape,blank,valid):
  b = L.image_board(image)
  +p = L.logical_position(row,col)
  Equal.trans(U32,L.cell_value(Q.encode(b),p),L.cached_word(b,p),Pair.snd(Array<U32>,U32,C.at(b,p)),
    L.encoded_logical_blank_uses_original_cached_mask(L.image_board(image),row,col)(shape,blank),
    L.cached_candidates_match_direct_if_unit_bits_agree(image,p,valid))

def L.word_remove_disjoint_union(n,others,gone,disjoint):
  match n others gone:
    case 0n WNil{} WNil{}:
      {==}
    case 1n+k WCon{False{},+others_tail} WCon{False{},+gone_tail}:
      Equal.cong(Word(k),Word(1n+k),w => WCon{False{},w},
        Word.and(k,Word.or(k,others_tail,gone_tail),Word.not(k,gone_tail)),others_tail,
        L.word_remove_disjoint_union(k,others_tail,gone_tail,
          Equal.cong(Word(1n+k),Word(k),w => L.bit_word_tail(k,w),WCon{False{},Word.and(k,others_tail,gone_tail)},Word.zero(1n+k),disjoint)))
    case 1n+k WCon{False{},+others_tail} WCon{True{},+gone_tail}:
      Equal.cong(Word(k),Word(1n+k),w => WCon{False{},w},
        Word.and(k,Word.or(k,others_tail,gone_tail),Word.not(k,gone_tail)),others_tail,
        L.word_remove_disjoint_union(k,others_tail,gone_tail,
          Equal.cong(Word(1n+k),Word(k),w => L.bit_word_tail(k,w),WCon{False{},Word.and(k,others_tail,gone_tail)},Word.zero(1n+k),disjoint)))
    case 1n+k WCon{True{},+others_tail} WCon{False{},+gone_tail}:
      Equal.cong(Word(k),Word(1n+k),w => WCon{True{},w},
        Word.and(k,Word.or(k,others_tail,gone_tail),Word.not(k,gone_tail)),others_tail,
        L.word_remove_disjoint_union(k,others_tail,gone_tail,
          Equal.cong(Word(1n+k),Word(k),w => L.bit_word_tail(k,w),WCon{False{},Word.and(k,others_tail,gone_tail)},Word.zero(1n+k),disjoint)))
    case 1n+k WCon{True{},+others_tail} WCon{True{},+gone_tail}:
      Empty.absurd({WCon{False{},Word.and(k,Word.or(k,others_tail,gone_tail),Word.not(k,gone_tail))} == WCon{True{},others_tail} : Word(1n+k)},
        L.false_is_not_true(Equal.sym(Bool,True{},False{},
          Equal.cong(Word(1n+k),Bool,w => L.bit_word_head(k,w),WCon{True{},Word.and(k,others_tail,gone_tail)},Word.zero(1n+k),disjoint))))

def L.u32_remove_disjoint_union(others,gone,disjoint):
  match others gone:
    case U32{+a} U32{+b}:
      Equal.cong(Word(32n),U32,w => U32{w},Word.and(32n,Word.or(32n,a,b),Word.not(32n,b)),a,
        L.word_remove_disjoint_union(32n,a,b,
          Equal.cong(U32,Word(32n),w => L.bits_of_u32(w),U32{Word.and(32n,a,b)},0,disjoint)))

def L.ordinary_update_word_when_old_is_unique(others,gone,added,disjoint):
  Equal.cong(U32,U32,w => U32.or(w,added),U32.and(U32.or(others,gone),U32.not(gone)),others,
    L.u32_remove_disjoint_union(others,gone,disjoint))

def L.ordinary_unit_formula_unique(others,old,value,disjoint):
  L.ordinary_update_word_when_old_is_unique(others,Board.bit(old),Board.bit(value),disjoint)

def L.word_replace_mask_commutes_with_clip(n,clip,used,gone,added):
  match n clip used gone added:
    case 0n WNil{} WNil{} WNil{} WNil{}:
      {==}
    case 1n+k WCon{False{},+ct} WCon{+x,+xt} WCon{+y,+yt} WCon{+z,+zt}:
      Equal.cong(Word(k),Word(1n+k),w => WCon{False{},w},Word.and(k,ct,L.word_replace_mask(k,xt,yt,zt)),
        L.word_replace_mask(k,Word.and(k,ct,xt),Word.and(k,ct,yt),Word.and(k,ct,zt)),
        L.word_replace_mask_commutes_with_clip(k,ct,xt,yt,zt))
    case 1n+k WCon{True{},+ct} WCon{+x,+xt} WCon{+y,+yt} WCon{+z,+zt}:
      +head = Bool.or(Bool.and(x,Bool.not(y)),z)
      Equal.cong(Word(k),Word(1n+k),w => WCon{head,w},Word.and(k,ct,L.word_replace_mask(k,xt,yt,zt)),
        L.word_replace_mask(k,Word.and(k,ct,xt),Word.and(k,ct,yt),Word.and(k,ct,zt)),
        L.word_replace_mask_commutes_with_clip(k,ct,xt,yt,zt))

def L.u32_replace_mask_commutes_with_clip(clip,used,gone,added):
  match clip used gone added:
    case U32{+c} U32{+x} U32{+y} U32{+z}:
      Equal.cong(Word(32n),U32,w => U32{w},Word.and(32n,c,L.word_replace_mask(32n,x,y,z)),
        L.word_replace_mask(32n,Word.and(32n,c,x),Word.and(32n,c,y),Word.and(32n,c,z)),
        L.word_replace_mask_commutes_with_clip(32n,c,x,y,z))

def L.ordinary_unit_update_preserves_legal_digit_union(others,old,value,used,seen,unique):
  +gone = Board.bit(old)
  +added = Board.bit(value)
  +g = U32.and(1022,gone)
  +a = U32.and(1022,added)
  %Equal.sym(U32,U32.and(1022,L.replace_digit_mask(used,gone,added)),L.replace_digit_mask(U32.and(1022,used),g,a),
    L.u32_replace_mask_commutes_with_clip(1022,used,gone,added)) :
    {_ == U32.or(others,a) : U32}
  %Equal.sym(U32,U32.and(1022,used),U32.or(others,g),seen) :
    {L.replace_digit_mask(_,g,a) == U32.or(others,a) : U32}
  L.ordinary_update_word_when_old_is_unique(others,g,a,unique)

def L.ordinary_unit_write_exact_word(image,slot,old,value):
  b = L.image_board(image)
  +prior = L.cell_value(L.image_board(image),slot)
  +next = L.ordinary_unit_word(old,value,prior)
  %Equal.sym(Array<U32> & U32,Board.get_cell(b,slot),(b,prior),
    L.cached_read_exact(L.image_board(image),slot,L.board_read_witness(L.image_board(image),slot))) :
    {L.cell_value(C.update_done(slot,old,value,_),slot) == next : U32}
  L.board_set_get(L.image_board(image),slot,next)

def L.ordinary_unit_actual_keeps_digit_union(image,slot,others,old,value,seen,unique):
  +used = L.cell_value(L.image_board(image),slot)
  +next = L.ordinary_unit_word(old,value,used)
  %Equal.sym(U32,L.cell_value(C.update_unit(slot,old,value,L.image_board(image)),slot),next,
    L.ordinary_unit_write_exact_word(image,slot,old,value)) :
    {U32.and(1022,_) == U32.or(others,U32.and(1022,Board.bit(value))) : U32}
  L.ordinary_unit_update_preserves_legal_digit_union(others,old,value,used,seen,unique)

def L.bool_and_assoc(a,b,c):
  match a b c:
    case False{} False{} False{}:
      {==}
    case False{} False{} True{}:
      {==}
    case False{} True{} False{}:
      {==}
    case False{} True{} True{}:
      {==}
    case True{} False{} False{}:
      {==}
    case True{} False{} True{}:
      {==}
    case True{} True{} False{}:
      {==}
    case True{} True{} True{}:
      {==}

def L.word_and_assoc(n,a,b,c):
  match n a b c:
    case 0n WNil{} WNil{} WNil{}:
      {==}
    case 1n+k WCon{+x,+xt} WCon{+y,+yt} WCon{+z,+zt}:
      +head = Bool.and(Bool.and(x,y),z)
      %Equal.sym(Bool,Bool.and(x,Bool.and(y,z)),head,L.bool_and_assoc(x,y,z)) :
        {WCon{_,Word.and(k,xt,Word.and(k,yt,zt))} == WCon{head,Word.and(k,Word.and(k,xt,yt),zt)} : Word(1n+k)}
      Equal.cong(Word(k),Word(1n+k),w => WCon{head,w},Word.and(k,xt,Word.and(k,yt,zt)),Word.and(k,Word.and(k,xt,yt),zt),
        L.word_and_assoc(k,xt,yt,zt))

def L.u32_and_assoc(a,b,c):
  match a b c:
    case U32{+x} U32{+y} U32{+z}:
      Equal.cong(Word(32n),U32,w => U32{w},Word.and(32n,x,Word.and(32n,y,z)),Word.and(32n,Word.and(32n,x,y),z),
        L.word_and_assoc(32n,x,y,z))

def L.row_mark_clip_when_disjoint(is_blank,value,mark,apart):
  match is_blank:
    case True{}:
      L.u32_mask_set_keeps_other(value,1022,mark,apart)
    case False{}:
      L.u32_mask_clear_keeps_other(value,1022,mark,apart)


def L.bool_and_comm(a,b):
  match a b:
    case False{} False{}:
      {==}
    case False{} True{}:
      {==}
    case True{} False{}:
      {==}
    case True{} True{}:
      {==}

def L.word_and_comm(n,a,b):
  match n a b:
    case 0n WNil{} WNil{}:
      {==}
    case 1n+k WCon{+x,+xt} WCon{+y,+yt}:
      +head = Bool.and(y,x)
      %Equal.sym(Bool,Bool.and(x,y),head,L.bool_and_comm(x,y)) :
        {WCon{_,Word.and(k,xt,yt)} == WCon{head,Word.and(k,yt,xt)} : Word(1n+k)}
      Equal.cong(Word(k),Word(1n+k),w => WCon{head,w},Word.and(k,xt,yt),Word.and(k,yt,xt),L.word_and_comm(k,xt,yt))

def L.u32_and_comm(a,b):
  match a b:
    case U32{+x} U32{+y}:
      Equal.cong(Word(32n),U32,w => U32{w},Word.and(32n,x,y),Word.and(32n,y,x),L.word_and_comm(32n,x,y))

def L.clip_discards_bit_zero_last(w):
  %Equal.sym(U32,U32.and(w,1023),U32.and(1023,w),L.u32_and_comm(w,1023)) :
    {U32.and(1022,_) == U32.and(1022,w) : U32}
  L.u32_and_assoc(1022,1023,w)

def L.row_inner_clip_equivalence(used,gone,added):
  +g = U32.and(gone,1023)
  +a = U32.and(added,1023)
  +k = U32.and(1022,used)
  +gg = U32.and(1022,gone)
  +aa = U32.and(1022,added)
  %Equal.sym(U32,U32.and(1022,L.replace_digit_mask(used,g,a)),L.replace_digit_mask(k,U32.and(1022,g),U32.and(1022,a)),
    L.u32_replace_mask_commutes_with_clip(1022,used,g,a)) :
    {_ == U32.and(1022,L.replace_digit_mask(used,gone,added)) : U32}
  %Equal.sym(U32,U32.and(1022,g),gg,L.clip_discards_bit_zero_last(gone)) :
    {L.replace_digit_mask(k,_,U32.and(1022,a)) == U32.and(1022,L.replace_digit_mask(used,gone,added)) : U32}
  %Equal.sym(U32,U32.and(1022,a),aa,L.clip_discards_bit_zero_last(added)) :
    {L.replace_digit_mask(k,gg,_) == U32.and(1022,L.replace_digit_mask(used,gone,added)) : U32}
  Equal.sym(U32,U32.and(1022,L.replace_digit_mask(used,gone,added)),L.replace_digit_mask(k,gg,aa),
    L.u32_replace_mask_commutes_with_clip(1022,used,gone,added))

def L.column_empty_bit_outside_digits(col):
  match col:
    case L.Coordinate0{}:
      {==}
    case L.Coordinate1{}:
      {==}
    case L.Coordinate2{}:
      {==}
    case L.Coordinate3{}:
      {==}
    case L.Coordinate4{}:
      {==}
    case L.Coordinate5{}:
      {==}
    case L.Coordinate6{}:
      {==}
    case L.Coordinate7{}:
      {==}
    case L.Coordinate8{}:
      {==}

def L.row_empty_outside_digits_using_geometry(row,col,geometry):
  (unused,observed) = geometry
  +p = L.logical_position(row,col)
  %Equal.sym(U32,M.rem9(p),L.coord_u32(col),observed) :
    {U32.and(1022,Board.bit((10 + _ : U32))) == 0 : U32}
  L.column_empty_bit_outside_digits(col)

def L.row_empty_bit_outside_digit_bits(row,col):
  L.row_empty_outside_digits_using_geometry(row,col,L.source_place_geometry(row,col))

def L.ordinary_row_clip_equals_unit_clip(old,value,empty,used,apart):
  +gone = Board.bit(old)
  +added = Board.bit(value)
  +a = U32.and(added,1023)
  +g = U32.and(gone,1023)
  +base = L.replace_digit_mask(used,g,a)
  Equal.trans(U32,U32.and(1022,L.ordinary_row_word(old,value,empty,used)),U32.and(1022,base),U32.and(1022,L.ordinary_unit_word(old,value,used)),
    L.row_mark_clip_when_disjoint(U32.is_eq(value,0),base,empty,apart),
    L.row_inner_clip_equivalence(used,gone,added))

def L.ordinary_row_write_exact_word(image,p,old,value):
  b = L.image_board(image)
  +slot = L.ordinary_row_slot(p)
  +prior = L.cell_value(L.image_board(image),slot)
  +empty = L.ordinary_empty_bit(p)
  +next = L.ordinary_row_word(old,value,empty,prior)
  %Equal.sym(Array<U32> & U32,Board.get_cell(b,slot),(b,prior),
    L.cached_read_exact(L.image_board(image),slot,L.board_read_witness(L.image_board(image),slot))) :
    {L.cell_value(C.row_updated(slot,old,value,empty,_),slot) == next : U32}
  L.board_set_get(L.image_board(image),slot,next)

def L.ordinary_row_actual_keeps_digit_union(image,row,col,others,old,value,seen,unique):
  +p = L.logical_position(row,col)
  +slot = L.ordinary_row_slot(p)
  +used = L.cell_value(L.image_board(image),slot)
  +empty = L.ordinary_empty_bit(p)
  %Equal.sym(U32,L.cell_value(C.update_row(p,old,value,L.image_board(image)),slot),L.ordinary_row_word(old,value,empty,used),
    L.ordinary_row_write_exact_word(image,p,old,value)) :
    {U32.and(1022,_) == U32.or(others,U32.and(1022,Board.bit(value))) : U32}
  %Equal.sym(U32,U32.and(1022,L.ordinary_row_word(old,value,empty,used)),U32.and(1022,L.ordinary_unit_word(old,value,used)),
    L.ordinary_row_clip_equals_unit_clip(old,value,empty,used,L.row_empty_bit_outside_digit_bits(row,col))) :
    {_ == U32.or(others,U32.and(1022,Board.bit(value))) : U32}
  L.ordinary_unit_update_preserves_legal_digit_union(others,old,value,used,seen,unique)

def L.actual_cached_row_scan(n,pos,col,used,image):
  match n:
    case 0n:
      {==}
    case 1n+k:
      +next = (pos + 1 : U32)
      b = L.image_board(image)
      +word = L.cell_value(L.image_board(image),next)
      +entry = L.cached_row_digit_entry(col,L.cell_value(L.image_board(image),pos))
      +next_used = U32.or(used,entry)
      %Equal.sym(Array<U32> & U32,Board.get_cell(b,next),(b,word),
        L.cached_read_exact(L.image_board(image),next,L.board_read_witness(L.image_board(image),next))) :
        {C.row_used(k,next,(col + 1 : U32),next_used,_) ==
          (b,L.cached_row_fold(k,next,(col + 1 : U32),next_used,image)) : Array<U32> & U32}
      L.actual_cached_row_scan(k,next,(col + 1 : U32),next_used,image)

def L.actual_cached_used_row(image,unit):
  b = L.image_board(image)
  +p = (unit * 9 : U32)
  +word = L.cell_value(L.image_board(image),p)
  %Equal.sym(Array<U32> & U32,Board.get_cell(b,p),(b,word),
    L.cached_read_exact(L.image_board(image),p,L.board_read_witness(L.image_board(image),p))) :
    {C.row_used(9n,p,0,0,_) == (b,L.cached_row_fold(9n,p,0,0,image)) : Array<U32> & U32}
  L.actual_cached_row_scan(9n,p,0,0,image)

def L.actual_cached_one_nonrow_write(image,unit):
  b = L.image_board(image)
  +slot = (81 + unit : U32)
  +used = L.direct_unit_fold(9n,unit,0,image,0)
  %Equal.sym(Array<U32> & U32,C.unit_used(b,unit),(b,used),L.direct_unit_used_image(image,unit)) :
    {C.cache_unit_done(slot,_) == Board.set_cell(b,slot,used) : Array<U32>}
  {==}

def L.actual_cached_one_row_write(image,unit):
  b = L.image_board(image)
  +slot = (81 + unit : U32)
  +used = L.cached_row_fold(9n,(unit * 9 : U32),0,0,image)
  %Equal.sym(Array<U32> & U32,C.cached_used(True{},unit,b),(b,used),L.actual_cached_used_row(image,unit)) :
    {C.cache_unit_done(slot,_) == Board.set_cell(b,slot,used) : Array<U32>}
  {==}

def L.bit_clip_distributes_over_or(m,x,y):
  match m x y:
    case False{} False{} False{}:
      {==}
    case False{} False{} True{}:
      {==}
    case False{} True{} False{}:
      {==}
    case False{} True{} True{}:
      {==}
    case True{} False{} False{}:
      {==}
    case True{} False{} True{}:
      {==}
    case True{} True{} False{}:
      {==}
    case True{} True{} True{}:
      {==}

def L.word_clip_distributes_over_or(n,m,x,y):
  match n m x y:
    case 0n WNil{} WNil{} WNil{}:
      {==}
    case 1n+k WCon{+mb,+mt} WCon{+xb,+xt} WCon{+yb,+yt}:
      +head = Bool.or(Bool.and(mb,xb),Bool.and(mb,yb))
      %Equal.sym(Bool,Bool.and(mb,Bool.or(xb,yb)),head,L.bit_clip_distributes_over_or(mb,xb,yb)) :
        {WCon{_,Word.and(k,mt,Word.or(k,xt,yt))} ==
          WCon{head,Word.or(k,Word.and(k,mt,xt),Word.and(k,mt,yt))} : Word(1n+k)}
      Equal.cong(Word(k),Word(1n+k),w => WCon{head,w},Word.and(k,mt,Word.or(k,xt,yt)),
        Word.or(k,Word.and(k,mt,xt),Word.and(k,mt,yt)),L.word_clip_distributes_over_or(k,mt,xt,yt))

def L.u32_clip_distributes_over_or(m,x,y):
  match m x y:
    case U32{+a} U32{+b} U32{+c}:
      Equal.cong(Word(32n),U32,w => U32{w},Word.and(32n,a,Word.or(32n,b,c)),
        Word.or(32n,Word.and(32n,a,b),Word.and(32n,a,c)),L.word_clip_distributes_over_or(32n,a,b,c))

def L.cached_row_clip_mark(blank,marker,outside):
  match blank:
    case True{}:
      outside
    case False{}:
      {==}

def L.cached_row_entry_digit_clip(col,raw,outside):
  +bit = Board.bit(raw)
  +candidate = U32.and(bit,1023)
  +marker = Board.bit((10 + col : U32))
  +mark = Bool.pick(U32,U32.is_eq(raw,0),marker,0)
  %Equal.sym(U32,U32.and(1022,U32.or(candidate,mark)),U32.or(U32.and(1022,candidate),U32.and(1022,mark)),
    L.u32_clip_distributes_over_or(1022,candidate,mark)) :
    {_ == U32.and(1022,bit) : U32}
  %Equal.sym(U32,U32.and(1022,mark),0,L.cached_row_clip_mark(U32.is_eq(raw,0),marker,outside)) :
    {U32.or(U32.and(1022,candidate),_) == U32.and(1022,bit) : U32}
  Equal.trans(U32,U32.or(U32.and(1022,candidate),0),U32.and(1022,candidate),U32.and(1022,bit),
    L.u32_or_zero_right(U32.and(1022,candidate)),L.clip_discards_bit_zero_last(bit))

def L.cached_row_acc_step_keeps_digit_word(col,raw,cached,direct,same,outside):
  +entry = L.cached_row_digit_entry(col,raw)
  +digit = Board.bit(raw)
  %Equal.sym(U32,U32.and(1022,U32.or(cached,entry)),U32.or(U32.and(1022,cached),U32.and(1022,entry)),
    L.u32_clip_distributes_over_or(1022,cached,entry)) :
    {_ == U32.and(1022,U32.or(direct,digit)) : U32}
  %Equal.sym(U32,U32.and(1022,cached),U32.and(1022,direct),same) :
    {U32.or(_,U32.and(1022,entry)) == U32.and(1022,U32.or(direct,digit)) : U32}
  %Equal.sym(U32,U32.and(1022,entry),U32.and(1022,digit),L.cached_row_entry_digit_clip(col,raw,outside)) :
    {U32.or(U32.and(1022,direct),_) == U32.and(1022,U32.or(direct,digit)) : U32}
  Equal.sym(U32,U32.and(1022,U32.or(direct,digit)),U32.or(U32.and(1022,direct),U32.and(1022,digit)),
    L.u32_clip_distributes_over_or(1022,direct,digit))

def L.cached_row_fold_matches_direct_digits(n,unit,j,pos,col,cached,direct,image,same,route):
  match n:
    case 0n:
      same
    case 1n+k:
      (found,(outside,rest)) = route
      +raw = L.cell_value(L.image_board(image),pos)
      +j1 = (j + 1 : U32)
      +p1 = (pos + 1 : U32)
      +c1 = (col + 1 : U32)
      +cached1 = U32.or(cached,L.cached_row_digit_entry(col,raw))
      %Equal.sym(U32,Board.unit_pos(unit,j),pos,found) :
        {U32.and(1022,L.cached_row_fold(k,p1,c1,cached1,image)) ==
          U32.and(1022,L.direct_unit_fold(k,unit,j1,image,U32.or(direct,Board.bit(L.cell_value(L.image_board(image),_))))) : U32}
      L.cached_row_fold_matches_direct_digits(k,unit,j1,p1,c1,cached1,U32.or(direct,Board.bit(raw)),image,
        L.cached_row_acc_step_keeps_digit_word(col,raw,cached,direct,same,outside),rest)

def L.logical_row_fold_route(row):
  match row:
    case L.Coordinate0{}:
      ({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},{==}))))))))))))))))))
    case L.Coordinate1{}:
      ({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},{==}))))))))))))))))))
    case L.Coordinate2{}:
      ({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},{==}))))))))))))))))))
    case L.Coordinate3{}:
      ({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},{==}))))))))))))))))))
    case L.Coordinate4{}:
      ({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},{==}))))))))))))))))))
    case L.Coordinate5{}:
      ({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},{==}))))))))))))))))))
    case L.Coordinate6{}:
      ({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},{==}))))))))))))))))))
    case L.Coordinate7{}:
      ({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},{==}))))))))))))))))))
    case L.Coordinate8{}:
      ({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},({==},{==}))))))))))))))))))

def L.cached_row_setup_digits_match_direct(image,row):
  b = L.image_board(image)
  +unit = L.coord_u32(row)
  +pos = (unit * 9 : U32)
  +slot = (81 + unit : U32)
  +used = L.cached_row_fold(9n,pos,0,0,image)
  %Equal.sym(Array<U32>,C.cache_unit_done(slot,C.cached_used(True{},unit,b)),Board.set_cell(b,slot,used),L.actual_cached_one_row_write(image,unit)) :
    {U32.and(1022,L.cell_value(_,slot)) == U32.and(1022,L.direct_unit_fold(9n,unit,0,image,0)) : U32}
  %Equal.sym(U32,L.cell_value(Board.set_cell(b,slot,used),slot),used,L.board_set_get(L.image_board(image),slot,used)) :
    {U32.and(1022,_) == U32.and(1022,L.direct_unit_fold(9n,unit,0,image,0)) : U32}
  L.cached_row_fold_matches_direct_digits(9n,unit,0,pos,0,0,0,image,{==},L.logical_row_fold_route(row))

def L.cache_setup_step_is_write_mode(image,unit,row):
  match row:
    case True{}:
      L.actual_cached_one_row_write(image,unit)
    case False{}:
      L.actual_cached_one_nonrow_write(image,unit)

def L.cache_setup_step_is_write(image,unit):
  L.cache_setup_step_is_write_mode(image,unit,(unit < 9 : U32))

def L.cache_setup_step_keeps_cell_image(image,unit,q,shape,apart):
  b = L.image_board(image)
  +slot = (81 + unit : U32)
  +word = L.cache_setup_word((unit < 9 : U32),unit,image)
  %Equal.sym(Array<U32>,L.cache_setup_step(unit,b),Board.set_cell(b,slot,word),L.cache_setup_step_is_write(image,unit)) :
    {L.cell_value(_,q) == L.cell_value(b,q) : U32}
  L.perfect_write_keeps_cell(L.image_board(image),slot,q,word,shape,apart)

def L.cache_setup_step_keeps_cell(b,unit,q):
  L.on_reified_board(b,x => L.CacheSetupKeepsCell(x,unit,q),
    L.reify_board(b),image => L.cache_setup_step_keeps_cell_image(image,unit,q))

def L.cache_setup_step_keeps_shape_image(image,unit,shape):
  b = L.image_board(image)
  +slot = (81 + unit : U32)
  +word = L.cache_setup_word((unit < 9 : U32),unit,image)
  %Equal.sym(Array<U32>,L.cache_setup_step(unit,b),Board.set_cell(b,slot,word),L.cache_setup_step_is_write(image,unit)) :
    L.Board128(_)
  L.board_set_keeps_perfect(L.image_board(image),slot,word,7n,shape)

def L.cache_setup_step_keeps_shape(b,unit,shape):
  f : (L.Board128(b) -> L.Board128(L.cache_setup_step(unit,b))) =
    L.on_reified_board(b,x => (L.Board128(x) -> L.Board128(L.cache_setup_step(unit,x))),
      L.reify_board(b),image => L.cache_setup_step_keeps_shape_image(image,unit))
  f(shape)

def L.cache_setup_shape_next_image(image,n,unit,shape,recurse):
  recurse(L.cache_setup_step(unit,L.image_board(image)),L.cache_setup_step_keeps_shape_image(image,unit,shape))

def L.cache_setup_shape_next(b,n,unit,shape,recurse):
  f : (L.Board128(b) -> L.CacheSetupShapeTail(n,(unit + 1 : U32)) -> L.Board128(C.cache_units(1n+n,unit,b))) =
    L.on_reified_board(b,x => (L.Board128(x) -> L.CacheSetupShapeTail(n,(unit + 1 : U32)) -> L.Board128(C.cache_units(1n+n,unit,x))),
      L.reify_board(b),image => L.cache_setup_shape_next_image(image,n,unit))
  f(shape,recurse)

def L.cache_setup_full_keeps_shape(n,unit,b,shape):
  match n:
    case 0n:
      shape
    case 1n+k:
      L.cache_setup_shape_next(b,k,unit,shape,x => witness => L.cache_setup_full_keeps_shape(k,(unit + 1 : U32),x,witness))

def L.cache_setup_read_next_parts(image,n,unit,q,shapes,routes,recurse):
  (s0,s1) = shapes
  (apart,later) = routes
  b = L.image_board(image)
  next = L.cache_setup_step(unit,L.image_board(image))
  Equal.trans(U32,L.cell_value(C.cache_units(1n+n,unit,b),q),L.cell_value(next,q),L.cell_value(b,q),
    recurse(L.cache_setup_step(unit,L.image_board(image)),L.cache_setup_step_keeps_shape_image(image,unit,s0),later),
    L.cache_setup_step_keeps_cell_image(image,unit,q,s1,apart))

def L.cache_setup_read_next_image(image,n,unit,q,shape,routes,recurse):
  L.cache_setup_read_next_parts(image,n,unit,q,
    L.copy_shape_proof(L.array_shape(L.image_board(image)),L.perfect_shape(7n),shape),routes,recurse)

def L.cache_setup_read_next(b,n,unit,q,shape,routes,recurse):
  f : (L.Board128(b) -> L.CacheSetupWalkRoutes(1n+n,unit,q) -> L.CacheSetupReadTail(n,(unit + 1 : U32),q) ->
    {L.cell_value(C.cache_units(1n+n,unit,b),q) == L.cell_value(b,q) : U32}) =
    L.on_reified_board(b,x => (L.Board128(x) -> L.CacheSetupWalkRoutes(1n+n,unit,q) -> L.CacheSetupReadTail(n,(unit + 1 : U32),q) ->
      {L.cell_value(C.cache_units(1n+n,unit,x),q) == L.cell_value(x,q) : U32}),
      L.reify_board(b),image => L.cache_setup_read_next_image(image,n,unit,q))
  f(shape,routes,recurse)

def L.cache_setup_sweep_keeps_cell(n,unit,q,b,shape,routes):
  match n:
    case 0n:
      {==}
    case 1n+k:
      L.cache_setup_read_next(b,k,unit,q,shape,routes,
        x => s => rs => L.cache_setup_sweep_keeps_cell(k,(unit + 1 : U32),q,x,s,rs))

def L.cache_setup_route_from_checked_split(n,unit,q,pieces,recurse):
  (apart,tail) = pieces
  (apart,recurse(tail))

def L.cache_setup_route_from_checked(n,unit,q,check):
  match n:
    case 0n:
      {==}
    case 1n+k:
      L.cache_setup_route_from_checked_split(k,unit,q,
        L.both_true(L.apart_guard((81 + unit : U32),q),L.cache_setup_route_guard(k,(unit + 1 : U32),q),check),
        next => L.cache_setup_route_from_checked(k,(unit + 1 : U32),q,next))

def L.cache_setup_sweep_guard_logical(row,col):
  match row col:
    case L.Coordinate0{} L.Coordinate0{}:
      {==}
    case L.Coordinate0{} L.Coordinate1{}:
      {==}
    case L.Coordinate0{} L.Coordinate2{}:
      {==}
    case L.Coordinate0{} L.Coordinate3{}:
      {==}
    case L.Coordinate0{} L.Coordinate4{}:
      {==}
    case L.Coordinate0{} L.Coordinate5{}:
      {==}
    case L.Coordinate0{} L.Coordinate6{}:
      {==}
    case L.Coordinate0{} L.Coordinate7{}:
      {==}
    case L.Coordinate0{} L.Coordinate8{}:
      {==}
    case L.Coordinate1{} L.Coordinate0{}:
      {==}
    case L.Coordinate1{} L.Coordinate1{}:
      {==}
    case L.Coordinate1{} L.Coordinate2{}:
      {==}
    case L.Coordinate1{} L.Coordinate3{}:
      {==}
    case L.Coordinate1{} L.Coordinate4{}:
      {==}
    case L.Coordinate1{} L.Coordinate5{}:
      {==}
    case L.Coordinate1{} L.Coordinate6{}:
      {==}
    case L.Coordinate1{} L.Coordinate7{}:
      {==}
    case L.Coordinate1{} L.Coordinate8{}:
      {==}
    case L.Coordinate2{} L.Coordinate0{}:
      {==}
    case L.Coordinate2{} L.Coordinate1{}:
      {==}
    case L.Coordinate2{} L.Coordinate2{}:
      {==}
    case L.Coordinate2{} L.Coordinate3{}:
      {==}
    case L.Coordinate2{} L.Coordinate4{}:
      {==}
    case L.Coordinate2{} L.Coordinate5{}:
      {==}
    case L.Coordinate2{} L.Coordinate6{}:
      {==}
    case L.Coordinate2{} L.Coordinate7{}:
      {==}
    case L.Coordinate2{} L.Coordinate8{}:
      {==}
    case L.Coordinate3{} L.Coordinate0{}:
      {==}
    case L.Coordinate3{} L.Coordinate1{}:
      {==}
    case L.Coordinate3{} L.Coordinate2{}:
      {==}
    case L.Coordinate3{} L.Coordinate3{}:
      {==}
    case L.Coordinate3{} L.Coordinate4{}:
      {==}
    case L.Coordinate3{} L.Coordinate5{}:
      {==}
    case L.Coordinate3{} L.Coordinate6{}:
      {==}
    case L.Coordinate3{} L.Coordinate7{}:
      {==}
    case L.Coordinate3{} L.Coordinate8{}:
      {==}
    case L.Coordinate4{} L.Coordinate0{}:
      {==}
    case L.Coordinate4{} L.Coordinate1{}:
      {==}
    case L.Coordinate4{} L.Coordinate2{}:
      {==}
    case L.Coordinate4{} L.Coordinate3{}:
      {==}
    case L.Coordinate4{} L.Coordinate4{}:
      {==}
    case L.Coordinate4{} L.Coordinate5{}:
      {==}
    case L.Coordinate4{} L.Coordinate6{}:
      {==}
    case L.Coordinate4{} L.Coordinate7{}:
      {==}
    case L.Coordinate4{} L.Coordinate8{}:
      {==}
    case L.Coordinate5{} L.Coordinate0{}:
      {==}
    case L.Coordinate5{} L.Coordinate1{}:
      {==}
    case L.Coordinate5{} L.Coordinate2{}:
      {==}
    case L.Coordinate5{} L.Coordinate3{}:
      {==}
    case L.Coordinate5{} L.Coordinate4{}:
      {==}
    case L.Coordinate5{} L.Coordinate5{}:
      {==}
    case L.Coordinate5{} L.Coordinate6{}:
      {==}
    case L.Coordinate5{} L.Coordinate7{}:
      {==}
    case L.Coordinate5{} L.Coordinate8{}:
      {==}
    case L.Coordinate6{} L.Coordinate0{}:
      {==}
    case L.Coordinate6{} L.Coordinate1{}:
      {==}
    case L.Coordinate6{} L.Coordinate2{}:
      {==}
    case L.Coordinate6{} L.Coordinate3{}:
      {==}
    case L.Coordinate6{} L.Coordinate4{}:
      {==}
    case L.Coordinate6{} L.Coordinate5{}:
      {==}
    case L.Coordinate6{} L.Coordinate6{}:
      {==}
    case L.Coordinate6{} L.Coordinate7{}:
      {==}
    case L.Coordinate6{} L.Coordinate8{}:
      {==}
    case L.Coordinate7{} L.Coordinate0{}:
      {==}
    case L.Coordinate7{} L.Coordinate1{}:
      {==}
    case L.Coordinate7{} L.Coordinate2{}:
      {==}
    case L.Coordinate7{} L.Coordinate3{}:
      {==}
    case L.Coordinate7{} L.Coordinate4{}:
      {==}
    case L.Coordinate7{} L.Coordinate5{}:
      {==}
    case L.Coordinate7{} L.Coordinate6{}:
      {==}
    case L.Coordinate7{} L.Coordinate7{}:
      {==}
    case L.Coordinate7{} L.Coordinate8{}:
      {==}
    case L.Coordinate8{} L.Coordinate0{}:
      {==}
    case L.Coordinate8{} L.Coordinate1{}:
      {==}
    case L.Coordinate8{} L.Coordinate2{}:
      {==}
    case L.Coordinate8{} L.Coordinate3{}:
      {==}
    case L.Coordinate8{} L.Coordinate4{}:
      {==}
    case L.Coordinate8{} L.Coordinate5{}:
      {==}
    case L.Coordinate8{} L.Coordinate6{}:
      {==}
    case L.Coordinate8{} L.Coordinate7{}:
      {==}
    case L.Coordinate8{} L.Coordinate8{}:
      {==}

def L.ordinary_occupancy_setup_keeps_logical_cell(b,row,col,shape):
  +p = L.logical_position(row,col)
  L.cache_setup_sweep_keeps_cell(27n,0,p,b,shape,
    L.cache_setup_route_from_checked(27n,0,p,L.cache_setup_sweep_guard_logical(row,col)))

def L.cache_setup_read_prefix_route(n,remaining,unit,q,whole):
  match n:
    case 0n:
      {==}
    case 1n+k:
      (first,tail) = whole
      (first,L.cache_setup_read_prefix_route(k,remaining,(unit + 1 : U32),q,tail))

def L.cache_setup_read_prefix_known(n,remaining,q,total,whole):
  use : (L.CacheSetupWalkRoutes(27n,0,q) -> L.CacheSetupWalkRoutes(n,0,q)) =
    %total : (L.CacheSetupWalkRoutes(_,0,q) -> L.CacheSetupWalkRoutes(n,0,q))
    full => L.cache_setup_read_prefix_route(n,remaining,0,q,full)
  use(whole)

def L.ordinary_occupancy_prefix_keeps_logical_cell(b,n,remaining,row,col,shape,total):
  +p = L.logical_position(row,col)
  L.cache_setup_sweep_keeps_cell(n,0,p,b,shape,
    L.cache_setup_read_prefix_known(n,remaining,p,total,
      L.cache_setup_route_from_checked(27n,0,p,L.cache_setup_sweep_guard_logical(row,col))))

def L.plain_word_projects(b,q,value,held):
  (shape,read) = held
  read

def L.plain_refresh_keeps_actual_cell_image(image,start,q,shape,apart):
  b = L.image_board(image)
  +v = L.cell_value(L.image_board(image),q)
  L.plain_word_projects(C.refresh_start(b,start),q,v,
    L.plain_pointer_keeps(L.image_board(image),C.refresh_start(b,start),q,v,apart,(shape,{==}),
      L.ordinary_refresh_pointer(L.image_board(image),start)))

def L.plain_refresh_keeps_actual_cell(b,start,q):
  L.on_reified_board(b,x => L.PlainRefreshKeepsCell(x,start,q),
    L.reify_board(b),image => L.plain_refresh_keeps_actual_cell_image(image,start,q))

def L.complete_ordinary_cache_keeps_logical_cell_parts(image,row,col,shapes):
  (s0,s1) = shapes
  b = L.image_board(image)
  +p = L.logical_position(row,col)
  before_refresh = C.cache_units(27n,0,L.image_board(image))
  Equal.trans(U32,L.cell_value(C.cache(b),p),L.cell_value(before_refresh,p),L.cell_value(b,p),
    L.plain_refresh_keeps_actual_cell(C.cache_units(27n,0,L.image_board(image)),0,p)(
      L.cache_setup_full_keeps_shape(27n,0,L.image_board(image),s0),
      L.pointer_route_from_logical(p,L.logical_address_facts(row,col))),
    L.ordinary_occupancy_setup_keeps_logical_cell(L.image_board(image),row,col,s1))

def L.complete_ordinary_cache_keeps_logical_cell(b,row,col,shape):
  +p = L.logical_position(row,col)
  f : (L.Board128(b) -> {L.cell_value(C.cache(b),p) == L.cell_value(b,p) : U32}) =
    L.on_reified_board(b,x => (L.Board128(x) -> {L.cell_value(C.cache(x),p) == L.cell_value(x,p) : U32}),
      L.reify_board(b),image => witness => L.complete_ordinary_cache_keeps_logical_cell_parts(image,row,col,
        L.copy_shape_proof(L.array_shape(L.image_board(image)),L.perfect_shape(7n),witness)))
  f(shape)

def L.actual_unit_route_for_every_cache_slot(group,index):
  match group index:
    case L.CacheRows{} L.Coordinate0{}:
      ((L.Coordinate0{},(L.Coordinate0{},{==})),((L.Coordinate0{},(L.Coordinate1{},{==})),((L.Coordinate0{},(L.Coordinate2{},{==})),((L.Coordinate0{},(L.Coordinate3{},{==})),((L.Coordinate0{},(L.Coordinate4{},{==})),((L.Coordinate0{},(L.Coordinate5{},{==})),((L.Coordinate0{},(L.Coordinate6{},{==})),((L.Coordinate0{},(L.Coordinate7{},{==})),((L.Coordinate0{},(L.Coordinate8{},{==})),{==})))))))))
    case L.CacheRows{} L.Coordinate1{}:
      ((L.Coordinate1{},(L.Coordinate0{},{==})),((L.Coordinate1{},(L.Coordinate1{},{==})),((L.Coordinate1{},(L.Coordinate2{},{==})),((L.Coordinate1{},(L.Coordinate3{},{==})),((L.Coordinate1{},(L.Coordinate4{},{==})),((L.Coordinate1{},(L.Coordinate5{},{==})),((L.Coordinate1{},(L.Coordinate6{},{==})),((L.Coordinate1{},(L.Coordinate7{},{==})),((L.Coordinate1{},(L.Coordinate8{},{==})),{==})))))))))
    case L.CacheRows{} L.Coordinate2{}:
      ((L.Coordinate2{},(L.Coordinate0{},{==})),((L.Coordinate2{},(L.Coordinate1{},{==})),((L.Coordinate2{},(L.Coordinate2{},{==})),((L.Coordinate2{},(L.Coordinate3{},{==})),((L.Coordinate2{},(L.Coordinate4{},{==})),((L.Coordinate2{},(L.Coordinate5{},{==})),((L.Coordinate2{},(L.Coordinate6{},{==})),((L.Coordinate2{},(L.Coordinate7{},{==})),((L.Coordinate2{},(L.Coordinate8{},{==})),{==})))))))))
    case L.CacheRows{} L.Coordinate3{}:
      ((L.Coordinate3{},(L.Coordinate0{},{==})),((L.Coordinate3{},(L.Coordinate1{},{==})),((L.Coordinate3{},(L.Coordinate2{},{==})),((L.Coordinate3{},(L.Coordinate3{},{==})),((L.Coordinate3{},(L.Coordinate4{},{==})),((L.Coordinate3{},(L.Coordinate5{},{==})),((L.Coordinate3{},(L.Coordinate6{},{==})),((L.Coordinate3{},(L.Coordinate7{},{==})),((L.Coordinate3{},(L.Coordinate8{},{==})),{==})))))))))
    case L.CacheRows{} L.Coordinate4{}:
      ((L.Coordinate4{},(L.Coordinate0{},{==})),((L.Coordinate4{},(L.Coordinate1{},{==})),((L.Coordinate4{},(L.Coordinate2{},{==})),((L.Coordinate4{},(L.Coordinate3{},{==})),((L.Coordinate4{},(L.Coordinate4{},{==})),((L.Coordinate4{},(L.Coordinate5{},{==})),((L.Coordinate4{},(L.Coordinate6{},{==})),((L.Coordinate4{},(L.Coordinate7{},{==})),((L.Coordinate4{},(L.Coordinate8{},{==})),{==})))))))))
    case L.CacheRows{} L.Coordinate5{}:
      ((L.Coordinate5{},(L.Coordinate0{},{==})),((L.Coordinate5{},(L.Coordinate1{},{==})),((L.Coordinate5{},(L.Coordinate2{},{==})),((L.Coordinate5{},(L.Coordinate3{},{==})),((L.Coordinate5{},(L.Coordinate4{},{==})),((L.Coordinate5{},(L.Coordinate5{},{==})),((L.Coordinate5{},(L.Coordinate6{},{==})),((L.Coordinate5{},(L.Coordinate7{},{==})),((L.Coordinate5{},(L.Coordinate8{},{==})),{==})))))))))
    case L.CacheRows{} L.Coordinate6{}:
      ((L.Coordinate6{},(L.Coordinate0{},{==})),((L.Coordinate6{},(L.Coordinate1{},{==})),((L.Coordinate6{},(L.Coordinate2{},{==})),((L.Coordinate6{},(L.Coordinate3{},{==})),((L.Coordinate6{},(L.Coordinate4{},{==})),((L.Coordinate6{},(L.Coordinate5{},{==})),((L.Coordinate6{},(L.Coordinate6{},{==})),((L.Coordinate6{},(L.Coordinate7{},{==})),((L.Coordinate6{},(L.Coordinate8{},{==})),{==})))))))))
    case L.CacheRows{} L.Coordinate7{}:
      ((L.Coordinate7{},(L.Coordinate0{},{==})),((L.Coordinate7{},(L.Coordinate1{},{==})),((L.Coordinate7{},(L.Coordinate2{},{==})),((L.Coordinate7{},(L.Coordinate3{},{==})),((L.Coordinate7{},(L.Coordinate4{},{==})),((L.Coordinate7{},(L.Coordinate5{},{==})),((L.Coordinate7{},(L.Coordinate6{},{==})),((L.Coordinate7{},(L.Coordinate7{},{==})),((L.Coordinate7{},(L.Coordinate8{},{==})),{==})))))))))
    case L.CacheRows{} L.Coordinate8{}:
      ((L.Coordinate8{},(L.Coordinate0{},{==})),((L.Coordinate8{},(L.Coordinate1{},{==})),((L.Coordinate8{},(L.Coordinate2{},{==})),((L.Coordinate8{},(L.Coordinate3{},{==})),((L.Coordinate8{},(L.Coordinate4{},{==})),((L.Coordinate8{},(L.Coordinate5{},{==})),((L.Coordinate8{},(L.Coordinate6{},{==})),((L.Coordinate8{},(L.Coordinate7{},{==})),((L.Coordinate8{},(L.Coordinate8{},{==})),{==})))))))))
    case L.CacheColumns{} L.Coordinate0{}:
      ((L.Coordinate0{},(L.Coordinate0{},{==})),((L.Coordinate1{},(L.Coordinate0{},{==})),((L.Coordinate2{},(L.Coordinate0{},{==})),((L.Coordinate3{},(L.Coordinate0{},{==})),((L.Coordinate4{},(L.Coordinate0{},{==})),((L.Coordinate5{},(L.Coordinate0{},{==})),((L.Coordinate6{},(L.Coordinate0{},{==})),((L.Coordinate7{},(L.Coordinate0{},{==})),((L.Coordinate8{},(L.Coordinate0{},{==})),{==})))))))))
    case L.CacheColumns{} L.Coordinate1{}:
      ((L.Coordinate0{},(L.Coordinate1{},{==})),((L.Coordinate1{},(L.Coordinate1{},{==})),((L.Coordinate2{},(L.Coordinate1{},{==})),((L.Coordinate3{},(L.Coordinate1{},{==})),((L.Coordinate4{},(L.Coordinate1{},{==})),((L.Coordinate5{},(L.Coordinate1{},{==})),((L.Coordinate6{},(L.Coordinate1{},{==})),((L.Coordinate7{},(L.Coordinate1{},{==})),((L.Coordinate8{},(L.Coordinate1{},{==})),{==})))))))))
    case L.CacheColumns{} L.Coordinate2{}:
      ((L.Coordinate0{},(L.Coordinate2{},{==})),((L.Coordinate1{},(L.Coordinate2{},{==})),((L.Coordinate2{},(L.Coordinate2{},{==})),((L.Coordinate3{},(L.Coordinate2{},{==})),((L.Coordinate4{},(L.Coordinate2{},{==})),((L.Coordinate5{},(L.Coordinate2{},{==})),((L.Coordinate6{},(L.Coordinate2{},{==})),((L.Coordinate7{},(L.Coordinate2{},{==})),((L.Coordinate8{},(L.Coordinate2{},{==})),{==})))))))))
    case L.CacheColumns{} L.Coordinate3{}:
      ((L.Coordinate0{},(L.Coordinate3{},{==})),((L.Coordinate1{},(L.Coordinate3{},{==})),((L.Coordinate2{},(L.Coordinate3{},{==})),((L.Coordinate3{},(L.Coordinate3{},{==})),((L.Coordinate4{},(L.Coordinate3{},{==})),((L.Coordinate5{},(L.Coordinate3{},{==})),((L.Coordinate6{},(L.Coordinate3{},{==})),((L.Coordinate7{},(L.Coordinate3{},{==})),((L.Coordinate8{},(L.Coordinate3{},{==})),{==})))))))))
    case L.CacheColumns{} L.Coordinate4{}:
      ((L.Coordinate0{},(L.Coordinate4{},{==})),((L.Coordinate1{},(L.Coordinate4{},{==})),((L.Coordinate2{},(L.Coordinate4{},{==})),((L.Coordinate3{},(L.Coordinate4{},{==})),((L.Coordinate4{},(L.Coordinate4{},{==})),((L.Coordinate5{},(L.Coordinate4{},{==})),((L.Coordinate6{},(L.Coordinate4{},{==})),((L.Coordinate7{},(L.Coordinate4{},{==})),((L.Coordinate8{},(L.Coordinate4{},{==})),{==})))))))))
    case L.CacheColumns{} L.Coordinate5{}:
      ((L.Coordinate0{},(L.Coordinate5{},{==})),((L.Coordinate1{},(L.Coordinate5{},{==})),((L.Coordinate2{},(L.Coordinate5{},{==})),((L.Coordinate3{},(L.Coordinate5{},{==})),((L.Coordinate4{},(L.Coordinate5{},{==})),((L.Coordinate5{},(L.Coordinate5{},{==})),((L.Coordinate6{},(L.Coordinate5{},{==})),((L.Coordinate7{},(L.Coordinate5{},{==})),((L.Coordinate8{},(L.Coordinate5{},{==})),{==})))))))))
    case L.CacheColumns{} L.Coordinate6{}:
      ((L.Coordinate0{},(L.Coordinate6{},{==})),((L.Coordinate1{},(L.Coordinate6{},{==})),((L.Coordinate2{},(L.Coordinate6{},{==})),((L.Coordinate3{},(L.Coordinate6{},{==})),((L.Coordinate4{},(L.Coordinate6{},{==})),((L.Coordinate5{},(L.Coordinate6{},{==})),((L.Coordinate6{},(L.Coordinate6{},{==})),((L.Coordinate7{},(L.Coordinate6{},{==})),((L.Coordinate8{},(L.Coordinate6{},{==})),{==})))))))))
    case L.CacheColumns{} L.Coordinate7{}:
      ((L.Coordinate0{},(L.Coordinate7{},{==})),((L.Coordinate1{},(L.Coordinate7{},{==})),((L.Coordinate2{},(L.Coordinate7{},{==})),((L.Coordinate3{},(L.Coordinate7{},{==})),((L.Coordinate4{},(L.Coordinate7{},{==})),((L.Coordinate5{},(L.Coordinate7{},{==})),((L.Coordinate6{},(L.Coordinate7{},{==})),((L.Coordinate7{},(L.Coordinate7{},{==})),((L.Coordinate8{},(L.Coordinate7{},{==})),{==})))))))))
    case L.CacheColumns{} L.Coordinate8{}:
      ((L.Coordinate0{},(L.Coordinate8{},{==})),((L.Coordinate1{},(L.Coordinate8{},{==})),((L.Coordinate2{},(L.Coordinate8{},{==})),((L.Coordinate3{},(L.Coordinate8{},{==})),((L.Coordinate4{},(L.Coordinate8{},{==})),((L.Coordinate5{},(L.Coordinate8{},{==})),((L.Coordinate6{},(L.Coordinate8{},{==})),((L.Coordinate7{},(L.Coordinate8{},{==})),((L.Coordinate8{},(L.Coordinate8{},{==})),{==})))))))))
    case L.CacheBoxes{} L.Coordinate0{}:
      ((L.Coordinate0{},(L.Coordinate0{},{==})),((L.Coordinate0{},(L.Coordinate1{},{==})),((L.Coordinate0{},(L.Coordinate2{},{==})),((L.Coordinate1{},(L.Coordinate0{},{==})),((L.Coordinate1{},(L.Coordinate1{},{==})),((L.Coordinate1{},(L.Coordinate2{},{==})),((L.Coordinate2{},(L.Coordinate0{},{==})),((L.Coordinate2{},(L.Coordinate1{},{==})),((L.Coordinate2{},(L.Coordinate2{},{==})),{==})))))))))
    case L.CacheBoxes{} L.Coordinate1{}:
      ((L.Coordinate0{},(L.Coordinate3{},{==})),((L.Coordinate0{},(L.Coordinate4{},{==})),((L.Coordinate0{},(L.Coordinate5{},{==})),((L.Coordinate1{},(L.Coordinate3{},{==})),((L.Coordinate1{},(L.Coordinate4{},{==})),((L.Coordinate1{},(L.Coordinate5{},{==})),((L.Coordinate2{},(L.Coordinate3{},{==})),((L.Coordinate2{},(L.Coordinate4{},{==})),((L.Coordinate2{},(L.Coordinate5{},{==})),{==})))))))))
    case L.CacheBoxes{} L.Coordinate2{}:
      ((L.Coordinate0{},(L.Coordinate6{},{==})),((L.Coordinate0{},(L.Coordinate7{},{==})),((L.Coordinate0{},(L.Coordinate8{},{==})),((L.Coordinate1{},(L.Coordinate6{},{==})),((L.Coordinate1{},(L.Coordinate7{},{==})),((L.Coordinate1{},(L.Coordinate8{},{==})),((L.Coordinate2{},(L.Coordinate6{},{==})),((L.Coordinate2{},(L.Coordinate7{},{==})),((L.Coordinate2{},(L.Coordinate8{},{==})),{==})))))))))
    case L.CacheBoxes{} L.Coordinate3{}:
      ((L.Coordinate3{},(L.Coordinate0{},{==})),((L.Coordinate3{},(L.Coordinate1{},{==})),((L.Coordinate3{},(L.Coordinate2{},{==})),((L.Coordinate4{},(L.Coordinate0{},{==})),((L.Coordinate4{},(L.Coordinate1{},{==})),((L.Coordinate4{},(L.Coordinate2{},{==})),((L.Coordinate5{},(L.Coordinate0{},{==})),((L.Coordinate5{},(L.Coordinate1{},{==})),((L.Coordinate5{},(L.Coordinate2{},{==})),{==})))))))))
    case L.CacheBoxes{} L.Coordinate4{}:
      ((L.Coordinate3{},(L.Coordinate3{},{==})),((L.Coordinate3{},(L.Coordinate4{},{==})),((L.Coordinate3{},(L.Coordinate5{},{==})),((L.Coordinate4{},(L.Coordinate3{},{==})),((L.Coordinate4{},(L.Coordinate4{},{==})),((L.Coordinate4{},(L.Coordinate5{},{==})),((L.Coordinate5{},(L.Coordinate3{},{==})),((L.Coordinate5{},(L.Coordinate4{},{==})),((L.Coordinate5{},(L.Coordinate5{},{==})),{==})))))))))
    case L.CacheBoxes{} L.Coordinate5{}:
      ((L.Coordinate3{},(L.Coordinate6{},{==})),((L.Coordinate3{},(L.Coordinate7{},{==})),((L.Coordinate3{},(L.Coordinate8{},{==})),((L.Coordinate4{},(L.Coordinate6{},{==})),((L.Coordinate4{},(L.Coordinate7{},{==})),((L.Coordinate4{},(L.Coordinate8{},{==})),((L.Coordinate5{},(L.Coordinate6{},{==})),((L.Coordinate5{},(L.Coordinate7{},{==})),((L.Coordinate5{},(L.Coordinate8{},{==})),{==})))))))))
    case L.CacheBoxes{} L.Coordinate6{}:
      ((L.Coordinate6{},(L.Coordinate0{},{==})),((L.Coordinate6{},(L.Coordinate1{},{==})),((L.Coordinate6{},(L.Coordinate2{},{==})),((L.Coordinate7{},(L.Coordinate0{},{==})),((L.Coordinate7{},(L.Coordinate1{},{==})),((L.Coordinate7{},(L.Coordinate2{},{==})),((L.Coordinate8{},(L.Coordinate0{},{==})),((L.Coordinate8{},(L.Coordinate1{},{==})),((L.Coordinate8{},(L.Coordinate2{},{==})),{==})))))))))
    case L.CacheBoxes{} L.Coordinate7{}:
      ((L.Coordinate6{},(L.Coordinate3{},{==})),((L.Coordinate6{},(L.Coordinate4{},{==})),((L.Coordinate6{},(L.Coordinate5{},{==})),((L.Coordinate7{},(L.Coordinate3{},{==})),((L.Coordinate7{},(L.Coordinate4{},{==})),((L.Coordinate7{},(L.Coordinate5{},{==})),((L.Coordinate8{},(L.Coordinate3{},{==})),((L.Coordinate8{},(L.Coordinate4{},{==})),((L.Coordinate8{},(L.Coordinate5{},{==})),{==})))))))))
    case L.CacheBoxes{} L.Coordinate8{}:
      ((L.Coordinate6{},(L.Coordinate6{},{==})),((L.Coordinate6{},(L.Coordinate7{},{==})),((L.Coordinate6{},(L.Coordinate8{},{==})),((L.Coordinate7{},(L.Coordinate6{},{==})),((L.Coordinate7{},(L.Coordinate7{},{==})),((L.Coordinate7{},(L.Coordinate8{},{==})),((L.Coordinate8{},(L.Coordinate6{},{==})),((L.Coordinate8{},(L.Coordinate7{},{==})),((L.Coordinate8{},(L.Coordinate8{},{==})),{==})))))))))

def L.direct_fold_agrees_on_unit_reads(n,unit,j,a,b,used,reads):
  match n:
    case 0n:
      {==}
    case 1n+k:
      (same,later) = reads
      +p = Board.unit_pos(unit,j)
      +a_word = L.cell_value(L.image_board(a),p)
      +b_word = L.cell_value(L.image_board(b),p)
      +next = (j + 1 : U32)
      %Equal.sym(U32,a_word,b_word,same) :
        {L.direct_unit_fold(k,unit,next,a,U32.or(used,Board.bit(_))) ==
          L.direct_unit_fold(k,unit,next,b,U32.or(used,Board.bit(b_word))) : U32}
      L.direct_fold_agrees_on_unit_reads(k,unit,next,a,b,U32.or(used,Board.bit(b_word)),later)

def L.occupancy_prefix_one_unit_read(image,prefix,remaining,at,shape,total,coordinate):
  (+row,(+col,same)) = coordinate
  b = L.image_board(image)
  out = C.cache_units(prefix,0,L.image_board(image))
  %Equal.sym(U32,at,L.logical_position(row,col),same) :
    {L.cell_value(out,_) == L.cell_value(b,_) : U32}
  L.ordinary_occupancy_prefix_keeps_logical_cell(L.image_board(image),prefix,remaining,row,col,shape,total)

def L.occupancy_prefix_unit_agreement_step(image,prefix,remaining,n,unit,j,shapes,totals,route,next):
  (s0,s1) = shapes
  (t0,(t1,t2)) = totals
  (here,later) = route
  (L.occupancy_prefix_one_unit_read(image,prefix,remaining,Board.unit_pos(unit,j),s0,t0,here),
    next(s1,t1,later))

def L.occupancy_prefix_unit_agreement(image,prefix,remaining,n,unit,j,shape,total,route):
  match n:
    case 0n:
      {==}
    case 1n+k:
      L.occupancy_prefix_unit_agreement_step(image,prefix,remaining,k,unit,j,
        L.copy_shape_proof(L.array_shape(L.image_board(image)),L.perfect_shape(7n),shape),
        L.copy_nat_eq(Nat.add(prefix,remaining),27n,total),route,
        witness => counted => rest => L.occupancy_prefix_unit_agreement(image,prefix,remaining,k,unit,(j + 1 : U32),witness,counted,rest))

def L.production_unit_result_agrees_if_reads_image(next,image,unit,reads):
  b = L.image_board(next)
  +val = L.direct_unit_fold(9n,unit,0,next,0)
  %Equal.sym(Array<U32> & U32,C.unit_used(b,unit),(b,val),L.direct_unit_used_image(next,unit)) :
    {Pair.snd(Array<U32>,U32,_) == L.direct_unit_fold(9n,unit,0,image,0) : U32}
  L.direct_fold_agrees_on_unit_reads(9n,unit,0,next,image,0,reads)

def L.occupancy_prefix_frozen_direct_fold(image,prefix,remaining,group,index,shape,total):
  +unit = L.group_unit(group,index)
  b = L.image_board(image)
  out = C.cache_units(prefix,0,L.image_board(image))
  f : (L.UnitFoldAgreement(9n,unit,0,out,b) -> {Pair.snd(Array<U32>,U32,C.unit_used(out,unit)) == L.direct_unit_fold(9n,unit,0,image,0) : U32}) =
    L.on_reified_board(out,x => (L.UnitFoldAgreement(9n,unit,0,x,b) ->
      {Pair.snd(Array<U32>,U32,C.unit_used(x,unit)) == L.direct_unit_fold(9n,unit,0,image,0) : U32}),
      L.reify_board(C.cache_units(prefix,0,L.image_board(image))),next => reads => L.production_unit_result_agrees_if_reads_image(next,image,unit,reads))
  f(L.occupancy_prefix_unit_agreement(image,prefix,remaining,9n,unit,0,shape,total,L.actual_unit_route_for_every_cache_slot(group,index)))

def L.cache_units_split_at_prefix(prefix,suffix,unit,b):
  match prefix:
    case 0n:
      {==}
    case 1n+k:
      L.cache_units_split_at_prefix(k,suffix,(unit + 1 : U32),L.cache_setup_step(unit,b))

def L.checked_cache_window(group,index):
  match group index:
    case L.CacheRows{} L.Coordinate0{}:
      ({==},({==},({==},{==})))
    case L.CacheRows{} L.Coordinate1{}:
      ({==},({==},({==},{==})))
    case L.CacheRows{} L.Coordinate2{}:
      ({==},({==},({==},{==})))
    case L.CacheRows{} L.Coordinate3{}:
      ({==},({==},({==},{==})))
    case L.CacheRows{} L.Coordinate4{}:
      ({==},({==},({==},{==})))
    case L.CacheRows{} L.Coordinate5{}:
      ({==},({==},({==},{==})))
    case L.CacheRows{} L.Coordinate6{}:
      ({==},({==},({==},{==})))
    case L.CacheRows{} L.Coordinate7{}:
      ({==},({==},({==},{==})))
    case L.CacheRows{} L.Coordinate8{}:
      ({==},({==},({==},{==})))
    case L.CacheColumns{} L.Coordinate0{}:
      ({==},({==},({==},{==})))
    case L.CacheColumns{} L.Coordinate1{}:
      ({==},({==},({==},{==})))
    case L.CacheColumns{} L.Coordinate2{}:
      ({==},({==},({==},{==})))
    case L.CacheColumns{} L.Coordinate3{}:
      ({==},({==},({==},{==})))
    case L.CacheColumns{} L.Coordinate4{}:
      ({==},({==},({==},{==})))
    case L.CacheColumns{} L.Coordinate5{}:
      ({==},({==},({==},{==})))
    case L.CacheColumns{} L.Coordinate6{}:
      ({==},({==},({==},{==})))
    case L.CacheColumns{} L.Coordinate7{}:
      ({==},({==},({==},{==})))
    case L.CacheColumns{} L.Coordinate8{}:
      ({==},({==},({==},{==})))
    case L.CacheBoxes{} L.Coordinate0{}:
      ({==},({==},({==},{==})))
    case L.CacheBoxes{} L.Coordinate1{}:
      ({==},({==},({==},{==})))
    case L.CacheBoxes{} L.Coordinate2{}:
      ({==},({==},({==},{==})))
    case L.CacheBoxes{} L.Coordinate3{}:
      ({==},({==},({==},{==})))
    case L.CacheBoxes{} L.Coordinate4{}:
      ({==},({==},({==},{==})))
    case L.CacheBoxes{} L.Coordinate5{}:
      ({==},({==},({==},{==})))
    case L.CacheBoxes{} L.Coordinate6{}:
      ({==},({==},({==},{==})))
    case L.CacheBoxes{} L.Coordinate7{}:
      ({==},({==},({==},{==})))
    case L.CacheBoxes{} L.Coordinate8{}:
      ({==},({==},({==},{==})))

def L.full_ordinary_setup_as_local_cache_write(group,index,b,count):
  +n = L.group_unit_nat(group,index)
  +m = L.cache_tail_count(group,index)
  +i = L.group_unit(group,index)
  %count : {C.cache_units(_,0,b) == C.cache_units(m,(i + 1 : U32),L.cache_setup_step(i,C.cache_units(n,0,b))) : Array<U32>}
  L.cache_units_split_at_prefix(n,1n+m,0,b)

def L.cache_group_row_test(group,index):
  match group index:
    case L.CacheRows{} L.Coordinate0{}:
      {==}
    case L.CacheRows{} L.Coordinate1{}:
      {==}
    case L.CacheRows{} L.Coordinate2{}:
      {==}
    case L.CacheRows{} L.Coordinate3{}:
      {==}
    case L.CacheRows{} L.Coordinate4{}:
      {==}
    case L.CacheRows{} L.Coordinate5{}:
      {==}
    case L.CacheRows{} L.Coordinate6{}:
      {==}
    case L.CacheRows{} L.Coordinate7{}:
      {==}
    case L.CacheRows{} L.Coordinate8{}:
      {==}
    case L.CacheColumns{} L.Coordinate0{}:
      {==}
    case L.CacheColumns{} L.Coordinate1{}:
      {==}
    case L.CacheColumns{} L.Coordinate2{}:
      {==}
    case L.CacheColumns{} L.Coordinate3{}:
      {==}
    case L.CacheColumns{} L.Coordinate4{}:
      {==}
    case L.CacheColumns{} L.Coordinate5{}:
      {==}
    case L.CacheColumns{} L.Coordinate6{}:
      {==}
    case L.CacheColumns{} L.Coordinate7{}:
      {==}
    case L.CacheColumns{} L.Coordinate8{}:
      {==}
    case L.CacheBoxes{} L.Coordinate0{}:
      {==}
    case L.CacheBoxes{} L.Coordinate1{}:
      {==}
    case L.CacheBoxes{} L.Coordinate2{}:
      {==}
    case L.CacheBoxes{} L.Coordinate3{}:
      {==}
    case L.CacheBoxes{} L.Coordinate4{}:
      {==}
    case L.CacheBoxes{} L.Coordinate5{}:
      {==}
    case L.CacheBoxes{} L.Coordinate6{}:
      {==}
    case L.CacheBoxes{} L.Coordinate7{}:
      {==}
    case L.CacheBoxes{} L.Coordinate8{}:
      {==}

def L.cache_one_narrow_nonrow(image,unit):
  b = L.image_board(image)
  +slot = (81 + unit : U32)
  +used = L.direct_unit_fold(9n,unit,0,image,0)
  %Equal.sym(Array<U32> & U32,C.unit_used(b,unit),(b,used),L.direct_unit_used_image(image,unit)) :
    {U32.and(1022,L.cell_value(C.cache_unit_done(slot,_),slot)) == U32.and(1022,Pair.snd(Array<U32>,U32,_)) : U32}
  Equal.cong(U32,U32,x => U32.and(1022,x),L.cell_value(Board.set_cell(b,slot,used),slot),used,L.board_set_get(L.image_board(image),slot,used))

def L.cache_one_narrow_row(image,index):
  b = L.image_board(image)
  +unit = L.coord_u32(index)
  +slot = (81 + unit : U32)
  %Equal.sym(Array<U32> & U32,C.unit_used(b,unit),(b,L.direct_unit_fold(9n,unit,0,image,0)),L.direct_unit_used_image(image,unit)) :
    {U32.and(1022,L.cell_value(C.cache_unit_done(slot,C.cached_used(True{},unit,b)),slot)) == U32.and(1022,Pair.snd(Array<U32>,U32,_)) : U32}
  L.cached_row_setup_digits_match_direct(image,index)

def L.cache_one_group_write_image(image,group,index,kind):
  match group:
    case L.CacheRows{}:
      b = L.image_board(image)
      +i = L.coord_u32(index)
      +slot = (81 + i : U32)
      %Equal.sym(Bool,(i < 9 : U32),True{},kind) :
        {U32.and(1022,L.cell_value(C.cache_unit_done(slot,C.cached_used(_,i,b)),slot)) ==
          U32.and(1022,Pair.snd(Array<U32>,U32,C.unit_used(b,i))) : U32}
      L.cache_one_narrow_row(image,index)
    case L.CacheColumns{}:
      b = L.image_board(image)
      +i = L.group_unit(L.CacheColumns{},index)
      +slot = (81 + i : U32)
      %Equal.sym(Bool,(i < 9 : U32),False{},kind) :
        {U32.and(1022,L.cell_value(C.cache_unit_done(slot,C.cached_used(_,i,b)),slot)) ==
          U32.and(1022,Pair.snd(Array<U32>,U32,C.unit_used(b,i))) : U32}
      L.cache_one_narrow_nonrow(image,i)
    case L.CacheBoxes{}:
      b = L.image_board(image)
      +i = L.group_unit(L.CacheBoxes{},index)
      +slot = (81 + i : U32)
      %Equal.sym(Bool,(i < 9 : U32),False{},kind) :
        {U32.and(1022,L.cell_value(C.cache_unit_done(slot,C.cached_used(_,i,b)),slot)) ==
          U32.and(1022,Pair.snd(Array<U32>,U32,C.unit_used(b,i))) : U32}
      L.cache_one_narrow_nonrow(image,i)

def L.cache_one_group_write(b,group,index):
  L.on_reified_board(b,x => L.CacheOneProjectedWrite(x,group,index),
    L.reify_board(b),image => L.cache_one_group_write_image(image,group,index,L.cache_group_row_test(group,index)))

def L.cache_units_complete_target(image,group,index,shape,totals,guards,pre_shape):
  (first,(second,unused)) = totals
  b = L.image_board(image)
  +n = L.group_unit_nat(group,index)
  +m = L.cache_tail_count(group,index)
  +i = L.group_unit(group,index)
  +q = L.actual_cache_target(group,index)
  mid = C.cache_units(n,0,L.image_board(image))
  wrote = L.cache_setup_step(i,C.cache_units(n,0,L.image_board(image)))
  result = C.cache_units(m,(i + 1 : U32),L.cache_setup_step(i,C.cache_units(n,0,L.image_board(image))))
  +direct = L.direct_unit_fold(9n,i,0,image,0)
  %Equal.sym(Array<U32>,C.cache_units(27n,0,b),result,L.full_ordinary_setup_as_local_cache_write(group,index,L.image_board(image),first)) :
    {U32.and(1022,L.cell_value(_,q)) == U32.and(1022,direct) : U32}
  %Equal.sym(U32,L.cell_value(result,q),L.cell_value(wrote,q),
    L.cache_setup_sweep_keeps_cell(m,(i + 1 : U32),q,L.cache_setup_step(i,C.cache_units(n,0,L.image_board(image))),
      L.cache_setup_step_keeps_shape(C.cache_units(n,0,L.image_board(image)),i,
        L.cache_setup_full_keeps_shape(n,0,L.image_board(image),pre_shape)),
      L.cache_setup_route_from_checked(m,(i + 1 : U32),q,guards))) :
    {U32.and(1022,_) == U32.and(1022,direct) : U32}
  %Equal.sym(U32,U32.and(1022,L.cell_value(wrote,q)),U32.and(1022,Pair.snd(Array<U32>,U32,C.unit_used(mid,i))),
    L.cache_one_group_write(C.cache_units(n,0,L.image_board(image)),group,index)) :
    {_ == U32.and(1022,direct) : U32}
  Equal.cong(U32,U32,x => U32.and(1022,x),Pair.snd(Array<U32>,U32,C.unit_used(mid,i)),direct,
    L.occupancy_prefix_frozen_direct_fold(image,n,1n+m,group,index,shape,second))

def L.complete_cache_sets_unit_digits_parts(image,group,index,shapes,window):
  (s0,(s1,s2)) = shapes
  (count,(gu,(apart,alias))) = window
  b = L.image_board(image)
  +q = L.actual_cache_target(group,index)
  +i = L.group_unit(group,index)
  +n = L.group_unit_nat(group,index)
  +m = L.cache_tail_count(group,index)
  +direct = L.direct_unit_fold(9n,i,0,image,0)
  prior = C.cache_units(27n,0,L.image_board(image))
  %alias : {U32.and(1022,L.cell_value(C.cache(b),_)) == U32.and(1022,direct) : U32}
  %Equal.sym(U32,L.cell_value(C.cache(b),q),L.cell_value(prior,q),
    L.plain_refresh_keeps_actual_cell(C.cache_units(27n,0,L.image_board(image)),0,q)(
      L.cache_setup_full_keeps_shape(27n,0,L.image_board(image),s0),apart)) :
    {U32.and(1022,_) == U32.and(1022,direct) : U32}
  L.cache_units_complete_target(image,group,index,s1,L.copy_nat_eq(Nat.add(n,1n+m),27n,count),gu,s2)

def L.complete_cache_sets_unit_digits(image,group,index,shape):
  L.complete_cache_sets_unit_digits_parts(image,group,index,
    L.copy_shape_three(L.array_shape(L.image_board(image)),L.perfect_shape(7n),shape),
    L.checked_cache_window(group,index))

def L.cache_scan_geometry(row,col):
  match row col:
    case L.Coordinate0{} L.Coordinate0{}:
      ({==},({==},{==}))
    case L.Coordinate0{} L.Coordinate1{}:
      ({==},({==},{==}))
    case L.Coordinate0{} L.Coordinate2{}:
      ({==},({==},{==}))
    case L.Coordinate0{} L.Coordinate3{}:
      ({==},({==},{==}))
    case L.Coordinate0{} L.Coordinate4{}:
      ({==},({==},{==}))
    case L.Coordinate0{} L.Coordinate5{}:
      ({==},({==},{==}))
    case L.Coordinate0{} L.Coordinate6{}:
      ({==},({==},{==}))
    case L.Coordinate0{} L.Coordinate7{}:
      ({==},({==},{==}))
    case L.Coordinate0{} L.Coordinate8{}:
      ({==},({==},{==}))
    case L.Coordinate1{} L.Coordinate0{}:
      ({==},({==},{==}))
    case L.Coordinate1{} L.Coordinate1{}:
      ({==},({==},{==}))
    case L.Coordinate1{} L.Coordinate2{}:
      ({==},({==},{==}))
    case L.Coordinate1{} L.Coordinate3{}:
      ({==},({==},{==}))
    case L.Coordinate1{} L.Coordinate4{}:
      ({==},({==},{==}))
    case L.Coordinate1{} L.Coordinate5{}:
      ({==},({==},{==}))
    case L.Coordinate1{} L.Coordinate6{}:
      ({==},({==},{==}))
    case L.Coordinate1{} L.Coordinate7{}:
      ({==},({==},{==}))
    case L.Coordinate1{} L.Coordinate8{}:
      ({==},({==},{==}))
    case L.Coordinate2{} L.Coordinate0{}:
      ({==},({==},{==}))
    case L.Coordinate2{} L.Coordinate1{}:
      ({==},({==},{==}))
    case L.Coordinate2{} L.Coordinate2{}:
      ({==},({==},{==}))
    case L.Coordinate2{} L.Coordinate3{}:
      ({==},({==},{==}))
    case L.Coordinate2{} L.Coordinate4{}:
      ({==},({==},{==}))
    case L.Coordinate2{} L.Coordinate5{}:
      ({==},({==},{==}))
    case L.Coordinate2{} L.Coordinate6{}:
      ({==},({==},{==}))
    case L.Coordinate2{} L.Coordinate7{}:
      ({==},({==},{==}))
    case L.Coordinate2{} L.Coordinate8{}:
      ({==},({==},{==}))
    case L.Coordinate3{} L.Coordinate0{}:
      ({==},({==},{==}))
    case L.Coordinate3{} L.Coordinate1{}:
      ({==},({==},{==}))
    case L.Coordinate3{} L.Coordinate2{}:
      ({==},({==},{==}))
    case L.Coordinate3{} L.Coordinate3{}:
      ({==},({==},{==}))
    case L.Coordinate3{} L.Coordinate4{}:
      ({==},({==},{==}))
    case L.Coordinate3{} L.Coordinate5{}:
      ({==},({==},{==}))
    case L.Coordinate3{} L.Coordinate6{}:
      ({==},({==},{==}))
    case L.Coordinate3{} L.Coordinate7{}:
      ({==},({==},{==}))
    case L.Coordinate3{} L.Coordinate8{}:
      ({==},({==},{==}))
    case L.Coordinate4{} L.Coordinate0{}:
      ({==},({==},{==}))
    case L.Coordinate4{} L.Coordinate1{}:
      ({==},({==},{==}))
    case L.Coordinate4{} L.Coordinate2{}:
      ({==},({==},{==}))
    case L.Coordinate4{} L.Coordinate3{}:
      ({==},({==},{==}))
    case L.Coordinate4{} L.Coordinate4{}:
      ({==},({==},{==}))
    case L.Coordinate4{} L.Coordinate5{}:
      ({==},({==},{==}))
    case L.Coordinate4{} L.Coordinate6{}:
      ({==},({==},{==}))
    case L.Coordinate4{} L.Coordinate7{}:
      ({==},({==},{==}))
    case L.Coordinate4{} L.Coordinate8{}:
      ({==},({==},{==}))
    case L.Coordinate5{} L.Coordinate0{}:
      ({==},({==},{==}))
    case L.Coordinate5{} L.Coordinate1{}:
      ({==},({==},{==}))
    case L.Coordinate5{} L.Coordinate2{}:
      ({==},({==},{==}))
    case L.Coordinate5{} L.Coordinate3{}:
      ({==},({==},{==}))
    case L.Coordinate5{} L.Coordinate4{}:
      ({==},({==},{==}))
    case L.Coordinate5{} L.Coordinate5{}:
      ({==},({==},{==}))
    case L.Coordinate5{} L.Coordinate6{}:
      ({==},({==},{==}))
    case L.Coordinate5{} L.Coordinate7{}:
      ({==},({==},{==}))
    case L.Coordinate5{} L.Coordinate8{}:
      ({==},({==},{==}))
    case L.Coordinate6{} L.Coordinate0{}:
      ({==},({==},{==}))
    case L.Coordinate6{} L.Coordinate1{}:
      ({==},({==},{==}))
    case L.Coordinate6{} L.Coordinate2{}:
      ({==},({==},{==}))
    case L.Coordinate6{} L.Coordinate3{}:
      ({==},({==},{==}))
    case L.Coordinate6{} L.Coordinate4{}:
      ({==},({==},{==}))
    case L.Coordinate6{} L.Coordinate5{}:
      ({==},({==},{==}))
    case L.Coordinate6{} L.Coordinate6{}:
      ({==},({==},{==}))
    case L.Coordinate6{} L.Coordinate7{}:
      ({==},({==},{==}))
    case L.Coordinate6{} L.Coordinate8{}:
      ({==},({==},{==}))
    case L.Coordinate7{} L.Coordinate0{}:
      ({==},({==},{==}))
    case L.Coordinate7{} L.Coordinate1{}:
      ({==},({==},{==}))
    case L.Coordinate7{} L.Coordinate2{}:
      ({==},({==},{==}))
    case L.Coordinate7{} L.Coordinate3{}:
      ({==},({==},{==}))
    case L.Coordinate7{} L.Coordinate4{}:
      ({==},({==},{==}))
    case L.Coordinate7{} L.Coordinate5{}:
      ({==},({==},{==}))
    case L.Coordinate7{} L.Coordinate6{}:
      ({==},({==},{==}))
    case L.Coordinate7{} L.Coordinate7{}:
      ({==},({==},{==}))
    case L.Coordinate7{} L.Coordinate8{}:
      ({==},({==},{==}))
    case L.Coordinate8{} L.Coordinate0{}:
      ({==},({==},{==}))
    case L.Coordinate8{} L.Coordinate1{}:
      ({==},({==},{==}))
    case L.Coordinate8{} L.Coordinate2{}:
      ({==},({==},{==}))
    case L.Coordinate8{} L.Coordinate3{}:
      ({==},({==},{==}))
    case L.Coordinate8{} L.Coordinate4{}:
      ({==},({==},{==}))
    case L.Coordinate8{} L.Coordinate5{}:
      ({==},({==},{==}))
    case L.Coordinate8{} L.Coordinate6{}:
      ({==},({==},{==}))
    case L.Coordinate8{} L.Coordinate7{}:
      ({==},({==},{==}))
    case L.Coordinate8{} L.Coordinate8{}:
      ({==},({==},{==}))

def L.complete_cache_original_projection_parts(image,row,col,shapes,slots,units):
  (s0,(s1,s2)) = shapes
  (rs,(cs,bs)) = slots
  (ri,(ci,bi)) = units
  +box = L.box_coordinate(row,col)
  +p = L.logical_position(row,col)
  +dr = L.group_unit(L.CacheRows{},row)
  +dc = L.group_unit(L.CacheColumns{},col)
  +db = L.group_unit(L.CacheBoxes{},box)
  +r = L.cache_group_slot(L.CacheRows{},row)
  +c = L.cache_group_slot(L.CacheColumns{},col)
  +k = L.cache_group_slot(L.CacheBoxes{},box)
  out = C.cache(L.image_board(image))
  %Equal.sym(U32,L.ordinary_row_slot(p),r,rs) :
    L.ThreeDigitWordsAgree(L.cell_value(out,_),L.cell_value(out,L.ordinary_col_slot(p)),L.cell_value(out,L.ordinary_box_slot(p)),
      L.direct_row_word(image,p),L.direct_col_word(image,p),L.direct_box_word(image,p))
  %Equal.sym(U32,L.ordinary_col_slot(p),c,cs) :
    L.ThreeDigitWordsAgree(L.cell_value(out,r),L.cell_value(out,_),L.cell_value(out,L.ordinary_box_slot(p)),
      L.direct_row_word(image,p),L.direct_col_word(image,p),L.direct_box_word(image,p))
  %Equal.sym(U32,L.ordinary_box_slot(p),k,bs) :
    L.ThreeDigitWordsAgree(L.cell_value(out,r),L.cell_value(out,c),L.cell_value(out,_),
      L.direct_row_word(image,p),L.direct_col_word(image,p),L.direct_box_word(image,p))
  %Equal.sym(U32,M.div9(p),dr,ri) :
    L.ThreeDigitWordsAgree(L.cell_value(out,r),L.cell_value(out,c),L.cell_value(out,k),
      L.direct_unit_fold(9n,_,0,image,0),L.direct_col_word(image,p),L.direct_box_word(image,p))
  %Equal.sym(U32,(9 + M.rem9(p) : U32),dc,ci) :
    L.ThreeDigitWordsAgree(L.cell_value(out,r),L.cell_value(out,c),L.cell_value(out,k),
      L.direct_unit_fold(9n,dr,0,image,0),L.direct_unit_fold(9n,_,0,image,0),L.direct_box_word(image,p))
  %Equal.sym(U32,(18 + Board.box_of(p) : U32),db,bi) :
    L.ThreeDigitWordsAgree(L.cell_value(out,r),L.cell_value(out,c),L.cell_value(out,k),
      L.direct_unit_fold(9n,dr,0,image,0),L.direct_unit_fold(9n,dc,0,image,0),L.direct_unit_fold(9n,_,0,image,0))
  (L.complete_cache_sets_unit_digits(image,L.CacheRows{},row,s0),
      (L.complete_cache_sets_unit_digits(image,L.CacheColumns{},col,s1),
       L.complete_cache_sets_unit_digits(image,L.CacheBoxes{},box,s2)))

def L.cached_word_from_recomputed_projection(next,original,p,equal):
  a = L.image_board(next)
  b = L.image_board(original)
  +r = L.cell_value(L.image_board(next),L.ordinary_row_slot(p))
  +c = L.cell_value(L.image_board(next),L.ordinary_col_slot(p))
  +k = L.cell_value(L.image_board(next),L.ordinary_box_slot(p))
  +dr = L.direct_row_word(original,p)
  +dc = L.direct_col_word(original,p)
  +db = L.direct_box_word(original,p)
  %Equal.sym(U32,L.cached_word(a,p),L.occupancy_candidate_mask(r,c,k),L.cached_candidates_are_occupancy_image(next,p)) :
    {_ == Pair.snd(Array<U32>,U32,C.at(b,p)) : U32}
  %Equal.sym(Array<U32> & U32,C.at(b,p),(b,L.direct_candidate_word(original,p)),L.actual_direct_candidates_image(original,p)) :
    {L.occupancy_candidate_mask(r,c,k) == Pair.snd(Array<U32>,U32,_) : U32}
  %Equal.sym(U32,L.direct_candidate_word(original,p),L.occupancy_candidate_mask(dr,dc,db),L.direct_candidate_is_three_unit_union(original,p)) :
    {L.occupancy_candidate_mask(r,c,k) == _ : U32}
  L.occupancy_masks_same_if_digits_same(r,c,k,dr,dc,db,equal)

def L.actual_cache_rebuilds_direct_candidates(image,row,col,shape):
  b = L.image_board(image)
  +p = L.logical_position(row,col)
  out = C.cache(L.image_board(image))
  f : (L.CacheRecomputedDigits(out,image,p) -> {L.cached_word(out,p) == Pair.snd(Array<U32>,U32,C.at(b,p)) : U32}) =
    L.on_reified_board(out,x => (L.CacheRecomputedDigits(x,image,p) ->
      {L.cached_word(x,p) == Pair.snd(Array<U32>,U32,C.at(b,p)) : U32}),L.reify_board(C.cache(L.image_board(image))),
      next => equal => L.cached_word_from_recomputed_projection(next,image,p,equal))
  f(L.complete_cache_original_projection_parts(image,row,col,
    L.copy_shape_three(L.array_shape(L.image_board(image)),L.perfect_shape(7n),shape),
    L.checked_ordinary_geometry(row,col),L.cache_scan_geometry(row,col)))

def L.ordinary_pointer_keeps_shape_parts(image,out,shape,writes):
  (+p,exact) = writes
  b = L.image_board(image)
  %Equal.sym(Array<U32>,out,Board.set_cell(b,108,p),exact) : L.Board128(_)
  L.board_set_keeps_perfect(L.image_board(image),108,p,7n,shape)

def L.ordinary_pointer_keeps_shape_image(image,start,shape):
  b = L.image_board(image)
  L.ordinary_pointer_keeps_shape_parts(image,C.refresh_start(b,start),shape,L.ordinary_refresh_pointer(L.image_board(image),start))

def L.ordinary_pointer_keeps_shape(b,start,shape):
  f : (L.Board128(b) -> L.Board128(C.refresh_start(b,start))) =
    L.on_reified_board(b,x => (L.Board128(x) -> L.Board128(C.refresh_start(x,start))),L.reify_board(b),
      image => L.ordinary_pointer_keeps_shape_image(image,start))
  f(shape)

def L.actual_cache_then_queue_blank_matches_direct_parts(image,row,col,shapes,blank):
  (s0,(s1,s2)) = shapes
  b = L.image_board(image)
  +p = L.logical_position(row,col)
  prepared = C.cache(L.image_board(image))
  Equal.trans(U32,L.cell_value(Q.encode(prepared),p),L.cached_word(prepared,p),Pair.snd(Array<U32>,U32,C.at(b,p)),
    L.encoded_logical_blank_uses_original_cached_mask(C.cache(L.image_board(image)),row,col)(
      L.ordinary_pointer_keeps_shape(C.cache_units(27n,0,L.image_board(image)),0,
        L.cache_setup_full_keeps_shape(27n,0,L.image_board(image),s0)),
      Equal.trans(U32,L.cell_value(prepared,p),L.cell_value(b,p),0,
        L.complete_ordinary_cache_keeps_logical_cell(L.image_board(image),row,col,s1),blank)),
    L.actual_cache_rebuilds_direct_candidates(image,row,col,s2))

def L.actual_cache_then_queue_blank_matches_direct(image,row,col,shape,blank):
  L.actual_cache_then_queue_blank_matches_direct_parts(image,row,col,
    L.copy_shape_three(L.array_shape(L.image_board(image)),L.perfect_shape(7n),shape),blank)

def L.plain_scan_normal_parts(n,p,b,same,word,keep,observed):
  %Equal.sym(Array<U32> & U32,Board.get_cell(b,p),(same,word),observed) :
    {C.first_empty(n,p,_) == C.first_empty(n,p,(b,Pair.snd(Array<U32>,U32,_))) : Array<U32>}
  %keep : {C.first_empty(n,p,(same,word)) == C.first_empty(n,p,(_,word)) : Array<U32>}
  {==}

def L.plain_scan_normal(n,p,b,read):
  (same,+word,(keep,observed)) = read
  L.plain_scan_normal_parts(n,p,b,same,word,keep,observed)

def L.plain_scan_positive_word(word,n,p,image,later):
  match word:
    case U32{WCon{True{}, rest}}:
      later
    case U32{WCon{False{}, WCon{True{}, rest}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      later
    case U32{WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{False{}, WCon{True{}, rest}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}:
      later
    case 0:
      {==}

def L.plain_scan_lift_exact(n,p,image,pure):
  b = L.image_board(image)
  +word = L.cell_value(L.image_board(image),p)
  %Equal.sym(Array<U32>,L.plain_first_actual(b,n,p),C.first_empty(n,p,(b,word)),
    L.plain_scan_normal(n,p,b,L.board_read_witness(L.image_board(image),p))) :
    {_ == Board.set_cell(b,108,L.plain_first_index(n,p,L.plain_open_at(image,p),image)) : Array<U32>}
  pure

def L.plain_scan_sets_exact(n,p,image):
  match n:
    case 0n:
      L.plain_scan_lift_exact(0n,p,image,{==})
    case 1n+k:
      +p1 = (p + 1 : U32)
      L.plain_scan_lift_exact(1n+k,p,image,
        L.plain_scan_positive_word(L.cell_value(L.image_board(image),p),k,p,image,L.plain_scan_sets_exact(k,p1,image)))

def L.plain_scan_reads_exact(n,p,image):
  b = L.image_board(image)
  +index = L.plain_first_index(n,p,L.plain_open_at(image,p),image)
  %Equal.sym(Array<U32>,L.plain_first_actual(b,n,p),Board.set_cell(b,108,index),
    L.plain_scan_sets_exact(n,p,image)) : {L.cell_value(_,108) == index : U32}
  L.board_set_get(L.image_board(image),108,index)

def L.plain_index_no_skip(n,p,open,image,observed):
  match n open:
    case 0n True{}:
      {==}
    case 0n False{}:
      {==}
    case 1n+k True{}:
      Inl{(observed,{==})}
    case 1n+k False{}:
      +p1 = (p + 1 : U32)
      Inr{(observed,L.plain_index_no_skip(k,p1,L.plain_open_at(image,p1),image,{==}))}

def L.plain_scan_no_skip(n,p,image):
  b = L.image_board(image)
  +index = L.plain_first_index(n,p,L.plain_open_at(image,p),image)
  %Equal.sym(U32,L.cell_value(L.plain_first_actual(b,n,p),108),index,L.plain_scan_reads_exact(n,p,image)) :
    L.PlainFirstWitness(n,p,image,_)
  L.plain_index_no_skip(n,p,L.plain_open_at(image,p),image,{==})

def L.logical_first_cursor_routes():
  ((L.Coordinate0{},(L.Coordinate0{},{==})),
   ((L.Coordinate0{},(L.Coordinate1{},{==})),
   ((L.Coordinate0{},(L.Coordinate2{},{==})),
   ((L.Coordinate0{},(L.Coordinate3{},{==})),
   ((L.Coordinate0{},(L.Coordinate4{},{==})),
   ((L.Coordinate0{},(L.Coordinate5{},{==})),
   ((L.Coordinate0{},(L.Coordinate6{},{==})),
   ((L.Coordinate0{},(L.Coordinate7{},{==})),
   ((L.Coordinate0{},(L.Coordinate8{},{==})),
   ((L.Coordinate1{},(L.Coordinate0{},{==})),
   ((L.Coordinate1{},(L.Coordinate1{},{==})),
   ((L.Coordinate1{},(L.Coordinate2{},{==})),
   ((L.Coordinate1{},(L.Coordinate3{},{==})),
   ((L.Coordinate1{},(L.Coordinate4{},{==})),
   ((L.Coordinate1{},(L.Coordinate5{},{==})),
   ((L.Coordinate1{},(L.Coordinate6{},{==})),
   ((L.Coordinate1{},(L.Coordinate7{},{==})),
   ((L.Coordinate1{},(L.Coordinate8{},{==})),
   ((L.Coordinate2{},(L.Coordinate0{},{==})),
   ((L.Coordinate2{},(L.Coordinate1{},{==})),
   ((L.Coordinate2{},(L.Coordinate2{},{==})),
   ((L.Coordinate2{},(L.Coordinate3{},{==})),
   ((L.Coordinate2{},(L.Coordinate4{},{==})),
   ((L.Coordinate2{},(L.Coordinate5{},{==})),
   ((L.Coordinate2{},(L.Coordinate6{},{==})),
   ((L.Coordinate2{},(L.Coordinate7{},{==})),
   ((L.Coordinate2{},(L.Coordinate8{},{==})),
   ((L.Coordinate3{},(L.Coordinate0{},{==})),
   ((L.Coordinate3{},(L.Coordinate1{},{==})),
   ((L.Coordinate3{},(L.Coordinate2{},{==})),
   ((L.Coordinate3{},(L.Coordinate3{},{==})),
   ((L.Coordinate3{},(L.Coordinate4{},{==})),
   ((L.Coordinate3{},(L.Coordinate5{},{==})),
   ((L.Coordinate3{},(L.Coordinate6{},{==})),
   ((L.Coordinate3{},(L.Coordinate7{},{==})),
   ((L.Coordinate3{},(L.Coordinate8{},{==})),
   ((L.Coordinate4{},(L.Coordinate0{},{==})),
   ((L.Coordinate4{},(L.Coordinate1{},{==})),
   ((L.Coordinate4{},(L.Coordinate2{},{==})),
   ((L.Coordinate4{},(L.Coordinate3{},{==})),
   ((L.Coordinate4{},(L.Coordinate4{},{==})),
   ((L.Coordinate4{},(L.Coordinate5{},{==})),
   ((L.Coordinate4{},(L.Coordinate6{},{==})),
   ((L.Coordinate4{},(L.Coordinate7{},{==})),
   ((L.Coordinate4{},(L.Coordinate8{},{==})),
   ((L.Coordinate5{},(L.Coordinate0{},{==})),
   ((L.Coordinate5{},(L.Coordinate1{},{==})),
   ((L.Coordinate5{},(L.Coordinate2{},{==})),
   ((L.Coordinate5{},(L.Coordinate3{},{==})),
   ((L.Coordinate5{},(L.Coordinate4{},{==})),
   ((L.Coordinate5{},(L.Coordinate5{},{==})),
   ((L.Coordinate5{},(L.Coordinate6{},{==})),
   ((L.Coordinate5{},(L.Coordinate7{},{==})),
   ((L.Coordinate5{},(L.Coordinate8{},{==})),
   ((L.Coordinate6{},(L.Coordinate0{},{==})),
   ((L.Coordinate6{},(L.Coordinate1{},{==})),
   ((L.Coordinate6{},(L.Coordinate2{},{==})),
   ((L.Coordinate6{},(L.Coordinate3{},{==})),
   ((L.Coordinate6{},(L.Coordinate4{},{==})),
   ((L.Coordinate6{},(L.Coordinate5{},{==})),
   ((L.Coordinate6{},(L.Coordinate6{},{==})),
   ((L.Coordinate6{},(L.Coordinate7{},{==})),
   ((L.Coordinate6{},(L.Coordinate8{},{==})),
   ((L.Coordinate7{},(L.Coordinate0{},{==})),
   ((L.Coordinate7{},(L.Coordinate1{},{==})),
   ((L.Coordinate7{},(L.Coordinate2{},{==})),
   ((L.Coordinate7{},(L.Coordinate3{},{==})),
   ((L.Coordinate7{},(L.Coordinate4{},{==})),
   ((L.Coordinate7{},(L.Coordinate5{},{==})),
   ((L.Coordinate7{},(L.Coordinate6{},{==})),
   ((L.Coordinate7{},(L.Coordinate7{},{==})),
   ((L.Coordinate7{},(L.Coordinate8{},{==})),
   ((L.Coordinate8{},(L.Coordinate0{},{==})),
   ((L.Coordinate8{},(L.Coordinate1{},{==})),
   ((L.Coordinate8{},(L.Coordinate2{},{==})),
   ((L.Coordinate8{},(L.Coordinate3{},{==})),
   ((L.Coordinate8{},(L.Coordinate4{},{==})),
   ((L.Coordinate8{},(L.Coordinate5{},{==})),
   ((L.Coordinate8{},(L.Coordinate6{},{==})),
   ((L.Coordinate8{},(L.Coordinate7{},{==})),
   ((L.Coordinate8{},(L.Coordinate8{},{==})),
   {==})))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))

def L.plain_cursor_cache_step(image,n,p,shapes,routes,next):
  (s0,s1) = shapes
  (head,tail) = routes
  (L.occupancy_prefix_one_unit_read(image,27n,0n,p,s0,{==},head),next(s1,tail))

def L.plain_cursor_cache_words(image,n,p,shape,routes):
  match n:
    case 0n:
      {==}
    case 1n+k:
      L.plain_cursor_cache_step(image,k,p,
        L.copy_shape_proof(L.array_shape(L.image_board(image)),L.perfect_shape(7n),shape),
        routes,s => rest => L.plain_cursor_cache_words(image,k,(p + 1 : U32),s,rest))

def L.plain_cursor_witness_step(n,p,ptr,cached,original,equal,witnessed,next):
  (head,tail) = equal
  match witnessed:
    case Inl{proof}:
      (open,here) = proof
      Inl{(Equal.trans(Bool,L.plain_open_at(original,p),L.plain_open_at(cached,p),True{},
        %head : {L.PlainBlank(_) == L.plain_open_at(cached,p) : Bool}
        {==},open),here)}
    case Inr{proof}:
      (filled,rest) = proof
      Inr{(Equal.trans(Bool,L.plain_open_at(original,p),L.plain_open_at(cached,p),False{},
        %head : {L.PlainBlank(_) == L.plain_open_at(cached,p) : Bool}
        {==},filled),next(tail,rest))}

def L.plain_cursor_witness_changes_image(n,p,ptr,cached,original,equal,witnessed):
  match n:
    case 0n:
      witnessed
    case 1n+k:
      L.plain_cursor_witness_step(k,p,ptr,cached,original,equal,witnessed,
        rs => w => L.plain_cursor_witness_changes_image(k,(p + 1 : U32),ptr,cached,original,rs,w))

def L.plain_first_shared_open_step(n,p,a,b,open,next):
  match open:
    case True{}:
      {==}
    case False{}:
      next

def L.plain_first_model_agrees_on_walk(n,p,a,b,reads):
  match n:
    case 0n:
      {==}
    case 1n+k:
      (head,tail) = reads
      +p1 = (p + 1 : U32)
      %Equal.sym(U32,L.cell_value(L.image_board(a),p),L.cell_value(L.image_board(b),p),head) :
        {L.plain_first_index(1n+k,p,L.PlainBlank(_),a) == L.plain_first_index(1n+k,p,L.plain_open_at(b,p),b) : U32}
      L.plain_first_shared_open_step(k,p,a,b,L.plain_open_at(b,p),L.plain_first_model_agrees_on_walk(k,p1,a,b,tail))

def L.plain_first_transport_observed_image(n,p,original,cached,raw,computed,reads):
  +expected = L.plain_first_index(n,p,L.plain_open_at(original,p),original)
  +intermediate = L.plain_first_index(n,p,L.plain_open_at(cached,p),cached)
  use : (L.PlainCursorWords(n,p,raw,L.image_board(original)) ->
    {L.cell_value(L.plain_first_actual(raw,n,p),108) == expected : U32}) =
    %computed : (L.PlainCursorWords(n,p,_,L.image_board(original)) ->
      {L.cell_value(L.plain_first_actual(_,n,p),108) == expected : U32})
    eq => Equal.trans(U32,L.cell_value(L.plain_first_actual(L.image_board(cached),n,p),108),intermediate,expected,
      L.plain_scan_reads_exact(n,p,cached),L.plain_first_model_agrees_on_walk(n,p,cached,original,eq))
  use(reads)

def L.actual_cache_initial_first_from_reification(original,shape,reified):
  (+cached,proof) = reified
  L.plain_first_transport_observed_image(81n,0,original,cached,C.cache_units(27n,0,L.image_board(original)),proof,
    L.plain_cursor_cache_words(original,81n,0,shape,L.logical_first_cursor_routes()))

def L.actual_cache_initial_first_blank(original,shape):
  L.actual_cache_initial_first_from_reification(original,shape,L.reify_board(C.cache_units(27n,0,L.image_board(original))))

def L.plain_row_route(row):
  match row:
    case L.Coordinate0{}:
      ((L.Coordinate0{},(L.Coordinate0{},{==})),((L.Coordinate0{},(L.Coordinate1{},{==})),((L.Coordinate0{},(L.Coordinate2{},{==})),((L.Coordinate0{},(L.Coordinate3{},{==})),((L.Coordinate0{},(L.Coordinate4{},{==})),((L.Coordinate0{},(L.Coordinate5{},{==})),((L.Coordinate0{},(L.Coordinate6{},{==})),((L.Coordinate0{},(L.Coordinate7{},{==})),((L.Coordinate0{},(L.Coordinate8{},{==})),{==})))))))))
    case L.Coordinate1{}:
      ((L.Coordinate1{},(L.Coordinate0{},{==})),((L.Coordinate1{},(L.Coordinate1{},{==})),((L.Coordinate1{},(L.Coordinate2{},{==})),((L.Coordinate1{},(L.Coordinate3{},{==})),((L.Coordinate1{},(L.Coordinate4{},{==})),((L.Coordinate1{},(L.Coordinate5{},{==})),((L.Coordinate1{},(L.Coordinate6{},{==})),((L.Coordinate1{},(L.Coordinate7{},{==})),((L.Coordinate1{},(L.Coordinate8{},{==})),{==})))))))))
    case L.Coordinate2{}:
      ((L.Coordinate2{},(L.Coordinate0{},{==})),((L.Coordinate2{},(L.Coordinate1{},{==})),((L.Coordinate2{},(L.Coordinate2{},{==})),((L.Coordinate2{},(L.Coordinate3{},{==})),((L.Coordinate2{},(L.Coordinate4{},{==})),((L.Coordinate2{},(L.Coordinate5{},{==})),((L.Coordinate2{},(L.Coordinate6{},{==})),((L.Coordinate2{},(L.Coordinate7{},{==})),((L.Coordinate2{},(L.Coordinate8{},{==})),{==})))))))))
    case L.Coordinate3{}:
      ((L.Coordinate3{},(L.Coordinate0{},{==})),((L.Coordinate3{},(L.Coordinate1{},{==})),((L.Coordinate3{},(L.Coordinate2{},{==})),((L.Coordinate3{},(L.Coordinate3{},{==})),((L.Coordinate3{},(L.Coordinate4{},{==})),((L.Coordinate3{},(L.Coordinate5{},{==})),((L.Coordinate3{},(L.Coordinate6{},{==})),((L.Coordinate3{},(L.Coordinate7{},{==})),((L.Coordinate3{},(L.Coordinate8{},{==})),{==})))))))))
    case L.Coordinate4{}:
      ((L.Coordinate4{},(L.Coordinate0{},{==})),((L.Coordinate4{},(L.Coordinate1{},{==})),((L.Coordinate4{},(L.Coordinate2{},{==})),((L.Coordinate4{},(L.Coordinate3{},{==})),((L.Coordinate4{},(L.Coordinate4{},{==})),((L.Coordinate4{},(L.Coordinate5{},{==})),((L.Coordinate4{},(L.Coordinate6{},{==})),((L.Coordinate4{},(L.Coordinate7{},{==})),((L.Coordinate4{},(L.Coordinate8{},{==})),{==})))))))))
    case L.Coordinate5{}:
      ((L.Coordinate5{},(L.Coordinate0{},{==})),((L.Coordinate5{},(L.Coordinate1{},{==})),((L.Coordinate5{},(L.Coordinate2{},{==})),((L.Coordinate5{},(L.Coordinate3{},{==})),((L.Coordinate5{},(L.Coordinate4{},{==})),((L.Coordinate5{},(L.Coordinate5{},{==})),((L.Coordinate5{},(L.Coordinate6{},{==})),((L.Coordinate5{},(L.Coordinate7{},{==})),((L.Coordinate5{},(L.Coordinate8{},{==})),{==})))))))))
    case L.Coordinate6{}:
      ((L.Coordinate6{},(L.Coordinate0{},{==})),((L.Coordinate6{},(L.Coordinate1{},{==})),((L.Coordinate6{},(L.Coordinate2{},{==})),((L.Coordinate6{},(L.Coordinate3{},{==})),((L.Coordinate6{},(L.Coordinate4{},{==})),((L.Coordinate6{},(L.Coordinate5{},{==})),((L.Coordinate6{},(L.Coordinate6{},{==})),((L.Coordinate6{},(L.Coordinate7{},{==})),((L.Coordinate6{},(L.Coordinate8{},{==})),{==})))))))))
    case L.Coordinate7{}:
      ((L.Coordinate7{},(L.Coordinate0{},{==})),((L.Coordinate7{},(L.Coordinate1{},{==})),((L.Coordinate7{},(L.Coordinate2{},{==})),((L.Coordinate7{},(L.Coordinate3{},{==})),((L.Coordinate7{},(L.Coordinate4{},{==})),((L.Coordinate7{},(L.Coordinate5{},{==})),((L.Coordinate7{},(L.Coordinate6{},{==})),((L.Coordinate7{},(L.Coordinate7{},{==})),((L.Coordinate7{},(L.Coordinate8{},{==})),{==})))))))))
    case L.Coordinate8{}:
      ((L.Coordinate8{},(L.Coordinate0{},{==})),((L.Coordinate8{},(L.Coordinate1{},{==})),((L.Coordinate8{},(L.Coordinate2{},{==})),((L.Coordinate8{},(L.Coordinate3{},{==})),((L.Coordinate8{},(L.Coordinate4{},{==})),((L.Coordinate8{},(L.Coordinate5{},{==})),((L.Coordinate8{},(L.Coordinate6{},{==})),((L.Coordinate8{},(L.Coordinate7{},{==})),((L.Coordinate8{},(L.Coordinate8{},{==})),{==})))))))))

def L.cached_row_fold_agrees_on_reads(n,p,col,used,cached,original,agree):
  match n:
    case 0n:
      {==}
    case 1n+k:
      (head,tail) = agree
      +p1 = (p + 1 : U32)
      +c1 = (col + 1 : U32)
      +same_acc = U32.or(used,L.cached_row_digit_entry(col,L.cell_value(L.image_board(cached),p)))
      %head : {L.cached_row_fold(k,p1,c1,same_acc,cached) ==
        L.cached_row_fold(k,p1,c1,U32.or(used,L.cached_row_digit_entry(col,_)),original) : U32}
      L.cached_row_fold_agrees_on_reads(k,p1,c1,same_acc,cached,original,tail)

def L.row_prefix_agreement_step(image,prefix,remaining,n,p,shapes,totals,routes,next):
  (s0,s1) = shapes
  (t0,(t1,t2)) = totals
  (here,later) = routes
  (L.occupancy_prefix_one_unit_read(image,prefix,remaining,p,s0,t0,here),next(s1,t1,later))

def L.row_prefix_agrees(image,prefix,remaining,n,p,shape,total,routes):
  match n:
    case 0n:
      {==}
    case 1n+k:
      L.row_prefix_agreement_step(image,prefix,remaining,k,p,
        L.copy_shape_proof(L.array_shape(L.image_board(image)),L.perfect_shape(7n),shape),
        L.copy_nat_eq(Nat.add(prefix,remaining),27n,total),routes,
        s => t => rest => L.row_prefix_agrees(image,prefix,remaining,k,(p + 1 : U32),s,t,rest))

def L.actual_row_step_reads_original(image,cached,unit,kind,reads):
  b = L.image_board(cached)
  +q = (81 + unit : U32)
  +p = (unit * 9 : U32)
  +word = L.cached_row_fold(9n,p,0,0,cached)
  +expected = L.cached_row_fold(9n,p,0,0,image)
  %Equal.sym(Bool,(unit < 9 : U32),True{},kind) :
    {L.cell_value(C.cache_unit_done(q,C.cached_used(_,unit,b)),q) == expected : U32}
  %Equal.sym(Array<U32>,C.cache_unit_done(q,C.cached_used(True{},unit,b)),Board.set_cell(b,q,word),
    L.actual_cached_one_row_write(cached,unit)) : {L.cell_value(_,q) == expected : U32}
  %Equal.sym(U32,L.cell_value(Board.set_cell(b,q,word),q),word,L.board_set_get(L.image_board(cached),q,word)) :
    {_ == expected : U32}
  L.cached_row_fold_agrees_on_reads(9n,p,0,0,cached,image,reads)

def L.actual_row_step_reads_prefix(image,row,prefix,remaining,shape,total):
  +unit = L.group_unit(L.CacheRows{},row)
  +p = (unit * 9 : U32)
  +q = (81 + unit : U32)
  original = L.image_board(image)
  out = C.cache_units(prefix,0,L.image_board(image))
  f : (L.PlainCursorWords(9n,p,out,original) -> {L.cell_value(L.cache_setup_step(unit,out),q) == L.cached_row_fold(9n,p,0,0,image) : U32}) =
    L.on_reified_board(out,x => (L.PlainCursorWords(9n,p,x,original) ->
      {L.cell_value(L.cache_setup_step(unit,x),q) == L.cached_row_fold(9n,p,0,0,image) : U32}),
      L.reify_board(C.cache_units(prefix,0,L.image_board(image))),
      cached => reads => L.actual_row_step_reads_original(image,cached,unit,L.cache_group_row_test(L.CacheRows{},row),reads))
  f(L.row_prefix_agrees(image,prefix,remaining,9n,p,shape,total,L.plain_row_route(row)))

def L.complete_cache_rebuild_row_word_counts(image,row,shapes,counts,guard,apart,alias):
  (s0,(s1,s2)) = shapes
  (t0,(t1,t2)) = counts
  b = L.image_board(image)
  +n = L.group_unit_nat(L.CacheRows{},row)
  +m = L.cache_tail_count(L.CacheRows{},row)
  +i = L.group_unit(L.CacheRows{},row)
  +q = L.actual_cache_target(L.CacheRows{},row)
  +word = L.cached_row_fold(9n,(i * 9 : U32),0,0,image)
  prior = C.cache_units(27n,0,L.image_board(image))
  wrote = L.cache_setup_step(i,C.cache_units(n,0,L.image_board(image)))
  result = C.cache_units(m,(i + 1 : U32),L.cache_setup_step(i,C.cache_units(n,0,L.image_board(image))))
  %alias : {L.cell_value(C.cache(b),_) == word : U32}
  %Equal.sym(U32,L.cell_value(C.cache(b),q),L.cell_value(prior,q),
    L.plain_refresh_keeps_actual_cell(C.cache_units(27n,0,L.image_board(image)),0,q)(
      L.cache_setup_full_keeps_shape(27n,0,L.image_board(image),s0),apart)) : {_ == word : U32}
  %Equal.sym(Array<U32>,prior,result,L.full_ordinary_setup_as_local_cache_write(L.CacheRows{},row,L.image_board(image),t0)) :
    {L.cell_value(_,q) == word : U32}
  %Equal.sym(U32,L.cell_value(result,q),L.cell_value(wrote,q),
    L.cache_setup_sweep_keeps_cell(m,(i + 1 : U32),q,L.cache_setup_step(i,C.cache_units(n,0,L.image_board(image))),
      L.cache_setup_step_keeps_shape(C.cache_units(n,0,L.image_board(image)),i,
        L.cache_setup_full_keeps_shape(n,0,L.image_board(image),s1)),
      L.cache_setup_route_from_checked(m,(i + 1 : U32),q,guard))) : {_ == word : U32}
  L.actual_row_step_reads_prefix(image,row,n,1n+m,s2,t1)

def L.complete_cache_rebuild_row_word_parts(image,row,shapes,window):
  (count,(guard,(apart,alias))) = window
  +n = L.group_unit_nat(L.CacheRows{},row)
  +m = L.cache_tail_count(L.CacheRows{},row)
  L.complete_cache_rebuild_row_word_counts(image,row,shapes,L.copy_nat_eq(Nat.add(n,1n+m),27n,count),guard,apart,alias)

def L.complete_cache_rebuild_row_word(image,row,shape):
  L.complete_cache_rebuild_row_word_parts(image,row,
    L.copy_shape_three(L.array_shape(L.image_board(image)),L.perfect_shape(7n),shape),
    L.checked_cache_window(L.CacheRows{},row))

def L.swap_join_left_keeps_word(right,result):
  (b,+d) = result
  {==}

def L.swap_join_right_keeps_word(left,result):
  (b,+d) = result
  {==}

def L.array_image_swap_previous_word(tree,n,p,value,left):
  match tree left:
    case L.ImageLeaf{d} _:
      {==}
    case L.ImageNode{lo,hi} True{}:
      +h = U32.shr(n)
      +z = U32.is_lt(p,U32.shr(h))
      %Equal.sym(U32,Pair.snd(Array<U32>,U32,Array.swap.lo(U32,L.image_board(hi),Array.swap.go(U32,L.image_board(lo),h,p,value,z))),Pair.snd(Array<U32>,U32,Array.swap.go(U32,L.image_board(lo),h,p,value,z)),L.swap_join_left_keeps_word(L.image_board(hi),Array.swap.go(U32,L.image_board(lo),h,p,value,z))) :
        {_ == Pair.snd(Array<U32>,U32,Array.swap.lo(U32,L.image_board(hi),Array.get.go(U32,L.image_board(lo),h,p,z))) : U32}
      %Equal.sym(U32,Pair.snd(Array<U32>,U32,Array.swap.lo(U32,L.image_board(hi),Array.get.go(U32,L.image_board(lo),h,p,z))),Pair.snd(Array<U32>,U32,Array.get.go(U32,L.image_board(lo),h,p,z)),L.swap_join_left_keeps_word(L.image_board(hi),Array.get.go(U32,L.image_board(lo),h,p,z))) :
        {Pair.snd(Array<U32>,U32,Array.swap.go(U32,L.image_board(lo),h,p,value,z)) == _ : U32}
      L.array_image_swap_previous_word(lo,h,p,value,z)
    case L.ImageNode{lo,hi} False{}:
      +h = U32.shr(n)
      +q = U32.sub(p,h)
      +z = U32.is_lt(q,U32.shr(h))
      %Equal.sym(U32,Pair.snd(Array<U32>,U32,Array.swap.hi(U32,L.image_board(lo),Array.swap.go(U32,L.image_board(hi),h,q,value,z))),Pair.snd(Array<U32>,U32,Array.swap.go(U32,L.image_board(hi),h,q,value,z)),L.swap_join_right_keeps_word(L.image_board(lo),Array.swap.go(U32,L.image_board(hi),h,q,value,z))) :
        {_ == Pair.snd(Array<U32>,U32,Array.swap.hi(U32,L.image_board(lo),Array.get.go(U32,L.image_board(hi),h,q,z))) : U32}
      %Equal.sym(U32,Pair.snd(Array<U32>,U32,Array.swap.hi(U32,L.image_board(lo),Array.get.go(U32,L.image_board(hi),h,q,z))),Pair.snd(Array<U32>,U32,Array.get.go(U32,L.image_board(hi),h,q,z)),L.swap_join_right_keeps_word(L.image_board(lo),Array.get.go(U32,L.image_board(hi),h,q,z))) :
        {Pair.snd(Array<U32>,U32,Array.swap.go(U32,L.image_board(hi),h,q,value,z)) == _ : U32}
      L.array_image_swap_previous_word(hi,h,q,value,z)

def L.array_swap_previous_word(tree,n,p,value,left):
  L.on_reified_board(tree,x => {Pair.snd(Array<U32>,U32,Array.swap.go(U32,x,n,p,value,left)) ==
    Pair.snd(Array<U32>,U32,Array.get.go(U32,x,n,p,left)) : U32},
    L.reify_board(tree),image => L.array_image_swap_previous_word(image,n,p,value,left))

def L.array_swap_at_previous_word(p,value,sizing):
  (b,+n) = sizing
  +p1 = U32.and(p,U32.sub(n,1))
  L.array_swap_previous_word(b,n,p1,value,U32.is_lt(p1,U32.shr(n)))

def L.board_swap_previous_word(b,p,value):
  L.array_swap_at_previous_word(p,value,Array.size(U32,b))

def L.ordinary_swapped_returns_previous_field(p,value,pair):
  (b,+d) = pair
  {==}

def L.ordinary_swap_returns_original_target(image,p,value):
  b = L.image_board(image)
  before = Array.swap(U32,L.image_board(image),p,value)
  %Equal.sym(U32,Pair.snd(Array<U32>,U32,C.swapped(p,value,before)),Pair.snd(Array<U32>,U32,before),L.ordinary_swapped_returns_previous_field(p,value,before)) : {_ == L.cell_value(b,p) : U32}
  L.board_swap_previous_word(L.image_board(image),p,value)

def L.ordinary_swap_target_from_pair(p,value,pair,routes,set):
  (b,+old) = pair
  L.ordinary_after_write_keeps(b,p,old,value,p,value)(routes,set)

def L.ordinary_swap_target_exact(image,row,col,value,shape):
  b = L.image_board(image)
  +p = L.logical_position(row,col)
  L.ordinary_swap_target_from_pair(p,value,Array.swap(U32,L.image_board(image),p,value),
    L.ordinary_routes_from_coordinates(row,col,row,col),
    (L.board_set_keeps_perfect(L.image_board(image),p,value,7n,shape),L.board_set_get(L.image_board(image),p,value)))

def L.ordinary_pointer_clear_exact(image,p,start):
  L.board_set_get(L.image_board(image),108,U32.min(start,p))

def L.ordinary_pointer_fill_away_is_identity(b,p,start,away):
  %Equal.sym(Bool,U32.is_eq(p,start),False{},away) : {C.refresh_if(_,b,start) == b : Array<U32>}
  {==}

def L.ordinary_pointer_fill_at_rescans_without_skipping(image,p,start,hit):
  b = L.image_board(image)
  +n = U32.to_nat((81 - start : U32))
  %Equal.sym(Bool,U32.is_eq(p,start),True{},hit) :
    L.PlainFirstWitness(n,start,image,L.cell_value(C.refresh_if(_,b,start),108))
  L.plain_scan_no_skip(n,start,image)

def L.ordinary_pointer_clear_from_actual_read(image,p,same,word,kept,read):
  b = L.image_board(image)
  %Equal.sym(Array<U32> & U32,Board.get_cell(b,108),(same,word),read) :
    {L.cell_value(C.start_after_set(True{},p,_),108) == U32.min(Pair.snd(Array<U32>,U32,_),p) : U32}
  %Equal.sym(Array<U32>,same,b,kept) :
    {L.cell_value(C.start_after_set(True{},p,(_,word)),108) == U32.min(word,p) : U32}
  L.ordinary_pointer_clear_exact(image,p,word)

def L.ordinary_pointer_clear_normalized(image,p,read):
  (same,+word,(keep,proof)) = read
  L.ordinary_pointer_clear_from_actual_read(image,p,same,word,keep,proof)

def L.ordinary_pointer_clear_uses_actual_prior(image,p):
  L.ordinary_pointer_clear_normalized(image,p,L.board_read_witness(L.image_board(image),108))

def L.prepared_seed_rows_shape_step(image,n,unit,shape,next):
  +slot = (81 + unit : U32)
  next(Board.set_cell(L.image_board(image),slot,523264),
    L.board_set_keeps_perfect(L.image_board(image),slot,523264,7n,shape))

def L.prepared_seed_rows_keeps_shape(n,unit,b,shape):
  match n:
    case 0n:
      shape
    case 1n+k:
      f : (L.Board128(b) -> L.Board128(C.empty_rows_go(1n+k,unit,b))) =
        L.on_reified_board(b,x => (L.Board128(x) -> L.Board128(C.empty_rows_go(1n+k,unit,x))),L.reify_board(b),
          image => s => L.prepared_seed_rows_shape_step(image,k,unit,s,
            x => sh => L.prepared_seed_rows_keeps_shape(k,(unit + 1 : U32),x,sh)))
      f(shape)

def L.prepared_seed_rows_preserves_word_step(n,unit,q,image,shapes,route,next):
  (s0,s1) = shapes
  (head,tail) = route
  b = L.image_board(image)
  +slot = (81 + unit : U32)
  updated = Board.set_cell(L.image_board(image),slot,523264)
  Equal.trans(U32,L.cell_value(C.empty_rows_go(n,(unit + 1 : U32),updated),q),L.cell_value(updated,q),L.cell_value(b,q),
    next(Board.set_cell(L.image_board(image),slot,523264))(
      L.board_set_keeps_perfect(L.image_board(image),slot,523264,7n,s0),tail),
    L.perfect_write_keeps_cell(L.image_board(image),slot,q,523264,s1,head))

def L.prepared_seed_rows_preserves_word(n,unit,q,b):
  match n:
    case 0n:
      s => route => {==}
    case 1n+k:
      L.on_reified_board(b,x => L.SeedRowsKeepsWord(1n+k,unit,q,x),L.reify_board(b),
        image => shape => route => L.prepared_seed_rows_preserves_word_step(k,unit,q,image,
          L.copy_shape_proof(L.array_shape(L.image_board(image)),L.perfect_shape(7n),shape),route,
          x => L.prepared_seed_rows_preserves_word(k,(unit + 1 : U32),q,x)))

def L.prepared_seed_rows_preserves_original_cell(image,row,col,shape):
  +p = L.logical_position(row,col)
  L.prepared_seed_rows_preserves_word(9n,0,p,L.image_board(image))(shape,
    L.cache_setup_read_prefix_known(9n,18n,p,{==},
      L.cache_setup_route_from_checked(27n,0,p,L.cache_setup_sweep_guard_logical(row,col))))

def L.prepared_seed_rows_split(prefix,suffix,unit,b):
  match prefix:
    case 0n:
      {==}
    case 1n+k:
      L.prepared_seed_rows_split(k,suffix,(unit + 1 : U32),Board.set_cell(b,(81 + unit : U32),523264))

def L.seed_exact_row_window(row):
  match row:
    case L.Coordinate0{}:
      ({==},({==},{==}))
    case L.Coordinate1{}:
      ({==},({==},{==}))
    case L.Coordinate2{}:
      ({==},({==},{==}))
    case L.Coordinate3{}:
      ({==},({==},{==}))
    case L.Coordinate4{}:
      ({==},({==},{==}))
    case L.Coordinate5{}:
      ({==},({==},{==}))
    case L.Coordinate6{}:
      ({==},({==},{==}))
    case L.Coordinate7{}:
      ({==},({==},{==}))
    case L.Coordinate8{}:
      ({==},({==},{==}))

def L.prepared_seed_row_all_columns_empty_parts(row,image,shape,window):
  (count,(guard,alias)) = window
  +n = L.coordinate_nat(row)
  +tail = L.column_tail(row)
  +unit = L.coord_u32(row)
  +slot = (81 + unit : U32)
  b = L.image_board(image)
  prior = C.empty_rows_go(n,0,L.image_board(image))
  wrote = Board.set_cell(C.empty_rows_go(n,0,L.image_board(image)),slot,523264)
  %alias : {L.cell_value(C.empty_rows(b),_) == 523264 : U32}
  %count : {L.cell_value(C.empty_rows_go(_,0,b),slot) == 523264 : U32}
  %Equal.sym(Array<U32>,C.empty_rows_go(Nat.add(n,1n+tail),0,b),
    C.empty_rows_go(1n+tail,unit,prior),L.prepared_seed_rows_split(n,1n+tail,0,L.image_board(image))) :
    {L.cell_value(_,slot) == 523264 : U32}
  %Equal.sym(U32,L.cell_value(C.empty_rows_go(tail,(unit + 1 : U32),wrote),slot),L.cell_value(wrote,slot),
    L.prepared_seed_rows_preserves_word(tail,(unit + 1 : U32),slot,
      Board.set_cell(C.empty_rows_go(n,0,L.image_board(image)),slot,523264))(
        L.board_set_keeps_perfect(C.empty_rows_go(n,0,L.image_board(image)),slot,523264,7n,
          L.prepared_seed_rows_keeps_shape(n,0,L.image_board(image),shape)),
        L.cache_setup_route_from_checked(tail,(unit + 1 : U32),slot,guard))) :
    {_ == 523264 : U32}
  L.board_set_get(C.empty_rows_go(n,0,L.image_board(image)),slot,523264)

def L.empty_reified_matches():
  {==}

def L.prepared_seed_row_all_columns_empty(row):
  %L.empty_reified_matches() :
    {L.cell_value(C.empty_rows(_),L.cache_group_slot(L.CacheRows{},row)) == 523264 : U32}
  L.prepared_seed_row_all_columns_empty_parts(row,L.empty_image(7n),{==},L.seed_exact_row_window(row))

def L.empty_image_reads_zero(height,size,p,left):
  match height left:
    case 0n True{}:
      {==}
    case 0n False{}:
      {==}
    case 1n+k True{}:
      b = L.image_board(L.empty_image(k))
      +h = U32.shr(size)
      +z = U32.is_lt(p,U32.shr(h))
      out = Array.get.go(U32,b,h,p,z)
      %Equal.sym(U32,Pair.snd(Array<U32>,U32,Array.swap.lo(U32,b,out)),
        Pair.snd(Array<U32>,U32,out),L.swap_join_left_keeps_word(L.image_board(L.empty_image(k)),
          Array.get.go(U32,L.image_board(L.empty_image(k)),h,p,z))) : {_ == 0 : U32}
      L.empty_image_reads_zero(k,h,p,z)
    case 1n+k False{}:
      b = L.image_board(L.empty_image(k))
      +h = U32.shr(size)
      +q = U32.sub(p,h)
      +z = U32.is_lt(q,U32.shr(h))
      out = Array.get.go(U32,b,h,q,z)
      %Equal.sym(U32,Pair.snd(Array<U32>,U32,Array.swap.hi(U32,b,out)),
        Pair.snd(Array<U32>,U32,out),L.swap_join_right_keeps_word(L.image_board(L.empty_image(k)),
          Array.get.go(U32,L.image_board(L.empty_image(k)),h,q,z))) : {_ == 0 : U32}
      L.empty_image_reads_zero(k,h,q,z)

def L.empty_board_reads_zero(p):
  +masked = U32.and(p,127)
  L.empty_image_reads_zero(7n,128,masked,U32.is_lt(masked,64))

def L.prepared_seed_logical_cell_is_blank(row,col):
  +p = L.logical_position(row,col)
  %Equal.sym(U32,L.cell_value(C.empty_rows(Board.empty()),p),L.cell_value(Board.empty(),p),
    L.prepared_seed_rows_preserves_original_cell(L.empty_image(7n),row,col,{==})) :
    {_ == 0 : U32}
  L.empty_board_reads_zero(p)

def L.prepared_seed_nonrow_window(group,index,nonrow):
  match group index:
    case L.CacheRows{} _:
      Empty.absurd({L.cache_setup_route_guard(9n,0,L.cache_group_slot(L.CacheRows{},index)) == True{} : Bool},
        L.false_is_not_true(Equal.sym(Bool,True{},False{},nonrow)))
    case L.CacheColumns{} L.Coordinate0{}:
      {==}
    case L.CacheColumns{} L.Coordinate1{}:
      {==}
    case L.CacheColumns{} L.Coordinate2{}:
      {==}
    case L.CacheColumns{} L.Coordinate3{}:
      {==}
    case L.CacheColumns{} L.Coordinate4{}:
      {==}
    case L.CacheColumns{} L.Coordinate5{}:
      {==}
    case L.CacheColumns{} L.Coordinate6{}:
      {==}
    case L.CacheColumns{} L.Coordinate7{}:
      {==}
    case L.CacheColumns{} L.Coordinate8{}:
      {==}
    case L.CacheBoxes{} L.Coordinate0{}:
      {==}
    case L.CacheBoxes{} L.Coordinate1{}:
      {==}
    case L.CacheBoxes{} L.Coordinate2{}:
      {==}
    case L.CacheBoxes{} L.Coordinate3{}:
      {==}
    case L.CacheBoxes{} L.Coordinate4{}:
      {==}
    case L.CacheBoxes{} L.Coordinate5{}:
      {==}
    case L.CacheBoxes{} L.Coordinate6{}:
      {==}
    case L.CacheBoxes{} L.Coordinate7{}:
      {==}
    case L.CacheBoxes{} L.Coordinate8{}:
      {==}

def L.prepared_seed_nonrow_slot_is_zero(group,index,nonrow):
  +q = L.cache_group_slot(group,index)
  %Equal.sym(U32,L.cell_value(C.empty_rows(Board.empty()),q),L.cell_value(Board.empty(),q),
    L.prepared_seed_rows_preserves_word(9n,0,q,Board.empty())(L.empty_board_depth_seven(),
      L.cache_setup_route_from_checked(9n,0,q,L.prepared_seed_nonrow_window(group,index,nonrow)))) :
    {_ == 0 : U32}
  L.empty_board_reads_zero(q)

def L.prepared_read_shape_parts(image,p,same,word,keep,read,shape):
  b = L.image_board(image)
  %Equal.sym(Array<U32> & U32,Board.get_cell(b,p),(same,word),read) :
    L.PreparedPairShape(_)
  %Equal.sym(Array<U32>,same,b,keep) : L.PreparedPairShape((_,word))
  shape

def L.prepared_read_shape_witness(image,p,read,shape):
  (same,+word,(kept,seen)) = read
  L.prepared_read_shape_parts(image,p,same,word,kept,seen,shape)

def L.prepared_read_shape_image(image,p,shape):
  L.prepared_read_shape_witness(image,p,L.board_read_witness(L.image_board(image),p),shape)

def L.prepared_read_preserves_shape(b,p,shape):
  f : (L.Board128(b) -> L.PreparedPairShape(Board.get_cell(b,p))) =
    L.on_reified_board(b,x => (L.Board128(x) -> L.PreparedPairShape(Board.get_cell(x,p))),
      L.reify_board(b),image => s => L.prepared_read_shape_image(image,p,s))
  f(shape)

def L.prepared_write_cell_shape(pos,digit,state,shape):
  (b,+bad) = state
  L.board_set_keeps_perfect(b,pos,digit,7n,shape)

def L.prepared_append_unit_mask_shape(unit,bit,bad,state,shape):
  (b,+used) = state
  L.board_set_keeps_perfect(b,(81 + unit : U32),U32.or(used,bit),7n,shape)

def L.prepared_append_unit_shape_image(unit,bit,image,bad,shape):
  b = L.image_board(image)
  L.prepared_append_unit_mask_shape(unit,bit,bad,Board.get_cell(L.image_board(image),(81 + unit : U32)),
    L.prepared_read_preserves_shape(L.image_board(image),(81 + unit : U32),shape))

def L.prepared_append_unit_shape(unit,bit,state,shape):
  (b,+bad) = state
  f : (L.Board128(b) -> L.PreparedPairShape(P.prepared_unit(unit,bit,(b,bad)))) =
    L.on_reified_board(b,x => (L.Board128(x) -> L.PreparedPairShape(P.prepared_unit(unit,bit,(x,bad)))),L.reify_board(b),
      image => s => L.prepared_append_unit_shape_image(unit,bit,image,bad,s))
  f(shape)


def L.prepared_append_row_mask_shape(unit,bit,empty,bad,state,shape):
  (b,+used) = state
  L.board_set_keeps_perfect(b,(81 + unit : U32),U32.or(U32.and(used,U32.not(empty)),bit),7n,shape)

def L.prepared_append_row_shape_image(pos,bit,image,bad,shape):
  b = L.image_board(image)
  +unit = M.div9(pos)
  +p = (81 + unit : U32)
  L.prepared_append_row_mask_shape(unit,bit,Board.bit((10 + M.rem9(pos) : U32)),bad,Board.get_cell(L.image_board(image),p),
    L.prepared_read_preserves_shape(L.image_board(image),p,shape))

def L.prepared_append_row_shape(pos,bit,state,shape):
  (b,+bad) = state
  f : (L.Board128(b) -> L.PreparedPairShape(P.prepared_row(pos,bit,(b,bad)))) =
    L.on_reified_board(b,x => (L.Board128(x) -> L.PreparedPairShape(P.prepared_row(pos,bit,(x,bad)))),L.reify_board(b),
      image => s => L.prepared_append_row_shape_image(pos,bit,image,bad,s))
  f(shape)


def L.prepared_store_nonzero_chain_shape_image(pos,digit,image,bad,shape):
  +bit = Board.bit(digit)
  +col = (9 + M.rem9(pos) : U32)
  +box = (18 + Board.box_of(pos) : U32)
  rowed = P.prepared_row(pos,bit,(L.image_board(image),bad))
  coled = P.prepared_unit(col,bit,rowed)
  boxed = P.prepared_unit(box,bit,coled)
  L.prepared_write_cell_shape(pos,digit,boxed,
    L.prepared_append_unit_shape(box,bit,P.prepared_unit(col,bit,P.prepared_row(pos,bit,(L.image_board(image),bad))),
      L.prepared_append_unit_shape(col,bit,P.prepared_row(pos,bit,(L.image_board(image),bad)),
        L.prepared_append_row_shape(pos,bit,(L.image_board(image),bad),shape))))

def L.prepared_store_nonzero_chain_shape(pos,digit,state,shape):
  (b,+bad) = state
  f : (L.Board128(b) -> L.PreparedPairShape(P.prepared_set(pos,digit,P.prepared_unit((18 + Board.box_of(pos) : U32),Board.bit(digit),P.prepared_unit((9 + M.rem9(pos) : U32),Board.bit(digit),P.prepared_row(pos,Board.bit(digit),(b,bad))))))) =
    L.on_reified_board(b,x => (L.Board128(x) -> L.PreparedPairShape(P.prepared_set(pos,digit,P.prepared_unit((18 + Board.box_of(pos) : U32),Board.bit(digit),P.prepared_unit((9 + M.rem9(pos) : U32),Board.bit(digit),P.prepared_row(pos,Board.bit(digit),(x,bad))))))),L.reify_board(b),
      image => s => L.prepared_store_nonzero_chain_shape_image(pos,digit,image,bad,s))
  f(shape)


def L.prepared_legal_store_keeps_shape(digit,pos,state,shape):
  match digit:
    case L.D0{}:
      L.prepared_write_cell_shape(pos,0,state,shape)
    case L.D1{}:
      L.prepared_store_nonzero_chain_shape(pos,1,state,shape)
    case L.D2{}:
      L.prepared_store_nonzero_chain_shape(pos,2,state,shape)
    case L.D3{}:
      L.prepared_store_nonzero_chain_shape(pos,3,state,shape)
    case L.D4{}:
      L.prepared_store_nonzero_chain_shape(pos,4,state,shape)
    case L.D5{}:
      L.prepared_store_nonzero_chain_shape(pos,5,state,shape)
    case L.D6{}:
      L.prepared_store_nonzero_chain_shape(pos,6,state,shape)
    case L.D7{}:
      L.prepared_store_nonzero_chain_shape(pos,7,state,shape)
    case L.D8{}:
      L.prepared_store_nonzero_chain_shape(pos,8,state,shape)
    case L.D9{}:
      L.prepared_store_nonzero_chain_shape(pos,9,state,shape)

def L.prepared_read_keeps_logical_word_parts(image,pos,q,word,same,value,kept,read,proof):
  b = L.image_board(image)
  %Equal.sym(Array<U32> & U32,Board.get_cell(b,pos),(same,value),read) :
    L.PreparedWord(_,q,word)
  %Equal.sym(Array<U32>,same,b,kept) :
    L.PreparedWord((_,value),q,word)
  proof

def L.prepared_read_keeps_logical_word_witness(image,pos,q,word,read,proof):
  (same,+value,(kept,observed)) = read
  L.prepared_read_keeps_logical_word_parts(image,pos,q,word,same,value,kept,observed,proof)

def L.prepared_read_keeps_logical_word_image(image,pos,q,word,proof):
  L.prepared_read_keeps_logical_word_witness(image,pos,q,word,L.board_read_witness(L.image_board(image),pos),proof)

def L.prepared_read_keeps_logical_word(b,pos,q,word,proof):
  f : (L.PlainWord(b,q,word) -> L.PreparedWord(Board.get_cell(b,pos),q,word)) =
    L.on_reified_board(b,x => (L.PlainWord(x,q,word) -> L.PreparedWord(Board.get_cell(x,pos),q,word)),
      L.reify_board(b),image => w => L.prepared_read_keeps_logical_word_image(image,pos,q,word,w))
  f(proof)

def L.prepared_cell_exact_value_parts(pos,value,image,bad,shape):
  (L.board_set_keeps_perfect(L.image_board(image),pos,value,7n,shape),L.board_set_get(L.image_board(image),pos,value))

def L.prepared_cell_exact_value(pos,value,state,shape):
  (b,+bad) = state
  f : (L.Board128(b) -> L.PreparedWord(P.prepared_set(pos,value,(b,bad)),pos,value)) =
    L.on_reified_board(b,x => (L.Board128(x) -> L.PreparedWord(P.prepared_set(pos,value,(x,bad)),pos,value)),
      L.reify_board(b),image => s => L.prepared_cell_exact_value_parts(pos,value,image,bad,s))
  f(shape)

def L.prepared_cell_keeps_other(pos,value,q,word,state,apart,proof):
  (b,+bad) = state
  L.plain_write(b,pos,value,q,word,apart,proof)

def L.prepared_unit_mask_keeps_word(unit,bit,bad,q,word,state,apart,proof):
  (b,+used) = state
  L.plain_write(b,(81 + unit : U32),U32.or(used,bit),q,word,apart,proof)

def L.prepared_unit_keeps_word_image(unit,bit,q,word,image,bad,apart,proof):
  +at = (81 + unit : U32)
  L.prepared_unit_mask_keeps_word(unit,bit,bad,q,word,Board.get_cell(L.image_board(image),at),apart,
    L.prepared_read_keeps_logical_word(L.image_board(image),at,q,word,proof))

def L.prepared_unit_keeps_word(unit,bit,q,word,state,apart,proof):
  (b,+bad) = state
  f : (L.RoutedApart((81 + unit : U32),q) -> L.PlainWord(b,q,word) ->
    L.PreparedWord(P.prepared_unit(unit,bit,(b,bad)),q,word)) =
    L.on_reified_board(b,x => (L.RoutedApart((81 + unit : U32),q) -> L.PlainWord(x,q,word) ->
      L.PreparedWord(P.prepared_unit(unit,bit,(x,bad)),q,word)),L.reify_board(b),
      image => a => w => L.prepared_unit_keeps_word_image(unit,bit,q,word,image,bad,a,w))
  f(apart,proof)

def L.prepared_row_mask_keeps_word(unit,bit,empty,bad,q,word,state,apart,proof):
  (b,+used) = state
  L.plain_write(b,(81 + unit : U32),U32.or(U32.and(used,U32.not(empty)),bit),q,word,apart,proof)

def L.prepared_row_keeps_word_image(pos,bit,q,word,image,bad,apart,proof):
  +unit = M.div9(pos)
  +at = L.ordinary_row_slot(pos)
  +empty = Board.bit((10 + M.rem9(pos) : U32))
  L.prepared_row_mask_keeps_word(unit,bit,empty,bad,q,word,Board.get_cell(L.image_board(image),at),apart,
    L.prepared_read_keeps_logical_word(L.image_board(image),at,q,word,proof))

def L.prepared_row_keeps_word(pos,bit,q,word,state,apart,proof):
  (b,+bad) = state
  f : (L.RoutedApart(L.ordinary_row_slot(pos),q) -> L.PlainWord(b,q,word) ->
    L.PreparedWord(P.prepared_row(pos,bit,(b,bad)),q,word)) =
    L.on_reified_board(b,x => (L.RoutedApart(L.ordinary_row_slot(pos),q) -> L.PlainWord(x,q,word) ->
      L.PreparedWord(P.prepared_row(pos,bit,(x,bad)),q,word)),L.reify_board(b),
      image => a => w => L.prepared_row_keeps_word_image(pos,bit,q,word,image,bad,a,w))
  f(apart,proof)

def L.prepared_meta_chain_keeps_image(p,value,q,word,image,bad,routes,proof):
  (cell,(row,(col,box))) = routes
  +bit = Board.bit(value)
  +c = L.prepared_column_unit(p)
  +b = L.prepared_box_unit(p)
  out = L.prepared_meta_chain(p,bit,(L.image_board(image),bad))
  L.prepared_cell_keeps_other(p,value,q,word,out,cell,
    L.prepared_unit_keeps_word(b,bit,q,word,P.prepared_unit(c,bit,P.prepared_row(p,bit,(L.image_board(image),bad))),box,
      L.prepared_unit_keeps_word(c,bit,q,word,P.prepared_row(p,bit,(L.image_board(image),bad)),col,
        L.prepared_row_keeps_word(p,bit,q,word,(L.image_board(image),bad),row,proof))))

def L.prepared_meta_chain_keeps_other(p,value,q,word,state,routes,proof):
  (b,+bad) = state
  f : (L.PreparedWriteRoutes(p,q) -> L.PlainWord(b,q,word) ->
    L.PreparedWord(P.prepared_set(p,value,L.prepared_meta_chain(p,Board.bit(value),(b,bad))),q,word)) =
    L.on_reified_board(b,x => (L.PreparedWriteRoutes(p,q) -> L.PlainWord(x,q,word) ->
      L.PreparedWord(P.prepared_set(p,value,L.prepared_meta_chain(p,Board.bit(value),(x,bad))),q,word)),
      L.reify_board(b),image => r => w => L.prepared_meta_chain_keeps_image(p,value,q,word,image,bad,r,w))
  f(routes,proof)

def L.prepared_slot_aliases(row,col):
  match row col:
    case L.Coordinate0{} L.Coordinate0{}:
      ({==},{==})
    case L.Coordinate0{} L.Coordinate1{}:
      ({==},{==})
    case L.Coordinate0{} L.Coordinate2{}:
      ({==},{==})
    case L.Coordinate0{} L.Coordinate3{}:
      ({==},{==})
    case L.Coordinate0{} L.Coordinate4{}:
      ({==},{==})
    case L.Coordinate0{} L.Coordinate5{}:
      ({==},{==})
    case L.Coordinate0{} L.Coordinate6{}:
      ({==},{==})
    case L.Coordinate0{} L.Coordinate7{}:
      ({==},{==})
    case L.Coordinate0{} L.Coordinate8{}:
      ({==},{==})
    case L.Coordinate1{} L.Coordinate0{}:
      ({==},{==})
    case L.Coordinate1{} L.Coordinate1{}:
      ({==},{==})
    case L.Coordinate1{} L.Coordinate2{}:
      ({==},{==})
    case L.Coordinate1{} L.Coordinate3{}:
      ({==},{==})
    case L.Coordinate1{} L.Coordinate4{}:
      ({==},{==})
    case L.Coordinate1{} L.Coordinate5{}:
      ({==},{==})
    case L.Coordinate1{} L.Coordinate6{}:
      ({==},{==})
    case L.Coordinate1{} L.Coordinate7{}:
      ({==},{==})
    case L.Coordinate1{} L.Coordinate8{}:
      ({==},{==})
    case L.Coordinate2{} L.Coordinate0{}:
      ({==},{==})
    case L.Coordinate2{} L.Coordinate1{}:
      ({==},{==})
    case L.Coordinate2{} L.Coordinate2{}:
      ({==},{==})
    case L.Coordinate2{} L.Coordinate3{}:
      ({==},{==})
    case L.Coordinate2{} L.Coordinate4{}:
      ({==},{==})
    case L.Coordinate2{} L.Coordinate5{}:
      ({==},{==})
    case L.Coordinate2{} L.Coordinate6{}:
      ({==},{==})
    case L.Coordinate2{} L.Coordinate7{}:
      ({==},{==})
    case L.Coordinate2{} L.Coordinate8{}:
      ({==},{==})
    case L.Coordinate3{} L.Coordinate0{}:
      ({==},{==})
    case L.Coordinate3{} L.Coordinate1{}:
      ({==},{==})
    case L.Coordinate3{} L.Coordinate2{}:
      ({==},{==})
    case L.Coordinate3{} L.Coordinate3{}:
      ({==},{==})
    case L.Coordinate3{} L.Coordinate4{}:
      ({==},{==})
    case L.Coordinate3{} L.Coordinate5{}:
      ({==},{==})
    case L.Coordinate3{} L.Coordinate6{}:
      ({==},{==})
    case L.Coordinate3{} L.Coordinate7{}:
      ({==},{==})
    case L.Coordinate3{} L.Coordinate8{}:
      ({==},{==})
    case L.Coordinate4{} L.Coordinate0{}:
      ({==},{==})
    case L.Coordinate4{} L.Coordinate1{}:
      ({==},{==})
    case L.Coordinate4{} L.Coordinate2{}:
      ({==},{==})
    case L.Coordinate4{} L.Coordinate3{}:
      ({==},{==})
    case L.Coordinate4{} L.Coordinate4{}:
      ({==},{==})
    case L.Coordinate4{} L.Coordinate5{}:
      ({==},{==})
    case L.Coordinate4{} L.Coordinate6{}:
      ({==},{==})
    case L.Coordinate4{} L.Coordinate7{}:
      ({==},{==})
    case L.Coordinate4{} L.Coordinate8{}:
      ({==},{==})
    case L.Coordinate5{} L.Coordinate0{}:
      ({==},{==})
    case L.Coordinate5{} L.Coordinate1{}:
      ({==},{==})
    case L.Coordinate5{} L.Coordinate2{}:
      ({==},{==})
    case L.Coordinate5{} L.Coordinate3{}:
      ({==},{==})
    case L.Coordinate5{} L.Coordinate4{}:
      ({==},{==})
    case L.Coordinate5{} L.Coordinate5{}:
      ({==},{==})
    case L.Coordinate5{} L.Coordinate6{}:
      ({==},{==})
    case L.Coordinate5{} L.Coordinate7{}:
      ({==},{==})
    case L.Coordinate5{} L.Coordinate8{}:
      ({==},{==})
    case L.Coordinate6{} L.Coordinate0{}:
      ({==},{==})
    case L.Coordinate6{} L.Coordinate1{}:
      ({==},{==})
    case L.Coordinate6{} L.Coordinate2{}:
      ({==},{==})
    case L.Coordinate6{} L.Coordinate3{}:
      ({==},{==})
    case L.Coordinate6{} L.Coordinate4{}:
      ({==},{==})
    case L.Coordinate6{} L.Coordinate5{}:
      ({==},{==})
    case L.Coordinate6{} L.Coordinate6{}:
      ({==},{==})
    case L.Coordinate6{} L.Coordinate7{}:
      ({==},{==})
    case L.Coordinate6{} L.Coordinate8{}:
      ({==},{==})
    case L.Coordinate7{} L.Coordinate0{}:
      ({==},{==})
    case L.Coordinate7{} L.Coordinate1{}:
      ({==},{==})
    case L.Coordinate7{} L.Coordinate2{}:
      ({==},{==})
    case L.Coordinate7{} L.Coordinate3{}:
      ({==},{==})
    case L.Coordinate7{} L.Coordinate4{}:
      ({==},{==})
    case L.Coordinate7{} L.Coordinate5{}:
      ({==},{==})
    case L.Coordinate7{} L.Coordinate6{}:
      ({==},{==})
    case L.Coordinate7{} L.Coordinate7{}:
      ({==},{==})
    case L.Coordinate7{} L.Coordinate8{}:
      ({==},{==})
    case L.Coordinate8{} L.Coordinate0{}:
      ({==},{==})
    case L.Coordinate8{} L.Coordinate1{}:
      ({==},{==})
    case L.Coordinate8{} L.Coordinate2{}:
      ({==},{==})
    case L.Coordinate8{} L.Coordinate3{}:
      ({==},{==})
    case L.Coordinate8{} L.Coordinate4{}:
      ({==},{==})
    case L.Coordinate8{} L.Coordinate5{}:
      ({==},{==})
    case L.Coordinate8{} L.Coordinate6{}:
      ({==},{==})
    case L.Coordinate8{} L.Coordinate7{}:
      ({==},{==})
    case L.Coordinate8{} L.Coordinate8{}:
      ({==},{==})

def L.prepared_geometry_to_routes(p,q,apart,old,aliases):
  (r,(c,(b,ptr))) = old
  (t0,t1) = aliases
  %Equal.sym(U32,(81 + L.prepared_column_unit(p) : U32),L.ordinary_col_slot(p),t0) : (L.RoutedApart(p,q) & L.RoutedApart(L.ordinary_row_slot(p),q) & L.RoutedApart(_,q) & L.RoutedApart((81 + L.prepared_box_unit(p) : U32),q))
  %Equal.sym(U32,(81 + L.prepared_box_unit(p) : U32),L.ordinary_box_slot(p),t1) : (L.RoutedApart(p,q) & L.RoutedApart(L.ordinary_row_slot(p),q) & L.RoutedApart(L.ordinary_col_slot(p),q) & L.RoutedApart(_,q))
  (apart,(r,(c,b)))

def L.logical_prepared_store_routes(sr,sc,qr,qc,each):
  +p = L.logical_position(sr,sc)
  +q = L.logical_position(qr,qc)
  L.prepared_geometry_to_routes(p,q,
    L.logical_distinct_apart(p,q,each,L.matrix_logical_entry(sr,sc,qr,qc),L.logical_address_facts(sr,sc),L.logical_address_facts(qr,qc)),
    L.ordinary_routes_from_coordinates(sr,sc,qr,qc),L.prepared_slot_aliases(sr,sc))

def L.prepared_store_keeps_other_legal(digit,p,q,word,state,routes,proof):
  match digit:
    case L.D0{}:
      (cell,(row,(col,box))) = routes
      L.prepared_cell_keeps_other(p,0,q,word,state,cell,proof)
    case L.D1{}:
      L.prepared_meta_chain_keeps_other(p,1,q,word,state,routes,proof)
    case L.D2{}:
      L.prepared_meta_chain_keeps_other(p,2,q,word,state,routes,proof)
    case L.D3{}:
      L.prepared_meta_chain_keeps_other(p,3,q,word,state,routes,proof)
    case L.D4{}:
      L.prepared_meta_chain_keeps_other(p,4,q,word,state,routes,proof)
    case L.D5{}:
      L.prepared_meta_chain_keeps_other(p,5,q,word,state,routes,proof)
    case L.D6{}:
      L.prepared_meta_chain_keeps_other(p,6,q,word,state,routes,proof)
    case L.D7{}:
      L.prepared_meta_chain_keeps_other(p,7,q,word,state,routes,proof)
    case L.D8{}:
      L.prepared_meta_chain_keeps_other(p,8,q,word,state,routes,proof)
    case L.D9{}:
      L.prepared_meta_chain_keeps_other(p,9,q,word,state,routes,proof)

def L.logical_prepared_store_keeps_other(digit,sr,sc,qr,qc,word,state,each,proof):
  +p = L.logical_position(sr,sc)
  +q = L.logical_position(qr,qc)
  L.prepared_store_keeps_other_legal(digit,p,q,word,state,L.logical_prepared_store_routes(sr,sc,qr,qc,each),proof)

def L.prepared_legal_digit_shape_for_final_write_image(p,value,image,bad,shape):
  +bit = Board.bit(value)
  +col = L.prepared_column_unit(p)
  +box = L.prepared_box_unit(p)
  after = L.prepared_meta_chain(p,bit,(L.image_board(image),bad))
  L.prepared_cell_exact_value(p,value,after,
    L.prepared_append_unit_shape(box,bit,P.prepared_unit(col,bit,P.prepared_row(p,bit,(L.image_board(image),bad))),
      L.prepared_append_unit_shape(col,bit,P.prepared_row(p,bit,(L.image_board(image),bad)),
        L.prepared_append_row_shape(p,bit,(L.image_board(image),bad),shape))))

def L.prepared_legal_digit_shape_for_final_write(p,value,state,shape):
  (b,+bad) = state
  f : (L.Board128(b) -> L.PreparedWord(P.prepared_set(p,value,L.prepared_meta_chain(p,Board.bit(value),(b,bad))),p,value)) =
    L.on_reified_board(b,x => (L.Board128(x) -> L.PreparedWord(P.prepared_set(p,value,L.prepared_meta_chain(p,Board.bit(value),(x,bad))),p,value)),
      L.reify_board(b),image => s => L.prepared_legal_digit_shape_for_final_write_image(p,value,image,bad,s))
  f(shape)

def L.prepared_legal_store_writes_exact_digit(digit,p,state,shape):
  match digit:
    case L.D0{}:
      L.prepared_cell_exact_value(p,0,state,shape)
    case L.D1{}:
      L.prepared_legal_digit_shape_for_final_write(p,1,state,shape)
    case L.D2{}:
      L.prepared_legal_digit_shape_for_final_write(p,2,state,shape)
    case L.D3{}:
      L.prepared_legal_digit_shape_for_final_write(p,3,state,shape)
    case L.D4{}:
      L.prepared_legal_digit_shape_for_final_write(p,4,state,shape)
    case L.D5{}:
      L.prepared_legal_digit_shape_for_final_write(p,5,state,shape)
    case L.D6{}:
      L.prepared_legal_digit_shape_for_final_write(p,6,state,shape)
    case L.D7{}:
      L.prepared_legal_digit_shape_for_final_write(p,7,state,shape)
    case L.D8{}:
      L.prepared_legal_digit_shape_for_final_write(p,8,state,shape)
    case L.D9{}:
      L.prepared_legal_digit_shape_for_final_write(p,9,state,shape)
