> 公開版では追加raw観測・候補dumpを除外しています。完全な証拠と過去履歴は納品済みアーカイブに保持されています。 [公開範囲](PUBLICATION.md)を参照。

# Dot cloud continuation, 2026-10-03

Source transfer archive SHA256:6185408f315912524c43d00c5fa5ee072cb52912538ea92fc0cc567a3f050b1e.
Restored complete Git bundle head2541ccac10680e1c200c81eabc9390fc215a480c; production accepted34 at90df642cd8b30ac40fd2dfacd57336638540ce84. Immutable originalbaseline343bf98cd6d2b128882bc4dcd8300df0cd2b55c6.

All engine binaries used for correctness/adoption/performance comparisons are built locally using unchanged lock: Bend2.0.34, Clang19.1.7, Lean4.34.1, default compiler flags. Host AMD EPYC9V74, nine visible CPUs; timings must not be mixed with Ryzen main-PC observations.

35 original cases and original corpus are unchanged. Each ordinary confirmation uses21 serial randomized paired observations plus2warmups percase, with existing5000paired bootstrap. Initialcloud comparison is3.3472026x, CI[3.2952767,3.3821088],1931CLI comparisons PASS. Each experiment is screened against immutable cloud-accepted34 or an explicitly recorded lateraccepted binary. All data and failed experiments are retained. Source patches/correctness claims are distinct from performance adoption.

Since15:38UTC, all shared-host CPU-heavy commands (compilation, tests and timing) are serialized under exclusive flock /tmp/bend-cloud-cpu.lock. Independent source inspection/editing is permitted concurrently; no CPU-heavy work overlaps timing.

Only meaningful verified improvements are adopted; an interval containing1 does not establish a win. Keep exact first zero/singleton physical-order selection then MRV, ascending digits, seeds and actual fuel operations; no hidden-single search shortcuts, answer caching, compiler/runtime modification or corpus narrowing.

Continue investigation until2026-10-03 19:00UTC (2026-10-04 04:00JST), even if5x is reached. Reserve18:30UTC onward for final aggregate checks. Final timing retains the predeclared two independent full35-case blocks,21pairs each, pooling all42observations percase; neitherblock is discarded. Complete all builds/correctness checks before timing. No remote push or merge.

A separate diagnostic-only generated-C build used -pg to sample30 easy10000 single-thread runs. Its executable is named profile-only and excluded from every correctness/adoption/timing comparison and delivery bundle. The diagnostic profile is used only to prioritize source investigations; production runtime/compiler settings remain unchanged.

Final secondary precision check declared17:39UTC:300 paired observations plus2warmups for each unchanged hard100-count case at1/8/16threads, directly against accepted52. This quantifies the targeted parallel tradeoff; it does not replace, narrow or contribute to the primary35-case score. Every observation is retained regardless of outcome. It runs after correctness/RSS checks and before the two original/final primary blocks, all under the same CPU lock.

Final pooled metadata warmups=2 refers to each block:four warmup pairs total per case across the two blocks. The secondary intervals are individual per-case95% intervals, not simultaneous family-wise intervals. Validation PASS does not mean the5x performance target was reached.
