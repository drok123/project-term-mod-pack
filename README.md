# PROJECT TERM — future-war horror for Project Zomboid

Early Build 42 single-player prototype. It contains a **mod-menu/load diagnostic and an experimental atmosphere pass**. The exact game patch version and in-game compatibility have **not yet been verified**. It does not yet contain machines, aircraft, props, or weapons.

## Install and test the first gate

1. Run `python3 tools/package.py`. The resulting ZIP is under `dist/`.
2. Extract it and put the inner `ProjectTermModPack` folder directly in `C:\Users\YOUR_NAME\Zomboid\mods\`. The metadata must be at `...\Zomboid\mods\ProjectTermModPack\42\mod.info`.
3. Completely restart Project Zomboid Build 42. Find **PROJECT TERM - Future War** in the Mods menu and enable it for a disposable single-player save.
4. Load the save. Copy `%UserProfile%\Zomboid\console.txt` immediately afterward and look for `[PROJECT TERM] v0.2.0 client Lua loaded`, `Atmosphere climate layer active`, and any errors.
5. Record the **exact full version displayed by the game** (including patch number) and the menu screenshot in `docs/test-log.md`. Record whether the same save loads cleanly after a restart. Do not mark the gate passed from a ZIP check alone.

If it does not appear, check the precise folder nesting above, remove older `ProjectTermModPack` copies, restart, and attach the relevant `console.txt` errors. Test a new save first; existing-save behavior remains unverified.

## Development layout

- `mod/ProjectTermModPack/`: only installable game files (`42/` contains version-specific Lua and metadata; `common/` is reserved for shared assets).
- `assets/source/`: original source art and audio when created.
- `docs/`: recorded test evidence and researched API behavior.
- `tools/`: package and static layout validation.
- `dist/`: generated ZIPs, excluded from Git.

Run `python3 tools/validate_mod.py` before packaging. Keep any future assets original for public distribution. No debug controls or sandbox settings exist yet. `PTMP_Atmosphere.lua` uses vanilla climate channels once per in-game minute and eases into gloomy daylight, muted color, increased cloud cover, and restrained distant haze. Edit its `Settings` table and restart to tune it. It does not make literal smoke particles or volumetric lights. Other climate mods can conflict.

**Atmosphere test after menu/load proof:** compare an outdoor street at noon and dusk with the mod off/on. Then check nighttime outdoors, a dark interior, rain, and a weather transition; capture screenshots and `console.txt` for each. Make sure nearby roads remain visible and natural weather continues. Disable the mod and reload the same save to verify the vanilla look returns. Record results in `docs/test-log.md` before advancing to props or machine behavior.
