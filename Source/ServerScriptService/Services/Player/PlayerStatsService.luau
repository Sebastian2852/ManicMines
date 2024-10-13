local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Core = require(ReplicatedStorage.Game.Modules.Core)

local PlayerStatsService = Knit.CreateService {
    Name = "PlayerStatsService",
    Client = {},
}

local DataService
local LogService

-- [[ PRIVATE ]] --

local function FindInventoryValueByName(Name :string, DataFolder :Core.DataFolder)
    return DataFolder.Inventory.Ores:FindFirstChild(Name) or DataFolder.Inventory.Ores:FindFirstChild("Stone")
end

local function FindTimesMinedValueByName(Name :string, DataFolder :Core.DataFolder)
    return DataFolder.TimesMined:FindFirstChild(Name) or DataFolder.TimesMined:FindFirstChild("Stone")
end



-- [[ PUBLIC ]]--

--[=[
Gives ores to the players inventory, doesnt matter if they dont have enough space to carry it
]=]
function PlayerStatsService:GiveOres(Player :Player, OreList)
    local DataFolder :Core.DataFolder = DataService:GetPlayerDataFolder(Player)

    for OreName, Data in pairs(OreList:LoopList()) do
        if Data.Amount == 0 then continue end

        if OreName == "Gold" then
            DataFolder.Gold.Value += Data.Amount
            LogService:Log("Gave "..Player.Name.." "..Data.Amount.." gold")
            continue
        end

        local DataValue = FindInventoryValueByName(OreName, DataFolder)
        DataValue.Value += Data.Amount
        LogService:Log("Gave "..Player.Name.." "..Data.Amount.." "..Data.DisplayName)
    end
end

--[=[
Gives the player ores and adds 1 to its times mined value
]=]
function PlayerStatsService:MinedOre(Player :Player, OreList)
    local DataFolder = DataService:GetPlayerDataFolder(Player)

    for OreName, _ in pairs(OreList:LoopList()) do
        local DataValue = FindTimesMinedValueByName(OreName, DataFolder)
        DataValue.Value += 1
        LogService:Log("Increased "..Player.Name.."'s "..OreName.." times mined value")
    end

    self:GiveOres(Player, OreList)
end



--[[ KNIT ]]

function PlayerStatsService:KnitStart()
    DataService = Knit.GetService("DataService")
    LogService = Knit.GetService("LogService")
end

return PlayerStatsService
