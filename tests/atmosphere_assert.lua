
        assert(callbacks.start and callbacks.minute)
        callbacks.start()
        for i=1,90 do
            clock.age = clock.age + 1/60
            callbacks.minute()
        end
        assert(climate[1].enabled and climate[1].value > 0.5, 'cloud floor')
        assert(climate[2].enabled and climate[2].value > 0.09 and climate[2].value < 0.25, 'low haze')
        assert(climate[3].value < climate[3].natural, 'dim daylight')
        assert(climate[4].value < climate[4].natural, 'dim ambient')
        assert(climate[6].value > 0.16, 'desaturation')
        assert(color.enabled, 'color channel enabled')
        assert(color.value.exterior[1] < .8 and color.value.exterior[3] == .65,
            'exterior cools without changing blue')
        assert(color.value.interior[1] > .48 and color.value.interior[4] == .8,
            'interior tint weaker and natural alpha preserved')
        climate[2].natural = 0.75
        for i=1,90 do clock.age = clock.age + 1/60; callbacks.minute() end
        assert(climate[2].value > 0.7, 'natural heavy fog preserved')
        SandboxVars.ProjectTerm = nil -- an existing save without this mod's sandbox page
        callbacks.key(Keyboard.KEY_F8)
        for _, channel in pairs(climate) do assert(not channel.enabled, 'F8 OFF releases overrides') end
        assert(not color.enabled, 'F8 OFF releases color')
        callbacks.key(Keyboard.KEY_F8)
        assert(climate[1].enabled, 'F8 ON restores climate pass')
        assert(color.enabled, 'F8 ON restores color')
        SandboxVars.ProjectTerm = {AtmosphereEnabled=true, AtmosphereIntensity=1,
            HazeDensity=1, Darkness=1}
        SandboxVars.ProjectTerm.AtmosphereEnabled = false
        clock.age = clock.age + 1/60
        callbacks.minute()
        for _, channel in pairs(climate) do assert(not channel.enabled, 'disabled releases overrides') end
        assert(not color.enabled, 'disabled releases color')
        SandboxVars.ProjectTerm.AtmosphereEnabled = true
        SandboxVars.ProjectTerm.HazeDensity = 0
        SandboxVars.ProjectTerm.Darkness = 0
        SandboxVars.ProjectTerm.ColdTint = 0
        climate[2].natural = 0
        clock.age = clock.age + 1/60
        callbacks.minute()
        for i=1,90 do clock.age = clock.age + 1/60; callbacks.minute() end
        assert(climate[2].value < 0.01, 'zero added haze')
        assert(math.abs(climate[3].value - climate[3].natural) < 0.01, 'zero darkness')
        assert(not color.enabled, 'zero cold tint releases color')
        SandboxVars.ProjectTerm.ColdTint = 1
        color.enabled = true -- simulate a second mod already owning the color override
        clock.age = clock.age + 1/60
        callbacks.minute()
        assert(color.enabled, 'other mod color ownership respected')
        isClient = function() return true end
        clock.age = clock.age + 1/60
        callbacks.minute()
        for _, channel in pairs(climate) do assert(not channel.enabled, 'release in multiplayer') end
        assert(color.enabled, 'other mod color remains enabled')
        isClient = function() return false end
        color.enabled = false
        ClimateColorInfo = nil -- simulate a B42 patch without exposed color constructor
        callbacks.start()
        assert(climate[1].enabled, 'color API failure does not disable haze pass')
        assert(not color.enabled, 'color API failure does not hold a color override')
    
ClimateColorInfo = {new=function() error('unavailable') end}
callbacks.start()
clock.age = 1
callbacks.minute()
assert(climate[1].enabled, 'clock rewind recovers')
callbacks.menu()
for _, channel in pairs(climate) do assert(not channel.enabled, 'menu releases overrides') end

-- Existing float overrides must survive both runtime and menu cleanup.
climate[1].enabled = true
climate[1].value = 0.123
callbacks.start()
assert(climate[1].value == 0.123, 'foreign float untouched')
callbacks.menu()
assert(climate[1].enabled, 'foreign float not released')
climate[1].enabled = false
-- A float API failure releases channels already acquired; next game can retry.
local original = manager.getClimateFloat
manager.getClimateFloat = function(self, id) if id == 3 then error('missing channel') end return original(self,id) end
callbacks.start()
for _, channel in pairs(climate) do assert(not channel.enabled, 'failure releases all owned floats') end
manager.getClimateFloat = original
callbacks.start()
assert(climate[1].enabled, 'new game resets failure latch')
callbacks.menu()
