require "Items/ProceduralDistributions"

local PREFIX = "[ProjectTerm] "

local function addItem(listName, fullType, weight)
    local list = ProceduralDistributions
        and ProceduralDistributions.list
        and ProceduralDistributions.list[listName]

    if not list or not list.items then
        print(PREFIX .. "loot list unavailable, skipped: " .. tostring(listName))
        return
    end

    table.insert(list.items, fullType)
    table.insert(list.items, weight)
end

local function installProjectTermLoot()
    -- Rifle is intentionally very rare. Cells/charges are more common so finding
    -- the weapon does not immediately make it unusable.
    local rifleLists = {
        "PoliceStorageGuns",
        "HuntingLockers",
        "GunStoreShelf",
        "GunStoreCounter",
        "ArmyStorageGuns",
    }

    local ammoLists = {
        "PoliceStorageGuns",
        "GunStoreShelf",
        "GunStoreCounter",
        "ArmyStorageGuns",
        "GunStoreAmmo",
    }

    for _, listName in ipairs(rifleLists) do
        addItem(listName, "ProjectTerm.ArcPulseRifle", 0.15)
    end

    for _, listName in ipairs(ammoLists) do
        addItem(listName, "ProjectTerm.ArcCell", 0.75)
        addItem(listName, "ProjectTerm.ArcCharge", 2.50)
    end

    print(PREFIX .. "loot hooks installed")
end

Events.OnPostDistributionMerge.Add(installProjectTermLoot)
