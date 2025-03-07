-- Roblox
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Cmdr = require(ReplicatedStorage.Packages.cmdr)
local Knit = require(ReplicatedStorage.Packages.Knit)

-- Game
local Profiler = require(ReplicatedStorage.Game.Modules.Profiler)
local Tests = require(ReplicatedStorage.Game.Tests)

-- [[ TESTING / STUDIO ONLY ]] --
if _G.DEBUG then
	Tests:RunTests()
end

-- [[ KNIT ]] --

Knit.AddServicesDeep(script.Parent.Services)

local KnitStartTimer = Profiler.Timer.new()

Knit.Start()
	:andThen(function()
		local StartTime = KnitStartTimer:GetTime()
		KnitStartTimer:Destroy()
		print(`Server loaded: {StartTime}ms elapsed`)
	end)
	:catch(warn)

-- [[ COMPONENTS ]] --

-- for _, Object in pairs(script.Parent.Components:GetDescendants()) do
-- if not Object:IsA("ModuleScript") then continue end
-- require(Object)
-- end

-- [[ CMDR ]] --

Cmdr:RegisterHooksIn(script.Parent.Cmdr.Hooks)
Cmdr:RegisterCommandsIn(script.Parent.Cmdr.Commands)
Cmdr:RegisterTypesIn(script.Parent.Cmdr.Types)
Cmdr:RegisterDefaultCommands({ "Help", "DefaultUtil" })
