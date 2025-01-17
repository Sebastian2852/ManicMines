local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Flipper = require(ReplicatedStorage.Packages.Flipper)
local Roact = require(ReplicatedStorage.Packages.Roact)

local PickaxeButton = Roact.Component:extend("PickaxeButton")

local Theme = require(script.Parent.Parent.Theme)

function PickaxeButton:init()
	self.Motor = Flipper.SingleMotor.new(0)
	local Binding, SetBinding = Roact.createBinding(self.Motor:getValue())
	self.Binding = Binding
	self.Motor:onStep(SetBinding)
end

function PickaxeButton:render()
	local PickaxeName = self.props.Name or "[UNKOWN]"
	local NameColor = self.props.NameColor or Color3.new(1, 1, 1)

	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
	}, {
		Corners = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 7),
		}, {}),

		PickaxeName = Roact.createElement("TextLabel", {
			Size = UDim2.fromScale(1, 0.7),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 2,

			Text = PickaxeName,
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextColor3 = NameColor,
			FontFace = Theme.Font,
		}, {}),
	})
end

return PickaxeButton
