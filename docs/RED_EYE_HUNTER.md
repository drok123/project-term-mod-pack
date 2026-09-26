# Red-Eye Ground Hunter — Milestone 1 Slice 1

Target: Project Zomboid Build 42.20.x, single-player prototype.

## Implemented approach

Hunters are tagged vanilla `IsoZombie` actors. Static Meshy endoskeleton assets are
not used as animated actors.

- `Events.OnZombieCreate` clears `modData.ProjectTerm` on every invocation before
  applying a new roll. This is required because B42 pools and reuses `IsoZombie`
  instances.
- `ProjectTerm.HuntersEnabled` gates selection and `HunterChance` is a percentage
  roll (3% by default).
- Selected zombies receive `ProjectTerm.isHunter`, optics, generation, difficulty,
  and health-baseline fields in mod data.
- Difficulty adds 15%, 30%, or 50% to the zombie's initialized health. It does not
  alter speed, damage, cognition, or knockdown behavior.
- The prototype leaves the vanilla outfit intact. Replacing it without a verified
  named-outfit pipeline risks broken or inappropriate zombie visuals.

Hunter identity is session-local. B42 does not expose a proven stable zombie ID
across unload/reload, so a reused or reloaded zombie is cleared and rolled again.

## Optics fallback

The shipped optic is a client-side `IsoLightSource` with color
`1.0, 0.03, 0.03` and radius 2. The client checks the currently loaded cell every
20 ticks, sorts living tagged hunters by distance to the local player, and gives
lights only to the nearest `MaxActiveHunterLights` hunters (10 by default).

Lights are removed and recreated when their hunter changes square. They are also
removed on death, pooled reuse, unload detection, master/optics disable, cap
eviction, and game start. The implementation deliberately uses
`addLamppost`/`removeLamppost`, not `setActive`.

There is no full-world or per-frame zombie scan. B42 has no documented
zombie-unload Lua event, so the periodic loaded-cell pass is also the unload
cleanup mechanism.

An emissive eye/face overlay is not included: emissive material behavior and an
original two-eye visual have not yet been proven in 42.20.x. The fallback is a
small red illumination, not literal head-tracked twin eye pixels.

## Sandbox options

All options are on the `ProjectTerm` page and are nil-safe in Lua:

| Option | Default | Range / values |
|---|---:|---|
| `HuntersEnabled` | true | boolean |
| `HunterChance` | 3.0 | 0–100 percent |
| `HunterDifficulty` | Normal | Easy / Normal / Brutal |
| `RedOpticsEnabled` | true | boolean |
| `MaxActiveHunterLights` | 10 | 0–32 |

Sandbox values are expected to be chosen when creating a world. The optics
toggle and cap are read live by the periodic client update, but live editing is
only a test convenience and is not a supported settings workflow.

## Debug helper

Launch with `-debug`, load a single-player test world, and run this in the Lua
console:

```lua
ProjectTerm.SpawnHunter()
```

It creates one vanilla zombie three tiles east of the local player, force-tags
it as a hunter, and logs the result with `[ProjectTerm]`. It refuses to run when
debug mode is disabled.

## 42.20.x single-player test

1. Enable the mod and create a fresh custom-sandbox save.
2. Set Hunter Chance to 100 temporarily and Maximum Active Hunter Lights to 2.
3. Confirm `[ProjectTerm] hunter spawn hooks installed` and the optics init log.
4. Load several zombies. Confirm only two nearest living hunters have red light.
5. Kill a lit hunter and confirm its light disappears and transfers to the next
   nearest hunter.
6. Move far enough to unload hunters, return, and check for orphan lights.
7. Disable Red Optics in a debug test and confirm lights are removed on the next
   update.
8. Run `ProjectTerm.SpawnHunter()` and confirm the forced-spawn log.
9. Repeat with the master toggle off and verify ordinary creates are explicitly
   cleared rather than retaining hunter state.

## Known limitations / follow-up

- In-game execution is still required; this repository has no B42 runtime.
- Single-player only is claimed. Multiplayer authority and mod-data sync are
  unproven.
- Stable identity/save persistence, emissive twin-eye visuals, a dark custom
  outfit, stagger resistance, servo audio, damaged optics, and machine-specific
  loot are follow-up work.
- No climate, haze, atmosphere, weather, HK flyover, tracer, impact, or plasma
  audio behavior is part of this slice.
