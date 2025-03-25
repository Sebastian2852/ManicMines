local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)

local ClientDataController

local Stage5 = Roact.Component:extend("Stage5")

local Signals = require(ReplicatedStorage.Game.GUI.Signals)
local Theme = require(ReplicatedStorage.Game.GUI.Theme)

function Stage5:init()
	ClientDataController = Knit.GetController("ClientDataController")
end

function Stage5:didMount()
	Signals.ToggleHUDButtons:Fire(false)
	Signals.ToggleHUDGold:Fire(true)
	Signals.ToggleInventory:Fire(false)
end

function Stage5:render()
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
				Size = UDim2.fromScale(1, 0.85),
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

					Text = "On the left of your screen is you gold. You can earn gold through your Gold Generator in your tycoon. <br /><br /><b><u>Tycoon Generators</u></b><br />Tycoon generators generate gold, xp, etc while you play. They are dependant on a single upgrade and generate faster the higher level that upgrade is. <br /> <br />The gold generator depends on your mining operations, once you upgrade it to level 1 it will start generating gold for you.",
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
				Size = UDim2.fromScale(1, 0.15),
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
					BackgroundTransparency = 1,

					Text = "Continue ...",
					TextScaled = true,
					FontFace = Theme.Font,
					TextColor3 = Theme.TextColor,

					[Roact.Event.MouseButton1Click] = function()
						ClientDataController:AdvanceTutorialStage()
					end,
				}, {
					Corners = Roact.createElement("UICorner", {
						CornerRadius = UDim.new(0, 7),
					}, {}),
				}),
			}, {
				Corners = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0, 7),
				}, {}),
			}),
		}),
	})
end

return Stage5
