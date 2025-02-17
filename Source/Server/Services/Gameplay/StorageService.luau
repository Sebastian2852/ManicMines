local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Knit = require(ReplicatedStorage.Packages.Knit)

local StorageService = Knit.CreateService {
	Name = "StorageService",
	Client = {
		OpenStorage = Knit.CreateSignal(),
		Update = Knit.CreateSignal(),
	},
}

local LogService
local DataService
local PlayerStatsService

-- [[ PUBLIC ]] --

--[=[
Moves the given amount of the given ore from inventory to storage for the given player
]=]
function StorageService:MoveOreToStorage(Player: Player, OreName: string, Amount: number): boolean
	local DataFolder: Core.DataFolder = DataService:GetPlayerDataFolder(Player)
	local OreExists = Core.Util:GetOreByName(OreName)
	if not OreExists then
		return false
	end

	local InventoryDataValue = DataFolder.Inventory.Ores:FindFirstChild(OreName)
	if not InventoryDataValue then
		LogService:Warn("Couldnt find inventory data value for: " .. tostring(OreName))
		return false
	end

	local StorageDataValue = DataFolder.Storage.Ores:FindFirstChild(OreName)
	if not StorageDataValue then
		LogService:Warn("Couldnt find storage data value for: " .. tostring(OreName))
		return false
	end

	if InventoryDataValue.Value < Amount then
		LogService:Warn(Player.Name .. " tried to move " .. Amount .. " " .. OreName .. " but not enough in inventory")
		return false
	end

	LogService:Log("Moved " .. Amount .. " " .. OreName .. " for player: " .. Player.Name)
	InventoryDataValue.Value -= Amount
	StorageDataValue.Value += Amount
	PlayerStatsService:CalculateInventoryCapacity(DataFolder)
	self.Client.Update:Fire(Player)
	return true
end

--[=[
Moves the given amount of the given ore from storage to inventory for the given player
]=]
function StorageService:MoveOreToInventory(Player: Player, OreName: string, Amount: number): boolean
	local DataFolder: Core.DataFolder = DataService:GetPlayerDataFolder(Player)
	local OreExists = Core.Util:GetOreByName(OreName)
	if not OreExists then
		return false
	end

	local InventoryDataValue = DataFolder.Inventory.Ores:FindFirstChild(OreName)
	if not InventoryDataValue then
		LogService:Warn("Couldnt find inventory data value for: " .. tostring(OreName))
		return false
	end

	local StorageDataValue = DataFolder.Storage.Ores:FindFirstChild(OreName)
	if not StorageDataValue then
		LogService:Warn("Couldnt find storage data value for: " .. tostring(OreName))
		return false
	end

	if StorageDataValue.Value < Amount then
		LogService:Warn(Player.Name .. " tried to move " .. Amount .. " " .. OreName .. " but not enough in inventory")
		return false
	end

	LogService:Log("Moved " .. Amount .. " " .. OreName .. " for player: " .. Player.Name)
	StorageDataValue.Value -= Amount
	InventoryDataValue.Value += Amount
	PlayerStatsService:CalculateInventoryCapacity(DataFolder)
	self.Client.Update:Fire(Player)
	return true
end

function StorageService:OpenStorageForPlayer(Player: Player)
	self.Client.OpenStorage:Fire(Player)
end

-- [[ CLIENT ]] --

function StorageService.Client:MoveToStorage(Player: Player, OreName: string, Amount: number): boolean
	return self.Server:MoveOreToStorage(Player, OreName, Amount)
end

function StorageService.Client:MoveToInventory(Player: Player, OreName: string, Amount: number): boolean
	return self.Server:MoveOreToInventory(Player, OreName, Amount)
end

function StorageService.Client:MoveAllToStorage(Player: Player)
	local DataFolder: Core.DataFolder = DataService:GetPlayerDataFolder(Player)

	for _, OreValue: IntValue in pairs(DataFolder.Inventory.Ores:GetChildren()) do
		if OreValue.Value <= 0 then
			continue
		end
		self.Server:MoveOreToStorage(Player, OreValue.Name, OreValue.Value)
	end
end

function StorageService.Client:MoveAllToInventory(Player: Player)
	local DataFolder: Core.DataFolder = DataService:GetPlayerDataFolder(Player)

	for _, OreValue: IntValue in pairs(DataFolder.Storage.Ores:GetChildren()) do
		if OreValue.Value <= 0 then
			continue
		end
		self.Server:MoveOreToInventory(Player, OreValue.Name, OreValue.Value)
	end
end

-- [[ KNIT ]] --

function StorageService:KnitStart()
	LogService = Knit.GetService("LogService")
	DataService = Knit.GetService("DataService")
	PlayerStatsService = Knit.GetService("PlayerStatsService")
end

return StorageService
