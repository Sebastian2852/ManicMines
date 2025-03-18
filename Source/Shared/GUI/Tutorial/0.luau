local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)

local Stage0 = Roact.Component:extend("Stage0")

function Stage0:render()
	return Roact.createElement("TextLabel", {
		Size = UDim2.fromScale(1, 0.1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,

		Text = "Stage 0",
		TextScaled = true,
		TextColor3 = Color3.fromRGB(255, 255, 255),
	}, {})
end

return Stage0
