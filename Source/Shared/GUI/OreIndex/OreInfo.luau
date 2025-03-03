local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)

local OreInfo = Roact.Component:extend("OreInfo")

local Theme = require(ReplicatedStorage.Game.GUI.Theme)

function OreInfo:render()
	local Block = self.props.Block
	if Block == nil then
		return
	end

	local DisplayName = Block:GetAttribute("DisplayName")

	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, {}),

		OreHeader = Roact.createElement("TextLabel", {
			Size = UDim2.fromScale(1, 0.1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 1,

			Text = DisplayName,
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = Theme.TextColor,
			FontFace = Theme.Font,
		}, {}),
	})
end

return OreInfo
