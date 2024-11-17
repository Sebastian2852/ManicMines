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
Calculate and set the given data folder's inventory item count value to the correct amount
]=]
function PlayerStatsService:CalculateInventoryCapacity(DataFolder :Core.DataFolder)
    local Total = 0

    for _, Ore :IntValue in pairs(DataFolder.Inventory.Ores:GetChildren()) do
        if Ore.Value <= 0 then continue end
        Total += Ore.Value
    end

    DataFolder.Inventory.InventoryItemCount.Value = Total
end

--[=[
Give a player a certain amount of levels
]=]
function PlayerStatsService:AwardLevel(Player :Player, Amount :number)
    local DataFolder :Core.DataFolder = DataService:GetPlayerDataFolder(Player)
    DataFolder.Level.Value += Amount
end

--[=[
Give a player a certain amount of XP
]=]
function PlayerStatsService:AwardXP(Player: Player, Amount: number)
    local DataFolder: Core.DataFolder = DataService:GetPlayerDataFolder(Player)
    local CurrentLevel = DataFolder.Level.Value
    local NextLevelConfig = Core.Assets.Levels:FindFirstChild(tostring(CurrentLevel + 1))

    if not NextLevelConfig then
        DataFolder.XP.Value += Amount
        return
    end

    local XpNeeded = NextLevelConfig:GetAttribute("XpNeeded")
    local CurrentXp = DataFolder.XP.Value
    local NewXp = CurrentXp + Amount

    if NewXp >= XpNeeded then
        local ExtraXp = NewXp - XpNeeded
        self:AwardLevel(Player, 1)
        self:AwardXP(Player, ExtraXp)
    else
        DataFolder.XP.Value = NewXp
    end
end

--[=[
Gives ores to the players inventory, doesnt matter if they dont have enough space to carry it
]=]
function PlayerStatsService:GiveOres(Player :Player, OreList)
    local DataFolder :Core.DataFolder = DataService:GetPlayerDataFolder(Player)

    for OreName, Data in pairs(OreList:LoopList()) do
        if Data.Amount == 0 then continue end

        if OreName == "GoldGoins" then
            DataFolder.Gold.Value += Data.Amount
            LogService:Log("Gave "..Player.Name.." "..Data.Amount.." gold")
            continue
        end

        local DataValue = FindInventoryValueByName(OreName, DataFolder)
        DataValue.Value += Data.Amount
        LogService:Log("Gave "..Player.Name.." "..Data.Amount.." "..Data.DisplayName)
    end
    self:CalculateInventoryCapacity(DataFolder)
end

--[=[
Takes ores from the player's inventory and storage
]=]
function PlayerStatsService:TakeOres(Player :Player, OreList)
    local DataFolder :Core.DataFolder = DataService:GetPlayerDataFolder(Player)

    for OreName, Data in pairs(OreList:LoopList()) do
        if Data.Amount == 0 then continue end

        if OreName == "Gold" then
            local NewAmount = DataFolder.Gold.Value - Data.Amount
            if NewAmount <= 0 then
                NewAmount = 0
            end
            DataFolder.Gold.Value = NewAmount
            LogService:Log("removed "..Player.Name.." "..Data.Amount.." gold")
            continue
        end

        local DataValue = FindInventoryValueByName(OreName, DataFolder)
        local NewAmount = DataValue.Value - Data.Amount
        if NewAmount <= 0 then
            NewAmount = 0
        end
        DataValue.Value = NewAmount
        LogService:Log("removed "..Player.Name.." "..Data.Amount.." "..Data.DisplayName)
    end
    self:CalculateInventoryCapacity(DataFolder)
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
