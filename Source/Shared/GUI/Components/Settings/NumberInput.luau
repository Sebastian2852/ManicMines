local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Roact = require(ReplicatedStorage.Packages.Roact)

return function(
	self: Roact.Component,
	PushToServer: () -> (),
	SettingName: string,
	Settings: { [string]: any },
	Min: number,
	Max: number
)
	local Value = Settings[SettingName]
	local Ref = Roact.createRef()

	return Roact.createElement("TextBox", {
		Size = UDim2.fromScale(0.3, 0.5),
		Position = UDim2.fromScale(0.99, 0.5),
		AnchorPoint = Core.UI.AnchorPoint.RightCenter,
		SizeConstraint = Enum.SizeConstraint.RelativeXY,
		BackgroundTransparency = 0,
		BackgroundColor3 = Core.UI.Theme.BackgroundColorDark,
		BorderSizePixel = 0,

		Text = tostring(Value),
		TextScaled = true,
		TextColor3 = Core.UI.Theme.TextColor3,
		FontFace = Core.UI.Theme.TextFont,
		PlaceholderText = tostring(Min) .. " - " .. tostring(Max),

		[Roact.Ref] = Ref,

		[Roact.Event.FocusLost] = function()
			local Entered = Ref:getValue().Text
			if not tonumber(Entered) then
				return
			end
			local EnteredNumber = tonumber(Entered)
			local ToSet = math.clamp(EnteredNumber, Min, Max)

			Ref:getValue().Text = tostring(ToSet)
			Settings[SettingName] = ToSet
			local NewSettings = self.state.Settings
			NewSettings[SettingName] = Settings[SettingName]
			self:setState { Settings = NewSettings }
			PushToServer()
		end,
	}, {})
end
