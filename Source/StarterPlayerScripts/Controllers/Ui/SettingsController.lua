local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game.ReplicatedStorage

local Knit = require(ReplicatedStorage.Packages.Knit)

local SettingsController = Knit.CreateController { Name = "PlayerSettingsController" }

--[[ VARIABLES ]]--

local Player = Knit.Player
local PlayerGUI = Player.PlayerGui

local LogService

local HudGUI = PlayerGUI:WaitForChild("HUD")
local SettingsButton = HudGUI:WaitForChild("Settings")

local Settings = {
    GlobalShadows = true
}



--[[ INTERNAL ]]--

local function PushToServer()
    LogService:Log("Pushing settings to server")
end

local function Update()
    LogService:Log("Updating settings")
    PushToServer()
    game.Lighting.GlobalShadows = Settings.GlobalShadows
end

local function OpenSettings()

end

UserInputService.InputBegan:Connect(function(Input, Processed)
    if Processed then return end
    if Input.KeyCode == Enum.KeyCode.Z then 
        Settings.GlobalShadows = not Settings.GlobalShadows
        Update()
    end
end)



--[[ PUBLIC ]]--




--[[ KNIT ]]--

function SettingsController:KnitStart()
    LogService = Knit.GetService("LogService")
end

return SettingsController