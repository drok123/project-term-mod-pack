ProjectTerm = {log=function() end, warnOnce=function() end}
function require() end

        callbacks = {}
        Events = {
            OnGameStart = { Add = function(f) callbacks.start = f end },
            EveryOneMinute = { Add = function(f) callbacks.minute = f end },
            OnMainMenuEnter = { Add = function(f) callbacks.menu = f end },
            OnKeyPressed = { Add = function(f) callbacks.key = f end }
        }
        Keyboard = { KEY_F8 = 66 }
        ClimateManager = {
            FLOAT_CLOUD_INTENSITY = 1, FLOAT_FOG_INTENSITY = 2,
            FLOAT_DAYLIGHT_STRENGTH = 3, FLOAT_AMBIENT = 4,
            FLOAT_GLOBAL_LIGHT_INTENSITY = 5, FLOAT_DESATURATION = 6
        }
        climate = {}
        for i, natural in ipairs({0.15, 0.0, 0.9, 0.8, 0.8, 0.0}) do
            local c = { natural = natural, value = natural, enabled = false }
            function c:getInternalValue() return self.natural end
            function c:getMin() return 0 end
            function c:getMax() return 1 end
            function c:isEnableOverride() return self.enabled end
            function c:setOverride(value) self.value = value end
            function c:setEnableOverride(value) self.enabled = value end
            climate[i] = c
        end
        local function rgb(r,g,b,a)
            return {getR=function() return r end, getG=function() return g end,
                getB=function() return b end, getAlphaFloat=function() return a end}
        end
        local naturalColor = {getExterior=function() return rgb(.8,.7,.65,.9) end,
            getInterior=function() return rgb(.5,.4,.3,.8) end}
        color = {enabled=false, natural=naturalColor}
        function color:isEnableOverride() return self.enabled end
        function color:getInternalValue() return self.natural end
        function color:setOverride(value) self.value=value end
        function color:setEnableOverride(value) self.enabled=value end
        ClimateManager.COLOR_GLOBAL_LIGHT = 7
        ClimateColorInfo = {new=function()
            return {setExterior=function(self,r,g,b,a) self.exterior={r,g,b,a} end,
                setInterior=function(self,r,g,b,a) self.interior={r,g,b,a} end}
        end}
        manager = { getClimateFloat = function(_, i) return climate[i] end,
            getClimateColor = function(_, i) if i==7 then return color end end }
        clock = { age = 100, getWorldAgeHours = function(self) return self.age end }
        function getClimateManager() return manager end
        function getGameTime() return clock end
        function isClient() return false end
        function isServer() return false end
        SandboxVars = {ProjectTerm = {AtmosphereEnabled=true, AtmosphereIntensity=1,
            HazeDensity=1, Darkness=1}}
        next = nil -- Build 42 Kahlua does not expose Lua 5.4's next() global
    