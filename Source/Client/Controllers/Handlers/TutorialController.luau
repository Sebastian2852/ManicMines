local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)
local Signals = require(ReplicatedStorage.Game.GUI.Signals)

local TutoriaController = Knit.CreateController({
	Name = "TutorialController",
})

local ClientDataController
local DataService

local ActiveTutorialFolder = nil
local GUITree = nil

function TutoriaController:AdvanceStage()
	ClientDataController:AdvanceTutorialStage()
end

function TutoriaController:ApplyCurrentStage()
	local CurrentStage = ClientDataController:GetTutorialStage()

	if ActiveTutorialFolder ~= nil then
		ActiveTutorialFolder:Destroy()
	end

	if CurrentStage < 0 then
		if GUITree then
			Roact.unmount(GUITree)
			GUITree = nil
		end
		Signals.ToggleHUDButtons:Fire(true)
		Signals.ToggleHotbar:Fire(true)
		Signals.ToggleHUDGold:Fire(true)
		Signals.ToggleInventory:Fire(true)
		return
	end

	local StageFolder = ReplicatedStorage.Assets.Tutorial:FindFirstChild(CurrentStage)
	if StageFolder then
		ActiveTutorialFolder = StageFolder:Clone()
		ActiveTutorialFolder.Parent = Workspace
	end
end

function TutoriaController:KnitStart()
	ClientDataController = Knit.GetController("ClientDataController")
	DataService = Knit.GetService("DataService")

	DataService.DataLoaded:Connect(function()
		local CurrentStage = ClientDataController:GetTutorialStage()
		if CurrentStage == -2 or CurrentStage == -1 then
			return
		end

		local GUI = require(ReplicatedStorage.Game.GUI.Tutorial)
		task.wait(1)
		GUITree = Roact.mount(
			Roact.createElement(GUI, {
				DataFolder = ClientDataController:GetDataFolder(),
			}),
			Knit.Player.PlayerGui,
			"Tutorial"
		)

		local DataFolder = ClientDataController:GetDataFolder() :: Core.DataFolder
		DataFolder.TutorialStage:GetPropertyChangedSignal("Value"):Connect(function()
			self:ApplyCurrentStage()
		end)
	end)
end

return TutoriaController
