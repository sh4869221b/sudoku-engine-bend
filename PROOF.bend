import Base
import ./LAWS.bend as L
import ./sudoku/batch.bend as B
import ./sudoku/types.bend as T

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

def L.mirror_involute_all81():
  {==}

def L.cell_set_get_boundary_samples():
  {==}

def L.candidate_mask_empty_cell0():
  {==}

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
