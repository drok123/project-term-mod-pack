# Project Term Mod Pack

Single-player Build 42 future-war conversion prototype. Current candidate: **0.2.0**, inspected against **42.20.4 b0bbce05d5**. Multiplayer is unsupported for this milestone.

## Implemented candidate

- Integrated adjustable haze, darkness, desaturation and cold tint from the prior local atmosphere prototype; F8 toggles the layer for comparison.
- Arc Pulse Rifle, registered Arc Charge ammo and energy-cell magazine. Fixed the registry exception found in the actual game log; corrected rifle animation/classification and bounded muzzle-flash cleanup.
- Rare configurable loot, centralized logs, and an opt-in right-click weapon test kit.
- Install-only packager, missing-asset checks, log capture and regression tests using the game's Kahlua runtime.

These changes pass automated checks, **not a new integrated game playtest**. Model scale/attachments, firing/reloading/damage, atmosphere appearance, save/reload and performance remain unproven. Hunters, aircraft, debris placement, custom audio and plasma tracers are not implemented.

## Install and test

Use the generated ZIP: extract its `project-term-mod-pack` folder under `C:/Users/<you>/Zomboid/mods/`. It must contain both `42/` and `common/`. Enable **Project Term Mod Pack** for a disposable single-player save. Disable the older **ProjectTermModPackB42** atmosphere mod and duplicate copies of this mod before testing.

In Custom Sandbox, use the PROJECT TERM settings page. Enable **Debug** to expose **Project Term: give weapon test kit** in the world right-click menu. The kit supplies one rifle, one empty cell and 48 charges; load charges into the cell and insert it into the rifle. F8 toggles atmosphere. Allow around 18 in-game minutes for the ON transition; verify indoors/outdoors and natural weather.

Follow [the test plan](docs/TEST_PLAN.md), capture logs with `python tools/capture_log.py`, and stop acceptance on mod errors or repeated spam. Logs remain local.

## Build from source

The Git repository contains scripts and model declarations, **not the prepared binary assets**. Put exported `models_X/` and `textures/` under `assets/prepared/`, or supply a directory with those two children:

```text
python tools/package.py --assets path/to/prepared --output dist/ProjectTermModPack-0.2.0.zip
```

Packaging checks all declared mesh/texture paths, excludes source/tools/docs, tests ZIP integrity and writes a SHA-256 manifest. It refuses a clean clone with missing exports. The local candidate uses exports recovered from the existing test installation; original GLBs remain unavailable. Public distribution rights and game loading remain separate gates.

See [API findings](docs/API_FINDINGS.md), [milestones](docs/MILESTONES.md), [asset pipeline](docs/ASSET_PIPELINE.md) and [checklist](CHECKLIST.md). Earlier/later game versions are unverified.
