local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)

local NumberSetting = Roact.Component:extend("NumberSetting")

local CreateNumberInput = require(ReplicatedStorage.Game.GUI.Settings.Components.NumberInput)
local Theme = require(ReplicatedStorage.Game.GUI.Theme)

function NumberSetting:render()
	local SettingName = self.props.SettingName
	local DisplayName = self.props.DisplayName
	local Description = self.props.Description
	local MinValue = self.props.MinValue
	local MaxValue = self.props.MaxValue
	local LayoutOrder = self.props.LayoutOrder

	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 0.15),
		Position = UDim2.fromScale(0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),

		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = LayoutOrder,
	}, {
		Info = Roact.createElement("Frame", {
			Size = UDim2.fromScale(0.84, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, {
			Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
			}, {}),

			NameLabel = Roact.createElement("TextLabel", {
				Size = UDim2.fromScale(0.9, 0.6),
				BackgroundTransparency = 1,
				LayoutOrder = 1,

				Text = DisplayName,
				TextScaled = true,
				RichText = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				FontFace = Theme.Font,
				TextColor3 = Theme.TextColor,
			}, {}),

			DescriptionLabel = Roact.createElement("TextLabel", {
				Size = UDim2.fromScale(0.9, 0.4),
				Position = UDim2.fromScale(0, 0.6),
				BackgroundTransparency = 1,
				LayoutOrder = 2,

				Text = Description,
				TextScaled = true,
				RichText = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				FontFace = Theme.Font,
				TextColor3 = Theme.TextDisabledColor,
			}, {}),
		}),

		Input = CreateNumberInput(self, SettingName, MinValue, MaxValue),
	})
end

return NumberSetting
