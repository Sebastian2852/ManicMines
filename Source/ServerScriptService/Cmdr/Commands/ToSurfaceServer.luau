local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

return function(Context)
    local TeleportService = Knit.GetService("TeleportService")
    TeleportService:TeleportPlayerToSurface(Context.Executor)
    return "Teleported to surface"
end