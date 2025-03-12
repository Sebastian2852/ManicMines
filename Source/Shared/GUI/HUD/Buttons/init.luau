local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)
local Signals = require(script.Parent.Parent.Signals)

local Buttons = Roact.Component:extend("Buttons")

local AnimatedButton = require(script.AnimatedButton)
local Theme = require(ReplicatedStorage.Game.GUI.Theme)

local TeleportService
local OreIndexController
local TycoonEditorController

function Buttons:init()
	local DataService = Knit.GetService("DataService")
	TeleportService = Knit.GetService("TeleportService")
	OreIndexController = Knit.GetController("OreIndexController")
	TycoonEditorController = Knit.GetController("TycoonEditorController")

	DataService:GetPlayerDataFolder():andThen(function(DataFolder: Core.DataFolder)
		local InTycoon = DataFolder.InTycoon

		InTycoon:GetPropertyChangedSignal("Value"):Connect(function()
			self:setState({
				InTycoon = InTycoon.Value,
			})
		end)

		self:setState({
			InTycoon = InTycoon.Value,
		})
	end)

	Signals.ToggleHUDButtons:Connect(function(New: boolean)
		self:setState({
			Hidden = not New,
		})
	end)
end

function Buttons:render()
	local InTycoon = self.state.InTycoon or false
	local Hidden = self.state.Hidden or false

	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			Padding = UDim.new(0, 10),
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
		}, {}),

		SurfaceButton = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 1,
			Visible = not Hidden,
		}, {
			AspectRatio = Roact.createElement("UIAspectRatioConstraint", {
				AspectRatio = 1,
				AspectType = Enum.AspectType.FitWithinMaxSize,
				DominantAxis = Enum.DominantAxis.Height,
			}, {}),

			Button = Roact.createElement(AnimatedButton, {
				Background = Theme.Images.SurfaceButton,
				Icon = "",
				OnClick = function()
					TeleportService:TeleportToSurface()
				end,
			}, {}),
		}),

		TycoonTeleport = not InTycoon and Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 2,
			Visible = not Hidden,
		}, {
			AspectRatio = Roact.createElement("UIAspectRatioConstraint", {
				AspectRatio = 1,
				AspectType = Enum.AspectType.FitWithinMaxSize,
				DominantAxis = Enum.DominantAxis.Height,
			}, {}),

			Button = Roact.createElement(AnimatedButton, {
				Background = Theme.Images.TycoonTeleportButton,
				Icon = "",
				OnClick = function()
					TeleportService:TeleportToTycoon()
				end,
			}, {}),
		}),

		TycoonEditor = InTycoon and Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 2,
			Visible = not Hidden,
		}, {
			AspectRatio = Roact.createElement("UIAspectRatioConstraint", {
				AspectRatio = 1,
				AspectType = Enum.AspectType.FitWithinMaxSize,
				DominantAxis = Enum.DominantAxis.Height,
			}, {}),

			Button = Roact.createElement(AnimatedButton, {
				Background = Theme.Images.TycoonEditor,
				Icon = "",
				OnClick = function()
					TycoonEditorController:OpenGUI()
				end,
			}, {}),
		}),

		OreIndex = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 3,
			Visible = not Hidden,
		}, {
			AspectRatio = Roact.createElement("UIAspectRatioConstraint", {
				AspectRatio = 1,
				AspectType = Enum.AspectType.FitWithinMaxSize,
				DominantAxis = Enum.DominantAxis.Height,
			}, {}),

			Button = Roact.createElement(AnimatedButton, {
				Background = Theme.Images.OreIndexButton,
				Icon = "",
				OnClick = function()
					OreIndexController:Open()
				end,
			}, {}),
		}),
	})
end

return Buttons
