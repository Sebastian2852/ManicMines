local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

return function(Context, Player: Player?)
	if Player == nil then
		Player = Context.Executor
	end

	local TeleportService = Knit.GetService("TeleportService")
	local MysteryMerchantService = Knit.GetService("MysteryMerchantService")

	local IsSpawned = MysteryMerchantService:IsMerchantSpawned()
	if not IsSpawned then
		return "Failed; Mystery Merchant is not currently spawned"
	end

	local NPC = CollectionService:GetTagged("MysteryMerchant/OpenGUI")[1]
	if not NPC then
		return "Failed; Couldn't find npc. THIS IS A BUG"
	end

	local TeleportPart = NPC:FindFirstChildWhichIsA("Part")
	local Position = TeleportPart.CFrame.Position + Vector3.new(0, 10, 0)

	TeleportService:TeleportPlayerToPosition(Player, Position, false)
	return `Teleported {Player.Name} to the mystery merchant`
end
