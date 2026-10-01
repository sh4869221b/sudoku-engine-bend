#!/usr/bin/env python3
"""Restore exact checked-in benchmark inputs and verify their SHA-256 hashes."""
import gzip,hashlib,json,pathlib,sys
root=pathlib.Path(__file__).resolve().parent
dest=pathlib.Path(sys.argv[1]).resolve() if len(sys.argv)>1 else root/'corpora/plain'
dest.mkdir(parents=True,exist_ok=True)
for item in json.loads((root/'corpus-manifest.json').read_text())['files']:
 data=gzip.decompress((root/'corpora'/(item['file']+'.gz')).read_bytes())
 assert len(data)==item['bytes'] and hashlib.sha256(data).hexdigest()==item['sha256']
 (dest/item['file']).write_bytes(data)
print(dest)
