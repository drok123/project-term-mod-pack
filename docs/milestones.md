# Milestones

## M1 sandbox page blocker — 2026-09-25

The tester cannot find the PROJECT TERM sandbox page in the options they inspected. Whether these were new-world options or an existing save is still unknown. Version 0.3.3 removes the F8 key's dependency on that page so the existing save can run a direct A/B diagnostic; neither the key nor page is yet confirmed in-game.

## M1 color candidate — 2026-09-25

Added a separately guarded cold exterior/interior light tint with a sandbox slider. Static and mocked checks pass; in-game visual validation and exact patch acceptance remain pending.

## M0 — 2026-09-25

Build 42 foundation candidate prepared. Static layout and ZIP checks pass. Awaiting game installation, Mods-menu screenshot, exact game version, and `console.txt` to close Gate 1.

## M1 candidate — 2026-09-25

Single-player gloomy climate pass added behind the same versioned mod. Static syntax and mocked climate checks pass; in-game visual and compatibility gates remain open. No claim of actual smoke particles, emissive rendering, or verified B42 lighting behavior.

## M1 controls candidate — 2026-09-25

Added new-game sandbox controls for atmosphere, haze, and darkness using the Build 42 `sandbox-options.txt` structure. Mock Lua behavior passes. A received screenshot shows only a startup warning, so exact game patch, mod visibility, and option UI still need game evidence.

## M1 first in-game load — 2026-09-25

The user's `console.txt` and screenshots identify **42.20.4 b0bbce05d5**. Single-player enters the world with ProjectTermModPackB42 loaded; atmosphere values and both v0.3.0 startup messages appear once in the observed load. A night interior is visible. The explicit Mods-menu view, visual baseline, daytime/weather tests, save reload, and performance assessment remain open. Unrelated-looking game errors are present in the log, so no whole-log clean bill is claimed.
