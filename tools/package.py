#!/usr/bin/env python3
"""Package only installable mod files, not the repository or source assets."""
from pathlib import Path
from zipfile import ZipFile, ZIP_DEFLATED
from validate_mod import ROOT, validate

errors = validate()
if errors:
    raise SystemExit('\n'.join(errors))
output = ROOT / 'dist' / 'ProjectTermModPack-B42-atmosphere-candidate.zip'
output.parent.mkdir(exist_ok=True)
with ZipFile(output, 'w', ZIP_DEFLATED) as archive:
    for folder in ('42', 'common'):
        for path in sorted((ROOT / folder).rglob('*')):
            if path.is_file():
                archive.write(path, Path('project-term-mod-pack') / path.relative_to(ROOT))
with ZipFile(output) as archive:
    broken = archive.testzip()
    if broken:
        raise SystemExit(f'ZIP integrity failed: {broken}')
    names = set(archive.namelist())
    assert 'project-term-mod-pack/42/mod.info' in names
    assert 'project-term-mod-pack/42/media/lua/client/PTMP_Boot.lua' in names
    assert 'project-term-mod-pack/42/media/lua/client/PTMP_Atmosphere.lua' in names
    assert 'project-term-mod-pack/common/README.txt' in names
print(f'Packaged {output} (ZIP and layout checks passed; in-game behavior untested)')
