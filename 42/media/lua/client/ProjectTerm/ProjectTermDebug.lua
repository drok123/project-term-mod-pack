require "ProjectTerm/ProjectTermConfig"
require "PTMP_Atmosphere"
require "ProjectTerm/ProjectTermProps"
require "ProjectTerm/ProjectTermAmbience"

local function singlePlayer()
    return not isClient() and not isServer()
end

local function allowed()
    return singlePlayer() and ProjectTerm.getConfig().Debug
end

local function giveWeapon(player)
    if not singlePlayer() or not player then return end
    local inventory = player:getInventory()
    if not inventory then return end
    local function add(fullType)
        if not inventory:AddItem(fullType) then
            ProjectTerm.warnOnce("give:" .. fullType, "debug item unavailable: " .. fullType)
        end
    end
    add("ProjectTerm.ArcPulseRifle")
    add("ProjectTerm.ArcCell")
    add("ProjectTerm.ArcCell")
    for i = 1, 48 do add("ProjectTerm.ArcCharge") end
    ProjectTerm.log("INFO", "requested rifle, two empty cells and 48 charges")
end

local function fillMenu(playerIndex, context, worldObjects, test)
    if test or not singlePlayer() then return end
    local player = getSpecificPlayer(playerIndex)
    if not player then return end
    context:addOption("PROJECT TERM: Give Arc Pulse Rifle kit", player, giveWeapon)
    context:addOption("PROJECT TERM: Toggle atmosphere (F8)", nil, function()
        if singlePlayer() then ProjectTerm.toggleAtmosphere() end
    end)
    if not allowed() then
        context:addOption("PROJECT TERM: Enable extra test controls", nil, function()
            if singlePlayer() then
                ProjectTerm.debugEnabled = true
                ProjectTerm.log("INFO", "Extra test controls enabled for this session; right-click again.")
            end
        end)
        return
    end
    context:addOption("Project Term: atmosphere status", nil, function()
        if allowed() then ProjectTerm.Atmosphere.report() end
    end)
    context:addOption("Project Term: preview haze", nil, function()
        if allowed() then ProjectTerm.Atmosphere.setPreview("haze") end
    end)
    context:addOption("Project Term: preview night lighting", nil, function()
        if allowed() then ProjectTerm.Atmosphere.setPreview("night") end
    end)
    context:addOption("Project Term: end atmosphere preview", nil, function()
        ProjectTerm.Atmosphere.setPreview(nil)
    end)
    context:addOption("Project Term: place skull and chassis", player, ProjectTerm.Props.place)
    context:addOption("Project Term: clean up test props", player, ProjectTerm.Props.cleanup)
    context:addOption("Project Term: play machine ambience", player, ProjectTerm.Ambience.preview)
    context:addOption("Project Term: stop machine ambience", nil, ProjectTerm.Ambience.stop)
end

Events.OnFillWorldObjectContextMenu.Add(fillMenu)
