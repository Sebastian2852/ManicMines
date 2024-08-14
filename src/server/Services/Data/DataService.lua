local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
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

--[=[
A list of all the data stores but as save slots so its easier to refrence in the code
]=]
DataService.SaveSlots = {
    Slot1 = DataStoreService:GetDataStore("SLOT1");
    Slot2 = DataStoreService:GetDataStore("SLOT2");
    Slot3 = DataStoreService:GetDataStore("SLOT3");
}

--[=[
Create all values in the template data folder so that it can be cloned for each player
and it be fully ready for data loading straight away
]=]
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

--[=[
Returns true/false if the given data store is a valid slot data store
]=]
local function IsSlotValid(Slot :DataStore) :boolean
    for _, v :DataStore in pairs(DataService.SaveSlots) do
        if Slot == v then return true end
    end

    return false
end



--[[ PUBLIC ]]--

--[=[
Saves a player's data from a given slot (must be a slot in the data slots
table)
]=]
function DataService:SavePlayerData(Player :Player, Slot :DataStore)
    local DataFolder = self:GetPlayerDataFolder(Player)

    LogService:Assert(DataFolder, "Tried loading data with No data folder")
    LogService:Assert(IsSlotValid(Slot), "Invalid data slot passed")

    local PlayerDataKey = Player.UserId.."-PlayerData"
    local TycoonDataKey = Player.UserId.."-TycoonData"
    local OreDataKey = Player.UserId.."-OreData"

    LogService:Log("["..Player.Name.."]", "Packaging ore data")
    local RawOreData = {}

    for _, Ore :IntValue in pairs(DataFolder.Inventory.Ores:GetChildren()) do
        RawOreData[Ore.Name] = {}
        RawOreData[Ore.Name].InventoryAmount = Ore.Value
        RawOreData[Ore.Name].StorageAmount = 0
        RawOreData[Ore.Name].TimesMined = 0
    end

    for _, Ore :IntValue in pairs(DataFolder.Storage.Ores:GetChildren()) do
        RawOreData[Ore.Name].StorageAmount = Ore.Value
    end

    for _, Ore :IntValue in pairs(DataFolder.TimesMined:GetChildren()) do
        RawOreData[Ore.Name].TimesMined = Ore.Value
    end

    LogService:Log("["..Player.Name.."]", "Packaging player data")
    local RawPlayerData = {}

    RawPlayerData.XP = DataFolder.XP.Value
    RawPlayerData.Level = DataFolder.Level.Value
    RawPlayerData.Gold = DataFolder.Gold.Value
    RawPlayerData.LastPlayed = os.time()

    LogService:Log("["..Player.Name.."]", "Packaging tycoon data")
    local RawTycoonData = {}

    RawTycoonData.Name = DataFolder.Tycoon.TycoonName.Value
    RawTycoonData.Upgrades = {}

    local EncodedOreData :string = HttpService:JSONEncode(RawOreData)
    local EncodedPlayerData :string = HttpService:JSONEncode(RawPlayerData)
    local EncodedTycoonData :string = HttpService:JSONEncode(RawTycoonData)

    local Success, ErrorMessage = pcall(function()
        Slot:SetAsync(PlayerDataKey, EncodedPlayerData)
        Slot:SetAsync(TycoonDataKey, EncodedTycoonData)
        Slot:SetAsync(OreDataKey, EncodedOreData)
    end)

    LogService:Assert(Success, ErrorMessage)
    LogService:Log("["..Player.Name.."]", "Saved player data!")
end

--[=[
Loads a player's data from a given slot (must be a slot in the data slots
table)
]=]
function DataService:LoadPlayerData(Player :Player, Slot :DataStore)
    local DataFolder = self:GetPlayerDataFolder(Player)

    LogService:Assert(DataFolder, "Tried loading data with No data folder")
    LogService:Assert(IsSlotValid(Slot), "Invalid data slot passed")

    local PlayerDataKey = Player.UserId.."-PlayerData"
    local TycoonDataKey = Player.UserId.."-TycoonData"
    local OreDataKey = Player.UserId.."-OreData"

    local RawPlayerData
    local RawTycoonData
    local RawOreData

    local Success, ErrorMessage = pcall(function()
        RawPlayerData = Slot:GetAsync(PlayerDataKey)
        RawTycoonData = Slot:GetAsync(TycoonDataKey)
        RawOreData = Slot:GetAsync(OreDataKey)

        if RawPlayerData ~= nil then
            RawPlayerData = HttpService:JSONDecode(RawPlayerData)
        end

        if RawTycoonData ~= nil then
            RawTycoonData = HttpService:JSONDecode(RawTycoonData)
        end

        if RawOreData ~= nil then
            RawOreData = HttpService:JSONDecode(RawOreData)
        end
    end)

    LogService:Assert(Success, ErrorMessage)

    DataFolder.XP.Value = RawPlayerData.XP
    DataFolder.Level.Value = RawPlayerData.Level
    DataFolder.Gold.Value = RawPlayerData.Gold
end

--[=[
Create a data folder for a given player
]=]
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

--[=[
Returns the player's data folder if they have one
]=]
function DataService:GetPlayerDataFolder(Player :Player) :Folder?
    local FoundDataFolder = RootDataFolder:FindFirstChild(tostring(Player.UserId))
    return FoundDataFolder
end

--[=[
Returns true/false if the the player has a data folder
]=]
function DataService:PlayerHasDataFolder(Player :Player) :boolean
    local FoundDataFolder = RootDataFolder:FindFirstChild(tostring(Player.UserId))
    if FoundDataFolder then
        return true
    end

    return false
end

function DataService:GetSlotInfo(Player :Player, Slot :DataStore) :{any}
    local Info = {
        SlotID = self:SlotDataStoreToNumber(Slot);
        Used = false;
    }

    local PlayerDataKey = Player.UserId.."-PlayerData"
    local TycoonDataKey = Player.UserId.."-TycoonData"

    local RawPlayerData
    local RawTycoonData

    local Success, ErrorMessage = pcall(function()
        RawPlayerData = Slot:GetAsync(PlayerDataKey)
        RawTycoonData = Slot:GetAsync(TycoonDataKey)

        if RawPlayerData ~= nil then
            RawPlayerData = HttpService:JSONDecode(RawPlayerData)
        end

        if RawTycoonData ~= nil then
            RawTycoonData = HttpService:JSONDecode(RawTycoonData)
        end
    end)

    LogService:Assert(Success, ErrorMessage)

    if RawPlayerData == nil or RawTycoonData == nil then
        return Info
    end

    Info.Used = true
    Info.TycoonName = RawTycoonData.Name
    Info.Gold = RawPlayerData.Gold
    Info.LastPlayed = RawPlayerData.LastPlayed

    return Info
end

--[=[
Turns a number into a data store from the save slots table, returns slot 1 data
store if an invalid number is given
]=]
function DataService:SlotNumberToDataStore(SlotNumber :number) :DataStore
    if SlotNumber == 1 then
        return DataService.SaveSlots.Slot1
    elseif SlotNumber == 2 then
        return DataService.SaveSlots.Slot2
    elseif SlotNumber == 3 then
        return DataService.SaveSlots.Slot3
    end

    return DataService.SaveSlots.Slot1
end

--[=[
Turns a save slot data store into a number, returns `1` if an invalid data store is given
]=]
function DataService:SlotDataStoreToNumber(Slot :DataStore) :DataStore
    if Slot == self.SaveSlots.Slot1 then
        return 1
    elseif Slot == self.SaveSlots.Slot2 then
        return 2
    elseif Slot == self.SaveSlots.Slot3 then
        return 3
    end

    return 1
end



--[[ CLIENT ]]--

function DataService.Client:GetSlotsInfo(Player :Player)
    local Info = {}

    table.insert(Info, DataService:GetSlotInfo(Player, DataService.SaveSlots.Slot1))
    table.insert(Info, DataService:GetSlotInfo(Player, DataService.SaveSlots.Slot2))
    table.insert(Info, DataService:GetSlotInfo(Player, DataService.SaveSlots.Slot3))

    return Info
end



--[[ KNIT ]]--

--[=[
Setup the template data folder to have every single value so that when it is
cloned for a player it already has every value the player needs ready. This should
make it so data loading is much faster than before.
]=]
function DataService:KnitInit()
    LogService = Knit.GetService("LogService")

    SetupTemplateDataFolder()

    -- TEMP CODE:
    -- This will be removed when the main menu is added and save slots are added
    game.Players.PlayerAdded:Connect(function(Player)
        self:CreateDataFolderForPlayer(Player)
        self:LoadPlayerData(Player, self.SaveSlots.Slot1)
    end)

    game.Players.PlayerRemoving:Connect(function(Player)
        self:SavePlayerData(Player, self.SaveSlots.Slot1)
    end)
end

function DataService:KnitStart()
    PickaxeService = Knit.GetService("PickaxeService")
end

return DataService
