require "Items/ProceduralDistributions"
require "ProjectTerm/ProjectTermConfig"

local function addItem(listName, fullType, weight)
    local list = ProceduralDistributions and ProceduralDistributions.list
        and ProceduralDistributions.list[listName]
    if not list or not list.items then
        ProjectTerm.warnOnce("loot:" .. listName, "loot list unavailable: " .. listName)
        return
    end
    -- Merges may repeat. Replace our entries instead of multiplying odds.
    for index = #list.items - 1, 1, -2 do
        if list.items[index] == fullType then
            table.remove(list.items, index + 1)
            table.remove(list.items, index)
        end
    end
    if weight > 0 then
        table.insert(list.items, fullType)
        table.insert(list.items, weight)
    end
end

local function installProjectTermLoot()
    local config = ProjectTerm.getConfig()
    local lists = {"PoliceStorageGuns", "HuntingLockers", "GunStoreShelf",
        "GunStoreCounter", "ArmyStorageGuns"}
    for _, name in ipairs(lists) do
        addItem(name, "ProjectTerm.ArcPulseRifle", 0.15 * config.WeaponLootMultiplier)
        if name ~= "HuntingLockers" then
            addItem(name, "ProjectTerm.ArcCell", 0.75 * config.AmmoLootMultiplier)
            addItem(name, "ProjectTerm.ArcCharge", 2.50 * config.AmmoLootMultiplier)
        end
    end
    ProjectTerm.log("DEBUG", "loot distributions updated")
end
Events.OnPostDistributionMerge.Add(installProjectTermLoot)
