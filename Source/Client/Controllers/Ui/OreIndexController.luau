local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)

local Signals = require(ReplicatedStorage.Game.GUI.Signals)

local OreIndexController = Knit.CreateController({ Name = "OreIndexController" })

local ClientDataController

local CurrentGuiTree = nil

function OreIndexController:ShouldOreBeLocked(OreName: string)
	local TimesMined = ClientDataController:GetTimesMinedForOre(OreName)
	return TimesMined <= 0
end

function OreIndexController:Open()
	if CurrentGuiTree ~= nil then
		Roact.unmount(CurrentGuiTree)
		CurrentGuiTree = nil
	end

	local OreIndex = require(ReplicatedStorage.Game.GUI.OreIndex)

	CurrentGuiTree = Roact.mount(Roact.createElement(OreIndex), Knit.Player.PlayerGui, "OreIndex")

	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	workspace.CurrentCamera.CFrame = workspace.Game.OreIndexScene.CameraPos.CFrame

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

	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom

	Signals.ToggleHUDButtons:Fire(true)
	Signals.ToggleHUDGold:Fire(true)
	Signals.ToggleHotbar:Fire(true)
	Signals.ToggleInventory:Fire(true)
end

function OreIndexController:KnitStart()
	ClientDataController = Knit.GetController("ClientDataController")
end

return OreIndexController
