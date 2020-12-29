local ServerStorage = game:GetService("ServerStorage")
local Selection = game:GetService("Selection")
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")
local StudioService = game:GetService("StudioService")

local PluginSettings = require(script.Parent.PluginSettings)

local Store = require(script.Parent.Parent.Data.Store)
local ResourceURL = require(script.Parent.Parent.Data.URLs)

local Module = {}

function Module.FetchPlugin(id: number): Folder
    local assetUrl = string.format(ResourceURL.Asset, id)
    local asset = game:GetObjects(assetUrl)[1]

    local container = Instance.new("Folder")
    container.Name = string.format("Plugin_%d", id)

    asset.Parent = container

    return container
end

function Module.BestGuessFromInput(id: number | string): number?
    local matchingNumbers = string.gmatch(tostring(id), "%d+")

    for match in matchingNumbers do
        return tonumber(match)
    end
end

function Module.GetPluginName(id: number | string): string
    local resolvedId = Module.BestGuessFromInput(id)
    local marketData = MarketplaceService:GetProductInfo(resolvedId, "Asset")

    return marketData.Name
end

function Module.ImportPlugin(name: string, id: number | string): nil
    local resolvedId = Module.BestGuessFromInput(id)

    coroutine.wrap(function()
        local pluginAsset = Module.FetchPlugin(resolvedId)
        pluginAsset.Parent = ServerStorage
        Selection:Set({ pluginAsset })
    end)()

    PluginSettings.PushRecent({
        Name = name,
        Id = resolvedId,
    })
end

function Module.FetchCreations(userId: number?)
    if not userId then
        userId = StudioService:GetUserId()
    end

    local success, response = pcall(function()
        return HttpService:RequestAsync({
            Url = string.format(
                ResourceURL.Proxy,
                string.format(ResourceURL.PluginCreations, userId, 1)
            ),
            Method = "GET",
            Headers = {
                Origin = ResourceURL.Origin,
            },
        })
    end)

    PluginSettings:Set("HttpPermissionRequested", true)

    if not success or not response.Success then
        return Store:Set("ErrorText", response)
    end

    success, response = pcall(function()
        return HttpService:JSONDecode(response.Body)
    end)

    if not success then
        return Store:Set("ErrorText", response)
    end

    local creations = {}
    for _, asset in ipairs(response) do
        table.insert(creations, {
            Name = asset.Name,
            Id = asset.AssetId,
        })
    end

    return creations
end

function Module.UpdateCreationsInStore()
    Store:SetState({
        Creations = {
            Loading = true,
        },
    })

    local creations = Module.FetchCreations()

    Store:Set({
        Creations = {
            Loaded = true,
            Data = creations,
        },
    })
end

return Module
