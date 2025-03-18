local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)

local TutoriaController = Knit.CreateController({
	Name = "TutorialController",
})

local ClientDataController
local DataService

local GUITree = nil

function TutoriaController:AdvanceStage()
	ClientDataController:AdvanceTutorialStage()
end

function TutoriaController:ApplyCurrentStage()
	local CurrentStage = ClientDataController:GetTutorialStage()

	if CurrentStage < 0 then
		if GUITree then
			Roact.unmount(GUITree)
			GUITree = nil
		end
		return
	end
end

function TutoriaController:KnitStart()
	ClientDataController = Knit.GetController("ClientDataController")
	DataService = Knit.GetService("DataService")

	DataService.DataLoaded:Connect(function()
		local CurrentStage = ClientDataController:GetTutorialStage()
		if CurrentStage == -2 or CurrentStage == -1 then
			print("Tutorial finished or skipped")
			return
		end

		local GUI = require(ReplicatedStorage.Game.GUI.Tutorial)
		GUITree = Roact.mount(
			Roact.createElement(GUI, {
				DataFolder = ClientDataController:GetDataFolder(),
			}),
			Knit.Player.PlayerGui,
			"Tutorial"
		)

		print("Tutorial time!")
	end)
end

return TutoriaController
