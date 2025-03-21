local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enums = require(ReplicatedStorage.Game.Modules.Enums)
local Roact = require(ReplicatedStorage.Packages.Roact)

local Stage3 = Roact.Component:extend("Stage0")

local FloatingInfo = require(ReplicatedStorage.Game.GUI.Common.FloatingInfo)
local Signals = require(ReplicatedStorage.Game.GUI.Signals)
local Theme = require(ReplicatedStorage.Game.GUI.Theme)

local function CreateLeftInfo(Top: string, Bottom: string, Position: UDim2, AnchorPoint: Vector2)
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
			Direction = Enums.FloatingInfoDirection.Left,
		}, {}),
	})
end

-- local function CreateRightInfo(Top: string, Bottom: string, Position: UDim2, AnchorPoint: Vector2)
-- 	return Roact.createElement("Frame", {
-- 		Size = UDim2.fromScale(0.2, 0.2),
-- 		Position = Position,
-- 		AnchorPoint = AnchorPoint,
-- 		BackgroundTransparency = 1,
-- 		BorderSizePixel = 0,
-- 	}, {
-- 		App = Roact.createElement(FloatingInfo, {
-- 			TopText = Top,
-- 			BottomText = Bottom,
-- 			Direction = Enums.FloatingInfoDirection.Right,
-- 		}, {}),
-- 	})
-- end

function Stage3:didMount()
	Signals.ToggleHUDButtons:Fire(true)
	Signals.ToggleHUDGold:Fire(false)
	Signals.ToggleInventory:Fire(true)
end

function Stage3:render()
	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		InventoryLabel = CreateLeftInfo(
			"Inventory",
			"Displays ores you have on you",
			UDim2.fromScale(0.86, 0.57),
			Vector2.new(1, 1)
		),

		LevelLabel = CreateLeftInfo(
			"Level",
			"Shows your level, XP and progress to next level",
			UDim2.fromScale(0.95, 0.46),
			Vector2.new(1, 1)
		),

		CapLabel = CreateLeftInfo(
			"Capacity",
			"Shows the max ores you can carry on you",
			UDim2.fromScale(0.8, 0.95),
			Vector2.new(1, 1)
		),

		InfoBox = Roact.createElement("Frame", {
			Size = UDim2.fromScale(0.5, 0.3),
			Position = UDim2.new(0, 10, 0.9, 0),
			AnchorPoint = Vector2.new(0, 1),
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

					Text = "Great job mining your first block! Now, let's get familiar with your inventory.<br /><br /><u>Your Inventory</u><br />- View Your Items: Check out what you've collected in your inventory.<br />- Capacity: You can carry up to seven items at a time.<br /><br /><u>Level & XP</u><br />- Track Progress: Your current level and XP are displayed above the inventory. Keep mining to level up!<br /><br /><u>Upgrading Your Tycoon</u><br />Your tycoon has many upgradable elements to help you while mining. <br /><br /><b>Press the green button to get started with upgrading your tycoon!</b>",
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

return Stage3
