import Base
import ../main.bend as App
import ../sudoku/commands.bend as C
import ../sudoku/generator.bend as G

def run(mode: U32) -> IO(Unit):
  match mode:
    case 5:
      do IO<Unit>:
        IO.print("534678912672195348198342567859761423426853791713924856961537284287419635345286179")
        App.generate_one(2, 43, 32, False{}, G.DigFuel{})
        IO.print("unreachable")
    case _:
      App.reply(C.eval(mode, False{}, 0n, 0n, "530070000600195000098000060800060003400803001700020006060000280000419005000080079"))

def args(xs: List<String>) -> IO(Unit):
  match xs:
    case program <> +name <> Nil{}:
      run(Bool.pick(U32, String.eq(name, "generate"), 5, C.mode(name)))
    case _:
      IO.die(Unit, 1, "test mode required")

def main() -> IO(Unit):
  do IO<Unit>:
    xs : List<String> <- IO.args()
    args(xs)
