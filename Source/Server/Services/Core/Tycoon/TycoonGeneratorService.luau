local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Logger = require(ReplicatedStorage.Game.Modules.Logger)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Roact = require(ReplicatedStorage.Packages.Roact)

local GeneratorGUI = require(ReplicatedStorage.Game.GUI.TycoonGenerator)

local TycoonGeneratorService = Knit.CreateService({
	Name = "TycoonGeneratorService",
	Client = {},
})

local DataService
local TycoonService
local TycoonUpgradeService
local PlayerStatsService

--[=[
Returns the data value of the given generator
]=]
function TycoonGeneratorService:GetGeneratorDataValue(Player: Player, GeneratorName: string): IntValue | nil
	local DataFolder: Core.DataFolder = DataService:GetPlayerDataFolder(Player)
	return DataFolder.Tycoon.Generators:FindFirstChild(GeneratorName)
end

--[=[
Adds the gui to the generator which also updates in realtime
]=]
function TycoonGeneratorService:AddGuiToGenerator(
	Generator: BasePart,
	Configuration: Configuration,
	DataFolder: Core.DataFolder
)
	local DataValue = self:GetGeneratorDataValue(Players:GetPlayerByUserId(DataFolder.Name), Generator.Name)
	local DisplayName = Configuration:GetAttribute("DisplayName")
	local Color = Configuration:GetAttribute("NameColor")

	Roact.mount(
		Roact.createElement(GeneratorGUI, {
			DisplayName = DisplayName,
			Color = Color,
			WatchValue = DataValue,
		}),
		Generator,
		"GUI"
	)
end

--[=[
Adds the touched event to the genertor part to give the player the stored amount
]=]
function TycoonGeneratorService:AddFunctionality(
	Generator: BasePart,
	Configuration: Configuration,
	DataFolder: Core.DataFolder
)
	local GeneratorDataValue = self:GetGeneratorDataValue(Players:GetPlayerByUserId(DataFolder.Name), Generator.Name)
	local CurrencyDataValue = DataFolder:FindFirstChild(Configuration:GetAttribute("Currency"))

	Generator.Touched:Connect(function(Part: BasePart)
		local Player = Players:GetPlayerFromCharacter(Part.Parent)

		if not Player then
			return
		end
		if TycoonService:GetPlayerTycoon(Player) ~= Generator.Parent.Parent.Parent then
			return
		end

		CurrencyDataValue.Value += GeneratorDataValue.Value
		GeneratorDataValue.Value = 0

		PlayerStatsService:AwardXP(Player, 0)
	end)
end

--[=[
Setup the generators in the given tycoon, returns a promise
]=]
function TycoonGeneratorService:AddGeneratorsToTycoonAsync(Tycoon: Model, Owner: Player)
	return Promise.new(function(Resolve)
		local DataFolder: Core.DataFolder = DataService:GetPlayerDataFolder(Owner)
		local GeneratorsFolder = Tycoon.Main:FindFirstChild("Generators") :: Folder
		if not GeneratorsFolder then
			Resolve()
		end

		for _, GeneratorPart: BasePart in pairs(GeneratorsFolder:GetChildren()) do
			Logger:Log("Setting up generator: " .. GeneratorPart:GetFullName())

			GeneratorPart.Anchored = true
			GeneratorPart.CanCollide = false

			local GeneratorConfig: Configuration = Core.Assets.Tycoon.Generators:FindFirstChild(GeneratorPart.Name)
			if not GeneratorConfig then
				Logger:Warn("No config found for generator: " .. GeneratorPart:GetFullName())
				continue
			end

			local UpgradeName = GeneratorConfig:GetAttribute("Upgrade") :: string
			local Currency = GeneratorConfig:GetAttribute("Currency") :: string

			if not TycoonUpgradeService:ValidUpgradeName(UpgradeName) then
				Logger:Warn("Invalid upgrade name: " .. UpgradeName .. " for config: " .. GeneratorConfig:GetFullName())
				continue
			end

			if not DataFolder:FindFirstChild(Currency) then
				Logger:Warn(
					"Invalid currency name: "
						.. Currency
						.. " for config: "
						.. GeneratorConfig:GetFullName()
						.. " (Note: Currency must be placed in root of data folder!)"
				)
				continue
			end

			self:AddGuiToGenerator(GeneratorPart, GeneratorConfig, DataFolder)
			self:AddFunctionality(GeneratorPart, GeneratorConfig, DataFolder)

			task.spawn(function()
				Logger:Log("[" .. Owner.Name .. "]", "Starting generator loop")
				while true do
					if not TycoonService:GetTycoonOwner(Tycoon) then
						break
					end

					local UpgradeValue = TycoonUpgradeService:GetUpgradeDataValue(Owner, UpgradeName)
					local TickrateConfig =
						GeneratorConfig:FindFirstChild(UpgradeValue.Value and tostring(UpgradeValue.Value) or "0")

					local TickRate = TickrateConfig:GetAttribute("TickRate") :: number
					local Amount = TickrateConfig:GetAttribute("Amount") :: number

					local DataValue = self:GetGeneratorDataValue(Owner, GeneratorConfig.Name)
					if not DataValue then
						break
					end

					task.wait(TickRate)

					DataValue.Value += Amount
					Logger:Log(
						"[" .. Owner.Name .. "]",
						"Added " .. tostring(Amount) .. " value to generator: " .. DataValue.Name
					)
				end
				Logger:Log("[" .. Owner.Name .. "]", "Finished generator loop")
			end)
		end
	end)
end

-- [[ KNIT ]] --

function TycoonGeneratorService:KnitStart()
	TycoonService = Knit.GetService("TycoonService")
	DataService = Knit.GetService("DataService")
	TycoonUpgradeService = Knit.GetService("TycoonUpgradeService")
	PlayerStatsService = Knit.GetService("PlayerStatsService")
end

return TycoonGeneratorService
