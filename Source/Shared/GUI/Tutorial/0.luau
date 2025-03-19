local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)

local ClientDataController

local Stage0 = Roact.Component:extend("Stage0")

local Signals = require(ReplicatedStorage.Game.GUI.Signals)
local Theme = require(ReplicatedStorage.Game.GUI.Theme)

function Stage0:init()
	ClientDataController = Knit.GetController("ClientDataController")
end

function Stage0:didMount()
	Signals.ToggleHUDButtons:Fire(false)
	Signals.ToggleHotbar:Fire(false)
	Signals.ToggleHUDGold:Fire(false)
	Signals.ToggleInventory:Fire(false)
end

function Stage0:render()
	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		InfoBox = Roact.createElement("Frame", {
			Size = UDim2.fromScale(0.5, 0.3),
			Position = UDim2.new(0.5, 0, 1, -10),
			AnchorPoint = Vector2.new(0.5, 1),
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
				Size = UDim2.fromScale(1, 0.8),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				LayoutOrder = 1,
			}, {
				Text = Roact.createElement("TextLabel", {
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,

					Text = "Welcome to Manic Mines! <br /> <br/>Seems like your new around here. Would you like to complete a quick tutorial?",
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

			Buttons = Roact.createElement("Frame", {
				Size = UDim2.fromScale(1, 0.2),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				LayoutOrder = 2,
			}, {
				Layout = Roact.createElement("UIListLayout", {
					Padding = UDim.new(0, 10),
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Right,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}, {}),

				Padding = Roact.createElement("UIPadding", {
					PaddingTop = UDim.new(0, 10),
					PaddingBottom = UDim.new(0, 10),
					PaddingLeft = UDim.new(0, 10),
					PaddingRight = UDim.new(0, 10),
				}, {}),

				StartButton = Roact.createElement("TextButton", {
					Size = UDim2.fromScale(0.3, 1),
					BackgroundColor3 = Theme.BackgroundColorGreen,
					LayoutOrder = 2,

					Text = "Start Tutorial",
					TextScaled = true,
					FontFace = Theme.Font,
					TextColor3 = Theme.TextColor,
				}, {
					Corners = Roact.createElement("UICorner", {
						CornerRadius = UDim.new(0, 7),
					}, {}),
				}),

				SkipButton = Roact.createElement("TextButton", {
					Size = UDim2.fromScale(0.3, 1),
					BackgroundColor3 = Theme.BackgroundColorRed,
					LayoutOrder = 1,

					Text = "Skip",
					TextScaled = true,
					FontFace = Theme.Font,
					TextColor3 = Theme.TextColor,

					[Roact.Event.MouseButton1Click] = function()
						ClientDataController:SetTutorialStage(-2)
					end,
				}, {
					Corners = Roact.createElement("UICorner", {
						CornerRadius = UDim.new(0, 7),
					}, {}),
				}),
			}),
		}),
	})
end

return Stage0
