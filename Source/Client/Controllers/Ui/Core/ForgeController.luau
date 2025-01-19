local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)
local Signal = require(ReplicatedStorage.Packages.Signal)

local ForgeController = Knit.CreateController({ Name = "ForgeController" })

local DataService
local ForgeService
local CharacterController
local DataFolder: Core.DataFolder

local CloseUI = Signal.new()

-- [[ PUBLIC ]] --

--[=[
Returns a boolean based on if the passed pickaxe should be locked or unlocked
]=]
function ForgeController:IsPickaxeLocked(Pickaxe: Configuration): boolean
	local MainUpgrade = Pickaxe:GetAttribute("MainUpgrade")
	local LevelValue = Pickaxe.Upgrades:FindFirstChild(MainUpgrade)
	local NeededLevel = LevelValue.Value

	local DataValue = DataFolder.Tycoon.Upgrades:FindFirstChild(MainUpgrade)
	local CurrentLevel = DataValue.Value

	if CurrentLevel >= NeededLevel then
		return false
	end

	return true
end

--[=[
Toggles all the prompts "enabled" property to "new" param
]=]
function ForgeController:TogglePrompts(Prompts: { ProximityPrompt }, New: boolean)
	for _, Prompt in pairs(Prompts) do
		Prompt.Enabled = New
	end
end

function ForgeController:KnitStart()
	DataService = Knit.GetService("DataService")
	ForgeService = Knit.GetService("ForgeService")
	CharacterController = Knit.GetController("CharacterController")

	local Tag = ""

	ForgeService:GetPromptTag():andThen(function(PromptTag)
		Tag = PromptTag
	end)

	local GUI
	local ForgeGUI = require(ReplicatedStorage.Game.GUI.Forge)
	local App = Roact.createElement(ForgeGUI, {
		CloseSignal = CloseUI,
	}, {})

	DataService.DataLoaded:Connect(function(PlayerDataFolder: Core.DataFolder)
		DataFolder = PlayerDataFolder
	end)

	ForgeService.OpenForge:Connect(function()
		GUI = Roact.mount(App, Knit.Player.PlayerGui, "Forge")
		CharacterController:DisableMovement()
		local Prompts = CollectionService:GetTagged(Tag)
		self:TogglePrompts(Prompts, false)
	end)

	CloseUI:Connect(function()
		Roact.unmount(GUI)
		CharacterController:EnableMovement()
		local Prompts = CollectionService:GetTagged(Tag)
		self:TogglePrompts(Prompts, true)
	end)
end

return ForgeController
