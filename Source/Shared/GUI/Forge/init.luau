-- # selene: allow(mixed_table)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)
local Signal = require(ReplicatedStorage.Packages.Signal)

local Forge = Roact.Component:extend("Forge")

local Camera = Workspace.CurrentCamera
local CameraPos = Workspace.Game:FindFirstChild("ForgeCameraPos")

local UIService
local DataService

local PickaxeButton = require(script.PickaxeButton)
local Theme = require(script.Parent.Theme)

function Forge:CreateOwnedButton(Name: string)
	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 0.08),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		App = Roact.createElement(PickaxeButton, {
			Name = Name,
		}, {}),
	})
end

function Forge:CreateUnOwnedButton(Name: string)
	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 0.08),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		App = Roact.createElement(PickaxeButton, {
			Name = Name,
			NameColor = Color3.fromHex("3f3f3f"),
		}, {}),
	})
end

function Forge:CreateLockedButton()
	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 0.08),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		App = Roact.createElement(PickaxeButton, {
			Name = "???",
			NameColor = Color3.fromHex("3f3f3f"),
		}, {}),
	})
end

function Forge:init()
	UIService = Knit.GetService("UIService")
	DataService = Knit.GetService("DataService")
end

function Forge:didMount()
	self:CreateButtons()
	CameraPos = Workspace.Game:FindFirstChild("ForgeCameraPos")

	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
	UIService:ToggleInventory(false)

	if CameraPos then
		Camera.CameraType = Enum.CameraType.Scriptable
		Camera.CFrame = CameraPos.CFrame
	end
end

function Forge:willUnmount()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
	UIService:ToggleInventory(true)

	Camera.CameraType = Enum.CameraType.Custom
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

			if v.Value == true then
				table.insert(Elements, self:CreateOwnedButton(PickaxeConfig:GetAttribute("Name")))
			else
				table.insert(Elements, self:CreateUnOwnedButton(PickaxeConfig:GetAttribute("Name")))
			end
		end

		self:setState({
			Buttons = Elements,
		})
	end)
end

function Forge:render()
	local PickaxeButtons = self.state.Buttons :: { [number]: Roact.Element } or {}
	local CloseSignal: Signal.Signal = self.props.CloseSignal

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
				Pickaxes = Roact.createElement("Frame", {
					Size = UDim2.fromScale(0.7, 0.8),
					Position = UDim2.fromScale(0.1, 0.5),
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
						CanvasSize = UDim2.fromScale(1, 1),
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

						Padding = Roact.createElement("UIPadding", {
							PaddingTop = UDim.new(0, 10),
							PaddingLeft = UDim.new(0, 10),
							PaddingRight = UDim.new(0, 10),
							PaddingBottom = UDim.new(0, 10),
						}, {}),

						table.unpack(PickaxeButtons),
					}),
				}),
			}),
		}),
	})
end

return Forge
