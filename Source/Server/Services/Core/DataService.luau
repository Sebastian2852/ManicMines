local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Knit = require(ReplicatedStorage.Packages.Knit)

local DataService = Knit.CreateService({
	Name = "DataService",
	Client = {
		DataLoaded = Knit.CreateSignal(),
	},
})

local PickaxeService
local LogService
local TycoonService
local PlayerDisplayService
local PlayerStatsService
local LoadingService

local RootDataFolder: Folder = ReplicatedStorage.PlayerData
local TemplateDataFolder: Core.DataFolder = RootDataFolder:FindFirstChild("Template")

local OresFolder: Folder = ReplicatedStorage.Assets.Ores
local PickaxesFolder: Folder = ReplicatedStorage.Assets.Pickaxe.Pickaxes
local TycoonUpgradesFolder: Folder = ReplicatedStorage.Assets.Tycoon.Upgrades

--[[ PRIVATE ]]
--

--[=[
A list of all the data stores but as save slots so its easier to refrence in the code
]=]
DataService.SaveSlots = {
	Slot1 = DataStoreService:GetDataStore("SLOT1_Wipe1"),
	Slot2 = DataStoreService:GetDataStore("SLOT2_Wipe1"),
	Slot3 = DataStoreService:GetDataStore("SLOT3_Wipe1"),
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

	local StoneTimesMinedValue = Instance.new("IntValue")
	StoneTimesMinedValue.Name = "Stone"
	StoneTimesMinedValue.Parent = TemplateDataFolder.TimesMined

	local StoneEmblemOwned = Instance.new("BoolValue")
	StoneEmblemOwned.Name = "Stone"
	StoneEmblemOwned.Parent = TemplateDataFolder.Emblems

	for _, Ore: BasePart in pairs(OresFolder:GetChildren()) do
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

	for _, TycoonGenerator in pairs(Core.Assets.Tycoon.Generators:GetChildren()) do
		local GeneratorValue = Instance.new("IntValue")
		GeneratorValue.Name = TycoonGenerator.Name
		GeneratorValue.Value = 0
		GeneratorValue.Parent = TemplateDataFolder.Tycoon.Generators
	end

	for SettingName, DefaultValue in pairs(Core.GameConfig.DefaultSettings) do
		local TypeToMake = ""

		if type(DefaultValue) == "number" then
			TypeToMake = "NumberValue"
		elseif type(DefaultValue) == "string" then
			TypeToMake = "StringValue"
		elseif type(DefaultValue) == "boolean" then
			TypeToMake = "BoolValue"
		end

		local NewValue = Instance.new(TypeToMake)
		NewValue.Name = SettingName
		NewValue.Value = DefaultValue
		NewValue.Parent = TemplateDataFolder.Settings
	end

	TemplateDataFolder.LastVersionPlayed.Value = Core.GameConfig.MainMenu.Version
	TemplateDataFolder.VersionCreated.Value = Core.GameConfig.MainMenu.Version
	LogService:Log("Setup template data folder")
end

--[=[
Returns true/false if the given data store is a valid slot data store
]=]
local function IsSlotValid(Slot: DataStore): boolean
	for _, v: DataStore in pairs(DataService.SaveSlots) do
		if Slot == v then
			return true
		end
	end

	return false
end

local function GetPathFromRoot(Root: Folder, Value: Instance): string
	local Path = {}

	while Value do
		table.insert(Path, 1, Value.Name)
		if Value == Root then
			return table.concat(Path, ".")
		end
		Value = Value.Parent
	end

	return nil
end

local function GetInstanceFromPath(Root: Instance, Path: string): Instance
	local segments = string.split(Path, ".")

	local currentInstance = Root
	for _, segment in ipairs(segments) do
		if not currentInstance then
			return nil -- Path is invalid
		end
		currentInstance = currentInstance:FindFirstChild(segment)
	end

	return currentInstance
end

--[[ PUBLIC ]]
--

--[=[
Saves a player's data from a given slot (must be a slot in the data slots
table)
]=]
function DataService:SavePlayerData(Player: Player)
	local Slot = self.Players[Player.UserId]
	if not Slot then
		return
	end

	local DataFolder = self:GetPlayerDataFolder(Player)

	LogService:Assert(DataFolder, "Tried saving data with No data folder")
	LogService:Assert(IsSlotValid(Slot), "Invalid data slot passed")

	DataFolder.LastVersionPlayed.Value = Core.GameConfig.MainMenu.Version

	local SaveData = Core.Data.SaveData.New(Player.UserId)

	local GeneralData = {}
	GeneralData["LastPlayed"] = os.time()
	LogService:Log("Saved general data: LastPlayed ~ " .. tostring(os.time()))
	for _, Value: ValueBase in pairs(DataFolder:GetChildren()) do
		if not Value:IsA("ValueBase") then
			continue
		end
		GeneralData[Value.Name] = Value.Value
		LogService:Log("Saved general data: " .. Value.Name .. " - " .. tostring(Value.Value))
	end
	local General = Core.Data.Data.New("General", GeneralData)
	SaveData:AddData(General)

	for _, Folder: Folder in pairs(DataFolder:GetChildren()) do
		if not Folder:IsA("Folder") then
			continue
		end
		local Data = {}

		for _, Value: ValueBase in pairs(Folder:GetDescendants()) do
			if not Value:IsA("ValueBase") then
				continue
			end
			local Key = GetPathFromRoot(Folder, Value)
			Data[Key] = Value.Value
			LogService:Log("Saved data: " .. Key .. " - " .. tostring(Value.Value))
		end

		local DataToAdd = Core.Data.Data.New(Folder.Name, Data)
		SaveData:AddData(DataToAdd)
	end

	SaveData:Save(Slot)
end

--[=[
Loads a player's data from a given slot (must be a slot in the data slots
table)
]=]
function DataService:LoadPlayerData(Player: Player, Slot: DataStore)
	self.Players[Player.UserId] = Slot
	local DataFolder = self:GetPlayerDataFolder(Player)

	LogService:Assert(DataFolder, "Tried loading data with No data folder")
	LogService:Assert(IsSlotValid(Slot), "Invalid data slot passed")

	LoadingService:StartLoading(Player)
	LoadingService:UpdateActionText(Player, "Loading data")

	local SaveData = Core.Data.SaveData.New(Player.UserId)
	SaveData:AddData(Core.Data.Data.New("General", {}))

	for _, Folder: Folder in pairs(DataFolder:GetChildren()) do
		if not Folder:IsA("Folder") then
			continue
		end
		local DataToAdd = Core.Data.Data.New(Folder.Name, {})
		SaveData:AddData(DataToAdd)
	end

	SaveData:Load(Slot)

	local General = SaveData:GetDataByName("General")
	if type(General) == "table" then
		for ValueName: string, Data: any in pairs(General) do
			local Value = DataFolder:FindFirstChild(ValueName)
			if Value then
				Value.Value = Data
				LogService:Log("Loaded general data: " .. ValueName .. " - " .. tostring(Data))
			else
				LogService:Warn("Couldnt find value for: " .. ValueName .. "; discarding data")
			end
		end
	else
		LogService:Warn("No general data")
	end

	for _, Folder: Folder in pairs(DataFolder:GetChildren()) do
		if not Folder:IsA("Folder") then
			continue
		end
		local Data = SaveData:GetDataByName(Folder.Name)

		for Path: string, Value: any in pairs(Data) do
			local Instance = GetInstanceFromPath(DataFolder, Path)
			if Instance then
				Instance.Value = Value
				LogService:Log("Loaded data: " .. Path .. " - " .. tostring(Value))
			else
				LogService:Warn("Couldnt find value for: " .. Path .. "; discarding data")
			end
		end
	end

	LogService:Log("Tutorial Stage:", DataFolder.TutorialStage.Value)

	PlayerStatsService:CalculateInventoryCapacity(DataFolder)
	task.spawn(function()
		task.wait(1)

		LoadingService:UpdateActionText(Player, "Loading GUI")
		self.Client.DataLoaded:Fire(Player, DataFolder)
		PlayerDisplayService:GivePlayerOverheadGUI(Player)
		task.wait(1)

		LoadingService:UpdateActionText(Player, "Giving tools")
		PickaxeService:GivePickaxeToPlayer(Player)

		LoadingService:UpdateActionText(Player, "Creating tycoon")
		TycoonService:CreateTycoonForPlayer(Player)
		DataFolder.InTycoon.Value = true
		DataFolder.InMine.Value = false

		Player.CharacterAdded:Connect(function()
			PlayerDisplayService:GivePlayerOverheadGUI(Player)
			PickaxeService:GivePickaxeToPlayer(Player)
		end)

		task.wait(1)
		LoadingService:EndLoading(Player)
	end)

	DataFolder.Pickaxes.Equipped:GetPropertyChangedSignal("Value"):Connect(function()
		PickaxeService:GivePickaxeToPlayer(Player)
	end)

	DataFolder.DataLoaded.Value = true
end

--[=[
Create a data folder for a given player
]=]
function DataService:CreateDataFolderForPlayer(Player: Player): Core.DataFolder
	if self:PlayerHasDataFolder(Player) then
		return nil
	end
	local DataFolder = TemplateDataFolder:Clone()
	DataFolder.Name = Player.UserId
	DataFolder.Parent = RootDataFolder

	LogService:Log("Created " .. Player.Name .. "'s data folder")
	return DataFolder
end

--[=[
Deletes the given player's data folder
]=]
function DataService:DeleteDataFolder(Player: Player): Core.DataFolder
	if not self:PlayerHasDataFolder(Player) then
		return nil
	end
	local DataFolder = self:GetPlayerDataFolder(Player)
	DataFolder:Destroy()

	LogService:Log("Deleted " .. Player.Name .. "'s data folder")
	return DataFolder
end

--[=[
Returns the player's data folder if they have one
]=]
function DataService:GetPlayerDataFolder(Player: Player): Core.DataFolder
	local FoundDataFolder = RootDataFolder:FindFirstChild(tostring(Player.UserId))
	return FoundDataFolder
end

--[=[
Returns true/false if the the player has a data folder
]=]
function DataService:PlayerHasDataFolder(Player: Player): boolean
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
function DataService:GetSlotInfo(Player: Player, Slot: DataStore): Core.SlotInfo
	local Info: Core.SlotInfo = {
		SlotID = self:SlotDataStoreToNumber(Slot),
		Used = false,
	}

	local SaveData = Core.Data.SaveData.New(Player.UserId)
	local Data = Core.Data.Data.New("General", {})
	SaveData:AddData(Data)
	SaveData:Load(Slot)
	local General = SaveData:GetDataByName("General")

	if type(General) == "table" and General.LastPlayed ~= nil and General.LastPlayed ~= 0 then
		Info.Used = true
		Info.TycoonName = General.TycoonName
		Info.Gold = General.Gold
		Info.LastPlayed = General.LastPlayed
	end

	return Info
end

--[=[
Turns a number into a data store from the save slots table, returns slot 1 data
store if an invalid number is given
]=]
function DataService:SlotNumberToDataStore(SlotNumber: number): DataStore
	LogService:Assert(
		type(SlotNumber) == "number",
		"'" .. type(SlotNumber) .. "' passed for 'SlotNumber', expected 'number'"
	)
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
function DataService:SlotDataStoreToNumber(Slot: DataStore): number
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
function DataService:NewSlot(Player: Player, SlotNumber: number, SlotSettings: Core.SaveSlotSettings)
	local AsDataStore = DataService:SlotNumberToDataStore(SlotNumber)
	if not IsSlotValid(AsDataStore) then
		return
	end

	if SlotSettings == nil then
		Player:Kick("Invalid slot settings; nil \nThis is a bug, report this to the developers!")
	end

	if SlotSettings.Name == nil then
		Player:Kick("Invalid slot settings; Name nil \nThis is a bug, report this to the developers!")
	end

	local PlayerData = RootDataFolder:WaitForChild(tostring(Player.UserId))
	PlayerData.TycoonName.Value = SlotSettings.Name or "[INVALID SLOT DATA]"
	PlayerData.TutorialStage.Value = SlotSettings.Tutorial == true and 0 or -2

	self.Players[Player.UserId] = AsDataStore
	LoadingService:StartLoading(Player)
	LoadingService:UpdateActionText(Player, "Creating slot")
	DataService:SavePlayerData(Player)
	DataService:LoadPlayerData(Player, AsDataStore)
end

--[=[
Deletes all data in a the given slot for the given player
]=]
function DataService:DeleteSlot(Player: Player, SlotNumber: number)
	local AsDataStore = DataService:SlotNumberToDataStore(SlotNumber)
	if not IsSlotValid(AsDataStore) then
		return
	end

	LogService:Log("Deleting slot " .. tostring(SlotNumber) .. " for " .. Player.Name)

	local SaveData = Core.Data.SaveData.New(Player.UserId)
	local Data = Core.Data.Data.New("General", {})
	SaveData:AddData(Data)
	SaveData:Save(AsDataStore)

	LogService:Log("Deleted slot " .. tostring(SlotNumber) .. " for " .. Player.Name)
end

--[=[
	Check if the player has enough of a single ore
]=]
function DataService:CanAffordOre(Player: Player, Ore: Core.OreListItem): boolean
	local DataFolder = self:GetPlayerDataFolder(Player)

	if Ore.Name == "GoldCoins" then
		local Amount = DataFolder.Gold.Value
		return Amount >= Ore.Amount
	end

	local InventoryDataValue = DataFolder.Inventory.Ores:FindFirstChild(Ore.Name) :: IntValue
	local StorageDataValue = DataFolder.Storage.Ores:FindFirstChild(Ore.Name) :: IntValue

	local Amount = InventoryDataValue.Value + StorageDataValue.Value

	return Amount >= Ore.Amount
end

--[=[
Returns true/false depending on if the given player can afford the given orelist
]=]
function DataService:CanAfford(Player: Player, Ores: Core.OreList): boolean
	for _, Ore in pairs(Ores:LoopList()) do
		local HasEnough = self:CanAffordOre(Player, Ore)
		if not HasEnough then
			return false
		end
	end
	return true
end

--[=[
Handles the given costs for the given player. Returns true/false for success
]=]
function DataService:HandleCosts(Player: Player, CostList: Core.OreList): boolean
	if not self:CanAfford(Player, CostList) then
		return false
	end
	PlayerStatsService:TakeOres(Player, CostList)
	return true
end

--[[ CLIENT ]]
--

function DataService.Client:CanAfford(Player, CostList)
	return self.Server:CanAfford(Player, CostList)
end

function DataService.Client:HandleCosts(Player, CostList)
	return self.Server:HandleCosts(Player, CostList)
end

function DataService.Client:GetSlotsInfo(Player: Player)
	local Info = {}

	table.insert(Info, DataService:GetSlotInfo(Player, DataService.SaveSlots.Slot1))
	table.insert(Info, DataService:GetSlotInfo(Player, DataService.SaveSlots.Slot2))
	table.insert(Info, DataService:GetSlotInfo(Player, DataService.SaveSlots.Slot3))

	return Info
end

function DataService.Client:LoadData(Player: Player, SlotID: number)
	local SlotToLoad = DataService:SlotNumberToDataStore(SlotID)
	DataService:LoadPlayerData(Player, SlotToLoad)
end

function DataService.Client:NewSlot(Player: Player, SlotNumber: number, SlotSettings: Core.SaveSlotSettings)
	DataService:NewSlot(Player, SlotNumber, SlotSettings)
end

function DataService.Client:DeleteSlot(Player: Player, SlotNumber: number)
	DataService:DeleteSlot(Player, SlotNumber)
end

function DataService.Client:GetPlayerDataFolder(Player: Player): Core.DataFolder
	local FoundDataFolder = RootDataFolder:FindFirstChild(tostring(Player.UserId))
	if not FoundDataFolder then
		repeat
			FoundDataFolder = RootDataFolder:FindFirstChild(tostring(Player.UserId))
			task.wait(0.1)
		until FoundDataFolder
	end
	return FoundDataFolder
end

function DataService.Client:PlayerHasDataFolder(Player: Player): boolean
	local FoundDataFolder = RootDataFolder:FindFirstChild(tostring(Player.UserId))
	if FoundDataFolder then
		return true
	end

	return false
end

function DataService.Client:GetOtherPlayerStats(_, Player: Player)
	return self:GetPlayerDataFolder(Player)
end

function DataService.Client:AdvanceTutorialStage(Player: Player)
	local DataFolder = self:GetPlayerDataFolder(Player)
	DataFolder.TutorialStage.Value += 1
end

--[[ KNIT ]]
--

function DataService:KnitInit()
	LogService = Knit.GetService("LogService")
	SetupTemplateDataFolder()
end

function DataService:KnitStart()
	PickaxeService = Knit.GetService("PickaxeService")
	TycoonService = Knit.GetService("TycoonService")
	PlayerDisplayService = Knit.GetService("PlayerDisplayService")
	PlayerStatsService = Knit.GetService("PlayerStatsService")
	LoadingService = Knit.GetService("LoadingService")

	local PlayersLeft = 0

	game.Players.PlayerAdded:Connect(function(Player)
		PlayersLeft += 1
		self:CreateDataFolderForPlayer(Player)
	end)

	game.Players.PlayerRemoving:Connect(function(Player)
		PlayersLeft -= 1
		self:SavePlayerData(Player)
		self:DeleteDataFolder(Player)
		self.Players[Player.UserId] = nil
		TycoonService:DeletePlayerTycoon(Player)
	end)

	game:BindToClose(function(CloseReason: Enum.CloseReason)
		LogService:Warn("Closing server, Reason: " .. CloseReason.Name)
		LogService:Log("Waiting for data to be saved")
		while PlayersLeft > 0 do
			task.wait(10)
		end
		LogService:Log("Data saved; closing server")
	end)
end

return DataService
