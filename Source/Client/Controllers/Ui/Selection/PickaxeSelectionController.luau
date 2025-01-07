local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)

local PickaxeSelectionController = Knit.CreateController({ Name = "PickaxeSelectionController" })

--[[ KNIT ]]
--

function PickaxeSelectionController:KnitStart()
	local NewGui = require(ReplicatedStorage.Game.GUI.PickaxeSelection)
	local App = Roact.createElement(NewGui, {}, {})
	Roact.mount(App, Knit.Player.PlayerGui, "Pickaxe Selection")
end

return PickaxeSelectionController
