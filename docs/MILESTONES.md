# Milestone log

## 2026-09-26 â€” first playable foundations, 0.2.0 candidate

- Inspected installed 42.20.4 b0bbce05d5; user selected single-player first.
- Fixed the observed custom-ammo registry exception and corrected firearm classification/animation fields using installed vanilla sources.
- Recovered prior local atmosphere code into the Git project, with F8 comparison, sandbox controls, guarded climate ownership, clock-rewind handling, and menu cleanup.
- Added centralized logging, opt-in debug weapon kit, configurable idempotent loot, log capture, export/source separation, and validated install-only packaging.
- Recovered 12 prepared model exports and textures from the local test installation into ignored staging. No source GLBs or asset licensing proof were recovered. Public release rights remain a gate.
- Automated Kahlua regression checks cover atmosphere, ammo/flash, loot, and debug controls; packaging verifies model/texture references and ZIP integrity.
- **Pending:** new-package game load, visual comparisons, reload/fire/damage, save/reload, weather transitions, and active-play performance. No hunter, craft, props, custom sound, or integrated milestone completion claimed.

## 2026-09-26 — visible test controls and prop/audio proof, 0.3.0 candidate

The user's 0.2.0 playtest confirms script loading and F8 OFF without ProjectTerm errors, resolving the earlier ammo registration load exception. They report little visual change; do not pass the visual gate.

0.3.0 now applies atmosphere immediately for comparisons, logs climate values, exposes reversible haze/night-lighting previews, places one capped persistent skull/chassis pair, and plays an original positional machine cue with sparse scheduling. Six Kahlua suites cover behavior; game rendering, attenuation, world persistence and gameplay acceptance remain pending. No active hunter or aircraft is claimed.
