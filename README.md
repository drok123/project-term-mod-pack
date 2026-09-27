# PROJECT TERM — Future War

Build 42 **single-player** prototype, version **0.4.2**, targeting **42.20.4 b0bbce05d5**. This integrates the latest 0.4.1 work with the tested weapon, atmosphere, prop and audio fixes. Mod ID remains **ProjectTermModPackB42**.

The haze settings are unchanged. F8 or the right-click atmosphere action applies the comparison immediately. The right-click rifle kit remains available on existing single-player saves. Choose **Enable extra test controls**, then right-click again for haze/night previews, skull/chassis placement and cleanup, and positional ambience playback/stop. Sandbox Debug also enables those controls.

## Install the playable build

Exit the game and extract the complete ZIP's `project-term-mod-pack` folder under `Zomboid/mods`. Keep `42/` and `common/` directly inside that folder. Enable only one Project Term installation; the older `ProjectTermModPack` mod ID should be disabled when using this build. Do not copy just the Lua files: models, textures and `42/media/sound/ProjectTerm/distant_machine.wav` are required.

**A Git checkout is source, not a complete install.** Large prepared model exports remain local build inputs. Git LFS rules are retained, but configured LFS alone does not upload missing assets. `tools/package.py` refuses missing model/texture/sound references and unresolved LFS pointer files.

## Current features and proof

- Controllable haze/tint/dimming, safe override release and instant F8 comparison; the user liked the haze in the prior playtest.
- Arc Pulse Rifle with custom Arc Charge/cell, corrected registry and firearm animation metadata. Rebuilt Arc Pulse/Iron Viper/Ironstorm exports retain every source face, UV and texture pixel; only the Arc Pulse currently has gameplay.
- Bounded shot flash, configurable idempotent loot, one debug skull/chassis pair and original positional machine ambience.
- Six game-Kahlua regression suites and native game-model importer checks pass. These are not a new full game playtest. Final hand alignment, reload/damage, audio attenuation and active-play performance remain to be checked.
- No active hunter or aircraft is integrated. Review findings and next hunter gates are in [the repair report](docs/REVIEW_0.4.2.md).

## Build and validate

Put exports under `assets/prepared/models_X` and `assets/prepared/textures`, or pass `--assets`. Packaging generates the original machine cue from Python source and writes a SHA-256 manifest beside the ZIP.

```text
python tools/validate_mod.py
python tools/check_all.py --game "path/to/ProjectZomboid" --javac "path/to/javac"
python tools/package.py --assets assets/prepared --output dist/ProjectTermModPack-0.4.2.zip
python tools/verify_install.py dist/ProjectTermModPack-0.4.2.manifest.json --mod-dir "path/to/Zomboid/mods/project-term-mod-pack"
```

`tools/weapon_mesh.py` rebuilds a supplied static weapon GLB without deleting faces. It needs Pillow only when converting embedded JPEG to lossless PNG. `tools/check_weapon_exports.py` verifies topology, transforms, UVs, normals and decoded image pixels against the source GLBs. Source hashes and exact transforms are recorded in `docs/weapon-export-manifests.json`. The original GLBs are preserved locally, not replaced by exports.

Follow [the quick test](docs/TEST_0.4.2.md) and capture each new console with `python tools/capture_log.py`. Logs and work files are kept local.
