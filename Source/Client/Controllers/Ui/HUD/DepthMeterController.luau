local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)

local CreateGradient = require(ReplicatedStorage.Game.GUI.Elements.Gradient)

local DepthMeterController = Knit.CreateController { Name = "DepthMeterController" }

local MineEffects

local DepthMeterComponent = Roact.Component:extend("DepthMeter")
local Player = Knit.Player

function DepthMeterComponent:init()
	self:setState {
		Position = Vector3.new(0, 0, 0),
		Show = false,
	}

	RunService:BindToRenderStep("CharacterPosition", Enum.RenderPriority.Input.Value, function()
		local Character = Player.Character
		if not Character or not Character.PrimaryPart or ReplicatedStorage.Player.Depth.Value <= 0 then
			self:setState {
				Position = Vector3.zero,
				Show = false,
			}
			return
		end

		self:setState {
			Position = Character.PrimaryPart.Position,
			Show = true,
		}
	end)
end

function DepthMeterComponent:GetPositionText(): string
	local Position = self.state.Position
	local X = math.floor(Position.X)
	local Y = ReplicatedStorage.Player.Depth.Value
	local Z = math.floor(Position.Z)

	return X .. ", " .. Y .. "m, " .. Z
end

function DepthMeterComponent:GetLayerName(): string
	local Final = "No layer"

	if MineEffects.CurrentLayer then
		Final = MineEffects.CurrentLayer:GetAttribute("DisplayName") or "Failed to get attribute"
	end

	return Final
end

function DepthMeterComponent:GetLayerColor(): Color3
	local Final = Color3.fromRGB(255, 0, 255)

	if MineEffects.CurrentLayer then
		Final = MineEffects.CurrentLayer:GetAttribute("Color")
	end

	return Final
end

function DepthMeterComponent:render()
	local PositionText = self:GetPositionText()
	local LayerName = self:GetLayerName()
	local LayerColor = self:GetLayerColor()

	return Roact.createElement("ScreenGui", {
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
	}, {
		Meter = self.state.Show and Roact.createElement("TextLabel", {
			Size = UDim2.fromScale(0.3, 0.05),
			Position = Core.UI.Position.TopCenter,
			AnchorPoint = Core.UI.AnchorPoint.TopCenter,

			BackgroundTransparency = 1,

			Text = PositionText,
			TextStrokeTransparency = 0,
			TextScaled = true,
			TextColor3 = Core.UI.Theme.TextColor3,
			FontFace = Core.UI.Theme.TextFont,
		}, {}),

		Layer = self.state.Show and Roact.createElement("TextLabel", {
			Size = UDim2.fromScale(0.3, 0.025),
			Position = UDim2.fromScale(0.5, 0.05),
			AnchorPoint = Core.UI.AnchorPoint.TopCenter,

			BackgroundTransparency = 1,

			Text = "(" .. LayerName .. ")",
			TextStrokeTransparency = 0,
			TextScaled = true,
			TextColor3 = Core.UI.Color.White,
			FontFace = Core.UI.Theme.TextFont,
		}, {
			CreateGradient(LayerColor, 0),
		}),
	})
end

function DepthMeterController:KnitStart()
	local LogService = Knit.GetService("LogService")
	local DataService = Knit.GetService("DataService")
	MineEffects = Knit.GetController("MineEffects")

	DataService.DataLoaded:Connect(function()
		local App = Roact.createElement(DepthMeterComponent)
		Roact.mount(App, Player.PlayerGui, "DepthMeter")
		LogService:Log("Mounted depth meter component")
	end)
end

return DepthMeterController
