# Installed Build 42 API evidence

Target: **single-player, 42.20.4 b0bbce05d5**, read from local `Zomboid/version.txt` and the existing console on 2026-09-26. This is the inspected build, not a claim that this new integrated package has been playtested.

## Confirmed bindings and observed failures

- The prior console repeatedly reports `expected argument of type String, got ItemKey` in this mod's registry. Installed `projectzomboid.jar` exposes public `AmmoType.register(String, String)`. The new mapping uses `projectterm:arc_charge` and full item name `ProjectTerm.ArcCharge`.
- Installed `media/lua/shared/TimedActions/ISReloadWeaponAction.lua` consumes ammunition in `onShoot`, registered to `OnWeaponSwingHitPoint`. Check shove/empty attack state, not remaining ammo, because the last round can already have been consumed by another handler.
- `IsoCell.addLamppost(int,int,int,float,float,float,int)` returns `IsoLightSource`; `removeLamppost(IsoLightSource)` exists. The effect retains its owning cell and has one active lamp maximum. Actual rendered flash remains unverified.
- Installed vanilla `media/scripts/generated/items/weapon.txt` M16 supplies Rifle swing animation, Idle_Weapon2, Run_Weapon2, Firearm subcategory, and `base:firearm` tag. These support the prototype's classification/animation; they do not prove custom reload operation.
- Installed climate debug Lua uses climate float constants, getters, and override controls. Reflection against the installed JAR confirms the float/color internal-value and override methods used by the integrated atmosphere module. Color and haze appearance remain pending.
- Installed `media/lua/client/MainScreen.lua` triggers `OnMainMenuEnter`; release temporary visual state there.
- The five targeted procedural gun lists exist in installed `ProceduralDistributions.lua`. `GunStoreAmmo` does not; removed that target. Loot merges now replace this mod's entries and preserve unrelated items.
- `AdminContextMenu.lua` demonstrates the world context-menu callback and `getSpecificPlayer`; debug scenarios demonstrate `getInventory():AddItem(fullType)`.

## Limits

Automated checks run the installed Kahlua interpreter with mocked game objects. They verify Lua behavior, not engine rendering, networking, script parsing, shooting, or world persistence. The old local atmosphere package has a historical test log; this integration must earn its own acceptance evidence. Do not run the old `ProjectTermModPackB42` atmosphere mod alongside this package.

Helicopter coordinates, emissive optics, volumetric cones, live aircraft models, rigged hunters, and positional custom audio remain research gates. No implementation claim is made for them.
