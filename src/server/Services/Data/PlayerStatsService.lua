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

--[[
Internal function to convert and ore into its inventory value
]]--
local function ConvertOreListItemToInventoryValue(DataFolder :Folder, Ore :Types.OreListItem) :IntValue
    local OreName = Ore.Name
    
    if OreName == "Gold" then
        return DataFolder.Gold
    end

    local FoundOreValue = DataFolder.Inventory.Ores:FindFirstChild(OreName)
    return FoundOreValue
end

--[=[
Internal function to convert and ore into a times mined value
]=]
local function ConvertOreListItemToTimesMinedValue(DataFolder :Folder, Ore :Types.OreListItem) :IntValue
    local OreName = Ore.Name

    local FoundValue = DataFolder.TimesMined:FindFirstChild(OreName)
    return FoundValue
end

--[[
Converts an ore part or ore name into an `OreListItem` which can be used with most functions that take in ores
as a paramater
]]--
function PlayerStatsService:ConvertOreNameToOreListItem(Ore :string|BasePart, Amount :number) :Types.OreListItem
    local OreName = ""

    if type(Ore) == "string" then
        OreName = Ore
    elseif Ore:IsA("BasePart") then
        OreName = Ore.Name
    end

    if OreName == "" then return end

    return {
        Name = OreName;
        Amount = Amount;
    }
end

--[[
Gives an ore to the players inventory, doesnt matter if they dont have enough space to carry it
]]--
function PlayerStatsService:GiveOre(Player :Player, Ore :Types.OreListItem)
    local DataFolder = DataService:GetPlayerDataFolder(Player)
    local ValueToChange :IntValue = ConvertOreListItemToInventoryValue(DataFolder, Ore)

    ValueToChange.Value += Ore.Amount
end

--[[
Gives the player an ore and adds it to its times mined value
]]--
function PlayerStatsService:MinedOre(Player :Player, Ore :Types.OreListItem)
    local DataFolder = DataService:GetPlayerDataFolder(Player)
    local ValueToChange = ConvertOreListItemToTimesMinedValue(DataFolder, Ore)

    ValueToChange.Value += 1
    self:GiveOre(Player, Ore)
end


--[[ KNIT ]]

function PlayerStatsService:KnitStart()
    DataService = Knit.GetService("DataService")
end

return PlayerStatsService
