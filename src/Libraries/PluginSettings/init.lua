local BasicState = require(script.Parent.Parent.Packages.BasicState)
local Config = require(script.Parent.Parent.Config)

local Module = {}

local DefaultSettings = require(script.Defaults)
local PluginState = BasicState.new(DefaultSettings)

export type PluginData = {
    Name: string,
    Id: number,
}

function Module.Init(plugin: Plugin)
    Module.__plugin = plugin
    Module.__state = PluginState

    local savedConfig = plugin:GetSetting(Config.PluginSettingsKey)

    if savedConfig then
        PluginState:SetState(savedConfig)
    end

    PluginState.Changed:Connect(function()
        plugin:SetSetting(Config.PluginSettingsKey, PluginState:GetState())
    end)
end

function Module:Get(...)
    return PluginState:Get(...)
end

function Module:Set(...)
    return PluginState:Set(...)
end

function Module.PushRecent(data: PluginData)
    local recentItems = PluginState:Get("RecentItems", {})
    local maxItems = PluginState:Get("MaxRecentItems", 100)

    for index, pluginItem in ipairs(recentItems) do
        if pluginItem.Id == data.Id then
            table.remove(recentItems, index)
        end
    end

    if #recentItems > 0 then
        for index = #recentItems, 1, -1 do
            local item = recentItems[index]
            recentItems[index + 1] = item
        end
    end

    recentItems[1] = data

    while #recentItems > maxItems do
        table.remove(recentItems, #recentItems)
    end

    PluginState:Set("RecentItems", recentItems)
end

return Module
