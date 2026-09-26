# Project Term Mod Pack

Single-player Build 42 future-war conversion prototype. Current candidate: **0.3.0**, inspected against **42.20.4 b0bbce05d5**. Multiplayer is unsupported for this milestone.

## Implemented candidate

- Integrated adjustable haze, darkness, desaturation and cold tint from the prior local atmosphere prototype; F8 toggles the layer for comparison.
- Arc Pulse Rifle, registered Arc Charge ammo and energy-cell magazine. Fixed the registry exception found in the actual game log; corrected rifle animation/classification and bounded muzzle-flash cleanup.
- Rare configurable loot, centralized logs, and an opt-in right-click weapon test kit.
- Immediate startup/F8 atmosphere, reversible haze/night-lighting previews and climate-value diagnostics.
- One persistent two-item skull/chassis prop test set, scoped cleanup, and rare positional machine ambience with preview/stop controls.
- Install-only packager, missing-asset checks, log capture and regression tests using the game's Kahlua runtime.

The user playtested 0.2.0: scripts loaded and F8 OFF worked without ProjectTerm exceptions, but the visual difference was weak. See [that result](docs/PLAYTEST_0.2.0.md). New 0.3.0 features pass automated checks and still need their own in-game acceptance. Model scale/attachments, firing/reloading/damage, atmosphere appearance, save/reload and performance remain unproven. Active hunters, aircraft, automatic debris placement and plasma tracers are not implemented. Debug-only skull/chassis placement and an original positional machine cue are now staged.

## Install and test

Use the generated ZIP: extract its `project-term-mod-pack` folder under `C:/Users/<you>/Zomboid/mods/`. It must contain both `42/` and `common/`. Enable **Project Term Mod Pack** for a disposable single-player save. Disable the older **ProjectTermModPackB42** atmosphere mod and duplicate copies of this mod before testing.

In Custom Sandbox, use the PROJECT TERM settings page. Enable **Debug** to expose **Project Term: give weapon test kit** in the world right-click menu. The kit supplies one rifle, one empty cell and 48 charges; load charges into the cell and insert it into the rifle. F8 toggles atmosphere. The ON comparison now applies immediately; later weather changes stay smooth. Debug right-click actions also preview atmosphere, place/clean test props and play/stop ambience. Follow [the 0.3.0 quick test](docs/TEST_0.3.0.md).

Follow [the test plan](docs/TEST_PLAN.md), capture logs with `python tools/capture_log.py`, and stop acceptance on mod errors or repeated spam. Logs remain local.

## Build from source

The Git repository contains scripts and model declarations, **not the prepared binary assets**. Put exported `models_X/` and `textures/` under `assets/prepared/`, or supply a directory with those two children:

```text
python tools/package.py --assets path/to/prepared --output dist/ProjectTermModPack-0.3.0.zip
```

Packaging generates the original machine WAV from its deterministic Python source, checks all declared mesh/texture/audio paths, excludes source/tools/docs, tests ZIP integrity and writes a SHA-256 manifest. It refuses a clean clone with missing exports. The local candidate uses exports recovered from the existing test installation; original GLBs remain unavailable. Public distribution rights and game loading remain separate gates.

See [API findings](docs/API_FINDINGS.md), [milestones](docs/MILESTONES.md), [asset pipeline](docs/ASSET_PIPELINE.md) and [checklist](CHECKLIST.md). Earlier/later game versions are unverified.
