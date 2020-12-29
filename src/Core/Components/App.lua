local PluginRoot = script.Parent.Parent.Parent
local Roact: Roact = require(PluginRoot.Packages.Roact)

local ThemeProvider = require(script.Parent.ThemeProvider)
local Header = require(script.Parent.Header)
local Pages = require(script.Parent.Pages)

local App = Roact.Component:extend("App")

function App:render()
    return ThemeProvider.withTheme(function(theme: StudioTheme)
        return Roact.createElement("Frame", {
            BorderSizePixel = 0,
            BackgroundColor3 = theme:GetColor("MainBackground"),
            Size = UDim2.fromScale(1, 1),
            ClipsDescendants = true,
        }, {
            Header = Roact.createElement(Header),
            Pages = Roact.createElement(Pages),
        })
    end)
end

return App
