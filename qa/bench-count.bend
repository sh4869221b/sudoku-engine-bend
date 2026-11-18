import Base
import ../sudoku/batch.bend as Batch
import ../sudoku/bench.bend as Bench

# Inject one valid puzzle into the generated benchmark path for a 10,000-job request.
def main() -> IO(Unit):
  Bench.generated(10000, Some{[Batch.Job{1, "534678912672195348198342567859761423426853791713924856961537284287419635345286179"}]})
