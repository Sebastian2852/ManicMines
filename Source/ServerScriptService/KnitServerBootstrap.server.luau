local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Core = require(ReplicatedStorage.Game.Modules.Core)

local SaveData = require(ReplicatedStorage.Game.Modules.Classes.SaveData.SaveData)
local Data = require(ReplicatedStorage.Game.Modules.Classes.SaveData.Data)

Knit.AddServicesDeep(script.Parent.Services)

local Timer = Core.Timer.new()
Timer:Start()

Knit.Start():andThen(function()
    Timer:End()
    local TimeTaken = Timer:GetTime(10)
    print("Knit started")
    print("It took "..TimeTaken.."s to start knit")
end):catch(warn)

-- TEST CODE
-- Only here to test the new data saving system stuff

game.Players.PlayerAdded:Connect(function(Player)
    local NewSaveData = SaveData.New(Player.UserId)
    local OreData = {}
    OreData["Stone"] = {}
    OreData["Stone"].InventoryAmount = 0
    OreData["Stone"].StorageAmount = 0
    OreData["Stone"].TimesMined = 0
    local MockData = Data.New("Ores", OreData)
    NewSaveData:AddData(MockData)
    NewSaveData:Save(nil)
end)