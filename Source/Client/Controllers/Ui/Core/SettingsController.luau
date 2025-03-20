local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game.ReplicatedStorage

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Logger = require(ReplicatedStorage.Game.Modules.Logger)

local SettingsController = Knit.CreateController({ Name = "PlayerSettingsController" })

local SettingsService
local DataService

local MapProps = Instance.new("Folder")
MapProps.Parent = workspace
MapProps.Name = "MAP_PROPS"

local Settings: Core.Settings = {}

--[[ PRIVATE ]]
--

--[=[
Pushes the current settings to the server
]=]
local function PushToServer()
	Logger:Log("Pushing settings to server")
	SettingsService:PushSettings(Settings)
end

--[=[
Updates the settings by actually doing the settings (e.g. Disabling shadows)
Only does things that can be done by the client. The rest will be handled by the server
]=]
local function Update()
	Logger:Log("Updating settings")
	game.Lighting.GlobalShadows = Settings.GlobalShadows

	if Settings.HideMapProps then
		MapProps.Parent = ReplicatedStorage
	else
		MapProps.Parent = workspace
	end
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

	task.spawn(function()
		local function AddAllParts()
			for _, v in pairs(CollectionService:GetTagged("SettingsController/HideWithPropHiding")) do
				v.Parent = MapProps
			end
		end

		CollectionService:GetInstanceAddedSignal("SettingsController/HideWithPropHiding"):Connect(function()
			AddAllParts()
		end)
	end)
end

return SettingsController
