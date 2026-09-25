#!/usr/bin/env python3
"""Run the atmosphere Lua against a tiny climate mock; never claims in-game proof."""
import ctypes
import ctypes.util
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / '42/media/lua/client/PTMP_Atmosphere.lua'
library = ctypes.util.find_library('lua5.4')
if not library:
    raise SystemExit('Lua 5.4 shared library unavailable; cannot run mock check')
lua = ctypes.CDLL(library)
lua.luaL_newstate.restype = ctypes.c_void_p
lua.luaL_openlibs.argtypes = [ctypes.c_void_p]
lua.luaL_loadstring.argtypes = [ctypes.c_void_p, ctypes.c_char_p]
lua.luaL_loadfilex.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_char_p]
lua.lua_pcallk.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int, ctypes.c_int, ctypes.c_longlong, ctypes.c_void_p]
lua.lua_tolstring.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_void_p]
lua.lua_tolstring.restype = ctypes.c_char_p
lua.lua_close.argtypes = [ctypes.c_void_p]
state = lua.luaL_newstate()
lua.luaL_openlibs(state)


def run(code: bytes, filename=False):
    loaded = lua.luaL_loadfilex(state, code, None) if filename else lua.luaL_loadstring(state, code)
    if loaded or lua.lua_pcallk(state, 0, 0, 0, 0, None):
        raise RuntimeError(lua.lua_tolstring(state, -1, None).decode())


try:
    run(b'''
        callbacks = {}
        Events = {
            OnGameStart = { Add = function(f) callbacks.start = f end },
            EveryOneMinute = { Add = function(f) callbacks.minute = f end }
        }
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
        manager = { getClimateFloat = function(_, i) return climate[i] end }
        clock = { age = 100, getWorldAgeHours = function(self) return self.age end }
        function getClimateManager() return manager end
        function getGameTime() return clock end
        function isClient() return false end
        function isServer() return false end
        SandboxVars = {ProjectTerm = {AtmosphereEnabled=true, AtmosphereIntensity=1,
            HazeDensity=1, Darkness=1}}
    ''')
    run(str(SOURCE).encode(), filename=True)
    run(b'''
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
        climate[2].natural = 0.75
        for i=1,90 do clock.age = clock.age + 1/60; callbacks.minute() end
        assert(climate[2].value > 0.7, 'natural heavy fog preserved')
        SandboxVars.ProjectTerm.AtmosphereEnabled = false
        clock.age = clock.age + 1/60
        callbacks.minute()
        for _, channel in pairs(climate) do assert(not channel.enabled, 'disabled releases overrides') end
        SandboxVars.ProjectTerm.AtmosphereEnabled = true
        SandboxVars.ProjectTerm.HazeDensity = 0
        SandboxVars.ProjectTerm.Darkness = 0
        climate[2].natural = 0
        clock.age = clock.age + 1/60
        callbacks.minute()
        for i=1,90 do clock.age = clock.age + 1/60; callbacks.minute() end
        assert(climate[2].value < 0.01, 'zero added haze')
        assert(math.abs(climate[3].value - climate[3].natural) < 0.01, 'zero darkness')
        isClient = function() return true end
        clock.age = clock.age + 1/60
        callbacks.minute()
        for _, channel in pairs(climate) do assert(not channel.enabled, 'release in multiplayer') end
    ''')
    print('Lua syntax and mocked climate behavior: OK (game behavior untested)')
finally:
    lua.lua_close(state)
