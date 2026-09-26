# Quick test: 0.3.0

Install this candidate over the **single active project-term-mod-pack folder** after exiting the game. Keep the old ProjectTermModPackB42 atmosphere mod and other duplicate copies disabled. Use a disposable single-player save with PROJECT TERM **Debug** enabled.

1. Load a daylight outdoor scene. The configured atmosphere now applies immediately. Press F8 OFF and ON at the same location. Check whether haze/tint/dimming is visible; the log prints natural/current/target values at both events.
2. Right-click → **Project Term: preview haze**. Check distant visibility, then choose **end atmosphere preview**. Repeat **preview night lighting**; it changes lighting channels only, never the clock. F8 OFF also clears the preview.
3. Right-click → **place skull and chassis** on open ground. Expect a vanilla animal skull and one inert machine model on adjacent free floor tiles. These are non-colliding inventory props, not an enemy. Check scale, orientation, pickup/drop and save/reload. Only one two-item set is allowed per save.
4. Right-click → **clean up test props**. Only the tagged test items at their recorded tiles or in your main inventory are removed. If moved into another container or elsewhere, return them first. Unresolved records retain the cap instead of allowing duplicate spawns.
5. Right-click → **play machine ambience**. Expect a brief distant turbine-like cue from 18–27 tiles away. Walk toward/away from it to assess attenuation. Use **stop machine ambience** to stop it. Natural cues have long quiet gaps; frequency 0 stops automatic cues, and AmbienceEnabled off stops the system. No enemy-attracting game noise is created.
6. Retest the existing weapon kit, all 24 shots, reload, dry fire and shove. Capture the new console afterward.

The new props/audio and visible atmosphere comparison are **not yet accepted in-game**. Rendering, attenuation, reload and performance require observations, not just the mock suites. This build does not yet add an active hunter or aircraft.

## Automated verification

```powershell
python tools/check_all.py --game 'D:/New folder/steamapps/common/ProjectZomboid' --javac 'C:/Program Files/Java/jdk-24/bin/javac.exe'
python tools/package.py
```

Six regression suites use the installed Kahlua runtime with mocked engine objects. Packaging generates the original deterministic 8-second mono PCM machine cue from `tools/generate_audio.py`, resolves every mesh/texture/audio reference, and verifies the ZIP. No sampled third-party sound is used.
