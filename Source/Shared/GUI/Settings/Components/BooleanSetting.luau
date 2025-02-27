local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)

local BooleanSetting = Roact.Component:extend("BooleanSetting")

local CreateCheckbox = require(ReplicatedStorage.Game.GUI.Settings.Components.Checkbox)
local Theme = require(ReplicatedStorage.Game.GUI.Theme)

function BooleanSetting:render()
	local SettingName = self.props.SettingName or ""
	local DisplayName = self.props.DisplayName or "[UNKOWN]"
	local Description = self.props.Description or "[UNKOWN]"
	local LayoutOrder = self.props.LayoutOrder or 99999

	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 0.15),
		Position = UDim2.fromScale(0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		LayoutOrder = LayoutOrder,

		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		Info = Roact.createElement("Frame", {
			Size = UDim2.fromScale(0.9, 1),
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

		Toggle = CreateCheckbox(self, SettingName),
	})
end

return BooleanSetting
