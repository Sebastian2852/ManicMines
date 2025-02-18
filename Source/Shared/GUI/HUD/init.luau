local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)

local HUD = Roact.Component:extend("HUD")

local Buttons = require(ReplicatedStorage.Game.GUI.HUD.Buttons)
local Currency = require(ReplicatedStorage.Game.GUI.HUD.Currency)
local DepthMeter = require(ReplicatedStorage.Game.GUI.HUD.DepthMeter)
local Inventory = require(ReplicatedStorage.Game.GUI.HUD.Inventory)

function HUD:render()
	return Roact.createElement("ScreenGui", {
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
	})
end

return HUD
