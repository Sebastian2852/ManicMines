local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local CharacterController = Knit.CreateController { Name = "CharacterController" }

local LogService

local FREEZE_ACTION = "FreezeAction"



-- [[ PUBLIC ]] --

--[=[
Disables the player's movement
]=]
function CharacterController:DisableMovement()
    LogService:Log("Disabling movement")
    ContextActionService:BindAction(FREEZE_ACTION, function()
        return Enum.ContextActionResult.Sink
    end, false, unpack(Enum.PlayerActions:GetEnumItems()))
end

--[=[
Enables the player's movement
]=]
function CharacterController:EnableMovement()
    LogService:Log("Enabling movement")
    ContextActionService:UnbindAction(FREEZE_ACTION)
end



-- [[ KNIT ]] --

function CharacterController:KnitStart()
    LogService = Knit.GetService("LogService")
end

return CharacterController