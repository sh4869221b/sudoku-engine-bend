#!/usr/bin/env python3
"""Independent, deterministic Sudoku QA; never reads performance cases/corpora.

Example (all CPU work must share the benchmark host's exclusive lock):
  flock -x /tmp/bend-cloud-cpu.lock python3 qa/cloud-20261003/randomized_correctness.py \
    --lock-held --base ../cloud-baseline --candidate ../cloud-accepted54 \
    --out qa/cloud-20261003/results/randomized-accepted54.json

Rerun the identical archived inputs with --cases <previous>.cases.json.
Without --lock-held this script acquires the same advisory lock itself.
No production module, reference solver, performance input, or package is imported.
"""

import sys
from pathlib import Path as _Path
sys.path.insert(0, str(_Path(__file__).resolve().parents[1]))
from runtime_args import native_command

import argparse
import base64
from collections import Counter
import fcntl
import gzip
import hashlib
import json
from pathlib import Path
import random
import subprocess
import sys
import time


SEED = 0x20261003D1FF
CLUE_COUNTS = [0, 1, 4, 8, 12, 16, 20, 24, 28, 32, 40, 48, 60, 72, 80, 81]
REPEATS = 48
MODES = ("solve", "count", "check")
DIGITS = set("123456789")
LOCK = "/tmp/bend-cloud-cpu.lock"


def sha(data):
    return hashlib.sha256(data).hexdigest()


def canonical_json(value):
    return json.dumps(value, ensure_ascii=True, sort_keys=True, separators=(",", ":")).encode()


def write_json(path, value):
    path.write_text(json.dumps(value, ensure_ascii=True, indent=2) + "\n")


def unit_strings(board):
    for row in range(9):
        yield board[row * 9:row * 9 + 9]
    for col in range(9):
        yield board[col::9]
    for row in (0, 3, 6):
        for col in (0, 3, 6):
            yield "".join(board[(row + dr) * 9 + col + dc] for dr in range(3) for dc in range(3))


def input_status(puzzle):
    if len(puzzle) != 81 or not set(puzzle) <= (DIGITS | set("0.")):
        return "malformed"
    for unit in unit_strings(puzzle):
        clues = [d for d in unit if d in DIGITS]
        if len(clues) != len(set(clues)):
            return "duplicate"
    return "valid"


def valid_solution(puzzle, solution):
    return (len(solution) == 81 and set(solution) == DIGITS
            and all(p in "0." or p == s for p, s in zip(puzzle, solution))
            and all(set(unit) == DIGITS for unit in unit_strings(solution)))


def transform(board, rng):
    digits = list("123456789")
    rng.shuffle(digits)
    bands, stacks = list(range(3)), list(range(3))
    rng.shuffle(bands)
    rng.shuffle(stacks)
    rows, cols = [], []
    for band in bands:
        offsets = list(range(3))
        rng.shuffle(offsets)
        rows.extend(band * 3 + x for x in offsets)
    for stack in stacks:
        offsets = list(range(3))
        rng.shuffle(offsets)
        cols.extend(stack * 3 + x for x in offsets)
    transpose = bool(rng.getrandbits(1))
    out = []
    for row in rows:
        for col in cols:
            value = board[col * 9 + row] if transpose else board[row * 9 + col]
            out.append(digits[int(value) - 1] if value in DIGITS else value)
    return "".join(out)


def generate_cases():
    rng = random.Random(SEED)
    canonical = "".join(str((row * 3 + row // 3 + col) % 9 + 1)
                        for row in range(9) for col in range(9))
    cases, completed = [], set()
    for repeat in range(REPEATS):
        for clues in CLUE_COUNTS:
            full = transform(canonical, rng)
            # Uniqueness here concerns completed grids only; no puzzle is rejected
            # based on a solver, oracle, benchmark, difficulty, or timing result.
            while full in completed:
                full = transform(canonical, rng)
            completed.add(full)
            keep = set(rng.sample(range(81), clues))
            blank_style = (repeat + clues) % 3
            puzzle = "".join(full[i] if i in keep else
                             ("0" if blank_style == 0 else "." if blank_style == 1
                              else rng.choice("0.")) for i in range(81))
            assert valid_solution(puzzle, full)
            cases.append(dict(id=f"valid-{repeat:02d}-{clues:02d}", kind="valid",
                              clues=clues, puzzle=puzzle, completed_grid=full,
                              completed_grid_sha256=sha(full.encode())))
    # Two-clue cases isolate a duplicate in exactly one row, column, or box.
    for kind in ("row", "column", "box"):
        for index in range(32):
            board = [rng.choice("0.") for _ in range(81)]
            if kind == "row":
                row = rng.randrange(9)
                cols = [3 * stack + rng.randrange(3) for stack in rng.sample(range(3), 2)]
                positions = [9 * row + col for col in cols]
            elif kind == "column":
                col = rng.randrange(9)
                rows = [3 * band + rng.randrange(3) for band in rng.sample(range(3), 2)]
                positions = [9 * row + col for row in rows]
            else:
                row, col = 3 * rng.randrange(3), 3 * rng.randrange(3)
                rows, cols = rng.sample(range(3), 2), rng.sample(range(3), 2)
                positions = [9 * (row + rows[k]) + col + cols[k] for k in range(2)]
            digit = rng.choice("123456789")
            for pos in positions:
                board[pos] = digit
            cases.append(dict(id=f"duplicate-{kind}-{index:02d}", kind="duplicate",
                              duplicate_unit=kind, puzzle="".join(board)))
    # Valid givens with a guaranteed contradiction: row 0 lacks only digit 9,
    # but that digit already occurs in column 8. Transformations preserve this.
    impossible = "123456780" + "000000009" + "0" * 63
    for index in range(32):
        cases.append(dict(id=f"unsatisfiable-{index:02d}", kind="unsatisfiable",
                          puzzle=transform(impossible, rng)))
    for mutation in ("short", "long", "ascii", "unicode", "space", "tab", "minus", "colon"):
        for index in range(6):
            board = transform(canonical, rng)
            position = rng.randrange(81)
            if mutation == "short":
                puzzle = board[:position] + board[position + 1:]
            elif mutation == "long":
                puzzle = board[:position] + "0" + board[position:]
            else:
                char = dict(ascii="x", unicode="９", space=" ", tab="\t", minus="-", colon=":")[mutation]
                puzzle = board[:position] + char + board[position + 1:]
            cases.append(dict(id=f"malformed-{mutation}-{index:02d}", kind="malformed",
                              mutation=mutation, puzzle=puzzle))
    for case in cases:
        case["puzzle_sha256"] = sha(case["puzzle"].encode("utf-8"))
    return dict(schema=1, seed=SEED, seed_hex=hex(SEED), valid_grids=REPEATS * len(CLUE_COUNTS),
                clue_counts=CLUE_COUNTS, repeats_per_clue_count=REPEATS,
                generation="Independent digit, band, stack, within-band row, within-stack column permutations and optional transpose of a canonical Latin-pattern Sudoku; uniform sample of retained cells. No filtering by solver outcomes.",
                counts=dict(Counter(c["kind"] for c in cases)), cases=cases,
                cases_sha256=sha(canonical_json(cases)))


class OracleBudget(Exception):
    pass


def count_to_two(puzzle, node_budget, seconds):
    """Fresh Python occupancy/MRV backtracker; descending digit enumeration.

    Node budget includes leaves/dead ends. The wall-clock budget is checked on
    entry and every 128 nodes. Unknown counts are never treated as verified.
    """
    start = time.monotonic()
    status = input_status(puzzle)
    if status != "valid":
        return dict(status="invalid", input_status=status, count=None, nodes=0, seconds=0.0)
    rows, cols, boxes = [0] * 9, [0] * 9, [0] * 9
    empty = []
    for index, value in enumerate(puzzle):
        row, col = divmod(index, 9)
        box = (row // 3) * 3 + col // 3
        if value in "0.":
            empty.append((row, col, box))
        else:
            bit = 1 << (int(value) - 1)
            rows[row] |= bit
            cols[col] |= bit
            boxes[box] |= bit
    nodes, found = 0, 0
    deadline = start + seconds

    def search(remaining):
        nonlocal nodes, found
        nodes += 1
        if nodes > node_budget:
            raise OracleBudget("node_budget")
        if nodes == 1 or nodes % 128 == 0:
            if time.monotonic() >= deadline:
                raise OracleBudget("time_budget")
        if not remaining:
            found += 1
            return
        # Scan every remaining position, including after finding a singleton;
        # the oracle is not production's first-zero/singleton search traversal.
        best_index, best_mask, best_size = -1, 0, 10
        for index, (row, col, box) in enumerate(remaining):
            mask = 511 & ~(rows[row] | cols[col] | boxes[box])
            size = mask.bit_count()
            if size == 0:
                return
            if size < best_size:
                best_index, best_mask, best_size = index, mask, size
        row, col, box = remaining[best_index]
        tail = remaining[:best_index] + remaining[best_index + 1:]
        while best_mask and found < 2:
            bit = 1 << (best_mask.bit_length() - 1)
            best_mask ^= bit
            rows[row] |= bit
            cols[col] |= bit
            boxes[box] |= bit
            search(tail)
            rows[row] ^= bit
            cols[col] ^= bit
            boxes[box] ^= bit

    try:
        search(empty)
        return dict(status="known", count=found, nodes=nodes, seconds=time.monotonic() - start)
    except OracleBudget as exc:
        return dict(status="unknown", count=None, solutions_found_lower_bound=found,
                    reason=str(exc), nodes=nodes, seconds=time.monotonic() - start)


def archive_output(data):
    return dict(base64=base64.b64encode(data).decode("ascii"), sha256=sha(data),
                bytes=len(data), text=data.decode("utf-8", errors="replace"))


def run(binary, args, threads, timeout):
    command = native_command(binary, threads, args)
    start = time.monotonic()
    try:
        result = subprocess.run(command, capture_output=True, timeout=timeout)
        code, stdout, stderr, timed_out = result.returncode, result.stdout, result.stderr, False
    except subprocess.TimeoutExpired as exc:
        code, stdout, stderr, timed_out = None, exc.stdout or b"", exc.stderr or b"", True
    return dict(exit=code, stdout=archive_output(stdout), stderr=archive_output(stderr),
                timed_out=timed_out, seconds=time.monotonic() - start)


def equivalent(lhs, rhs):
    return (not lhs["timed_out"] and not rhs["timed_out"]
            and all(lhs[k] == rhs[k] for k in ("exit", "stdout", "stderr")))


def batch_payload(case, mode, result):
    out, err, code = result["stdout"]["text"].rstrip("\n"), result["stderr"]["text"].rstrip("\n"), result["exit"]
    if result["timed_out"]:
        return None
    if code == 2:
        reason = out if mode == "check" else err
        return "error:" + reason.removeprefix("invalid ")
    if mode == "check":
        return out
    if mode == "count":
        return "count:" + ("fuel" if code == 4 else out)
    if code == 0:
        return "solved:" + out
    return "error:fuel" if code == 4 else out


def main(args):
    out = args.out.resolve()
    out.parent.mkdir(parents=True, exist_ok=True)
    manifest = json.loads(args.cases.read_text()) if args.cases else generate_cases()
    cases = manifest["cases"]
    assert manifest["cases_sha256"] == sha(canonical_json(cases))
    assert len({c["id"] for c in cases}) == len(cases)
    for case in cases:
        assert case["puzzle_sha256"] == sha(case["puzzle"].encode("utf-8"))
        expected = "valid" if case["kind"] in ("valid", "unsatisfiable") else case["kind"]
        assert input_status(case["puzzle"]) == expected
        if case["kind"] == "valid":
            assert valid_solution(case["puzzle"], case["completed_grid"])
    paths = {name: Path(str(out) + suffix) for name, suffix in
             (("cases", ".cases.json"), ("oracle", ".oracle.json"),
              ("batch", ".batch.txt"), ("raw", ".raw.json.gz"))}
    write_json(paths["cases"], manifest)
    print(f"Frozen {len(cases)} cases; SHA256 {manifest['cases_sha256']}", flush=True)
    oracles = {case["id"]: count_to_two(case["puzzle"], args.oracle_nodes, args.oracle_seconds)
               for case in cases}
    write_json(paths["oracle"], dict(node_budget=args.oracle_nodes, seconds_budget=args.oracle_seconds,
                                    time_check_interval_nodes=128, results=oracles))
    oracle_stats = Counter(value["status"] for value in oracles.values())
    print(f"Independent count oracle: {dict(oracle_stats)}", flush=True)
    binaries = {"baseline": args.base.resolve(), "candidate": args.candidate.resolve()}
    binary_hashes = {name: sha(path.read_bytes()) for name, path in binaries.items()}
    records, failures, direct, checks = [], [], {}, Counter()

    def failure(kind, **detail):
        failures.append(dict(kind=kind, **detail))

    def validate(case, mode, variant, result, context):
        checks[f"{context}_{variant}_exit_{result['exit']}"] += 1
        if result["timed_out"]:
            failure("timeout", case=case["id"], mode=mode, variant=variant, context=context)
            return
        oracle = oracles[case["id"]]
        if mode == "solve" and result["exit"] == 0:
            checks["successful_solutions_checked"] += 1
            if not valid_solution(case["puzzle"], result["stdout"]["text"].strip()):
                failure("invalid_solution", case=case["id"], variant=variant, context=context)
        if mode == "solve" and case["kind"] == "valid" and result["exit"] not in (0, 4):
            failure("known_satisfiable_rejected", case=case["id"], variant=variant, context=context)
        if mode == "solve" and oracle["status"] == "known" and oracle["count"] == 0 and result["exit"] not in (3, 4):
            failure("known_unsatisfiable_solved", case=case["id"], variant=variant, context=context)
        if mode == "check":
            expected = 2 if oracle["status"] == "invalid" else 0
            checks["independent_check_verdicts"] += 1
            if result["exit"] != expected:
                failure("check_verdict", case=case["id"], variant=variant, context=context)
        if mode == "count" and result["exit"] == 0:
            if oracle["status"] == "known":
                checks["independent_count_results_checked"] += 1
                if result["stdout"]["text"].strip() != str(oracle["count"]):
                    failure("count_oracle", case=case["id"], variant=variant, context=context)
            else:
                checks["count_results_not_oracle_checked"] += 1
        if oracle["status"] == "invalid" and result["exit"] != 2:
            failure("invalid_input_accepted", case=case["id"], mode=mode, variant=variant, context=context)

    for index, case in enumerate(cases):
        for mode in MODES:
            pair = {name: run(binary, [mode, case["puzzle"]], 1, args.timeout)
                    for name, binary in binaries.items()}
            exact = equivalent(pair["baseline"], pair["candidate"])
            records.append(dict(kind="standalone", case_id=case["id"], mode=mode,
                                threads=1, exact_match=exact, outputs=pair))
            checks["standalone_comparisons"] += 1
            if not exact:
                failure("differential", case=case["id"], mode=mode, context="standalone")
            for name, result in pair.items():
                validate(case, mode, name, result, "standalone")
                direct[(case["id"], mode, name)] = result
        if (index + 1) % 128 == 0:
            print(f"Standalone comparisons: {index + 1}/{len(cases)} cases; failures={len(failures)}", flush=True)
    # Fixed shuffle has no data-dependent filtering. Insert comments/blank lines
    # and CRLF so output order is checked against physical, not compact, indices.
    shuffled = cases[:]
    random.Random(SEED ^ 0xB47C).shuffle(shuffled)
    lines, indexed = [], []
    for index, case in enumerate(shuffled):
        if index % 47 == 0:
            lines.extend([b"# independent randomized suite\n", b"\r\n"])
        indexed.append((len(lines) + 1, case))
        lines.append(case["puzzle"].encode("utf-8") + (b"\r\n" if index % 3 == 0 else b"\n"))
    paths["batch"].write_bytes(b"".join(lines))
    for threads in (1, 8, 16):
        for mode in MODES:
            pair = {name: run(binary, ["batch", str(paths["batch"]), mode], threads, args.batch_timeout)
                    for name, binary in binaries.items()}
            exact = equivalent(pair["baseline"], pair["candidate"])
            records.append(dict(kind="batch", mode=mode, threads=threads,
                                input_sha256=sha(paths["batch"].read_bytes()), exact_match=exact, outputs=pair))
            checks["batch_comparisons"] += 1
            if not exact:
                failure("differential", mode=mode, threads=threads, context="batch")
            for name, result in pair.items():
                expected = []
                for physical, case in indexed:
                    payload = batch_payload(case, mode, direct[(case["id"], mode, name)])
                    expected.append(f"{physical} {payload}\n" if payload is not None else None)
                checks["batch_order_checks"] += 1
                if (None in expected or result["exit"] != 0 or result["stderr"]["bytes"]
                        or result["stdout"]["text"] != "".join(x or "" for x in expected)):
                    failure("batch_order_or_payload", mode=mode, threads=threads, variant=name)
                actual_lines = result["stdout"]["text"].splitlines()
                for (physical, case), line in zip(indexed, actual_lines):
                    if mode == "solve" and line.startswith(f"{physical} solved:"):
                        checks["successful_solutions_checked"] += 1
                        if not valid_solution(case["puzzle"], line.split("solved:", 1)[1]):
                            failure("invalid_solution", case=case["id"], variant=name, threads=threads, context="batch")
            print(f"Batch {mode}, threads={threads}; failures={len(failures)}", flush=True)
    with paths["raw"].open("wb") as file:
        with gzip.GzipFile(filename="", mode="wb", fileobj=file, mtime=0) as compressed:
            compressed.write(canonical_json(records))
    unchanged = {name: sha(path.read_bytes()) == binary_hashes[name] for name, path in binaries.items()}
    if not all(unchanged.values()):
        failure("binary_changed_during_run", unchanged=unchanged)
    summary = dict(status="PASS" if not failures else "FAIL", seed=SEED, seed_hex=hex(SEED),
                   cases=len(cases), distinct_puzzles=len({c["puzzle"] for c in cases}),
                   case_categories=dict(Counter(c["kind"] for c in cases)),
                   clue_distribution=dict(Counter(c["clues"] for c in cases if c["kind"] == "valid")),
                   unique_completed_grids=len({c["completed_grid"] for c in cases if c["kind"] == "valid"}),
                   cases_sha256=manifest["cases_sha256"], binary_sha256=binary_hashes,
                   script_sha256=sha(Path(__file__).read_bytes()), checks=dict(checks),
                   oracle_status=dict(oracle_stats),
                   oracle_known_counts=dict(Counter(str(v["count"]) for v in oracles.values() if v["status"] == "known")),
                   oracle_nodes_total=sum(v["nodes"] for v in oracles.values()),
                   oracle_nodes_max=max(v["nodes"] for v in oracles.values()),
                   oracle_by_clue_count={str(clues): dict(Counter(oracles[c["id"]]["status"]
                                                                 for c in cases if c.get("clues") == clues))
                                         for clues in manifest["clue_counts"]},
                   oracle_unknown_cases={k: v for k, v in oracles.items() if v["status"] == "unknown"},
                   production_fuel_cases=[dict(case=record["case_id"], mode=record["mode"], variant=name)
                                          for record in records if record["kind"] == "standalone"
                                          for name, result in record["outputs"].items() if result["exit"] == 4],
                   limits=dict(oracle_node_budget=args.oracle_nodes, oracle_seconds_budget=args.oracle_seconds,
                               oracle_time_check_interval_nodes=128, standalone_timeout=args.timeout,
                               batch_timeout=args.batch_timeout,
                               scope="Finite seeded differential/independent correctness suite; no exhaustiveness claim or performance inference. All count unknowns, production fuel exits, and process timeouts remain explicitly recorded."),
                   artifacts={name: dict(path=str(path), sha256=sha(path.read_bytes())) for name, path in paths.items()},
                   failures=failures)
    write_json(out, summary)
    print(json.dumps(summary, indent=2), flush=True)
    return 0 if not failures else 1


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--base", type=Path, required=True)
    parser.add_argument("--candidate", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True)
    parser.add_argument("--cases", type=Path, help="Reuse a prior .cases.json exactly, validating its hashes")
    parser.add_argument("--oracle-nodes", type=int, default=50000)
    parser.add_argument("--oracle-seconds", type=float, default=0.25)
    parser.add_argument("--timeout", type=float, default=20.0)
    parser.add_argument("--batch-timeout", type=float, default=120.0)
    parser.add_argument("--lock-held", action="store_true", help="Caller already holds flock -x " + LOCK)
    options = parser.parse_args()
    if options.lock_held:
        sys.exit(main(options))
    with open(LOCK, "a") as lock:
        print(f"Waiting for exclusive CPU lock: {LOCK}", flush=True)
        fcntl.flock(lock.fileno(), fcntl.LOCK_EX)
        sys.exit(main(options))
