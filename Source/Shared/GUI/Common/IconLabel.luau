local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)

local IconLabel = Roact.PureComponent:extend("IconLabel")

local Theme = require(script.Parent.Parent.Theme)

function IconLabel:render()
	local LayoutOrder = self.props.LayoutOrder or 0
	local IconImage = self.props.Image or Theme.Images.Missing
	local IconImageColor = self.props.ImageColor or Color3.new(1, 1, 1)
	local Text = self.props.Text or "[UNKNOWN]"

	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = LayoutOrder,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			Padding = UDim.new(0, 10),
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
		}, {}),

		Icon = Roact.createElement("ImageLabel", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 1,

			Image = IconImage,
			ImageColor3 = IconImageColor,
			ScaleType = Enum.ScaleType.Fit,
		}, {
			AspectRatio = Roact.createElement("UIAspectRatioConstraint", {
				AspectRatio = 1,
				AspectType = Enum.AspectType.FitWithinMaxSize,
				DominantAxis = Enum.DominantAxis.Height,
			}, {}),
		}),

		Text = Roact.createElement("TextLabel", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 2,

			Text = Text,
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = Theme.TextColor,
			FontFace = Theme.Font,
		}, {}),
	})
end

return IconLabel
