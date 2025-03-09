local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)

local MysteryMerchantService

local TradeFrame = Roact.Component:extend("TradeFrame")

local Theme = require(ReplicatedStorage.Game.GUI.Theme)

local function OreSideFrame(
	Emblem: string,
	Name: string,
	Amount: number,
	Alignment: Enum.TextXAlignment,
	CanDoTrade: boolean
)
	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(0.3, 1),
		LayoutOrder = Alignment == Enum.TextXAlignment.Left and 1 or 3,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		Top = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, {
			Layout = Roact.createElement("UIListLayout", {
				Padding = UDim.new(0, 10),
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
				HorizontalAlignment = Alignment == Enum.TextXAlignment.Left and Enum.HorizontalAlignment.Left
					or Enum.HorizontalAlignment.Right,
			}, {}),

			Emblem = Roact.createElement("ImageLabel", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				LayoutOrder = Alignment == Enum.TextXAlignment.Left and 1 or 2,

				Image = Emblem,
				ScaleType = Enum.ScaleType.Crop,
			}, {
				AspectRatio = Roact.createElement("UIAspectRatioConstraint", {
					AspectRatio = 1,
					AspectType = Enum.AspectType.FitWithinMaxSize,
					DominantAxis = Enum.DominantAxis.Height,
				}, {}),
			}),

			OreName = Roact.createElement("TextLabel", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				LayoutOrder = Alignment == Enum.TextXAlignment.Right and 1 or 2,

				Text = Name,
				TextScaled = true,
				TextXAlignment = Alignment,
				FontFace = Theme.Font,
				TextColor3 = CanDoTrade and Theme.TextColor or Theme.BackgroundColorRed,
			}, {}),
		}),

		Bottom = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 0.5),
			Position = UDim2.fromScale(0, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, {
			Amount = Roact.createElement("TextLabel", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,

				Text = Amount,
				TextScaled = true,
				TextXAlignment = Alignment,
				FontFace = Theme.Font,
				TextColor3 = CanDoTrade and Theme.TextColor or Theme.BackgroundColorRed,
			}, {}),
		}),
	})
end

function TradeFrame:init()
	MysteryMerchantService = Knit.GetService("MysteryMerchantService")
end

function TradeFrame:render()
	local CostOreName = self.props.CostOreName or "[UNKNOWN]"
	local CostOreEmblem = self.props.CostOreEmblem or Theme.Images.Missing
	local CostOreAmount = self.props.CostOreAmount

	local SellOreName = self.props.SellOreName or "[UNKNOWN]"
	local SellOreEmblem = self.props.SellOreEmblem or Theme.Images.Missing
	local SellOreAmount = self.props.SellOreAmount
	local CanDoTrade = self.props.CanDoTrade or false

	local TradeID = self.props.TradeID
	local TradeType = self.props.TradeType
	local RefreshSignal = self.props.RefreshSignal

	local Gradient = self.props.Gradient or ColorSequence.new(Color3.new(1, 0, 1))

	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 0.75,
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalFlex = Enum.UIFlexAlignment.SpaceEvenly,
		}, {}),

		Gradient = Roact.createElement("UIGradient", {
			Color = Gradient,
		}, {}),

		Corners = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 5),
		}, {}),

		CostOre = OreSideFrame(CostOreEmblem, CostOreName, CostOreAmount, Enum.TextXAlignment.Left, CanDoTrade),
		SelLore = OreSideFrame(SellOreEmblem, SellOreName, SellOreAmount, Enum.TextXAlignment.Right, true),

		Arrow = Roact.createElement("Frame", {
			Size = UDim2.fromScale(0.1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 2,
		}, {
			Image = Roact.createElement("ImageLabel", {
				Size = UDim2.new(1, 0, 0.7, -10),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Rotation = 90,

				Image = Theme.Images.UpArrow,
				ScaleType = Enum.ScaleType.Fit,
			}, {}),

			Action = Roact.createElement("TextButton", {
				Size = UDim2.fromScale(1, 0.3),
				Position = UDim2.fromScale(0, 1),
				AnchorPoint = Vector2.new(0, 1),
				BackgroundTransparency = 0.5,
				BackgroundColor3 = CanDoTrade and Theme.BackgroundColorGreen or Theme.BackgroundColorRed,
				BorderSizePixel = 0,

				Text = "Trade",
				TextScaled = true,
				FontFace = Theme.Font,
				TextColor3 = CanDoTrade and Theme.TextColor or Theme.TextDisabledColor,
				Interactable = CanDoTrade,

				[Roact.Event.MouseButton1Click] = function()
					if TradeType == "Buy" then
						MysteryMerchantService:BuyTrade(TradeID)
					elseif TradeType == "Sell" then
						MysteryMerchantService:SellTrade(TradeID)
					end
					RefreshSignal:Fire()
				end,
			}, {
				Corners = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0, 10),
				}, {}),
			}),
		}),
	})
end

return TradeFrame
