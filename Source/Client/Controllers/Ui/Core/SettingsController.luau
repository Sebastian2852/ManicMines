local ReplicatedStorage = game.ReplicatedStorage

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Knit = require(ReplicatedStorage.Packages.Knit)

local SettingsController = Knit.CreateController({ Name = "PlayerSettingsController" })

local LogService
local SettingsService
local DataService

local Settings: Core.Settings = {}

--[[ PRIVATE ]]
--

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

-- [[ PUBLIC ]] --

function SettingsController:ModifySetting(SettingName: string, NewValue: any)
	Settings[SettingName] = NewValue
	PushToServer()
end

function SettingsController:GetSetting(SettingName: string)
	return Settings[SettingName]
end

--[[ KNIT ]]
--

function SettingsController:KnitStart()
	LogService = Knit.GetService("LogService")
	SettingsService = Knit.GetService("SettingsService")
	DataService = Knit.GetService("DataService")

	DataService.DataLoaded:Connect(function(DataFolder: Core.DataFolder)
		for _, SettingValue: ValueBase in pairs(DataFolder.Settings:GetChildren()) do
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
