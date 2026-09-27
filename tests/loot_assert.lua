callbacks.merge()
callbacks.merge()
local items = ProceduralDistributions.list.PoliceStorageGuns.items
assert(#items == 8, "repeat merge must not duplicate loot")
assert(items[1] == "Base.Test" and items[2] == 3, "preserve vanilla entries")
assert(items[4] == 0.15 and items[6] == 0.75 and items[8] == 2.5)
SandboxVars.ProjectTerm.WeaponLootMultiplier = 0
SandboxVars.ProjectTerm.AmmoLootMultiplier = 2
callbacks.merge()
assert(#items == 6 and items[4] == 1.5 and items[6] == 5, "zero weapon and scaled ammo")
SandboxVars.ProjectTerm.AmmoLootMultiplier = 0
callbacks.merge()
assert(#items == 2, "zero loot removes only mod entries")
ProceduralDistributions.list.GunStoreShelf = nil
callbacks.merge()
callbacks.merge()
SandboxVars.ProjectTerm.AmmoLootMultiplier = 999
assert(ProjectTerm.getConfig().AmmoLootMultiplier == 5, "bounded setting")
SandboxVars.ProjectTerm = nil
assert(ProjectTerm.getConfig().WeaponLootMultiplier == 1, "existing save defaults")
print("PASS loot: repeated merge, defaults, scaling, zero, missing list, vanilla preservation")
