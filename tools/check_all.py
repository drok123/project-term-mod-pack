"""Run all mock regression suites with the installed game's Kahlua interpreter."""
import argparse
from pathlib import Path
import subprocess
import sys

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--game', required=True)
parser.add_argument('--javac', default='javac')
args = parser.parse_args()
root = Path(__file__).resolve().parents[1]
config = '42/media/lua/shared/ProjectTerm/ProjectTermConfig.lua'
client = '42/media/lua/client/ProjectTerm/'
suites = {
    'atmosphere': [config, client + 'ProjectTermAtmosphere.lua'],
    'runtime': ['42/media/registries.lua', client + 'ProjectTermPlasmaFX.lua'],
    'loot': [config, '42/media/lua/server/ProjectTerm/ProjectTermLoot.lua'],
    'debug': [config, client + 'ProjectTermDebug.lua'],
    'props': [config, client + 'ProjectTermProps.lua'],
    'ambience': [config, client + 'ProjectTermAmbience.lua'],
}
for name, sources in suites.items():
    print(f'Checking {name}', flush=True)
    subprocess.run([sys.executable, 'tools/run_lua_tests.py', '--game', args.game,
                    '--javac', args.javac, f'tests/{name}_setup.lua',
                    *sources, f'tests/{name}_assert.lua'], cwd=root, check=True)
print('All six Kahlua suites passed; engine boundaries are mocked, visual playtest still required.')
