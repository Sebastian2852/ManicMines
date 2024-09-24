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

-- TEMP CODE
-- Test loading stuff
game.Players.PlayerAdded:Connect(function(Player)
    local LoadingService = Knit.GetService("LoadingService")
    local LogService = Knit.GetService("LogService")

    LogService:Log("Waiting 5 seconds")
    task.wait(5)
    LoadingService:StartLoading(Player)
    task.wait(5)
    LoadingService:EndLoading(Player)
end)