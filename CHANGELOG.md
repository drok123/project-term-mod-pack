# Changelog

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
