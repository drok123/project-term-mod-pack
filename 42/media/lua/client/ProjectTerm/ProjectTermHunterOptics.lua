local HunterConfig = require "ProjectTerm/ProjectTermHunterConfig"

local PREFIX = "[ProjectTerm] "
local UPDATE_INTERVAL = 20
local LIGHT_RADIUS = 2

local activeLights = {}
local ticksUntilUpdate = 0

local function log(message)
    print(PREFIX .. tostring(message))
end

local function removeLight(zombie)
    local entry = activeLights[zombie]
    if not entry then return end

    local cell = getCell()
    if cell and entry.light then
        pcall(function()
            cell:removeLamppost(entry.light)
        end)
    end
    activeLights[zombie] = nil
end

local function removeAllLights()
    local zombies = {}
    for zombie in pairs(activeLights) do
        table.insert(zombies, zombie)
    end
    for _, zombie in ipairs(zombies) do
        removeLight(zombie)
    end
end

local function isLiveHunter(zombie)
    local ok, result = pcall(function()
        if zombie:isDead() or not zombie:isExistInTheWorld() then
            return false
        end
        local state = zombie:getModData().ProjectTerm
        return state and state.isHunter == true and state.optics == true
    end)
    return ok and result == true
end

local function addLight(zombie)
    local cell = getCell()
    if not cell then return end

    local x = math.floor(zombie:getX())
    local y = math.floor(zombie:getY())
    local z = math.floor(zombie:getZ())
    local ok, light = pcall(function()
        local source = IsoLightSource.new(x, y, z, 1.0, 0.03, 0.03, LIGHT_RADIUS)
        cell:addLamppost(source)
        return source
    end)

    if ok and light then
        activeLights[zombie] = {
            light = light,
            x = x,
            y = y,
            z = z,
        }
    end
end

local function ensureLight(zombie)
    local entry = activeLights[zombie]
    local x = math.floor(zombie:getX())
    local y = math.floor(zombie:getY())
    local z = math.floor(zombie:getZ())

    if entry and (entry.x ~= x or entry.y ~= y or entry.z ~= z) then
        removeLight(zombie)
        entry = nil
    end
    if not entry then
        addLight(zombie)
    end
end

local function refreshNearestLights()
    if not HunterConfig.isEnabled() or not HunterConfig.isOpticsEnabled() then
        removeAllLights()
        return
    end

    local player = getPlayer()
    local cell = getCell()
    if not player or not cell then
        removeAllLights()
        return
    end

    local candidates = {}
    local zombies = cell:getZombieList()
    for index = 0, zombies:size() - 1 do
        local zombie = zombies:get(index)
        if isLiveHunter(zombie) then
            local dx = zombie:getX() - player:getX()
            local dy = zombie:getY() - player:getY()
            table.insert(candidates, {
                zombie = zombie,
                distanceSquared = dx * dx + dy * dy,
            })
        end
    end

    table.sort(candidates, function(left, right)
        return left.distanceSquared < right.distanceSquared
    end)

    local wanted = {}
    local limit = math.min(HunterConfig.getMaxActiveLights(), #candidates)
    for index = 1, limit do
        wanted[candidates[index].zombie] = true
    end

    local toRemove = {}
    for zombie in pairs(activeLights) do
        if not wanted[zombie] then
            table.insert(toRemove, zombie)
        end
    end
    for _, zombie in ipairs(toRemove) do
        removeLight(zombie)
    end

    for zombie in pairs(wanted) do
        ensureLight(zombie)
    end
end

local function onTick()
    ticksUntilUpdate = ticksUntilUpdate - 1
    if ticksUntilUpdate > 0 then return end
    ticksUntilUpdate = UPDATE_INTERVAL
    refreshNearestLights()
end

local function onZombieCreate(zombie)
    -- Remove a light immediately if B42 reuses this pooled Java object.
    removeLight(zombie)
end

local function onZombieDead(zombie)
    removeLight(zombie)
end

local function onGameStart()
    removeAllLights()
    ticksUntilUpdate = 0
    log("hunter optics initialized (fallback light, cap "
        .. tostring(HunterConfig.getMaxActiveLights()) .. ")")
end

Events.OnGameStart.Add(onGameStart)
Events.OnZombieCreate.Add(onZombieCreate)
Events.OnZombieDead.Add(onZombieDead)
Events.OnTick.Add(onTick)
