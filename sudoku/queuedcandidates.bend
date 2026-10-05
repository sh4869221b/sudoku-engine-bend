import Base
import ./candidates.bend as C
import ./board.bend as B
import ./arithmetic.bend as M

# The count-table path is valid for every low-ten-bit candidate mask. Preserve
# the previous full-U32 predicate outside that bounded domain.
def counted_single(+mask: U32, upper: U32) -> Bool:
  match upper:
    case 0:
      (C.mask_count(mask) <= 1 : U32)
    case _:
      U32.is_eq(U32.and(mask, (mask - 1 : U32)), 0)

def zero_or_single(+mask: U32) -> Bool:
  counted_single(mask, U32.shrn(mask, 10n))

# Active search words hold a candidate mask or a fixed digit shifted by ten.
# Padding words109..111 flag the first zero/singleton in physical cell order.
def flagged(+pos: U32, +value: Bool, r: Array<U32> & U32) -> Array<U32>:
  (b, +flags) = r
  +slot = (109 + U32.shrn(pos, 5n) : U32)
  +bit = U32.shln(1, U32.to_nat(U32.and(pos, 31)))
  Array.set(U32, b, slot, Bool.pick(U32, value, U32.or(flags, bit), U32.and(flags, U32.not(bit))))

def flag(b: Array<U32>, +pos: U32, +value: Bool) -> Array<U32>:
  flagged(pos, value, Array.get(U32, b, (109 + U32.shrn(pos, 5n) : U32)))

def encoded_mask(+pos: U32, r: Array<U32> & U32) -> Array<U32>:
  (b, +mask) = r
  flag(Array.set(U32, b, pos, mask), pos, zero_or_single(mask))

def encoded(+pos: U32, r: Array<U32> & U32) -> Array<U32>:
  (b, digit) = r
  match digit:
    case 0:
      encoded_mask(pos, C.cached_at(b, pos))
    case d:
      Array.set(U32, b, pos, U32.shln(d, 10n))

def encode_go(+n: Nat, +pos: U32, b: Array<U32>) -> Array<U32>:
  match n:
    case 0n:
      b
    case 1n+k:
      encode_go(k, (pos + 1 : U32), encoded(pos, Array.get(U32, b, pos)))

# Full encoding starts with zero flags and visits each cell exactly once.
# A nonurgent cell therefore needs no read or write of its flag word. Keep
# encoded/encode_go unchanged for callers that supply existing flag words.
def encode_fresh_flag(+urgent: Bool, b: Array<U32>, +pos: U32) -> Array<U32>:
  match urgent:
    case True{}:
      flag(b, pos, True{})
    case False{}:
      b

def encode_fresh_mask(+pos: U32, r: Array<U32> & U32) -> Array<U32>:
  (b, +mask) = r
  encode_fresh_flag(zero_or_single(mask), Array.set(U32, b, pos, mask), pos)

def encode_fresh_cell(+pos: U32, r: Array<U32> & U32) -> Array<U32>:
  (b, digit) = r
  match digit:
    case 0:
      encode_fresh_mask(pos, C.cached_at(b, pos))
    case d:
      Array.set(U32, b, pos, U32.shln(d, 10n))

def encode_fresh_go(+n: Nat, +pos: U32, b: Array<U32>) -> Array<U32>:
  match n:
    case 0n:
      b
    case 1n+k:
      encode_fresh_go(k, (pos + 1 : U32), encode_fresh_cell(pos, Array.get(U32, b, pos)))

def encode(b: Array<U32>) -> Array<U32>:
  encode_fresh_go(81n, 0, Array.set(U32, Array.set(U32, Array.set(U32, b, 109, 0), 110, 0), 111, 0))

def decoded(+pos: U32, r: Array<U32> & U32) -> Array<U32>:
  (b, word) = r
  Array.set(U32, b, pos, U32.shrn(word, 10n))

def decode(+n: Nat, +pos: U32, b: Array<U32>) -> Array<U32>:
  match n:
    case 0n:
      b
    case 1n+k:
      decode(k, (pos + 1 : U32), decoded(pos, Array.get(U32, b, pos)))

def advance(+open: Bool, +pos: U32, +bestpos: U32, +bestmask: U32, +bestsize: U32, b: Array<U32>, +word: U32) -> Array<U32> & U32 & U32 & U32:
  match open:
    case True{}:
      C.scalar_advance(pos, bestpos, bestmask, bestsize, (b, word))
    case False{}:
      (b, (bestpos, (bestmask, bestsize)))

def inspected(+pos: U32, +bestpos: U32, +bestmask: U32, +bestsize: U32, r: Array<U32> & U32) -> Array<U32> & U32 & U32 & U32:
  (b, +word) = r
  advance((word < 1024 : U32), pos, bestpos, bestmask, bestsize, b, word)

# All urgency flags are zero on entry:2 is the exact remaining size lower bound.
def scan(+n: Nat, +pos: U32, r: Array<U32> & U32 & U32 & U32) -> Array<U32> & C.Choice:
  match n r:
    case _ Tuple{b, Tuple{p, Tuple{m, 0}}}:
      (b, C.Choice{p, m, 0})
    case _ Tuple{b, Tuple{p, Tuple{m, 1}}}:
      (b, C.Choice{p, m, 1})
    case _ Tuple{b, Tuple{p, Tuple{m, 2}}}:
      (b, C.Choice{p, m, 2})
    case 0n Tuple{b, Tuple{p, Tuple{m, size}}}:
      (b, C.Choice{p, m, size})
    case 1n+k Tuple{b, Tuple{p, Tuple{m, size}}}:
      scan(k, (pos + 1 : U32), inspected(pos, p, m, size, Array.get(U32, b, pos)))

def start(r: Array<U32> & U32) -> Array<U32> & C.Choice:
  (b, +pos) = r
  scan(U32.to_nat((81 - pos : U32)), pos, (b, (81, (0, 10))))

def trailing(+index: U32) -> U32:
  match index:
    case 0:
      0
    case 1:
      1
    case 2:
      28
    case 3:
      2
    case 4:
      29
    case 5:
      14
    case 6:
      24
    case 7:
      3
    case 8:
      30
    case 9:
      22
    case 10:
      20
    case 11:
      15
    case 12:
      25
    case 13:
      17
    case 14:
      4
    case 15:
      8
    case 16:
      31
    case 17:
      27
    case 18:
      13
    case 19:
      23
    case 20:
      21
    case 21:
      19
    case 22:
      16
    case 23:
      7
    case 24:
      26
    case 25:
      12
    case 26:
      18
    case 27:
      6
    case 28:
      11
    case 29:
      5
    case 30:
      10
    case 31:
      9
    case _:
      0

def urgent(+pos: U32, r: Array<U32> & U32) -> Array<U32> & C.Choice:
  (b, +mask) = r
  (b, C.Choice{pos, mask, Bool.pick(U32, U32.is_eq(mask, 0), 0, 1)})

def flags(+n: Nat, +base: U32, r: Array<U32> & U32) -> Array<U32> & C.Choice:
  match n:
    case 0n:
      start(Array.get(U32, Pair.fst(Array<U32>, U32, r), 108))
    case 1n+k:
      (b, bits) = r
      match bits:
        case 0:
          flags(k, (base + 32 : U32), Array.get(U32, b, (110 + U32.shrn(base, 5n) : U32)))
        case +word:
          +bit = U32.and(word, (0 - word : U32))
          +pos = (base + trailing(U32.shrn((bit * 125613361 : U32), 27n)) : U32)
          urgent(pos, Array.get(U32, b, pos))

def select(b: Array<U32>) -> Array<U32> & C.Choice:
  flags(3n, 0, Array.get(U32, b, 109))

def changed_flag(+needed: Bool, b: Array<U32>, +pos: U32) -> Array<U32>:
  match needed:
    case True{}:
      flag(b, pos, True{})
    case False{}:
      b

def changed(+needed: Bool, +pos: U32, +bit: U32, b: Array<U32>, +old: U32) -> Array<U32>:
  match needed:
    case False{}:
      b
    case True{}:
      +mask = U32.and(old, U32.not(bit))
      changed_flag(U32.is_ne(U32.and(old, (old - 1 : U32)), 0) && zero_or_single(mask), Array.set(U32, b, pos, mask), pos)

def peer(+pos: U32, +bit: U32, r: Array<U32> & U32) -> Array<U32>:
  (b, +old) = r
  changed(U32.is_ne(U32.and(old, bit), 0), pos, bit, b, old)

def peer_if(+needed: Bool, b: Array<U32>, +pos: U32, +bit: U32) -> Array<U32>:
  match needed:
    case False{}:
      b
    case True{}:
      peer(pos, bit, Array.get(U32, b, pos))

# Row/column loops use their direct stride. Only four box peers remain after
# excluding both selected axes; compute those positions once per placement.
def row_line(n: Nat, +j: U32, +base: U32, +placed: U32, +bit: U32, b: Array<U32>) -> Array<U32>:
  match n:
    case 0n:
      b
    case 1n+k:
      +pos = (base + j : U32)
      row_line(k, (j + 1 : U32), base, placed, bit, peer(pos, bit, Array.get(U32, b, pos)))

def column_line(n: Nat, +j: U32, +col: U32, +placed: U32, +bit: U32, b: Array<U32>) -> Array<U32>:
  match n:
    case 0n:
      b
    case 1n+k:
      +pos = (j * 9 + col : U32)
      column_line(k, (j + 1 : U32), col, placed, bit, peer(pos, bit, Array.get(U32, b, pos)))

def box_four(+base: U32, +row1: U32, +row2: U32, +col1: U32, +col2: U32, +bit: U32, b: Array<U32>) -> Array<U32>:
  +p1 = (base + row1 * 9 + col1 : U32)
  +p2 = (base + row1 * 9 + col2 : U32)
  +p3 = (base + row2 * 9 + col1 : U32)
  +p4 = (base + row2 * 9 + col2 : U32)
  peer(p4, bit, Array.get(U32, peer(p3, bit, Array.get(U32, peer(p2, bit, Array.get(U32, peer(p1, bit, Array.get(U32, b, p1)), p2)), p3)), p4))

def clear_forced(guess: Bool, b: Array<U32>, pos: U32) -> Array<U32>:
  match guess:
    case True{}:
      b
    case False{}:
      flag(b, pos, False{})

def first_read(r: Array<U32> & U32) -> Array<U32> & Bool:
  (b, word) = r
  (b, (word < 1024 : U32))

def first_step(n: Nat, +pos: U32, r: Array<U32> & Bool) -> Array<U32>:
  match n r:
    case 0n Tuple{b, open}:
      Array.set(U32, b, 108, 81)
    case _ Tuple{b, True{}}:
      Array.set(U32, b, 108, pos)
    case 1n+k Tuple{b, False{}}:
      first_step(k, (pos + 1 : U32), first_read(Array.get(U32, b, (pos + 1 : U32))))

def refresh_needed(+needed: Bool, b: Array<U32>, +start: U32) -> Array<U32>:
  match needed:
    case False{}:
      b
    case True{}:
      first_step(U32.to_nat((81 - start : U32)), start, first_read(Array.get(U32, b, start)))

def refresh(+pos: U32, r: Array<U32> & U32) -> Array<U32>:
  (b, +start) = r
  refresh_needed(U32.is_eq(pos, start), b, start)

# Production precondition: pos0..80 and digit1..9. The fixed word digit<<10
# has no low candidate bits, so the row/column self visits below are no-ops.
def place(+guess: Bool, +pos: U32, +digit: U32, b: Array<U32>) -> Array<U32>:
  +bit = B.bit(digit)
  +row = M.div9(pos)
  +col = M.rem9(pos)
  +base = (M.div3(row) * 27 + M.div3(col) * 3 : U32)
  refresh(pos, Array.get(U32, box_four(base, M.rem3((row + 1 : U32)), M.rem3((row + 2 : U32)), M.rem3((col + 1 : U32)), M.rem3((col + 2 : U32)), bit, column_line(9n, 0, col, pos, bit, row_line(9n, 0, (row * 9 : U32), pos, bit, Array.set(U32, clear_forced(guess, b, pos), pos, U32.shln(digit, 10n))))), 108))
