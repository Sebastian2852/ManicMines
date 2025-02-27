local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

return function(Context, ToPlayer: Player?)
	local TeleportService = Knit.GetService("TeleportService")
	TeleportService:TeleportPlayerToTycoon(Context.Executor, ToPlayer or Context.Executor, true)
	return "Teleported to tycoon"
end
