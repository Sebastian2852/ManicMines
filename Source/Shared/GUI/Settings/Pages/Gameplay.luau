local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)

local Gameplay = Roact.Component:extend("Gameplay")

local BooleanSetting = require(ReplicatedStorage.Game.GUI.Settings.Components.BooleanSetting)
local Title = require(ReplicatedStorage.Game.GUI.Settings.Components.Title)

function Gameplay:render()
	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, {}),

		Title = Roact.createElement(Title, {
			Text = "Gameplay",
		}, {}),

		ShortUnits = Roact.createElement(BooleanSetting, {
			SettingName = "InventoryShortUnits",
			DisplayName = "Inventory Uses Short Units",
			Description = "Make the inventory (and storage) use short units. E.g. 1000 -> 1k",
			LayoutOrder = 1,
		}, {}),
	})
end

return Gameplay
