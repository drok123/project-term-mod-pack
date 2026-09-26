callbacks = {}
function require(_) end
Events = {OnFillWorldObjectContextMenu = {Add = function(fn) callbacks.menu = fn end}}
SandboxVars = {ProjectTerm = {Debug = false}}
client, server = false, false
function isClient() return client end
function isServer() return server end
items = {}
player = {getInventory = function() return {AddItem = function(_, name) table.insert(items, name); return {} end} end}
function getSpecificPlayer(_) return player end
context = {addOption = function(_, _, target, fn) callbacks.give = function() fn(target) end end}
