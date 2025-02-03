local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)
local Trove = require(ReplicatedStorage.Packages.trove)

local ClientDataController

local Storage = Roact.Component:extend("Storage")

local OreFrame = require(script.OreFrame)
local Theme = require(script.Parent.Parent.Theme)

function Storage:init()
	ClientDataController = Knit.GetController("ClientDataController")
	self.Trove = Trove.new()

	self:setState({
		OreFrames = {},
	})
end

function Storage:CreateOreFrame(Emblem: string, Name: string, Amount: number, OreName: string)
	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 0.1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		App = Roact.createElement(OreFrame, {
			Image = Emblem,
			Text = Name,
			Amount = Amount,
			OreName = OreName,
		}, {}),
	})
end

function Storage:didMount()
	self:setState({
		OreFrames = {},
	})

	local DataFolder: Core.DataFolder = ClientDataController:GetDataFolder()

	for _, v: IntValue in pairs(DataFolder.Storage.Ores:GetChildren()) do
		local RealOre = v.Name == "Stone" and Core.Assets.Stone or Core.Assets.Ores:FindFirstChild(v.Name)

		local Connection = v:GetPropertyChangedSignal("Value"):Connect(function()
			self:setState(function(State)
				local Amount = v.Value
				State["OreFrames"][v.Name] = Amount > 0
						and self:CreateOreFrame(
							RealOre:GetAttribute("EmblemImageID"),
							RealOre:GetAttribute("DisplayName"),
							v.Value,
							v.Name
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
						v.Value,
						v.Name
					)
				or nil
			return State
		end)

		self.Trove:Add(Connection)
	end
end

function Storage:willUnmount()
	self.Trove:Clean()
end

function Storage:render()
	local OreFrames = self.state.OreFrames
	OreFrames["Layout"] = Roact.createElement("UIListLayout", {}, {})

	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalFlex = Enum.UIFlexAlignment.Fill,
		}, {}),

		Title = Roact.createElement("TextLabel", {
			Size = UDim2.fromScale(1, 0.125),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 1,

			Text = "Storage",
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Right,
			TextColor3 = Theme.TextColor,
			FontFace = Theme.Font,
		}, {}),

		Ores = Roact.createElement("ScrollingFrame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.6,
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

return Storage
