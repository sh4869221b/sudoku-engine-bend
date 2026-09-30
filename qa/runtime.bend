import Base

def main() -> IO(Unit):
  do IO<Unit>:
    count : U32 <- IO.thread_count()
    IO.print("runtime_threads=" ++ U32.show(count))
