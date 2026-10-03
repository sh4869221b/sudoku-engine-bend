> 公開版では追加raw観測・候補dumpを除外しています。完全な証拠と過去履歴は納品済みアーカイブに保持されています。 [公開範囲](../cloud-20261003/PUBLICATION.md)を参照。

# Protocol locked before baseline timing

Baseline: 343bf98cd6d2b128882bc4dcd8300df0cd2b55c6. Host: cachyos-x8664.
Both binaries: checksum-locked Bend 2.0.34, Lean 4.34.1, Clang 19.1.7,
unchanged build.sh and output contracts. Runtime packages only added locally to
satisfy the pinned Clang's Debian shared-library dependencies on CachyOS.

Primary final metric: sum of wall-time medians for every one of the 35 frozen
qa/perf-20261001/cases.json cases; speedup = baseline sum / final sum. This is
one fixed workload suite, including all seven commands and 1/8/16 threads.
No cases may be removed from final evaluation. Report per-case quartiles,
raw timings and output hashes; BENCH internal time is secondary only.

Screening: the same suite's seven substantial single-thread workloads
(generate100, easy10000 solve, mixed1000 solve, hard100 count, rate300,
easy10000 bench, mixed1000 bench). Two warmups and nine serial randomized
paired repetitions. Confirmation uses all 35 cases and 21 repetitions.
A change must preserve exact exit/stdout/stderr (except BENCH timing), search
fuel/state semantics, laws, and independent solution/rating oracles. Adoption
requires reproducible improvement: screen >=3% suite improvement and >=5% on
an affected substantial workload; confirmation >=3% primary improvement, a
paired bootstrap 95% lower speedup bound above 1, and no reproducible >5%
regression on a substantial workload. Startup-scale cases are reported but not
used alone to claim a regression or speedup. Repeat if noise prevents a decision.

Stop only at verified >=5x primary cumulative improvement or ten distinct
implemented and validated ideas, including rejected ideas. Build/test failures
are reported separately; a failed build does not count as an implemented trial.
Final full verify.sh and fixed-suite remeasurement compare the accepted combined
change to the original baseline. No remote push or merge.
