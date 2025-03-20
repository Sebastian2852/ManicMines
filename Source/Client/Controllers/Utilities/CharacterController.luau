local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Logger = require(ReplicatedStorage.Game.Modules.Logger)

local CharacterController = Knit.CreateController({ Name = "CharacterController" })

local FREEZE_ACTION = "FreezeAction"

-- [[ PUBLIC ]] --

--[=[
Disables the player's movement
]=]
function CharacterController:DisableMovement()
	Logger:Log("Disabling movement")
	ContextActionService:BindAction(FREEZE_ACTION, function()
		return Enum.ContextActionResult.Sink
	end, false, unpack(Enum.PlayerActions:GetEnumItems()))
end

--[=[
Enables the player's movement
]=]
function CharacterController:EnableMovement()
	Logger:Log("Enabling movement")
	ContextActionService:UnbindAction(FREEZE_ACTION)
end

return CharacterController
