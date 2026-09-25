ProjectTerm = ProjectTerm or {}

local PREFIX = "[ProjectTerm] "

local function log(message)
    print(PREFIX .. tostring(message))
end

local function onGameBoot()
    log("Build 42 prototype scripts loaded")
    log("Arc Pulse Rifle test item: ProjectTerm.ArcPulseRifle")
end

Events.OnGameBoot.Add(onGameBoot)
