# Changelog

## 0.2.0 - 2026-09-26

- Added the experimental single-player atmosphere layer with configurable
  intensity, haze, darkness, and cold tint.
- Added an F8 runtime comparison that releases and restores owned climate
  overrides.
- Added Build 42 sandbox labels and options.
- Added static layout, Lua mock, and installable ZIP gates covering both the
  atmosphere files and existing ProjectTerm Machines/Arc Pulse files.
- Added milestone and in-game gate notes while preserving the Arc Pulse Rifle,
  custom ammunition, FX, model declarations, and loot prototype.

## 0.1.0 - 2026-09-25

- Added Build 42 mod structure and manifest.
- Added required `common/` directory.
- Added prepared model declarations for 12 machine/weapon assets.
- Added Arc Pulse Rifle prototype.
- Replaced temporary vanilla 5.56 dependency with registered custom Arc Charge ammo and Arc Energy Cell magazine.
- Added rare world-loot injection for the rifle, cells, and charges with guarded B42 procedural-distribution hooks.
- Added a short client-side violet muzzle-light flash using the weapon swing event.
- Added asset-pipeline documentation and Blender FBX export helper.
