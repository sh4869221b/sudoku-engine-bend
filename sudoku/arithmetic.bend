import Base

# Nat constant division avoids the U32 quotient workaround emitted by Bend
# 2.0.34. Conversion is exact for every U32, not only legal cell positions.
def div3(x: U32) -> U32:
  U32.from_nat(Nat.div(U32.to_nat(x), 3n))

def div9(x: U32) -> U32:
  U32.from_nat(Nat.div(U32.to_nat(x), 9n))

def div27(x: U32) -> U32:
  U32.from_nat(Nat.div(U32.to_nat(x), 27n))

def rem3(+x: U32) -> U32:
  (x - div3(x) * 3 : U32)

def rem9(+x: U32) -> U32:
  (x - div9(x) * 9 : U32)

def rem27(+x: U32) -> U32:
  (x - div27(x) * 27 : U32)
