# Changelog

## 0.2.0 - 2026-09-26 (candidate)

- Fixed the observed B42 ammo registry load exception and firearm classification/animation fields.
- Integrated prior local atmosphere, cold tint, sandbox controls and F8 comparison; added clock-rewind and menu cleanup.
- Corrected muzzle-flash event timing, final-round handling and owning-cell cleanup.
- Added opt-in debug weapon kit, loot multipliers, idempotent loot injection and shared logging.
- Added Kahlua regression harness, install-only asset-validated packaging, log capture and milestone/API/test records.
- Single-player 42.20.4 target; new integrated game acceptance still pending.


## 0.1.0 - 2026-09-25

- Added Build 42 mod structure and manifest.
- Added required `common/` directory.
- Added prepared model declarations for 12 machine/weapon assets.
- Added Arc Pulse Rifle prototype.
- Replaced temporary vanilla 5.56 dependency with registered custom Arc Charge ammo and Arc Energy Cell magazine.
- Added rare world-loot injection for the rifle, cells, and charges with guarded B42 procedural-distribution hooks.
- Added a short client-side violet muzzle-light flash using the weapon swing event.
- Added asset-pipeline documentation and Blender FBX export helper.
