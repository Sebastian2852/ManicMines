local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)

local Graphics = Roact.Component:extend("Graphics")

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
			Text = "Experimental",
			Subtitle = "⚠️ THESE SETTINGS ARE EXPERIMENTAL AND <font color='#fc9905'>CAN CAUSE ERRORS OR DATA LOSS</font>; USE AT YOUR OWN RISK ⚠️",
		}, {}),
	})
end

return Graphics
