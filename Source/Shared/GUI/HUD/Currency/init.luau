local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)
local Signals = require(script.Parent.Parent.Signals)

local Currency = Roact.Component:extend("Currency")

local Amount = require(script.Currency)
local MiningPower = require(ReplicatedStorage.Game.GUI.HUD.Currency.MiningPower)
local Theme = require(ReplicatedStorage.Game.GUI.Theme)

function Currency:init()
	Signals.ToggleHUDGold:Connect(function(New: boolean)
		self:setState({
			Hidden = not New,
		})
	end)
end

function Currency:render()
	local Hidden = self.state.Hidden or false

	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Top,
		}, {}),

		GoldContainer = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 0.15),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Visible = not Hidden,
			LayoutOrder = 1,
		}, {
			Gold = Roact.createElement(Amount, {
				Currency = "Gold",
				Image = Theme.Images.Gold,
			}, {}),
		}),

		MiningPowerContainer = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 0.1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Visible = not Hidden,
			LayoutOrder = 2,
		}, {
			MiningPower = Roact.createElement(MiningPower, {
				Image = Theme.Images.MiningPower,
			}, {}),
		}),
	})
end

return Currency
