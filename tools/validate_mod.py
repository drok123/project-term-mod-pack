#!/usr/bin/env python3
"""Static gate only: catches folder nesting and metadata errors before an in-game test."""
from pathlib import Path
import json
import re

ROOT = Path(__file__).resolve().parents[1]
MOD = ROOT
INFO = MOD / '42' / 'mod.info'
COMMON = MOD / 'common'
OPTIONS = MOD / '42/media/sandbox-options.txt'
TRANSLATIONS = MOD / '42/media/lua/shared/Translate/EN/Sandbox.json'

# Keep the release gate honest about both halves of the combined prototype.
# package.py imports this list so source-layout and ZIP checks cannot drift.
REQUIRED_FILES = (
    Path('42/mod.info'),
    Path('42/media/lua/client/PTMP_Boot.lua'),
    Path('42/media/lua/client/PTMP_Atmosphere.lua'),
    Path('42/media/sandbox-options.txt'),
    Path('42/media/lua/shared/Translate/EN/Sandbox.json'),
    Path('42/media/lua/shared/ProjectTerm/ProjectTermBoot.lua'),
    Path('42/media/lua/client/ProjectTerm/ProjectTermPlasmaFX.lua'),
    Path('42/media/lua/server/ProjectTerm/ProjectTermLoot.lua'),
    Path('42/media/lua/shared/Translate/EN/ItemName.json'),
    Path('42/media/registries.lua'),
    Path('42/media/scripts/term_weapons.txt'),
    Path('42/media/scripts/term_asset_models.txt'),
    Path('common/README.txt'),
)


def validate() -> list[str]:
    errors = []
    for relative in REQUIRED_FILES:
        required = MOD / relative
        if not required.exists():
            errors.append(f'Missing: {relative}')
    if not COMMON.is_dir():
        errors.append('Missing directory: common')
    if not INFO.exists():
        return errors
    fields = {}
    for line in INFO.read_text(encoding='utf-8').splitlines():
        if '=' in line and not line.startswith('#'):
            key, value = line.split('=', 1)
            fields[key] = value
    for key in ('name', 'id', 'author', 'modversion', 'description', 'versionMin'):
        if not fields.get(key):
            errors.append(f'Missing mod.info field: {key}')
    if fields.get('id') != 'ProjectTermModPack':
        errors.append('mod.info id must remain ProjectTermModPack')
    if fields.get('versionMin') != '42.20.0':
        errors.append('mod.info versionMin must remain 42.20.0')
    if (MOD / 'mod.info').exists() or (MOD / 'media').exists():
        errors.append('Root-level legacy mod files must not be used for this B42 package')
    if (MOD / 'mod').exists():
        errors.append('Nested mod/ directory would break direct GitHub Desktop installation')
    if TRANSLATIONS.exists() and OPTIONS.exists():
        try:
            labels = json.loads(TRANSLATIONS.read_text(encoding='utf-8'))
            if not isinstance(labels, dict):
                errors.append('Sandbox.json must be a JSON object')
            else:
                pages = re.findall(r'\bpage\s*=\s*(\w+)', OPTIONS.read_text(encoding='utf-8'))
                translations = re.findall(r'\btranslation\s*=\s*(\w+)', OPTIONS.read_text(encoding='utf-8'))
                for key in {f'Sandbox_{page}' for page in pages} | {f'Sandbox_{name}' for name in translations}:
                    if not labels.get(key):
                        errors.append(f'Missing sandbox translation: {key}')
        except json.JSONDecodeError as exc:
            errors.append(f'Invalid Sandbox.json: {exc}')
    return errors


if __name__ == '__main__':
    problems = validate()
    if problems:
        raise SystemExit('\n'.join(problems))
    print('Static Build 42 layout and metadata: OK (in-game detection untested)')
