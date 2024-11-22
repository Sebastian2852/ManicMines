local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Core = require(ReplicatedStorage.Game.Modules.Core)

local SettingsService = Knit.CreateService {
    Name = "SettingsService",
    Client = {
        UpdateSettings = Knit.CreateSignal();
        SettingsChanged = Knit.CreateSignal();
    },
}

local DataService
local LogService

--[[ PRIVATE ]]--

--[=[
Updates the given player's settings in their data folder with the given settings
]=]
local function UpdateSettings(Player :Player, Settings :Core.Settings)
    LogService:Log("Updating", Player.Name.."'s", "settings")
    local PlayerData = DataService:GetPlayerDataFolder(Player)

    for SettingName, SettingValue in pairs(Settings) do
        PlayerData.Settings[SettingName].Value = SettingValue
    end
end



--[[ PUBLIC ]]--

function SettingsService:ResetPlayerSettings(Player :Player)
    LogService:Log("Resetting player's settings to default")
    UpdateSettings(Player, Core.GameConfig.DefaultSettings)
    self.Client.SettingsChanged:Fire(Player)
end


-- [[ CLIENT ]] --

function SettingsService.Client:PushSettings(Player :Player, NewSettings :Core.Settings)
    UpdateSettings(Player, NewSettings)
    self.SettingsChanged:Fire(Player)
end



--[[ KNIT ]]--

function SettingsService:KnitStart()
    DataService = Knit.GetService("DataService")
    LogService = Knit.GetService("LogService")
end

return SettingsService
