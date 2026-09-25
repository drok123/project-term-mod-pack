#!/usr/bin/env python3
"""Static gate only: catches folder nesting and metadata errors before an in-game test."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MOD = ROOT / 'mod' / 'ProjectTermModPack'
INFO = MOD / '42' / 'mod.info'
COMMON = MOD / 'common'
CLIENT = MOD / '42' / 'media' / 'lua' / 'client' / 'PTMP_Boot.lua'


def validate() -> list[str]:
    errors = []
    for required in (INFO, COMMON, CLIENT):
        if not required.exists():
            errors.append(f'Missing: {required.relative_to(ROOT)}')
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
    if fields.get('versionMin', '').split('.')[0] != '42':
        errors.append('versionMin must target Build 42')
    if (MOD / 'mod.info').exists() or (MOD / 'media').exists():
        errors.append('Root-level legacy mod files must not be used for this B42 package')
    return errors


if __name__ == '__main__':
    problems = validate()
    if problems:
        raise SystemExit('\n'.join(problems))
    print('Static Build 42 layout and metadata: OK (in-game detection untested)')
