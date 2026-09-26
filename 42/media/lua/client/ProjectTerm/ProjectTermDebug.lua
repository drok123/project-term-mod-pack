ProjectTerm = ProjectTerm or {}

local function singlePlayer()
    return not (isClient and isClient()) and not (isServer and isServer())
end

local function giveWeapon(player)
    if not singlePlayer() or not player then return end
    local inventory = player:getInventory()
    if not inventory then return end

    local function add(fullType, count)
        for _ = 1, (count or 1) do
            local item = inventory:AddItem(fullType)
            if not item then
                print("[PROJECT TERM] Debug give failed: " .. tostring(fullType))
                return false
            end
        end
        return true
    end

    add("ProjectTerm.ArcPulseRifle", 1)
    add("ProjectTerm.ArcCell", 2)
    add("ProjectTerm.ArcCharge", 48)
    print("[PROJECT TERM] Debug weapon kit added.")
end

local function fillMenu(playerIndex, context, worldObjects, test)
    if test or not singlePlayer() then return end
    local player = getSpecificPlayer(playerIndex)
    if not player then return end

    context:addOption("PROJECT TERM: Give Arc Pulse Rifle kit", player, giveWeapon)
    context:addOption("PROJECT TERM: Toggle atmosphere (F8)", nil, function()
        if ProjectTerm.toggleAtmosphere then
            local state = ProjectTerm.toggleAtmosphere()
            print("[PROJECT TERM] Context-menu atmosphere toggle -> " .. tostring(state))
        else
            print("[PROJECT TERM] Atmosphere toggle function unavailable.")
        end
    end)
end

Events.OnFillWorldObjectContextMenu.Add(fillMenu)

if Events.OnGameStart then
    Events.OnGameStart.Add(function()
        print("[PROJECT TERM] Debug controls active: right-click world for weapon kit; F8 toggles atmosphere.")
    end)
end
