# Project Term Mod Pack — prepared Meshy assets

This package stages the 12 supplied Meshy GLBs for Project Zomboid Build 42.

## Repository status (2026-09-26)

The Git tree has declarations only. The 12 previously prepared models and 36 textures were recovered locally from the existing test installation into ignored `assets/prepared/`. `tools/package.py` overlays that directory into installable `42/media/` and refuses unresolved declarations. Original GLBs, source hashes and preparation manifests are not in this checkout; the claims below describe the prior preparation notes, not independently repeated conversion work.

## Prior preparation notes
- Clean stable asset IDs (no timestamped Meshy names).
- Aggressively reduced static meshes for isometric/game use.
- Y-up source geometry converted to Z-up staging geometry.
- Base-color textures converted to PNG and capped at 1024x1024.
- Normal and metallic/roughness maps preserved alongside the base texture for later material work.
- Static DirectX `.x` meshes placed under `42/media/models_X/Terminator/`.
- PZ model declarations generated in `42/media/scripts/term_asset_models.txt`.
- OBJ+MTL staging copies included for Blender inspection or FBX conversion.
- Exact source hashes and triangle counts are recorded in the local prepared-asset package manifest.

## Important character note
Every supplied GLB had 0 skins and 0 animation tracks. The humanoid machine models are therefore ready as static props/corpses/display models, but not yet as animated enemies. They need to be retopologized/rigged to the skeleton/animation strategy chosen for the Terminator NPC system. Keep the original GLBs as source masters.

## Before declaring an asset final in-game
1. Load it in PZ and verify size/orientation. Adjust model-script `scale` first instead of destructively rescaling the source.
2. Check UV orientation. The generated `.x` writer flips V for DirectX convention; the OBJ staging copy keeps glTF UV convention.
3. For held weapons, create explicit hand attachment transforms in the item/weapon script.
4. For vehicles/fliers, split moving parts only when animation/gameplay needs them.
5. Humanoids must be rigged and animated before enabling them as AI actors.

## Suggested role mapping
- `arc_pulse_rifle`, `iron_viper`: infantry weapons
- `ironstorm_cannon`: heavy/static weapon
- `cybernetic_motorcycle`: ground vehicle/prop
- `iron_shadow_gunship`: aerial machine visual/animated-event candidate
- `terminator_endoskeleton`, `silver_sentinel`, `iron_reaper`, `steel_sentinel`, `rustborn_sentinel`: humanoid machine candidates (rig required)
- `ironclad_sentinel_a`, `ironclad_sentinel_b`: large machine/vehicle candidates; retained separately until gameplay roles are assigned

## Build 42 folder placement
The prepared package uses the Build 42 versioned mod layout under `42/media/...`.
