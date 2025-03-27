local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)

local Stage8 = Roact.Component:extend("Stage8")

local Signals = require(ReplicatedStorage.Game.GUI.Signals)
local Theme = require(ReplicatedStorage.Game.GUI.Theme)

function Stage8:didMount()
	Signals.ToggleHUDButtons:Fire(true)
	Signals.ToggleHUDGold:Fire(false)
	Signals.ToggleInventory:Fire(false)
end

function Stage8:render()
	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		InfoBox = Roact.createElement("Frame", {
			Size = UDim2.fromScale(0.5, 0.3),
			Position = UDim2.new(0.5, 0, 0.2, 0),
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

					Text = "This is the forge. Here you can buy and equip pickaxes. Pickaxes require you Mining Operations upgrade to be at a certain level. <br /><br />A pickaxe which is fully colored is unlocked and bought. <br />A pickaxe which is grayed out but you can see the name and icon is unlocked but not bought yet <br />A pickaxe which is grayed out and the name and icon hidden is a pickaxe you have not unlocked yet. <br /><br /><b>Close the forge to continue</b>",
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

return Stage8
