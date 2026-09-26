require "ProjectTerm/ProjectTermConfig"

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
local runtimeEnabled = true
local preview = nil
local Atmosphere = {}
ProjectTerm.Atmosphere = Atmosphere

local function preferences()
    local vars = SandboxVars and SandboxVars.ProjectTerm or {}
    local function scale(name)
        local value = tonumber(vars[name])
        if value == nil or value ~= value then return 1 end
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
    local red = interior and 0.025 or 0.09
    local green = interior and 0.008 or 0.035
    return math.max(0, color:getR() * (1 - red * amount)),
        math.max(0, color:getG() * (1 - green * amount)),
        color:getB(), color:getAlphaFloat()
end

local function applyColdTint(manager, id, amount)
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
                ProjectTerm.warnOnce('atmosphere-color-owned', 'Global light color already overridden; leaving it alone.')
            end
        end
        if not colorState.owned then return end
        local natural = colorState.channel:getInternalValue()
        local er, eg, eb, ea = tintColor(natural:getExterior(), amount, false)
        local ir, ig, ib, ia = tintColor(natural:getInterior(), amount, true)
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
        ProjectTerm.warnOnce('atmosphere-color-api', 'Cold tint disabled after color API error: ' .. tostring(err))
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
        ProjectTerm.warnOnce('atmosphere-owned-' .. name, 'Climate ' .. name .. ' already overridden; leaving it alone.')
    end
    return state
end

local function apply(manager, name, id, target, elapsed)
    local state = getState(manager, name, id)
    if not state.owned then return end
    local channel = state.channel
    target = clamp(target, channel:getMin(), channel:getMax())
    state.target = target
    if state.current == nil then
        state.current = target -- immediate start/A-B comparison; later weather changes ease in
    end
    local alpha = clamp(elapsed / Settings.transitionMinutes, 0, 1)
    state.current = state.current + (target - state.current) * alpha
    channel:setOverride(state.current, 1.0)
    channel:setEnableOverride(true)
end

local function update(immediate)
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
    if lastMinute and minute < lastMinute then
        release() -- a different world/clock must not retain the previous world channels
        lastMinute = nil
    end
    if not immediate and lastMinute and minute == lastMinute then return end
    local elapsed = immediate and Settings.transitionMinutes or (lastMinute and clamp(minute - lastMinute, 1, 60) or 1)
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
            (Settings.hazeFloor + pulse + math.max(0, cloud - 0.5) * 0.06)
            * intensity * hazeScale)
        apply(manager, 'cloud', CM.FLOAT_CLOUD_INTENSITY,
            cloud + (math.max(cloud, Settings.cloudFloor) - cloud) * intensity, elapsed)
        apply(manager, 'fog', CM.FLOAT_FOG_INTENSITY,
            math.max(fog, addedHaze, preview == 'haze' and 0.35 or 0), elapsed)
        apply(manager, 'daylight', CM.FLOAT_DAYLIGHT_STRENGTH,
            math.min(preview == 'night' and 0.10 or 1, daylight * (1 - (1 - Settings.daylightFactor) * intensity * darknessScale)), elapsed)
        apply(manager, 'ambient', CM.FLOAT_AMBIENT,
            math.min(preview == 'night' and 0.25 or 1, ambient * (1 - (1 - Settings.ambientFactor) * intensity * darknessScale)), elapsed)
        apply(manager, 'globalLight', CM.FLOAT_GLOBAL_LIGHT_INTENSITY,
            math.min(preview == 'night' and 0.20 or 1, globalLight * (1 - (1 - Settings.globalLightFactor) * intensity * darknessScale)), elapsed)
        apply(manager, 'desaturation', CM.FLOAT_DESATURATION,
            desaturation + (math.max(desaturation, Settings.desaturationFloor) - desaturation) * intensity, elapsed)
        applyColdTint(manager, CM.COLOR_GLOBAL_LIGHT,
            clamp(intensity * tintScale, 0, 2))

        if not logged then
            ProjectTerm.log('info', 'Atmosphere climate layer active (single-player experimental).')
            logged = true
        end
    end)
    if not ok then
        release()
        failed = true
        ProjectTerm.warnOnce('atmosphere-api', 'Atmosphere disabled after climate error: ' .. tostring(err))
    end
end

-- Read-only snapshot for debug UI; no save data or clock changes.
function Atmosphere.getStatus()
    local enabled, intensity = preferences()
    local result = {enabled = enabled and intensity > 0 and not failed,
        failed = failed, preview = preview, channels = {}}
    for name, state in pairs(states) do
        result.channels[name] = {owned = state.owned,
            natural = state.channel:getInternalValue(), current = state.current,
            target = state.target}
    end
    return result
end

function Atmosphere.report()
    local status = Atmosphere.getStatus()
    local parts = {'Atmosphere ' .. (status.enabled and 'ON' or 'OFF'),
        'preview=' .. (preview == 'night' and 'night lighting only' or preview or 'none')}
    for _, name in ipairs({'cloud', 'fog', 'daylight', 'ambient', 'globalLight', 'desaturation'}) do
        local c = status.channels[name]
        if c then
            parts[#parts + 1] = name .. '=' .. (c.owned and
                string.format('%.2f->%.2f (natural %.2f)', c.current or 0, c.target or 0, c.natural) or 'external')
        end
    end
    ProjectTerm.log('INFO', table.concat(parts, '; '))
    return status
end

-- Reversible render-channel previews, never simulated time or saved weather.
function Atmosphere.setPreview(mode)
    if mode ~= nil and mode ~= 'haze' and mode ~= 'night' then return false, 'Unknown preview' end
    if mode ~= nil and not ProjectTerm.getConfig().Debug then return false, 'Enable debug mode for previews' end
    if (isClient and isClient()) or (isServer and isServer()) then return false, 'Single-player only' end
    local enabled, intensity = preferences()
    if not enabled or intensity <= 0 or failed then return false, 'Atmosphere is disabled' end
    preview = mode
    update(true)
    Atmosphere.report()
    return not failed, failed and 'Climate API failure' or 'Preview updated'
end

Events.OnGameStart.Add(function()
    release()
    lastMinute, failed, logged, colorFailed = nil, false, false, false
    runtimeEnabled = true
    preview = nil
    update(true)
    Atmosphere.report()
end)
Events.EveryOneMinute.Add(function() update(false) end)

-- Direct on/off comparison in single-player, including existing saves whose
-- sandbox page was unavailable when the save was created.
if Events.OnKeyPressed then
    Events.OnKeyPressed.Add(function(key)
        if not Keyboard or key ~= Keyboard.KEY_F8 then return end
        if (isClient and isClient()) or (isServer and isServer()) then return end
        runtimeEnabled = not runtimeEnabled
        if not runtimeEnabled then preview = nil; release() end
        lastMinute = nil
        if runtimeEnabled then update(true) end
        Atmosphere.report()
    end)
end

-- Release the channels while the old world still exists.
if Events.OnMainMenuEnter then
    Events.OnMainMenuEnter.Add(function()
        release()
        preview = nil
        lastMinute, failed, logged, colorFailed = nil, false, false, false
    end)
end
