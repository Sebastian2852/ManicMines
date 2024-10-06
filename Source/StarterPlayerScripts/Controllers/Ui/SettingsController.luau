local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game.ReplicatedStorage

local Knit = require(ReplicatedStorage.Packages.Knit)
local Core = require(ReplicatedStorage.Game.Modules.Core)

local SettingsController = Knit.CreateController { Name = "PlayerSettingsController" }

local Player = Knit.Player
local PlayerGUI = Player.PlayerGui

local LogService
local SettingsService
local DataService

local HudGUI = PlayerGUI:WaitForChild("HUD")
local Settings :Core.Settings = {}

--[[ PRIVATE ]]--

--[=[
Pushes the current settings to the server
]=]
local function PushToServer()
    LogService:Log("Pushing settings to server")
    SettingsService:PushSettings(Settings)
end


--[=[
Updates the settings by actually doing the settings (e.g. Disabling shadows)
Only does things that can be done by the client. The rest will be handled by the server
]=]
local function Update()
    LogService:Log("Updating settings")
    game.Lighting.GlobalShadows = Settings.GlobalShadows
end

--[[
!!!This is only here to test the settings!!!
]]
UserInputService.InputBegan:Connect(function(Input, Processed)
    if Processed then return end
    if Input.KeyCode == Enum.KeyCode.Z then 
        Settings.GlobalShadows = not Settings.GlobalShadows
        Settings.RainbowEffect = not Settings.RainbowEffect
        Update()
        PushToServer()
    end
end)



--[[ KNIT ]]--

function SettingsController:KnitStart()
    LogService = Knit.GetService("LogService")
    SettingsService = Knit.GetService("SettingsService")
    DataService = Knit.GetService("DataService")

    DataService:GetPlayerDataFolder():andThen(function(PlayerData :Core.DataFolder)
        for _, SettingValue :ValueBase in pairs(PlayerData.Settings:GetChildren()) do
            Settings[SettingValue.Name] = SettingValue.Value

            SettingValue:GetPropertyChangedSignal("Value"):Connect(function()
                Settings[SettingValue.Name] = SettingValue.Value
                Update()
            end)
        end

        Update()
    end)
end

return SettingsController