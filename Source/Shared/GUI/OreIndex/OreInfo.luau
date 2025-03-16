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
		table.insert(DepthRange, RarityValue)
	end

	-- Create and configure the graph
	local GraphHandler = GraphModule.new(Frame)
	GraphHandler.Resolution = 50
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
			Size = UDim2.fromScale(1, 0.125),
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
			Size = UDim2.fromScale(1, 0.1),
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
			Size = UDim2.fromScale(1, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 4,

			[Roact.Ref] = self.GraphFrameRef,
		}, {}),
	})
end

return OreInfo
