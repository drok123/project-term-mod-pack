ProjectTerm = ProjectTerm or {}

local HunterConfig = {}

HunterConfig.defaults = {
    HuntersEnabled = true,
    HunterChance = 3.0,
    HunterDifficulty = 2,
    RedOpticsEnabled = true,
    MaxActiveHunterLights = 10,
}

local function projectTermSandbox()
    return SandboxVars and SandboxVars.ProjectTerm or nil
end

local function read(name)
    local options = projectTermSandbox()
    local value = options and options[name]
    if value == nil then
        return HunterConfig.defaults[name]
    end
    return value
end

local function clamp(value, minimum, maximum)
    value = tonumber(value)
    if not value then return minimum end
    if value < minimum then return minimum end
    if value > maximum then return maximum end
    return value
end

function HunterConfig.isEnabled()
    return read("HuntersEnabled") == true
end

function HunterConfig.getChance()
    return clamp(read("HunterChance"), 0.0, 100.0)
end

function HunterConfig.getDifficulty()
    return math.floor(clamp(read("HunterDifficulty"), 1, 3))
end

function HunterConfig.isOpticsEnabled()
    return read("RedOpticsEnabled") == true
end

function HunterConfig.getMaxActiveLights()
    return math.floor(clamp(read("MaxActiveHunterLights"), 0, 32))
end

function HunterConfig.getHealthMultiplier()
    local multipliers = { 1.15, 1.30, 1.50 }
    return multipliers[HunterConfig.getDifficulty()]
end

ProjectTerm.HunterConfig = HunterConfig
return HunterConfig
