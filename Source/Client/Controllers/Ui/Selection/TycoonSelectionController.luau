local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)

local TycoonSelectionController = Knit.CreateController({
	Name = "TycoonSelectionController",
})

local TycoonService
local LogService
local DataService

local Assets = ReplicatedStorage.Assets
local TycoonAssets = Assets.Tycoon
local DataFolder: Core.DataFolder

local SelectionOutline: SelectionBox = TycoonAssets.UpgradeSelection
local CurrentlySelecting = false
local CurrentOutline = nil
local Selection = nil

local ActiveTree = nil

-- [[ PUBLIC ]]--

--[=[
Deselects the currently selected hitbox by destroying the outline it was given
]=]
function TycoonSelectionController:Deselect()
	if not CurrentlySelecting then
		return
	end
	LogService:Log("Deselecting upgrade hitbox")
	if CurrentOutline then
		CurrentOutline:Destroy()
	end
	if ActiveTree then
		Roact.unmount(ActiveTree)
		ActiveTree = nil
	end
	if Selection ~= nil then
		Selection = nil
	end
	CurrentlySelecting = false
end

--[=[
Selectes a given hitbox by giving it an outline, if anything is already selected it will
automatically deslect it
]=]
function TycoonSelectionController:SelectHitbox(Hitbox)
	LogService:Log("Selecting upgrade hitbox")
	if CurrentlySelecting then
		self:Deselect()
	end
	if Selection ~= nil then
		self:Deselect()
	end

	local Config = ReplicatedStorage.Assets.Tycoon.Upgrades:FindFirstChild(Hitbox.Name)
	local LevelConfig = Config:FindFirstChild(DataFolder.Tycoon.Upgrades:FindFirstChild(Config.Name).Value)

	local SelectionGUI = require(ReplicatedStorage.Game.GUI.TycoonSelection)
	local App = Roact.createElement(SelectionGUI, {
		UpgradeConfig = Config,
		LevelConfig = LevelConfig,
	}, {})

	ActiveTree = Roact.mount(App, Knit.Player.PlayerGui, "Tycoon Selection")

	local New = SelectionOutline:Clone()
	New.Parent = Hitbox
	New.Adornee = Hitbox
	New.Name = "Selection"

	CurrentOutline = New
	Selection = Hitbox
	CurrentlySelecting = true
	LogService:Log("Selected upgrade hitbox: " .. Hitbox.Name)
end

--[=[
Takes in an upgrade config and returns the cost for the upgrade as a OreList or nil
if there is no config passed or no cost folder in the config
]=]
function TycoonSelectionController:CreateCostOreList(UpgradeConfig: Configuration)
	if UpgradeConfig == nil then
		return nil
	end
	if not UpgradeConfig:FindFirstChild("Cost") then
		return nil
	end
	return Core.Util:CreateOreListFromFolder(UpgradeConfig:FindFirstChild("Cost"))
end

-- [[ KNIT ]]--

function TycoonSelectionController:KnitStart()
	TycoonService = Knit.GetService("TycoonService")
	LogService = Knit.GetService("LogService")
	DataService = Knit.GetService("DataService")

	DataService.DataLoaded:Connect(function(Data)
		DataFolder = Data
	end)

	TycoonService.SelectUpgrade:Connect(function(UpgradeName: string)
		TycoonService:GetPlayerTycoon():andThen(function(Tycoon: Model)
			local Hitbox = Tycoon.Main.Upgrades:FindFirstChild(UpgradeName)
			self:SelectHitbox(Hitbox)
		end)
	end)
end

return TycoonSelectionController
