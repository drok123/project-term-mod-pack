local HunterConfig = require "ProjectTerm/ProjectTermHunterConfig"

ProjectTerm = ProjectTerm or {}

local PREFIX = "[ProjectTerm] "
local generation = 0

local function log(message)
    print(PREFIX .. tostring(message))
end

local function restorePooledState(zombie, oldState)
    if not oldState or not oldState.isHunter then return end

    -- Remove our durability before this pooled Java object represents another
    -- zombie. Resetting unconditionally also covers a previously damaged hunter.
    if oldState.baseHealth then
        pcall(function()
            zombie:setHealth(oldState.baseHealth)
        end)
    end
end

local function resetHunterState(zombie)
    local modData = zombie:getModData()
    local oldState = modData.ProjectTerm
    restorePooledState(zombie, oldState)

    generation = generation + 1
    modData.ProjectTerm = {
        isHunter = false,
        optics = false,
        generation = generation,
    }
    return modData.ProjectTerm
end

local function applyHunterState(zombie, forced, state)
    state = state or resetHunterState(zombie)
    local baseHealth = zombie:getHealth()
    local hunterHealth = baseHealth * HunterConfig.getHealthMultiplier()

    zombie:setHealth(hunterHealth)
    state.isHunter = true
    state.optics = true
    state.forced = forced == true
    state.baseHealth = baseHealth
    state.hunterHealth = hunterHealth
    state.difficulty = HunterConfig.getDifficulty()
    return zombie
end

local function onZombieCreate(zombie)
    if not zombie then return end

    -- Always reset first: IsoZombie objects are pooled in B42.
    local state = resetHunterState(zombie)
    if not HunterConfig.isEnabled() then return end

    if ZombRandFloat(0.0, 100.0) < HunterConfig.getChance() then
        applyHunterState(zombie, false, state)
    end
end

local function onZombieDead(zombie)
    if not zombie then return end
    local state = zombie:getModData().ProjectTerm
    if state then
        state.optics = false
    end
end

function ProjectTerm.SpawnHunter()
    if not isDebugEnabled() then
        log("SpawnHunter refused: launch with -debug")
        return nil
    end

    local player = getPlayer()
    if not player then
        log("SpawnHunter failed: no local player")
        return nil
    end

    local zombie = createZombie(
        player:getX() + 3.0,
        player:getY(),
        player:getZ(),
        nil,
        0,
        player:getDir()
    )

    if not zombie then
        log("SpawnHunter failed: createZombie returned nil")
        return nil
    end

    applyHunterState(zombie, true)
    log("forced hunter spawned near player")
    return zombie
end

Events.OnZombieCreate.Add(onZombieCreate)
Events.OnZombieDead.Add(onZombieDead)
log("hunter spawn hooks installed")
