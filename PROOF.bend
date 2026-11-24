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
