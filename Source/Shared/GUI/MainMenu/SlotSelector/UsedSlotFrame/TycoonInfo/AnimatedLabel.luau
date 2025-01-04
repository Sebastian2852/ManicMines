local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Flipper = require(ReplicatedStorage.Packages.Flipper)
local Roact = require(ReplicatedStorage.Packages.Roact)

local AnimatedLabel = Roact.PureComponent:extend("AnimatedLabel")

local Theme = require(script.Parent.Parent.Parent.Parent.Parent.Theme)

function AnimatedLabel:init()
	self.Motor = Flipper.SingleMotor.new(0)
	local Binding, SetBinding = Roact.createBinding(self.Motor:getValue())
	self.Binding = Binding
	self.Motor:onStep(SetBinding)
end

function AnimatedLabel:render()
	local Text = self.props.Text
	local LayoutOrder = self.props.LayoutOrder

	local Size = self.Binding:map(function(Value)
		return UDim2.fromScale(1, 0.2):Lerp(UDim2.fromScale(1, 0.26), Value)
	end)

	return Roact.createElement("TextLabel", {
		Size = Size,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = LayoutOrder,

		Text = Text,
		TextScaled = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = Theme.TextColor,
		FontFace = Theme.Font,

		[Roact.Event.MouseEnter] = function()
			self.Motor:setGoal(Flipper.Spring.new(1, {
				frequency = 5,
				dampingRatio = 1,
			}))
		end,

		[Roact.Event.MouseLeave] = function()
			self.Motor:setGoal(Flipper.Spring.new(0, {
				frequency = 4,
				dampingRatio = 1,
			}))
		end,
	}, {})
end

return AnimatedLabel
