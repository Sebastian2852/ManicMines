local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Core = require(ReplicatedStorage.Game.Modules.Core)

Knit.AddServicesDeep(script.Parent.Services)

local Timer = Core.Timer.new()
Timer:Start()

Knit.Start():andThen(function()
    Timer:End()
    local TimeTaken = Timer:GetTime(10)
    print("Knit started")
    print("It took "..TimeTaken.."s to start knit")
end):catch(warn)

Core.Events.NewDataFolder.OnBindableEvent:Connect(function(DataFolder)
    print("New data folder: "..DataFolder.Name)
end)

Core.Events.DataLoaded.OnBindableEvent:Connect(function()
    print("data loaded")
end)