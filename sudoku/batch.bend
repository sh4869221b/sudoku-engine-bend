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

def consume_join(left: JobTree, pair: JobTree & List<&2, Job>) -> JobTree & List<&2, Job>:
  (right, tail) = pair
  (JFork{left, right}, tail)

def consume_right(next: List<&2, Job> -> JobTree & List<&2, Job>, pair: JobTree & List<&2, Job>) -> JobTree & List<&2, Job>:
  (left, rest) = pair
  consume_join(left, next(rest))

# Consume each list node once instead of copying take/drop prefixes at each level.
def consume(+depth: Nat, xs: List<&2, Job>) -> JobTree & List<&2, Job>:
  match depth xs:
    case _ Nil{}:
      (JEmpty{}, Nil{})
    case 0n j <> tail:
      (JLeaf{j}, tail)
    case 1n+k items:
      consume_right(rest => consume(k, rest), consume(k, items))

def build(+xs: List<&2, Job>) -> JobTree:
  +d = U32.to_nat(depth_go(32n, U32.from_nat(List.length(&2, Job, xs)), 1, 0))
  Pair.fst(JobTree, List<&2, Job>, consume(d, xs))

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

# One streaming pass keeps line and job accumulators reversed until finalized.
def text_reverse(s: String, acc: String) -> String:
  match s:
    case SNil{}:
      acc
    case SCon{h, tail}:
      text_reverse(tail, SCon{h, acc})

def text_line(reversed: String) -> String:
  match reversed:
    case SCon{'\r', tail}:
      text_reverse(tail, "")
    case other:
      text_reverse(other, "")

def text_add_if(omit: Bool, line: String, index: U32, acc: List<&2, Job>) -> List<&2, Job>:
  match omit:
    case True{}:
      acc
    case False{}:
      Job{index, line} <> acc

def text_add(+line: String, index: U32, acc: List<&2, Job>) -> List<&2, Job>:
  text_add_if(skip(line), line, index, acc)

def text_scan(s: String, +index: U32, line: String, acc: List<&2, Job>) -> List<&2, Job>:
  match s:
    case SNil{}:
      List.reverse(&2, Job, text_add(text_line(line), index, acc))
    case SCon{'\n', tail}:
      text_scan(tail, (index + 1 : U32), "", text_add(text_line(line), index, acc))
    case SCon{h, tail}:
      text_scan(tail, index, SCon{h, line}, acc)

def text_jobs(text: String) -> List<&2, Job>:
  text_scan(text, 1, "", Nil{})
