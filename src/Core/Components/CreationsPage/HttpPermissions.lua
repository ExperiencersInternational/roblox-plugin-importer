local TextService = game:GetService("TextService")

local PluginRoot = script.Parent.Parent.Parent.Parent

local Roact: Roact = require(PluginRoot.Packages.Roact)
local PluginSettings = require(PluginRoot.Libraries.PluginSettings)
local PluginImporter = require(PluginRoot.Libraries.PluginImporter)

local ThemeProvider = require(script.Parent.Parent.ThemeProvider)

local HttpPermissions = Roact.Component:extend("HttpPermissions")

local Strings = {
    Button = "Allow",
    Prompt = "We need permission to use HTTP requests to fetch your creations. Click the button below to allow.",
}

function HttpPermissions:init()
    self:setState({
        promptSize = UDim2.fromOffset(0, 14),
    })

    self.containerRef = Roact.createRef()
end

function HttpPermissions:RecalculateWidths()
    local container = self.containerRef:getValue()

    if not container then
        return
    end

    local promptSize = TextService:GetTextSize(Strings.Prompt, 14, Enum.Font.Gotham, Vector2.new()).X + 32
    local containerWidth = container.AbsoluteSize.X - 32

    self:setState({
        promptSize = UDim2.fromOffset(
            promptSize > containerWidth and containerWidth or promptSize,
            14 * ((math.floor(promptSize / containerWidth) % 14) + 1)
        )
    })
end

function HttpPermissions:didMount()
    self:RecalculateWidths()
end

function HttpPermissions:render()
    local widths = {
        Button = TextService:GetTextSize(Strings.Button, 14, Enum.Font.GothamSemibold, Vector2.new()).X,
    }

    return ThemeProvider.withTheme(function(theme: StudioTheme)
        return Roact.createElement("Frame", {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.fromScale(1, 1),
            ClipsDescendants = true,

            [Roact.Ref] = self.containerRef,
            [Roact.Change.AbsoluteSize] = function()
                self:RecalculateWidths()
            end,
        }, {
            ListLayout = Roact.createElement("UIListLayout", {
                Padding = UDim.new(0, 8),
                FillDirection = Enum.FillDirection.Vertical,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Center,
            }),

            Padding = Roact.createElement("UIPadding", {
                PaddingBottom = UDim.new(0, 16),
                PaddingLeft = UDim.new(0, 16),
                PaddingRight = UDim.new(0, 16),
                PaddingTop = UDim.new(0, 16),
            }),

            PromptText = Roact.createElement("TextLabel", {
                BackgroundTransparency = 1,
                Size = self.state.promptSize,
                Font = Enum.Font.Gotham,
                Text = "We need permission to use HTTP requests to fetch your creations. Click the button below to allow.",
                TextColor3 = theme:GetColor("MainText"),
                TextSize = 14,
                TextWrapped = true,
            }),

            AllowButton = Roact.createElement("TextButton", {
                BackgroundColor3 = theme:GetColor("DialogMainButton"),
                BorderColor3 = theme:GetColor("ButtonBorder"),
                BorderSizePixel = 1,
                Size = UDim2.fromOffset(
                    widths.Button + 16,
                    14 + 16
                ),
                LayoutOrder = 100,
                Font = Enum.Font.GothamSemibold,
                Text = "Allow",
                TextColor3 = theme:GetColor("DialogMainButtonText"),
                TextSize = 14,

                [Roact.Event.MouseButton1Click] = function()
                    PluginImporter.UpdateCreationsInStore()
                end,
            }, {
                BorderRadius = Roact.createElement("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                }),
            }),
        })
    end)
end

return PluginSettings.__state:Roact(HttpPermissions, { "HttpPermissionRequested" })
