local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)

local Forge = Roact.Component:extend("Forge")

local PickaxeButton = require(script.PickaxeButton)
local Theme = require(script.Parent.Theme)

function Forge:CreateOwnedButton(Name: string)
	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 0.08),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		App = Roact.createElement(PickaxeButton, {
			Name = Name,
		}, {}),
	})
end

function Forge:CreateUnOwnedButton(Name: string)
	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 0.08),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		App = Roact.createElement(PickaxeButton, {
			Name = Name,
			NameColor = Color3.fromHex("3f3f3f"),
		}, {}),
	})
end

function Forge:CreateLockedButton()
	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 0.08),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		App = Roact.createElement(PickaxeButton, {
			Name = "???",
			NameColor = Color3.fromHex("3f3f3f"),
		}, {}),
	})
end

function Forge:render()
	return Roact.createElement("ScreenGui", {
		ResetOnSpawn = false,
		ClipToDeviceSafeArea = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		ScreenInsets = Enum.ScreenInsets.None,
		SafeAreaCompatibility = Enum.SafeAreaCompatibility.None,
	}, {
		App = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, {
			Top = Roact.createElement("Frame", {
				Size = UDim2.fromScale(1, 0.3),
				BackgroundColor3 = Color3.new(1, 1, 1),
				BorderSizePixel = 0,
			}, {
				Gradient = Roact.createElement("UIGradient", {
					Rotation = 90,
					Color = ColorSequence.new(Color3.new(0, 0, 0)),
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0, 0),
						NumberSequenceKeypoint.new(1, 1, 0),
					}),
				}, {}),

				Title = Roact.createElement("TextLabel", {
					Size = UDim2.fromScale(0.3, 0.3),
					Position = UDim2.fromScale(0.5, 0.1),
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,

					Text = "<u>Forge</u>",
					TextColor3 = Color3.new(1, 1, 1),
					TextScaled = true,
					RichText = true,
					FontFace = Theme.Font,
				}, {}),
			}),

			Left = Roact.createElement("Frame", {
				Size = UDim2.fromScale(0.3, 1),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
			}, {
				Pickaxes = Roact.createElement("Frame", {
					Size = UDim2.fromScale(0.7, 0.8),
					Position = UDim2.fromScale(0.1, 0.5),
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundColor3 = Color3.new(0, 0, 0),
					BackgroundTransparency = 0.5,
					BorderSizePixel = 0,
				}, {
					Scroller = Roact.createElement("ScrollingFrame", {
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 1,
						BorderSizePixel = 0,

						AutomaticCanvasSize = Enum.AutomaticSize.Y,
						CanvasSize = UDim2.fromScale(1, 1),
						ScrollBarThickness = 0,
						VerticalScrollBarInset = Enum.ScrollBarInset.None,
						ScrollingDirection = Enum.ScrollingDirection.Y,
					}, {
						Layout = Roact.createElement("UIListLayout", {
							SortOrder = Enum.SortOrder.LayoutOrder,
							FillDirection = Enum.FillDirection.Vertical,
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							Padding = UDim.new(0, 10),
						}, {}),

						Padding = Roact.createElement("UIPadding", {
							PaddingTop = UDim.new(0, 10),
							PaddingLeft = UDim.new(0, 10),
							PaddingRight = UDim.new(0, 10),
							PaddingBottom = UDim.new(0, 10),
						}, {}),

						UnOwned = Forge:CreateUnOwnedButton("Un Owned"),
						Bought = Forge:CreateOwnedButton("Owned"),
						Locked = Forge:CreateLockedButton(),
					}),
				}),
			}),
		}),
	})
end

return Forge
