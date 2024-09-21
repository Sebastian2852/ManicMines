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

--[=[
Convert an ore type into its inventory value
]=]
local function ConvertOreListItemToInventoryValue(DataFolder :Folder, Ore :Core.Ore) :IntValue
    local OreName = Ore.Name
    
    if OreName == "Gold" then
        return DataFolder.Gold
    end

    local FoundOreValue = DataFolder.Inventory.Ores:FindFirstChild(OreName)
    return FoundOreValue
end

--[=[
Convert an ore type into its TimesMined value
]=]
local function ConvertOreListItemToTimesMinedValue(DataFolder :Folder, Ore :Core.Ore) :IntValue
    local OreName = Ore.Name

    local FoundValue = DataFolder.TimesMined:FindFirstChild(OreName)
    return FoundValue
end



-- [[ PUBLIC ]]--

--[=[
Gives an ore to the players inventory, doesnt matter if they dont have enough space to carry it
]=]
function PlayerStatsService:GiveOre(Player :Player, Ore :Core.Ore)
    local DataFolder = DataService:GetPlayerDataFolder(Player)
    local ValueToChange :IntValue = ConvertOreListItemToInventoryValue(DataFolder, Ore)

    ValueToChange.Value += Ore.Amount
    LogService:Log("Gave "..Player.Name.." "..Ore.Amount.." "..Ore.Name)
end

--[=[
Gives the player an ore and adds it to its times mined value
]=]
function PlayerStatsService:MinedOre(Player :Player, Ore :Core.Ore)
    local DataFolder = DataService:GetPlayerDataFolder(Player)
    local ValueToChange = ConvertOreListItemToTimesMinedValue(DataFolder, Ore)

    LogService:Log("Increased "..Player.Name.."'s "..Ore.Name.." times mined value")
    ValueToChange.Value += 1
    self:GiveOre(Player, Ore)
end



--[[ KNIT ]]

function PlayerStatsService:KnitStart()
    DataService = Knit.GetService("DataService")
    LogService = Knit.GetService("LogService")
end

return PlayerStatsService
