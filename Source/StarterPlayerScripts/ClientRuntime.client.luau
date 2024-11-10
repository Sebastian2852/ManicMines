-- Roblox
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Cmdr = require(ReplicatedStorage:WaitForChild("CmdrClient"))

-- [[ KNIT ]] --

Knit.AddControllersDeep(script.Parent.Controllers)
Knit.Start():andThen(function()
    print("Knit started")
end):catch(warn)



-- [[ CMDR ]] --

Cmdr:SetActivationKeys({ Enum.KeyCode.F2 })