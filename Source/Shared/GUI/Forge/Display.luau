local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Signal = require(ReplicatedStorage.Packages.Signal)
local Trove = require(ReplicatedStorage.Packages.trove)

local Camera = Workspace.CurrentCamera

local Display = {}

Display.Trove = Trove.new()
Display.SetCurrentPickaxe = Signal.new()
Display.UpdateButtons = Signal.new()
Display.CurrentPickaxe = nil :: Model | nil

local function IsPickaxeLocked(Pickaxe: Configuration): boolean
	local MainUpgrade = Pickaxe:GetAttribute("MainUpgrade")
	local LevelValue = Pickaxe.Upgrades:WaitForChild(MainUpgrade)
	local NeededLevel = LevelValue.Value

	local DataFolder = ReplicatedStorage.PlayerData:FindFirstChild(tostring(Players.LocalPlayer.UserId))
	local DataValue = DataFolder.Tycoon.Upgrades:FindFirstChild(MainUpgrade)
	local CurrentLevel = DataValue.Value

	if CurrentLevel >= NeededLevel then
		return false
	end

	return true
end

function Display.HidePickaxe()
	if Display.CurrentPickaxe then
		Display.CurrentPickaxe:PivotTo(Camera.CFrame + Vector3.new(0, -10, 0))
	end
end

--[=[
	Show a pickaxe on the screen
]=]
function Display.ShowPickaxe(PickaxeConfig: Configuration)
	local Tool = PickaxeConfig:FindFirstChildWhichIsA("Tool")
	if not Tool then
		return
	end

	local IsLocked = IsPickaxeLocked(PickaxeConfig)

	Display.HidePickaxe()
	Display.SetCurrentPickaxe:Fire(PickaxeConfig)
	local Model = Instance.new("Model")

	for _, v in pairs(Tool:GetChildren()) do
		local New = v:Clone() :: BasePart | Instance
		New.Parent = Model

		if New:IsA("BasePart") then
			New.Anchored = true

			if IsLocked then
				New.Color = Color3.new(0, 0, 0)
				New.Material = Enum.Material.SmoothPlastic
				New.MaterialVariant = ""
			end
		end

		if New.Name == "Handle" then
			Model.PrimaryPart = New
		end
	end

	Model.Parent = Camera
	Model:PivotTo(Workspace.Game.ForgePickaxePos.CFrame)
	Display.CurrentPickaxe = Model
	Display.Trove:Add(Model)
end

function Display.CleanUp()
	Display.Trove:Clean()
end

return Display
