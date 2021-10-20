local ServerStorage = game:GetService("ServerStorage")
local Selection = game:GetService("Selection")
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")
local StudioService = game:GetService("StudioService")
local RunService = game:GetService("RunService")

local PluginSettings = require(script.Parent.PluginSettings)

-- local Store = require(script.Parent.Parent.Data.Store)
local ResourceURL = require(script.Parent.Parent.Data.URLs)

local Module = {}
Module.ToolboxCache = {}

local NetworkRequest; do
    local Replicated = game:GetService("ReplicatedStorage")
    local RemoteId = "__PLUGIN_IMPORTER_NET_REQUEST__"

    if RunService:IsRunning() then
       if RunService:IsClient() then
            NetworkRequest = Replicated:WaitForChild(RemoteId)
       else
            NetworkRequest = Replicated:FindFirstChild(RemoteId)

            if not NetworkRequest then
                NetworkRequest = Instance.new("RemoteFunction")
                NetworkRequest.Name = RemoteId

                NetworkRequest.OnServerInvoke = function(_, options)
                    return Module.SearchToolbox(
                        options.category,
                        options.creatorId,
                        options.creatorType,
                        options.sort,
                        options.limit,
                        options.page,
                        options.cacheMode
                    )
                end

                NetworkRequest.Parent = Replicated
            end

       end
    end
end

function Module.BuildURL(segments: {string}): string
    assert(#segments == 2, "Invalid number of segments; index 1 should be a subdomain, and 2 should be the path")

    local url = string.format(ResourceURL.Proxy, segments[1], segments[2])
    return url
end

function Module.FetchPlugin(id: number): Folder
    local assetUrl = string.format(Module.BuildURL(ResourceURL.Asset), id)
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

    PluginSettings.PushRecent({
        Name = name,
        Id = resolvedId,
    })

    coroutine.wrap(function()
        local pluginAsset = Module.FetchPlugin(resolvedId)
        pluginAsset.Parent = ServerStorage
        Selection:Set({ pluginAsset })
    end)()

    coroutine.wrap(function()
        local pluginName = Module.GetPluginName(resolvedId)

        Module.UpdateRecentsFromResults({{
            Name = pluginName,
            Id = resolvedId,
        }})
    end)()
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
    if NetworkRequest and RunService:IsClient() then
        return NetworkRequest:InvokeServer({
            category = category,
            creatorId = creatorId,
            creatorType = creatorType,
            sort = sort,
            limit = limit,
            page = page,
            cacheMode = cacheMode,
        })
    end

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
        Url = string.format(Module.BuildURL(ResourceURL.Toolbox), category, sort, creatorId, limit, page, creatorType, cacheMode)
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

    Module.UpdateRecentsFromResults(results)

    return returns
end

function Module.UpdateRecentsFromResults(results: {}?)
    if type(results) ~= "table" then
        return
    end

    local updated = PluginSettings:Get("RecentItems", {})

    local indexes = {}; do
        for index, item in ipairs(updated) do
            indexes[item.Id] = index
        end
    end

    for _, result in ipairs(results) do
        local match = indexes[result.Id]

        if not match then
            continue
        end

        updated[match].Name = result.Name
    end

    PluginSettings:Set("RecentItems", updated)
end

function Module.FetchCreations(creatorId: number?, isGroup: boolean?)
    if not creatorId then
        creatorId = StudioService:GetUserId()
    end

    if type(isGroup) ~= "boolean" then
        isGroup = false
    end

    local freePlugins = Module.SearchToolbox("FreePlugins", creatorId, isGroup and 2 or 1)
    local whitelistPlugins = Module.SearchToolbox("WhitelistedPlugins", creatorId, isGroup and 2 or 1)
    local creations, processedIds = {}, {}

    for _, result in ipairs(freePlugins.results) do
        if processedIds[result.Id] then
            continue
        end

        local newIndex = #creations + 1
        creations[newIndex] = result
        processedIds[result.Id] = newIndex
    end

    for _, result in ipairs(whitelistPlugins.results) do
        if processedIds[result.Id] then
            continue
        end

        local newIndex = #creations + 1
        creations[newIndex] = result
        processedIds[result.Id] = newIndex
    end

    Module.UpdateRecentsFromResults(creations)

    return creations
end

function Module.FetchGroupMemberships(userId: number?)
    if not userId then
        userId = StudioService:GetUserId()
    end

    local httpResponse = HttpService:RequestAsync({
        Url = string.format(Module.BuildURL(ResourceURL.Groups), userId),
    })

    local json = HttpService:JSONDecode(httpResponse.Body)
    local results = {}

    for _, result in ipairs(json.data) do
        table.insert(results, {
            Id = result.group.id,
            Name = result.group.name,
        })
    end

    return results
end

function Module.AllowHttpPermissions()
    PluginSettings:Set("HttpPermissionRequested", true)
end

return Module
