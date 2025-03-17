local ReplicatedStorage = game:GetService("ReplicatedStorage")
--[[
This module is basically the core of the game since it is required by most scripts and gives access to some core settings and functions
that without the whole game would break down. They are all in this one module so that you can have 1 `require(core)` instead of a million
different requires for all the module.

Since most of the scripts require all of the modules anyway this is easier.
]]

local Private = require(ReplicatedStorage.Game.Modules.Core.Private)

--[=[
Settings used for when creating a new save slot
]=]
export type SaveSlotSettings = {
	Name: string,

	Tutorial: boolean,
}

--[=[
A data folder described in code
]=]
export type DataFolder = {
	Emblems: Folder,
	TimesMined: Folder,

	Inventory: Private.DataFolder_InventoryFolder,
	Storage: Private.DataFolder_StorageFolder,
	Settings: Private.DataFolder_SettingsFolder,
	Stats: Private.DataFolder_StatsFolder,
	Pickaxes: Private.DataFolder_PickaxesFolder,
	Tycoon: Private.DataFolder_TycoonFolder,

	XP: IntValue,
	Level: IntValue,
	Gold: IntValue,
	TycoonName: StringValue,
	TutorialStage: NumberValue,

	InMine: BoolValue,
	InTycoon: BoolValue,
	ServerMining: BoolValue,
	DataLoaded: BoolValue,

	LastVersionPlayed: StringValue,
	VersionCreated: StringValue,

	FindFirstChild: (DataFolder, Name: string) -> any,
}

export type SlotInfo = {
	SlotID: number,
	Used: boolean,
	TycoonName: string,
	Gold: number,
	LastPlayed: number,
}

--[=[
A chat message to be sent from the server to the client
]=]
export type ChatMessage = {
	Message: string,
	Prefix: string,
	HasPrefix: boolean,
	MessageColor: Color3,
}

--[=[
Used for setting tables, contains every setting.
]=]
export type Settings = {
	GlobalShadows: boolean,
	RainbowEffect: boolean,
	MusicVolume: number,
	InventoryShortUnits: boolean,
	HideMapProps: boolean,
	HideOverheadGUI: boolean,
}

--[=[
Used for well admin permissions
]=]
export type AdminPermissions = {
	EditTycoonName: boolean,
	EditTycoonUpgrades: boolean,

	GiveOres: boolean,
	TakeOres: boolean,
}

--[=[
A config for a sound type
]=]
export type SoundConfig = {
	Positional: boolean,
	PositionToPlay: BasePart | Vector3,
	Looped: boolean,
	Volume: number,
	Pitch: number,
	Speed: number,

	RollOffMode: Enum.RollOffMode,
	RollOffDistanceBegin: number,
	RollOffMaxDistance: number,
}

--[=[
A sound type for use by the AudioEngine
Contains all the functions and more complex options
]=]
export type Sound = {
	SoundID: string,
	Config: SoundConfig,

	OnFinish: () -> (),
	OnLoop: (TimesLooped: number) -> (),
}

local GameConfig = require(script.GameConfig)
local Roact = require(ReplicatedStorage.Packages.Roact)
local UI = require(script.UI)
local Util = require(script.Util)

local OreList = require(ReplicatedStorage.Game.Modules.Classes.OreList)
local Queue = require(script.Parent.Classes.Queue)

local Data = require(script.Parent.Classes.SaveData.Data)
local SaveData = require(script.Parent.Classes.SaveData.SaveData)

export type OreList = OreList.OreList
export type OreListItem = OreList.OreListItem

return {
	GameConfig = GameConfig,
	Util = Util,
	OreList = OreList,
	Queue = Queue,

	UI = UI,
	Roact = Roact,

	Data = {
		SaveData = SaveData,
		Data = Data,
	},

	Assets = ReplicatedStorage.Assets,
}
