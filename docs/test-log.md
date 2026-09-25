# In-game gate log

## Gate 1 — mod appears and loads

- Status: **partial game proof; explicit Mods-menu screenshot and repeat checks pending**
- Exact game version observed: **42.20.4 b0bbce05d5**, as shown on the main menu and `console.txt` (`version=42.20.4 b0bbce05d5 demo=false`).
- Mode: single-player loaded; multiplayer untested
- Mods-menu screenshot: pending
- Save loads into the world: **yes**. The supplied paused night screenshot shows the character inside a furnished house.
- Same save reloads: pending
- Existing save behavior: pending
- `console.txt` reviewed: **yes**, one provided capture. It logs `loading ProjectTermModPackB42`, four atmosphere values at 1/true, `[PROJECT TERM] Atmosphere climate layer active`, and `[PROJECT TERM] v0.3.0 client Lua loaded` once per observed load.
- Mod-specific load exception or repeated `[PROJECT TERM]` spam: **none seen** in the supplied capture. The log also contains `FluidContainerScript`, recipe, map metaID, and other game warnings/errors; their cause is unconfirmed and they should not be recorded as a clean whole-game log.
- Tester/date/hardware and performance notes: pending
- Screenshots received: main menu with version and paused night gameplay; earlier startup warning image did not contain version information. No Mods-menu screenshot yet.
- Additional screenshot received: paused daylight outdoor field on 42.20.4 b0bbce05d5, with a character near a tree, shrubs, grass, and a clear nearby path. The FPS overlay reads 75 while paused, so it is not a gameplay performance measurement. No same-location mod-off baseline, v0.3.2 startup log, or visible sandbox settings accompany this frame. The color tint and strength of the climate effect cannot be attributed from this image alone; the environment still appears mostly green and intact.
- Second outdoor screenshot received: paused scene on 42.20.4 b0bbce05d5, with dense gray fog at the edges, a very dark area around the character, and an open corpse inventory panel. The close character and corpse are difficult to distinguish. The location, time of day, weather, and F8 state are not identified, and it is not a registered same-place/same-time A/B pair with the prior daylight frame. Do not attribute the fog or dark pocket to this mod without the matching toggle log and baseline. The overlay reads about 74–75 FPS while paused and is not a gameplay performance result.
- Third outdoor screenshot received about two minutes later: the same paused, foggy corpse scene at 2048×1152. It is a useful fixed-camera companion to the second screenshot, but neither frame identifies which is F8 ON. The central scene averages differ by less than one RGB level out of 255, while the pixel-by-pixel differences mostly reflect shifting fog/UI. There is no convincing visual climate A/B transition in this pair. Check for `[PROJECT TERM] Atmosphere comparison: OFF` and `ON` in a fresh `console.txt`; the comparison key is disabled by default unless explicitly enabled on a new sandbox save. Do not mark the toggle or visual gate verified from these screenshots.

The later main-menu and paused gameplay screenshots, together with `console.txt`, establish that the game detects and runs the mod on the build above. They do not prove appearance in the Mods menu, in-game visual effect size, weather transitions, or save reload behavior.

## Gate 2 — API findings and atmosphere

Source candidate prepared; blocked by Gate 1 for in-game acceptance. Record API observations from the installed build and attach day/night, interior/exterior, rain, and weather-transition evidence. Test disabling and reloading for a clean vanilla look. Check nearby visibility, interior legibility, and `console.txt` for repeated errors. The implementation uses climate float IDs and overrides listed in the [current public API](https://projectzomboid.com/modding/zombie/iso/weather/ClimateManager.html) and [ClimateFloat methods](https://projectzomboid.com/modding/zombie/iso/weather/ClimateManager.ClimateFloat.html); their behavior in the installed Build 42 patch is unproven.

Sandbox controls added in 0.3.0; verify the PROJECT TERM page appears on new custom sandbox setup, that 0 haze preserves naturally occurring fog, that 0 darkness preserves vanilla lighting, and that disabling atmosphere releases overrides.

Version 0.3.1 adds an opt-in F8 comparison key. The Lua mock confirms releasing and reapplying owned climate overrides, but key delivery and the resulting visual transition are untested in game.

Version 0.3.2 adds an adjustable cold blue-gray global light tint. The official API documents `ClimateManager.COLOR_GLOBAL_LIGHT`, `ClimateManager:getClimateColor`, `ClimateColor:getInternalValue`/`setOverride`/`setEnableOverride`, and `ClimateColorInfo` exterior/interior colors. Their Lua binding and appearance in **42.20.4** are unverified. The mock checks intended channel calls and graceful fallback; game evidence is still required. The previous version 0.3.1 load does not verify 0.3.2.

The tester reports that the PROJECT TERM page is **absent from the sandbox options they inspected**. We do not yet know whether those are a new Custom Sandbox game's options with the mod enabled globally, or an existing save's settings. The `42/media/sandbox-options.txt` and `Sandbox_EN.txt` format matches the bundled B42 Woodcutting reference; static format alone does not prove registration in 42.20.4. This fails the sandbox UI gate. Version 0.3.3 makes F8 independent of the missing page to unblock the A/B test, but its key delivery still needs a fresh `console.txt`. Check an unpaused in-game press for `Atmosphere comparison: OFF` / `ON`, then capture the same-location views. Test the actual page separately from the **main menu → new game → Custom Sandbox** after the mod is globally enabled; an existing save's sandbox settings are not enough to establish whether the page registers at world creation.

First observed runtime data: `AtmosphereEnabled true`, `AtmosphereIntensity 1.0`, `HazeDensity 1.0`, `Darkness 1.0` in `console.txt`. This proves option values reached the game, but the options page itself has not been screenshotted. A paused night screenshot shows a lit interior and dark exterior; no baseline screenshot was provided, so the mod's visual contribution is unmeasured.
