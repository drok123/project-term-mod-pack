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

## 0.3.3 in-game F8 evidence and 0.3.4 fix candidate

A new `console(1).txt` from **42.20.4 b0bbce05d5** shows `loading ProjectTermModPackB42`, five option values including `ColdTint 1.0`, the atmosphere startup message, and the exact `v0.3.3` startup message. F8 key presses were received: OFF at frame 553, ON at 781, OFF at 842, ON at 1021, and OFF at 1120. **F8 event delivery is verified on 0.3.3.** The log then contains **14 repeated exceptions** at `PTMP_Atmosphere.lua:137`, where the disabled-path `next(states)` tries to call a nil global in Build 42's Kahlua runtime. The OFF key handler had already called `release()`; the visual OFF result is still unverified. Other game warnings are present and are not attributed to this mod.

Version 0.3.4 removes the unsupported `next()` call and makes release idempotent on the minute timer. A Lua mock with `next = nil` passes; see the in-game rerun below. The earlier log proves five sandbox values loaded, **not** that the PROJECT TERM options page appeared.

## 0.3.4 F8 rerun on 42.20.4 b0bbce05d5

The supplied `console(2).txt` records `loading ProjectTermModPackB42`, `v0.3.4 client Lua loaded`, and the atmosphere startup message. All five variables appear at 1.0/true, including ColdTint. The log contains eight F8 toggle messages, alternating OFF/ON (frames 803, 872, 1187, 1233, 1265, 1281, 1293, 3138). There is **no** `PTMP_Atmosphere.lua` exception or repeated PROJECT TERM message after those presses. The previously observed disabled-path error is resolved in this run; **F8 runtime gate passed**. The log still has five preexisting-looking game data/map errors at startup and two unknown GLFW key messages after the last toggle; their relationship to this mod is not established. It also records `NightDarkness 3`, so the very dark screenshot cannot be attributed solely to the mod. Paired visuals, interior/rain tests, options-page visibility, and save reload remain pending.

First observed runtime data: `AtmosphereEnabled true`, `AtmosphereIntensity 1.0`, `HazeDensity 1.0`, `Darkness 1.0` in `console.txt`. This proves option values reached the game, but the options page itself has not been screenshotted. A paused night screenshot shows a lit interior and dark exterior; no baseline screenshot was provided, so the mod's visual contribution is unmeasured.

## Additional daylight image and console on 42.20.4 b0bbce05d5

The supplied `image(20260925-044449).png` shows a paused daytime residential street with dense, pale white fog. The player, nearby road, and house are visible. The on-screen FPS is measured while paused and does not establish active-play performance. The accompanying `console(3).txt` shows `v0.3.4 client Lua loaded` and an `Atmosphere comparison: OFF` message at frame 1265, with no PROJECT TERM Lua exception. The screenshot has no visible F8 state or reliable timestamp linking it to that event, so its OFF status is **probable but unconfirmed**. In particular, the image alone cannot establish whether the pale fog is vanilla weather or a PROJECT TERM effect. Capture F8 ON at this same location and game time after allowing the climate transition to settle; record the toggle state alongside both frames before judging the visual gate. The screenshot does not verify sandbox-page visibility, active-play FPS, indoor lighting, rain, or reload behavior.

## 0.3.5 sandbox translation repair candidate

The Indie Stone's 42.15 release notes state that translation files changed to JSON. The prior `42/media/lua/shared/translate/en/Sandbox_EN.txt` was a legacy Lua table despite this test build being 42.20.4. Version 0.3.5 moves the same page/option labels to `42/media/lua/shared/Translate/EN/Sandbox.json` and checks JSON syntax and key coverage locally. This might explain missing labels, but it does **not** prove why the PROJECT TERM page was absent in the tester's menu. Reload 0.3.5, confirm its version line in `console.txt`, and check the mod's page in the **new game → Custom Sandbox** screen with the mod enabled. Capture the page and any load errors; keep this gate open until observed in game.

## 0.3.5 sandbox page observed; 0.3.6 label correction

`image(20260925-045408).png` shows the PROJECT TERM page selected in the Sandbox Options screen, with five controls visible at their defaults. This **passes the page visibility gate** in the tested 42.20.4 build. The page title is translated, but each option label is a raw key (`Sandbox_AtmosphereEnabled`, `Sandbox_AtmosphereIntensity`, `Sandbox_HazeDensity`, `Sandbox_Darkness`, `Sandbox_ColdTint`). The game requests keys without the `ProjectTerm_` prefix that 0.3.5 placed in `Sandbox.json`. Version 0.3.6 matches the five observed key names, including tooltip suffixes. Check in-game that labels now render correctly; no label claim is made from static validation alone.

`console(4).txt` confirms `version=42.20.4 b0bbce05d5`, `loading ProjectTermModPackB42`, `v0.3.5 client Lua loaded`, five configured sandbox values, and an F8 OFF event at frame 732 without a mod-specific exception. It also logs `mod "ProjectTermModPackB42" overrides media/lua/shared/translate/en/sandbox.json`, consistent with the JSON file being found. Other startup errors appear in game content and are not attributed to this mod. `image(20260925-045614).png` depicts a paused, clear daylight yard at a different location than the earlier pale-fog street. Although the log contains one OFF event, the image has no explicit toggle indicator or timestamp and cannot prove a controlled visual comparison. FPS in this paused shot does not measure active-play performance.
