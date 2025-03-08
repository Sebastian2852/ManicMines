local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)
local Trove = require(ReplicatedStorage.Packages.trove)

local MysteryMerchantService
local ClientDataController

local MysteryMerchant = Roact.Component:extend("MysteryMerchant")

local Theme = require(ReplicatedStorage.Game.GUI.Theme)
local TradeFrame = require(ReplicatedStorage.Game.GUI.MysteryMerchant.TradeFrame)

local function BuyOreFrame(OreName: string, Price: number)
	local RealOre = ReplicatedStorage.Assets.Ores:FindFirstChild(OreName)
	local DisplayName = RealOre:GetAttribute("DisplayName")
	local Gradient = RealOre:GetAttribute("InventoryBackgroundColor")
	local Emblem = RealOre:GetAttribute("EmblemImageID")

	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 0.2),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		App = Roact.createElement(TradeFrame, {
			CostOreName = "Gold Coins",
			CostOreEmblem = Theme.Images.Gold,
			CostOreAmount = Price,

			SellOreName = DisplayName,
			SellOreEmblem = Emblem,
			SellOreAmount = 1,

			CanDoTrade = ClientDataController:GetOresAmount("GoldCoins") >= Price,
			Gradient = Gradient,
		}, {}),
	})
end

local function SellOreFrame(OreName: string, Price: number)
	local RealOre = ReplicatedStorage.Assets.Ores:FindFirstChild(OreName)
	local DisplayName = RealOre:GetAttribute("DisplayName")
	local Gradient = RealOre:GetAttribute("InventoryBackgroundColor")
	local Emblem = RealOre:GetAttribute("EmblemImageID")

	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 0.2),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		App = Roact.createElement(TradeFrame, {
			SellOreName = "Gold Coins",
			SellOreEmblem = Theme.Images.Gold,
			SellOreAmount = Price,

			CostOreName = DisplayName,
			CostOreEmblem = Emblem,
			CostOreAmount = 1,

			CanDoTrade = ClientDataController:GetOresAmount(OreName) >= Price,
			Gradient = Gradient,
		}, {}),
	})
end

function MysteryMerchant:init()
	MysteryMerchantService = Knit.GetService("MysteryMerchantService")
	ClientDataController = Knit.GetController("ClientDataController")
	self.Trove = Trove.new()
end

function MysteryMerchant:didMount()
	local GetPromise = MysteryMerchantService:GetTrades():andThen(function(Trades: { ["Buy"]: {}, ["Sell"]: {} })
		local Elements = {}
		for OreName, Price in pairs(Trades["Sell"]) do
			Elements[OreName] = BuyOreFrame(OreName, Price)
		end
		for OreName, Price in pairs(Trades["Buy"]) do
			Elements[OreName] = SellOreFrame(OreName, Price)
		end

		self:setState({
			TradeFrames = Elements,
		})
	end)

	self.Trove:AddPromise(GetPromise)
end

function MysteryMerchant:willUnmount()
	self.Trove:Clean()
end

function MysteryMerchant:render()
	local TradeFrames = self.state.TradeFrames or {}
	TradeFrames["Layout"] = Roact.createElement("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Padding = UDim.new(0, 10),
	}, {})

	return Roact.createElement("ScreenGui", {
		ResetOnSpawn = false,
	}, {
		App = Roact.createElement("Frame", {
			Size = UDim2.fromScale(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Theme.BackgroundColor,
			BackgroundTransparency = 0.5,
			BorderSizePixel = 0,
		}, {
			Padding = Roact.createElement("UIPadding", {
				PaddingTop = UDim.new(0, 10),
				PaddingBottom = UDim.new(0, 10),
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
			}, {}),

			Title = Roact.createElement("TextLabel", {
				Size = UDim2.fromScale(1, 0.1),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,

				Text = "Mystery Merchant",
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				FontFace = Theme.Font,
				TextColor3 = Theme.TextColor,
			}, {}),

			Content = Roact.createElement("Frame", {
				Size = UDim2.fromScale(1, 0.9),
				Position = UDim2.fromScale(0, 0.1),
				BackgroundColor3 = Theme.BackgroundColor,
				BackgroundTransparency = 0.75,
				BorderSizePixel = 0,
			}, {
				Corners = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0, 7),
				}, {}),

				Scroller = Roact.createElement("ScrollingFrame", {
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,

					AutomaticCanvasSize = Enum.AutomaticSize.Y,
					CanvasSize = UDim2.fromScale(1, 2),
					ScrollBarThickness = 5,
					VerticalScrollBarInset = Enum.ScrollBarInset.None,
					ScrollingDirection = Enum.ScrollingDirection.Y,
				}, TradeFrames),
			}),
		}),
	})
end

return MysteryMerchant
