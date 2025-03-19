local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)

local Stage1 = Roact.Component:extend("Stage1")

local Signals = require(ReplicatedStorage.Game.GUI.Signals)
local Theme = require(ReplicatedStorage.Game.GUI.Theme)

function Stage1:didMount()
	Signals.ToggleHUDButtons:Fire(true)
	Signals.ToggleHUDGold:Fire(false)
	Signals.ToggleInventory:Fire(false)
end

function Stage1:render()
	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		DarkenTop = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 0.85),
			BackgroundColor3 = Theme.BackgroundColor,
			BackgroundTransparency = 0.5,
			BorderSizePixel = 0,
		}, {}),

		DarkenBottom = Roact.createElement("Frame", {
			Size = UDim2.fromScale(0.82, 0.15),
			Position = UDim2.fromScale(1, 1),
			AnchorPoint = Vector2.new(1, 1),
			BackgroundColor3 = Theme.BackgroundColor,
			BackgroundTransparency = 0.5,
			BorderSizePixel = 0,
		}, {}),

		InfoBox = Roact.createElement("Frame", {
			Size = UDim2.fromScale(0.5, 0.3),
			Position = UDim2.new(0.5, 0, 0.9, 0),
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundColor3 = Theme.BackgroundColor,
			BackgroundTransparency = 0.5,
			BorderSizePixel = 0,
			ZIndex = 2,
		}, {
			Corners = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 10),
			}, {}),

			Layout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}, {}),

			Content = Roact.createElement("Frame", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				LayoutOrder = 1,
			}, {
				Padding = Roact.createElement("UIPadding", {
					PaddingTop = UDim.new(0, 10),
					PaddingBottom = UDim.new(0, 10),
					PaddingLeft = UDim.new(0, 10),
					PaddingRight = UDim.new(0, 10),
				}, {}),

				Text = Roact.createElement("TextLabel", {
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,

					Text = "Lets start by getting to the mine, click the blue up arrow button highlighted in the bottom left!",
					TextScaled = true,
					RichText = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					FontFace = Theme.Font,
					TextColor3 = Theme.TextColor,
				}, {
					TextSize = Roact.createElement("UITextSizeConstraint", {
						MinTextSize = 16,
						MaxTextSize = 30,
					}, {}),
				}),
			}),
		}),
	})
end

return Stage1
