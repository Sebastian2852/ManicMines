local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)

local StorageService

local Storage = Roact.Component:extend("Storage")

local InventorySide = require(ReplicatedStorage.Game.GUI.Storage.Inventory)
local StorageSide = require(ReplicatedStorage.Game.GUI.Storage.Storage)
local Theme = require(ReplicatedStorage.Game.GUI.Theme)

function Storage:init()
	StorageService = Knit.GetService("StorageService")
end

function Storage:render()
	return Roact.createElement("ScreenGui", {
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, {
		App = Roact.createElement("Frame", {
			Size = UDim2.fromScale(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 0.5,
			BackgroundColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,
		}, {
			Padding = Roact.createElement("UIPadding", {
				PaddingTop = UDim.new(0, 10),
				PaddingBottom = UDim.new(0, 10),
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
			}, {}),

			Content = Roact.createElement("Frame", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
			}, {
				Left = Roact.createElement("Frame", {
					Size = UDim2.fromScale(0.5, 0.9),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
				}, {
					App = Roact.createElement(InventorySide, {}, {}),
				}),

				Right = Roact.createElement("Frame", {
					Size = UDim2.fromScale(0.5, 0.9),
					Position = UDim2.fromScale(1, 0),
					AnchorPoint = Vector2.new(1, 0),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
				}, {
					App = Roact.createElement(StorageSide, {}, {}),
				}),

				Bottom = Roact.createElement("Frame", {
					Size = UDim2.fromScale(1, 0.1),
					Position = UDim2.fromScale(0.5, 1),
					AnchorPoint = Vector2.new(0.5, 1),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
				}, {
					DepositButton = Roact.createElement("TextButton", {
						Size = UDim2.fromScale(0.3, 0.9),
						Position = UDim2.fromScale(0, 0.5),
						AnchorPoint = Vector2.new(0, 0.5),
						BackgroundColor3 = Theme.BackgroundColorGreen,
						BorderSizePixel = 0,

						Text = "Deposit All",
						TextScaled = true,
						TextColor3 = Theme.TextColorDisabled,
						FontFace = Theme.Font,

						[Roact.Event.MouseButton1Click] = function()
							StorageService:MoveAllToStorage()
						end,
					}, {}),

					WithdrawalAll = Roact.createElement("TextButton", {
						Size = UDim2.fromScale(0.3, 0.9),
						Position = UDim2.fromScale(1, 0.5),
						AnchorPoint = Vector2.new(1, 0.5),
						BackgroundColor3 = Theme.BackgroundColorRed,
						BorderSizePixel = 0,

						Text = "Withdrawal All",
						TextScaled = true,
						TextColor3 = Theme.TextColor,
						FontFace = Theme.Font,

						[Roact.Event.MouseButton1Click] = function()
							StorageService:MoveAllToInventory()
						end,
					}, {}),
				}),
			}),
		}),
	})
end

return Storage
