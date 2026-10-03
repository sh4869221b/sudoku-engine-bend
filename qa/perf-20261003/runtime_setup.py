import gzip,hashlib,json,pathlib,subprocess,urllib.request
root=pathlib.Path(__file__).resolve().parents[2]
dest=root/'.toolchains/clang19'; downloads=root/'.toolchains/downloads'
manifest=root/'qa/perf-20261003/runtime-packages.json'
if manifest.exists():
 blocks=json.loads(manifest.read_text())
else:
 index=gzip.decompress(urllib.request.urlopen('https://deb.debian.org/debian/dists/bookworm/main/binary-amd64/Packages.gz').read()).decode()
 blocks=[dict(line.split(': ',1) for line in block.splitlines() if ': ' in line and not line.startswith(' ')) for block in index.split('\n\n')]
wanted={'libedit2','libz3-4','libxml2','libbsd0','libmd0','libicu72'}
records=[]
for fields in blocks:
 if fields.get('Package') not in wanted:continue
 url='https://deb.debian.org/debian/'+fields['Filename']; data=urllib.request.urlopen(url).read(); assert hashlib.sha256(data).hexdigest()==fields['SHA256']
 path=downloads/pathlib.Path(fields['Filename']).name; path.write_bytes(data)
 subprocess.run(['dpkg-deb','-x',str(path),str(dest)],check=True)
 records.append({k:fields[k] for k in ('Package','Version','Filename','SHA256')});print(fields['Package'],flush=True)
(root/'qa/perf-20261003/runtime-packages.json').write_text(json.dumps(records,indent=2)+'\n')
