# Project Term Mod Pack

A draft Project Zomboid Build 42 future-war prototype combining a
machine-occupied wasteland, an Arc Pulse Rifle test slice, and an experimental
single-player atmosphere layer.

## Current status

Staged for testing:

- Build 42 `42/` and `common/` layout
- Arc Pulse Rifle, Arc Energy Cell, Arc Charge, rare loot hooks, and a brief
  violet muzzle-light effect
- machine and weapon model declarations plus the Blender/FBX workflow
- configurable haze, darkness, desaturation, and cold tint in single-player
- F8 atmosphere on/off comparison
- static layout, Lua mock, and packaging gates

The 0.2.1 defaults make the exterior grade strongest at night: deeper
blue-black light, blue/gray desaturation, and thin dirty distance haze. Daytime
uses a restrained fraction of that grade, and interiors receive a much weaker
tint so nearby rooms should remain legible. These are tuning intentions, not
in-game proof.

This remains a draft. The atmosphere deliberately releases its climate
overrides in multiplayer. Controlled same-place day/night F8 A/B captures,
interior/rain checks, and a combined-package PROJECT TERM sandbox label
screenshot are still pending. Models, attachments, weapon behavior, weather
transitions, reloads, performance, and compatibility also need in-game
verification.

## Install for local testing

Clone or copy the repository to:

`C:/Users/<you>/Zomboid/mods/project-term-mod-pack/`

The resulting manifest must be exactly:

`C:/Users/<you>/Zomboid/mods/project-term-mod-pack/42/mod.info`

Keep the sibling `common/` directory, enable **Project Term Mod Pack** in the
Mods menu, and activate it for the test save.

## Atmosphere test

1. Start Project Zomboid Build 42.20+ and create a single-player Custom
   Sandbox test save.
2. Set the PROJECT TERM atmosphere options as desired.
3. Check `console.txt` for both `[PROJECT TERM] v0.2.1 client Lua loaded` and
   `[PROJECT TERM] Atmosphere climate layer active (single-player experimental).`
4. Press F8 and confirm `[PROJECT TERM] Atmosphere comparison: OFF` or `ON`.
5. At one fixed outdoor camera, capture F8 OFF and ON after each transition
   settles; repeat at day and night and record time, weather, and F8 state.
6. Repeat the settled F8 comparison indoors and during rain. Confirm nearby
   rooms remain usable and natural heavy weather is not flattened.
7. From a new Custom Sandbox setup, capture the PROJECT TERM page and confirm
   all five labels render instead of raw translation keys.

## Arc Pulse Rifle test

1. In a fresh debug/test save, add `ProjectTerm.ArcPulseRifle`,
   `ProjectTerm.ArcCell`, and `ProjectTerm.ArcCharge`.
2. Load Arc Charges into the Arc Energy Cell, insert the cell, then equip,
   fire, reload, and drop the rifle.
3. Confirm the brief violet muzzle-light flash and inspect `console.txt` for
   `[ProjectTerm]` messages plus script, model, ammo, and loot errors.

The rifle uses the custom ammo registry id `projectterm:arc_charge`. Its sounds
remain vanilla M16 placeholders pending custom plasma audio.

## Developer checks

```bash
python3 tools/validate_mod.py
python3 tools/check_lua.py
python3 tools/package.py
```

`package.py` writes an ignored candidate ZIP under `dist/`.

## Asset pipeline

See `docs/ASSET_PIPELINE.md`.

## Compatibility

Target baseline: Project Zomboid Build 42.20.x. Other B42 versions are
unverified.
