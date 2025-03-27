local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enums = require(ReplicatedStorage.Game.Modules.Enums)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)

local ClientDataController

local Stage9 = Roact.Component:extend("Stage9")

local FloatingInfo = require(ReplicatedStorage.Game.GUI.Common.FloatingInfo)
local Signals = require(ReplicatedStorage.Game.GUI.Signals)
local Theme = require(ReplicatedStorage.Game.GUI.Theme)

local function CreateRightInfo(Top: string, Bottom: string, Position: UDim2, AnchorPoint: Vector2)
	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(0.2, 0.2),
		Position = Position,
		AnchorPoint = AnchorPoint,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		App = Roact.createElement(FloatingInfo, {
			TopText = Top,
			BottomText = Bottom,
			Direction = Enums.FloatingInfoDirection.Right,
		}, {}),
	})
end

function Stage9:init()
	ClientDataController = Knit.GetController("ClientDataController")
end

function Stage9:didMount()
	Signals.ToggleHUDButtons:Fire(false)
	Signals.ToggleHUDGold:Fire(true)
	Signals.ToggleInventory:Fire(false)
end

function Stage9:render()
	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		TurningPoint = CreateRightInfo(
			"Turning Point",
			"How far you can mine before blocks get harder to mine",
			UDim2.fromScale(-0.05, 0.76),
			Vector2.new(0, 1)
		),

		MiningPower = CreateRightInfo(
			"Mining Power",
			"How powerful your pickaxe actually is based on a number of factors",
			UDim2.fromScale(0.025, 0.6),
			Vector2.new(0, 1)
		),

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

					Text = "On the left below the gold is your mining power and turning point.<br /><br />- Your mining power is how powerful your pickaxe actually is based on range, power, delay and Research & Development upgrade level <br />- Your tunring point is how deep you can mine before blocks take longer to mine than usual, it is based on your Data & Analysis upgrade level",
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

					Text = "Finish Tutorial ...",
					TextScaled = true,
					FontFace = Theme.Font,
					TextColor3 = Theme.TextColor,

					[Roact.Event.MouseButton1Click] = function()
						ClientDataController:SetTutorialStage(-1)
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

return Stage9
