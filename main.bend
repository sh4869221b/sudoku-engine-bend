import Base
import ./sudoku/commands.bend as C
import ./sudoku/cliargs.bend as A
import ./sudoku/board.bend as B
import ./sudoku/types.bend as T
import ./sudoku/generator.bend as G
import ./sudoku/batch.bend as Batch
import ./sudoku/bench.bend as Bench

def help() -> String:
  "bend-sudoku solve|check|count|rate <81-character puzzle>\nbend-sudoku generate [--seed N] [--count K] [--clues N | --difficulty easy|medium|hard | --minimal] [--symmetry]\nbend-sudoku batch <file> solve|check|count|rate\nbend-sudoku bench <file> | --generate N\nUse 0 or . for blanks. No embedded whitespace.\n--difficulty is only a clue-count preset: easy=36, medium=32, hard=28. It does not guarantee a rate label.\n--minimal is strict per-clue minimality without symmetry, or pair-minimality with --symmetry. It conflicts with --clues/--difficulty.\nExact clue targets never undershoot. TargetUnmet is a stderr warning, exit 0.\nGeneration fuel failure exits 4: already printed puzzles are valid; the failed puzzle and all later puzzles are omitted.\nBatch skips empty/# lines, preserves physical indices, and exits 0 even for per-line errors or no jobs.\nExit: 0 success, 1 usage/read error, 2 invalid puzzle, 3 no solution/contradiction, 4 fuel.\nRuntime flags --threads N precede --; use -- before application arguments if needed."

def usage(message: String) -> IO(Unit):
  IO.die(Unit, 1, message ++ "\n" ++ help())

def print_nonempty(text: String) -> IO(Unit):
  match text:
    case SNil{}:
      IO.pure(Unit, Unit{})
    case SCon{h, tail}:
      IO.print(SCon{h, tail})

def exit(code: U32, message: String) -> IO(Unit):
  match code:
    case 0:
      IO.pure(Unit, Unit{})
    case _:
      IO.die(Unit, code, message)

def reply(result: C.Reply) -> IO(Unit):
  match result:
    case C.Reply{code, out, err}:
      do IO<Unit>:
        print_nonempty(out)
        exit(code, err)

def gen_warning(unmet: Bool, index: U32, seed: U32, target: U32, clues: U32) -> IO(Unit):
  match unmet:
    case False{}:
      IO.pure(Unit, Unit{})
    case True{}:
      IO.print_err("TargetUnmet index=" ++ U32.show(index) ++ " seed=" ++ U32.show(seed) ++ " target=" ++ U32.show(target) ++ " reached=" ++ U32.show(clues))

def generate_one(index: U32, seed: U32, +target: U32, minimal: Bool, result: G.DigResult) -> IO(Unit):
  match result:
    case G.DigFuel{}:
      IO.die(Unit, 4, "generate index=" ++ U32.show(index) ++ " seed=" ++ U32.show(seed) ++ " fuel; valid completed prefix retained; repeating the same seed repeats the failure")
    case G.DigDone{board, +clues}:
      do IO<Unit>:
        IO.print(B.show(board))
        gen_warning(Bool.not(minimal) && U32.is_ne(target, clues), index, seed, target, clues)


def generate_loop(n: Nat, +index: U32, +seed: U32, +target: U32, +symmetry: Bool, +minimal: Bool) -> IO(Unit):
  match n:
    case 0n:
      IO.pure(Unit, Unit{})
    case 1n+k:
      do IO<Unit>:
        generate_one(index, seed, target, minimal, G.generate(T.digging_fuel(), seed, target, symmetry))
        generate_loop(k, (index + 1 : U32), (seed + 1 : U32), target, symmetry, minimal)

def generate(options: A.ParsedOptions) -> IO(Unit):
  match options:
    case A.BadOptions{message}:
      usage(message)
    case A.Pending{key, options}:
      usage("missing option value")
    case A.GoodOptions{A.GenOptions{seed, count, target, symmetry, minimal, seen}}:
      generate_loop(U32.to_nat(count), 1, seed, target, symmetry, minimal)

def read_result(result: Result<&1, &1, U32 & String, String>) -> IO(String):
  match result:
    case Done{text}:
      IO.pure(String, text)
    case Fail{reason}:
      IO.die(String, 1, "file read failed")

def read_close(pair: File & Result<&1, &1, U32 & String, String>) -> IO(String):
  (file, result) = pair
  do IO<String>:
    File.close(file)
    read_result(result)

def read_amount(ok: Bool, amount: U32, file: File) -> IO(String):
  match ok:
    case False{}:
      do IO<String>:
        File.close(file)
        IO.die(String, 1, "file exceeds the 16 MiB input limit")
    case True{}:
      do IO<String>:
        data : File & Result<&1, &1, U32 & String, String> <- File.read(file, amount)
        read_close(data)

def sized(pair: File & Result<&1, &1, U32 & String, U32>) -> IO(String):
  (file, result) = pair
  match result:
    case Fail{reason}:
      do IO<String>:
        File.close(file)
        IO.die(String, 1, "file size failed")
    case Done{+amount}:
      read_amount((amount <= 16777216 : U32), amount, file)

def opened(result: Result<&1, &1, U32 & String, File>) -> IO(String):
  match result:
    case Fail{reason}:
      IO.die(String, 1, "file open failed")
    case Done{file}:
      do IO<String>:
        size : File & Result<&1, &1, U32 & String, U32> <- File.size(file)
        sized(size)

def read_file(path: String) -> IO(String):
  do IO<String>:
    file : Result<&1, &1, U32 & String, File> <- File.open(path, "r")
    opened(file)

def batch(mode: U32, path: String) -> IO(Unit):
  match mode:
    case 0:
      usage("unknown batch mode")
    case _:
      do IO<Unit>:
        text : String <- read_file(path)
        IO.write(Batch.run(mode, Batch.build(Batch.text_jobs(text))))

def benchmark_generated(ok: Bool, value: String) -> IO(Unit):
  match ok:
    case True{}:
      Bench.gen_option(U32.read(value))
    case False{}:
      usage("bench expects exactly one file or --generate N")

def benchmark(args: List<String>) -> IO(Unit):
  match args:
    case path <> Nil{}:
      do IO<Unit>:
        text : String <- read_file(path)
        Bench.file_jobs(Batch.text_jobs(text))
    case flag <> count <> Nil{}:
      benchmark_generated(String.eq(flag, "--generate"), count)
    case _:
      usage("bench expects exactly one file or --generate N")

def dispatch_one(mode: U32, args: List<String>) -> IO(Unit):
  match args:
    case puzzle <> Nil{}:
      reply(C.eval(mode, False{}, T.solve_fuel(), T.rate_fuel(), puzzle))
    case _:
      usage("expected exactly one puzzle")

def dispatch_mode(mode: U32, args: List<String>) -> IO(Unit):
  match mode:
    case 0:
      usage("unknown command")
    case _:
      dispatch_one(mode, args)

def dispatch_other(command: String, args: List<String>) -> IO(Unit):
  dispatch_mode(C.mode(command), args)

def dispatch_named(kind: U32, command: String, args: List<String>) -> IO(Unit):
  match kind args:
    case 1 _:
      generate(A.parse(args))
    case 2 path <> name <> Nil{}:
      batch(C.mode(name), path)
    case 2 _:
      usage("batch requires a file and mode")
    case 3 _:
      benchmark(args)
    case 4 Nil{}:
      IO.print(help())
    case 4 _:
      usage("unexpected help arguments")
    case _ _:
      dispatch_other(command, args)

def dispatch(+command: String, args: List<String>) -> IO(Unit):
  dispatch_named(Bool.pick(U32, String.eq(command, "generate"), 1, Bool.pick(U32, String.eq(command, "batch"), 2, Bool.pick(U32, String.eq(command, "bench"), 3, Bool.pick(U32, String.eq(command, "--help") || String.eq(command, "help"), 4, 0)))), command, args)

def argv(args: List<String>) -> IO(Unit):
  match args:
    case program <> command <> tail:
      dispatch(command, tail)
    case _:
      usage("missing command")

def main() -> IO(Unit):
  do IO<Unit>:
    args : List<String> <- IO.args()
    argv(args)
