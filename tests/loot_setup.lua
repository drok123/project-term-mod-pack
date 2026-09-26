callbacks = {}
Events = {OnPostDistributionMerge = {Add = function(fn) callbacks.merge = fn end}}
function require(_) end
SandboxVars = {ProjectTerm = {}}
ProceduralDistributions = {list = {}}
for _, name in ipairs({"PoliceStorageGuns", "HuntingLockers", "GunStoreShelf", "GunStoreCounter", "ArmyStorageGuns"}) do
    ProceduralDistributions.list[name] = {items = {"Base.Test", 3}}
end
