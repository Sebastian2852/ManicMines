local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)

local Signals = require(ReplicatedStorage.Game.GUI.Signals)

local OreIndexController = Knit.CreateController({ Name = "OreIndexController" })

local ClientDataController

local Camera = workspace.CurrentCamera
local OreIndexSceneCamera = workspace.Game.OreIndexScene.CameraPos
local CameraBaseCFrame = OreIndexSceneCamera.CFrame
local CameraOffsetFactor = 0.2

local CurrentGuiTree = nil
local MouseMoveConnection = nil

function OreIndexController:ShouldOreBeLocked(OreName: string)
	local TimesMined = ClientDataController:GetTimesMinedForOre(OreName)
	return TimesMined <= 0
end

function OreIndexController:OnMouseMove(MousePosition: Vector2)
	local ViewportSize = Camera.ViewportSize

	local OffsetX = ((MousePosition.X / ViewportSize.X) - 0.5) * 2
	local OffsetY = -((MousePosition.Y / ViewportSize.Y) - 0.5) * 2

	local OffsetCFrame = CFrame.new(OffsetX * CameraOffsetFactor, OffsetY * CameraOffsetFactor, 0)
	Camera.CFrame = CameraBaseCFrame * OffsetCFrame
end

function OreIndexController:Open()
	if CurrentGuiTree ~= nil then
		Roact.unmount(CurrentGuiTree)
		CurrentGuiTree = nil
	end

	local OreIndex = require(ReplicatedStorage.Game.GUI.OreIndex)

	CurrentGuiTree = Roact.mount(Roact.createElement(OreIndex), Knit.Player.PlayerGui, "OreIndex")

	if MouseMoveConnection then
		MouseMoveConnection:Disconnect()
	end

	MouseMoveConnection = UserInputService.InputChanged:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement then
			self:OnMouseMove(Input.Position)
		end
	end)

	Camera.CameraType = Enum.CameraType.Scriptable
	Camera.CFrame = workspace.Game.OreIndexScene.CameraPos.CFrame

	Signals.ToggleHUDButtons:Fire(false)
	Signals.ToggleHUDGold:Fire(false)
	Signals.ToggleHotbar:Fire(false)
	Signals.ToggleInventory:Fire(false)
end

function OreIndexController:Close()
	if CurrentGuiTree ~= nil then
		Roact.unmount(CurrentGuiTree)
		CurrentGuiTree = nil
	end

	if MouseMoveConnection then
		MouseMoveConnection:Disconnect()
		MouseMoveConnection = nil
	end

	Camera.CameraType = Enum.CameraType.Custom

	Signals.ToggleHUDButtons:Fire(true)
	Signals.ToggleHUDGold:Fire(true)
	Signals.ToggleHotbar:Fire(true)
	Signals.ToggleInventory:Fire(true)
end

function OreIndexController:KnitStart()
	ClientDataController = Knit.GetController("ClientDataController")
end

return OreIndexController
