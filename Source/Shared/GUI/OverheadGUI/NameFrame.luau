local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Roact = require(ReplicatedStorage.Packages.Roact)

local NameFrame = Roact.Component:extend("NameFrame")

local Theme = require(ReplicatedStorage.Game.GUI.Theme)

function NameFrame:init()
	local UserID = self.props.UserID or 0
	local Player = Players:GetPlayerByUserId(UserID)

	self:setState({
		Name = Player.Name,
		DisplayName = Player.DisplayName,
	})
end

function NameFrame:render()
	local Username = self.state.Name
	local DisplayName = self.state.DisplayName
	local DevPrefix = Core.GameConfig.Admins.Admins[self.props.UserID or 0]

	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, {}),

		DisplayName = Roact.createElement("TextLabel", {
			Size = UDim2.fromScale(1, 0.6),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 1,

			Text = DevPrefix and `[DEV] {DisplayName}` or DisplayName,
			TextScaled = true,
			FontFace = Theme.Font,
			TextColor3 = DevPrefix and Color3.fromRGB(179, 138, 255) or Theme.TextColor,
			TextStrokeTransparency = 0,
		}, {}),

		Username = Roact.createElement("TextLabel", {
			Size = UDim2.fromScale(1, 0.3),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 2,

			Text = `(@{Username})`,
			TextScaled = true,
			FontFace = Theme.Font,
			TextColor3 = Theme.TextColor,
			TextStrokeTransparency = 0,
		}, {}),
	})
end

return NameFrame
