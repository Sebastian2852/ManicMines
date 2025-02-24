local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)
local Trove = require(ReplicatedStorage.Packages.trove)

local TycoonGenerator = Roact.Component:extend("TycoonGenerator")

local Theme = require(ReplicatedStorage.Game.GUI.Theme)

function TycoonGenerator:init()
	self:setState({
		Amount = -1,
	})

	self.Cleaner = Trove.new()
end

function TycoonGenerator:didMount()
	local Value: IntValue = self.props.WatchValue

	self.Cleaner:Add(Value:GetPropertyChangedSignal("Value"):Connect(function()
		self:setState({
			Amount = Value.Value,
		})
	end))

	self:setState({
		Amount = Value.Value,
	})
end

function TycoonGenerator:willUnmount()
	self.Cleaner:Clean()
end

function TycoonGenerator:render()
	local DisplayName = self.props.DisplayName or "[UNKNOWN]"
	local Color = self.props.Color or ColorSequence.new(Color3.new(1, 0, 1))
	local Amount = self.state.Amount

	return Roact.createElement("BillboardGui", {
		LightInfluence = 0,
		Size = UDim2.new(0, 200, 2, 0),
		StudsOffset = Vector3.new(0, 2, 0),
	}, {
		Title = Roact.createElement("TextLabel", {
			Size = UDim2.new(0, 600, 0.3, 0),
			Position = UDim2.new(0.5, -300, 0.3, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,

			Text = "Touch to collect:",
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
			FontFace = Theme.Font,
			TextStrokeTransparency = 0,
		}, {}),

		Amount = Roact.createElement("TextLabel", {
			Size = UDim2.new(0, 500, 0.5, 0),
			Position = UDim2.new(0.5, -250, 0.5, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,

			Text = `{Amount} {DisplayName}`,
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
			FontFace = Theme.Font,
			TextStrokeTransparency = 0,
		}, {
			Gradient = Roact.createElement("UIGradient", {
				Color = Color,
			}, {}),
		}),
	})
end

return TycoonGenerator
