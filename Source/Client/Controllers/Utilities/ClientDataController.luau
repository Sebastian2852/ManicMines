local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Knit = require(ReplicatedStorage.Packages.Knit)

local ClientDataController = Knit.CreateController({
	Name = "ClientDataController",
})

local DataService
ClientDataController.DataFolder = nil

function ClientDataController:GetDataFolder(): Core.DataFolder
	if self.DataFolder then
		return self.DataFolder
	end

	local DataFolder = ReplicatedStorage.PlayerData:FindFirstChild(Knit.Player.UserId)
	self.DataFolder = DataFolder
	return DataFolder
end

--[=[
	Check if the player has enough of a single ore
]=]
function ClientDataController:HasEnoughOre(Ore: Core.OreListItem): boolean
	local DataFolder = self:GetDataFolder()

	if Ore.Name == "GoldCoins" then
		local Amount = DataFolder.Gold.Value
		return Amount >= Ore.Amount
	end

	local InventoryDataValue = DataFolder.Inventory.Ores:FindFirstChild(Ore.Name) :: IntValue
	local StorageDataValue = DataFolder.Storage.Ores:FindFirstChild(Ore.Name) :: IntValue

	local Amount = InventoryDataValue.Value + StorageDataValue.Value

	return Amount >= Ore.Amount
end

function ClientDataController:GetTycoonName()
	local DataFolder = self:GetDataFolder()
	return DataFolder.TycoonName.Value
end

function ClientDataController:GetOresAmount(Name: string): number
	local DataFolder = self:GetDataFolder()

	if Name == "GoldCoins" then
		local Amount = DataFolder.Gold.Value
		return Amount
	end

	local InventoryDataValue = DataFolder.Inventory.Ores:FindFirstChild(Name) :: IntValue
	local StorageDataValue = DataFolder.Storage.Ores:FindFirstChild(Name) :: IntValue
	local Amount = InventoryDataValue.Value + StorageDataValue.Value

	return Amount
end

--[=[
	Check if the player has enough for an ore list
]=]
function ClientDataController:HasEnoughOres(Ores: Core.OreList): boolean
	for _, Ore in pairs(Ores:LoopList()) do
		local HasEnough = self:HasEnoughOre(Ore)
		if not HasEnough then
			return false
		end
	end
	return true
end

--[=[
	Returns how many times the player has mined the given ore
]=]
function ClientDataController:GetTimesMinedForOre(OreName: string): number
	local DataFolder = self:GetDataFolder()
	local DataValue: IntValue = DataFolder.TimesMined:FindFirstChild(OreName)

	if DataValue == nil then
		return 0
	end

	return DataValue.Value
end

function ClientDataController:AdvanceTutorialStage()
	local DataFolder = self:GetDataFolder()
	local NewValue = DataFolder.TutorialStage.Value + 1
	self:SetTutorialStage(NewValue)
end

function ClientDataController:SetTutorialStage(New: number)
	DataService:SetTutorialStage(New)
end

function ClientDataController:GetTutorialStage()
	local DataFolder = self:GetDataFolder()
	return DataFolder.TutorialStage.Value
end

function ClientDataController:KnitStart()
	DataService = Knit.GetService("DataService")
end

return ClientDataController
