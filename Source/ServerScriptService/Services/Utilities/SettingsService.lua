local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Types = require(ReplicatedStorage.Game.Modules.Types)
local GameConfig = require(ReplicatedStorage.Game.Modules.GameConfig)

local SettingsService = Knit.CreateService {
    Name = "SettingsService",
    Client = {
        UpdateSettings = Knit.CreateSignal();
    },
}

--[[ VARIABLES ]]--

local DataService
local LogService



--[[ INTERNAL ]]--

--[=[
Updates the given player's settings in their data folder with the given settings
]=]
local function UpdateSettings(Player :Player, Settings :Types.Settings)
    LogService:Log("Updating", Player.Name.."'s", "settings")
    local PlayerData = DataService:GetPlayerDataFolder(Player)

    for SettingName, SettingValue in pairs(Settings) do
        PlayerData.Settings[SettingName].Value = SettingValue
    end
end



--[[ PUBLIC ]]--

function SettingsService:ResetPlayerSettings(Player :Player)
    LogService:Log("Resetting player's settings to default")
    UpdateSettings(Player, GameConfig.DefaultSettings)
end

--[[ KNIT ]]--

function SettingsService:KnitStart()
    DataService = Knit.GetService("DataService")
    LogService = Knit.GetService("LogService")

    self.Client.UpdateSettings:Connect(function(Player :Player, NewSettings :Types.Settings)
        UpdateSettings(Player, NewSettings)
    end)
end

return SettingsService
