> 公開版では追加raw観測・候補dumpを除外しています。完全な証拠と過去履歴は納品済みアーカイブに保持されています。 [公開範囲](../cloud-20261003/PUBLICATION.md)を参照。

# Structural performance protocol

Compare to original343bf98 and its ../baseline binary, not to the previous
experiment branch. Reuse all35 fixed cases and the same corpora/checksums,
Bend2.0.34/Clang19.1.7/Lean4.34.1 and build.sh. Primary metric remains ratio of
sum of all35 wall-time medians. No case removal, output workload reduction,
compile flags, enlarged fuel or runtime modifications.
Screens: fixed seven substantial cases, two warmups and nine paired serial
samples. Confirm meaningful candidates on35 cases with21 samples and paired
bootstrap. Report internal BENCH separately. Retain only reproducible gains
beyond noise with independent correctness/contract matrix passing and regression
review. Earlier ten micro experiments do not count toward this phase.
Aim for cumulative5x or ten new distinct implemented+validated structural ideas;
failed builds and parameter tweaks do not add to the count. Save every candidate
patch, correctness result, raw measurements, adoption/rejection and combined
speedup. Check final suite and remeasure combined implementation.

Incremental screens compare each new idea with the current accepted binary,
so earlier accepted gains cannot justify a ineffective subsequent change.
Cumulative confirmations and final measurement always use original343bf98.
