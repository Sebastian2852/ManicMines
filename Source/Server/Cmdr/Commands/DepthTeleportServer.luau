local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

return function(_, Player: Player, Depth: number)
	local TeleportService = Knit.GetService("TeleportService")
	TeleportService:TeleportToDepth(Player, Depth)
end
