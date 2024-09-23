local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Knit = require(game.ReplicatedStorage.Packages.Knit)
local Core = require(ReplicatedStorage.Game.Modules.Core)

local RootDataFolder :Folder = game.ReplicatedStorage.PlayerData
local TemplateDataFolder :Core.DataFolder = RootDataFolder:FindFirstChild("Template")

local OresFolder :Folder = ReplicatedStorage.Assets.Ores
local PickaxesFolder :Folder = ReplicatedStorage.Assets.Pickaxe.Pickaxes
local TycoonUpgradesFolder :Folder = ReplicatedStorage.Assets.Tycoon.Upgrades

local PickaxeService
local LogService
local TycoonService
local PlayerDisplayService

local DataService = Knit.CreateService {
    Name = "DataService",
    Client = {},
}

--[[ PRIVATE ]]--

--[=[
A list of all the data stores but as save slots so its easier to refrence in the code
]=]
DataService.SaveSlots = {
    Slot1 = DataStoreService:GetDataStore("SLOT1");
    Slot2 = DataStoreService:GetDataStore("SLOT2");
    Slot3 = DataStoreService:GetDataStore("SLOT3");
}

DataService.Players = {}

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

    for _, TycoonUpgrade in pairs(TycoonUpgradesFolder:GetChildren()) do
        local UpgradeValue = Instance.new("IntValue")
        UpgradeValue.Name = TycoonUpgrade.Name
        UpgradeValue.Value = 0
        UpgradeValue.Parent = TemplateDataFolder.Tycoon.Upgrades
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

--[=[
Checks wether a data table is valid
]=]
local function IsRawDataValid(Data :{any}) :boolean
    if Data == nil then return false end
    if Data == {} then return false end

    return true
end

--[=[
Checks if a JSON encoded save data table is valid
]=]
local function IsSavedDataValid(Data :string) :boolean
    if Data == nil then return false end
    if Data == "{}" then return false end

    return true
end


--[[ PUBLIC ]]--

--[=[
Saves a player's data from a given slot (must be a slot in the data slots
table)
]=]
function DataService:SavePlayerData(Player :Player)
    local Slot = self.Players[Player.UserId]
    if not Slot then return end

    local DataFolder = self:GetPlayerDataFolder(Player)

    LogService:Assert(DataFolder, "Tried saving data with No data folder")
    LogService:Assert(IsSlotValid(Slot), "Invalid data slot passed")

    local SaveData = Core.Data.SaveData.New(Player.UserId)

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
    local OreData = Core.Data.Data.New("Ore", RawOreData)



    LogService:Log("["..Player.Name.."]", "Packaging player data")
    local RawPlayerData = {}
    RawPlayerData.XP = DataFolder.XP.Value
    RawPlayerData.Level = DataFolder.Level.Value
    RawPlayerData.Gold = DataFolder.Gold.Value
    RawPlayerData.LastPlayed = os.time()
    local PlayerData = Core.Data.Data.New("PlayerData", RawPlayerData)



    LogService:Log("["..Player.Name.."]", "Packaging tycoon data")
    local RawTycoonData = {}
    RawTycoonData.Name = DataFolder.Tycoon.TycoonName.Value
    RawTycoonData.Upgrades = {}
    local TycoonData = Core.Data.Data.New("Tycoon", RawTycoonData)

    SaveData:AddData(OreData)
    SaveData:AddData(PlayerData)
    SaveData:AddData(TycoonData)

    SaveData:Save(Slot)

    LogService:Log("["..Player.Name.."]", "Saved player data!")
end

--[=[
Loads a player's data from a given slot (must be a slot in the data slots
table)
]=]
function DataService:LoadPlayerData(Player :Player, Slot :DataStore)
    self.Players[Player.UserId] = Slot
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

    if IsRawDataValid(RawPlayerData) then
        DataFolder.XP.Value = RawPlayerData.XP
        DataFolder.Level.Value = RawPlayerData.Level
        DataFolder.Gold.Value = RawPlayerData.Gold
    else return end

    if IsRawDataValid(RawTycoonData) then
        DataFolder.Tycoon.TycoonName.Value = RawTycoonData.Name
    else return end

    if IsRawDataValid(RawOreData) then
        for OreName, OreData in pairs(RawOreData) do
            local InventoryAmount = OreData["InventoryAmount"]
            local StorageAmount = OreData["StorageAmount"]
            local TimesMined = OreData["TimesMined"]

            local InventoryOre = DataFolder.Inventory.Ores:FindFirstChild(OreName)
            local StorageOre = DataFolder.Storage.Ores:FindFirstChild(OreName)
            local TimesMinedOre = DataFolder.TimesMined:FindFirstChild(OreName)

            if InventoryOre then
                InventoryOre.Value = InventoryAmount
            else
                LogService:Warn("Discarding data for ore", OreName, "; No longer exists")
            end

            if StorageOre then
                StorageOre.Value = StorageAmount
            else
                LogService:Warn("Discarding data for ore", OreName, "; No longer exists")
            end

            if TimesMinedOre then
                TimesMinedOre.Value = TimesMined
            else
                LogService:Warn("Discarding data for ore", OreName, "; No longer exists")
            end
        end
    else return end

    PlayerDisplayService:GivePlayerOverheadGUI(Player)
    PickaxeService:GivePickaxeToPlayer(Player)
    TycoonService:CreateTycoonForPlayer(Player)
    Player.CharacterAdded:Connect(function()
        PlayerDisplayService:GivePlayerOverheadGUI(Player)
        PickaxeService:GivePickaxeToPlayer(Player)
    end)

    DataFolder.DataLoaded.Value = true
end

--[=[
Create a data folder for a given player
]=]
function DataService:CreateDataFolderForPlayer(Player :Player) :Core.DataFolder
    if self:PlayerHasDataFolder(Player) then return nil end
    local DataFolder = TemplateDataFolder:Clone()
    DataFolder.Name = Player.UserId
    DataFolder.Parent = RootDataFolder

    LogService:Log("Created "..Player.Name.."'s data folder")
    return DataFolder
end

--[=[
Returns the player's data folder if they have one
]=]
function DataService:GetPlayerDataFolder(Player :Player) :Core.DataFolder?
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

--[=[
Returns the information for a given slot for a player:
- SlotID
- Used
- Gold
- Tycoon Name
- Last Played
]=]
function DataService:GetSlotInfo(Player :Player, Slot :DataStore) :Core.SlotInfo
    local Info :Core.SlotInfo = {
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

    if RawPlayerData == nil or RawPlayerData == {} or RawTycoonData == nil or RawTycoonData == {} then
        return Info
    end

    if RawTycoonData.Name == nil then
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
    LogService:Assert(type(SlotNumber) == "number", "'"..type(SlotNumber).."' passed for 'SlotNumber', expected 'number'")
    if SlotNumber == 1 then
        return DataService.SaveSlots.Slot1
    elseif SlotNumber == 2 then
        return DataService.SaveSlots.Slot2
    elseif SlotNumber == 3 then
        return DataService.SaveSlots.Slot3
    end

    LogService:Warn("Invalid slot number", SlotNumber)
    return DataService.SaveSlots.Slot1
end

--[=[
Turns a save slot data store into a number, returns `1` if an invalid data store is given
]=]
function DataService:SlotDataStoreToNumber(Slot :DataStore) :number
    if Slot == self.SaveSlots.Slot1 then
        return 1
    elseif Slot == self.SaveSlots.Slot2 then
        return 2
    elseif Slot == self.SaveSlots.Slot3 then
        return 3
    end

    LogService:Warn("Invalid slot data store", Slot)
    return 1
end

--[=[
Creates a new slot in the given slot number for a player
]=]
function DataService:NewSlot(Player :Player, SlotNumber :number, SlotSettings :Core.SaveSlotSettings)
    local AsDataStore = DataService:SlotNumberToDataStore(SlotNumber)
    if not IsSlotValid(AsDataStore) then return end

    local PlayerData = DataService:GetPlayerDataFolder(Player)
    PlayerData.Tycoon.TycoonName.Value = SlotSettings.Name

    self.Players[Player.UserId] = AsDataStore
    DataService:SavePlayerData(Player)
    DataService:LoadPlayerData(Player, AsDataStore)
end

--[=[
Deletes all data in a the given slot for the given player
]=]
function DataService:DeleteSlot(Player :Player, SlotNumber :number)
    local AsDataStore = DataService:SlotNumberToDataStore(SlotNumber)
    if not IsSlotValid(AsDataStore) then return end

    LogService:Log("Deleting slot "..tostring(SlotNumber).." for "..Player.Name)
    local PlayerDataKey = Player.UserId.."-PlayerData"
    local TycoonDataKey = Player.UserId.."-TycoonData"
    local OreDataKey = Player.UserId.."-OreData"

    local Data = "{}"

    local Success, ErrorMessage = pcall(function()
        AsDataStore:SetAsync(PlayerDataKey, Data)
        AsDataStore:SetAsync(TycoonDataKey, Data)
        AsDataStore:SetAsync(OreDataKey, Data)
    end)

    LogService:Assert(Success, ErrorMessage)

    LogService:Log("Deleted slot "..tostring(SlotNumber).." for "..Player.Name)
end



--[[ CLIENT ]]--

function DataService.Client:GetSlotsInfo(Player :Player)
    local Info = {}

    table.insert(Info, DataService:GetSlotInfo(Player, DataService.SaveSlots.Slot1))
    table.insert(Info, DataService:GetSlotInfo(Player, DataService.SaveSlots.Slot2))
    table.insert(Info, DataService:GetSlotInfo(Player, DataService.SaveSlots.Slot3))

    return Info
end

function DataService.Client:LoadData(Player :Player, SlotID :number)
    local SlotToLoad = DataService:SlotNumberToDataStore(SlotID)
    DataService:LoadPlayerData(Player, SlotToLoad)
end

function DataService.Client:NewSlot(Player :Player, SlotNumber :number, SlotSettings :Core.SaveSlotSettings)
    DataService:NewSlot(Player, SlotNumber, SlotSettings)
end

function DataService.Client:DeleteSlot(Player :Player, SlotNumber :number)
    DataService:DeleteSlot(Player, SlotNumber)
end

function DataService.Client:GetPlayerDataFolder(Player :Player) :Core.DataFolder
    local FoundDataFolder = RootDataFolder:FindFirstChild(tostring(Player.UserId))
    if not FoundDataFolder then
        repeat
            FoundDataFolder = RootDataFolder:FindFirstChild(tostring(Player.UserId))
            task.wait(0.1)
        until FoundDataFolder
    end
    return FoundDataFolder
end

function DataService.Client:PlayerHasDataFolder(Player :Player) :boolean
    local FoundDataFolder = RootDataFolder:FindFirstChild(tostring(Player.UserId))
    if FoundDataFolder then
        return true
    end

    return false
end



--[[ KNIT ]]--

function DataService:KnitInit()
    LogService = Knit.GetService("LogService")
    SetupTemplateDataFolder()
end

function DataService:KnitStart()
    PickaxeService = Knit.GetService("PickaxeService")
    TycoonService = Knit.GetService("TycoonService")
    PlayerDisplayService = Knit.GetService("PlayerDisplayService")

    game.Players.PlayerAdded:Connect(function(Player)
        self:CreateDataFolderForPlayer(Player)
    end)

    game.Players.PlayerRemoving:Connect(function(Player)
        self:SavePlayerData(Player)
        self.Players[Player.UserId] = nil
    end)
end

return DataService