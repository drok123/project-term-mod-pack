require "Items/ProceduralDistributions"
local PREFIX="[ProjectTerm] "
local function addItem(listName, fullType, weight)
 local list=ProceduralDistributions and ProceduralDistributions.list and ProceduralDistributions.list[listName]
 if not list or not list.items then print(PREFIX.."loot list unavailable, skipped: "..tostring(listName)); return end
 table.insert(list.items, fullType); table.insert(list.items, weight)
end
local function installProjectTermLoot()
 local rifleLists={"PoliceStorageGuns","HuntingLockers","GunStoreShelf","GunStoreCounter","ArmyStorageGuns"}
 local ammoLists={"PoliceStorageGuns","GunStoreShelf","GunStoreCounter","ArmyStorageGuns","GunStoreAmmo"}
 for _,n in ipairs(rifleLists) do addItem(n,"ProjectTerm.ArcPulseRifle",0.15) end
 for _,n in ipairs(ammoLists) do addItem(n,"ProjectTerm.ArcCell",0.75); addItem(n,"ProjectTerm.ArcCharge",2.50) end
 print(PREFIX.."loot hooks installed")
end
Events.OnPostDistributionMerge.Add(installProjectTermLoot)
