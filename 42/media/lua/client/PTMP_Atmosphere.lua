-- Experimental B42 single-player climate layer. No shader, particles, or
-- gameplay visibility changes are claimed. Tunable parameters are below.
local Settings = {
    enabled = true,
    cloudFloor = 0.64,
    hazeFloor = 0.12,
    extraHazeMaximum = 0.28,
    hazePulse = 0.045,             -- subtle multi-hour changes, not fog events
    daylightFactor = 0.86,
    ambientFactor = 0.83,
    globalLightFactor = 0.84,
    desaturationFloor = 0.24,
    dayGradeFloor = 0.35,          -- keep days readable; let nights carry the grade
    transitionMinutes = 18,
}
local runtimeEnabled = true

local function preferences()
    local vars = SandboxVars and SandboxVars.ProjectTerm or {}
    local function scale(name)
        local value = tonumber(vars[name])
        if value == nil then return 1 end
        return math.max(0, math.min(2, value))
    end
    return vars.AtmosphereEnabled ~= false and runtimeEnabled,
        scale('AtmosphereIntensity'), scale('HazeDensity'), scale('Darkness'),
        scale('ColdTint')
end

local states = {}
local colorState = nil
local colorFailed = false
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
    if colorState and colorState.owned then
        pcall(function() colorState.channel:setEnableOverride(false) end)
    end
    colorState = nil
end

local function tintColor(color, amount, interior)
    -- Work from the natural light color every minute, so dawn, dusk, rain,
    -- and artificial interior light are not permanently colored or flattened.
    local red = interior and 0.050 or 0.200
    local green = interior and 0.022 or 0.105
    local blue = interior and 0.005 or 0.020
    return math.max(0, color:getR() * (1 - red * amount)),
        math.max(0, color:getG() * (1 - green * amount)),
        math.max(0, color:getB() * (1 - blue * amount)),
        color:getAlphaFloat()
end

local function applyColdTint(manager, id, amount, nightWeight)
    if amount <= 0 then
        if colorState and colorState.owned then
            colorState.channel:setEnableOverride(false)
        end
        colorState = nil
        return
    end
    if colorFailed then return end
    local ok, err = pcall(function()
        if not colorState then
            if not id or not ClimateColorInfo then error('Climate color API unavailable') end
            local channel = manager:getClimateColor(id)
            if not channel then error('Global light color channel unavailable') end
            colorState = {
                channel = channel,
                owned = not channel:isEnableOverride(),
                value = ClimateColorInfo.new(),
            }
            if not colorState.owned then
                print('[PROJECT TERM] Global light color already overridden; leaving it alone.')
            end
        end
        if not colorState.owned then return end
        local natural = colorState.channel:getInternalValue()
        local grade = amount * (Settings.dayGradeFloor
            + (1 - Settings.dayGradeFloor) * nightWeight)
        local er, eg, eb, ea = tintColor(natural:getExterior(), grade, false)
        local ir, ig, ib, ia = tintColor(natural:getInterior(), grade, true)
        colorState.value:setExterior(er, eg, eb, ea)
        colorState.value:setInterior(ir, ig, ib, ia)
        colorState.channel:setOverride(colorState.value, 1.0)
        colorState.channel:setEnableOverride(true)
    end)
    if not ok then
        if colorState and colorState.owned then
            pcall(function() colorState.channel:setEnableOverride(false) end)
        end
        colorState = nil
        colorFailed = true
        print('[PROJECT TERM] Cold tint disabled after color API error: ' .. tostring(err))
    end
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
    if failed then return end
    local enabled, intensity, hazeScale, darknessScale, tintScale = preferences()
    if not Settings.enabled or not enabled or intensity <= 0 then
        release() -- Kahlua does not expose Lua's next(); empty release is cheap.
        lastMinute = nil
        return
    end
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
        local nightWeight = clamp(1 - daylight, 0, 1)
        local darknessWeight = 0.40 + 0.60 * nightWeight
        local hazeWeight = 0.75 + 0.25 * nightWeight

        -- Keep added daytime fog restrained; night and overcast distance carry
        -- more of the dirty haze while natural heavy weather remains untouched.
        local pulse = (math.sin(minute / 150) + 1) * 0.5 * Settings.hazePulse
        local addedHaze = math.min(Settings.extraHazeMaximum,
            (Settings.hazeFloor + pulse + math.max(0, cloud - 0.5) * 0.06)
            * intensity * hazeScale * hazeWeight)
        local cloudWeight = 0.65 + 0.35 * nightWeight
        apply(manager, 'cloud', CM.FLOAT_CLOUD_INTENSITY,
            cloud + (math.max(cloud, Settings.cloudFloor) - cloud)
                * intensity * cloudWeight, elapsed)
        apply(manager, 'fog', CM.FLOAT_FOG_INTENSITY,
            math.max(fog, addedHaze), elapsed)
        apply(manager, 'daylight', CM.FLOAT_DAYLIGHT_STRENGTH,
            daylight * (1 - (1 - Settings.daylightFactor)
                * intensity * darknessScale * darknessWeight), elapsed)
        apply(manager, 'ambient', CM.FLOAT_AMBIENT,
            ambient * (1 - (1 - Settings.ambientFactor)
                * intensity * darknessScale * darknessWeight), elapsed)
        apply(manager, 'globalLight', CM.FLOAT_GLOBAL_LIGHT_INTENSITY,
            globalLight * (1 - (1 - Settings.globalLightFactor)
                * intensity * darknessScale * darknessWeight), elapsed)
        apply(manager, 'desaturation', CM.FLOAT_DESATURATION,
            desaturation + (math.max(desaturation, Settings.desaturationFloor) - desaturation) * intensity, elapsed)
        applyColdTint(manager, CM.COLOR_GLOBAL_LIGHT,
            clamp(intensity * tintScale, 0, 2), nightWeight)

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
    lastMinute, failed, logged, colorFailed = nil, false, false, false
    runtimeEnabled = true
    update()
end)
Events.EveryOneMinute.Add(update)

-- Direct on/off comparison in single-player, including existing saves whose
-- sandbox page was unavailable when the save was created.
if Events.OnKeyPressed then
    Events.OnKeyPressed.Add(function(key)
        if not Keyboard or key ~= Keyboard.KEY_F8 then return end
        if (isClient and isClient()) or (isServer and isServer()) then return end
        runtimeEnabled = not runtimeEnabled
        if not runtimeEnabled then release() end
        lastMinute = nil
        print('[PROJECT TERM] Atmosphere comparison: ' .. (runtimeEnabled and 'ON' or 'OFF'))
        if runtimeEnabled then update() end
    end)
end
