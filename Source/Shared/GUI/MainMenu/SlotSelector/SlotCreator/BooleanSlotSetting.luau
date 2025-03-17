local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)
local Theme = require(ReplicatedStorage.Game.GUI.Theme)

local BooleanSlotSetting = Roact.Component:extend("BooleanSlotSetting")

function BooleanSlotSetting:init()
	self:setState({
		IsChecked = self.props.InitialValue or false,
	})
end

function BooleanSlotSetting:render()
	local DisplayName = self.props.DisplayName or "[UNKNOWN]"
	local Description = self.props.Description or "[UNKNOWN]"
	local LayoutOrder = self.props.LayoutOrder or 99999

	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 0.3),
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

		Toggle = Roact.createElement("ImageButton", {
			Size = UDim2.fromScale(0.1, 0.6),
			Position = UDim2.fromScale(0.95, 0.5),
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundTransparency = 1,
			Image = self.state.IsChecked and "rbxasset://textures/DeveloperFramework/checkbox_checked_dark.png"
				or "rbxasset://textures/DeveloperFramework/checkbox_unchecked_dark.png", -- Replace with your tick image asset ID
			ImageColor3 = Theme.TextColor,

			[Roact.Event.MouseButton1Click] = function()
				local newCheckedState = not self.state.IsChecked
				self:setState({
					IsChecked = newCheckedState,
				})

				if self.props.OnToggle then
					self.props.OnToggle(newCheckedState)
				end
			end,
		}, {
			AspectRatio = Roact.createElement("UIAspectRatioConstraint", {
				AspectRatio = 1,
				AspectType = Enum.AspectType.ScaleWithParentSize,
				DominantAxis = Enum.DominantAxis.Height,
			}, {}),
		}),
	})
end

return BooleanSlotSetting
