local Config = require(script.Parent.Parent.Config)

return function(plugin: Plugin)
    local Toolbar = plugin:CreateToolbar("Plugins")
    local ToggleButton = Toolbar:CreateButton(
        Config.PluginGUID .. ":main-button",
        "Import plugins from the Roblox website via URL or directly from your creations",
        Config.PluginIcon,
        "Import"
    )

    local MainWindow = plugin:CreateDockWidgetPluginGui(
        Config.PluginGUID .. ":main-window",
        DockWidgetPluginGuiInfo.new(
            Enum.InitialDockState.Left,
            false,
            false,
            300,
            500,
            1,
            1
        )
    )

    ToggleButton.ClickableWhenViewportHidden = true
    ToggleButton.Parent = Toolbar

    MainWindow.Name = Config.PluginGUID .. ":main-window"
    MainWindow.Title = "Plugin Importer"
    MainWindow.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    ToggleButton:SetActive(MainWindow.Enabled)
    ToggleButton.Click:Connect(function()
        MainWindow.Enabled = not MainWindow.Enabled
    end)

    MainWindow:GetPropertyChangedSignal("Enabled"):Connect(function()
        ToggleButton:SetActive(MainWindow.Enabled)
    end)

    Toolbar.Parent = plugin

    return {
        Plugin = plugin,
        Toolbar = Toolbar,
        ToggleButton = ToggleButton,
        MainWindow = MainWindow,
    }
end
