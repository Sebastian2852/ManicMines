local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)

local SettingsController = Knit.GetController("PlayerSettingsController")

return function(Component: Roact.Component, SettingName: string)
	local Value = SettingsController:GetSetting(SettingName)

	local ImageId = "rbxasset://textures/DeveloperFramework/checkbox_unchecked_dark.png"
	if Value == true then
		ImageId = "rbxasset://textures/DeveloperFramework/checkbox_checked_dark.png"
	end
	return Roact.createElement("ImageButton", {
		Size = UDim2.fromScale(0.5, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,

		BackgroundTransparency = 1,
		BorderSizePixel = 0,

		Image = ImageId,

		[Roact.Event.MouseButton1Click] = function()
			SettingsController:ModifySetting(SettingName, not Value)
			Component:setState({
				SettingName = not Value,
			})
		end,
	}, {
		AspectRatio = Roact.createElement("UIAspectRatioConstraint", {
			AspectRatio = 1,
			AspectType = Enum.AspectType.ScaleWithParentSize,
			DominantAxis = Enum.DominantAxis.Height,
		}, {}),
	})
end
