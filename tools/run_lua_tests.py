"""Run ordered Lua scripts in installed PZ Kahlua with mocked game APIs."""
import argparse
import os
from pathlib import Path
import subprocess
import tempfile
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--game', required=True, type=Path)
p.add_argument('--javac', default='javac')
p.add_argument('scripts', nargs='+', type=Path)
a = p.parse_args()
game = a.game.resolve()
java = game / ('jre64/bin/java.exe' if os.name == 'nt' else 'jre64/bin/java')
scripts = [str(s.resolve()) for s in a.scripts]
with tempfile.TemporaryDirectory(prefix='project-term-lua-') as build:
    subprocess.run([a.javac, '-d', build, str(Path(__file__).with_name('LuaTestRunner.java'))], check=True)
    subprocess.run([str(java), '-cp', os.pathsep.join([build, str(game / 'projectzomboid.jar')]), 'LuaTestRunner', *scripts], cwd=game, check=True)
