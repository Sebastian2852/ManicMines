local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)

local InfoFrame = Roact.Component:extend("InfoFrame")

local StatFrame = require(script.StatFrame)
local Theme = require(script.Parent.Parent.Theme)

function InfoFrame:CreateStatFrame(Text: string, IconImage: string, LayoutOrder: number)
	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 0.3),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		App = Roact.createElement(StatFrame, {
			LayoutOrder = LayoutOrder,
			Image = IconImage,
			Text = Text,
		}, {}),
	})
end

function InfoFrame:render()
	local Power = self.props.Power or "[UNKOWN]"
	local Range = self.props.Range or "[UNKOWN]"
	local Delay = self.props.Delay or "[UNKOWN]"

	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		Background = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 0.5,
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			ZIndex = 1,
		}, {
			Corners = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 7),
			}, {}),
		}),

		Content = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = 2,
		}, {
			Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalFlex = Enum.UIFlexAlignment.Fill,
			}, {}),

			Title = Roact.createElement("TextLabel", {
				Size = UDim2.fromScale(1, 0.1),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				LayoutOrder = 1,

				Text = "[PICKAXE NAME]",
				TextScaled = true,
				TextColor3 = Theme.TextColor,
				FontFace = Theme.Font,
			}, {}),

			Stats = Roact.createElement("Frame", {
				Size = UDim2.fromScale(1, 0.3),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				LayoutOrder = 2,
			}, {
				Title = Roact.createElement("TextLabel", {
					Size = UDim2.fromScale(1, 0.2),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,

					Text = "Stats",
					TextScaled = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextColor3 = Theme.TextColor,
					FontFace = Theme.Font,
				}, {}),

				Stats = Roact.createElement("Frame", {
					Size = UDim2.fromScale(1, 0.8),
					Position = UDim2.fromScale(0, 0.2),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
				}, {
					Layout = Roact.createElement("UIListLayout", {
						SortOrder = Enum.SortOrder.LayoutOrder,
						FillDirection = Enum.FillDirection.Vertical,
						VerticalAlignment = Enum.VerticalAlignment.Center,
					}, {}),

					Power = self:CreateStatFrame(Power, Theme.Images.Power, 1),
					Range = self:CreateStatFrame(Range, Theme.Images.Range, 1),
					Delay = self:CreateStatFrame(Delay, Theme.Images.Delay, 1),
				}),
			}),
		}),
	})
end

return InfoFrame
