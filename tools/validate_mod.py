#!/usr/bin/env python3
"""Static gate only: catches folder nesting and metadata errors before an in-game test."""
from pathlib import Path
import json
import re

ROOT = Path(__file__).resolve().parents[1]
MOD = ROOT
INFO = MOD / '42' / 'mod.info'
COMMON = MOD / 'common'
CLIENT = MOD / '42' / 'media' / 'lua' / 'client' / 'PTMP_Boot.lua'
ATMOSPHERE = MOD / '42' / 'media' / 'lua' / 'client' / 'PTMP_Atmosphere.lua'
OPTIONS = MOD / '42' / 'media' / 'sandbox-options.txt'
TRANSLATIONS = MOD / '42' / 'media' / 'lua' / 'shared' / 'Translate' / 'EN' / 'Sandbox.json'


def validate() -> list[str]:
    errors = []
    for required in (INFO, COMMON, CLIENT, ATMOSPHERE, OPTIONS, TRANSLATIONS):
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
