local PluginRoot = script.Parent.Parent.Parent

local ResourceURLs = require(PluginRoot.Data.URLs)
local Roact: Roact = require(PluginRoot.Packages.Roact)

local ThemeProvider = require(script.Parent.ThemeProvider)

local PluginItem = Roact.Component:extend("PluginItem")

function PluginItem:render()
    local props = self.props
    local themeModifier = "Default"

    return ThemeProvider.withTheme(function(theme: StudioTheme)
        return Roact.createElement("TextButton", {
            AutoButtonColor = false,
            BackgroundTransparency = 1,
            ClipsDescendants = true,
            Text = "",

            [Roact.Event.MouseButton1Click] = props.Clicked,
        }, {
            Thumbnail = props.Id and Roact.createElement("ImageLabel", {
                AnchorPoint = Vector2.new(.5, 0),
                BackgroundTransparency = 1,
                Position = UDim2.fromScale(.5, 0),
                Size = UDim2.fromOffset(100, 100),
                ClipsDescendants = true,
                Image = string.format(ResourceURLs.ThumbnailUrl, props.Id, 150, 150),
                ImageColor3 = Color3.new(1, 1, 1),
                ScaleType = Enum.ScaleType.Fit,
            }),

            Label = props.Label and Roact.createElement("TextLabel", {
                AnchorPoint = Vector2.new(0, 1),
                BackgroundTransparency = 1,
                Position = UDim2.fromScale(0, 1),
                Size = UDim2.new(1, 0, 1, -108),
                ClipsDescendants = true,
                Font = Enum.Font.Gotham,
                Text = props.Label,
                TextColor3 = theme:GetColor("LinkText", themeModifier),
                TextSize = 14,
                TextTruncate = Enum.TextTruncate.AtEnd,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
            }),
        })
    end)
end

PluginItem.DefaultProps = {
    --[[string?]] Label = nil,
    --[[number?]] Id = nil,

    --[[() -> any?]] Clicked = nil,
}

return PluginItem
