local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)

Knit.OnStart():andThen(function()
	local GUI = require(ReplicatedStorage.Game.GUI.MysteryMerchant)

	local Connection
	Connection = UserInputService.InputBegan:Connect(function(Input)
		if Input.KeyCode ~= Enum.KeyCode.Z then
			return
		end

		Roact.mount(Roact.createElement(GUI), Knit.Player.PlayerGui, "TEST_GUI")
		Connection:Disconnect()
	end)
end)
