local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

return function(Context, Player :Player?)
    Player = Player and Player or Context.Executor
    local TeleportService = Knit.GetService("TeleportService")
    local TycoonService = Knit.GetService("TycoonService")
    TeleportService:TeleportPlayerToTycoon(Player, TycoonService:GetPlayerTycoon(Player), true)
    return "Teleported to tycoon"
end