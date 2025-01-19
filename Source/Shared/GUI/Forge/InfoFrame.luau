-- # selene: allow(mixed_table)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Roact = require(ReplicatedStorage.Packages.Roact)

local InfoFrame = Roact.Component:extend("InfoFrame")

local IconLabel = require(ReplicatedStorage.Game.GUI.Common.IconLabel)
local Theme = require(script.Parent.Parent.Theme)

function InfoFrame:CreateIconLabel(Text: string, IconImage: string, LayoutOrder: number)
	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 0.3),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		App = Roact.createElement(IconLabel, {
			LayoutOrder = LayoutOrder,
			Image = IconImage,
			Text = Text,
		}, {}),
	})
end

function InfoFrame:CreateCostsFragment(Costs: Core.OreList)
	local Elements = {}

	for _, v: Core.OreListItem in pairs(Costs:LoopList()) do
		Elements[v.Name] = self:CreateIconLabel(v.DisplayName .. ": " .. v.Amount, v.Emblem, v.Amount)
	end

	return Roact.createFragment(Elements)
end

function InfoFrame:render()
	local Power = self.props.Power or "[UNKNOWN]"
	local Range = self.props.Range or "[UNKNOWN]"
	local Delay = self.props.Delay or "[UNKNOWN]"
	local PickaxeName = self.props.Name or "[UNKNOWN]"

	local Costs = self.props.Costs or Core.OreList.New()

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

				Text = PickaxeName,
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

					Power = self:CreateIconLabel(Power, Theme.Images.Power, 1),
					Range = self:CreateIconLabel(Range, Theme.Images.Range, 1),
					Delay = self:CreateIconLabel(Delay, Theme.Images.Delay, 1),
				}),
			}),

			Costs = Roact.createElement("Frame", {
				Size = UDim2.fromScale(1, 0.3),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				LayoutOrder = 3,
			}, {
				Title = Roact.createElement("TextLabel", {
					Size = UDim2.fromScale(1, 0.2),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,

					Text = "Costs",
					TextScaled = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextColor3 = Theme.TextColor,
					FontFace = Theme.Font,
				}, {}),

				Costs = Roact.createElement("ScrollingFrame", {
					Size = UDim2.fromScale(1, 0.8),
					Position = UDim2.fromScale(0, 0.2),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,

					CanvasSize = UDim2.fromScale(1, 1),
					AutomaticCanvasSize = Enum.AutomaticSize.Y,
					ScrollBarThickness = 5,
					ScrollBarImageColor3 = Color3.new(1, 1, 1),
					VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right,
					VerticalScrollBarInset = Enum.ScrollBarInset.Always,
					ScrollingDirection = Enum.ScrollingDirection.Y,
				}, {
					Layout = Roact.createElement("UIListLayout", {
						SortOrder = Enum.SortOrder.LayoutOrder,
						FillDirection = Enum.FillDirection.Vertical,
						VerticalAlignment = Enum.VerticalAlignment.Top,
					}, {}),

					self:CreateCostsFragment(Costs),
				}),
			}),
		}),
	})
end

return InfoFrame
