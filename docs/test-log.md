# In-game gate log

## Gate 1 — mod appears and loads

- Status: **pending in-game verification**
- Exact game version tested: **none yet**
- Mode: single-player intended; multiplayer untested
- Mods-menu screenshot: pending
- Disposable new save loads: pending
- Same save reloads: pending
- Existing save behavior: pending
- `console.txt` retained and checked for errors/log spam: pending
- Tester/date/hardware and performance notes: pending

Static packaging is not evidence that the game detected or ran this mod.

## Gate 2 — API findings and atmosphere

Source candidate prepared; blocked by Gate 1 for in-game acceptance. Record API observations from the installed build and attach day/night, interior/exterior, rain, and weather-transition evidence. Test disabling and reloading for a clean vanilla look. Check nearby visibility, interior legibility, and `console.txt` for repeated errors. The implementation uses climate float IDs and overrides listed in the [current public API](https://projectzomboid.com/modding/zombie/iso/weather/ClimateManager.html) and [ClimateFloat methods](https://projectzomboid.com/modding/zombie/iso/weather/ClimateManager.ClimateFloat.html); their behavior in the installed Build 42 patch is unproven.
