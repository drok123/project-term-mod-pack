function require(_) end
SandboxVars={ProjectTerm={Debug=true}}
callbacks={}
Events={}
for _,name in ipairs({'OnTick','EveryOneMinute','OnGameStart','OnMainMenuEnter'}) do
    local key=name
    Events[key]={Add=function(fn) callbacks[key]=fn end}
end
client=false
function isClient() return client end
function isServer() return false end
ms,age=0,100
function getTimestampMs() return ms end
function getGameTime() return {getWorldAgeHours=function() return age end} end
function ZombRand(_) return 0 end
player={getX=function() return 10 end,getY=function() return 20 end,getZ=function() return 0 end}
function getSpecificPlayer(_) return player end
created,owned,returned,ticks,stopped=0,0,0,0,0
soundId=1
world={}
function world:getFreeEmitter(x,y,z)
    assert(x==28 and y==20 and z==0, 'positional source outside player')
    created=created+1
    lastEmitter={empty=false,stopAll=function(self) stopped=stopped+1; self.empty=true end,
        playSound=function(_,name) assert(name=='ProjectTermDistantMachine'); return soundId end,
        tick=function() ticks=ticks+1 end,isEmpty=function(self) return self.empty end}
    return lastEmitter
end
function world:takeOwnershipOfEmitter(_) owned=owned+1 end
function world:returnOwnershipOfEmitter(_) returned=returned+1 end
function getWorld() return world end
