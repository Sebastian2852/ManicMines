local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)
local Trove = require(ReplicatedStorage.Packages.trove)

local ClientDataController

local Inventory = Roact.Component:extend("Inventory")

local OreFrame = require(script.OreFrame)
local Theme = require(script.Parent.Parent.Theme)

function Inventory:init()
	ClientDataController = Knit.GetController("ClientDataController")
	self.Trove = Trove.new()

	self:setState({
		OreFrames = {},
	})
end

function Inventory:CreateOreFrame(Emblem: string, Name: string, Amount: number)
	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 0.1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		App = Roact.createElement(OreFrame, {
			Image = Emblem,
			Text = Name,
			Amount = Amount,
		}, {}),
	})
end

function Inventory:didMount()
	self:setState({
		OreFrames = {},
	})

	local DataFolder: Core.DataFolder = ClientDataController:GetDataFolder()

	for _, v: IntValue in pairs(DataFolder.Inventory.Ores:GetChildren()) do
		local RealOre = v.Name == "Stone" and Core.Assets.Stone or Core.Assets.Ores:FindFirstChild(v.Name)

		local Connection = v:GetPropertyChangedSignal("Value"):Connect(function()
			self:setState(function(State)
				local Amount = v.Value
				State["OreFrames"][v.Name] = Amount > 0
						and self:CreateOreFrame(
							RealOre:GetAttribute("EmblemImageID"),
							RealOre:GetAttribute("DisplayName"),
							v.Value
						)
					or nil
				return State
			end)
		end)

		self:setState(function(State)
			local Amount = v.Value
			State["OreFrames"][v.Name] = Amount > 0
					and self:CreateOreFrame(
						RealOre:GetAttribute("EmblemImageID"),
						RealOre:GetAttribute("DisplayName"),
						v.Value
					)
				or nil
			return State
		end)

		self.Trove:Add(Connection)
	end
end

function Inventory:willUnmount()
	self.Trove:Clean()
end

function Inventory:render()
	local OreFrames = self.state.OreFrames
	OreFrames["Layout"] = Roact.createElement("UIListLayout", {}, {})

	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, {}),

		Title = Roact.createElement("TextLabel", {
			Size = UDim2.fromScale(1, 0.125),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 1,

			Text = "Inventory",
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = Theme.TextColor,
			FontFace = Theme.Font,
		}, {}),

		Ores = Roact.createElement("ScrollingFrame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 2,

			CanvasSize = UDim2.fromScale(1, 1),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 5,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
			VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Left,
		}, OreFrames),
	})
end

return Inventory
