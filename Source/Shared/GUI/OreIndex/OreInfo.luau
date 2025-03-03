local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)

local OreInfo = Roact.PureComponent:extend("OreInfo")

local Theme = require(ReplicatedStorage.Game.GUI.Theme)

function OreInfo:render()
	local Block = self.props.Block
	if Block == nil then
		return
	end

	local DisplayName = Block:GetAttribute("DisplayName")
	local DepthRange: NumberRange = Block:GetAttribute("SpawningRange")
	local XpWhenMined = Block:GetAttribute("XP")
	local AmountDroppedWhenMined = Block:GetAttribute("AmountDroppedWhenMined")

	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, {}),

		Padding = Roact.createElement("UIPadding", {
			PaddingTop = UDim.new(0, 10),
			PaddingBottom = UDim.new(0, 10),
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
		}, {}),

		OreHeader = Roact.createElement("TextLabel", {
			Size = UDim2.fromScale(1, 0.15),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 1,

			Text = DisplayName,
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = Theme.TextColor,
			FontFace = Theme.Font,
		}, {}),

		OreInfo = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 0.25),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 2,
		}, {
			Layout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}, {}),

			Depth = Roact.createElement("TextLabel", {
				Size = UDim2.fromScale(1, 0.3),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				LayoutOrder = 1,

				Text = `Depth: {DepthRange.Min}m - {DepthRange.Max}m`,
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = Theme.TextColor,
				FontFace = Theme.Font,
			}, {}),

			XP = Roact.createElement("TextLabel", {
				Size = UDim2.fromScale(1, 0.3),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				LayoutOrder = 1,

				Text = `XP when mined: {XpWhenMined} XP`,
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = Theme.TextColor,
				FontFace = Theme.Font,
			}, {}),

			Amount = Roact.createElement("TextLabel", {
				Size = UDim2.fromScale(1, 0.3),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				LayoutOrder = 1,

				Text = `Amount dropped when mined: {AmountDroppedWhenMined}`,
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = Theme.TextColor,
				FontFace = Theme.Font,
			}, {}),
		}),

		RarityHeader = Roact.createElement("TextLabel", {
			Size = UDim2.fromScale(1, 0.125),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 3,

			Text = "Rarity",
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = Theme.TextColor,
			FontFace = Theme.Font,
		}, {}),

		RarityGraph = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 0.4),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 4,
		}, {
			WipLabel = Roact.createElement("TextLabel", {
				Size = UDim2.fromScale(1, 0.5),
				Position = UDim2.fromScale(0, 0.5),
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,

				Text = "[RARITY GRAPH]<br />Work in progress",
				TextScaled = true,
				RichText = true,
				TextColor3 = Theme.TextDisabledColor,
				FontFace = Theme.Font,
			}, {}),
		}),
	})
end

return OreInfo
