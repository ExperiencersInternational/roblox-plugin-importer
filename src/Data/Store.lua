local BasicState = require(script.Parent.Parent.Packages.BasicState)

local Store = BasicState.new({
    Location = "/recents",
})

function Store:GoTo(path: string)
    Store:Set("Location", string.lower(path))
end

return Store
