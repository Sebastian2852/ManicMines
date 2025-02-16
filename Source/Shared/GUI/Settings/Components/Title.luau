local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)

local Title = Roact.PureComponent:extend("Title")

local Theme = require(ReplicatedStorage.Game.GUI.Theme)

function Title:render()
	local Text = self.props.Text or "[UNKOWN]"

	return Roact.createElement("TextLabel", {
		Size = UDim2.fromScale(1, 0.1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = 0,

		Text = Text,
		TextScaled = true,
		RichText = true,
		TextColor3 = Theme.TextColor,
		FontFace = Theme.Font,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, {})
end

return Title
