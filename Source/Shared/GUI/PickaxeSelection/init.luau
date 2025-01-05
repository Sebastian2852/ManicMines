local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)
local Theme = require(script.Parent.Theme)

local PickaxeSelection = Roact.Component:extend("PickaxeSelection")

local Bar = require(script.Bar)

function PickaxeSelection:init()
	local Block = self.props.Block :: BasePart

	local DisplayName = Block:GetAttribute("DisplayName")
	local Emblem = Block:GetAttribute("EmblemImageID")

	self:setState {
		DisplayName = DisplayName,
		EmblemID = Emblem,
	}
end

function PickaxeSelection:render()
	local DisplayName = self.state.DisplayName
	local EmblemID = self.state.EmblemID

	return Roact.createElement("ScreenGui", {
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, {
		Container = Roact.createElement("Frame", {
			Size = UDim2.fromScale(0.244, 0.128),
			Position = UDim2.fromScale(0.5, 0.717),
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, {
			Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Vertical,
			}, {}),

			TextArea = Roact.createElement("Frame", {
				Size = UDim2.fromScale(1, 0.5),
				LayoutOrder = 1,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
			}, {
				Layout = Roact.createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = Enum.FillDirection.Horizontal,
				}, {}),

				Image = Roact.createElement("ImageLabel", {
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					BorderSizePixel = 1,
					LayoutOrder = 1,

					Image = EmblemID,
					ScaleType = Enum.ScaleType.Fit,
				}, {
					Aspect = Roact.createElement("UIAspectRatioConstraint", {
						AspectRatio = 1,
						AspectType = Enum.AspectType.FitWithinMaxSize,
						DominantAxis = Enum.DominantAxis.Height,
					}, {}),
				}),

				Text = Roact.createElement("Frame", {
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					LayoutOrder = 2,
				}, {
					Layout = Roact.createElement("UIListLayout", {
						SortOrder = Enum.SortOrder.LayoutOrder,
						FillDirection = Enum.FillDirection.Vertical,
					}, {}),

					Pading = Roact.createElement("UIPadding", {
						PaddingLeft = UDim.new(0, 10),
					}, {}),

					DisplayName = Roact.createElement("TextLabel", {
						Size = UDim2.fromScale(1, 0.6),
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						LayoutOrder = 1,

						Text = DisplayName,
						TextScaled = true,
						TextColor3 = Theme.TextColor,
						FontFace = Theme.Font,
						TextStrokeTransparency = 0,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Bottom,
					}, {}),

					TimeToMine = Roact.createElement("TextLabel", {
						Size = UDim2.fromScale(1, 0.4),
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						LayoutOrder = 2,

						Text = "XX% • xx.xxS",
						TextScaled = true,
						TextColor3 = Theme.TextColor,
						FontFace = Theme.Font,
						TextStrokeTransparency = 0,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextYAlignment = Enum.TextYAlignment.Top,
					}, {}),
				}),
			}),

			BarArea = Roact.createElement("Frame", {
				Size = UDim2.fromScale(1, 0.5),
				LayoutOrder = 2,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
			}, {
				Container = Roact.createElement("Frame", {
					Size = UDim2.fromScale(1, 0.35),
					Position = UDim2.fromScale(0.5, 0.3),
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
				}, {
					Bar = Roact.createElement(Bar, {}, {}),
				}),
			}),
		}),
	})
end

return PickaxeSelection
