import os
from pathlib import Path
import sys
import unittest
from unittest.mock import patch

if __package__:
    from .runtime_args import native_command
else:
    sys.path.insert(0, str(Path(__file__).resolve().parent))
    from runtime_args import native_command


class RuntimeArguments(unittest.TestCase):
    def test_current_runtime_preserves_application_arguments(self):
        args = ['batch', 'file with spaces', 'count', '--threads', 'literal']
        with patch.dict(os.environ, {}, clear=True):
            self.assertEqual(native_command('./engine', 8, args),
                             [str(Path('engine').resolve()), '+RTS', '--threads',
                              '8', '-RTS', *args])

    def test_only_explicit_baseline_uses_old_runtime(self):
        with patch.dict(os.environ, {'BEND_LEGACY_BINARY': './old'}):
            self.assertEqual(native_command('./old', 16, ['count', 'puzzle']),
                             [str(Path('old').resolve()), '--threads', '16', '--',
                              'count', 'puzzle'])
            self.assertIn('+RTS', native_command('./new', 16, []))


if __name__ == '__main__':
    unittest.main()
