# Changelog

## 0.3.5 — Build 42 sandbox translation format

- Moved the custom sandbox page labels and tooltips from Lua-style `Sandbox_EN.txt` to `Translate/EN/Sandbox.json`, following the 42.15+ translation format.
- Static validation checks the JSON syntax and page/option label coverage. Page visibility in 42.20.4 still requires a fresh in-game Custom Sandbox check.

## 0.3.4 — fix repeated F8-off runtime exception

- Replaced an unsupported Lua `next()` call in the disabled atmosphere path. A 42.20.4 game log shows the F8 OFF/ON key events work but the minute update threw 14 exceptions while OFF.
- The local Lua mock now runs with `next` unavailable. In-game recheck of 0.3.4 is pending.

## 0.3.3 — direct comparison key

- Removed the sandbox gate from F8 so existing single-player saves can attempt the atmosphere A/B check.
- Removed the unverified F8 sandbox option. The tester reports that the PROJECT TERM sandbox page is absent; page registration remains an open in-game gate.

## 0.3.2 — cold light candidate

- Added an adjustable blue-gray exterior light tint with a weaker interior tint. A missing color API cannot take down the existing haze pass.
- Extended the Lua mock to check color override ownership, F8 release, zero tint, and color API failure. The tint remains untested in the game.

## 0.3.1 — first game evidence and comparison candidate

- Recorded first single-player load on Project Zomboid 42.20.4 b0bbce05d5.
- Added an opt-in F8 climate toggle for same-location screenshots; Lua mock passes, in-game hotkey behavior pending.

## 0.3.0 — atmosphere controls candidate

- Added a Build 42 custom sandbox page with atmosphere, haze, and darkness controls.
- Added mock checks for disabling and zeroing haze/darkness; in-game UI and visual checks are pending.

## 0.2.0 — atmosphere candidate

- Added an experimental single-player gloomy climate layer with restrained haze and gradual transitions.
- Added diagnostic messages and conservative conflict/error handling; no in-game validation yet.

## 0.1.0 — foundation candidate

- Added a Build 42 versioned mod layout and minimal client load diagnostic.
- Added packaging and static validation; in-game compatibility remains unverified.
