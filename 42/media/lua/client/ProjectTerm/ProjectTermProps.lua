require "ProjectTerm/ProjectTermConfig"
ProjectTerm.Props = {}
local P = ProjectTerm.Props
local KEY = "ProjectTermPropProof"
local CAP = 2

local function allowed()
    return ProjectTerm.getConfig().Debug and not isClient() and not isServer()
end

local function data()
    local value = ModData.getOrCreate(KEY)
    value.placements = value.placements or {}
    value.serial = value.serial or 0
    return value
end

function P.status()
    local value = data()
    return {count = #value.placements, cap = CAP}
end

function P.place(player)
    if not allowed() or not player or not getCell() then return false end
    local value = data()
    if #value.placements > 0 then
        ProjectTerm.log("INFO", "Prop set already recorded; clean it up before placing another.")
        return false
    end
    local x, y, z = math.floor(player:getX()), math.floor(player:getY()), math.floor(player:getZ())
    local squares = {}
    -- Only four adjacent tiles, on real floor and free of occupied obstacles.
    for _, offset in ipairs({{1, 0}, {0, 1}, {-1, 0}, {0, -1}}) do
        local square = getCell():getGridSquare(x + offset[1], y + offset[2], z)
        if square and square:TreatAsSolidFloor() and square:isFree(false) then
            table.insert(squares, square)
        end
    end
    if #squares < CAP then
        ProjectTerm.log("INFO", "Prop proof needs two free adjacent floor tiles.")
        return false
    end
    for i, fullType in ipairs({"Base.Cow_Skull", "ProjectTerm.SentinelWreck"}) do
        local square = squares[i]
        local item = square:AddWorldInventoryItem(fullType, 0.5, 0.5, 0)
        if item then
            value.serial = value.serial + 1
            local token = KEY .. ":" .. tostring(value.serial)
            item:getModData().ProjectTermPropToken = token
            table.insert(value.placements, {x = square:getX(), y = square:getY(), z = square:getZ(), token = token})
        else
            ProjectTerm.warnOnce("prop:" .. fullType, "Could not create prop " .. fullType)
        end
    end
    ProjectTerm.log("INFO", "Placed " .. tostring(#value.placements) .. "/2 prop proof items; inert world items, no collision added.")
    return #value.placements == CAP
end

function P.cleanup(player)
    if not allowed() or not player or not getCell() then return false end
    local value = data()
    for i = #value.placements, 1, -1 do
        local entry = value.placements[i]
        local removed = false
        local square = getCell():getGridSquare(entry.x, entry.y, entry.z)
        if square then
            local objects = square:getWorldObjects()
            for j = objects:size() - 1, 0, -1 do
                local object = objects:get(j)
                local item = object:getItem()
                if item and item:getModData().ProjectTermPropToken == entry.token then
                    square:transmitRemoveItemFromSquare(object)
                    removed = true
                end
            end
        end
        -- Also handle a proof item picked up into the player's main inventory.
        local inventory = player:getInventory()
        if not removed and inventory then
            local items = inventory:getItems()
            for j = items:size() - 1, 0, -1 do
                local item = items:get(j)
                if item:getModData().ProjectTermPropToken == entry.token then
                    inventory:Remove(item)
                    removed = true
                end
            end
        end
        if removed then table.remove(value.placements, i) end
    end
    ProjectTerm.log("INFO", "Prop cleanup: " .. tostring(#value.placements) .. " unresolved. Return moved items to their original tile or main inventory before retrying.")
    return #value.placements == 0
end
