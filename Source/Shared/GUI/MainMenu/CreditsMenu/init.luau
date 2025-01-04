local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Flipper = require(ReplicatedStorage.Packages.Flipper)
local Roact = require(ReplicatedStorage.Packages.Roact)

local CreditsMenu = Roact.Component:extend("CreditsMenu")

local Theme = require(script.Parent.Parent.Theme)

local CloseButton = require(ReplicatedStorage.Game.GUI.Common.CloseButton)

function CreditsMenu:init()
	self.Motor = Flipper.SingleMotor.new(0)
	local Binding, SetBinding = Roact.createBinding(self.Motor:getValue())
	self.Binding = Binding
	self.Motor:onStep(SetBinding)
end

function CreditsMenu:didMount()
	self.Motor:setGoal(Flipper.Spring.new(1, {
		frequency = 5,
		dampingRatio = 1,
	}))
end

function CreditsMenu:render()
	local Position = self.Binding:map(function(Value)
		return UDim2.fromScale(0, -1.5):Lerp(UDim2.fromScale(0, 0), Value)
	end)

	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		Position = Position,
		BackgroundColor3 = Theme.BackgroundColor,
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
	}, {
		Title = Roact.createElement("TextLabel", {
			Size = UDim2.fromScale(1, 0.1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,

			Text = "Credits",
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = Theme.TextColor,
			FontFace = Theme.Font,
		}, {}),

		CloseButton = Roact.createElement(CloseButton, {
			OnClick = function()
				self.Motor:setGoal(Flipper.Spring.new(0, {
					frequency = 5,
					dampingRatio = 1,
				}))

				task.wait(0.2)

				self.props.OnClick()
			end,
		}, {}),

		Content = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 0.9),
			Position = UDim2.fromScale(0, 0.1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, {
			WipLabel = Roact.createElement("TextLabel", {
				Size = UDim2.fromScale(1, 1),
				Position = UDim2.fromScale(0, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,

				Text = "Work in progress",
				TextScaled = true,
				TextColor3 = Theme.TextColor,
				FontFace = Theme.Font,
			}, {}),
		}),
	})
end

return CreditsMenu
