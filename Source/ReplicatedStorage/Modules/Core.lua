--[[
This module is basically the core of the game since it is required by most scripts and gives access to some core settings and functions
that without the whole game would break down. They are all in this one module so that you can have 1 `require(core)` instead of a million
different requires for all the module.

Since most of the scripts require all of the modules anyway this is easier.
]]

local Private = require(script.Parent.ModulesInCore.Core_Private)

--[=[
An ore list is used in places like awarding the player with a set of ores
]=]
export type OreListItem = {
    Name :string;
    Amount :number;
}
export type OreList = {OreListItem}

--[=[
Settings used for when creating a new save slot
]=]
export type SaveSlotSettings = {
    Name :string;

    Tutorial :boolean;
}

--[=[
A data folder described in code
]=]
export type DataFolder = {
    Emblems :Folder;
    TimesMined :Folder;

    Inventory :Private.DataFolder_InventoryFolder;
    Storage :Private.DataFolder_StorageFolder;
    Settings :Private.DataFolder_SettingsFolder;
    Stats :Private.DataFolder_StatsFolder;
    Pickaxes :Private.DataFolder_PickaxesFolder;
    Tycoon :Private.DataFolder_TycoonFolder;

    XP :IntValue;
    Level :IntValue;
    Gold :IntValue;

    InMine :BoolValue;
    InTycoon :BoolValue;
    ServerMining :BoolValue;
    DataLoaded :BoolValue;
}

export type SlotInfo = {
    SlotID :number;
    Used :boolean;
    TycoonName :string;
    Gold :number;
    LastPlayed :number;
}

--[=[
A chat message to be sent from the server to the client
]=]
export type ChatMessage = {
    Message :string;
    Prefix :string;
    HasPrefix :boolean;
    MessageColor :Color3;
}

--[=[
Used for setting tables, contains every setting.
]=]
export type Settings = {
    GlobalShadows :boolean;
    RainbowEffect :boolean;
}

local GameConfig = require(script.Parent.ModulesInCore.GameConfig)
local Util = require(script.Parent.ModulesInCore.Util)

local Timer = require(script.Parent.Classes.Timer)

return {
    GameConfig = GameConfig;
    Util = Util;
    Timer = Timer;
}