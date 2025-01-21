-- # selene: allow(mixed_table)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Roact = require(ReplicatedStorage.Packages.Roact)

local CostFrame = Roact.Component:extend("CostFrame")

local IconLabel = require(script.Parent.Parent.Common.IconLabel)

function CostFrame:GetFrames()
	local Orelist = self.props.OreList or Core.OreList.New()

	Orelist:AddOre("Stone", 300)
	Orelist:AddOre("Gold", 15)
	Orelist:AddOre("Iron", 301)

	local Promises = {}
	local Elements = {}

	for _, Ore: Core.OreListItem in pairs(Orelist:LoopList()) do
		table.insert(
			Promises,
			Promise.new(function(Resolve)
				Elements[Ore.Name] = Roact.createElement("Frame", {
					Size = UDim2.fromScale(1, 0.25),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					LayoutOrder = -Ore.Amount,
				}, {
					App = Roact.createElement(IconLabel, {
						Image = Ore.Emblem,
						Text = Ore.DisplayName .. ": " .. Ore.Amount,
					}, {}),
				})
				Resolve()
			end)
		)
	end

	Promise.all(Promises):await()

	return Roact.createFragment(Elements)
end

function CostFrame:render()
	local Frames = self:GetFrames()

	return Roact.createElement("ScrollingFrame", {
		Size = UDim2.fromScale(1, 0.8),
		Position = UDim2.fromScale(0, 0.2),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,

		CanvasSize = UDim2.fromScale(1, 1),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 5,
		ScrollBarImageColor3 = Color3.new(1, 1, 1),
		VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right,
		VerticalScrollBarInset = Enum.ScrollBarInset.Always,
		ScrollingDirection = Enum.ScrollingDirection.Y,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Vertical,
		}, {}),

		Frames,
	})
end

return CostFrame
