local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Roact = require(ReplicatedStorage.Packages.Roact)

local NameFrame = Roact.Component:extend("NameFrame")

local Theme = require(ReplicatedStorage.Game.GUI.Theme)

function NameFrame:init()
	local UserID = self.props.UserID or 0
	local DataFolder = ReplicatedStorage.PlayerData:FindFirstChild(UserID) :: Core.DataFolder

	local function Update(LevelName: string, Color: Color3)
		self:setState({
			Name = LevelName,
			Color = Color,
		})
	end

	local function GetLevelConfig(Level: number)
		return Core.Assets.Levels:FindFirstChild(tostring(Level))
	end

	DataFolder.Level:GetPropertyChangedSignal("Value"):Connect(function()
		local Config = GetLevelConfig(DataFolder.Level.Value)
		Update(Config:GetAttribute("LevelName"), Config:GetAttribute("LevelColor"))
	end)

	local Config = GetLevelConfig(DataFolder.Level.Value)
	Update(Config:GetAttribute("LevelName"), Config:GetAttribute("LevelColor"))
end

function NameFrame:render()
	local Name = self.state.Name or "[UNKOWN]"
	local Color = self.state.Color or Color3.new(1, 0, 1)

	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
		}, {}),

		DisplayName = Roact.createElement("TextLabel", {
			Size = UDim2.fromScale(1, 0.6),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 1,

			Text = Name,
			TextScaled = true,
			FontFace = Theme.Font,
			TextColor3 = Color,
			TextStrokeTransparency = 0,
		}, {}),
	})
end

return NameFrame
