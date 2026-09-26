require "ProjectTerm/ProjectTermConfig"

local function allowed()
    return ProjectTerm.getConfig().Debug
        and not isClient() and not isServer()
end

local function giveWeapon(player)
    if not allowed() or not player then return end
    local inventory = player:getInventory()
    if not inventory then return end
    local function add(fullType)
        if not inventory:AddItem(fullType) then
            ProjectTerm.warnOnce("give:" .. fullType, "debug item unavailable: " .. fullType)
        end
    end
    add("ProjectTerm.ArcPulseRifle")
    add("ProjectTerm.ArcCell")
    for i = 1, 48 do add("ProjectTerm.ArcCharge") end
    ProjectTerm.log("DEBUG", "requested rifle, one empty cell and 48 charges")
end

local function fillMenu(playerIndex, context, worldObjects, test)
    if test or not allowed() then return end
    local player = getSpecificPlayer(playerIndex)
    if not player then return end
    context:addOption("Project Term: give weapon test kit", player, giveWeapon)
end

Events.OnFillWorldObjectContextMenu.Add(fillMenu)
