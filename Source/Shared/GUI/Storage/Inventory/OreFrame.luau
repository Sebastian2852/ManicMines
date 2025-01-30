local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)

local OreFrame = Roact.PureComponent:extend("OreFrame")

local Theme = require(script.Parent.Parent.Parent.Theme)

function OreFrame:render()
	local LayoutOrder = self.props.LayoutOrder or 0
	local Amount = self.props.Amount or -1
	local IconImage = self.props.Image or Theme.Images.Missing
	local Text = self.props.Text or "[UNKNOWN]"

	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = LayoutOrder,
	}, {
		Info = Roact.createElement("Frame", {
			Size = UDim2.fromScale(0.5, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
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
				ScaleType = Enum.ScaleType.Fit,
			}, {
				AspectRatio = Roact.createElement("UIAspectRatioConstraint", {
					AspectRatio = 1,
					AspectType = Enum.AspectType.ScaleWithParentSize,
					DominantAxis = Enum.DominantAxis.Height,
				}, {}),
			}),

			Text = Roact.createElement("TextLabel", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				LayoutOrder = 2,

				Text = Text .. " - " .. Amount,
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = Theme.TextColor,
				FontFace = Theme.Font,
			}, {}),
		}),

		Buttons = Roact.createElement("Frame", {
			Size = UDim2.fromScale(0.5, 1),
			Position = UDim2.fromScale(0.5, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, {}),
	})
end

return OreFrame
