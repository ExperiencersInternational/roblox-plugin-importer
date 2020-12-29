local PluginRoot = script.Parent.Parent.Parent
local Roact: Roact = require(PluginRoot.Packages.Roact)

local Studio: Studio = settings().Studio
local ThemeProvider = Roact.Component:extend("ThemeProvider")

function ThemeProvider:init()
    self:setState({
        theme = Studio.Theme,
        isDark = Studio.Theme.Name == "Dark",
    })

    self.changeConnection = Studio.ThemeChanged:Connect(function()
        self:setState({
            theme = Studio.Theme,
            isDark = Studio.Theme.Name == "Dark",
        })
    end)
end

function ThemeProvider:willUnmount()
    self.changeConnection:Disconnect()
end

function ThemeProvider:render()
    local render = Roact.oneChild(self.props[Roact.Children])
    return render(self.state.theme, self.state.isDark)
end

function ThemeProvider.withTheme(render: () -> RoactComponent): RoactComponent
    return Roact.createElement(ThemeProvider, {}, {
        render = render,
    })
end

return ThemeProvider
