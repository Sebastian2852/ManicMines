local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

Knit.AddControllersDeep(script.Parent.Controllers)

Knit.Start():andThen(function()
    print("Knit started")
end):catch(warn)