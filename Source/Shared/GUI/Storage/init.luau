local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)

local StorageService

local Storage = Roact.Component:extend("Storage")

local CloseButton = require(ReplicatedStorage.Game.GUI.Common.CloseButton)
local Global = require(ReplicatedStorage.Game.GUI.Global)
local InventorySide = require(ReplicatedStorage.Game.GUI.Storage.Inventory)
local StorageSide = require(ReplicatedStorage.Game.GUI.Storage.Storage)
local Theme = require(ReplicatedStorage.Game.GUI.Theme)

function Storage:init()
	StorageService = Knit.GetService("StorageService")
	Global.init(self)
end

function Storage:didMount()
	Global.didMount(self)
end

function Storage:willUnmount()
	Global.willUnmount(self)
end

function Storage:render()
	local Close = self.props.Close or function()
		warn("Missing Close function")
	end

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
			Close = Roact.createElement(CloseButton, {
				Size = UDim2.fromScale(1, 0.08),
				OnClick = Close,
			}, {}),

			Title = Roact.createElement("TextLabel", {
				Size = UDim2.fromScale(0.5, 0.1),
				Position = UDim2.fromOffset(10, 3),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,

				Text = "<u>Storage</u>",
				TextScaled = true,
				RichText = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				FontFace = Theme.Font,
				TextColor3 = Theme.TextColor,
			}, {}),

			Main = Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 0.9, 10),
				Position = UDim2.fromScale(0.5, 1),
				AnchorPoint = Vector2.new(0.5, 1),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
			}, {
				Padding = Roact.createElement("UIPadding", {
					PaddingTop = UDim.new(0, 10),
					PaddingBottom = UDim.new(0, 10),
					PaddingLeft = UDim.new(0, 10),
					PaddingRight = UDim.new(0, 10),
				}, {}),

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
					}, {
						Corners = Roact.createElement("UICorner", {
							CornerRadius = UDim.new(0, 7),
						}, {}),
					}),

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
					}, {
						Corners = Roact.createElement("UICorner", {
							CornerRadius = UDim.new(0, 7),
						}, {}),
					}),
				}),
			}),
		}),
	})
end

return Storage
