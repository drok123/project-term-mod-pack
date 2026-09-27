function require(_) end
SandboxVars = {ProjectTerm = {Debug = true}}
client = false
function isClient() return client end
function isServer() return false end
persistent = {}
ModData = {getOrCreate = function(_) return persistent end}
local function list(items)
    items.size = function(self) return #self end
    items.get = function(self, i) return self[i + 1] end
    return items
end
inventoryItems = list({})
inventory = {getItems = function() return inventoryItems end,
    Remove = function(_, item) for i,v in ipairs(inventoryItems) do if v == item then table.remove(inventoryItems,i); break end end end}
player = {getX=function() return 10 end, getY=function() return 20 end, getZ=function() return 0 end,
    getInventory=function() return inventory end}
squares = {}
function makeItem(name)
    local md = {}
    return {name=name, getModData=function() return md end}
end
local function square(x,y)
    local sq = {x=x,y=y,free=true,solid=true,objects=list({})}
    function sq:getX() return self.x end
    function sq:getY() return self.y end
    function sq:getZ() return 0 end
    function sq:TreatAsSolidFloor() return self.solid end
    function sq:isFree(_) return self.free end
    function sq:getWorldObjects() return self.objects end
    function sq:AddWorldInventoryItem(name,_,_,_)
        local item = makeItem(name)
        table.insert(self.objects, {getItem=function() return item end})
        return item
    end
    function sq:transmitRemoveItemFromSquare(object)
        for i,v in ipairs(self.objects) do if object==v then table.remove(self.objects,i); break end end
    end
    squares[x..":"..y] = sq
end
square(11,20); square(10,21); square(9,20); square(10,19)
lookups=0
cell = {getGridSquare=function(_,x,y,z) lookups=lookups+1; return squares[x..":"..y] end}
function getCell() return cell end
