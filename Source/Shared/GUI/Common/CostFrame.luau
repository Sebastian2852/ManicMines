-- # selene: allow(mixed_table)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Roact = require(ReplicatedStorage.Packages.Roact)
local Theme = require(script.Parent.Parent.Theme)

local ClientDataController

local CostFrame = Roact.Component:extend("CostFrame")

local IconLabel = require(script.Parent.Parent.Common.IconLabel)

function CostFrame:init()
	ClientDataController = Knit.GetController("ClientDataController")
end

function CostFrame:GetFrames()
	local Orelist = self.props.OreList or Core.OreList.New()

	local Promises = {}
	local Elements = {}

	for _, Ore: Core.OreListItem in pairs(Orelist:LoopList()) do
		local CanAfford = ClientDataController:HasEnoughOre(Ore)
		local Amount = ClientDataController:GetOresAmount(Ore.Name)
		local NeeedAmount = Ore.Amount

		table.insert(
			Promises,
			Promise.new(function(Resolve)
				Elements[Ore.Name] = Roact.createElement("Frame", {
					Size = UDim2.fromScale(1, 0.25),
					BackgroundTransparency = CanAfford and 1 or 0.5,
					BackgroundColor3 = CanAfford and Color3.new(0, 0, 0) or Theme.BackgroundColorRed,
					BorderSizePixel = 0,
					LayoutOrder = -Ore.Amount,
				}, {
					App = Roact.createElement(IconLabel, {
						Image = Ore.Emblem,
						Text = CanAfford and Ore.DisplayName .. ": " .. Ore.Amount
							or `{Ore.DisplayName}: {Ore.Amount} ({NeeedAmount - Amount} missing)`,
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
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromScale(0, 0),
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
