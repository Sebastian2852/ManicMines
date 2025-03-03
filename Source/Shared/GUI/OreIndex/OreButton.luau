local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)

local OreButton = Roact.PureComponent:extend("OreButton")

local IconLabel = require(ReplicatedStorage.Game.GUI.Common.IconLabel)

function OreButton:render()
	local Emblem = self.props.Emblem
	local OreName = self.props.OreName
	local IsLocked = self.props.IsLocked or false
	local OnClick = self.props.OnClick or function()
		warn("No on click!!")
	end

	return Roact.createElement("TextButton", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,

		[Roact.Event.MouseButton1Click] = function()
			OnClick()
		end,
	}, {
		App = Roact.createElement(IconLabel, {
			Image = Emblem,
			Text = IsLocked and "???" or OreName,
			ImageColor = IsLocked and Color3.new(0, 0, 0) or Color3.new(1, 1, 1),
		}, {}),
	})
end

return OreButton
