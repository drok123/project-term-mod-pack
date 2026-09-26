require "ProjectTerm/ProjectTermConfig"
ProjectTerm.Ambience = {}
local A = ProjectTerm.Ambience
local emitter, owner, expires, nextMinute, lastMinute
local earliest = 0
local failed = false

local function singlePlayer()
    return not isClient() and not isServer()
end

function A.stop()
    if emitter then
        pcall(function() emitter:stopAll() end)
        if owner then pcall(function() owner:returnOwnershipOfEmitter(emitter) end) end
    end
    emitter, owner, expires = nil, nil, nil
end

local function play(player)
    local config = ProjectTerm.getConfig()
    if failed or not singlePlayer() or not config.AmbienceEnabled
        or not player or emitter then return false end
    local world = getWorld()
    if not world then return false end
    local ok, err = pcall(function()
        local angle = ZombRand(628) / 100
        local distance = 18 + ZombRand(10)
        owner = world
        emitter = world:getFreeEmitter(player:getX() + math.cos(angle) * distance,
            player:getY() + math.sin(angle) * distance, player:getZ())
        if not emitter then error("sound emitter unavailable") end
        -- Retain/tick our single emitter so the world pool cannot reuse it
        -- before our cleanup; return it once the clip ends.
        world:takeOwnershipOfEmitter(emitter)
        local id = emitter:playSound("ProjectTermDistantMachine")
        if not id or id == 0 then error("sound clip did not start") end
        expires = getTimestampMs() + 10000
        earliest = getTimestampMs() + 90000
    end)
    if not ok then
        A.stop()
        failed = true
        ProjectTerm.warnOnce("ambience-api", "Ambience disabled for this session: " .. tostring(err))
        return false
    end
    ProjectTerm.log("DEBUG", "Distant machine cue started (one positional emitter).")
    return true
end

function A.preview(player)
    if not ProjectTerm.getConfig().Debug then return false end
    return play(player)
end

function A.status()
    return {active = emitter ~= nil, failed = failed, nextMinute = nextMinute}
end

local function onTick()
    if not emitter then return end
    if not singlePlayer() or not ProjectTerm.getConfig().AmbienceEnabled
        or getTimestampMs() >= expires then A.stop(); return end
    local ok, empty = pcall(function()
        emitter:tick()
        return emitter:isEmpty()
    end)
    if not ok then
        failed = true
        ProjectTerm.warnOnce("ambience-tick", "Ambience emitter failed; disabling for this session.")
    end
    if not ok or empty then A.stop() end
end

local function onMinute()
    local config = ProjectTerm.getConfig()
    if not singlePlayer() or not config.AmbienceEnabled or config.AudioFrequency <= 0 then
        A.stop(); nextMinute = nil; return
    end
    local clock = getGameTime()
    if not clock then return end
    local minute = math.floor(clock:getWorldAgeHours() * 60)
    if lastMinute and minute < lastMinute then nextMinute = nil end
    lastMinute = minute
    if not nextMinute then nextMinute = minute + (60 + ZombRand(61)) / config.AudioFrequency end
    if minute < nextMinute or getTimestampMs() < earliest then return end
    nextMinute = minute + (60 + ZombRand(61)) / config.AudioFrequency
    play(getSpecificPlayer(0))
end

local function reset()
    A.stop()
    nextMinute, lastMinute = nil, nil
    earliest, failed = 0, false
end
Events.OnTick.Add(onTick)
Events.EveryOneMinute.Add(onMinute)
Events.OnGameStart.Add(reset)
Events.OnMainMenuEnter.Add(reset)
