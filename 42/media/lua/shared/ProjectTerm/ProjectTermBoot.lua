ProjectTerm = ProjectTerm or {}
local PREFIX = "[ProjectTerm] "
local function onGameBoot()
 print(PREFIX .. "Build 42 prototype scripts loaded")
 print(PREFIX .. "Arc Pulse Rifle test item: ProjectTerm.ArcPulseRifle")
end
Events.OnGameBoot.Add(onGameBoot)
