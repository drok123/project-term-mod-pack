# 0.4.2 consolidation and repair

Based on the user's latest `codex/b42-mod-menu-foundation` branch at `4d6602c`, not a rollback to the older 0.3.0 branch. The installed 0.4.1 scripts were inspected and snapshotted locally before integration. Mod ID **ProjectTermModPackB42**, public `ProjectTerm.toggleAtmosphere()` and the single-player right-click kit are retained. Existing saves can enable additional test controls directly from the right-click menu.

## Fixed regressions

- Latest console again throws `expected argument of type String, got ItemKey` from the ammo registry. Restore installed-build-verified `AmmoType.register("projectterm:arc_charge", "ProjectTerm.ArcCharge")`.
- Remove the missing `GunStoreAmmo` loot target and restore idempotent, configurable loot insertion.
- Restore vanilla-verified rifle animation/firearm classification and shot-event flash cleanup.
- Eliminate conflicting/stale version messages; use one shared version source.
- Reconcile atmosphere into **one** controller at the latest `PTMP_Atmosphere.lua` path. Keep the same haze/tint strength; preserve immediate comparisons, preview controls, ownership protection, clock reset and menu cleanup.
- Restore tested prop and ambience controls that were absent from the newer branch. Missing audio now produces one actionable warning rather than throwing a Lua error inside pcall.

## Weapon assets

The earlier Arc Pulse export has 17,856 triangles and 15,368 open edges after positional seam welding. The supplied new Arc Pulse GLB has 56,094 triangles, 35,409 vertices and no open/nonmanifold edges. The new exporter retains all faces and vertices, preserves UVs and decoded base-color pixels, and transforms position/normal/winding consistently.

All three supplied weapons were rebuilt: Arc Pulse **56,094**, Iron Viper **72,076**, Ironstorm **76,840** triangles. Their source SHA-256 hashes and exact transforms are recorded in `weapon-export-manifests.json`. No decimation or selective face deletion is used. Original GLBs remain local source inputs.

The Arc Pulse's 1.90-unit raw length was about 3.5 times the installed vanilla M16's 0.546-unit length. It now uses a 0.55-unit mesh, correct barrel/height axes and a provisional pistol-grip pivot with model scale **1.0**, preventing the newer branch's 0.285 scale from shrinking it twice. Muzzle/world attachment entries follow installed vanilla script conventions. Grip alignment still needs a held/aiming screenshot in-game.

UV evidence: the installed X importer and `ImportedStaticMesh` conversion each flip V once. Keeping source UVs in the X file therefore avoids the old export's extra flip. See [Assimp's X importer](https://github.com/assimp/assimp/blob/master/code/AssetLib/X/XFileImporter.cpp); local installed-class inspection is the build-specific evidence.

The game-native Jassimp importer loads all three exports with the original vertex/triangle counts. This proves native import, not final hand placement, firing or frame rate.

## Installation gap

The previously tested installed folder lacked `42/media/sound/ProjectTerm/distant_machine.wav`, although the generated test ZIP contained it. The ZIP is the playable deliverable; a Git source download alone omits locally staged model assets and generated audio. `tools/verify_install.py` compares the installed folder against the package SHA-256 manifest to catch missing or mismatched files.

## Hunter review

The separate hunter branch is not merged blindly: it lacks an enforced SP guard, bounded safe debug placement and owning-cell/menu light cleanup, and scans all loaded zombies repeatedly. A red ground light is not verified head-tracked eyes. The next hunter slice should be opt-in, one safe debug spawn, bounded updates and explicit save/load/death tests before automatic population changes.

## Validation scope

Six game-Kahlua suites, current Build 42 layout/translation checks, exact source-to-export geometry/texture checks, native Jassimp import, package reference checks and ZIP integrity. The haze parameters are unchanged. In-game grip alignment, weapon fire/reload, audio attenuation and performance remain acceptance gates.
