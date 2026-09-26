# project-term-mod-pack â€” Build 42 development checklist

> **Project brief:** Turn Project Zomboid Build 42 into a machine-occupied future wasteland years after nuclear destruction: old ruins, survivors in the rubble, oppressive smoke, red-eyed hunters, flying patrol craft, and scarce plasma weapons. The visual reference is dark, dirty 1980s future-war horror. Build an original identity and assets for public distribution.

## Current pass â€” 2026-09-26

0.3.0 candidate: actual installed build **42.20.4 b0bbce05d5**, **single-player first**. See `docs/MILESTONES.md`, `docs/API_FINDINGS.md`, and `docs/TEST_PLAN.md`. `[x]` means the stated repository task is done; `[~]` means implemented or partly verified, with game acceptance outstanding. User tested 0.2.0: load and F8 OFF events passed with no ProjectTerm exceptions; visual change was weak. New 0.3.0 visual/prop/audio acceptance is pending; see `docs/PLAYTEST_0.2.0.md` and `docs/TEST_0.3.0.md`.

## 0. Start here

- [x] Record exact inspected build and target: **42.20.4 b0bbce05d5, single-player**. User 0.2.0 run reviewed; 0.3.0 acceptance pending.
- [x] Add a Build 42 mod manifest and folder layout based on a known working B42 example. **In-game Mods-menu verification still pending.**
- [x] Keep installable game files separate from source assets, documentation, and helper tools. **Packager whitelists 42/common plus staged exports; source area and asset checks added.**
- [x] Add a README with install path, dev workflow, supported game version, controls, known issues, and test instructions.
- [x] Add a changelog, `.gitignore`, and a short milestone log.
- [~] Capture `console.txt` for every test; **snapshot tool added and prior failing log captured; future runs still required.** stop on load errors or repeated log spam.
- [ ] Verify the APIs and asset formats against the actual installed B42 build before relying on them. A helicopter-event position, emissive material, dynamic light cone, or live world-model hook is a research question until proven in-game.

Suggested repository layout (adjust the installable folder names to the tested B42 structure):

```text
project-term-mod-pack/
  README.md
  CHECKLIST.md
  CHANGELOG.md
  docs/                 # design, API findings, tests
  assets/source/        # Blender, source textures, source audio
  mod/                  # installable B42 mod tree
  tools/                # exporters, validators, debug helpers
```

**Fast path:** get a mod-menu entry, then a visible atmosphere change, then one prop, one red-eye threat, one visible aircraft, and one working energy weapon. Keep each experiment playable and logged.

## 1. Art direction and world rules

- [ ] Set the world **years after the bombs**: settled rubble, soot, rust, weathering, dead vegetation, skeletonized remains, scavenged interiors, and improvised human shelter.
- [ ] Layer active machine occupation over old destruction: patrol marks, precision burns, broken machines, cables, red sensors, searchlights, and occasional fresh combat damage.
- [ ] Keep cold blue-black ambient tones, murky smoke/ash haze, sparse hard white searchlights, tiny red optics, and brief purple/red plasma flashes.
- [ ] Make the player feel isolated and hunted. Use quiet stretches between distant turbine, metal, and plasma sounds.
- [ ] Avoid pristine sci-fi, uniformly fresh fires/corpses, constant whiteout fog, oversized red glow, and every street being equally destroyed.
- [ ] Use the four supplied future-war references as mood targets; keep source artwork out of the repository unless its use is authorized.

## 2. First playable atmosphere

- [x] Inspect installed B42 climate float/color APIs and document exposed hooks. **Installed JAR reflection and vanilla Lua inspected; visual acceptance remains separate.**
- [~] Add a persistent *smoky* baseline haze, with occasional denser periods, while keeping nearby streets navigable.
- [~] Tune darkness/desaturation and cold tint. **Prior local implementation integrated, mocked behavior passes; interior visibility and visual tuning pending.**
- [ ] Test day/night, indoors/outdoors, rain and weather transitions; make settings reversible on mod disable.
- [ ] Add lightweight ash or soot detail only where the engine can support it without excessive per-frame work.
- [ ] Add rare distant red illumination and brief machine-related light cues where technically feasible.
- [~] Add restrained positional ambience: **original turbine cue, sparse SP scheduler, preview/stop and audio controls staged; attenuation game test and other sound families pending.** wind over ruins, distant turbines, servo/metal movement, electrical hum, far-off gunfire or plasma, and explosions.
- [~] Expose sandbox settings. **Atmosphere, intensity, haze, darkness, cold tint, ambience enable/frequency implemented; ash pending.**
- [~] Add debug controls: **F8 on/off, immediate haze/night-lighting previews, status output, ambience preview/stop implemented. True clock/night simulation is not claimed.**

**Visual acceptance:** the world remains recognizable up close; distant streets and rooftops recede into dirty darkness. Nights feel dangerous and interiors remain usable.

## 3. Ruin and bone set dressing

- [~] Prove one skull/bone prop and one wreck/debris prop. **Debug-only vanilla cow skull plus inert Sentinel chassis implemented; rendering/scale/persistence playtest pending.**
- [ ] Build reusable aged sets: bones and skull piles; burnt cars, trucks, and military wrecks; concrete, rebar, beams, fences, sandbags, craters, scorch marks, utility poles, streetlights, scrap, and destroyed machine parts.
- [ ] Add survivor evidence: scavenged shelters, camps, barricades, bunkers, warning signs, caches, damaged radios, and destroyed hideouts.
- [ ] Test spawn placement around roads, buildings, collision, pathing, and save/reload. Avoid blocking critical routes.
- [~] Favor bounded placement. **Prop proof checks four adjacent tiles, caps one pair per save and cleans tagged items only; authored world zones pending.**
- [ ] Keep vanilla geography recognizable beneath the decay. Prototype a few future-war pockets before attempting map-wide destruction.
- [ ] Later: ruined industrial districts, highways, Louisville sectors, machine control zones, bone fields, and resistance areas.

## 4. Red-eye ground hunters

- [ ] Prototype one threat using an existing humanoid system; verify spawn, movement, damage, death, save/load, and cleanup.
- [ ] Give it small red optics, distinct metal/servo audio, extra durability, restrained stagger, and a recognizable silhouette.
- [ ] Verify whether actual emissive eye textures work in the tested B42 renderer; otherwise prototype a cheap visual fallback.
- [ ] Scale eye visibility with range and fog; move the eyes with the head, extinguish on death, and allow damaged one-eye/flicker variants later.
- [ ] Advance to original skeletal machine models, walk/run/scan animations, damage states, sparks, and possibly a crawling state only after the first threat works.
- [ ] Later: human-looking infiltrators with damage revealing machinery, rare reveal events, and stronger perception.
- [ ] Add sandbox controls for spawn frequency and difficulty plus debug spawn/glow toggles.

**Horror acceptance:** two faint red points appear in the haze before the enemy body is clear.

## 5. Flying patrol craft

- [ ] Investigate the vanilla helicopter event implementation in the *installed* B42 build. Document whether its path/coordinates are available to Lua, Java hooks, or neither.
- [ ] Create a moving visible placeholder first, separate from the vanilla event if necessary. Test draw order, altitude illusion, occlusion, multiplayer implications, and cleanup.
- [ ] If coordinates are accessible, follow the event safely; otherwise give the craft an independent scripted flyover path. Do not claim vanilla-event tracking until demonstrated.
- [ ] Add heading/bank changes, looping turbine animation, distant engine audio, red sensors, hard white searchlight, and fade/occlusion in fog.
- [ ] Shape the craft as a low, wide predatory industrial VTOL silhouette with turbines and underslung sensors; no visible helicopter rotor.
- [ ] Limit concurrent craft and dynamic lights. Add debug flyover, path display, position logging, and forced despawn.
- [ ] Later: sweeping or reactive lights, zombie migration, machine patrol zones, distant strafing/plasma and explosions, wrecks, and resistance anti-air fire.

**Aircraft acceptance:** at night the player can see a moving silhouette or searchlight through the haze; it enters, traverses, and leaves the area without leaving an active entity behind.

## 6. Energy weapon prototype

- [~] Make one original plasma rifle, one rare energy-cell ammo type, and a working fire/reload/damage loop. **Arc Pulse Rifle + registered Arc Charge + Arc Energy Cell are implemented; in-game fire/reload validation pending.**
- [~] Add a bright but brief muzzle effect, purple/red streak or feasible beam illusion, impact flash, sparks, smoke, and punchy industrial audio. **Brief violet muzzle-light flash implemented; tracer/impact/sparks/smoke/custom audio pending.**
- [~] Keep damage high and ammo scarce; make firing conspicuous to nearby threats if the engine permits. **High-damage/rare-loot tuning and loud firearm radius are staged; gameplay balance pending.**
- [ ] Verify inventory behavior, save/load, sound range, collisions, and performance. **Drop-in test build generated 2026-09-26 for this pass.**
- [ ] Later: heat, maintenance, pistol, carbine, heavy model, resistance-built model, and machine-only variants.
- [~] Add debug controls. **Opt-in single-player right-click weapon kit implemented and tested in Kahlua; standalone effect spawn pending.**

## 7. Searchlights and audio

- [ ] Prototype one sweep and measure its cost and visibility in haze; use a visual approximation if true volumetric cones are unavailable.
- [ ] Attach to the craft only after the standalone sweep works; later use at machine bases.
- [ ] Keep beam motion smooth, brightness controlled, and activation intermittent.
- [ ] Add separate ambience families for ruins, flying turbines, servo movement, damaged machinery, scanning, electrical arcing, and distant firefights.
- [ ] Check positional attenuation and silence between cues. Do not flood the mix.

## 8. Tools, settings, and performance

- [~] Centralize configuration and lightweight logging. **Shared config/logger, deduplicated warnings and debug setting added.** Add a debug mode with spawn counts, craft positions, update costs, and event/path traces.
- [ ] Debug actions: force fog/night; toggle atmosphere, eyes, and searchlight; spawn hunter, craft, prop set, or weapon; trigger flyover; reload config where safe.
- [ ] Sandbox controls: atmosphere, fog, ash, darkness, machine density/difficulty, aircraft frequency, weapon and resistance loot rarity, prop density, audio frequency, and machine-zone density.
- [ ] Plan presets: cinematic, survival, brutal, atmosphere only, machines only.
- [ ] Avoid full-world or per-zombie scans every frame. Bound active entities, effects, and lights; despawn outside useful range.
- [ ] Prefer static wreckage and LOD/simpler distant craft. Profile Louisville, rural zones, high zombie density, night, and heavy fog.

## 9. Asset pipeline

- [~] Establish Blender export, game-ready model/animation formats, coordinates, scale, texture/material conventions, collision, and LOD from a real B42 loading test. **Static-mesh prep/export pipeline exists; real B42 load/scale/attachment test still pending.**
- [~] Separate `assets/source/` from installable exported assets; document naming and export commands. **Source area, deterministic original audio generator and export staging separated; packager validates and overlays exports. Local binaries are not committed; clean clones need exports.**
- [ ] Determine what eye emissive/glow and dynamic light methods the renderer actually supports.
- [ ] Asset priority: simple red-eye prototype â†’ flying placeholder â†’ ground machine â†’ polished craft â†’ damage variants â†’ resistance props â†’ heavy machines.
- [ ] Use original models, textures, names, logos, and sounds for a public release; do not include ripped film assets.

## 10. Implementation order and gates

1. [~] Repository skeleton, README, and manifest are in place; **in-game mod-menu proof pending.**
2. [~] Shared logging, F8/debug kit controls and exact-version/API notes implemented; integrated in-game gate pending.
3. [~] Dark lighting and controllable haze integrated and Kahlua tested; interior/weather visual checks pending.
4. [~] Sandbox settings and one machine ambience cue implemented; in-game attenuation pending.
5. [~] Skull/chassis debug placement and bounded cleanup implemented; in-game rendering/save proof pending.
6. [ ] Red-eye humanoid prototype, damage/death/cleanup, and audio.
7. [ ] Investigate helicopter event; visible moving craft placeholder.
8. [ ] Add craft silhouette, turbine, fog behavior, and measured searchlight.
9. [~] Arc Pulse Rifle uses registered custom Arc Charge/cell; observed registry exception fixed and brief muzzle flash regression-tested. **In-game firing/reload, tracer/impact and custom audio pending.**
10. [ ] Integrate, profile, test save/reload, and package the first playable build.

**Every gate:** mod appears in the menu; new save loads without errors; check existing-save behavior; no runaway spawning or log spam; performance remains acceptable; document single-player/multiplayer support accurately.

## Milestone 1 definition of done

- [ ] B42 loads a night scene with dark blue-black atmosphere and persistent dirty haze that remains playable.
- [ ] Aged bones and wreckage appear in sensible locations.
- [ ] Restrained machine ambience plays and attenuates correctly.
- [ ] At least one occasional red-eyed enemy works end to end.
- [ ] One visible HK-inspired flying test craft crosses the area and cleans itself up.
- [ ] One prototype plasma rifle fires and damages correctly.
- [ ] Sandbox controls and debug triggers work.
- [ ] No major errors, runaway spawns, or severe performance regressions in the tested scenarios.
- [ ] README states exactly what is proven, what is experimental, the supported B42 version, and how to install/test.

**Next milestone:** deepen machine AI and models, world zones, resistance gameplay, and aircraft behavior after this integrated slice is stable.
