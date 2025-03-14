local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)

local Gameplay = Roact.Component:extend("Gameplay")

local BooleanSetting = require(ReplicatedStorage.Game.GUI.Settings.Components.BooleanSetting)
local NumberSetting = require(ReplicatedStorage.Game.GUI.Settings.Components.NumberSetting)
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

		HideOverheadGUI = Roact.createElement(BooleanSetting, {
			SettingName = "HideOverheadGUI",
			DisplayName = "Hide Overhead GUI",
			Description = "Hide your overhead GUI from yourself",
			LayoutOrder = 2,
		}, {}),

		MusicVolume = Roact.createElement(NumberSetting, {
			SettingName = "MusicVolume",
			DisplayName = "Music volume",
			Description = "The volume of all music in the game. This excludes any sound effects",
			LayoutOrder = 3,
			MinValue = 0,
			MaxValue = 1,
		}, {}),
	})
end

return Gameplay
