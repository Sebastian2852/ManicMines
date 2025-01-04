local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Packages.Roact)

local Theme = require(script.Parent.Parent.Theme)

local Title = Roact.Component:extend("Title")

function Title:render()
	local GameName = self.props.GameName or "[GAME NAME]"
	local UpdateName = self.props.UpdateName or "[UPDATE NAME]"

	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromScale(0.5, 0.17),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}, {}),

		Name = Roact.createElement("TextLabel", {
			Size = UDim2.fromScale(1, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,

			Text = GameName,
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Bottom,
			TextColor3 = Theme.TextColor,
			FontFace = Theme.Font,
		}, {}),

		Update = Roact.createElement("TextLabel", {
			Size = UDim2.fromScale(1, 0.15),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,

			Text = UpdateName,
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextColor3 = Theme.TextDisabledColor,
			FontFace = Theme.Font,
		}, {}),
	})
end

return Title
