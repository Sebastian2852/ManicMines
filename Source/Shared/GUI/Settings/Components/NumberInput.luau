local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)

local SettingsController = Knit.GetController("PlayerSettingsController")

local Theme = require(ReplicatedStorage.Game.GUI.Theme)

return function(Component: Roact.Component, SettingName: string, MinValue: number, MaxValue: number)
	local Value = SettingsController:GetSetting(SettingName)

	return Roact.createElement("TextBox", {
		Size = UDim2.fromScale(0.15, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		SizeConstraint = Enum.SizeConstraint.RelativeXY,
		BackgroundTransparency = 0.5,
		BackgroundColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,

		Text = tostring(Value),
		TextScaled = true,
		TextColor3 = Theme.TextColor,
		FontFace = Theme.Font,
		PlaceholderText = tostring(MinValue) .. " - " .. tostring(MaxValue),

		[Roact.Event.FocusLost] = function(Box)
			local Entered = Box.Text
			if not tonumber(Entered) then
				return
			end

			local EnteredNumber = tonumber(Entered)
			local ToSet = math.clamp(EnteredNumber, MinValue, MaxValue)
			SettingsController:ModifySetting(SettingName, ToSet)
			Component:setState({
				[SettingName] = ToSet,
			})
		end,
	}, {})
end
