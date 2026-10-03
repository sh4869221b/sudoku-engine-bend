import Base

def next(+seed: U32) -> U32:
  +a = U32.xor(seed, U32.shln(seed, 13n))
  +b = U32.xor(a, U32.shrn(a, 17n))
  U32.xor(b, U32.shln(b, 5n))

