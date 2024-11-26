local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

return function(Context)
    local TeleportService = Knit.GetService("TeleportService")
    TeleportService:TeleportPlayerToPosition(Context.Executor, workspace.Game.MineSpawn.Position, false)
    return "Teleported to mine"
end