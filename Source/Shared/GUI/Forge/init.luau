-- # selene: allow(mixed_table)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Display = require(script.Display)
local Enums = require(ReplicatedStorage.Game.Modules.Enums)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Signals = require(ReplicatedStorage.Game.GUI.Signals)

local Forge = Roact.Component:extend("Forge")

local Camera = Workspace.CurrentCamera
local CameraPos = Workspace.Game:FindFirstChild("ForgeCameraPos")

local DataService

local FloatingInfo = require(ReplicatedStorage.Game.GUI.Common.FloatingInfo)
local InfoFrame = require(script.InfoFrame)
local PickaxeButton = require(script.PickaxeButton)
local Theme = require(script.Parent.Theme)

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

local function IsPickaxeBought(Pickaxe: Configuration): boolean
	local DataFolder: Core.DataFolder =
		ReplicatedStorage.PlayerData:FindFirstChild(tostring(Players.LocalPlayer.UserId))
	local DataValue = DataFolder.Pickaxes.Owned:FindFirstChild(Pickaxe.Name)

	return DataValue.Value
end

local function IsPickaxeEquipped(Pickaxe: Configuration): boolean
	local DataFolder: Core.DataFolder =
		ReplicatedStorage.PlayerData:FindFirstChild(tostring(Players.LocalPlayer.UserId))
	return DataFolder.Pickaxes.Equipped.Value == tonumber(Pickaxe.Name)
end

local function GetPickaxeImage(Config: Configuration): string
	local MainOre = Config:FindFirstChild("MainOre") :: StringValue
	local Ore = ReplicatedStorage.Assets.Ores:FindFirstChild(MainOre.Value)
		or ReplicatedStorage.Assets.Stone :: BasePart
	return Ore:GetAttribute("EmblemImageID")
end

function Forge:CreateOwnedButton(Name: string, Config: Configuration)
	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(0.95, 0.08),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = tonumber(Config.Name),
	}, {
		App = Roact.createElement(PickaxeButton, {
			PickaxeConfig = Config,
			Name = Name,
			Image = GetPickaxeImage(Config),
		}, {}),
	})
end

function Forge:CreateUnOwnedButton(Name: string, Config: Configuration)
	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(0.95, 0.08),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = tonumber(Config.Name),
	}, {
		App = Roact.createElement(PickaxeButton, {
			PickaxeConfig = Config,
			Name = Name,
			Image = GetPickaxeImage(Config),
			NameColor = Color3.fromHex("3f3f3f"),
			ImageColor = Color3.fromHex("3f3f3f"),
		}, {}),
	})
end

function Forge:CreateLockedButton(Config: Configuration)
	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(0.95, 0.08),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = tonumber(Config.Name),
	}, {
		App = Roact.createElement(PickaxeButton, {
			PickaxeConfig = Config,
			Name = "???",
			Image = GetPickaxeImage(Config),
			NameColor = Color3.fromHex("3f3f3f"),
			ImageColor = Color3.new(0, 0, 0),
		}, {}),
	})
end

function Forge:init()
	DataService = Knit.GetService("DataService")

	Display.SetCurrentPickaxe:Connect(function(Pickaxe: Configuration)
		self:setState({
			CurrentPickaxe = Pickaxe,
		})
	end)

	Display.UpdateButtons:Connect(function()
		self:CreateButtons()
	end)
end

function Forge:didMount()
	self:CreateButtons()
	CameraPos = Workspace.Game:FindFirstChild("ForgeCameraPos")

	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
	Signals.ToggleInventory:Fire(false)
	Signals.ToggleHUDButtons:Fire(false)
	Signals.ToggleHUDGold:Fire(false)
	Signals.ToggleHotbar:Fire(false)

	if CameraPos then
		Camera.CameraType = Enum.CameraType.Scriptable
		Camera.CFrame = CameraPos.CFrame
	end
end

function Forge:willUnmount()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
	Signals.ToggleInventory:Fire(true)
	Signals.ToggleHUDButtons:Fire(true)
	Signals.ToggleHUDGold:Fire(true)
	Signals.ToggleHotbar:Fire(true)

	Camera.CameraType = Enum.CameraType.Custom
	Display:CleanUp()
end

function Forge:CreateButtons()
	DataService:GetPlayerDataFolder():andThen(function(DataFolder: Core.DataFolder)
		local Elements = {}

		for _, v: BoolValue in pairs(DataFolder.Pickaxes.Owned:GetChildren()) do
			local PickaxeConfig = ReplicatedStorage.Assets.Pickaxe.Pickaxes:FindFirstChild(v.Name)
			if not PickaxeConfig then
				warn("No config")
				continue
			end

			if IsPickaxeLocked(PickaxeConfig) then
				table.insert(Elements, self:CreateLockedButton(PickaxeConfig))
				continue
			end

			if v.Value == true then
				table.insert(Elements, self:CreateOwnedButton(PickaxeConfig:GetAttribute("Name"), PickaxeConfig))
			else
				table.insert(Elements, self:CreateUnOwnedButton(PickaxeConfig:GetAttribute("Name"), PickaxeConfig))
			end
		end

		self:setState({
			Buttons = Elements,
		})
	end)
end

function Forge:CreateLeftInfo(Top: string, Bottom: string, Position: UDim2, AnchorPoint: Vector2)
	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(0.2, 0.2),
		Position = Position,
		AnchorPoint = AnchorPoint,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		App = Roact.createElement(FloatingInfo, {
			TopText = Top,
			BottomText = Bottom,
			Direction = Enums.FloatingInfoDirection.Left,
		}, {}),
	})
end

function Forge:CreateRightInfo(Top: string, Bottom: string, Position: UDim2, AnchorPoint: Vector2)
	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(0.2, 0.2),
		Position = Position,
		AnchorPoint = AnchorPoint,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		App = Roact.createElement(FloatingInfo, {
			TopText = Top,
			BottomText = Bottom,
			Direction = Enums.FloatingInfoDirection.Right,
		}, {}),
	})
end

function Forge:render()
	local PickaxeButtons = self.state.Buttons :: { [number]: Roact.Element } or {}
	local CloseSignal: Signal.Signal = self.props.CloseSignal

	local SelectedConfig = self.state.CurrentPickaxe :: Configuration
	local SelectedTool = SelectedConfig and SelectedConfig:FindFirstChildWhichIsA("Tool")

	local Delay = SelectedTool and SelectedTool:GetAttribute("Delay") or -1
	local Power = SelectedTool and SelectedTool:GetAttribute("Damage") or -1
	local Range = SelectedTool and (SelectedTool:GetAttribute("Range") / 6) or -1

	local Costs = SelectedConfig and SelectedConfig:FindFirstChild("Ores")
	local IsLocked = SelectedConfig and IsPickaxeLocked(SelectedConfig) or false
	local IsUnlocked = SelectedConfig and IsPickaxeBought(SelectedConfig) or false
	local Equipped = SelectedConfig and IsPickaxeEquipped(SelectedConfig) or false

	local UpgradeMessage = ""

	if SelectedConfig then
		local Upgrade = SelectedConfig.Upgrades:FindFirstChild(SelectedConfig:GetAttribute("MainUpgrade"))
		local UpgradeConfig = Core.Assets.Tycoon.Upgrades:FindFirstChild(SelectedConfig:GetAttribute("MainUpgrade"))
		UpgradeMessage = `Level {Upgrade.Value} {UpgradeConfig:GetAttribute("UpgradeName")} needed`
	end

	return Roact.createElement("ScreenGui", {
		ResetOnSpawn = false,
		ClipToDeviceSafeArea = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		ScreenInsets = Enum.ScreenInsets.None,
		SafeAreaCompatibility = Enum.SafeAreaCompatibility.None,
	}, {
		App = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, {
			Top = Roact.createElement("Frame", {
				Size = UDim2.fromScale(1, 0.3),
				BackgroundColor3 = Color3.new(1, 1, 1),
				BorderSizePixel = 0,
			}, {
				Gradient = Roact.createElement("UIGradient", {
					Rotation = 90,
					Color = ColorSequence.new(Color3.new(0, 0, 0)),
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0, 0),
						NumberSequenceKeypoint.new(1, 1, 0),
					}),
				}, {}),

				Title = Roact.createElement("TextLabel", {
					Size = UDim2.fromScale(0.3, 0.3),
					Position = UDim2.fromScale(0.5, 0.1),
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,

					Text = "<u>Forge</u>",
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true,
					RichText = true,
					FontFace = Theme.Font,
				}, {}),

				CloseButton = Roact.createElement("TextButton", {
					Size = UDim2.fromScale(0.1, 0.1),
					Position = UDim2.new(0.5, 0, 0.4, 10),
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundColor3 = Theme.BackgroundColorRed,
					BorderSizePixel = 0,

					Text = "<- Back",
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true,
					FontFace = Theme.Font,

					[Roact.Event.MouseButton1Click] = function()
						CloseSignal:Fire()
					end,
				}, {
					Corners = Roact.createElement("UICorner", {
						CornerRadius = UDim.new(0, 7),
					}, {}),
				}),
			}),

			Left = Roact.createElement("Frame", {
				Size = UDim2.fromScale(0.3, 1),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
			}, {
				Padding = Roact.createElement("UIPadding", {
					PaddingTop = UDim.new(0, 10),
					PaddingLeft = UDim.new(0, 10),
					PaddingRight = UDim.new(0, 10),
					PaddingBottom = UDim.new(0, 10),
				}, {}),

				Pickaxes = Roact.createElement("Frame", {
					Size = UDim2.fromScale(0.7, 0.8),
					Position = UDim2.new(0, 10, 0.5, 0),
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundColor3 = Color3.new(0, 0, 0),
					BackgroundTransparency = 0.5,
					BorderSizePixel = 0,
				}, {
					Scroller = Roact.createElement("ScrollingFrame", {
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 1,
						BorderSizePixel = 0,

						AutomaticCanvasSize = Enum.AutomaticSize.Y,
						CanvasSize = UDim2.fromScale(1, 2),
						ScrollBarThickness = 0,
						VerticalScrollBarInset = Enum.ScrollBarInset.None,
						ScrollingDirection = Enum.ScrollingDirection.Y,
					}, {
						Layout = Roact.createElement("UIListLayout", {
							SortOrder = Enum.SortOrder.LayoutOrder,
							FillDirection = Enum.FillDirection.Vertical,
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							Padding = UDim.new(0, 10),
						}, {}),

						table.unpack(PickaxeButtons),
					}),
				}),
			}),

			Info = SelectedConfig and Roact.createElement("Frame", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
			}, {
				PickaxeInfo = Roact.createElement("Frame", {
					Size = UDim2.fromScale(0.15, 0.5),
					Position = UDim2.new(1, -10, 0.5, 0),
					AnchorPoint = Vector2.new(1, 0.5),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
				}, {
					App = Roact.createElement(InfoFrame, {
						Power = IsLocked and "???" or Power,
						Range = IsLocked and "???" or Range,
						Delay = IsLocked and "???" or Delay,
						Name = IsLocked and "???" or SelectedConfig:GetAttribute("Name"),
						ShowButton = not IsLocked,
						Unlocked = IsUnlocked,
						Equipped = Equipped,
						ConfigName = SelectedConfig and SelectedConfig.Name,
						Costs = IsLocked and Core.OreList.New() or (Costs and Core.OreList.CreateFromFolder(Costs)),
						IsLocked = IsLocked,
						UpgradeMessage = UpgradeMessage,
					}, {}),
				}),

				Power = self:CreateRightInfo(
					"Power",
					IsLocked and "???" or tostring(Power),
					UDim2.fromScale(0.59, 0.25),
					Vector2.new(0.5, 0.5)
				),

				Range = self:CreateRightInfo(
					"Range",
					IsLocked and "???" or tostring(Range),
					UDim2.fromScale(0.59, 0.5),
					Vector2.new(0.5, 0.5)
				),

				Delay = self:CreateLeftInfo(
					"Delay",
					IsLocked and "???" or tostring(Delay),
					UDim2.fromScale(0.405, 0.45),
					Vector2.new(0.5, 0.5)
				),
			}),
		}),
	})
end

return Forge
