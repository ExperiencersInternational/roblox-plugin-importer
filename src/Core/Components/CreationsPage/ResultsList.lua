local PluginRoot = script.Parent.Parent.Parent.Parent
local Roact: Roact = require(PluginRoot.Packages.Roact)

local ThemeProvider = require(script.Parent.Parent.ThemeProvider)
local ResultsCanvas = require(script.Parent.ResultsCanvas)

local ResultsList = Roact.Component:extend("ResultsList")

function ResultsList:render()
    return ThemeProvider.withTheme(function(theme: StudioTheme)
        return Roact.createElement("Frame", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.fromScale(1, 1),
            Position = UDim2.fromScale(0, 1),
            ClipsDescendants = true,
        }, {
            ScrollBackground = Roact.createElement("Frame", {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundColor3 = theme:GetColor("Border"),
                BorderSizePixel = 0,
                Position = UDim2.fromScale(1, 0),
                Size = UDim2.new(0, 16, 1, 0),
                ClipsDescendants = true,
            }),

            Canvas = Roact.createElement(ResultsCanvas),
        })
    end)
end

return ResultsList
