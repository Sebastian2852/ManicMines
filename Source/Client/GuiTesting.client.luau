local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)

Knit.OnStart():andThen(function()
	local GUI = require(ReplicatedStorage.Game.GUI.MysteryMerchant)
	Roact.mount(Roact.createElement(GUI), Knit.Player.PlayerGui, "TEST_GUI")
end)
