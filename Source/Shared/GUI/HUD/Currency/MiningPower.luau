local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)

local PickaxeService

local MiningPower = Roact.Component:extend("MiningPower")

local Theme = require(ReplicatedStorage.Game.GUI.Theme)

function MiningPower:init()
	PickaxeService = Knit.GetService("PickaxeService")

	PickaxeService:GetMiningPower():andThen(function(GetMiningPower)
		self:setState({
			Amount = GetMiningPower,
		})
	end)

	PickaxeService.UpdateMiningPower:Connect(function(GetMiningPower)
		self:setState({
			Amount = GetMiningPower,
		})
	end)
end

function MiningPower:render()
	local Image = self.props.Image or Theme.Images.Missing
	local Amount = self.state.Amount or "Unkown"

	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			Padding = UDim.new(0, 5),
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
		}, {}),

		Image = Roact.createElement("ImageLabel", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 1,

			Image = Image,
			ScaleType = Enum.ScaleType.Fit,
		}, {
			AspectRatio = Roact.createElement("UIAspectRatioConstraint", {
				AspectRatio = 1,
				AspectType = Enum.AspectType.FitWithinMaxSize,
				DominantAxis = Enum.DominantAxis.Height,
			}, {}),
		}),

		Text = Roact.createElement("TextLabel", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 2,

			Text = Amount,
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = Theme.TextColor,
			FontFace = Theme.Font,
		}, {}),
	})
end

return MiningPower
