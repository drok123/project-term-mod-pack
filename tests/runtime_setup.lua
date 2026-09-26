-- Mock only the engine boundary; execute the mod's real registry and effect files.
local function event()
    return { Add = function(callback) return callback end }
end
Events = {}
for _, name in ipairs({"OnWeaponSwingHitPoint", "OnTick", "OnMainMenuEnter"}) do
    Events[name] = event()
    local current = Events[name]
    current.Add = function(callback) current.callback = callback end
end
AmmoType = { register = function(id, item)
    assert(id == "projectterm:arc_charge")
    assert(type(item) == "string" and item == "ProjectTerm.ArcCharge")
    registryChecked = true
end }
runtimeCell = { added = 0, removed = 0 }
function runtimeCell:addLamppost(x, y, z, r, g, b, radius)
    assert(x == 10 and y == 20 and z == 0)
    assert(radius == 5)
    self.added = self.added + 1
    return {id = self.added}
end
function runtimeCell:removeLamppost(light)
    assert(light and light.id)
    self.removed = self.removed + 1
end
currentCell = runtimeCell
function getCell() return currentCell end
runtimeAttacker = {
    isDoShove = function(self) return self.shoving end,
    isRangedWeaponEmpty = function(self) return self.empty end,
    getX = function() return 10.7 end,
    getY = function() return 20.3 end,
    getZ = function() return 0 end,
}
runtimeWeapon = {
    getFullType = function(self) return self.fullType end,
    getCurrentAmmoCount = function() return 0 end,
    fullType = "ProjectTerm.ArcPulseRifle",
}
