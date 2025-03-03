local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)

local OreIndexController = Knit.CreateController({ Name = "OreIndexController" })

local ClientDataController

function OreIndexController:ShouldOreBeLocked(OreName: string)
	local TimesMined = ClientDataController:GetTimesMinedForOre(OreName)
	return TimesMined <= 0
end

function OreIndexController:KnitStart()
	ClientDataController = Knit.GetController("ClientDataController")

	local OreIndex = require(ReplicatedStorage.Game.GUI.OreIndex)
	Roact.mount(Roact.createElement(OreIndex), Knit.Player.PlayerGui, "OreIndex")
end

return OreIndexController
