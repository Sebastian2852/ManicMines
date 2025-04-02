local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)

local LoadingController = Knit.CreateController({
	Name = "LoadingController",
})

local Player = Knit.Player

--[[ KNIT ]]
--

function LoadingController:KnitStart()
	local LoadingScreen = require(ReplicatedStorage.Game.GUI.LoadingScreen)
	Roact.mount(Roact.createElement(LoadingScreen, {}, {}), Player.PlayerGui, "LoadingScreen")
end

return LoadingController
