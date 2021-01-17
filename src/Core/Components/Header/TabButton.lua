local TextService = game:GetService("TextService")

local PluginRoot = script.Parent.Parent.Parent.Parent
local Roact: Roact = require(PluginRoot.Packages.Roact)

local ThemeProvider = require(script.Parent.Parent.ThemeProvider)

local TabButton = Roact.Component:extend("TabButton")
local BorderThickness = 2

type BorderPosition = {
    AnchorPoint: Vector2,
    Position: UDim2,
    Size: UDim2,
}

local BorderPosition: { [string]: BorderPosition } = {
    Top = { AnchorPoint = Vector2.new(), Position = UDim2.new(), Size = UDim2.new(1, 0, 0, BorderThickness), },
    Right = { AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0), Size = UDim2.new(0, BorderThickness, 1, 0), },
    Bottom = { AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, BorderThickness), },
    Left = { AnchorPoint = Vector2.new(), Position = UDim2.new(), Size = UDim2.new(0, BorderThickness, 1, 0), },
}

local function MakeBorderFrame(position: BorderPosition, colour: Color3)
    return Roact.createElement("Frame", {
        AnchorPoint = position.AnchorPoint,
        BackgroundColor3 = colour,
        BorderSizePixel = 0,
        Position = position.Position,
        Size = position.Size,
        ZIndex = position == BorderPosition.Top and 1 or 100,
        ClipsDescendants = true,
    })
end

function TabButton:init()
    self:setState({
        hovered = false,
        pressed = false,
        labelFits = true,
    })

    self.OnInputBegin = function(_, input: InputObject)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            self:setState({ hovered = true, })
        elseif string.match(input.UserInputType.Name, "MouseButton%d") then
            self:setState({ pressed = true, })
        end
    end

    self.OnInputEnd = function(_, input: InputObject)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            self:setState({ hovered = false, })
        elseif string.match(input.UserInputType.Name, "MouseButton%d") then
            self:setState({ pressed = false, })
        end
    end
end

function TabButton:didUpdate(_, oldState)
    local props, state = self.props, self.state

    if props.Disabled then
        return
    end

    if props.Hovered and oldState.hovered ~= state.hovered then
        props.Hovered(self, state.hovered)
    end

    if props.Clicked and oldState.pressed == true and state.hovered then
        props.Clicked(self)
    end
end

function TabButton:GetModifier()
    local props, state = self.props, self.state
    local modifier = "Default"

    if props.Disabled then
        modifier = "Disabled"
    elseif props.Selected then
        modifier = "Selected"
    elseif state.pressed then
        modifier = "Pressed"
    elseif state.hovered then
        modifier = "Hover"
    end

    return modifier, modifier == "Selected" and "Default" or modifier
end

function TabButton:render()
    local props, state = self.props, self.state
    local themeModifier, deselectedModifier = self:GetModifier()

    local textWidth = 0
    if props.Label then
        textWidth = TextService:GetTextSize(props.Label, 14, "Gotham", Vector2.new()).X
    end

    return ThemeProvider.withTheme(function(theme: StudioTheme)
        return Roact.createElement("TextButton", {
            Active = not props.Disabled,
            AutoButtonColor = false,
            BackgroundColor3 = theme:GetColor("RibbonTab", deselectedModifier),
            BorderSizePixel = 0,
            LayoutOrder = props.LayoutOrder,
            ClipsDescendants = true,
            Text = "",

            [Roact.Event.InputBegan] = self.OnInputBegin,
            [Roact.Event.InputEnded] = self.OnInputEnd,
        }, {
            Borders = Roact.createElement("Frame", {
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.fromScale(1, 1),
                ClipsDescendants = true,
                ZIndex = 100,
            }, {
                Top = props.Selected and MakeBorderFrame(BorderPosition.Top, theme:GetColor("LinkText", themeModifier)),
                Right = props.Selected and MakeBorderFrame(BorderPosition.Right, theme:GetColor("Border", themeModifier)),
                Left = props.Selected and MakeBorderFrame(BorderPosition.Left, theme:GetColor("Border", themeModifier)),
                Bottom = not props.Selected and MakeBorderFrame(BorderPosition.Bottom, theme:GetColor("Border", themeModifier)),
            }),

            Content = Roact.createElement("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                ClipsDescendants = true,

                [Roact.Change.AbsoluteSize] = function(rbx)
                    local contentWidth = 36 + textWidth

                    self:setState({
                        labelFits = contentWidth < rbx.AbsoluteSize.X
                    })
                end,
            }, {
                Padding = Roact.createElement("UIPadding", {
                    PaddingBottom = UDim.new(0, 4),
                    PaddingLeft = UDim.new(0, 4),
                    PaddingRight = UDim.new(0, 4),
                    PaddingTop = UDim.new(0, 4),
                }),

                ListLayout = Roact.createElement("UIListLayout", {
                    Padding = UDim.new(0, 8),
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                }),

                Icon = props.Icon and Roact.createElement("ImageLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.fromOffset(16, 16),
                    ClipsDescendants = true,
                    Image = props.Icon,
                    ImageColor3 = props.IconColour or theme:GetColor("ButtonText", themeModifier),
                    ScaleType = Enum.ScaleType.Fit,
                }),

                Label = (state.labelFits and props.Label) and Roact.createElement("TextLabel", {
                    BackgroundTransparency = 1,
                    LayoutOrder = 100,
                    Size = UDim2.fromOffset(textWidth, 14),
                    ClipsDescendants = true,
                    Font = Enum.Font.Gotham,
                    Text = props.Label,
                    TextColor3 = props.LabelColour or theme:GetColor("ButtonText", themeModifier),
                    TextSize = 14,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                }),
            }),
        })
    end)
end

TabButton.DefaultProps = {
    --[[string?]] Label = nil,
    --[[Color3?]] LabelColour = nil,

    --[[string?]] Icon = nil,
    --[[Color3?]] IconColour = nil,

    --[[boolean?]] Disabled = nil,
    --[[boolean?]] Selected = nil,

    --[[number?]] LayoutOrder = nil,

    --[[() -> any?]] Clicked = nil,
    --[[() -> any?]] Hovered = nil,
}

return TabButton
