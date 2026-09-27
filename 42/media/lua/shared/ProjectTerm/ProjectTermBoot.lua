require "ProjectTerm/ProjectTermConfig"

local function onGameBoot()
    ProjectTerm.log("INFO", "v" .. ProjectTerm.VERSION .. " scripts loaded; target 42.20.4, single-player experimental")
    ProjectTerm.log("INFO", "Arc Pulse Rifle test item: ProjectTerm.ArcPulseRifle")
end

Events.OnGameBoot.Add(onGameBoot)
