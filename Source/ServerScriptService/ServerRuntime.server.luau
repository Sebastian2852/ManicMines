-- Roblox
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Cmdr = require(ReplicatedStorage.Packages.cmdr)

-- Game
local Core = require(ReplicatedStorage.Game.Modules.Core)
local Tests = require(ReplicatedStorage.Game.Tests)



-- [[ TESTING / STUDIO ONLY ]] --
-- TODO: Make this only run in studio
Tests:RunTests()



-- [[ KNIT ]] --

Knit.AddServicesDeep(script.Parent.Services)

local Timer = Core.Timer.new()
Timer:Start()

Knit.Start():andThen(function()
    Timer:End()
    local TimeTaken = Timer:GetTime(10)
    print("Knit started")
    print("It took "..TimeTaken.."s to start knit")
end):catch(warn)



-- [[ CMDR ]] --

Cmdr:RegisterHooksIn(script.Parent.Cmdr.Hooks)
Cmdr:RegisterCommandsIn(script.Parent.Cmdr.Commands)