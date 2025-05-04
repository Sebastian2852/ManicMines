local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)

local Graphics = Roact.Component:extend("Graphics")

local BooleanSetting = require(ReplicatedStorage.Game.GUI.Settings.Components.BooleanSetting)
local NumberSetting = require(ReplicatedStorage.Game.GUI.Settings.Components.NumberSetting)
local Title = require(ReplicatedStorage.Game.GUI.Settings.Components.Title)

function Graphics:render()
	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, {}),

		Title = Roact.createElement(Title, {
			Text = "Graphics",
		}, {}),

		Shadows = Roact.createElement(BooleanSetting, {
			SettingName = "GlobalShadows",
			DisplayName = "Shadows",
			Description = "Toggle global shadows",
			LayoutOrder = 1,
		}, {}),

		RainbowEffects = Roact.createElement(BooleanSetting, {
			SettingName = "RainbowEffect",
			DisplayName = "RGB effects",
			Description = "Toggle the RGB effects that is present in some ores (This makes them neon white)",
			LayoutOrder = 2,
		}, {}),

		OreCracks = Roact.createElement(BooleanSetting, {
			SettingName = "OreCracks",
			DisplayName = "Ore cracks",
			Description = "Enable/Disable the ore cracks on blocks that are being mined",
			LayoutOrder = 3,
		}, {}),

		Wind = Roact.createElement(BooleanSetting, {
			SettingName = "Wind",
			DisplayName = "Wind Effects",
			Description = "Enable/Disable the slight movment on trees",
			LayoutOrder = 4,
		}, {}),

		WindDistance = Roact.createElement(NumberSetting, {
			SettingName = "WindDistance",
			DisplayName = "Wind Distance",
			Description = "Maximum distance wind can affect parts. ",
			LayoutOrder = 5,

			MinValue = 1,
			MaxValue = 300,
		}, {}),
	})
end

return Graphics
