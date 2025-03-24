local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Display = require(script.Parent.Display)
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
	local Image = self.props.Image or Theme.Images.Missing
	local ImageColor = self.props.ImageColor or Color3.new(1, 1, 1)
	local PickaxeConfig = self.props.PickaxeConfig or ReplicatedStorage.Assets.Pickaxe.Pickaxes["0"]
	local Animated = self.props.Animated or false

	local Size = self.Binding:map(function(Value)
		return UDim2.fromScale(1, 1):Lerp(UDim2.fromScale(1, 1.2), Value)
	end)

	return Roact.createElement("Frame", {
		Size = Size,
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
	}, {
		Corners = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 7),
		}, {}),

		Padding = Roact.createElement("UIPadding", {
			PaddingTop = UDim.new(0, 10),
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
			PaddingBottom = UDim.new(0, 10),
		}, {}),

		ClickArea = Roact.createElement("TextButton", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,

			Text = "",

			[Roact.Event.MouseButton1Click] = function()
				Display.ShowPickaxe(PickaxeConfig)
			end,

			[Roact.Event.MouseEnter] = function()
				if Animated then
					self.Motor:setGoal(Flipper.Spring.new(1, {
						frequency = 4,
						dampingRatio = 1,
					}))
				end
			end,

			[Roact.Event.MouseLeave] = function()
				if Animated then
					self.Motor:setGoal(Flipper.Spring.new(0, {
						frequency = 4,
						dampingRatio = 1,
					}))
				end
			end,
		}, {}),

		Content = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, {
			Layout = Roact.createElement("UIListLayout", {
				Padding = UDim.new(0, 10),
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalFlex = Enum.UIFlexAlignment.Fill,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}, {}),

			Image = Roact.createElement("ImageLabel", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				LayoutOrder = 1,

				Image = Image,
				ImageColor3 = ImageColor,
				ScaleType = Enum.ScaleType.Fit,
			}, {
				AspectRatio = Roact.createElement("UIAspectRatioConstraint", {
					AspectRatio = 1,
					AspectType = Enum.AspectType.ScaleWithParentSize,
					DominantAxis = Enum.DominantAxis.Height,
				}, {}),
			}),

			PickaxeName = Roact.createElement("TextLabel", {
				Size = UDim2.fromScale(1, 1),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				LayoutOrder = 2,

				Text = PickaxeName,
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = NameColor,
				FontFace = Theme.Font,
			}, {}),
		}),
	})
end

return PickaxeButton
