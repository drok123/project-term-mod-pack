"""Compare an installed mod with a package SHA-256 manifest (read only)."""
import argparse
import hashlib
import json
from pathlib import Path

parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('manifest',type=Path)
parser.add_argument('--mod-dir',type=Path,default=Path.home()/'Zomboid/mods/project-term-mod-pack')
args=parser.parse_args()
expected=json.loads(args.manifest.read_text(encoding='utf-8'))
root=args.mod_dir.resolve()
bad=[]
for name,record in expected.items():
    path=(root/name).resolve()
    if not path.is_relative_to(root): raise SystemExit('Manifest path escapes mod directory')
    if not path.is_file(): bad.append('MISSING '+name)
    elif hashlib.sha256(path.read_bytes()).hexdigest()!=record['sha256']: bad.append('DIFFERENT '+name)
if bad:
    print('\n'.join(bad))
    raise SystemExit(f'{len(bad)} missing/different files; install the complete packaged mod, including media/sound.')
print(f'PASS: all {len(expected)} packaged files match the installed mod.')
