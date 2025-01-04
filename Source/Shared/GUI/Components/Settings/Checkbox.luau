local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Roact = require(ReplicatedStorage.Packages.Roact)

return function(self: Roact.Component, PushToServer: () -> (), SettingName: string, Settings: { [string]: any })
	local Value = Settings[SettingName]

	local ImageId = Core.UI.Images.CheckBoxUnchecked
	if Value == true then
		ImageId = Core.UI.Images.CheckBoxChecked
	end
	return Roact.createElement("ImageButton", {
		Size = UDim2.fromScale(0.7, 0.7),
		Position = UDim2.fromScale(0.9, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,

		BackgroundTransparency = 1,
		BorderSizePixel = 0,

		Image = ImageId,

		[Roact.Event.MouseButton1Click] = function()
			Settings[SettingName] = not Settings[SettingName]
			local NewSettings = self.state.Settings
			NewSettings[SettingName] = Settings[SettingName]
			self:setState { Settings = NewSettings }
			PushToServer()
		end,
	}, {})
end
