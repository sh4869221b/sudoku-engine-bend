"""The executable QA gate must reject bad results under PYTHONOPTIMIZE."""
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

if __package__:
    from . import lanes
else:
    import lanes

QA = Path(__file__).resolve().parent
RUN_GATE = """
import runpy
import subprocess
import sys
from unittest.mock import patch

gate, code, stdout = sys.argv[1:]
result = subprocess.CompletedProcess([], int(code), stdout, '')
with patch('subprocess.run', return_value=result):
    runpy.run_path(gate, run_name='__main__')
"""


class OptimizedChecks(unittest.TestCase):
    def test_bad_cli_results_cannot_record_pass(self):
        for code, stdout, reason in ((0, 'wrong output\n', 'unexpected stdout'),
                                     (7, '', 'unexpected exit code')):
            with self.subTest(code=code), tempfile.TemporaryDirectory() as td:
                root = Path(td)
                qa = root / 'qa'
                qa.mkdir()
                for name in ('lanes.py', 'checks.py'):
                    shutil.copyfile(QA / name, qa / name)
                evidence = root / '.omo/evidence'
                evidence.mkdir(parents=True)
                result = subprocess.run(
                    [sys.executable, '-c', RUN_GATE, str(qa / 'lanes.py'), str(code), stdout],
                    cwd=qa, env=dict(os.environ, PYTHONOPTIMIZE='1'),
                    capture_output=True, text=True, timeout=30)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn(reason, result.stderr)
                self.assertNotIn('PASS', result.stdout)
                self.assertFalse((evidence / 'lanes.json').exists())

    def test_differentials_reject_mismatched_binaries_under_optimization(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            row = lanes.SOLVED + '\n'
            for name in ('verification.txt', 'rate-300.txt', 'hard-100.txt', 'mixed-1000.txt'):
                (root / name).write_text(row * 257)
            cases = (
                ('deadline-20261003/file_differential.py', [], 'file differential mismatch'),
                ('perf-20261001/differential.py',
                 ['--repo', str(QA.parent), '--corpora', td], 'CLI differential mismatch'),
                ('compiler-20261004/scheduling.py', ['--corpora', td], 'scheduler comparison mismatch'),
            )
            for level in ('1', '2'):
                for script, extra, reason in cases:
                    with self.subTest(level=level, script=script):
                        output = root / f'report-{Path(script).stem}-{level}.json'
                        result = subprocess.run(
                            [sys.executable, str(QA / script), '--base', '/bin/true',
                             '--candidate', '/bin/false', '--out', str(output), *extra],
                            cwd=root, env=dict(os.environ, PYTHONOPTIMIZE=level),
                            capture_output=True, text=True, timeout=30)
                        self.assertNotEqual(result.returncode, 0)
                        self.assertIn(reason, result.stderr)
                        self.assertNotIn('PASS', result.stdout)
                        self.assertFalse(output.exists())
                        self.assertFalse(Path(str(output) + '.raw.json.gz').exists())

    def test_count_table_runs_as_script_and_module_in_an_isolated_tree(self):
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            (root / 'qa').mkdir()
            (root / 'sudoku').mkdir()
            for path in ('qa/checks.py', 'qa/generate_count_table.py', 'sudoku/candidates.bend'):
                shutil.copyfile(QA.parent / path, root / path)
            env = dict(os.environ, PYTHONOPTIMIZE='2')
            env.pop('PYTHONPATH', None)
            for entry in (['qa/generate_count_table.py'], ['-m', 'qa.generate_count_table']):
                with self.subTest(entry=entry):
                    result = subprocess.run([sys.executable, *entry, '--check'], cwd=root,
                                            env=env, capture_output=True, text=True, timeout=30)
                    self.assertEqual(result.returncode, 0, result.stderr)
                    self.assertIn('PASS all1024', result.stdout)
                    self.assertEqual(result.stderr, '')

    def test_large_bench_output_must_have_finite_nonnegative_timing_and_empty_stderr(self):
        for value, stderr, reason in (
            ('--', '', 'unexpected bench output'),
            ('1e999', '', 'invalid per_ms'),
            ('-1', '', 'unexpected bench output'),
            ('-1e-999', '', 'unexpected bench output'),
            ('0', 'unexpected noise\n', 'unexpected stderr'),
        ):
            with self.subTest(value=value, stderr=stderr):
                text = f'N=10000 mode=cpu threads=runtime total_ms=1 per_ms={value}\n'
                result = subprocess.CompletedProcess([], 0, text, stderr)
                checks = []
                with patch.object(lanes.subprocess, 'run', return_value=result):
                    with self.assertRaisesRegex(AssertionError, reason):
                        lanes.run_case(checks, 'js', ['node'], ['bench', '--generate', '10000'],
                                       bench_n=10000)
                self.assertEqual(checks, [])
