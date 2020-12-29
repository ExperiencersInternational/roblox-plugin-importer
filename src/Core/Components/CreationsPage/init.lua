local PluginRoot = script.Parent.Parent.Parent

local Roact: Roact = require(PluginRoot.Packages.Roact)
local Store = require(PluginRoot.Data.Store)
local PluginSettings = require(PluginRoot.Libraries.PluginSettings)
local PluginImporter = require(PluginRoot.Libraries.PluginImporter)

local HttpPermissions = require(script.HttpPermissions)

local CreationsPage = Roact.Component:extend("CreationsPage")

function CreationsPage:didMount()
    if self.state.HttpPermissionRequested then
        PluginImporter.UpdateCreationsInStore()
    end
end

function CreationsPage:render()
    return Roact.createElement("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        ClipsDescendants = true,

        Visible = self.state.Location == "/creations",
    }, {
        HttpPermissions = not self.state.HttpPermissionRequested and Roact.createElement(HttpPermissions),
    })
end

return PluginSettings.__state:Roact(
    Store:Roact(CreationsPage, { "Location" }),
    { "HttpPermissionRequested" }
)