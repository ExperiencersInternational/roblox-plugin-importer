local PluginRoot = script.Parent

local PluginSettings = require(PluginRoot.Libraries.PluginSettings)
PluginSettings.Init(plugin)

-- local Config = require(PluginRoot.Config)
local MakeFacade = require(PluginRoot.Core.MakeFacade)
local RoactInstance = require(PluginRoot.Core.RoactInstance)

do
    local Facade = MakeFacade(plugin)
    local RoactApp = RoactInstance(Facade.MainWindow)

    plugin.Unloading:Connect(RoactApp.Unmount)
end
