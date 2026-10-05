import Base
import ./rating-fused.bend as F
import ./rating-listfree.bend as L
import ./rating-combine.bend as C

def main() -> IO(Unit):
  do IO<Unit>:
    F.main()
    L.main()
    C.main()
