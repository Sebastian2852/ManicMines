-- Roblox
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
require(ReplicatedStorage.Packages.Iris).Init()
local Cmdr = require(ReplicatedStorage:WaitForChild("CmdrClient"))

-- [[ KNIT ]] --

Knit.AddControllersDeep(script.Parent.Controllers)
Knit.Start():andThen(function()
    print("Knit started")
end):catch(warn)



-- [[ COMPONENTS ]] --

for _, Object in pairs(script.Parent.Components:GetDescendants()) do
    if not Object:IsA("ModuleScript") then continue end
    require(Object)
end



-- [[ CMDR ]] --

Cmdr:SetActivationKeys({ Enum.KeyCode.F2 })