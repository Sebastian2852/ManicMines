-- Roblox
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Cmdr = require(ReplicatedStorage.Packages.cmdr)

-- Game
local Profiler = require(ReplicatedStorage.Game.Modules.Profiler)
local Tests = require(ReplicatedStorage.Game.Tests)



-- [[ TESTING / STUDIO ONLY ]] --
-- TODO: Make this only run in studio
Tests:RunTests()



-- [[ KNIT ]] --

Knit.AddServicesDeep(script.Parent.Services)

local Timer = Profiler.Timer.new("[RUNTIME] Start knit")

Knit.Start():andThen(function()
    Timer:Stop()
    print("Knit started")
end):catch(warn)



-- [[ COMPONENTS ]] --

-- for _, Object in pairs(script.Parent.Components:GetDescendants()) do
    -- if not Object:IsA("ModuleScript") then continue end
    -- require(Object)
-- end



-- [[ CMDR ]] --

Cmdr:RegisterHooksIn(script.Parent.Cmdr.Hooks)
Cmdr:RegisterCommandsIn(script.Parent.Cmdr.Commands)
Cmdr:RegisterTypesIn(script.Parent.Cmdr.Types)
Cmdr:RegisterDefaultCommands({"Help", "DefaultUtil"})