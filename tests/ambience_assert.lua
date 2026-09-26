local A=ProjectTerm.Ambience
callbacks.OnGameStart()
assert(A.preview(player) and A.status().active)
assert(not A.preview(player) and created==1, 'one active emitter')
callbacks.OnTick(); assert(ticks==1)
lastEmitter.empty=true; callbacks.OnTick()
assert(not A.status().active and returned==1)
assert(A.preview(player))
ms=10001; callbacks.OnTick()
assert(not A.status().active and returned==2, 'hard timeout')
assert(A.preview(player)); callbacks.OnMainMenuEnter()
assert(returned==3 and not A.status().active, 'menu cleanup')
SandboxVars.ProjectTerm.AmbienceEnabled=false
assert(not A.preview(player))
SandboxVars.ProjectTerm.AmbienceEnabled=true
client=true; assert(not A.preview(player)); client=false
SandboxVars.ProjectTerm.Debug=false; assert(not A.preview(player))
callbacks.EveryOneMinute(); age=102; ms=100000; callbacks.EveryOneMinute()
assert(A.status().active, 'scheduled cue without debug')
A.stop(); local prior=created
age=105; ms=110000; callbacks.EveryOneMinute()
assert(created==prior, 'wall clock cooldown during fast forward')
ms=200000; callbacks.EveryOneMinute(); assert(created==prior+1)
SandboxVars.ProjectTerm.AudioFrequency=0; callbacks.EveryOneMinute()
assert(not A.status().active and not A.status().nextMinute)
callbacks.OnGameStart(); SandboxVars.ProjectTerm.Debug=true
soundId=0
assert(not A.preview(player) and A.status().failed)
assert(owned==returned, 'every acquired emitter returned even on failure')
soundId=1; callbacks.OnGameStart(); assert(A.preview(player), 'new session retry')
callbacks.OnMainMenuEnter()
