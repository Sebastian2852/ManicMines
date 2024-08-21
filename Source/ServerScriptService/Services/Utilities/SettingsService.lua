local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Types = require(ReplicatedStorage.Game.Modules.Types)

local SettingsService = Knit.CreateService {
    Name = "SettingsService",
    Client = {
        UpdateSettings = Knit.CreateSignal();
    },
}

--[[ VARIABLES ]]--

local DataService



--[[ INTERNAL ]]--

--[=[
Updates the given player's settings in their data folder with the given settings
]=]
local function UpdateSettings(Player :Player, Settings :Types.Settings)
    local PlayerData = DataService:GetPlayerDataFolder(Player)

    for SettingName, SettingValue in pairs(Settings) do
        PlayerData.Settings[SettingName].Value = SettingValue
    end
end



--[[ KNIT ]]--

function SettingsService:KnitStart()
    DataService = Knit.GetService("DataService")

    self.Client.UpdateSettings:Connect(function(Player :Player, NewSettings :Types.Settings)
        UpdateSettings(Player, NewSettings)
    end)
end

return SettingsService
