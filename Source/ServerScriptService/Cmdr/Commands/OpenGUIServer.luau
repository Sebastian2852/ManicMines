local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

return function(Context, Gui :string, Player :Player?)

    local ForgeService = Knit.GetService("ForgeService")

    if Player == nil then
        Player = Context.Executor
    end

    Gui = string.lower(Gui)
    if Gui == "forge" then
        ForgeService:OpenForgeForPlayer(Player)
        return "Opened forge for "..Player.Name
    elseif Gui == "storage" then
        return "Opening storage from server is not yet implemented."
    end

    return "Couldnt find GUI with the name: "..tostring(Gui)
end