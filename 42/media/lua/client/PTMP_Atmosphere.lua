-- Experimental B42 single-player climate layer. No shader, particles, or
-- gameplay visibility changes are claimed. Tunable parameters are below.
local Settings = {
    enabled = true,
    cloudFloor = 0.58,
    hazeFloor = 0.10,
    extraHazeMaximum = 0.25,
    hazePulse = 0.035,             -- subtle multi-hour changes, not fog events
    daylightFactor = 0.82,
    ambientFactor = 0.88,
    globalLightFactor = 0.87,
    desaturationFloor = 0.17,
    transitionMinutes = 18,
}

local states = {}
local lastMinute = nil
local failed = false
local logged = false

local function clamp(value, lower, upper)
    return math.max(lower, math.min(upper, value))
end

local function release()
    for _, state in pairs(states) do
        if state.owned then
            pcall(function() state.channel:setEnableOverride(false) end)
        end
    end
    states = {}
end

local function getState(manager, name, id)
    if id == nil then error('Missing climate ID: ' .. name) end
    if states[name] then return states[name] end
    local channel = manager:getClimateFloat(id)
    if not channel then error('Missing climate channel: ' .. name) end
    -- Respect another controller that already owns an override on load.
    local state = { channel = channel, owned = not channel:isEnableOverride(), current = nil }
    states[name] = state
    if not state.owned then
        print('[PROJECT TERM] Climate ' .. name .. ' already overridden; leaving it alone.')
    end
    return state
end

local function apply(manager, name, id, target, elapsed)
    local state = getState(manager, name, id)
    if not state.owned then return end
    local channel = state.channel
    target = clamp(target, channel:getMin(), channel:getMax())
    if state.current == nil then
        state.current = clamp(channel:getInternalValue(), channel:getMin(), channel:getMax())
    end
    local alpha = clamp(elapsed / Settings.transitionMinutes, 0, 1)
    state.current = state.current + (target - state.current) * alpha
    channel:setOverride(state.current, 1.0)
    channel:setEnableOverride(true)
end

local function update()
    if failed or not Settings.enabled then return end
    if (isClient and isClient()) or (isServer and isServer()) then
        release() -- the server owns climate in multiplayer
        return
    end
    local clock, manager = getGameTime(), getClimateManager()
    if not clock or not manager then return end
    local minute = math.floor(clock:getWorldAgeHours() * 60)
    if lastMinute and minute <= lastMinute then return end
    local elapsed = lastMinute and clamp(minute - lastMinute, 1, 60) or 1
    lastMinute = minute

    local ok, err = pcall(function()
        local CM = ClimateManager
        local function natural(name, id)
            return getState(manager, name, id).channel:getInternalValue()
        end
        local cloud = natural('cloud', CM.FLOAT_CLOUD_INTENSITY)
        local fog = natural('fog', CM.FLOAT_FOG_INTENSITY)
        local daylight = natural('daylight', CM.FLOAT_DAYLIGHT_STRENGTH)
        local ambient = natural('ambient', CM.FLOAT_AMBIENT)
        local globalLight = natural('globalLight', CM.FLOAT_GLOBAL_LIGHT_INTENSITY)
        local desaturation = natural('desaturation', CM.FLOAT_DESATURATION)

        -- The pulse adds slight distance variation; actual vanilla fog remains.
        local pulse = (math.sin(minute / 150) + 1) * 0.5 * Settings.hazePulse
        local addedHaze = math.min(Settings.extraHazeMaximum,
            Settings.hazeFloor + pulse + math.max(0, cloud - 0.5) * 0.06)
        apply(manager, 'cloud', CM.FLOAT_CLOUD_INTENSITY,
            math.max(cloud, Settings.cloudFloor), elapsed)
        apply(manager, 'fog', CM.FLOAT_FOG_INTENSITY,
            math.max(fog, addedHaze), elapsed)
        apply(manager, 'daylight', CM.FLOAT_DAYLIGHT_STRENGTH,
            daylight * Settings.daylightFactor, elapsed)
        apply(manager, 'ambient', CM.FLOAT_AMBIENT,
            ambient * Settings.ambientFactor, elapsed)
        apply(manager, 'globalLight', CM.FLOAT_GLOBAL_LIGHT_INTENSITY,
            globalLight * Settings.globalLightFactor, elapsed)
        apply(manager, 'desaturation', CM.FLOAT_DESATURATION,
            math.max(desaturation, Settings.desaturationFloor), elapsed)

        if not logged then
            print('[PROJECT TERM] Atmosphere climate layer active (single-player experimental).')
            logged = true
        end
    end)
    if not ok then
        release()
        failed = true
        print('[PROJECT TERM] Atmosphere disabled after climate error: ' .. tostring(err))
    end
end

Events.OnGameStart.Add(function()
    release()
    lastMinute, failed, logged = nil, false, false
    update()
end)
Events.EveryOneMinute.Add(update)
