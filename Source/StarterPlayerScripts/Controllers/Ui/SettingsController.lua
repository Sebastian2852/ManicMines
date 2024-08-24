local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game.ReplicatedStorage

local Knit = require(ReplicatedStorage.Packages.Knit)

local SettingsController = Knit.CreateController { Name = "PlayerSettingsController" }

--[[ VARIABLES ]]--

local Player = Knit.Player
local PlayerGUI = Player.PlayerGui

local LogService
local SettingsService

local HudGUI = PlayerGUI:WaitForChild("HUD")
--local SettingsButton = HudGUI:WaitForChild("Settings")

local Settings = {
    GlobalShadows = true
}



--[[ INTERNAL ]]--

--[=[
Pushes the current settings to the server
]=]
local function PushToServer()
    LogService:Log("Pushing settings to server")
    SettingsService.UpdateSettings:Fire(Settings)
end

--[=[
Updates the settings by actually doing the settings (e.g. Disabling shadows)
Only does things that can be done by the client. The rest will be handled by the server
]=]
local function Update()
    LogService:Log("Updating settings")
    PushToServer()
    game.Lighting.GlobalShadows = Settings.GlobalShadows
end

--[[
!!!This is only here to test the settings!!!
]]
UserInputService.InputBegan:Connect(function(Input, Processed)
    if Processed then return end
    if Input.KeyCode == Enum.KeyCode.Z then 
        Settings.GlobalShadows = not Settings.GlobalShadows
        Update()
    end
end)

--[[ KNIT ]]--

function SettingsController:KnitStart()
    LogService = Knit.GetService("LogService")
    SettingsService = Knit.GetService("SettingsService")
end

return SettingsController