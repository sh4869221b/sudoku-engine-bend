# Diagnostic measurements (not release acceptance)

All five trials used the same immutable baseline, corpus and seven screening
cases. Screens retained two warmup pairs per case, 15 measured pairs for the
first four trials and 21 for the scalar-counter trial. Executions were serial
and their order randomized per pair. 95% intervals use the existing 5,000
paired bootstrap implementation. These GCC measurements do not establish a
speedup: every aggregate interval includes 1. They are not interchangeable with
the locked Clang measurements from GitHub Actions.

| Trial | Sum-of-medians ratio | 95% paired interval | Diagnostic verdict |
|---|---:|---:|---|
| Fresh urgency flags | 1.0296x | 0.9617–1.0715 | Inconclusive |
| Combined missing/hidden scan | 1.0216x | 0.9641–1.0641 | Inconclusive |
| Row-local parser | 1.0301x | 0.9696–1.0955 | Inconclusive |
| Row/column-local parser | 0.9909x | 0.9367–1.0230 | Inconclusive |
| Scalar missing-support counter | 0.9889x | 0.9398–1.0300 | Inconclusive |

The scalar-counter trial's rate-300 target is 233.116 ms versus 232.085 ms
(1.0044x). This does not justify its larger state/update refactor, so that trial
is not part of the production proposal. The original row-only parser and the
row/column parser are distinct trials. All local evidence is retained including
non-improvements; none of these local ratios is advertised as an accepted win.

The encode/rating combination's 1,931 exact CLI comparisons cover 347 distinct
puzzles, all seven commands, seeds and invalid input boundaries, ordered batches
at 1/8/16 threads, independent solved-grid checks and the independent rating
oracle. This result predates parser integration and must not be attributed to
the final combined source. Dedicated parser and encode tests compare every128
word; rating tests compare support values, action order and fuel transitions.
GCC QA used larger stack limits as recorded in metadata.json. Lean verdict,
standard compiler flags and the complete supported backend lanes require the
separate locked verification.
