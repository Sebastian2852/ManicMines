local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)

local Currency = Roact.Component:extend("Currency")

local Theme = require(script.Parent.Parent.Parent.Theme)

function Currency:init()
	local DataService = Knit.GetService("DataService")

	local CurrencyName = self.props.Currency :: string

	DataService:GetPlayerDataFolder():andThen(function(DataFolder: Core.DataFolder)
		local Value = DataFolder:FindFirstChild(CurrencyName)

		if not Value then
			self:setState({
				Amount = -1,
			})
			return
		end

		Value:GetPropertyChangedSignal("Value"):Connect(function()
			self:setState({
				Amount = Value.Value,
			})
		end)

		self:setState({
			Amount = Value.Value,
		})
	end)
end

function Currency:render()
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

return Currency
