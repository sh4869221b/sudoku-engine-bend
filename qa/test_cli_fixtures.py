"""CLI gate setup must preserve the reviewed source fixtures."""
import pathlib
import runpy
import shutil
import tempfile
import unittest
from unittest import mock


ROOT = pathlib.Path(__file__).resolve().parents[1]


class FixturePreservationTest(unittest.TestCase):
    def test_cli_setup_does_not_replace_fixture_edits(self):
        with tempfile.TemporaryDirectory() as td:
            root = pathlib.Path(td)
            (root / 'qa').mkdir()
            script = root / 'qa/cli.py'
            shutil.copy2(ROOT / 'qa/cli.py', script)
            shutil.copytree(ROOT / 'fixtures', root / 'fixtures')
            # A reviewed change must reach the fixture gate unchanged, even if it
            # differs from the smoke-test constants at the start of the script.
            (root / 'fixtures/easy/easy.count.expected').write_text('99\n')
            (root / 'fixtures/easy/easy.txt').write_text('0' * 81 + '\n')
            before = {p.relative_to(root): p.read_bytes()
                      for p in (root / 'fixtures').rglob('*') if p.is_file()}
            # Stop at the native process boundary: this regression needs no Bend
            # installation and does not claim to test Sudoku solver correctness.
            with mock.patch('subprocess.run', side_effect=RuntimeError('native boundary')):
                with self.assertRaisesRegex(RuntimeError, 'native boundary'):
                    runpy.run_path(str(script), run_name='__main__')
            after = {p.relative_to(root): p.read_bytes()
                     for p in (root / 'fixtures').rglob('*') if p.is_file()}
            self.assertEqual(before, after)


if __name__ == '__main__':
    unittest.main()
