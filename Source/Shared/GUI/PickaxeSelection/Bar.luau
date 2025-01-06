local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Flipper = require(ReplicatedStorage.Packages.Flipper)
local Roact = require(ReplicatedStorage.Packages.Roact)
local Theme = require(script.Parent.Parent.Theme)

local Bar = Roact.Component:extend("Bar")

function Bar:init()
	local Block = self.props.Block :: BasePart

	self.Motor = Flipper.SingleMotor.new(0)
	local Binding, SetBinding = Roact.createBinding(self.Motor:getValue())
	self.Binding = Binding
	self.Motor:onStep(SetBinding)

	Block:GetAttributeChangedSignal("Health"):Connect(function()
		local Health = Block:GetAttribute("Health")
		local MaxHealth = Block:GetAttribute("MaxHealth")
		local Size = math.clamp(MaxHealth / Health, 0, 1)

		self.Motor:setGoal(Flipper.Spring.new(Size, {
			frequency = 4,
			dampingRatio = 1,
		}))
	end)
end

function Bar:render()
	local BarSize = self.Binding:map(function(Value)
		return UDim2.fromScale(0, 1):Lerp(UDim2.fromScale(1, 1), Value)
	end)

	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		Stroke = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 0,
			BackgroundColor3 = Theme.BackgroundColor,
			BorderSizePixel = 0,
		}, {
			Corners = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 4),
			}, {}),

			Stroke = Roact.createElement("UIStroke", {
				Thickness = 3,
				Color = Theme.BackgroundColor,
			}, {}),
		}),

		Bar = Roact.createElement("Frame", {
			Size = BarSize,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderSizePixel = 0,
			ZIndex = 2,
		}, {}),
	})
end

return Bar
