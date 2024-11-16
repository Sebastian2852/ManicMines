local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local ForgeService = Knit.CreateService {
    Name = "ForgeService",
    Client = {
        OpenForge = Knit.CreateSignal();
    },
}

--[=[
Opens the forge GUI for the given player
]=]
function ForgeService:OpenForgeForPlayer(Player :Player)
    self.Client.OpenForge:Fire(Player)
end

return ForgeService