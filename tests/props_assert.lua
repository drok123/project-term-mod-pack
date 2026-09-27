local P = ProjectTerm.Props
assert(P.place(player) and P.status().count == 2)
assert(lookups == 4, "bounded adjacent search")
assert(not P.place(player) and P.status().count == 2, "persistent cap")
local a,b = squares['11:20'], squares['10:21']
local unrelated = {getItem=function() return makeItem('Base.Cow_Skull') end}
table.insert(a.objects,unrelated)
local held = b.objects[1]:getItem()
table.remove(b.objects,1); table.insert(inventoryItems,held)
assert(P.cleanup(player) and #a.objects == 1 and a.objects[1] == unrelated, "cleanup only tagged")
assert(#inventoryItems == 0 and P.status().count == 0, "inventory cleanup")
a.free=false; b.solid=false; squares['9:20'].free=false
assert(not P.place(player) and P.status().count == 0, "two free floors required")
a.free=true; b.solid=true
assert(P.place(player))
squares['11:20']=nil
assert(not P.cleanup(player) and P.status().count == 1, "unloaded record retained")
assert(not P.place(player), "unloaded records cannot bypass cap")
squares['11:20']=a
assert(P.cleanup(player))
client=true
assert(not P.place(player) and P.status().count == 0, "SP only")
client=false; SandboxVars.ProjectTerm.Debug=false
assert(not P.place(player), "debug only")
