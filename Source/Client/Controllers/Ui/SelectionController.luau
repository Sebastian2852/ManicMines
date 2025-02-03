local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)

local TycoonService
local LogService
local DataService

local DataFolder

local TycoonSelectionOutline = ReplicatedStorage.Assets.Tycoon.UpgradeSelection
local CurrentlySelectingTycoon = false
local TycoonSelectionUITree = nil
local CurrentTycoonOutline = nil
local TycoonSelection = nil

local SelectionUIController = Knit.CreateController({ Name = "SelectionUIController" })

--[=[
Deselects the currently selected hitbox by destroying the outline it was given
]=]
function SelectionUIController:Deselect()
	if not CurrentlySelectingTycoon then
		return
	end
	LogService:Log("Deselecting upgrade hitbox")
	if CurrentTycoonOutline then
		CurrentTycoonOutline:Destroy()
	end
	if TycoonSelectionUITree then
		Roact.unmount(TycoonSelectionUITree)
		TycoonSelectionUITree = nil
	end
	if TycoonSelection ~= nil then
		TycoonSelection = nil
	end
	CurrentlySelectingTycoon = false
end

--[=[
Selectes a given hitbox by giving it an outline, if anything is already selected it will
automatically deslect it
]=]
function SelectionUIController:SelectTycoonHitbox(Hitbox)
	LogService:Log("Selecting upgrade hitbox")
	if CurrentlySelectingTycoon then
		self:Deselect()
	end
	if TycoonSelection ~= nil then
		self:Deselect()
	end

	local Config = ReplicatedStorage.Assets.Tycoon.Upgrades:FindFirstChild(Hitbox.Name)
	local LevelConfig = Config:FindFirstChild(DataFolder.Tycoon.Upgrades:FindFirstChild(Config.Name).Value)

	local SelectionGUI = require(ReplicatedStorage.Game.GUI.TycoonSelection)
	local App = Roact.createElement(SelectionGUI, {
		UpgradeConfig = Config,
		LevelConfig = LevelConfig,
		Close = function()
			self:Deselect()
		end,
	}, {})

	TycoonSelectionUITree = Roact.mount(App, Knit.Player.PlayerGui, "Tycoon Selection")

	local New = TycoonSelectionOutline:Clone()
	New.Parent = Hitbox
	New.Adornee = Hitbox
	New.Name = "Selection"

	CurrentTycoonOutline = New
	TycoonSelection = Hitbox
	CurrentlySelectingTycoon = true
	LogService:Log("Selected upgrade hitbox: " .. Hitbox.Name)
end

--[[ KNIT ]]

function SelectionUIController:KnitStart()
	TycoonService = Knit.GetService("TycoonService")
	LogService = Knit.GetService("LogService")
	DataService = Knit.GetService("DataService")

	DataService.DataLoaded:Connect(function(Data)
		DataFolder = Data
	end)

	local App = Roact.createElement(require(ReplicatedStorage.Game.GUI.PickaxeSelection), {}, {})
	Roact.mount(App, Knit.Player.PlayerGui, "Pickaxe Selection")

	TycoonService.SelectUpgrade:Connect(function(UpgradeName: string)
		TycoonService:GetPlayerTycoon():andThen(function(Tycoon: Model)
			local Hitbox = Tycoon.Main.Upgrades:FindFirstChild(UpgradeName)
			self:SelectTycoonHitbox(Hitbox)
		end)
	end)
end

return SelectionUIController
