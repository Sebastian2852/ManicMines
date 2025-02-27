local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

return function(Context, Depth: number, Player: Player?)
	local MineService = Knit.GetService("MineService")
	local TeleportService = Knit.GetService("TeleportService")
	local RoomPos = MineService:GenerateRoomAtDepth(Depth)

	Player = Player and Player or Context.Executor
	TeleportService:TeleportPlayerToPosition(Player, RoomPos, true)
end
