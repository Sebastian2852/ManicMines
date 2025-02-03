local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)
local Trove = require(ReplicatedStorage.Packages.trove)

local MineEffects

local Player = Players.LocalPlayer

local DepthMeter = Roact.Component:extend("DepthMeter")

local Theme = require(ReplicatedStorage.Game.GUI.Theme)

function DepthMeter:init()
	MineEffects = Knit.GetController("MineEffects")
	self.Trove = Trove.new()
end

function DepthMeter:didMount()
	local Connection = RunService.Heartbeat:Connect(function()
		local Character = Player.Character
		if not Character then
			return
		end

		local PrimaryPart = Character.PrimaryPart
		if not PrimaryPart then
			return
		end

		local Position = PrimaryPart.CFrame.Position

		self:setState({
			X = Position.X,
			Z = Position.Z,
		})
	end)
	self.Trove:Add(Connection)
end

function DepthMeter:GetPositionText(): string
	local X = self.state.X or 0
	local Z = self.state.Z or 0

	local FlooredX = math.floor(X)
	local Depth = ReplicatedStorage.Player.Depth.Value
	local FlooredZ = math.floor(Z)

	return FlooredX .. ", " .. Depth .. "m, " .. FlooredZ
end

function DepthMeter:GetLayerName(): string
	local LayerName = "No layer"

	if MineEffects.CurrentLayer then
		LayerName = MineEffects.CurrentLayer:GetAttribute("DisplayName") or "Failed to get attribute"
	end

	return LayerName
end

function DepthMeter:GetLayerColor(): Color3
	local Color = Color3.fromRGB(255, 0, 255)

	if MineEffects.CurrentLayer then
		Color = MineEffects.CurrentLayer:GetAttribute("Color")
	end

	return Color
end

function DepthMeter:shouldUpdate(_, NextState)
	local CurrentX = self.state.X
	local CurrentZ = self.state.Z

	local NewX = NextState.X
	local NewZ = NextState.Z

	if CurrentX == NewX then
		return false
	end

	if CurrentZ == NewZ then
		return false
	end

	return true
end

function DepthMeter:willUnmount()
	self.Trove:Clean()
end

function DepthMeter:render()
	if ReplicatedStorage.Player.Depth.Value <= 0 then
		return nil
	end

	local PositionText = self:GetPositionText()
	local LayerName = self:GetLayerName()
	local LayerColor = self:GetLayerColor()

	return Roact.createElement("ScreenGui", {
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
	}, {
		Meter = Roact.createElement("TextLabel", {
			Size = UDim2.fromScale(0.3, 0.05),
			Position = UDim2.fromScale(0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0),

			BackgroundTransparency = 1,

			Text = PositionText,
			TextStrokeTransparency = 0,
			TextScaled = true,
			TextColor3 = Theme.TextColor,
			FontFace = Theme.Font,
		}, {}),

		Layer = Roact.createElement("TextLabel", {
			Size = UDim2.fromScale(0.3, 0.025),
			Position = UDim2.fromScale(0.5, 0.05),
			AnchorPoint = Vector2.new(0.5, 0),

			BackgroundTransparency = 1,

			Text = "(" .. LayerName .. ")",
			TextStrokeTransparency = 0,
			TextScaled = true,
			TextColor3 = Theme.TextColor,
			FontFace = Theme.Font,
		}, {
			Gradient = Roact.createElement("UIGradient", {
				Color = LayerColor,
			}, {}),
		}),
	})
end

return DepthMeter
