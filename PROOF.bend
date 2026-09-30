import Base
import ./LAWS.bend as L
import ./sudoku/batch.bend as B
import ./sudoku/types.bend as T

def L.batch_solve_eq_seq(tree):
  match tree:
    case B.JEmpty{}:
      {==}
    case B.JLeaf{job}:
      {==}
    case B.JFork{l, r}:
      %L.batch_solve_eq_seq(l) : {B.batch_solve(l) ++ B.batch_solve(r) == _ ++ B.seq_solve(r) : String}
      %L.batch_solve_eq_seq(r) : {B.batch_solve(l) ++ B.batch_solve(r) == B.batch_solve(l) ++ _ : String}
      {==}

def L.batch_check_eq_seq(tree):
  match tree:
    case B.JEmpty{}:
      {==}
    case B.JLeaf{job}:
      {==}
    case B.JFork{l, r}:
      %L.batch_check_eq_seq(l) : {B.batch_check(l) ++ B.batch_check(r) == _ ++ B.seq_check(r) : String}
      %L.batch_check_eq_seq(r) : {B.batch_check(l) ++ B.batch_check(r) == B.batch_check(l) ++ _ : String}
      {==}

def L.batch_count_eq_seq(tree):
  match tree:
    case B.JEmpty{}:
      {==}
    case B.JLeaf{job}:
      {==}
    case B.JFork{l, r}:
      %L.batch_count_eq_seq(l) : {B.batch_count(l) ++ B.batch_count(r) == _ ++ B.seq_count(r) : String}
      %L.batch_count_eq_seq(r) : {B.batch_count(l) ++ B.batch_count(r) == B.batch_count(l) ++ _ : String}
      {==}

def L.batch_rate_eq_seq(tree):
  match tree:
    case B.JEmpty{}:
      {==}
    case B.JLeaf{job}:
      {==}
    case B.JFork{l, r}:
      %L.batch_rate_eq_seq(l) : {B.batch_rate(l) ++ B.batch_rate(r) == _ ++ B.seq_rate(r) : String}
      %L.batch_rate_eq_seq(r) : {B.batch_rate(l) ++ B.batch_rate(r) == B.batch_rate(l) ++ _ : String}
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
