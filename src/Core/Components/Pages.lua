local PluginRoot = script.Parent.Parent.Parent
local Roact: Roact = require(PluginRoot.Packages.Roact)

local RecentsPage = require(script.Parent.RecentsPage)
local CreationsPage = require(script.Parent.CreationsPage)

local Pages = Roact.Component:extend("Pages")

function Pages:render()
    return Roact.createElement("Frame", {
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -36),
        Position = UDim2.fromOffset(0, 36),
        ClipsDescendants = true,
    }, {
        RecentsPage = Roact.createElement(RecentsPage),
        CreationsPage = Roact.createElement(CreationsPage),
    })
end

return Pages
