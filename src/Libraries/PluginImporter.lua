local ServerStorage = game:GetService("ServerStorage")
local Selection = game:GetService("Selection")
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")
local StudioService = game:GetService("StudioService")

local PluginSettings = require(script.Parent.PluginSettings)

local Store = require(script.Parent.Parent.Data.Store)
local ResourceURL = require(script.Parent.Parent.Data.URLs)

local Module = {}
Module.ToolboxCache = {}

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

function Module.SearchToolbox(
    category: string,
    creatorId: number,
    creatorType: number?,
    sort: string?,
    limit: number?,
    page: number?,
    cacheMode: string?
)
    creatorType = creatorType or 1
    sort = sort or "Updated"
    limit = limit or 50
    page = page or 1
    cacheMode = cacheMode or "Normal"

    local cacheKey = table.concat({ category, creatorId, creatorType, sort, limit, page, cacheMode }, ",")
    local cacheItem = Module.ToolboxCache[cacheKey]

    if cacheItem and os.clock() - cacheItem.time < 60 then
        return cacheItem.data
    end

    local response = HttpService:RequestAsync({
        Url = string.format(ResourceURL.Toolbox, category, sort, creatorId, limit, page, creatorType, cacheMode)
    })

    local json = HttpService:JSONDecode(response.Body)
    local results = {}

    for _, result in ipairs(json.Results) do
        results[#results + 1] = {
            Name = result.Asset.Name,
            Id = result.Asset.Id,
        }
    end

    local returns = {
        page = page,
        totalPages = math.ceil(json.TotalResults / limit),
        results = results,
    }

    Module.ToolboxCache[cacheKey] = {
        time = os.clock(),
        data = returns,
    }

    return returns
end

function Module.FetchCreations(userId: number?)
    if not userId then
        userId = StudioService:GetUserId()
    end

    local freePlugins = Module.SearchToolbox("FreePlugins", userId)
    local whitelistPlugins = Module.SearchToolbox("WhitelistedPlugins", userId)
    local creations, processedIds = {}, {}

    for _, result in ipairs(freePlugins.results) do
        if processedIds[result.Id] then
            continue
        end

        creations[#creations + 1] = result
        processedIds[result.Id] = true
    end

    for _, result in ipairs(whitelistPlugins.results) do
        if processedIds[result.Id] then
            continue
        end

        creations[#creations + 1] = result
        processedIds[result.Id] = true
    end

    return creations
end

function Module.AllowHttpPermissions()
    PluginSettings:Set("HttpPermissionRequested", true)
end

return Module
