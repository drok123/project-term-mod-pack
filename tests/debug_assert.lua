callbacks.menu(0, context, {}, false)
assert(not callbacks.give, "debug disabled by default")
SandboxVars.ProjectTerm.Debug = true
callbacks.menu(0, context, {}, true)
assert(not callbacks.give, "test pass has no mutation")
callbacks.menu(0, context, {}, false)
assert(callbacks.give)
callbacks.give()
assert(#items == 50 and items[1] == "ProjectTerm.ArcPulseRifle" and items[2] == "ProjectTerm.ArcCell")
client = true
callbacks.give()
assert(#items == 50, "callback rechecks multiplayer")
print("PASS debug: opt-in menu, bounded kit, multiplayer guarded")
