import Base

type Options is Data:
  GenOptions{seed: U32, count: U32, target: U32, symmetry: Bool, minimal: Bool, seen: U32}

type ParsedOptions is Data:
  GoodOptions{options: Options}
  Pending{key: U32, options: Options}
  BadOptions{message: String}

def has(seen: U32, bit: U32) -> Bool:
  U32.is_ne(U32.and(seen, bit), 0)

def key(+s: String) -> U32:
  Bool.pick(U32, String.eq(s, "--seed"), 1, Bool.pick(U32, String.eq(s, "--count"), 2, Bool.pick(U32, String.eq(s, "--clues"), 4, Bool.pick(U32, String.eq(s, "--difficulty"), 8, Bool.pick(U32, String.eq(s, "--symmetry"), 16, Bool.pick(U32, String.eq(s, "--minimal"), 32, 0))))))

def profile(+s: String) -> Maybe<&2, U32>:
  Bool.pick(Maybe<&2, U32>, String.eq(s, "easy"), Some{36}, Bool.pick(Maybe<&2, U32>, String.eq(s, "medium"), Some{32}, Bool.pick(Maybe<&2, U32>, String.eq(s, "hard"), Some{28}, None{})))

def checked(ok: Bool, options: Options) -> ParsedOptions:
  match ok:
    case True{}:
      GoodOptions{options}
    case False{}:
      BadOptions{"numeric value out of range"}

def set_number(key: U32, value: Maybe<&2, U32>, options: Options) -> ParsedOptions:
  match key value options:
    case _ None{} _:
      BadOptions{"expected unsigned decimal integer or easy|medium|hard profile"}
    case 1 Some{n} GenOptions{seed, count, target, symmetry, minimal, seen}:
      GoodOptions{GenOptions{n, count, target, symmetry, minimal, seen}}
    case 2 Some{+n} GenOptions{seed, count, target, symmetry, minimal, seen}:
      checked(U32.is_ne(n, 0), GenOptions{seed, n, target, symmetry, minimal, seen})
    case _ Some{+n} GenOptions{seed, count, target, symmetry, minimal, seen}:
      checked((n <= 81 : U32), GenOptions{seed, count, n, symmetry, minimal, seen})

def new_option(duplicate: Bool, +key: U32, options: Options) -> ParsedOptions:
  match duplicate key options:
    case True{} _ _:
      BadOptions{"duplicate option"}
    case False{} 0 _:
      BadOptions{"unknown option"}
    case False{} 16 GenOptions{seed, count, target, symmetry, minimal, seen}:
      GoodOptions{GenOptions{seed, count, target, True{}, minimal, U32.or(seen, key)}}
    case False{} 32 GenOptions{seed, count, target, symmetry, minimal, seen}:
      GoodOptions{GenOptions{seed, count, target, symmetry, True{}, U32.or(seen, key)}}
    case False{} _ GenOptions{seed, count, target, symmetry, minimal, seen}:
      Pending{key, GenOptions{seed, count, target, symmetry, minimal, U32.or(seen, key)}}

def step(+token: String, state: ParsedOptions) -> ParsedOptions:
  match state:
    case BadOptions{message}:
      BadOptions{message}
    case Pending{8, options}:
      set_number(8, profile(token), options)
    case Pending{key, options}:
      set_number(key, U32.read(token), options)
    case GoodOptions{GenOptions{seed, count, target, symmetry, minimal, +seen}}:
      +k = key(token)
      new_option(has(seen, k), k, GenOptions{seed, count, target, symmetry, minimal, seen})

def final_check(conflict: Bool, options: Options) -> ParsedOptions:
  match conflict:
    case True{}:
      BadOptions{"--clues, --difficulty and --minimal are mutually exclusive"}
    case False{}:
      GoodOptions{options}

def finish(state: ParsedOptions) -> ParsedOptions:
  match state:
    case Pending{key, options}:
      BadOptions{"missing option value"}
    case BadOptions{message}:
      BadOptions{message}
    case GoodOptions{GenOptions{seed, count, target, symmetry, +minimal, +seen}}:
      final_check((has(seen, 4) && has(seen, 8)) || (minimal && has(seen, 12)), GenOptions{seed, count, Bool.pick(U32, minimal, 0, target), symmetry, minimal, seen})

def parse_go(args: List<String>, state: ParsedOptions) -> ParsedOptions:
  match args:
    case Nil{}:
      finish(state)
    case token <> tail:
      parse_go(tail, step(token, state))

def parse(args: List<String>) -> ParsedOptions:
  parse_go(args, GoodOptions{GenOptions{0, 1, 32, False{}, False{}, 0}})
