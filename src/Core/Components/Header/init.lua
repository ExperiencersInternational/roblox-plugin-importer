local PluginRoot = script.Parent.Parent.Parent
local Roact: Roact = require(PluginRoot.Packages.Roact)

local ThemeProvider = require(script.Parent.ThemeProvider)
local TabBar = require(script.TabBar)

local Header = Roact.Component:extend("Header")

function Header:render()
    return ThemeProvider.withTheme(function(theme: StudioTheme)
        return Roact.createElement("Frame", {
            BackgroundColor3 = theme:GetColor("RibbonTab"),
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 36),
            ClipsDescendants = true,
        }, {
            TabBar = Roact.createElement(TabBar),
        })
    end)
end

return Header
