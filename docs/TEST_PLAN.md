# 0.2.0 single-player acceptance

Use a disposable test save on 42.20.4 b0bbce05d5. Disable the older `ProjectTermModPackB42` mod and any duplicate `ProjectTermModPack` installation. Extract the ZIP into a staging directory, then install its `project-term-mod-pack` folder under `Zomboid/mods`. Keep one copy enabled.

1. Check the Mods-menu entry and PROJECT TERM sandbox page. Start with defaults; turn Debug on for the weapon kit.
2. Load a new save. Right-click the world and choose **Project Term: give weapon test kit**. Expect one rifle, one empty cell, and 48 charges. Fill the cell, insert it, fire all 24 rounds, reload, drop/pick up, and save/reload. Check damage, animations, sound radius, and a flash on the final round; dry firing and shoving should not flash.
3. At one fixed place/time, capture atmosphere ON/OFF with F8. Allow roughly 18 in-game minutes for the ON transition. Repeat outdoors/indoors, day/night, rain, natural fog, and a weather transition. Nearby streets and interiors must remain usable. Zero intensity disables the layer; zero haze preserves natural fog.
4. Quit to menu and reload; compare with the mod disabled on another test save. Verify no persistent climate override or light remains. Test the Debug setting off and ensure no kit entry appears.
5. Check loot in fresh containers/new worlds at multiplier 0, 1, and 2. Previously generated loot is not removed by a setting change.
6. Record active-play frame rate and errors in rural/urban scenes. A paused FPS screenshot is not performance evidence.
7. After each test run `python tools/capture_log.py`; optionally pass `--source` and `--output-dir`. Logs stay local because they may include machine/user details. Review errors by source, including preexisting vanilla errors.

Record build, package version, save type, enabled mods, scenario, result, screenshots, and log path per run. Stop feature acceptance on mod load exceptions or repeating errors. This candidate has **no new in-game acceptance run yet**.

## Automated checks

The harness compiles a small Java helper with a JDK, then executes Lua with the game's bundled Java and actual Kahlua library. It does not start the game or modify its files. Set paths explicitly:

```powershell
python tools/run_lua_tests.py --game 'D:/New folder/steamapps/common/ProjectZomboid' --javac 'C:/Program Files/Java/jdk-24/bin/javac.exe' tests/loot_setup.lua 42/media/lua/shared/ProjectTerm/ProjectTermConfig.lua 42/media/lua/server/ProjectTerm/ProjectTermLoot.lua tests/loot_assert.lua
python tools/run_lua_tests.py --game 'D:/New folder/steamapps/common/ProjectZomboid' --javac 'C:/Program Files/Java/jdk-24/bin/javac.exe' tests/debug_setup.lua 42/media/lua/shared/ProjectTerm/ProjectTermConfig.lua 42/media/lua/client/ProjectTerm/ProjectTermDebug.lua tests/debug_assert.lua
```

See `tests/` for the matching atmosphere and runtime setup/assert scripts. Mock boundaries must not be reported as full in-game validation.
