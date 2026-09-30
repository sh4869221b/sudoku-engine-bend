import Base
import ./commands.bend as C
import ./types.bend as T

type Job is Data:
  Job{index: U32, puzzle: String}

type JobTree is Data:
  JEmpty{}
  JLeaf{job: Job}
  JFork{left: JobTree, right: JobTree}

def skip(+line: String) -> Bool:
  String.is_empty(line) || String.starts_with(line, "#")

def normalize_line(+line: String) -> String:
  Bool.pick(String, String.ends_with(line, "\r"), String.take(line, Nat.sub(String.length(line), 1n)), line)

def jobs(lines: List<&2, String>, +index: U32) -> List<&2, Job>:
  match lines:
    case Nil{}:
      Nil{}
    case raw <> tail:
      +line = normalize_line(raw)
      List.append(&2, Job, Bool.pick(List<&2, Job>, skip(line), Nil{}, [Job{index, line}]), jobs(tail, (index + 1 : U32)))

def leaf(xs: List<&2, Job>) -> JobTree:
  match xs:
    case Nil{}:
      JEmpty{}
    case j <> tail:
      JLeaf{j}

def tree(+depth: Nat, +size: Nat, +xs: List<&2, Job>) -> JobTree:
  match depth:
    case 0n:
      leaf(xs)
    case 1n+k:
      +half = Nat.div(size, 2n)
      JFork{tree(k, half, List.take(&2, Job, xs, half)), tree(k, half, List.drop(&2, Job, xs, half))}

def depth_go(fuel: Nat, +n: U32, +size: U32, +depth: U32) -> U32:
  match fuel:
    case 0n:
      depth
    case 1n+k:
      Bool.pick(U32, (size >= n : U32), depth, depth_go(k, n, U32.shl(size), (depth + 1 : U32)))

def build(+xs: List<&2, Job>) -> JobTree:
  +d = U32.to_nat(depth_go(32n, U32.from_nat(List.length(&2, Job, xs)), 1, 0))
  tree(d, U32.to_nat(U32.shln(1, d)), xs)

def job_line(mode: U32, job: Job) -> String:
  match job:
    case Job{index, puzzle}:
      U32.show(index) ++ " " ++ C.only_out(C.eval(mode, True{}, T.solve_fuel(), T.rate_fuel(), puzzle)) ++ "\n"

def batch_solve(tree: JobTree) -> String:
  match tree:
    case JEmpty{}:
      ""
    case JLeaf{job}:
      job_line(1, job)
    case JFork{l, r}:
      a b = batch_solve(l) batch_solve(r)
      a ++ b

def batch_check(tree: JobTree) -> String:
  match tree:
    case JEmpty{}:
      ""
    case JLeaf{job}:
      job_line(2, job)
    case JFork{l, r}:
      a b = batch_check(l) batch_check(r)
      a ++ b

def batch_count(tree: JobTree) -> String:
  match tree:
    case JEmpty{}:
      ""
    case JLeaf{job}:
      job_line(3, job)
    case JFork{l, r}:
      a b = batch_count(l) batch_count(r)
      a ++ b

def batch_rate(tree: JobTree) -> String:
  match tree:
    case JEmpty{}:
      ""
    case JLeaf{job}:
      job_line(4, job)
    case JFork{l, r}:
      a b = batch_rate(l) batch_rate(r)
      a ++ b

def run(mode: U32, tree: JobTree) -> String:
  match mode:
    case 1:
      batch_solve(tree)
    case 2:
      batch_check(tree)
    case 3:
      batch_count(tree)
    case _:
      batch_rate(tree)

def sequential(xs: List<&2, Job>, +mode: U32) -> String:
  match xs:
    case Nil{}:
      ""
    case job <> tail:
      job_line(mode, job) ++ sequential(tail, mode)

# Sequential structural comparator for the proof gate; each mode uses the same leaf evaluator.
def seq_solve(tree: JobTree) -> String:
  match tree:
    case JEmpty{}:
      ""
    case JLeaf{job}:
      job_line(1, job)
    case JFork{l, r}:
      seq_solve(l) ++ seq_solve(r)

def seq_check(tree: JobTree) -> String:
  match tree:
    case JEmpty{}:
      ""
    case JLeaf{job}:
      job_line(2, job)
    case JFork{l, r}:
      seq_check(l) ++ seq_check(r)

def seq_count(tree: JobTree) -> String:
  match tree:
    case JEmpty{}:
      ""
    case JLeaf{job}:
      job_line(3, job)
    case JFork{l, r}:
      seq_count(l) ++ seq_count(r)

def seq_rate(tree: JobTree) -> String:
  match tree:
    case JEmpty{}:
      ""
    case JLeaf{job}:
      job_line(4, job)
    case JFork{l, r}:
      seq_rate(l) ++ seq_rate(r)
