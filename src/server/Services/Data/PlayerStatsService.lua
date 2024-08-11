local Knit = require(game.ReplicatedStorage.Packages.Knit)

local Types = require(game.ReplicatedStorage.Shared.Modules.Types)
local DataService

--[[
A service that has all the functions to do with stats, stuff like giving ores
paying for stuff, etc. All those functions are in this service
]]--
local PlayerStatsService = Knit.CreateService {
    Name = "PlayerStatsService",
    Client = {},
}

local function ConvertOreListItemToInventoryValue(DataFolder :Folder, Ore :Types.OreListItem)
    local OreName = Ore.Name
    
    if OreName == "Gold" then
        return DataFolder.Gold
    end

    local FoundOreValue = DataFolder.Inventory.Ores:FindFirstChild(OreName)
    return FoundOreValue
end

function PlayerStatsService:GiveOre(Player :Player, Ore :Types.OreListItem)
    local DataFolder = DataService:GetPlayerDataFolder(Player)
    local ValueToChange :IntValue = ConvertOreListItemToInventoryValue(DataFolder, Ore)

    ValueToChange.Value += Ore.Amount
end


--[[ KNIT ]]

function PlayerStatsService:KnitStart()
    DataService = Knit.GetService("DataService")
end

return PlayerStatsService
