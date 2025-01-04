local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)

local UnUsedSlotFrame = Roact.Component:extend("UnUsedSlotFrame")

local SlotButton = require(script.Parent.SlotButton)
local Theme = require(script.Parent.Parent.Parent.Theme)

function UnUsedSlotFrame:render()
	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 0.3),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		Content = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, {
			Layout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}, {}),

			Left = Roact.createElement("Frame", {
				Size = UDim2.fromScale(0.5, 1),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				LayoutOrder = 1,
			}, {
				Layout = Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}, {}),

				SlotName = Roact.createElement("Frame", {
					Size = UDim2.fromScale(1, 0.5),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					LayoutOrder = 1,
				}, {
					Text = Roact.createElement("TextLabel", {
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 1,
						BorderSizePixel = 0,

						Text = "Unused Slot",
						TextScaled = true,
						TextXAlignment = Enum.TextXAlignment.Center,
						TextYAlignment = Enum.TextYAlignment.Bottom,
						TextColor3 = Theme.TextColor,
						FontFace = Theme.Font,
					}, {}),
				}),

				Buttons = Roact.createElement("Frame", {
					Size = UDim2.fromScale(1, 0.5),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.fromScale(0, 0.5),
					LayoutOrder = 2,
				}, {
					Layout = Roact.createElement("UIListLayout", {
						Padding = UDim.new(0, 10),
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						SortOrder = Enum.SortOrder.LayoutOrder,
					}, {}),

					Create = Roact.createElement(SlotButton, {
						Text = "Create",
						Color = Theme.BackgroundColorGreen,
						LayoutOrder = 1,
						OnClick = function()
							self.props.OnCreate()
						end,
					}, {}),
				}),
			}),
		}),
	})
end

return UnUsedSlotFrame
