local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)

local PlayerDisplayService = Knit.CreateService({
	Name = "PlayerDisplayService",
	Client = {},
})

local OverheadGUI

function PlayerDisplayService:GivePlayerOverheadGUI(Player: Player)
	local Character = Player.Character or Player.CharacterAdded:Wait()

	Roact.mount(
		Roact.createElement(OverheadGUI, {
			UserID = Player.UserId,
		}, {}),
		Character,
		"OverheadGUI"
	)
end

function PlayerDisplayService:KnitInit()
	OverheadGUI = require(ReplicatedStorage.Game.GUI.OverheadGUI)
end

return PlayerDisplayService
