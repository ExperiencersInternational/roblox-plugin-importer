local PluginRoot = script.Parent.Parent.Parent
local Roact: Roact = require(PluginRoot.Packages.Roact)

local ThemeProvider = require(script.Parent.ThemeProvider)

local TextInput = Roact.Component:extend("TextInput")

function TextInput:init()
    self:setState({
        hovered = false,
        pressed = false,
        focused = false,
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

            if self.state.hovered then
                self.OnRootClicked()
            end
        end
    end

    self.OnFocusGain = function()
        self:setState({ focused = true, })
    end

    self.OnFocusLost = function(...)
        self:setState({ focused = false, hovered = false, })

        if self.props.FocusLost then
            self.props.FocusLost(...)
        end
    end

    self.OnRootClicked = function()
        local textInput = self.textInputRef:getValue()

        if textInput then
            textInput:CaptureFocus()
        end
    end

    self.textInputRef = Roact.createRef()
end

function TextInput:GetModifier()
    local props, state = self.props, self.state
    local modifier = "Default"

    if props.Disabled then
        modifier = "Disabled"
    elseif state.focused then
        modifier = "Selected"
    elseif state.pressed then
        modifier = "Pressed"
    elseif state.hovered then
        modifier = "Hover"
    end

    return modifier, modifier == "Hover" and "Default" or modifier
end

function TextInput:render()
    local state, props = self.state, self.props
    local themeModifier, hoverlessModifier = self:GetModifier()

    return ThemeProvider.withTheme(function(theme: StudioTheme)
        return Roact.createElement("TextButton", {
            Active = not props.Disabled,
            AutoButtonColor = false,
            BackgroundColor3 = theme:GetColor("InputFieldBorder", themeModifier),
            BorderSizePixel = 0,
            Size = UDim2.fromScale(1, 1),
            ClipsDescendants = true,
            Text = "",

            [Roact.Event.InputBegan] = self.OnInputBegin,
            [Roact.Event.InputEnded] = self.OnInputEnd,
        }, {
            BorderRadius = Roact.createElement("UICorner", {
                CornerRadius = UDim.new(0, 4),
            }),

            Padding = Roact.createElement("UIPadding", {
                PaddingBottom = UDim.new(0, 1),
                PaddingLeft = UDim.new(0, 1),
                PaddingRight = UDim.new(0, 1),
                PaddingTop = UDim.new(0, 1),
            }),

            Main = Roact.createElement("Frame", {
                BackgroundColor3 = theme:GetColor("InputFieldBackground", hoverlessModifier),
                BorderSizePixel = 0,
                Size = UDim2.fromScale(1, 1),
                ClipsDescendants = true,
            }, {
                BorderRadius = Roact.createElement("UICorner", {
                    CornerRadius = UDim.new(0, 3),
                }),

                InputContainer = Roact.createElement("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 1),
                    ClipsDescendants = true,
                }, {
                    Padding = Roact.createElement("UIPadding", {
                        PaddingBottom = UDim.new(0, 4),
                        PaddingLeft = UDim.new(0, 8),
                        PaddingRight = UDim.new(0, 8),
                        PaddingTop = UDim.new(0, 4),
                    }),

                    Input = Roact.createElement("TextBox", {
                        BackgroundTransparency = 1,
                        ClearTextOnFocus = props.ClearTextOnFocus,
                        MultiLine = props.MultiLine,
                        TextEditable = props.TextEditable,
                        Size = UDim2.fromScale(1, 1),
                        ClipsDescendants = true,
                        Font = Enum.Font.Gotham,
                        PlaceholderColor3 = theme:GetColor("DimmedText", themeModifier),
                        PlaceholderText = props.Placeholder,
                        Text = "",
                        TextColor3 = theme:GetColor("MainText", themeModifier),
                        TextSize = 14,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        TextXAlignment = Enum.TextXAlignment.Left,

                        [Roact.Ref] = self.textInputRef,
                        [Roact.Event.Focused] = self.OnFocusGain,
                        [Roact.Event.FocusLost] = self.OnFocusLost,
                    }),
                }),
            }),
        })
    end)
end

TextInput.DefaultProps = {
    --[[string?]] Placeholder = nil,

    --[[boolean?]] Disabled = nil,
    --[[boolean?]] ClearTextOnFocus = nil,
    --[[boolean?]] MultiLine = nil,
    --[[boolean?]] TextEditable = nil,

    --[[() -> any?]] FocusLost = nil,
}

return TextInput
