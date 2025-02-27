local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

return function(Context, Player: Player?)
	Player = Player and Player or Context.Executor
	local TeleportService = Knit.GetService("TeleportService")
	TeleportService:TeleportPlayerToTycoon(Player, Player, true)
	return "Teleported to tycoon"
end
