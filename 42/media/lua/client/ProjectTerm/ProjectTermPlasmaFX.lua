ProjectTerm = ProjectTerm or {}

local activeFlash = nil
local flashCell = nil
local ticksLeft = 0

local function removeFlash()
    if activeFlash and flashCell then
        pcall(function()
            flashCell:removeLamppost(activeFlash)
        end)
    end
    activeFlash = nil
    flashCell = nil
    ticksLeft = 0
end

local function addPulseFlash(attacker, weapon)
    if not attacker or not weapon then return end
    if weapon:getFullType() ~= "ProjectTerm.ArcPulseRifle" then return end

    if attacker:isDoShove() or attacker:isRangedWeaponEmpty() then return end
    -- The vanilla reload handler consumes ammunition on this same event.
    -- Do not check the remaining count here: the final round can already be gone.
    local cell = getCell()
    if not cell then return end

    removeFlash()

    local x = math.floor(attacker:getX())
    local y = math.floor(attacker:getY())
    local z = math.floor(attacker:getZ())

    local okLight, light = pcall(function()
        -- Short violet-white flash. Client-only visual; no gameplay effect.
        return cell:addLamppost(x, y, z, 0.85, 0.20, 1.00, 5)
    end)

    if okLight then
        activeFlash = light
        flashCell = cell
        ticksLeft = 3
    end
end

local function onTick()
    if not activeFlash then return end
    ticksLeft = ticksLeft - 1
    if ticksLeft <= 0 then
        removeFlash()
    end
end

Events.OnWeaponSwingHitPoint.Add(addPulseFlash)
Events.OnTick.Add(onTick)
Events.OnMainMenuEnter.Add(removeFlash)
