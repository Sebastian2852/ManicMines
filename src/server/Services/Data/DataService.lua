local Knit = require(game.ReplicatedStorage.Packages.Knit)

local RootDataFolder :Folder = game.ReplicatedStorage.PlayerData
local TemplateDataFolder :Folder = RootDataFolder:FindFirstChild("Template")

local OresFolder :Folder = game.ReplicatedStorage.Assets.Ores

local DataService = Knit.CreateService {
    Name = "DataService",
    Client = {},
}

--[[
Create a data folder for a given player
]]--
function DataService:CreateDataFolderForPlayer(Player :Player) :Folder
    if self:PlayerHasDataFolder(Player) then return nil end
    local DataFolder = TemplateDataFolder:Clone()
    DataFolder.Name = Player.UserId
    DataFolder.Parent = RootDataFolder
    return DataFolder
end

--[[
Returns the player's data folder if they have one
]]--
function DataService:GetPlayerDataFolder(Player :Player) :Folder?
    local FoundDataFolder = RootDataFolder:FindFirstChild(tostring(Player.UserId))
    return FoundDataFolder
end

--[[
Returns true/false if the the player has a data folder
]]--
function DataService:PlayerHasDataFolder(Player :Player) :boolean
    local FoundDataFolder = RootDataFolder:FindFirstChild(tostring(Player.UserId))
    if FoundDataFolder then
        return true
    end

    return false
end


--[[ KNIT ]]--

--[[
Setup the template data folder to have every single value so that when it is
cloned for a player it already has every value the player needs ready. This should
make it so data loading is much faster than before.
]]--
function DataService:KnitInit()
    for _, Ore :BasePart in pairs(OresFolder:GetChildren()) do
        local InventoryValue = Instance.new("IntValue")
        InventoryValue.Name = Ore.Name
        InventoryValue.Parent = TemplateDataFolder.Inventory
        
        local StorageValue = Instance.new("IntValue")
        StorageValue.Name = Ore.Name
        StorageValue.Parent = TemplateDataFolder.Storage

        local TimesMinedValue = Instance.new("IntValue")
        TimesMinedValue.Name = Ore.Name
        TimesMinedValue.Parent = TemplateDataFolder.TimesMined

        local EmblemOwned = Instance.new("BoolValue")
        EmblemOwned.Name = Ore.Name
        EmblemOwned.Parent = TemplateDataFolder.Emblems
    end

    -- TEMP CODE:
    -- This will be removed when the main menu is added and save slots are added
    game.Players.PlayerAdded:Connect(function(Player)
        self:CreateDataFolderForPlayer(Player)
    end)
end

return DataService
