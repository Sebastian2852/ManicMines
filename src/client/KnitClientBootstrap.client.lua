local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
Knit.ControllersReady = false

Knit.AddControllersDeep(script.Parent.Controllers)

Knit.Start():catch(warn)

Knit.ControllersReady = true