local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)
local Signals = require(ReplicatedStorage.Game.GUI.Signals)

local TycoonEditorController = Knit.CreateController({ Name = "TycoonEditorController" })

local Tree
local MouseConnection

local CameraOffsetFactor = 0.5
local Camera = workspace.CurrentCamera

function TycoonEditorController:OnMouseMove(BaseCFrame: CFrame, MousePosition: Vector2)
	local ViewportSize = Camera.ViewportSize

	local OffsetX = ((MousePosition.X / ViewportSize.X) - 0.5) * 2
	local OffsetY = -((MousePosition.Y / ViewportSize.Y) - 0.5) * 2

	local OffsetCFrame = CFrame.new(OffsetX * CameraOffsetFactor, OffsetY * CameraOffsetFactor, 0)
	Camera.CFrame = BaseCFrame * OffsetCFrame
end

function TycoonEditorController:OpenGUI()
	Signals.ToggleHUDButtons:Fire(false)
	Signals.ToggleHUDGold:Fire(false)
	Signals.ToggleHotbar:Fire(false)
	Signals.ToggleInventory:Fire(false)

	if Tree then
		Roact.unmount(Tree)
		Tree = nil
	end

	if MouseConnection then
		MouseConnection:Disconnect()
	end

	local Tycoon = workspace.Game.Tycoons:FindFirstChild(Knit.Player.UserId)

	Camera = workspace.CurrentCamera
	Camera.CameraType = Enum.CameraType.Scriptable
	self:OnMouseMove(Tycoon.Main.EditorCamPart.CFrame, UserInputService:GetMouseLocation())
	MouseConnection = UserInputService.InputChanged:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement then
			self:OnMouseMove(Tycoon.Main.EditorCamPart.CFrame, Input.Position)
		end
	end)

	local GUI = require(ReplicatedStorage.Game.GUI.TycoonEditor)
	Tree = Roact.mount(Roact.createElement(GUI), Knit.Player.PlayerGui, "TycoonEditor")
end

function TycoonEditorController:CloseGUI()
	Signals.ToggleHUDButtons:Fire(true)
	Signals.ToggleHUDGold:Fire(true)
	Signals.ToggleHotbar:Fire(true)
	Signals.ToggleInventory:Fire(true)

	if Tree then
		Roact.unmount(Tree)
		Tree = nil
	end

	if MouseConnection then
		MouseConnection:Disconnect()
	end

	Camera.CameraType = Enum.CameraType.Custom
end

return TycoonEditorController
