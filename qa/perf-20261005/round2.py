#!/usr/bin/env python3
"""Locked serial screening before expensive candidate verification."""
import hashlib, json, os, pathlib, re, shutil, subprocess, sys, tarfile

ROOT = pathlib.Path(__file__).resolve().parents[2]
BASE = '06b49c06e07b447f2a077183515570695592a3b4'
WORK = pathlib.Path(os.environ['BEND_PERF_WORK']).resolve()
RESULTS = WORK / 'results'
MANIFEST = ROOT / 'qa/perf-20261005/round2-candidates.json'
SCREEN = {'generate100_clues36', 'batch_easy-10000_solve_t1',
          'batch_mixed-1000_solve_t1', 'batch_hard-100_count_t1',
          'batch_rate-300_rate_t1', 'bench_easy-10000_t1',
          'batch_hard-100_count_t8'}

def run(args, cwd=ROOT, log=None):
    if log:
        with (RESULTS / log).open('w') as stream:
            subprocess.run(args, cwd=cwd, check=True, stdout=stream,
                           stderr=subprocess.STDOUT)
    else:
        subprocess.run(args, cwd=cwd, check=True)

def save(name, obj):
    (RESULTS / name).write_text(json.dumps(obj, indent=2) + '\n')

def fresh_tree(name):
    dest = WORK / name
    dest.mkdir()
    archive = subprocess.run(['git', 'archive', BASE], cwd=ROOT,
                             check=True, capture_output=True).stdout
    archive_path = WORK / (name + '.tar')
    archive_path.write_bytes(archive)
    with tarfile.open(archive_path) as stream:
        stream.extractall(dest, filter='data')
    archive_path.unlink()
    return dest

def gate(summary, data, affected, phase):
    rows = json.loads(data.read_text())['summary']
    substantial = [row for row in rows if row['baseline']['wall_ms']['median'] >= 5]
    affected_wins = [row['case'] for row in substantial
                    if row['case'] in affected and row['speedup'] >= 1.05]
    major_regressions = [row['case'] for row in substantial
                         if row['speedup'] < (1 / 1.05)]
    reasons = []
    if summary['primary_speedup'] < 1.03:
        reasons.append('aggregate speedup below 1.03')
    if summary['paired_bootstrap_95_ci'][0] <= 1:
        reasons.append('95% confidence lower bound does not exceed 1')
    if phase == 'screen' and not affected_wins:
        reasons.append('no substantial affected case reaches 1.05 speedup')
    if phase == 'full' and major_regressions:
        reasons.append('substantial case elapsed time regresses more than 5%')
    return {'pass': not reasons, 'reasons': reasons,
            'substantial_baseline_min_ms': 5, 'affected_case_wins': affected_wins,
            'major_regression_cases': major_regressions}

def measure(name, tree, cases, phase):
    stem = name + '-' + phase
    data = RESULTS / (stem + '.json')
    run(['python3', 'qa/perf-20261001/measure.py', '--base',
         str(WORK / 'baseline/bin/bend-sudoku'), '--candidate',
         str(tree / 'bin/bend-sudoku'), '--cases', str(cases),
         '--corpora', str(WORK / 'corpora'), '--reps', '21',
         '--out', str(data)], log=stem + '.log')
    summary_path = RESULTS / (stem + '-summary.json')
    run(['python3', 'qa/perf-20261003/analyze.py', str(data),
         '--out', str(summary_path)])
    return json.loads(summary_path.read_text()), data

def main():
    if WORK.exists():
        raise RuntimeError('Use a fresh work directory: ' + str(WORK))
    RESULTS.mkdir(parents=True)
    (WORK / 'corpora').mkdir()
    os.environ.update(BEND_TOOLCHAIN_DIR=str(ROOT / '.toolchains'),
                      BEND_NO_TELEMETRY='1', BUN_JSC_forceRAMSize='67108864',
                      BEND_LOW_MEMORY='1')
    if subprocess.check_output(['git', 'status', '--porcelain'], cwd=ROOT).strip():
        raise RuntimeError('Checkout must be clean')
    save('source.json', {'baseline': BASE, 'candidate_commit':
         subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
         'policy': 'screen/full >=1.03 aggregate,95% lower>1; screen affected substantial case>=1.05; full no substantial case elapsed regression>5%; verification only after full gate'})
    run(['python3', 'qa/toolchain.py', 'check'], log='toolchain-versions.json')
    installation = ROOT / '.toolchains/installed.json'
    shutil.copyfile(installation, RESULTS / 'toolchain-installed.json')
    shutil.copyfile(ROOT / 'toolchain.lock.json', RESULTS / 'toolchain.lock.json')
    frozen = ['qa/perf-20261001/cases.json', 'qa/perf-20261001/corpus-manifest.json',
              'qa/perf-20261001/prepare_corpus.py', 'qa/perf-20261001/measure.py',
              'qa/perf-20261003/analyze.py']
    corpus_manifest = json.loads(subprocess.check_output(
        ['git', 'show', BASE + ':qa/perf-20261001/corpus-manifest.json'], cwd=ROOT))
    frozen += ['qa/perf-20261001/corpora/' + item['file'] + '.gz'
               for item in corpus_manifest['files']]
    hashes = {}
    for relative in frozen:
        expected = subprocess.check_output(['git', 'show', BASE + ':' + relative], cwd=ROOT)
        actual = (ROOT / relative).read_bytes()
        if actual != expected:
            raise RuntimeError('Frozen benchmark input/script changed: ' + relative)
        hashes[relative] = hashlib.sha256(actual).hexdigest()
    hashes['toolchain.lock.json'] = hashlib.sha256((ROOT / 'toolchain.lock.json').read_bytes()).hexdigest()
    save('frozen-input-identities.json', hashes)
    (RESULTS / 'baseline-tree.txt').write_text(subprocess.check_output(
        ['git', 'rev-parse', BASE + '^{tree}'], cwd=ROOT, text=True))
    run(['python3', 'qa/perf-20261001/prepare_corpus.py', str(WORK / 'corpora')])
    cases = json.loads((ROOT / 'qa/perf-20261001/cases.json').read_text())
    selected = [case for case in cases if case['name'] in SCREEN]
    if len(cases) != 35 or len(selected) != 7:
        raise RuntimeError('Frozen suite changed')
    screen_path = WORK / 'screen-cases.json'
    screen_path.write_text(json.dumps(selected, indent=2) + '\n')
    manifest = json.loads(MANIFEST.read_text())
    entries = manifest['candidates']
    if not entries:
        raise RuntimeError('No candidate overlays supplied')
    if {entry['name'] for entry in entries} != set(manifest['expected_candidates']):
        raise RuntimeError('Every predeclared candidate must be supplied')
    trees, identities, names, affected_cases, oracles = {}, {}, set(), {}, {}
    for entry in entries:
        name = entry['name']
        if not re.fullmatch(r'[a-z][a-z0-9-]{0,47}', name) or name == 'baseline' or name in names:
            raise RuntimeError('Invalid or duplicate candidate name: ' + name)
        names.add(name)
        affected = set(entry['affected_cases'])
        if not affected or not affected <= SCREEN:
            raise RuntimeError('Affected cases must be a nonempty subset of frozen screen: ' + name)
        affected_cases[name] = affected
        oracles[name] = entry['oracles']
        if not oracles[name] or len(set(oracles[name])) != len(oracles[name]):
            raise RuntimeError('Every candidate requires nonempty unique executable oracles')
        overlay = ROOT / 'qa/perf-20261005/trials' / name
        declared = entry['files']
        if not declared or len(set(declared)) != len(declared):
            raise RuntimeError('Missing or duplicate overlay files: ' + name)
        actual = {str(p.relative_to(overlay)) for p in overlay.rglob('*') if p.is_file()}
        if actual != set(declared):
            raise RuntimeError('Manifest must list every overlay file: ' + name)
        tree = fresh_tree(name)
        identities[name] = {}
        for relative in declared:
            if not re.fullmatch(r'(sudoku/[a-z]+|qa/[a-z0-9-]+)\.bend', relative):
                raise RuntimeError('Only production Sudoku or candidate Bend oracle modules may be overlaid')
            source, target = overlay / relative, tree / relative
            if source.is_symlink() or not source.resolve().is_relative_to(overlay.resolve()) or (relative.startswith('sudoku/') and not target.is_file()):
                raise RuntimeError('Unsafe or unknown overlay: ' + relative)
            shutil.copyfile(source, target)
            identities[name][relative] = hashlib.sha256(source.read_bytes()).hexdigest()
        for oracle in oracles[name]:
            if not re.fullmatch(r'qa/[a-z0-9-]+\.bend', oracle) or oracle not in declared:
                raise RuntimeError('Oracle must be a declared candidate QA Bend file')
        if oracles[name]:
            harness = tree / 'qa/verify_gates.sh'
            text = harness.read_text()
            marker = 'export BEND_NO_TELEMETRY=1\n'
            if text.count(marker) != 1:
                raise RuntimeError('Baseline verification registration point changed')
            commands = []
            for index, oracle in enumerate(oracles[name]):
                binary = 'bin/round2-oracle-' + str(index)
                commands.extend(['mkdir -p bin',
                    '"$BEND" ' + oracle + ' -o ' + binary,
                    './' + binary + ' --threads 1'])
            harness.write_text(text.replace(marker, marker + '\n'.join(commands) + '\n'))
            identities[name]['qa/verify_gates.sh'] = hashlib.sha256(harness.read_bytes()).hexdigest()
        trees[name] = tree
    save('overlay-identities.json', identities)
    baseline = fresh_tree('baseline')
    run(['bash', 'build.sh'], cwd=baseline, log='baseline-build.log')
    for name, tree in trees.items():
        run(['bash', 'build.sh'], cwd=tree, log=name + '-build.log')
    # No compiler, verification or other benchmark runs overlap these measurements.
    decision = {'status': 'SCREENING', 'candidates': {}}
    for name, tree in trees.items():
        summary, data = measure(name, tree, screen_path, 'screen')
        verdict = gate(summary, data, affected_cases[name], 'screen')
        decision['candidates'][name] = {'screen': summary, 'screen_gate': verdict,
            'status': 'SCREEN_PASS' if verdict['pass'] else 'SCREEN_REJECTED'}
        save('decision.json', decision)
    for name, tree in trees.items():
        record = decision['candidates'][name]
        if record['status'] != 'SCREEN_PASS':
            continue
        summary, data = measure(name, tree, ROOT / 'qa/perf-20261001/cases.json', 'full')
        verdict = gate(summary, data, affected_cases[name], 'full')
        record.update(full=summary, full_gate=verdict, status='FULL_PASS' if verdict['pass'] else 'FULL_REJECTED')
        save('decision.json', decision)
    for name, tree in trees.items():
        record = decision['candidates'][name]
        if record['status'] != 'FULL_PASS':
            continue
        try:
            run(['bash', 'verify.sh', '--low-memory', '--skip-benchmark'], cwd=tree,
                log=name + '-verify.log')
            run(['python3', 'qa/perf-20261001/differential.py', '--base',
                str(baseline / 'bin/bend-sudoku'), '--candidate',
                str(tree / 'bin/bend-sudoku'), '--repo', str(tree), '--corpora',
                str(WORK / 'corpora'), '--out', str(RESULTS / (name + '-differential.json'))],
                log=name + '-differential.log')
            record['status'] = 'ACCEPTANCE_REVIEW_READY'
        except subprocess.CalledProcessError as error:
            record.update(status='VERIFICATION_FAILED', exit_code=error.returncode)
        finally:
            for summary in tree.glob('.verification/*/summary.json'):
                shutil.copyfile(summary, RESULTS / (name + '-verification-summary.json'))
            save('decision.json', decision)
    decision['status'] = 'COMPLETE'
    save('decision.json', decision)
    print(json.dumps(decision, indent=2))
    if any(record['status'] == 'VERIFICATION_FAILED' for record in decision['candidates'].values()):
        raise SystemExit(1)

if __name__ == '__main__':
    main()
