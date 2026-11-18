"""Successful benchmark reports must be valid before comparison or recording."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

if __package__:
    from .checks import bench_timing, normalized_bench
else:
    sys.path.insert(0, str(Path(__file__).resolve().parent))
    from checks import bench_timing, normalized_bench


QA = Path(__file__).resolve().parent
SOLVED = '534678912672195348198342567859761423426853791713924856961537284287419635345286179'
FAKE_ENGINE = """#!/bin/sh
set -eu
shift 4
case "${1-}" in
  generate)
    if [ -n "$QA_TEST_GENERATE" ]; then cat "$QA_TEST_GENERATE"; fi
    ;;
  bench)
    n=$(wc -l < "$2")
    if [ "$n" -eq 0 ]; then n=1; fi
    total=10
    per_ms=$QA_TEST_PER_MS
    if [ "$per_ms" = valid ]; then total=0; per_ms=0; fi
    printf 'N=%s mode=cpu threads=runtime total_ms=%s per_ms=%s\\n' "$n" "$total" "$per_ms"
    printf '%s' "$QA_TEST_STDERR" >&2
    ;;
esac
"""


class BenchTimingTest(unittest.TestCase):
    def test_valid_reports_use_binary32_operands_and_division(self):
        for n, total, average in (
            (10, 0, '0'), (10, 1, '1e-1'), (3, 1, '0.33333334'),
            (10000, 1, '0.0001'), (1, 16777217, '16777216'),
        ):
            with self.subTest(n=n, total=total, average=average):
                report = f'N={n} mode=cpu threads=runtime total_ms={total} per_ms={average}\n'
                self.assertEqual(bench_timing(report, '', expected_n=n), (n, total))
                self.assertEqual(bench_timing(report.encode(), b''), (n, total))

    def test_normalization_preserves_counts_after_validating_timings(self):
        prefix = b'N=10 mode=cpu threads=runtime '
        first, time1 = normalized_bench(prefix + b'total_ms=1 per_ms=0.1\n', b'')
        second, time2 = normalized_bench(prefix + b'total_ms=2 per_ms=0.2\n', b'')
        self.assertEqual(first, second)
        self.assertEqual((time1, time2), (1, 2))
        with self.assertRaisesRegex(AssertionError, 'job count'):
            normalized_bench(prefix + b'total_ms=2 per_ms=0.2\n', b'', expected_n=11)

    def test_zero_and_out_of_range_times(self):
        for total, average in ((0, '1e-999'), (1, '1e39'), (1, '0'), (1, '1e999')):
            with self.subTest(total=total, average=average), self.assertRaises(AssertionError):
                bench_timing(f'N=1 mode=cpu threads=runtime total_ms={total} per_ms={average}\n', '')

    def test_explicit_thread_count_must_match_when_using_numbered_reports(self):
        report = 'N=1000 mode=cpu threads=8 total_ms=1 per_ms=0.001000\n'
        self.assertEqual(bench_timing(report, '', threads=8), (1000, 1))
        with self.assertRaisesRegex(AssertionError, 'unexpected bench threads'):
            bench_timing(report, '', threads=1)

    def test_entrypoints_reject_invalid_benchmark_reports_before_publishing(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            (root / 'bin').mkdir()
            (root / 'qa').mkdir()
            evidence = root / '.omo/evidence'
            evidence.mkdir(parents=True)
            for path in ('qa/benchmark.py', 'qa/checks.py', 'toolchain.lock.json'):
                shutil.copyfile(QA.parent / path, root / path)
            fake = root / 'bin/bend-sudoku'
            fake.write_text(FAKE_ENGINE)
            fake.chmod(0o700)
            for name in ('verification.txt', 'rate-300.txt', 'hard-100.txt'):
                (root / name).touch()
            corpus = root / 'mixed-1000.txt'
            corpus.write_text((SOLVED + '\n') * 257)
            generated = root / 'generated.txt'
            generated.write_text((SOLVED + '\n') * 10000)
            cases = root / 'cases.json'
            cases.write_text(json.dumps([{'name': 'bench', 'args': ['bench', str(corpus)]}]))
            pair = ['--base', str(fake), '--candidate', str(fake)]
            output = root / 'comparison.json'
            out = ['--out', str(output)]
            commands = (
                (root / 'qa/benchmark.py', [], evidence / 'benchmark.json', str(generated)),
                (QA / 'compiler-20261004/scheduling.py', [*pair, '--corpora', td, *out], output, ''),
                (QA / 'perf-20261001/differential.py',
                 [*pair, '--repo', str(QA.parent), '--corpora', td, *out], output, ''),
                (QA / 'perf-20261001/measure.py', [*pair, '--cases', str(cases), *out], output, ''),
            )
            for script, args, report, generate in commands:
                for average, stderr, reason in (
                    ('--', '', 'unexpected bench output'),
                    ('7', '', 'per_ms does not match total_ms / N'),
                    ('valid', 'noise\n', 'unexpected stderr from bench'),
                ):
                    with self.subTest(script=script.name, average=average, stderr=stderr):
                        env = dict(os.environ, PYTHONSAFEPATH='1', QA_TEST_PER_MS=average,
                                   QA_TEST_STDERR=stderr, QA_TEST_GENERATE=generate)
                        env.pop('BEND_LEGACY_BINARY', None)
                        result = subprocess.run(
                            [sys.executable, '-I', '-OO', str(script), *args],
                            cwd=root, env=env, capture_output=True, text=True, timeout=30)
                        self.assertNotEqual(result.returncode, 0, result.stdout)
                        self.assertIn(reason, result.stderr)
                        self.assertFalse(report.exists())
                        self.assertFalse(Path(str(report) + '.raw.json.gz').exists())


if __name__ == '__main__':
    unittest.main()
