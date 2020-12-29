local PluginRoot = script.Parent.Parent.Parent

local Roact: Roact = require(PluginRoot.Packages.Roact)
local Store = require(PluginRoot.Data.Store)

local Header = require(script.Header)
local ResultsList = require(script.ResultsList)

local RecentsPage = Roact.Component:extend("RecentsPage")

function RecentsPage:render()
    return Roact.createElement("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        ClipsDescendants = true,

        Visible = self.state.Location == "/recents",
    }, {
        Header = Roact.createElement(Header),
        Content = Roact.createElement(ResultsList),
    })
end

return Store:Roact(RecentsPage, { "Location" })
