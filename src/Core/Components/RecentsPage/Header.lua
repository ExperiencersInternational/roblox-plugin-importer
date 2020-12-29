local PluginRoot = script.Parent.Parent.Parent.Parent

local PluginImporter = require(PluginRoot.Libraries.PluginImporter)
local Roact: Roact = require(PluginRoot.Packages.Roact)

local ThemeProvider = require(script.Parent.Parent.ThemeProvider)
local TextInput = require(script.Parent.Parent.TextInput)

local Header = Roact.Component:extend("Header")

function Header:render()
    return ThemeProvider.withTheme(function(theme: StudioTheme)
        return Roact.createElement("Frame", {
            BackgroundColor3 = theme:GetColor("Titlebar"),
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 64),
            ClipsDescendants = true,
        }, {
            Padding = Roact.createElement("UIPadding", {
                PaddingBottom = UDim.new(0, 12),
                PaddingLeft = UDim.new(0, 12),
                PaddingRight = UDim.new(0, 12),
                PaddingTop = UDim.new(0, 12),
            }),

            ImportUrl = Roact.createElement(TextInput, {
                Placeholder = "Paste URL or ID",

                FocusLost = function(rbx: TextBox, enterPressed: boolean)
                    if not enterPressed then
                        return
                    end

                    local userInput = rbx.Text
                    rbx.Text = ""

                    PluginImporter.ImportPlugin(PluginImporter.GetPluginName(userInput), userInput)
                end,
            })
        })
    end)
end

return Header
