local PluginRoot = script.Parent.Parent

local Config = require(PluginRoot.Config)
local Roact = require(PluginRoot.Packages.Roact)

local RootComponent = require(script.Parent.Components.App)

return function(mountTarget: GuiBase2d)
    local instance = Roact.mount(
        Roact.createElement(RootComponent),
        mountTarget,
        Config.PluginGUID .. ":roact-instance"
    )

    local function unmountInstance()
        Roact.unmount(instance)
    end

    return {
        Instance = instance,
        Unmount = unmountInstance,
    }
end
