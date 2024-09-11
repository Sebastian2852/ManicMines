local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Core = require(ReplicatedStorage.Game.Modules.Core)

Knit.AddControllersDeep(script.Parent.Controllers)

Knit.Start():andThen(function()
    print("Knit started")
end):catch(warn)

Core.Events.NewDataFolder.RemoteEvent.OnClientEvent:Connect(function(DataFolder)
    print("New data folder: "..DataFolder.Name)
end)

Core.Events.DataLoaded.RemoteEvent.OnClientEvent:Connect(function()
    print("data loaded")
end)