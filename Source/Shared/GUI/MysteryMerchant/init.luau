local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)

local MysteryMerchant = Roact.Component:extend("MysteryMerchant")

local Theme = require(ReplicatedStorage.Game.GUI.Theme)

function MysteryMerchant:render()
	return Roact.createElement("ScreenGui", {
		ResetOnSpawn = false,
	}, {
		App = Roact.createElement("Frame", {
			Size = UDim2.fromScale(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Theme.BackgroundColor,
			BackgroundTransparency = 0.5,
			BorderSizePixel = 0,
		}, {
			Padding = Roact.createElement("UIPadding", {
				PaddingTop = UDim.new(0, 10),
				PaddingBottom = UDim.new(0, 10),
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
			}, {}),

			Title = Roact.createElement("TextLabel", {
				Size = UDim2.fromScale(1, 0.1),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,

				Text = "Mystery Merchant",
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				FontFace = Theme.Font,
				TextColor3 = Theme.TextColor,
			}, {}),

			Content = Roact.createElement("Frame", {
				Size = UDim2.fromScale(1, 0.9),
				Position = UDim2.fromScale(0, 0.1),
				BackgroundColor3 = Theme.BackgroundColor,
				BackgroundTransparency = 0.75,
				BorderSizePixel = 0,
			}, {
				Corners = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0, 7),
				}, {}),
			}),
		}),
	})
end

return MysteryMerchant
