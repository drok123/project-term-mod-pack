# Changelog

## 0.1.x - Unreleased

- Added the single-player red-eye hunter prototype using tagged, pooled vanilla zombies.
- Added nil-safe hunter sandbox controls for spawn chance, difficulty, optics, and light cap.
- Added capped nearest-hunter red fallback lights with death, reuse, disable, and unload cleanup.
- Added a `-debug`-gated `ProjectTerm.SpawnHunter()` helper and implementation/test notes.

## 0.1.0 - 2026-09-25

- Added Build 42 mod structure and manifest.
- Added required `common/` directory.
- Added prepared model declarations for 12 machine/weapon assets.
- Added Arc Pulse Rifle prototype.
- Replaced temporary vanilla 5.56 dependency with registered custom Arc Charge ammo and Arc Energy Cell magazine.
- Added rare world-loot injection for the rifle, cells, and charges with guarded B42 procedural-distribution hooks.
- Added a short client-side violet muzzle-light flash using the weapon swing event.
- Added asset-pipeline documentation and Blender FBX export helper.
