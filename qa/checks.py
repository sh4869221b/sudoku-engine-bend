"""Checks for executable QA scripts, including under Python optimization."""


def require(condition, detail):
    if not condition:
        raise AssertionError(detail)
