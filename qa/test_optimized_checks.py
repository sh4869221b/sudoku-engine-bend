"""The executable QA gate must reject bad results under PYTHONOPTIMIZE."""
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

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
