local PluginRoot = script.Parent.Parent.Parent.Parent
local Store = require(PluginRoot.Data.Store)

local ResourceImage = require(PluginRoot.Data.Images)
local Roact: Roact = require(PluginRoot.Packages.Roact)

local ThemeProvider = require(script.Parent.Parent.ThemeProvider)
local TabButton = require(script.Parent.TabButton)

local TabBar = Roact.Component:extend("TabBar")

function TabBar:render()
    local location = self.state.Location

    return ThemeProvider.withTheme(function(theme: StudioTheme)
        return Roact.createElement("Frame", {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 36),
            ClipsDescendants = true,
        }, {
            GridLayout = Roact.createElement("UIGridLayout", {
                CellPadding = UDim2.new(),
                CellSize = UDim2.fromScale(.5, 1),
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                SortOrder = Enum.SortOrder.LayoutOrder,
                StartCorner = Enum.StartCorner.TopLeft,
                VerticalAlignment = Enum.VerticalAlignment.Top,
            }),

            Recent = Roact.createElement(TabButton, {
                Label = "Recent",
                Icon = ResourceImage.TabButtonIcon.Recents,
                Selected = location == "/recents",
                LayoutOrder = 100,

                Clicked = function()
                    Store:GoTo("/recents")
                end,
            }),

            Creations = Roact.createElement(TabButton, {
                Label = "Creations",
                Icon = ResourceImage.TabButtonIcon.Creations,
                Selected = location == "/creations",
                LayoutOrder = 200,

                Clicked = function()
                    Store:GoTo("/creations")
                end,
            })
        })
    end)
end

return Store:Roact(TabBar, { "Location" })
