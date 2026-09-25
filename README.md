# PROJECT TERM — future-war horror for Project Zomboid

Early Build 42 single-player prototype. This repository currently contains a **mod-menu and load diagnostic**, not playable atmosphere, machines, aircraft, or weapons. The exact game version and in-game compatibility have **not yet been verified**.

## Install and test the first gate

1. Run `python3 tools/package.py`. The resulting ZIP is under `dist/`.
2. Extract it and put the inner `ProjectTermModPack` folder directly in `C:\Users\YOUR_NAME\Zomboid\mods\`. The metadata must be at `...\Zomboid\mods\ProjectTermModPack\42\mod.info`.
3. Completely restart Project Zomboid Build 42. Find **PROJECT TERM - Future War** in the Mods menu and enable it for a disposable single-player save.
4. Load the save. Copy `%UserProfile%\Zomboid\console.txt` immediately afterward and look for `[PROJECT TERM] v0.1.0 client Lua loaded` and any errors.
5. Record the **exact full version displayed by the game** (including patch number) and the menu screenshot in `docs/test-log.md`. Record whether the same save loads cleanly after a restart. Do not mark the gate passed from a ZIP check alone.

If it does not appear, check the precise folder nesting above, remove older `ProjectTermModPack` copies, restart, and attach the relevant `console.txt` errors. Test a new save first; existing-save behavior remains unverified.

## Development layout

- `mod/ProjectTermModPack/`: only installable game files (`42/` contains version-specific Lua and metadata; `common/` is reserved for shared assets).
- `assets/source/`: original source art and audio when created.
- `docs/`: recorded test evidence and researched API behavior.
- `tools/`: package and static layout validation.
- `dist/`: generated ZIPs, excluded from Git.

Run `python3 tools/validate_mod.py` before packaging. Keep any future assets original for public distribution. No debug controls or sandbox settings exist yet. The next gate is a controlled atmosphere experiment after an actual B42 mod-menu and load test.
