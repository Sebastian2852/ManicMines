local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

return function(Context, Player: Player?)
	local StorageService = Knit.GetService("StorageService")
	local DataService = Knit.GetService("DataService")

	if Player == nil then
		Player = Context.Executor
	end

	local DataFolder = DataService:GetPlayerDataFolder(Player)
	local OresMoved = 0
	local TotalOresMoved = 0

	for _, OreValue: IntValue in pairs(DataFolder.Inventory.Ores:GetChildren()) do
		if OreValue.Value <= 0 then
			continue
		end
		OresMoved += 1
		TotalOresMoved += OreValue.Value
		local Success = StorageService:MoveOreToStorage(Player, OreValue.Name, OreValue.Value)
		if not Success then
			return "Failed to move ore: " .. OreValue.Name
		end
	end

	return `Moved {OresMoved} different ores to storage ({TotalOresMoved} total)`
end
