local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Core = require(ReplicatedStorage.Game.Modules.Core)
local GraphModule = require(ReplicatedStorage.Packages.GraphModule)
local Roact = require(ReplicatedStorage.Packages.Roact)

local OreInfo = Roact.PureComponent:extend("OreInfo")

local Theme = require(ReplicatedStorage.Game.GUI.Theme)

function OreInfo:init()
	self.GraphFrameRef = Roact.createRef()
end

-- Function to calculate rarity using the same logic as MineService
local function CalculateRarity(OreSpawningRange, NormalRarity, Depth, Curve)
	local NormalDepth = (Depth - OreSpawningRange.Min) / (OreSpawningRange.Max - OreSpawningRange.Min)
	local Rarity = Core.Util:EvaluateNumberSequence(Curve, NormalDepth)

	local AdjustedRarity = 0

	if Rarity <= 0 then
		AdjustedRarity = math.huge
	elseif Rarity >= 1 then
		AdjustedRarity = 1
	else
		local x = 1 - (Rarity * 2)
		AdjustedRarity = NormalRarity ^ x
	end

	return AdjustedRarity
end

function OreInfo:componentDidUpdate()
	local Frame = self.GraphFrameRef.current :: Frame?
	if not Frame then
		return
	end

	local Block = self.props.Block
	if not Block then
		return
	end

	Frame:ClearAllChildren()

	-- Extract ore attributes
	local SpawningRange: NumberRange = Block:GetAttribute("SpawningRange")
	local NormalRarity = Block:GetAttribute("Rarity")
	local SpawningCurve = Block:GetAttribute("SpawningCurve")

	-- Generate data points for the graph
	local DepthRange = {}
	local Step = (SpawningRange.Max - SpawningRange.Min) / 50 -- 50 data points
	for Depth = SpawningRange.Min, SpawningRange.Max, Step do
		local RarityValue = CalculateRarity(SpawningRange, NormalRarity, Depth, SpawningCurve)
		table.insert(DepthRange, math.floor((1 / RarityValue) * NormalRarity))
	end

	-- Create and configure the graph
	local GraphHandler = GraphModule.new(Frame)
	GraphHandler.Resolution = 20
	GraphHandler.BaselineZero = true
	GraphHandler.Data = {
		Rarity = DepthRange,
	}
end

function OreInfo:render()
	local Block = self.props.Block
	if Block == nil then
		return
	end

	local DisplayName = Block:GetAttribute("DisplayName")
	local DepthRange: NumberRange = Block:GetAttribute("SpawningRange")
	local XpWhenMined = Block:GetAttribute("XP")
	local AmountDroppedWhenMined = Block:GetAttribute("AmountDroppedWhenMined")
	local BlockColor = Block:GetAttribute("InventoryBackgroundColor")
	local Description = Block:GetAttribute("OreIndexDescription") or ""
	local Rarity = Block:GetAttribute("Rarity")

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
			Size = UDim2.fromScale(1, 0.075),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 1,

			Text = DisplayName,
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = Theme.TextColor,
			FontFace = Theme.Font,
		}, {
			Gradient = Roact.createElement("UIGradient", {
				Color = BlockColor,
			}, {}),
		}),

		Description = Roact.createElement("TextLabel", {
			Size = UDim2.fromScale(1, 0.04),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 2,

			Text = Description,
			TextScaled = true,
			RichText = true,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextColor3 = Theme.TextColor,
			FontFace = Theme.Font,
		}, {}),

		InfoHeader = Roact.createElement("TextLabel", {
			Size = UDim2.fromScale(1, 0.06),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 3,

			Text = "Basic Info",
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = Theme.TextColor,
			FontFace = Theme.Font,
		}, {}),

		OreInfo = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 0.15),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 4,
		}, {
			Layout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				SortOrder = Enum.SortOrder.Name,
			}, {}),

			Depth = Roact.createElement("TextLabel", {
				Size = UDim2.fromScale(1, 0.25),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,

				Text = `Depth: {DepthRange.Min}m - {DepthRange.Max}m`,
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = Theme.TextColor,
				FontFace = Theme.Font,
			}, {}),

			BaseRarity = Roact.createElement("TextLabel", {
				Size = UDim2.fromScale(1, 0.25),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,

				Text = `Base rarity (1/x): {Rarity}`,
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = Theme.TextColor,
				FontFace = Theme.Font,
			}, {}),

			XP = Roact.createElement("TextLabel", {
				Size = UDim2.fromScale(1, 0.25),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,

				Text = `XP when mined: {XpWhenMined} XP`,
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = Theme.TextColor,
				FontFace = Theme.Font,
			}, {}),

			Amount = Roact.createElement("TextLabel", {
				Size = UDim2.fromScale(1, 0.25),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,

				Text = `Amount dropped when mined: {AmountDroppedWhenMined}`,
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = Theme.TextColor,
				FontFace = Theme.Font,
			}, {}),
		}),

		RarityHeader = Roact.createElement("TextLabel", {
			Size = UDim2.fromScale(1, 0.06),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 5,

			Text = "Rarity",
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = Theme.TextColor,
			FontFace = Theme.Font,
		}, {}),

		RarityGraph = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 6,

			[Roact.Ref] = self.GraphFrameRef,
		}, {}),
	})
end

return OreInfo
