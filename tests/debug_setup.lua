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
menu = {}
ProjectTerm = {
    Atmosphere = {report=function() end, setPreview=function() end},
    Props = {place=function() end, cleanup=function() end},
    Ambience = {preview=function() end, stop=function() end},
}
context = {addOption = function(_, label, target, fn)
    menu[label] = function() fn(target) end
    if label == "Project Term: give weapon test kit" then callbacks.give = menu[label] end
end}
