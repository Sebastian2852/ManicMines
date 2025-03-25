local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)

local Stage6 = Roact.Component:extend("Stage6")

local Signals = require(ReplicatedStorage.Game.GUI.Signals)
local Theme = require(ReplicatedStorage.Game.GUI.Theme)

function Stage6:didMount()
	Signals.ToggleHUDButtons:Fire(true)
	Signals.ToggleHUDGold:Fire(false)
	Signals.ToggleInventory:Fire(false)
end

function Stage6:render()
	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		InfoBox = Roact.createElement("Frame", {
			Size = UDim2.fromScale(0.5, 0.3),
			Position = UDim2.new(0.5, 0, 0.1, 0),
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = Theme.BackgroundColor,
			BackgroundTransparency = 0.5,
			BorderSizePixel = 0,
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

					Text = "There is also an XP generator in your tycoon that depends on the Research & Development upgrade. <br /><br />Mining operations also allows you to unlock new pickaxes to buy. Lets have a look at the forge to buy a new pickaxe! <br/><br /><b>Teleport to mine to continue!</b>",
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

return Stage6
