local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Core = require(ReplicatedStorage.Game.Modules.Core)

local StorageService = Knit.CreateService {
    Name = "StorageService";
    Client = {};
}

local LogService
local DataService

function StorageService:MoveOreToStorage(Player :Player, OreName :string, Amount :number) :boolean
    local DataFolder :Core.DataFolder = DataService:GetPlayerDataFolder(Player)
    local OreExists = Core.Util:GetOreByName(OreName)
    if not OreExists then return false end

    local InventoryDataValue = DataFolder.Inventory.Ores:FindFirstChild(OreName)
    if not InventoryDataValue then
        LogService:Warn("Couldnt find inventory data value for: "..tostring(OreName))
        return false
    end

    local StorageDataValue = DataFolder.Storage.Ores:FindFirstChild(OreName)
    if not StorageDataValue then
        LogService:Warn("Couldnt find storage data value for: "..tostring(OreName))
        return false
    end

    if InventoryDataValue.Value < Amount then
        LogService:Warn(Player.Name.." tried to move "..Amount.." "..OreName.." but not enough in inventory")
        return false
    end

    LogService:Log("Moved "..Amount.." "..OreName.." for player: "..Player.Name)
    InventoryDataValue.Value -= Amount
    StorageDataValue.Value += Amount
    return true
end



-- [[ CLIENT ]] --

function StorageService.Client:MoveToStorage(Player :Player, OreName :string, Amount :number) :boolean
    return self.Server:MoveOreToStorage(Player, OreName, Amount)
end



-- [[ KNIT ]] --

function StorageService:KnitStart()
    LogService = Knit.GetService("LogService")
    DataService = Knit.GetService("DataService")
end

return StorageService