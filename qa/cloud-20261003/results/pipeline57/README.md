# Trial57: bounded input-to-output batch pipeline

Rejected. Fixed1024 accepted jobs perchunk was chosen before timing and never retuned.

The accepted e62c7e2 source is changed only in main.bend's batch call and new helper definitions appended to sudoku/batch.bend. File.read and all up-front16MiB/read errors remain unchanged. The original text_jobs and write implementations remain available, and BENCH uses its original path. Structural recursion consumes the remaining String tail; at1024 accepted jobs an affine continuation flushes the original balanced solver tree and ordered output writer, then resumes. Physical line indices and one-trailing-CR normalization are unchanged.

Build: ALL PROOFS CHECK. Differential checks:288 explicit chunk-boundary comparisons,129 file comparisons, and1931 complete CLI comparisons all PASS. Boundary sizes0/1/1023/1024/1025/2047/2048/2049 cover four batch modes at1/8/16threads, comments/empty lines, no-final-LF/final-LF/mixed-CRLF, malformed input, Unicode, NUL, and physical indices. The broader129-file test also covers invalid bytes.

Screen: fixed7cases,9pairs each, plus2warmups, aggregate1.034098x (95%paired bootstrap CI1.008340–1.056530).

Confirmation: all35frozen cases,21pairs each, plus2warmups, aggregate0.984249x (95%paired bootstrap CI0.968292–1.001444). Easy10000 batch solve:1thread1.079526x,8threads0.933378x,16threads0.868577x. The positive single-thread result does not survive the whole suite. No cases or observations were excluded.

No engine-memory reduction is claimed. Screen wait4 RSS was preliminary; this can inherit Python's pre-exec high-water mark. The tiny C-launcher memory pass was not run for the rejected candidate. Full proof/lane/fuel aggregate gates were not run after rejection; do not substitute the build check/differentials for that suite.

Reproduction: use the original pinned toolchain via BEND_TOOLCHAIN_DIR, build.sh, then the three run_*.sh scripts. Hold exclusive flock -x /tmp/bend-cloud-cpu.lock around every build/test/measurement script. Binary paths are relative to this worktree; original corpora remain at ../bend-transfer/cloud-handoff-20261003/corpora. Scripts retain all raw outputs/samples. The initial syntax error is preserved in build-01-syntax.log. No FFI, runtime, flags, fuel, search order, source corpus or external publication was changed.
