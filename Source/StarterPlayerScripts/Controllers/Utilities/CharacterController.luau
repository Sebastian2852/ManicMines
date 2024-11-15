local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local CharacterController = Knit.CreateController { Name = "CharacterController" }

local FREEZE_ACTION = "FreezeAction"

-- [[ PUBLIC ]] --

--[=[
Disables the player's movement
]=]
function CharacterController:DisableMovement()
    ContextActionService:BindAction(FREEZE_ACTION, function()
        return Enum.ContextActionResult.Sink
    end, false, unpack(Enum.PlayerActions:GetEnumItems()))
end

--[=[
Enables the player's movement
]=]
function CharacterController:EnableMovement()
    ContextActionService:UnbindAction(FREEZE_ACTION)
end

return CharacterController