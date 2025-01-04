local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Enums = require(ReplicatedStorage.Game.Modules.Enums)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)

local CreateBasicListLayout = require(ReplicatedStorage.Game.GUI.Elements.BasicListLayout)
local CreateOreFrame = require(ReplicatedStorage.Game.GUI.Components.Storage.StorageOreFrame)
local CreateRoundedCorners = require(ReplicatedStorage.Game.GUI.Elements.Corners)

local StorageController = Knit.CreateController { Name = "StorageController" }

local TycoonUpgradeService
local DataService
local StorageService
local LogService

local DataFolder: Core.DataFolder

-- [[ PRIVATE ]] --

local function CreateOreFramesForOreList(OreList: Core.OreList, Type: Enums.Enum)
	local Frames = {}
	for OreName, OreData: Core.OreListItem in pairs(OreList:LoopList()) do
		if OreName == "GoldCoins" then
			continue
		end
		Frames[OreName] = CreateOreFrame(Type, OreName, OreData.Amount)
	end
	return Frames
end

local function GetInventoryAsOreList(): Core.OreList
	local OreList = Core.OreList.CreateFromFolder(DataFolder.Inventory.Ores)
	return OreList
end

local function GetStorageAsOreList(): Core.OreList
	local OreList = Core.OreList.CreateFromFolder(DataFolder.Storage.Ores)
	return OreList
end

-- [[ GUI ]] --

local StorageComponent = Roact.Component:extend("StorageComponent")

function StorageComponent:init()
	self:setState {
		Enabled = true,
	}

	TycoonUpgradeService.OpenStorage:Connect(function()
		self:setState {
			Enabled = true,
		}
	end)

	StorageService.OpenStorage:Connect(function()
		self:setState {
			Enabled = true,
		}
	end)

	StorageService.Update:Connect(function()
		self:setState(function(Props)
			return {
				ReRender = (not Props.ReRender) or false,
			}
		end)
	end)
end

function StorageComponent:render()
	LogService:Log("Rendering storage component")
	local InventoryFrames = CreateOreFramesForOreList(GetInventoryAsOreList(), Enums.StorageOreFrameType.Inventory) -- Core.UI:CreateOreFrames(GetInventoryAsOreList(), Enums.OreFrameStyle.Normal, UDim2.fromScale(1, 0.05))
	InventoryFrames["Layout"] = CreateBasicListLayout(Enums.UiListType.ByName)

	local StorageFrames = CreateOreFramesForOreList(GetStorageAsOreList(), Enums.StorageOreFrameType.Storage) -- Core.UI:CreateOreFrames(GetStorageAsOreList(), Enums.OreFrameStyle.Normal, UDim2.fromScale(1, 0.05))
	StorageFrames["Layout"] = CreateBasicListLayout(Enums.UiListType.ByName)

	return Roact.createElement("ScreenGui", {
		ResetOnSpawn = false,
	}, {
		Main = self.state.Enabled and Roact.createElement("Frame", {
			Size = UDim2.fromScale(0.5, 0.5),
			Position = Core.UI.Position.Center,
			AnchorPoint = Core.UI.AnchorPoint.Center,
			BackgroundColor3 = Core.UI.Theme.BackgroundColorPrimary,
			BorderSizePixel = 0,
		}, {
			Title = Roact.createElement("TextLabel", {
				Size = UDim2.fromScale(1, 0.1),
				AnchorPoint = Core.UI.AnchorPoint.TopCenter,
				Position = Core.UI.Position.TopCenter,

				Text = "Storage",
				TextScaled = true,
				BackgroundTransparency = 1,
				FontFace = Core.UI.Theme.TextFont,
				TextColor3 = Core.UI.Theme.TextColor3,
			}, {}),

			CloseButton = Roact.createElement("TextButton", {
				Size = UDim2.fromScale(0.138, 0.06),
				Position = UDim2.fromScale(0, -0.07),
				BackgroundColor3 = Core.UI.Theme.CloseButtonColor,
				BorderSizePixel = 0,
				Modal = true,

				Text = "Close",
				TextScaled = true,
				TextColor3 = Core.UI.Color.White,
				FontFace = Core.UI.Theme.TextFont,

				[Roact.Event.MouseButton1Click] = function()
					self:setState {
						Enabled = false,
					}
				end,
			}, {
				Corners = CreateRoundedCorners(0.2),
			}),

			Main = Roact.createElement("Frame", {
				Size = UDim2.fromScale(1, 0.8),
				Position = UDim2.fromScale(0.5, 0.1),
				AnchorPoint = Core.UI.AnchorPoint.TopCenter,
				BackgroundTransparency = 1,
			}, {
				Inventory = Roact.createElement("Frame", {
					Size = UDim2.fromScale(0.5, 1),
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.fromScale(0, 0.5),
					BackgroundColor3 = Core.UI.Theme.BackgroundColorDark,
					BackgroundTransparency = 0,
				}, {
					Title = Roact.createElement("TextLabel", {
						Size = UDim2.fromScale(1, 0.1),
						AnchorPoint = Core.UI.AnchorPoint.TopCenter,
						Position = Core.UI.Position.TopCenter,

						Text = "Inventory",
						TextXAlignment = Enum.TextXAlignment.Left,
						TextScaled = true,
						BackgroundTransparency = 1,
						TextStrokeTransparency = 0,

						FontFace = Core.UI.Theme.TextFont,
						TextColor3 = Core.UI.Theme.TextColor3,
					}, {}),

					Ores = Roact.createElement("ScrollingFrame", {
						Size = UDim2.fromScale(1, 0.9),
						Position = UDim2.fromScale(0, 1),
						AnchorPoint = Core.UI.AnchorPoint.BottomLeft,

						AutomaticCanvasSize = Enum.AutomaticSize.Y,
						BackgroundTransparency = 1,
						ScrollBarImageTransparency = 1,
						BorderSizePixel = 0,
						ScrollBarThickness = 0,
						CanvasSize = UDim2.fromScale(0, 0.07),
						VerticalScrollBarInset = Enum.ScrollBarInset.None,
						VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Left,
					}, InventoryFrames),
				}),

				Storage = Roact.createElement("Frame", {
					Size = UDim2.fromScale(0.5, 1),
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.fromScale(1, 0.5),
					BackgroundColor3 = Core.UI.Theme.BackgroundColorDark,
					BackgroundTransparency = 0,
				}, {
					Title = Roact.createElement("TextLabel", {
						Size = UDim2.fromScale(1, 0.1),
						AnchorPoint = Core.UI.AnchorPoint.TopCenter,
						Position = Core.UI.Position.TopCenter,

						Text = "Storage",
						TextXAlignment = Enum.TextXAlignment.Right,
						TextScaled = true,
						BackgroundTransparency = 1,
						TextStrokeTransparency = 0,

						FontFace = Core.UI.Theme.TextFont,
						TextColor3 = Core.UI.Theme.TextColor3,
					}, {}),

					Ores = Roact.createElement("ScrollingFrame", {
						Size = UDim2.fromScale(1, 0.9),
						Position = UDim2.fromScale(0, 1),
						AnchorPoint = Core.UI.AnchorPoint.BottomLeft,
						BackgroundColor3 = Core.UI.Theme.BackgroundColorDark,

						AutomaticCanvasSize = Enum.AutomaticSize.Y,
						BackgroundTransparency = 1,
						ScrollBarImageTransparency = 1,
						BorderSizePixel = 0,
						ScrollBarThickness = 0,
						CanvasSize = UDim2.fromScale(0, 0.07),
						VerticalScrollBarInset = Enum.ScrollBarInset.None,
						VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right,
					}, StorageFrames),
				}),
			}),

			Buttons = Roact.createElement("Frame", {
				Size = UDim2.fromScale(1, 0.1),
				Position = UDim2.fromScale(0, 0.9),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
			}, {
				DepositAll = Roact.createElement("TextButton", {
					Size = UDim2.fromScale(0.2, 0.5),
					Position = UDim2.fromScale(0.15, 0.5),
					AnchorPoint = Core.UI.AnchorPoint.LeftCenter,
					BackgroundColor3 = Core.UI.Theme.OpenButtonColor,
					BorderSizePixel = 0,

					Text = "Deposit All",
					TextScaled = true,
					FontFace = Core.UI.Theme.TextFont,
					TextColor3 = Core.UI.Theme.TextColor3,

					[Roact.Event.MouseButton1Click] = function()
						StorageService:MoveAllToStorage()
					end,
				}, {
					Corners = CreateRoundedCorners(0.3),
				}),

				WithdrawalAll = Roact.createElement("TextButton", {
					Size = UDim2.fromScale(0.2, 0.5),
					Position = UDim2.fromScale(0.85, 0.5),
					AnchorPoint = Core.UI.AnchorPoint.RightCenter,
					BackgroundColor3 = Core.UI.Theme.CloseButtonColor,
					BorderSizePixel = 0,

					Text = "Withdrawal All",
					TextScaled = true,
					FontFace = Core.UI.Theme.TextFont,
					TextColor3 = Core.UI.Theme.TextColor3,

					[Roact.Event.MouseButton1Click] = function()
						StorageService:MoveAllToInventory()
					end,
				}, {
					Corners = CreateRoundedCorners(0.3),
				}),
			}),
		}),
	})
end

-- [[ KNIT ]] --

function StorageController:KnitStart()
	TycoonUpgradeService = Knit.GetService("TycoonUpgradeService")
	DataService = Knit.GetService("DataService")
	StorageService = Knit.GetService("StorageService")
	LogService = Knit.GetService("LogService")

	DataService.DataLoaded:Connect(function(Data: Core.DataFolder)
		DataFolder = Data
		local App = Roact.createElement(StorageComponent)
		Roact.mount(App, Knit.Player.PlayerGui, "Storage")
		LogService:Log("Mounted storage component")
	end)
end

return StorageController
