local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)

local LoadingSlots = Roact.Component:extend("LoadingSlots")

local Theme = require(script.Parent.Parent.Parent.Theme)

function LoadingSlots:render()
	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		Label = Roact.createElement("TextLabel", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,

			Text = "Loading",
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextColor3 = Theme.TextDisabledColor,
			FontFace = Theme.Font,
		}, {}),
	})
end

return LoadingSlots
