-- Roblox
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Profiler = require(ReplicatedStorage.Game.Modules.Profiler)
require(ReplicatedStorage.Packages.Iris).Init()

-- [[ KNIT ]] --

local KnitStartTimer = Profiler.Timer.new()

Knit.AddControllersDeep(script.Parent.Controllers)
Knit.Start()
	:andThen(function()
		local StartTime = KnitStartTimer:GetTime()
		KnitStartTimer:Destroy()
		print(`Client loaded: {StartTime}ms elapsed`)
	end)
	:catch(warn)

-- [[ COMPONENTS ]] --

for _, Object in pairs(script.Parent.Components:GetDescendants()) do
	if not Object:IsA("ModuleScript") then
		continue
	end
	require(Object)
end

-- [[ CMDR ]] --

local Cmdr = require(ReplicatedStorage:WaitForChild("CmdrClient"))
Cmdr:SetActivationKeys({ Enum.KeyCode.F2 })
Cmdr:SetPlaceName("ManicMines")
Cmdr:SetActivationUnlocksMouse(true)
