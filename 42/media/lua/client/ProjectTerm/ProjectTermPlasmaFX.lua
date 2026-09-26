ProjectTerm = ProjectTerm or {}
local activeFlash=nil
local ticksLeft=0
local function removeFlash()
 if activeFlash and getCell() then pcall(function() getCell():removeLamppost(activeFlash) end) end
 activeFlash=nil; ticksLeft=0
end
local function addPulseFlash(attacker, weapon)
 if not attacker or not weapon or weapon:getFullType() ~= "ProjectTerm.ArcPulseRifle" then return end
 local ok,count=pcall(function() return weapon:getCurrentAmmoCount() end)
 if ok and count ~= nil and count <= 0 then return end
 removeFlash()
 local x=math.floor(attacker:getX()); local y=math.floor(attacker:getY()); local z=math.floor(attacker:getZ())
 local okLight,light=pcall(function() return getCell():addLamppost(x,y,z,0.85,0.20,1.00,5) end)
 if okLight then activeFlash=light; ticksLeft=3 end
end
local function onTick()
 if not activeFlash then return end
 ticksLeft=ticksLeft-1
 if ticksLeft<=0 then removeFlash() end
end
Events.OnWeaponSwing.Add(addPulseFlash)
Events.OnTick.Add(onTick)
