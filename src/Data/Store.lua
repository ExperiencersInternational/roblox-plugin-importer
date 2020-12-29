local RunService = game:GetService("RunService")
local BasicState = require(script.Parent.Parent.Packages.BasicState)

local Store = BasicState.new({
    Location = "/recents",
    ErrorText = nil,

    Creations = {
        Loading = false,
        Loaded = false,
        Data = {},
    },
})

function Store:GoTo(path: string)
    Store:Set("Location", string.lower(path))
end

local ErrorStart, ErrorConnection = 0, nil
Store:GetChangedSignal("ErrorText"):Connect(function()
    ErrorStart = os.clock()

    if ErrorConnection then
        ErrorConnection:Disconnect()
    end

    ErrorConnection = RunService.Heartbeat:Connect(function()
        if os.clock() - ErrorStart > 4 then
            ErrorConnection:Disconnect()
            Store:Delete("ErrorText")
        end
    end)
end)

return Store
