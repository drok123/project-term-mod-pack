# Changelog

## 0.2.1 - 2026-09-26

- Strengthened the default Future War grade with deeper blue-black night
  exteriors, greater blue/gray desaturation, and slightly dirtier distant haze.
- Made tint, dimming, cloud, and haze strength follow natural daylight so the
  effect is strongest at night without turning daytime into a whiteout.
- Kept the interior color shift deliberately weaker than the exterior grade.
- Extended the Lua mock to check restrained daytime color, stronger night-blue
  color, interior legibility, and the existing clean-release controls.
- Added conditional packaging, sandbox-label, and Lua syntax gates for the
  separately developed Red-Eye Hunter file set.
- In-game day/night, interior/rain, and combined-package sandbox label proof
  remains pending.

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
