local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Events = require(ReplicatedStorage.Game.Modules.Events)

Knit.AddServicesDeep(script.Parent.Services)

Knit.Start():andThen(function()
    print("Knit started")
end):catch(warn)

Events.NewDataFolder.OnEvent:Connect(function(DataFolder)
    print("New data folder:", DataFolder.Name)
end)