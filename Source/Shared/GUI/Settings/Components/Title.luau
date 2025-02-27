local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)

local Title = Roact.PureComponent:extend("Title")

local Theme = require(ReplicatedStorage.Game.GUI.Theme)

function Title:render()
	local Text = self.props.Text or "[UNKOWN]"
	local Subtitle = self.props.Subtitle or ""

	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 0.15),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = 0,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, {}),

		Title = Roact.createElement("TextLabel", {
			Size = UDim2.fromScale(1, 0.6),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 1,

			Text = Text,
			TextScaled = true,
			RichText = true,
			TextColor3 = Theme.TextColor,
			FontFace = Theme.Font,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, {}),

		Subtitle = Roact.createElement("TextLabel", {
			Size = UDim2.fromScale(1, 0.4),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 2,

			Text = Subtitle,
			TextScaled = true,
			RichText = true,
			TextColor3 = Theme.TextColor,
			FontFace = Theme.Font,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, {}),
	})
end

return Title
