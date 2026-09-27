"""Compatibility entry point: use installed-game Kahlua instead of a system Lua DLL."""
from pathlib import Path
import runpy
runpy.run_path(str(Path(__file__).with_name("check_all.py")), run_name="__main__")
