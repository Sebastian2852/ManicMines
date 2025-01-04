local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Core = require(ReplicatedStorage.Game.Modules.Core)
local Roact = require(ReplicatedStorage.Packages.Roact)

local Component = Roact.Component:extend("OrelikeFrame")

function Component:render()
	local Name: string = self.props.Name
	local Amount: number = self.props.Amount
	local Icon: string = self.props.Icon
	local Gradient: ColorSequence = self.props.Color
	local Size = self.props.Size
	local Position = self.props.Position

	return Roact.createElement("Frame", {
		Size = Size,
		Position = Position,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
	}, {
		Gradient = Roact.createElement("UIGradient", {
			Color = Gradient,
		}, {}),

		Layout = Roact.createElement("UIListLayout", {
			Padding = UDim.new(0.01, 0),
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,

			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			ItemLineAlignment = Enum.ItemLineAlignment.Automatic,
			VerticalAlignment = Enum.VerticalAlignment.Center,

			HorizontalFlex = Enum.UIFlexAlignment.Fill,
			VerticalFlex = Enum.UIFlexAlignment.None,
		}, {}),

		OreImage = Roact.createElement("ImageLabel", {
			Size = UDim2.fromScale(0.1, 1),
			BackgroundTransparency = 1,
			LayoutOrder = 1,

			Image = Icon,
			ScaleType = Enum.ScaleType.Fit,
		}, {
			AspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint", {
				AspectRatio = 1,
				AspectType = Enum.AspectType.ScaleWithParentSize,
				DominantAxis = Enum.DominantAxis.Height,
			}, {}),
		}),

		Details = Roact.createElement("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			LayoutOrder = 2,
		}, {
			Layout = Roact.createElement("UIListLayout", {
				Padding = UDim.new(0, 0),
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,

				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				ItemLineAlignment = Enum.ItemLineAlignment.Automatic,
				VerticalAlignment = Enum.VerticalAlignment.Center,

				HorizontalFlex = Enum.UIFlexAlignment.Fill,
				VerticalFlex = Enum.UIFlexAlignment.Fill,
			}, {}),

			OreName = Roact.createElement("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(0.6, 1),
				LayoutOrder = 1,

				Text = Name,
				FontFace = Core.UI.Theme.TextFont,
				TextStrokeTransparency = 0,
				TextScaled = true,

				TextXAlignment = Enum.TextXAlignment.Left,

				TextColor3 = Core.UI.Theme.TextColor3,
			}, {}),

			OreAmount = Roact.createElement("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(0.22, 1),
				LayoutOrder = 2,

				Text = tostring(Amount),
				FontFace = Core.UI.Theme.TextFont,
				TextStrokeTransparency = 0,
				TextScaled = true,

				TextXAlignment = Enum.TextXAlignment.Right,

				TextColor3 = Core.UI.Theme.TextColor3,
			}, {}),
		}),
	})
end

return function(Icon: string, Name: string, Amount: number, Color: ColorSequence, Size: UDim2, Position: UDim2)
	return Roact.createElement(
		Component,
		{ Name = Name, Amount = Amount, Icon = Icon, Color = Color, Size = Size, Position = Position }
	)
end
