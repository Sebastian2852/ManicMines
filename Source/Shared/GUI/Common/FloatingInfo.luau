local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Enums = require(ReplicatedStorage.Game.Modules.Enums)
local Flipper = require(ReplicatedStorage.Packages.Flipper)
local Roact = require(ReplicatedStorage.Packages.Roact)
local Theme = require(script.Parent.Parent.Theme)

local FloatingInfo = Roact.PureComponent:extend("FloatingInfo")

function FloatingInfo:init()
	self.Motor = Flipper.SingleMotor.new(0)
	local Binding, SetBinding = Roact.createBinding(self.Motor:getValue())
	self.Binding = Binding
	self.Motor:onStep(SetBinding)
end

function FloatingInfo:RenderLeft()
	local TopText = self.props.TopText or "[UNKOWN]"
	local BottomText = self.props.BottomText or "[UNKOWN]"

	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		Image = Roact.createElement("ImageLabel", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = "rbxassetid://104098381785293",
		}, {}),

		TopText = Roact.createElement("TextLabel", {
			Size = UDim2.fromScale(0.5, 0.3),
			Position = UDim2.fromScale(0.05, 0),
			AnchorPoint = Vector2.new(0, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,

			Text = TopText,
			TextScaled = true,
			TextColor3 = Color3.new(1, 1, 1),
			FontFace = Theme.Font,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Bottom,
		}, {}),

		BottomText = Roact.createElement("TextLabel", {
			Size = UDim2.fromScale(0.5, 0.2),
			Position = UDim2.fromScale(0.05, 0.4),
			AnchorPoint = Vector2.new(0, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,

			Text = BottomText,
			TextScaled = true,
			TextColor3 = Color3.new(1, 1, 1),
			FontFace = Theme.Font,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
		}, {}),
	})
end

function FloatingInfo:RenderRight()
	local TopText = self.props.TopText or "[UNKOWN]"
	local BottomText = self.props.BottomText or "[UNKOWN]"

	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		Image = Roact.createElement("ImageLabel", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = "rbxassetid://100428969260195",
		}, {}),

		TopText = Roact.createElement("TextLabel", {
			Size = UDim2.fromScale(0.5, 0.3),
			Position = UDim2.fromScale(0.95, 0),
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,

			Text = TopText,
			TextScaled = true,
			TextColor3 = Color3.new(1, 1, 1),
			FontFace = Theme.Font,
			TextXAlignment = Enum.TextXAlignment.Right,
			TextYAlignment = Enum.TextYAlignment.Bottom,
		}, {}),

		BottomText = Roact.createElement("TextLabel", {
			Size = UDim2.fromScale(0.5, 0.2),
			Position = UDim2.fromScale(0.95, 0.4),
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,

			Text = BottomText,
			TextScaled = true,
			TextColor3 = Color3.new(1, 1, 1),
			FontFace = Theme.Font,
			TextXAlignment = Enum.TextXAlignment.Right,
			TextYAlignment = Enum.TextYAlignment.Top,
		}, {}),
	})
end

function FloatingInfo:render()
	local Direction = self.props.Direction or Enums.FloatingInfoDirection.Right

	if Direction == Enums.FloatingInfoDirection.Right then
		return self:RenderRight()
	else
		return self:RenderLeft()
	end
end

return FloatingInfo
