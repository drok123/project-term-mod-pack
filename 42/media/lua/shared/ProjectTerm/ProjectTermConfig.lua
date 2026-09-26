ProjectTerm = ProjectTerm or {}
ProjectTerm.VERSION = "0.3.0"
local warned = {}

function ProjectTerm.getConfig()
    local vars = SandboxVars and SandboxVars.ProjectTerm or {}
    local function number(name, fallback, maximum)
        local value = tonumber(vars[name])
        if not value or value ~= value then value = fallback end
        return math.max(0, math.min(maximum, value))
    end
    return {
        Debug = vars.Debug == true,
        WeaponLootMultiplier = number("WeaponLootMultiplier", 1, 5),
        AmmoLootMultiplier = number("AmmoLootMultiplier", 1, 5),
        AmbienceEnabled = vars.AmbienceEnabled ~= false,
        AudioFrequency = number("AudioFrequency", 1, 3),
    }
end

function ProjectTerm.log(level, message)
    level = string.upper(tostring(level))
    if level == "DEBUG" and not ProjectTerm.getConfig().Debug then return end
    print("[ProjectTerm][" .. tostring(level) .. "] " .. tostring(message))
end

function ProjectTerm.warnOnce(key, message)
    if warned[key] then return end
    warned[key] = true
    ProjectTerm.log("WARN", message)
end
