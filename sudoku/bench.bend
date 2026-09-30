import Base
import ./batch.bend as B
import ./commands.bend as C
import ./board.bend as Board
import ./parser.bend as P
import ./validate.bend as V
import ./solver.bend as S
import ./types.bend as T
import ./generator.bend as G

type Stats is Data:
  Stats{solved: U32, failed: U32}

def clue_match(puzzle: String, solution: String) -> Bool:
  match puzzle solution:
    case SNil{} SNil{}:
      True{}
    case SCon{+p, pt} SCon{s, st}:
      (Char.is_eq(p, '0') || Char.is_eq(p, '.') || Char.is_eq(p, s)) && clue_match(pt, st)
    case _ _:
      False{}

def valid_reply(reply: C.Reply) -> Bool:
  match reply:
    case C.Reply{0, out, err}:
      True{}
    case _:
      False{}

def count_reply(+puzzle: String, reply: C.Reply) -> Stats:
  match reply:
    case C.Reply{0, +solution, err}:
      +ok = clue_match(puzzle, solution) && Bool.not(String.contains(solution, "0")) && valid_reply(C.eval(2, False{}, 1n, 1n, solution))
      Stats{Bool.pick(U32, ok, 1, 0), Bool.pick(U32, ok, 0, 1)}
    case _:
      Stats{0, 1}

def add(a: Stats, b: Stats) -> Stats:
  match a b:
    case Stats{sa, fa} Stats{sb, fb}:
      Stats{(sa + sb : U32), (fa + fb : U32)}

def run(tree: B.JobTree) -> Stats:
  match tree:
    case B.JEmpty{}:
      Stats{0, 0}
    case B.JLeaf{B.Job{index, +puzzle}}:
      count_reply(puzzle, C.eval(1, False{}, T.solve_fuel(), T.rate_fuel(), puzzle))
    case B.JFork{l, r}:
      a b = run(l) run(r)
      add(a, b)

def all_valid(jobs: List<&2, B.Job>) -> Bool:
  match jobs:
    case Nil{}:
      True{}
    case B.Job{index, puzzle} <> tail:
      valid_reply(C.eval(2, False{}, 1n, 1n, puzzle)) && all_valid(tail)

def gen_text(result: G.DigResult) -> Maybe<&2, String>:
  match result:
    case G.DigDone{board, clues}:
      Some{Board.show(board)}
    case G.DigFuel{}:
      None{}

def gen_prepend(index: U32, head: Maybe<&2, String>, rest: Maybe<&2, List<&2, B.Job>>) -> Maybe<&2, List<&2, B.Job>>:
  match head rest:
    case Some{puzzle} Some{tail}:
      Some{B.Job{index, puzzle} <> tail}
    case _ _:
      None{}

def generate(n: Nat, +index: U32) -> Maybe<&2, List<&2, B.Job>>:
  match n:
    case 0n:
      Some{Nil{}}
    case 1n+k:
      gen_prepend(index, gen_text(G.generate(T.digging_fuel(), index, 36, False{})), generate(k, (index + 1 : U32)))

def allowed_n(+n: U32) -> Bool:
  U32.is_eq(n, 1) || U32.is_eq(n, 10) || U32.is_eq(n, 100) || U32.is_eq(n, 1000) || U32.is_eq(n, 10000)

def report(+n: U32, start: Nat, finish: Nat, stats: Stats) -> IO(Unit):
  match stats:
    case Stats{solved, 0}:
      +elapsed = Nat.sub(finish, start)
      IO.print("N=" ++ U32.show(n) ++ " mode=cpu threads=runtime total_ms=" ++ Nat.show(elapsed) ++ " per_ms=" ++ F32.show(F32.div(F32.from_nat(elapsed), U32.to_f32(n))))
    case Stats{solved, failed}:
      IO.die(Unit, 4, "benchmark failed: solved=" ++ U32.show(solved) ++ " failed=" ++ U32.show(failed))

def timed_result(n: U32, start: Nat, stats: Stats) -> IO(Unit):
  # Calling this helper forces the pure fork-join result before reading the end clock.
  match stats:
    case Stats{solved, failed}:
      do IO<Unit>:
        finish : Nat <- IO.now()
        report(n, start, finish, Stats{solved, failed})

def timed(n: U32, tree: B.JobTree) -> IO(Unit):
  do IO<Unit>:
    start : Nat <- IO.now()
    timed_result(n, start, run(tree))

def prepared(ok: Bool, n: U32, jobs: List<&2, B.Job>) -> IO(Unit):
  match ok:
    case False{}:
      IO.die(Unit, 2, "invalid benchmark input")
    case True{}:
      timed(n, B.build(jobs))

def file_jobs(+jobs: List<&2, B.Job>) -> IO(Unit):
  +n = U32.from_nat(List.length(&2, B.Job, jobs))
  prepared(U32.is_ne(n, 0) && all_valid(jobs), n, jobs)

def generated(jobs: Maybe<&2, List<&2, B.Job>>) -> IO(Unit):
  match jobs:
    case None{}:
      IO.die(Unit, 4, "benchmark preparation fuel")
    case Some{xs}:
      file_jobs(xs)

def gen_count(ok: Bool, count: U32) -> IO(Unit):
  match ok:
    case False{}:
      IO.die(Unit, 1, "bench --generate requires 1,10,100,1000 or 10000")
    case True{}:
      generated(generate(U32.to_nat(count), 1))

def gen_option(count: Maybe<&2, U32>) -> IO(Unit):
  match count:
    case None{}:
      IO.die(Unit, 1, "invalid benchmark count")
    case Some{+n}:
      gen_count(allowed_n(n), n)
