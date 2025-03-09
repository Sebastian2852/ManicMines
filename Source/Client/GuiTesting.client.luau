local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)

Knit.OnStart():andThen(function()
	local GUI = require(ReplicatedStorage.Game.GUI.MysteryMerchant)
	local Tree = nil

	UserInputService.InputBegan:Connect(function(Input)
		if Input.KeyCode ~= Enum.KeyCode.Z then
			return
		end

		if Tree ~= nil then
			return
		end

		Tree = Roact.mount(
			Roact.createElement(GUI, {
				Close = function()
					Roact.unmount(Tree)
					Tree = nil
				end,
			}),
			Knit.Player.PlayerGui,
			"TEST_GUI"
		)
	end)
end)
