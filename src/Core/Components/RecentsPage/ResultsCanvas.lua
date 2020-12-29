local PluginRoot = script.Parent.Parent.Parent.Parent

local PluginImporter = require(PluginRoot.Libraries.PluginImporter)
local PluginSettings = require(PluginRoot.Libraries.PluginSettings)
local Roact: Roact = require(PluginRoot.Packages.Roact)

local ThemeProvider = require(script.Parent.Parent.ThemeProvider)
local PluginItem = require(script.Parent.Parent.PluginItem)

local ResultsCanvas = Roact.Component:extend("ResultsCanvas")

function ResultsCanvas:GetPluginItems()
    local pluginItems = {}

    for index, pluginInfo in ipairs(PluginSettings:Get("RecentItems", {})) do
        pluginItems[index] = Roact.createElement(PluginItem, {
            Label = pluginInfo.Name,
            Id = pluginInfo.Id,

            Clicked = function()
                PluginImporter.ImportPlugin(pluginInfo.Name, pluginInfo.Id)
            end,
        })
    end

    return pluginItems
end

function ResultsCanvas:render()
    return ThemeProvider.withTheme(function(theme: StudioTheme)
        return Roact.createElement("ScrollingFrame", {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, -4, 1, 0),
            ZIndex = 100,
            ClipsDescendants = true,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            CanvasSize = UDim2.new(),
            ScrollBarImageColor3 = theme:GetColor("ScrollBar"),
            ScrollBarThickness = 8,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            VerticalScrollBarInset = Enum.ScrollBarInset.Always,
        }, {
            Padding = Roact.createElement("UIPadding", {
                PaddingBottom = UDim.new(0, 16),
                PaddingLeft = UDim.new(0, 16),
                PaddingRight = UDim.new(0, 16),
                PaddingTop = UDim.new(0, 16),
            }),

            GridLayout = Roact.createElement("UIGridLayout", {
                CellPadding = UDim2.fromOffset(16, 16),
                CellSize = UDim2.fromOffset(100, 140),
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                SortOrder = Enum.SortOrder.LayoutOrder,
                StartCorner = Enum.StartCorner.TopLeft,
                VerticalAlignment = Enum.VerticalAlignment.Top,
            }),

            Roact.createFragment(self:GetPluginItems()),
        })
    end)
end

return PluginSettings.__state:Roact(ResultsCanvas, { "RecentItems" })
