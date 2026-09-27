assert(registryChecked, "registry must map its ammo id to a full item-type string")
local fire = Events.OnWeaponSwingHitPoint.callback
assert(fire, "flash must use the vanilla shot hit-point event")
fire(nil, runtimeWeapon)
runtimeWeapon.fullType = "Base.AssaultRifle"
fire(runtimeAttacker, runtimeWeapon)
runtimeWeapon.fullType = "ProjectTerm.ArcPulseRifle"
runtimeAttacker.shoving = true
fire(runtimeAttacker, runtimeWeapon)
runtimeAttacker.shoving = false
runtimeAttacker.empty = true
fire(runtimeAttacker, runtimeWeapon)
assert(runtimeCell.added == 0, "unrelated weapon, shove, and dry-fire must not flash")
runtimeAttacker.empty = false
fire(runtimeAttacker, runtimeWeapon)
assert(runtimeCell.added == 1, "the final shot must flash even after ammo consumption")
fire(runtimeAttacker, runtimeWeapon)
assert(runtimeCell.added == 2 and runtimeCell.removed == 1, "replacement must keep only one light")
Events.OnTick.callback()
Events.OnTick.callback()
assert(runtimeCell.removed == 1)
Events.OnTick.callback()
assert(runtimeCell.removed == 2, "light must expire after three ticks")
Events.OnTick.callback()
assert(runtimeCell.removed == 2, "cleanup must be idempotent")
fire(runtimeAttacker, runtimeWeapon)
currentCell = nil
Events.OnMainMenuEnter.callback()
assert(runtimeCell.removed == 3, "cleanup must use the cell that owns the light")
fire(runtimeAttacker, runtimeWeapon)
assert(runtimeCell.added == 3, "no world must not create a light")
print("PASS: ammo registry and bounded muzzle-flash lifecycle")
