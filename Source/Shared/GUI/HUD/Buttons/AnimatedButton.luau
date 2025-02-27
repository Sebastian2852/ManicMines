local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Flipper = require(ReplicatedStorage.Packages.Flipper)
local Roact = require(ReplicatedStorage.Packages.Roact)

local AnimatedButton = Roact.PureComponent:extend("AnimatedButton")

local Theme = require(script.Parent.Parent.Parent.Theme)

function AnimatedButton:init()
	self.Motor = Flipper.SingleMotor.new(0)
	local Binding, SetBinding = Roact.createBinding(self.Motor:getValue())
	self.Binding = Binding
	self.Motor:onStep(SetBinding)
end

function AnimatedButton:didMount()
	self.Motor:setGoal(Flipper.Spring.new(0.5, {
		frequency = 4,
		dampingRatio = 1,
	}))
end

function AnimatedButton:willUnmount()
	self.Motor:setGoal(Flipper.Spring.new(0, {
		frequency = 4,
		dampingRatio = 1,
	}))

	local Done = false

	self.Motor:onComplete(function()
		Done = true
	end)

	repeat
		task.wait(0.001)
	until Done
end

function AnimatedButton:render()
	local Icon = self.props.Icon :: string or Theme.Images.Missing
	local Background = self.props.Background :: string or Theme.Images.Missing
	local OnClick = self.props.OnClick or function()
		warn("Missing on-click function!")
	end

	local ButtonSize = self.Binding:map(function(Value)
		return UDim2.fromScale(0, 0):Lerp(UDim2.fromScale(2, 2), Value)
	end)

	return Roact.createElement("Frame", {
		Size = ButtonSize,
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		ClickArea = Roact.createElement("TextButton", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = 3,

			Text = "",
			TextSize = 0,

			[Roact.Event.MouseEnter] = function()
				self.Motor:setGoal(Flipper.Spring.new(0.6, {
					frequency = 4,
					dampingRatio = 1,
				}))
			end,

			[Roact.Event.MouseLeave] = function()
				self.Motor:setGoal(Flipper.Spring.new(0.5, {
					frequency = 4,
					dampingRatio = 1,
				}))
			end,

			[Roact.Event.MouseButton1Click] = function()
				self.Motor:setGoal(Flipper.Spring.new(0.5, {
					frequency = 4,
					dampingRatio = 1,
				}))

				OnClick()
			end,
		}, {}),

		Icon = Roact.createElement("ImageLabel", {
			Size = UDim2.fromScale(0.9, 0.9),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = 2,

			Image = Icon,
			ScaleType = Enum.ScaleType.Fit,
		}, {}),

		Background = Roact.createElement("ImageLabel", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = 1,

			Image = Background,
			ScaleType = Enum.ScaleType.Crop,
		}, {}),
	})
end

return AnimatedButton
