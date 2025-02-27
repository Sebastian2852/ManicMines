local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)

local ButtonBorder = Roact.PureComponent:extend("ButtonBorder")

function ButtonBorder:render()
	local Color = self.props.Color or Color3.new(1, 1, 1)

	return Roact.createElement("ImageLabel", {
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,

		Image = "rbxassetid://5981360137",
		ImageColor3 = Color,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(10, 10, 10, 10),
		SliceScale = 0.5,
	}, {})
end

return ButtonBorder
