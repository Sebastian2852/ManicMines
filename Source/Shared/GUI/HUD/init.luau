local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Flipper = require(ReplicatedStorage.Packages.Flipper)
local Roact = require(ReplicatedStorage.Packages.Roact)

local HUD = Roact.Component:extend("HUD")

local Buttons = require(ReplicatedStorage.Game.GUI.HUD.Buttons)
local Currency = require(ReplicatedStorage.Game.GUI.HUD.Currency)
local DepthMeter = require(ReplicatedStorage.Game.GUI.HUD.DepthMeter)
local Inventory = require(ReplicatedStorage.Game.GUI.HUD.Inventory)
local Theme = require(ReplicatedStorage.Game.GUI.Theme)

local function Lerp(Start: number, End: number, Time: number)
	return Start * (1 - Time) + End * Time
end

function HUD:init()
	self.Motor = Flipper.SingleMotor.new(0)
	local Binding, SetBinding = Roact.createBinding(self.Motor:getValue())
	self.Binding = Binding
	self.Motor:onStep(SetBinding)

	self:setState({
		BelowOptimalDepth = false,
	})

	ReplicatedStorage.Player.BelowOptimalDepth:GetPropertyChangedSignal("Value"):Connect(function()
		local BelowOptimalDepth = ReplicatedStorage.Player.BelowOptimalDepth.Value
		self:setState({
			BelowOptimalDepth = BelowOptimalDepth,
		})

		self.Motor:setGoal(Flipper.Spring.new(BelowOptimalDepth and 1 or 0, {
			frequency = 4,
			dampingRatio = 1,
		}))
	end)

	ReplicatedStorage.Player.DepthDifference:GetPropertyChangedSignal("Value"):Connect(function()
		local DepthDifference = ReplicatedStorage.Player.DepthDifference.Value
		self:setState({
			DepthDifference = DepthDifference,
		})
	end)
end

function HUD:render()
	local BelowOptimalDepth = self.state.BelowOptimalDepth
	local DepthDifference = self.state.DepthDifference

	local ImageTransparency = self.Binding:map(function()
		return 1 - Lerp(0, 0.6, math.clamp(DepthDifference / 10, 0, 1))
	end)

	return Roact.createFragment({
		HUD = Roact.createElement("ScreenGui", {
			ResetOnSpawn = false,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		}, {
			App = Roact.createElement("Frame", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
			}, {
				InventoryContainer = Roact.createElement("Frame", {
					Size = UDim2.fromScale(0.14, 0.6),
					Position = UDim2.fromScale(1, 1),
					AnchorPoint = Vector2.new(1, 1),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
				}, {
					Inventory = Roact.createElement(Inventory, {}, {}),
				}),

				CurrencyContainer = Roact.createElement("Frame", {
					Size = UDim2.fromScale(0.2, 0.3),
					Position = UDim2.fromScale(0, 0.5),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
				}, {
					Padding = Roact.createElement("UIPadding", {
						PaddingLeft = UDim.new(0, 5),
					}, {}),

					Currency = Roact.createElement(Currency, {}, {}),
				}),

				ButtonsContainer = Roact.createElement("Frame", {
					Size = UDim2.fromScale(0.3, 0.1),
					Position = UDim2.fromScale(0, 1),
					AnchorPoint = Vector2.new(0, 1),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
				}, {
					Padding = Roact.createElement("UIPadding", {
						PaddingLeft = UDim.new(0, 15),
						PaddingBottom = UDim.new(0, 15),
					}, {}),

					Buttons = Roact.createElement(Buttons, {}, {}),
				}),

				DepthMeterContainer = Roact.createElement("Frame", {
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
				}, {
					App = Roact.createElement(DepthMeter, {}, {}),
				}),
			}),
		}),
		TurningPointEffects = Roact.createElement("ScreenGui", {
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			DisplayOrder = 200,
			IgnoreGuiInset = true,
		}, {
			DepthWarning = BelowOptimalDepth and Roact.createElement("ImageLabel", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,

				Image = Theme.Images.Vignette,
				ImageColor3 = Color3.new(1, 0, 0),
				ImageTransparency = ImageTransparency,
			}, {}),
		}),
	})
end

return HUD
