local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)

local OreIndexController = Knit.CreateController({ Name = "OreIndexController" })

function OreIndexController:KnitStart()
	local OreIndex = require(ReplicatedStorage.Game.GUI.OreIndex)
	Roact.mount(Roact.createElement(OreIndex), Knit.Player.PlayerGui, "OreIndex")
end

return OreIndexController
