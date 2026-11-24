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
