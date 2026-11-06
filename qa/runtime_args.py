"""Native runtime arguments for current QA and explicit old/new comparisons."""
import os
from pathlib import Path


def native_command(binary, threads, args):
    """Only the exact BEND_LEGACY_BINARY path uses the pre-2.0.38 ABI.

    No probing process runs in the timing window. Unset BENDRTS for comparisons
    so inherited runtime defaults cannot change the declared thread count.
    """
    binary = str(Path(binary).resolve())
    legacy = os.environ.get('BEND_LEGACY_BINARY')
    if legacy and Path(legacy).resolve() == Path(binary):
        return [binary, '--threads', str(threads), '--', *args]
    return [binary, '+RTS', '--threads', str(threads), '-RTS', *args]
