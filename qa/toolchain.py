#!/usr/bin/env python3
"""Install and select the checksum-locked Linux toolchain using stdlib only."""
import argparse
import hashlib
import json
import os
import pathlib
import platform
import re
import shlex
import shutil
import subprocess
import sys
import urllib.parse

ROOT = pathlib.Path(__file__).resolve().parents[1]
LOCK_PATH = ROOT / 'toolchain.lock.json'
LOCK = json.loads(LOCK_PATH.read_text())
TOOLS = pathlib.Path(os.environ.get('BEND_TOOLCHAIN_DIR', ROOT / '.toolchains')).resolve()


def digest(path):
    h = hashlib.sha256()
    with open(path, 'rb') as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b''):
            h.update(chunk)
    return h.hexdigest()


def checked(path, expected):
    if digest(path) != expected:
        raise RuntimeError(f'Checksum mismatch: {path}')


def run(args, **kwargs):
    return subprocess.run([str(a) for a in args], check=True, **kwargs)


def fetch(item):
    downloads = TOOLS / 'downloads'
    downloads.mkdir(parents=True, exist_ok=True)
    dest = downloads / pathlib.PurePosixPath(urllib.parse.urlsplit(item['url']).path).name
    if not dest.exists():
        partial = dest.with_suffix(dest.suffix + '.partial')
        run(['curl', '--fail', '--location', '--retry', '2', '--connect-timeout', '30',
             '--max-time', '600', '--output', partial, item['url']])
        checked(partial, item['sha256'])
        partial.replace(dest)
    checked(dest, item['sha256'])
    return dest


def paths(version):
    return {
        'bend': TOOLS / 'bend/bin/bend',
        'clang': TOOLS / 'clang19/usr/bin/clang-19',
        'lean': TOOLS / f'lean-{version}-linux/bin/lean',
        'leanc': TOOLS / f'lean-{version}-linux/bin/leanc',
        'kernel': TOOLS / f'kernel-{version}/bendtt',
        'kernel_source': TOOLS / 'bend/bend2/bendtt.lean',
    }


def environment(version):
    p = paths(version)
    env = dict(os.environ)
    env.update(BEND_TOOLCHAIN_DIR=str(TOOLS), BEND=str(p['bend']), CC=str(p['clang']),
               BENDTT=str(p['kernel']), BEND_NO_TELEMETRY='1')
    env['PATH'] = ':'.join([str(p['bend'].parent), str(p['lean'].parent),
                            str(p['clang'].parent), env.get('PATH', '')])
    env['LD_LIBRARY_PATH'] = str(TOOLS / 'clang19/usr/lib/x86_64-linux-gnu') + (
        ':' + env['LD_LIBRARY_PATH'] if env.get('LD_LIBRARY_PATH') else '')
    return env


def check_versions(version):
    p = paths(version)
    env = environment(version)
    outputs = {name: run([p[name], 'version' if name == 'bend' else '--version'], env=env, capture_output=True,
                         text=True).stdout.strip() for name in ('bend', 'clang', 'lean')}
    if outputs['bend'] != 'bend ' + LOCK['bend']['version']:
        raise RuntimeError(f"Wrong Bend version: {outputs['bend']}")
    if not re.search(r'\bclang version ' + re.escape(LOCK['clang']['version']) + r'\b', outputs['clang']):
        raise RuntimeError(f"Wrong Clang version: {outputs['clang']}")
    if not outputs['lean'].startswith('Lean (version ' + version + ','):
        raise RuntimeError(f"Wrong Lean version: {outputs['lean']}")
    checked(p['bend'], LOCK['bend']['binary_sha256'])
    checked(p['kernel_source'], LOCK['bend']['kernel_source_sha256'])
    return outputs


def install(version):
    if platform.system() != 'Linux' or platform.machine() not in ('x86_64', 'amd64'):
        raise RuntimeError('This lockfile supports Linux x86_64 only')
    for tool in ('curl', 'tar', 'zstd', 'dpkg-deb', 'cc'):
        if not shutil.which(tool):
            raise RuntimeError(f'Missing prerequisite: {tool}')
    TOOLS.mkdir(parents=True, exist_ok=True)
    # Re-extract verified archives, so a previous partial installation is repairable.
    run(['tar', '-xzf', fetch(LOCK['bend']), '-C', TOOLS])
    lean = LOCK['lean']['versions'][version]
    run(['tar', '--zstd', '-xf', fetch(lean), '-C', TOOLS])
    clang_root = TOOLS / 'clang19'
    clang_root.mkdir(exist_ok=True)
    for package in LOCK['clang']['packages']:
        run(['dpkg-deb', '-x', fetch(package), clang_root])
    versions = check_versions(version)
    p = paths(version)
    p['kernel'].parent.mkdir(exist_ok=True)
    shutil.copy2(p['kernel_source'], p['kernel'].parent / 'bendtt.lean')
    env = environment(version)
    run([p['lean'], '-c', 'bendtt.c', 'bendtt.lean'], cwd=p['kernel'].parent, env=env)
    run([p['leanc'], '-O3', '-DNDEBUG', 'bendtt.c', '-o', 'bendtt'], cwd=p['kernel'].parent, env=env)
    manifest = {'lock_sha256': digest(LOCK_PATH), 'lean_version': version, 'versions': versions,
                'files': {name: {'path': str(path), 'sha256': digest(path)} for name, path in p.items()}}
    (TOOLS / 'installed.json').write_text(json.dumps(manifest, indent=2) + '\n')
    print(f"Ready: Bend {LOCK['bend']['version']}, Clang {LOCK['clang']['version']}, Lean {version}")
    print(f'Toolchain: {TOOLS}')


def selected():
    manifest_path = TOOLS / 'installed.json'
    if not manifest_path.exists():
        raise RuntimeError(f'No locked toolchain in {TOOLS}; run ./setup.sh first')
    manifest = json.loads(manifest_path.read_text())
    if manifest['lock_sha256'] != digest(LOCK_PATH):
        raise RuntimeError('Toolchain lock changed; run ./setup.sh again')
    version = manifest['lean_version']
    if version not in LOCK['lean']['versions']:
        raise RuntimeError('Installed Lean version is not in the lockfile')
    for name, path in paths(version).items():
        checked(path, manifest['files'][name]['sha256'])
    check_versions(version)
    return version


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('command', choices=['setup', 'env', 'check'])
    parser.add_argument('--lean-version', choices=list(LOCK['lean']['versions']),
                        default=LOCK['lean']['default_version'])
    args = parser.parse_args()
    if args.command == 'setup':
        install(args.lean_version)
    elif args.command == 'env':
        env = environment(selected())
        if os.environ.get('BEND_LOW_MEMORY') == '1':
            env['BEND'] = str(ROOT / 'qa/low_memory.py')
        for key in ('BEND_TOOLCHAIN_DIR', 'BEND', 'CC', 'BENDTT', 'BEND_NO_TELEMETRY', 'PATH', 'LD_LIBRARY_PATH'):
            print('export ' + key + '=' + shlex.quote(env[key]))
    else:
        print(json.dumps(check_versions(selected()), indent=2))


if __name__ == '__main__':
    try:
        main()
    except (OSError, ValueError, RuntimeError, subprocess.CalledProcessError) as exc:
        print(f'Toolchain error: {exc}', file=sys.stderr)
        sys.exit(1)
