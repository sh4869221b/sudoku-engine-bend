"""Checks for executable QA scripts, including under Python optimization."""

import math
import re
import struct


DECIMAL = r'\+?(?:[0-9]+(?:\.[0-9]*)?|\.[0-9]+)(?:[eE][+-]?[0-9]+)?'
BENCH_LINE = re.compile(
    rf'N=([1-9][0-9]*) mode=cpu threads=(runtime|[0-9]+) '
    rf'total_ms=([0-9]+) per_ms=({DECIMAL})\n'
)


def require(condition, detail):
    if not condition:
        raise AssertionError(detail)


def binary32(value):
    return struct.unpack('>f', struct.pack('>f', value))[0]


def bench_timing(stdout, stderr, *, expected_n=None, threads=None):
    """Validate a successful report and return the job count and total milliseconds."""
    require(not stderr, ('unexpected stderr from bench', stderr))
    line = stdout.decode('ascii', errors='replace') if isinstance(stdout, bytes) else stdout
    match = BENCH_LINE.fullmatch(line)
    require(match is not None, ('unexpected bench output', stdout))
    n, reported_threads, total, per_ms = match.groups()
    n, total = int(n), int(total)
    require(n <= 0xFFFFFFFF and (expected_n is None or n == expected_n),
            ('unexpected bench job count', n, expected_n))
    require(reported_threads == 'runtime' or reported_threads == str(threads),
            ('unexpected bench threads', reported_threads, threads))
    per_value = float(per_ms)
    require(math.isfinite(per_value), ('invalid per_ms', per_ms))

    # Bend prints a decimal that round-trips to the F32 division result.
    # Both operands are rounded to F32 before the division.
    try:
        expected = binary32(binary32(total) / binary32(n))
        actual = binary32(per_value)
    except (OverflowError, struct.error) as exc:
        raise AssertionError(('bench timing outside F32 range', total, per_ms)) from exc
    if total == 0:
        mantissa = re.split('[eE]', per_ms, maxsplit=1)[0]
        require(not any(c in '123456789' for c in mantissa), ('per_ms must be zero', per_ms))
    require(math.isfinite(expected) and actual == expected,
            ('per_ms does not match total_ms / N', per_ms, total, n))
    return n, total


def normalized_bench(stdout, stderr, *, expected_n=None):
    """Return a validated comparison key and the measured total."""
    n, total = bench_timing(stdout, stderr, expected_n=expected_n)
    key = f'N={n} mode=cpu threads=runtime total_ms=<time> per_ms=<time>\n'
    return key.encode('ascii'), total
