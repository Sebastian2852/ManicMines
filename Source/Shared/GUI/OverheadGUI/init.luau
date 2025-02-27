local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)

local OverheadGUI = Roact.Component:extend("OverheadGUI")

local LevelFrame = require(ReplicatedStorage.Game.GUI.OverheadGUI.LevelFrame)
local NameFrame = require(ReplicatedStorage.Game.GUI.OverheadGUI.NameFrame)

function OverheadGUI:render()
	local UserID = self.props.UserID or 0

	return Roact.createElement("BillboardGui", {
		Size = UDim2.fromScale(7, 3),
		StudsOffset = Vector3.new(0, 5, 0),

		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		LightInfluence = 0,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, {}),

		Level = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 1,
		}, {
			App = Roact.createElement(LevelFrame, {
				UserID = UserID,
			}, {}),
		}),

		Name = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 2,
		}, {
			App = Roact.createElement(NameFrame, {
				UserID = UserID,
			}, {}),
		}),
	})
end

return OverheadGUI
