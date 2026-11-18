#!/usr/bin/env python3
"""Real Node checks for the Bend 2.0.40 Nat host boundary and Sudoku CLI.

Run after building bin/bend-sudoku; --out must be a fresh JSON file.
No File-effect coverage is claimed: that backend requires Bun, not Node.
Run --self-test for Python-only acceptance/recording regressions (no compiler).
"""
import argparse
import json
import os
import pathlib
import re
import shutil
import sys
import tempfile

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
from check_real import ROOT, SOURCE_COMMIT, Recorder, require, sha256, utc_now

sys.path.insert(0, str(ROOT / 'qa'))
from checks import bench_timing

SOLVED = '534678912672195348198342567859761423426853791713924856961537284287419635345286179'
EASY = '530070000600195000098000060800060003400803001700020006060000280000419005000080079'
NAT_SOURCE = 'import Base\ndef echo_nat(x: Nat) -> Nat:\n  x\ndef main() -> Nat:\n  5n\n'
HOST_TEST = r'''
import lib from './nat_host.mjs';
const results = [];
function check(ok, label) { if (!ok) throw new Error(label); }
check(typeof lib.main() === 'number' && lib.main() === 5, 'Nat result must be Number');
results.push({case:'Nat result', type:typeof lib.main(), value:lib.main()});
for (const n of [0, 5, 2**48-1, 2**48, 2**53-1, 2**53]) {
  const got = lib.echo_nat(n);
  check(typeof got === 'number' && got === n, 'accepted Number round-trip');
  results.push({case:'accepted Number', input:n, value:got, type:typeof got});
}
for (const [label,n] of [['BigInt',5n],['negative',-1],['fraction',1.5],
                        ['infinity',Infinity],['NaN',NaN],['above bound',2**53+2]]) {
  let error = null;
  try { lib.echo_nat(n); } catch (caught) { error = String(caught); }
  check(error === 'bend: expected a Nat host number: an integer from 0 to 2^53', 'rejected '+label);
  results.push({case:'rejected host value', label, error});
}
console.log(JSON.stringify({status:'PASS', cases:results}));
'''


CLI_CASES = [(['solve', EASY], 0), (['check', SOLVED], 0),
             (['count', EASY], 0), (['rate', SOLVED], 0),
             (['solve', 'bad'], 2), (['nonsense'], 1),
             (['generate', '--seed', '4294967296'], 1)] + [
    (['generate', '--seed', str(seed), '--clues', str(clues)], 0)
    for seed in (0, 42, 4294967295) for clues in (50, 81)]
EXPECTED_CASES = {
    'Node version', 'compile Nat host module', 'compile Sudoku JavaScript',
    'Nat host boundary',
    *(f'CLI {index}: {lane}' for index in range(len(CLI_CASES))
      for lane in ('native', 'node')),
    *(f'IO.now generated bench: {lane}' for lane in ('native', 'node')),
}
HOST_ACCEPTED = (0, 5, 2**48-1, 2**48, 2**53-1, 2**53)
HOST_REJECTED = ('BigInt', 'negative', 'fraction', 'infinity', 'NaN', 'above bound')
NAT_ERROR = 'bend: expected a Nat host number: an integer from 0 to 2^53'


def check_success(record):
    require(record['exit_code'] == 0 and record['stderr'] == '',
            'Command must succeed without stderr')


def check_emission(record, output):
    check_success(record)
    require(record['stdout'] == '', 'Unexpected JavaScript export diagnostics')
    require(output.is_file() and output.stat().st_size > 0,
            'Missing or empty emitted JavaScript')


def check_host_boundary(record):
    check_success(record)
    host = json.loads(record['stdout'])
    expected = [{'case': 'Nat result', 'type': 'number', 'value': 5}]
    expected += [{'case': 'accepted Number', 'input': n, 'value': n, 'type': 'number'}
                 for n in HOST_ACCEPTED]
    expected += [{'case': 'rejected host value', 'label': label, 'error': NAT_ERROR}
                 for label in HOST_REJECTED]
    # Comparing the complete payload prevents duplicated/omitted checks from
    # satisfying a mere length check. Reject JSON booleans explicitly below.
    require(host == {'status': 'PASS', 'cases': expected},
            'Not every distinct host boundary check completed correctly')
    require(all(type(case['value']) is int for case in host['cases'][:7]),
            'Host Number results must be whole JSON numbers, not booleans')
    require(all(type(case['input']) is int for case in host['cases'][1:7]),
            'Host Number inputs must be whole JSON numbers, not booleans')
    return host


def check_generated_board(text, clues):
    require(re.fullmatch(r'[0-9]{81}\n', text) is not None,
            'Generated puzzle must be exactly 81 ASCII digits')
    board = text[:-1]
    require(sum(c != '0' for c in board) == clues, 'Generated clue count differs')
    units = [board[row * 9:(row + 1) * 9] for row in range(9)]
    units += [board[col::9] for col in range(9)]
    units += [''.join(board[(row + dy) * 9 + col + dx]
                      for dy in range(3) for dx in range(3))
              for row in (0, 3, 6) for col in (0, 3, 6)]
    for unit in units:
        given = unit.replace('0', '')
        require(len(given) == len(set(given)), 'Generated board has conflicting givens')


def check_cli(record, args, expected_exit, reference=None):
    require(record['exit_code'] == expected_exit, 'Unexpected CLI exit status')
    if expected_exit == 0:
        check_success(record)
    if reference is not None:
        require(all(reference[key] == record[key]
                    for key in ('stdout', 'stderr', 'exit_code')),
                'Native/Node CLI mismatch')
    if args[0] == 'generate' and expected_exit == 0:
        check_generated_board(record['stdout'], int(args[args.index('--clues') + 1]))


def check_bench(record):
    check_success(record)
    try:
        bench_timing(record['stdout'], record['stderr'], expected_n=10)
    except AssertionError as exc:
        require(False, exc.args[0])


def check_complete(result):
    records = result['cases']
    require(len(records) == len(EXPECTED_CASES)
            and {record['case'] for record in records} == EXPECTED_CASES
            and all(record['status'] == 'PASS' for record in records),
            'Not every required Node check completed')
    require(result.get('cli_comparisons') == len(CLI_CASES)
            and result.get('generated_board_exact_comparisons') == 6
            and result.get('generated_bench_checks') == 2,
            'Required CLI comparisons are incomplete')
    # Recheck the host payload at the final acceptance boundary too.
    check_host_boundary({'exit_code': 0, 'stderr': '',
                         'stdout': json.dumps(result.get('host_boundary'))})


def run_checks(result, checkpoint):
    import toolchain
    require(toolchain.LOCK['bend']['version'] == '2.0.40'
            and toolchain.LOCK['bend']['source_commit'] == SOURCE_COMMIT,
            'Requires the reviewed Bend 2.0.40 source/version pair')
    node = shutil.which('node')
    require(node is not None, 'Node is required')
    binary = ROOT / 'bin/bend-sudoku'
    require(binary.is_file() and os.access(binary, os.X_OK),
            'Build an executable native engine first')
    env = toolchain.environment(toolchain.selected())
    env.update(BEND_LOW_MEMORY='0')
    work = pathlib.Path(result['work'])
    recorder = Recorder(result, checkpoint)
    version = recorder.run('Node version', [node, '--version'], env, work)
    recorder.accept(version, lambda: (check_success(version), require(
        re.fullmatch(r'v[0-9]+\.[0-9]+\.[0-9]+(?:[-+][^\s]+)?\n', version['stdout']) is not None,
        'Unexpected Node version output')))
    result['native_sha256'] = sha256(binary)
    result['toolchain'] = toolchain.LOCK['bend']
    source = work / 'nat_host.bend'
    source.write_text(NAT_SOURCE)
    script = work / 'nat_host.mjs'
    runner = work / 'host_test.mjs'
    runner.write_text(HOST_TEST)
    engine_js = work / 'bend-sudoku.js'
    for label, src, dst in [('Nat host module', source, script),
                            ('Sudoku JavaScript', ROOT / 'main.bend', engine_js)]:
        record = recorder.run('compile ' + label, [env['BEND'], src, '-o', dst], env, work)
        recorder.accept(record, lambda: check_emission(record, dst))
    record = recorder.run('Nat host boundary', [node, runner], env, work)
    def check_host():
        result['host_boundary'] = check_host_boundary(record)
    recorder.accept(record, check_host)
    for index, (args, expected_exit) in enumerate(CLI_CASES):
        records = []
        for lane, prefix in [('native', [binary, '+RTS', '--threads', '1', '-RTS']),
                             ('node', [node, engine_js])]:
            rec = recorder.run(f'CLI {index}: {lane}', [*prefix, *args], env, work, timeout=120)
            recorder.accept(rec, lambda: check_cli(
                rec, args, expected_exit, records[0] if records else None))
            records.append(rec)
    for lane, prefix in [('native', [binary, '+RTS', '--threads', '1', '-RTS']), ('node', [node, engine_js])]:
        rec = recorder.run('IO.now generated bench: ' + lane,
                           [*prefix, 'bench', '--generate', '10'], env, work, timeout=120)
        recorder.accept(rec, lambda: check_bench(rec))
    result['cli_comparisons'] = len(CLI_CASES)
    result['generated_board_exact_comparisons'] = 6
    result['generated_bench_checks'] = 2
    result['javascript_sha256'] = sha256(engine_js)
    check_complete(result)


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--out', type=pathlib.Path)
    group.add_argument('--self-test', action='store_true',
                       help='Run Python-only regression tests; starts no compiler or Node')
    args = parser.parse_args(argv)
    if args.self_test:
        return self_test()
    out = pathlib.Path(os.path.abspath(args.out))
    try:
        stream = out.open('x', encoding='utf-8')
    except OSError as exc:
        parser.error(f'Cannot create fresh report {out}: {exc}')
    result = {'schema_version': 1, 'source_commit': SOURCE_COMMIT,
              'status': 'RUNNING', 'started_at_utc': utc_now(), 'cases': [],
              'python_optimization': sys.flags.optimize}
    def checkpoint():
        stream.seek(0)
        json.dump(result, stream, indent=2)
        stream.write('\n')
        stream.truncate()
        stream.flush()
        os.fsync(stream.fileno())
    with stream:
        try:
            result['work'] = tempfile.mkdtemp(prefix=out.stem + '-work-', dir=out.parent)
            checkpoint()
            run_checks(result, checkpoint)
            check_complete(result)
            result['status'] = 'PASS'
        except BaseException as exc:
            result.update(status='FAIL', error=f'{type(exc).__name__}: {exc}')
        finally:
            result['finished_at_utc'] = utc_now()
            checkpoint()
    print(f"{result['status']}: {out}")
    if 'error' in result:
        print(result['error'], file=sys.stderr)
    return 0 if result['status'] == 'PASS' else 1


def self_test():
    """Regression checks embedded here so the real harness stays standalone."""
    import contextlib
    import copy
    import io
    import subprocess
    import types
    import unittest
    from unittest import mock
    import check_real

    module = sys.modules[__name__]

    def host_payload():
        return {'status': 'PASS', 'cases': [
            {'case': 'Nat result', 'type': 'number', 'value': 5},
            *({'case': 'accepted Number', 'input': n, 'value': n, 'type': 'number'}
              for n in HOST_ACCEPTED),
            *({'case': 'rejected host value', 'label': name, 'error': NAT_ERROR}
              for name in HOST_REJECTED)]}

    def record(stdout='', stderr='', exit_code=0):
        return {'exit_code': exit_code, 'stdout': stdout, 'stderr': stderr}

    class AcceptanceTests(unittest.TestCase):
        def setUp(self):
            self.temp = tempfile.TemporaryDirectory(prefix='js harness self-test ')
            self.addCleanup(self.temp.cleanup)
            self.root = pathlib.Path(self.temp.name)
            self.out = self.root / 'report.json'

        def invoke(self, action):
            with mock.patch.object(module, 'run_checks', side_effect=action), \
                    contextlib.redirect_stdout(io.StringIO()), \
                    contextlib.redirect_stderr(io.StringIO()):
                code = main(['--out', str(self.out)])
            return code, json.loads(self.out.read_text())

        def passing(self, result, checkpoint):
            result.update(cli_comparisons=13, generated_board_exact_comparisons=6,
                          generated_bench_checks=2, host_boundary=host_payload())
            result['cases'].extend({'case': name, 'status': 'PASS'} for name in EXPECTED_CASES)

        def test_real_process_inventory_and_required_case_identity(self):
            self.assertEqual(len(CLI_CASES), 13)
            self.assertEqual(len(EXPECTED_CASES), 32)
            code, report = self.invoke(self.passing)
            self.assertEqual((code, report['status']), (0, 'PASS'))
            self.assertEqual(report['python_optimization'], sys.flags.optimize)
            self.assertEqual(report['source_commit'], SOURCE_COMMIT)

        def test_incomplete_duplicate_failed_or_uncompared_checks_cannot_pass(self):
            def missing(report):
                report['cases'].pop()
            def duplicate(report):
                report['cases'][0] = dict(report['cases'][1])
            def failed(report):
                report['cases'][0]['status'] = 'FAIL'
            def comparisons(report):
                report['cli_comparisons'] = 12
            def host(report):
                report['host_boundary']['cases'][-1] = report['host_boundary']['cases'][-2]
            for index, mutate in enumerate((missing, duplicate, failed, comparisons, host)):
                self.out = self.root / f'incomplete-{index}.json'
                def incomplete(result, checkpoint):
                    self.passing(result, checkpoint)
                    mutate(result)
                with self.subTest(case=index):
                    code, report = self.invoke(incomplete)
                    self.assertEqual((code, report['status']), (1, 'FAIL'))
                    self.assertTrue(report['error'])

        def test_fresh_output_refuses_existing_files_directories_and_symlinks(self):
            target = self.root / 'valuable'
            target.write_text('keep me')
            makers = (lambda p: p.write_text('original'), lambda p: p.mkdir(),
                      lambda p: p.symlink_to(target),
                      lambda p: p.symlink_to(self.root / 'missing'))
            for index, make in enumerate(makers):
                out = self.root / str(index)
                make(out)
                with self.subTest(case=index), \
                        mock.patch.object(module, 'run_checks') as run, \
                        contextlib.redirect_stderr(io.StringIO()):
                    with self.assertRaises(SystemExit) as error:
                        main(['--out', str(out)])
                    self.assertEqual(error.exception.code, 2)
                    run.assert_not_called()
                    self.assertTrue(os.path.lexists(out))
                    self.assertEqual(target.read_text(), 'keep me')
                    if index == 0:
                        self.assertEqual(out.read_text(), 'original')

        def test_required_output_before_work(self):
            with mock.patch.object(module, 'run_checks') as run, \
                    contextlib.redirect_stderr(io.StringIO()):
                with self.assertRaises(SystemExit) as error:
                    main([])
            self.assertEqual(error.exception.code, 2)
            run.assert_not_called()

        def test_failure_retains_report_and_private_work(self):
            def fail(result, checkpoint):
                (pathlib.Path(result['work']) / 'failure').write_text('diagnostics')
                require(False, 'injected acceptance failure')
            code, report = self.invoke(fail)
            self.assertEqual((code, report['status']), (1, 'FAIL'))
            self.assertIn('injected acceptance failure', report['error'])
            self.assertEqual((pathlib.Path(report['work']) / 'failure').read_text(), 'diagnostics')
            self.assertIn('finished_at_utc', report)

        def test_timeout_marks_record_failed_and_stops_process_group(self):
            process = mock.Mock(returncode=-9)
            process.communicate.side_effect = [subprocess.TimeoutExpired(['fake'], 120),
                                               ('partial stdout', 'partial stderr')]
            result = {'cases': []}
            with mock.patch.object(check_real.subprocess, 'Popen', return_value=process), \
                    mock.patch.object(check_real, 'stop_process') as stop:
                with self.assertRaisesRegex(RuntimeError, 'timed out after 120'):
                    Recorder(result, mock.Mock()).run('fake', ['fake'], {}, self.root, timeout=120)
            stop.assert_called_once_with(process)
            self.assertEqual(result['cases'][0]['status'], 'FAIL')
            self.assertTrue(result['cases'][0]['timed_out'])
            self.assertEqual(result['cases'][0]['stdout'], 'partial stdout')

        def test_cli_mismatch_is_a_failed_process_record(self):
            result = {'cases': []}
            checked = dict(record('different\n'), case='CLI 0: node', status='AWAITING_CHECK')
            result['cases'].append(checked)
            checkpoint = mock.Mock()
            with self.assertRaisesRegex(RuntimeError, 'Native/Node CLI mismatch'):
                Recorder(result, checkpoint).accept(checked, lambda: check_cli(
                    checked, ['solve', EASY], 0, record(SOLVED + '\n')))
            self.assertEqual(checked['status'], 'FAIL')
            checkpoint.assert_called_once_with()

        def test_emission_requires_nonempty_file_and_no_diagnostics(self):
            output = self.root / 'out.js'
            with self.assertRaises(RuntimeError):
                check_emission(record(), output)
            output.touch()
            with self.assertRaises(RuntimeError):
                check_emission(record(), output)
            output.write_text('valid generated output')
            check_emission(record(), output)
            for bad in (record('warning'), record(stderr='warning'), record(exit_code=-9)):
                with self.subTest(record=bad), self.assertRaises(RuntimeError):
                    check_emission(bad, output)

        def test_host_payload_requires_distinct_exact_boundary_results(self):
            good = host_payload()
            self.assertEqual(check_host_boundary(record(json.dumps(good))), good)
            bads = []
            duplicate = copy.deepcopy(good)
            duplicate['cases'][-1] = copy.deepcopy(duplicate['cases'][-2])
            bads.append(duplicate)
            boolean = copy.deepcopy(good)
            boolean['cases'][1]['value'] = False
            bads.append(boolean)
            numeric_type = copy.deepcopy(good)
            numeric_type['cases'][1]['input'] = 0.0
            bads.append(numeric_type)
            wrong_type = copy.deepcopy(good)
            wrong_type['cases'][0]['type'] = 'bigint'
            bads.append(wrong_type)
            for bad in bads:
                with self.subTest(payload=bad), self.assertRaises(RuntimeError):
                    check_host_boundary(record(json.dumps(bad)))

        def test_generated_board_shape_clues_and_all_units(self):
            check_generated_board(SOLVED + '\n', 81)
            check_generated_board(SOLVED[:50] + '0' * 31 + '\n', 50)
            row_conflict = SOLVED[1] + SOLVED[1:]
            column_conflict = SOLVED[9] + SOLVED[1:]
            box_conflict = SOLVED[10] + SOLVED[1:]
            for text, clues in ((SOLVED, 81), ('0' * 81 + '\n', 81),
                                (SOLVED + '\n', 50), (row_conflict + '\n', 81),
                                (column_conflict + '\n', 81), (box_conflict + '\n', 81)):
                with self.subTest(text=text), self.assertRaises(RuntimeError):
                    check_generated_board(text, clues)

        def test_bench_rejects_invalid_or_inconsistent_time(self):
            prefix = 'N=10 mode=cpu threads=runtime total_ms=12 per_ms='
            for value in ('1.2', '12e-1'):
                check_bench(record(prefix + value + '\n'))
            for value in ('0', '1e-3', '1e999', '-1', 'nan', 'inf', '1..2', '1e'):
                with self.subTest(value=value), self.assertRaises(RuntimeError):
                    check_bench(record(prefix + value + '\n'))
            with self.assertRaises(RuntimeError):
                check_bench(record((prefix + '1\n').replace('N=10', 'N=1')))

        def test_full_orchestration_uses_only_mocked_processes(self):
            root = self.root / 'project'
            (root / 'bin').mkdir(parents=True)
            (root / 'main.bend').write_text('source')
            binary = root / 'bin/bend-sudoku'
            binary.write_text('fake binary')
            binary.chmod(0o700)
            work = self.root / 'work'
            work.mkdir()
            fake = types.SimpleNamespace(
                LOCK={'bend': {'version': '2.0.40', 'source_commit': SOURCE_COMMIT}},
                selected=mock.Mock(return_value='4.34.1'),
                environment=mock.Mock(return_value={'BEND': '/fake/bend'}))
            result = {'work': str(work), 'cases': []}
            def execute(recorder, case, command, env, cwd, timeout=60):
                output, code = '', 0
                if case == 'Node version':
                    output = 'v22.0.0\n'
                elif case.startswith('compile '):
                    pathlib.Path(command[-1]).write_text('emitted JS')
                elif case == 'Nat host boundary':
                    output = json.dumps(host_payload())
                elif case.startswith('CLI '):
                    index = int(case.split()[1].rstrip(':'))
                    args, code = CLI_CASES[index]
                    output = 'same output\n'
                    if args[0] == 'generate' and code == 0:
                        clues = int(args[-1])
                        output = SOLVED[:clues] + '0' * (81 - clues) + '\n'
                else:
                    self.assertEqual(command[-3:], ['bench', '--generate', '10'])
                    output = 'N=10 mode=cpu threads=runtime total_ms=12 per_ms=1.2\n'
                item = dict(record(output, exit_code=code), case=case,
                            status='AWAITING_CHECK', timeout_seconds=timeout)
                recorder.result['cases'].append(item)
                return item
            with mock.patch.object(module, 'ROOT', root), \
                    mock.patch.dict(sys.modules, {'toolchain': fake}), \
                    mock.patch.object(shutil, 'which', return_value='/fake/node'), \
                    mock.patch.object(Recorder, 'run', execute):
                run_checks(result, mock.Mock())
            check_complete(result)
            self.assertEqual(len(result['cases']), 32)
            self.assertEqual(len(result['host_boundary']['cases']), 13)
            self.assertTrue(all(item['timeout_seconds'] == 120 for item in result['cases'][4:]))

    suite = unittest.defaultTestLoader.loadTestsFromTestCase(AcceptanceTests)
    return 0 if unittest.TextTestRunner(verbosity=2).run(suite).wasSuccessful() else 1


if __name__ == '__main__':
    raise SystemExit(main())
