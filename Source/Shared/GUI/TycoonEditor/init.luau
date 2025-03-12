local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)

local TycoonEditorController

local OreIndex = Roact.Component:extend("OreIndex")

local Main = require(ReplicatedStorage.Game.GUI.TycoonEditor.Main)
local Theme = require(ReplicatedStorage.Game.GUI.Theme)

function OreIndex:init()
	TycoonEditorController = Knit.GetController("TycoonEditorController")
end

function OreIndex:render()
	return Roact.createElement("ScreenGui", {
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
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

				Text = "<u>Tycoon Editor</u>",
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
				RichText = true,
				FontFace = Theme.Font,
			}, {}),

			CloseButton = Roact.createElement("TextButton", {
				Size = UDim2.fromScale(0.1, 0.1),
				Position = UDim2.new(0.5, 0, 0.4, 10),
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Theme.BackgroundColorRed,
				BorderSizePixel = 0,

				Text = "<- Back",
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
				FontFace = Theme.Font,

				[Roact.Event.MouseButton1Click] = function()
					TycoonEditorController:CloseGUI()
				end,
			}, {
				Corners = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0, 7),
				}, {}),
			}),
		}),

		Main = Roact.createElement("Frame", {
			Size = UDim2.fromScale(0.25, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, {
			App = Roact.createElement(Main, {}, {}),
		}),
	})
end

return OreIndex
