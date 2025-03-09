local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Knit = require(ReplicatedStorage.Packages.Knit)

Knit.OnStart():andThen(function()
	UserInputService.InputBegan:Connect(function(Input)
		if Input.KeyCode ~= Enum.KeyCode.Z then
			return
		end

		warn("No test GUI active")
	end)
end)
