#!/usr/bin/env python3
"""Package only installable mod files, not the repository or source assets."""
from pathlib import Path
from zipfile import ZipFile, ZIP_DEFLATED
from validate_mod import ROOT, MOD, validate

errors = validate()
if errors:
    raise SystemExit('\n'.join(errors))
output = ROOT / 'dist' / 'ProjectTermModPack-B42-gate1.zip'
output.parent.mkdir(exist_ok=True)
with ZipFile(output, 'w', ZIP_DEFLATED) as archive:
    for path in sorted(MOD.rglob('*')):
        if path.is_file():
            archive.write(path, path.relative_to(ROOT / 'mod'))
with ZipFile(output) as archive:
    broken = archive.testzip()
    if broken:
        raise SystemExit(f'ZIP integrity failed: {broken}')
    names = set(archive.namelist())
    assert 'ProjectTermModPack/42/mod.info' in names
    assert 'ProjectTermModPack/42/media/lua/client/PTMP_Boot.lua' in names
    assert 'ProjectTermModPack/common/README.txt' in names
print(f'Packaged {output} (ZIP and layout checks passed; in-game detection untested)')
