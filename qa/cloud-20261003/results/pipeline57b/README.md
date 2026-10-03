# Trial57b: bounded4096-job batch pipeline

Rejected: full35case confirmation confidence interval includes1. This is the sole predeclared chunk-size variant after trial57 showed a persistent single-thread gain but repeated parallel-wave regressions. The4096 bound reduces10chunks to3for the10000job corpus; it was fixed before all57b timing. No size grid or further tuning was performed.

Source differs from57 only by the fixed chunk bound1024→4096 and its comment. All whole-file reading,16MiB up-front errors, structural recursion, line semantics, original balanced solver tree, ordered leaf IO and original parser/write oracles are retained. BENCH is unchanged. Both trials start at accepted e62c7e2.

Build: ALL PROOFS CHECK. Exact differential checks:396 explicit boundary comparisons,129 file comparisons and1931 complete CLI comparisons PASS. Sizes0/1/1023/1024/1025/4095/4096/4097/8191/8192/8193 cover4batch modes at1/8/16threads, physical indices, LF/CRLF/EOF, empty/comment skips, one-CR normalization, malformed inputs, Unicode and NUL. The129-file test also includes invalid bytes.

Screen7cases×9pairs:1.031726x,95%paired bootstrap CI1.005830–1.046299. Confirmation35cases×21pairs:1.013564x,95%CI0.998804–1.029906. Both include2warmups percase and preserve every observation. Easy10000 solve ratios:1thread1.052320x,8threads1.002562x,16threads0.986101x. The4096variant largely removes57's parallel-wave regression, but does not establish a whole-suite gain.

No engine-memory reduction is claimed; Python-launcher RSS can inherit its pre-exec high-water mark. No C-launcher memory measurement or full proof/lane/fuel aggregate gates were run after rejection. Build checking and differential suites are not substitutes for the unrun aggregate gates.

Reproduce with the pinned toolchain and build.sh followed by run_correctness.sh, run_screen.sh and run_confirm.sh; hold exclusive flock -x /tmp/bend-cloud-cpu.lock around each complete build/test/measurement script. Binaries/corpora are sibling paths recorded in the scripts. Source patch, initial design, source hashes, output logs, raw differential results and all raw timing observations are retained. Main production source is unchanged; no push/merge.
