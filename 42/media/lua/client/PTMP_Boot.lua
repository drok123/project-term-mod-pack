-- Minimal load diagnostic. Keep this tiny until the B42 load gate is proven.
if Events and Events.OnGameStart then
    Events.OnGameStart.Add(function()
        print('[PROJECT TERM] v0.3.0 client Lua loaded; verify exact game version and console.txt.')
    end)
end
