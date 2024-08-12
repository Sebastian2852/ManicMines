local Knit = require(game.ReplicatedStorage.Packages.Knit)

local RootDataFolder :Folder = game.ReplicatedStorage.PlayerData
local TemplateDataFolder :Folder = RootDataFolder:FindFirstChild("Template")

local OresFolder :Folder = game.ReplicatedStorage.Assets.Ores
local PickaxesFolder :Folder = game.ReplicatedStorage.Assets.Pickaxe.Pickaxes

local PickaxeService
local LogService

local DataService = Knit.CreateService {
    Name = "DataService",
    Client = {},
}

--[[ INTERNAL ]]--

local function SetupTemplateDataFolder()
    local StoneInventoryValue = Instance.new("IntValue")
    StoneInventoryValue.Name = "Stone"
    StoneInventoryValue.Parent = TemplateDataFolder.Inventory.Ores

    local StoneStorageValue = Instance.new("IntValue")
    StoneStorageValue.Name = "Stone"
    StoneStorageValue.Parent = TemplateDataFolder.Storage.Ores

    local TimesMinedValue = Instance.new("IntValue")
    TimesMinedValue.Name = "Stone"
    TimesMinedValue.Parent = TemplateDataFolder.TimesMined

    local EmblemOwned = Instance.new("BoolValue")
    EmblemOwned.Name = "Stone"
    EmblemOwned.Parent = TemplateDataFolder.Emblems

    for _, Ore :BasePart in pairs(OresFolder:GetChildren()) do
        local InventoryValue = Instance.new("IntValue")
        InventoryValue.Name = Ore.Name
        InventoryValue.Parent = TemplateDataFolder.Inventory.Ores
        
        local StorageValue = Instance.new("IntValue")
        StorageValue.Name = Ore.Name
        StorageValue.Parent = TemplateDataFolder.Storage.Ores

        local TimesMinedValue = Instance.new("IntValue")
        TimesMinedValue.Name = Ore.Name
        TimesMinedValue.Parent = TemplateDataFolder.TimesMined

        local EmblemOwned = Instance.new("BoolValue")
        EmblemOwned.Name = Ore.Name
        EmblemOwned.Parent = TemplateDataFolder.Emblems
    end

    for _, Pickaxe in pairs(PickaxesFolder:GetChildren()) do
        local PickaxeValue = Instance.new("BoolValue")
        PickaxeValue.Name = Pickaxe.Name
        PickaxeValue.Value = Pickaxe:GetAttribute("OwnedByDefault")
        PickaxeValue.Parent = TemplateDataFolder.Pickaxes.Owned

        local PickaxeUpgradeFolder = Instance.new("Folder")
        PickaxeUpgradeFolder.Name = Pickaxe.Name
        PickaxeUpgradeFolder.Parent = TemplateDataFolder.Pickaxes.Upgrades
    end

    LogService:Log("Setup template data folder")
end



--[[ PUBLIC ]]--

--[[
Create a data folder for a given player
]]--
function DataService:CreateDataFolderForPlayer(Player :Player) :Folder
    if self:PlayerHasDataFolder(Player) then return nil end
    local DataFolder = TemplateDataFolder:Clone()
    DataFolder.Name = Player.UserId
    DataFolder.Parent = RootDataFolder

    -- Move this into the load data function when that is made
    PickaxeService:GivePickaxeToPlayer(Player) 
    Player.CharacterAdded:Connect(function()
        PickaxeService:GivePickaxeToPlayer(Player) 
    end)

    LogService:Log("Created "..Player.Name.."'s data folder")
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
    LogService = Knit.GetService("LogService")

    SetupTemplateDataFolder()

    -- TEMP CODE:
    -- This will be removed when the main menu is added and save slots are added
    game.Players.PlayerAdded:Connect(function(Player)
        self:CreateDataFolderForPlayer(Player)
    end)
end

function DataService:KnitStart()
    PickaxeService = Knit.GetService("PickaxeService")
end

return DataService
