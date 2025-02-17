local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)
local Signals = require(script.Parent.Parent.Signals)

local Currency = Roact.Component:extend("Currency")

local Amount = require(script.Currency)
local Theme = require(script.Parent.Parent.Theme)

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
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
		}, {}),

		GoldContainer = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 0.15),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Visible = not Hidden,
		}, {
			Gold = Roact.createElement(Amount, {
				Currency = "Gold",
				Image = Theme.Images.Gold,
			}, {}),
		}),
	})
end

return Currency
