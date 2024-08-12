local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

Knit.AddServicesDeep(script.Parent.Services)

-- Disable server promises since we wont be using them
-- At least for now
Knit.Start({ServicePromises = false}):catch(warn)