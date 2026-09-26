# User playtest: 0.2.0 on 2026-09-26

The user's test **was a real playtest**, not an incorrect package. They reported little noticeable visual change.

Reviewed the newly supplied local `console.txt` and archived a private snapshot using `tools/capture_log.py`. Evidence:

- Exact version: `42.20.4 b0bbce05d5`.
- `loading ProjectTermModPack` and `v0.2.0 scripts loaded` appear.
- Only the current ProjectTerm ID appears; the older atmosphere ID is absent.
- Config arrives at atmosphere/intensity/haze/darkness/tint defaults, Debug true, both loot multipliers 1.
- Loot update and atmosphere-active messages appear.
- F8 receives **OFF at frame 412**, then the world saves/exits at frame 552. No ON event appears in this capture.
- No ProjectTerm exception or repeated mod error is present. The earlier ammo registration exception is absent. Five unrelated-looking vanilla data/map errors remain; this is not a clean whole-game log.
- No weapon-kit use, weapon firing, or visual A/B evidence is recorded. Do not infer those gates passed.

## Result and response

Pass the integrated script-load and F8 OFF event-delivery checks for this run. Visual strength remains unsatisfactory based on user feedback. The 18-minute gradual startup was a plausible contributor, not a proven sole cause. In 0.3.0 the full configured layer applies at startup and F8 ON; subsequent weather remains smooth. Status output now includes actual natural/current/target climate values, and debug haze/night-lighting previews make the comparison repeatable. The previews do not move time or claim to simulate a true night.
