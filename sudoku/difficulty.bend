import Base
import ./board.bend as B
import ./candidates.bend as C

type Cell is Data:
  Fixed{digit: U32}
  Open{mask: U32}

type Action is Data:
  NoAction{}
  Place{pos: U32, digit: U32, technique: U32}
  Remove{positions: List<&2, U32>, mask: U32, technique: U32}

type RateResult is Data:
  Rated{status: U32, technique: U32, steps: U32, score: U32}

# status: 0 complete, 1 requires guess, 2 contradiction, 3 fuel

def cell_from(d: U32) -> Cell:
  match d:
    case 0:
      Open{1022}
    case _:
      Fixed{d}

def from_values(xs: List<U32>) -> List<&2, Cell>:
  match xs:
    case Nil{}:
      Nil{}
    case d <> tail:
      cell_from(d) <> from_values(tail)

def cell_or(c: Maybe<&2, Cell>) -> Cell:
  match c:
    case Some{cell}:
      cell
    case None{}:
      Open{0}

def cell(xs: List<&2, Cell>, pos: U32) -> Cell:
  cell_or(List.get(&2, Cell, xs, U32.to_nat(pos)))

def mask(c: Cell) -> U32:
  match c:
    case Fixed{d}:
      0
    case Open{m}:
      m

def is_fixed(c: Cell, digit: U32) -> Bool:
  match c:
    case Fixed{d}:
      U32.is_eq(d, digit)
    case Open{m}:
      False{}

def in_unit(+unit: U32, +p: U32) -> Bool:
  Bool.pick(Bool, (unit < 9 : U32), U32.is_eq((p / 9 : U32), unit), Bool.pick(Bool, (unit < 18 : U32), U32.is_eq((p % 9 : U32), (unit - 9 : U32)), U32.is_eq(B.box_of(p), (unit - 18 : U32))))

def contains(xs: List<&2, U32>, +p: U32) -> Bool:
  match xs:
    case Nil{}:
      False{}
    case h <> t:
      U32.is_eq(h, p) || contains(t, p)

def clear_cell(c: Cell, bits: U32) -> Cell:
  match c:
    case Fixed{d}:
      Fixed{d}
    case Open{m}:
      Open{U32.and(m, U32.not(bits))}

def place_cells(xs: List<&2, Cell>, +i: U32, +pos: U32, +digit: U32) -> List<&2, Cell>:
  match xs:
    case Nil{}:
      Nil{}
    case +h <> t:
      Bool.pick(Cell, U32.is_eq(i, pos), Fixed{digit}, Bool.pick(Cell, B.peers(i, pos), clear_cell(h, B.bit(digit)), h)) <> place_cells(t, (i + 1 : U32), pos, digit)

def remove_cells(xs: List<&2, Cell>, +i: U32, +positions: List<&2, U32>, +bits: U32) -> List<&2, Cell>:
  match xs:
    case Nil{}:
      Nil{}
    case +h <> t:
      Bool.pick(Cell, contains(positions, i), clear_cell(h, bits), h) <> remove_cells(t, (i + 1 : U32), positions, bits)

def apply(xs: List<&2, Cell>, action: Action) -> List<&2, Cell>:
  match action:
    case NoAction{}:
      xs
    case Place{pos, digit, technique}:
      place_cells(xs, 0, pos, digit)
    case Remove{positions, bits, technique}:
      remove_cells(xs, 0, positions, bits)

def init_action(pos: U32, c: Cell) -> Action:
  match c:
    case Fixed{digit}:
      Place{pos, digit, 0}
    case Open{m}:
      NoAction{}

def initialize_go(n: Nat, +pos: U32, +xs: List<&2, Cell>) -> List<&2, Cell>:
  match n:
    case 0n:
      xs
    case 1n+k:
      initialize_go(k, (pos + 1 : U32), apply(xs, init_action(pos, cell(xs, pos))))

def singleton_digit(ds: List<&2, U32>) -> U32:
  match ds:
    case Nil{}:
      0
    case d <> t:
      d

def naked_cell(pos: U32, +m: U32) -> Action:
  Bool.pick(Action, U32.is_eq(C.mask_count(m), 1), Place{pos, singleton_digit(C.mask_digits(m)), 1}, NoAction{})

def naked(xs: List<&2, Cell>, +pos: U32, found: Action) -> Action:
  match xs found:
    case _ Place{p, d, tech}:
      Place{p, d, tech}
    case _ Remove{ps, m, tech}:
      Remove{ps, m, tech}
    case Nil{} NoAction{}:
      NoAction{}
    case h <> t NoAction{}:
      naked(t, (pos + 1 : U32), naked_cell(pos, mask(h)))

def support_scan(xs: List<&2, Cell>, +p: U32, +unit: U32, +digit: U32) -> List<&2, U32>:
  match xs:
    case Nil{}:
      Nil{}
    case h <> tail:
      List.append(&2, U32, Bool.pick(List<&2, U32>, in_unit(unit, p) && U32.is_ne(U32.and(mask(h), B.bit(digit)), 0), [p], Nil{}), support_scan(tail, (p + 1 : U32), unit, digit))

def unit_support(n: Nat, +unit: U32, +j: U32, +digit: U32, +xs: List<&2, Cell>) -> List<&2, U32>:
  match n j:
    case 9n 0:
      support_scan(xs, 0, unit, digit)
    case 0n _:
      Nil{}
    case 1n+k _:
      +p = B.unit_pos(unit, j)
      List.append(&2, U32, Bool.pick(List<&2, U32>, U32.is_ne(U32.and(mask(cell(xs, p)), B.bit(digit)), 0), [p], Nil{}), unit_support(k, unit, (j + 1 : U32), digit, xs))

def fixed_scan(xs: List<&2, Cell>, +p: U32, +unit: U32, +digit: U32) -> Bool:
  match xs:
    case Nil{}:
      False{}
    case h <> tail:
      (in_unit(unit, p) && is_fixed(h, digit)) || fixed_scan(tail, (p + 1 : U32), unit, digit)

def fixed_in(n: Nat, +unit: U32, +j: U32, +digit: U32, +xs: List<&2, Cell>) -> Bool:
  match n j:
    case 9n 0:
      fixed_scan(xs, 0, unit, digit)
    case 0n _:
      False{}
    case 1n+k _:
      is_fixed(cell(xs, B.unit_pos(unit, j)), digit) || fixed_in(k, unit, (j + 1 : U32), digit, xs)

def hidden_one(support: List<&2, U32>, digit: U32, fixed: Bool) -> Action:
  match support fixed:
    case p <> Nil{} False{}:
      Place{p, digit, 2}
    case _ _:
      NoAction{}

def hidden_go(n: Nat, +index: U32, +xs: List<&2, Cell>, found: Action) -> Action:
  match n found:
    case _ Place{p, d, tech}:
      Place{p, d, tech}
    case _ Remove{ps, m, tech}:
      Remove{ps, m, tech}
    case 0n NoAction{}:
      NoAction{}
    case 1n+k NoAction{}:
      +u = (index / 9 : U32)
      +d = (1 + index % 9 : U32)
      hidden_go(k, (index + 1 : U32), xs, hidden_one(unit_support(9n, u, 0, d, xs), d, fixed_in(9n, u, 0, d, xs)))

def all_in(ps: List<&2, U32>, +unit: U32) -> Bool:
  match ps:
    case Nil{}:
      True{}
    case p <> t:
      in_unit(unit, p) && all_in(t, unit)

def elimination_positions(n: Nat, +target: U32, +source: U32, +j: U32, +bits: U32, +xs: List<&2, Cell>) -> List<&2, U32>:
  match n:
    case 0n:
      Nil{}
    case 1n+k:
      +p = B.unit_pos(target, j)
      List.append(&2, U32, Bool.pick(List<&2, U32>, Bool.not(in_unit(source, p)) && U32.is_ne(U32.and(mask(cell(xs, p)), bits), 0), [p], Nil{}), elimination_positions(k, target, source, (j + 1 : U32), bits, xs))

def removal(ps: List<&2, U32>, bits: U32, technique: U32) -> Action:
  match ps:
    case Nil{}:
      NoAction{}
    case p <> tail:
      Remove{p <> tail, bits, technique}

def locked_target(ok: Bool, +source: U32, +target: U32, +digit: U32, xs: List<&2, Cell>) -> Action:
  match ok:
    case False{}:
      NoAction{}
    case True{}:
      removal(elimination_positions(9n, target, source, 0, B.bit(digit), xs), B.bit(digit), 3)

def locked_targets(targets: List<&2, U32>, +source: U32, +digit: U32, +support: List<&2, U32>, +xs: List<&2, Cell>, found: Action) -> Action:
  match targets found:
    case _ Remove{ps, m, tech}:
      Remove{ps, m, tech}
    case _ Place{p, d, tech}:
      Place{p, d, tech}
    case Nil{} NoAction{}:
      NoAction{}
    case +target <> tail NoAction{}:
      locked_targets(tail, source, digit, support, xs, locked_target(U32.is_ne(source, target) && all_in(support, target), source, target, digit, xs))

def locked_support(source: U32, digit: U32, support: List<&2, U32>, xs: List<&2, Cell>) -> Action:
  match support:
    case Nil{}:
      NoAction{}
    case +p <> +tail:
      locked_targets([(p / 9 : U32), (9 + p % 9 : U32), (18 + B.box_of(p) : U32)], source, digit, p <> tail, xs, NoAction{})

def locked_go(n: Nat, +index: U32, +xs: List<&2, Cell>, found: Action) -> Action:
  match n found:
    case _ Remove{ps, m, tech}:
      Remove{ps, m, tech}
    case _ Place{p, d, tech}:
      Place{p, d, tech}
    case 0n NoAction{}:
      NoAction{}
    case 1n+k NoAction{}:
      +u = (index / 9 : U32)
      +d = (1 + index % 9 : U32)
      locked_go(k, (index + 1 : U32), xs, locked_support(u, d, unit_support(9n, u, 0, d, xs), xs))

def pair_count(n: Nat, +unit: U32, +j: U32, +bits: U32, +xs: List<&2, Cell>) -> U32:
  match n:
    case 0n:
      0
    case 1n+k:
      (Bool.pick(U32, U32.is_eq(mask(cell(xs, B.unit_pos(unit, j))), bits), 1, 0) + pair_count(k, unit, (j + 1 : U32), bits, xs) : U32)

def pair_positions(n: Nat, +unit: U32, +j: U32, +bits: U32, +xs: List<&2, Cell>) -> List<&2, U32>:
  match n:
    case 0n:
      Nil{}
    case 1n+k:
      +p = B.unit_pos(unit, j)
      +m = mask(cell(xs, p))
      List.append(&2, U32, Bool.pick(List<&2, U32>, U32.is_ne(m, bits) && U32.is_ne(U32.and(m, bits), 0), [p], Nil{}), pair_positions(k, unit, (j + 1 : U32), bits, xs))

def pair_action(ok: Bool, unit: U32, +bits: U32, xs: List<&2, Cell>) -> Action:
  match ok:
    case False{}:
      NoAction{}
    case True{}:
      removal(pair_positions(9n, unit, 0, bits, xs), bits, 4)

def pair_go(n: Nat, +index: U32, +xs: List<&2, Cell>, found: Action) -> Action:
  match n found:
    case _ Remove{ps, m, tech}:
      Remove{ps, m, tech}
    case _ Place{p, d, tech}:
      Place{p, d, tech}
    case 0n NoAction{}:
      NoAction{}
    case 1n+k NoAction{}:
      +u = (index / 9 : U32)
      +m = mask(cell(xs, B.unit_pos(u, (index % 9 : U32))))
      pair_go(k, (index + 1 : U32), xs, pair_action(U32.is_eq(C.mask_count(m), 2) && U32.is_eq(pair_count(9n, u, 0, m, xs), 2), u, m, xs))

def ladder_pair(xs: List<&2, Cell>, found: Action) -> Action:
  match found:
    case NoAction{}:
      pair_go(243n, 0, xs, NoAction{})
    case other:
      other

def ladder_locked(+xs: List<&2, Cell>, found: Action) -> Action:
  match found:
    case NoAction{}:
      ladder_pair(xs, locked_go(243n, 0, xs, NoAction{}))
    case other:
      other

def ladder_hidden(+xs: List<&2, Cell>, found: Action) -> Action:
  match found:
    case NoAction{}:
      ladder_locked(xs, hidden_go(243n, 0, xs, NoAction{}))
    case other:
      other

def ladder(+xs: List<&2, Cell>) -> Action:
  ladder_hidden(xs, naked(xs, 0, NoAction{}))

def zero_cell(xs: List<&2, Cell>) -> Bool:
  match xs:
    case Nil{}:
      False{}
    case Open{0} <> tail:
      True{}
    case other <> tail:
      zero_cell(tail)

def possible_bits(c: Cell) -> U32:
  match c:
    case Fixed{d}:
      B.bit(d)
    case Open{m}:
      m

def covered_scan(xs: List<&2, Cell>, +p: U32, +unit: U32, covered: U32) -> U32:
  match xs:
    case Nil{}:
      covered
    case h <> tail:
      covered_scan(tail, (p + 1 : U32), unit, U32.or(covered, Bool.pick(U32, in_unit(unit, p), possible_bits(h), 0)))

def missing_units(n: Nat, +unit: U32, +xs: List<&2, Cell>) -> Bool:
  match n:
    case 0n:
      False{}
    case 1n+k:
      U32.is_ne(covered_scan(xs, 0, unit, 0), 1022) || missing_units(k, (unit + 1 : U32), xs)

def missing_go(n: Nat, +index: U32, +xs: List<&2, Cell>) -> Bool:
  match n index:
    case 243n 0:
      missing_units(27n, 0, xs)
    case 0n _:
      False{}
    case 1n+k _:
      +u = (index / 9 : U32)
      +d = (1 + index % 9 : U32)
      (Bool.not(fixed_in(9n, u, 0, d, xs)) && List.is_empty(&2, U32, unit_support(9n, u, 0, d, xs))) || missing_go(k, (index + 1 : U32), xs)

def full(xs: List<&2, Cell>) -> Bool:
  match xs:
    case Nil{}:
      True{}
    case Open{m} <> tail:
      False{}
    case Fixed{d} <> tail:
      full(tail)

def technique(action: Action) -> U32:
  match action:
    case NoAction{}:
      0
    case Place{p, d, tech}:
      tech
    case Remove{ps, m, tech}:
      tech

def weight(tech: U32) -> U32:
  match tech:
    case 1:
      1
    case 2:
      2
    case 3:
      5
    case 4:
      10
    case _:
      0

type State is Data:
  Rating{cells: List<&2, Cell>, technique: U32, steps: U32, score: U32}
  Finished{result: RateResult}

def make_step(xs: List<&2, Cell>, +maxtech: U32, steps: U32, score: U32, action: Action) -> State:
  match action:
    case NoAction{}:
      Finished{Rated{1, maxtech, steps, score}}
    case Place{+p, +d, +tech}:
      Rating{apply(xs, Place{p, d, tech}), Bool.pick(U32, (tech > maxtech : U32), tech, maxtech), (steps + 1 : U32), (score + weight(tech) : U32)}
    case Remove{+ps, +m, +tech}:
      Rating{apply(xs, Remove{ps, m, tech}), Bool.pick(U32, (tech > maxtech : U32), tech, maxtech), (steps + 1 : U32), (score + weight(tech) : U32)}

def step_ready(bad: Bool, complete: Bool, +xs: List<&2, Cell>, tech: U32, steps: U32, score: U32) -> State:
  match bad complete:
    case True{} _:
      Finished{Rated{2, tech, steps, score}}
    case False{} True{}:
      Finished{Rated{0, tech, steps, score}}
    case False{} False{}:
      make_step(xs, tech, steps, score, ladder(xs))

def rate_loop(fuel: Nat, state: State) -> RateResult:
  match fuel state:
    case _ Finished{result}:
      result
    case 0n Rating{xs, tech, steps, score}:
      Rated{3, tech, steps, score}
    case 1n+k Rating{+xs, tech, steps, score}:
      rate_loop(k, step_ready(zero_cell(xs) || missing_go(243n, 0, xs), full(xs), xs, tech, steps, score))

def rate(fuel: Nat, board: Array<U32>) -> RateResult:
  rate_loop(fuel, Rating{initialize_go(81n, 0, from_values(List.take(&1, U32, Array.to_list(~U32, board), 81n))), 0, 0, 0})

def label(+status: U32, +score: U32) -> String:
  Bool.pick(String, (status >= 2 : U32), "-", Bool.pick(String, U32.is_eq(status, 1), "Hard", Bool.pick(String, (score < 25 : U32), "Easy", Bool.pick(String, (score < 60 : U32), "Medium", "Hard"))))

def technique_name(tech: U32) -> String:
  match tech:
    case 0:
      "None"
    case 1:
      "NakedSingle"
    case 2:
      "HiddenSingle"
    case 3:
      "LockedCandidates"
    case _:
      "NakedPair"

def status_name(status: U32) -> String:
  match status:
    case 0:
      "ok"
    case 1:
      "guess"
    case 2:
      "contradiction"
    case _:
      "fuel"

def line(result: RateResult) -> String:
  match result:
    case Rated{+status, tech, steps, +score}:
      "label:" ++ label(status, score) ++ " tech:" ++ technique_name(tech) ++ " steps:" ++ U32.show(steps) ++ " score:" ++ U32.show(score) ++ " status:" ++ status_name(status)
