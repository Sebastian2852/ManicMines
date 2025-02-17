local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)

local HoverInfo = Roact.Component:extend("HoverInfo")

function HoverInfo:render()
	local TextToShow = self.props.Text or "[UNKNOWN]"
	local Hovered = self.state.Hovered or false

	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,

		[Roact.Event.MouseEnter] = function()
			self:setState({
				Hovered = true,
			})
		end,

		[Roact.Event.MouseLeave] = function()
			self:setState({
				Hovered = false,
			})
		end,
	}, {
		App = Hovered and Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			Position = UDim2.fromScale(0.5, 1),
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, {
			Text = Roact.createElement("TextLabel", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,

				Text = TextToShow,
				TextScaled = true,
				TextColor3 = Color3.new(1, 1, 1),
				TextStrokeTransparency = 0,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Top,
			}, {}),
		}),
	})
end

return HoverInfo
