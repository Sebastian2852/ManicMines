local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
--[[
This module is basically the core of the game since it is required by most scripts and gives access to some core settings and functions
that without the whole game would break down. They are all in this one module so that you can have 1 `require(core)` instead of a million
different requires for all the module.

Since most of the scripts require all of the modules anyway this is easier.
]]

local Private = require(script.Parent.ModulesInCore.Core_Private)

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

--[=[
Used for well admin permissions
]=]
export type AdminPermissions = {
    EditTycoonName :boolean;
    EditTycoonUpgrades :boolean;
}

local GameConfig = require(script.Parent.ModulesInCore.GameConfig)
local Util = require(script.Parent.ModulesInCore.Util)
local UI
local Roact

local Timer = require(script.Parent.Classes.Timer)
local OreList = require(script.Parent.Classes.OreList)

local SaveData = require(script.Parent.Classes.SaveData.SaveData)
local Data = require(script.Parent.Classes.SaveData.Data)
local Maid = require(ReplicatedStorage.Packages.maid)

if RunService:IsClient() then
    Roact = require(ReplicatedStorage.Packages.Roact)
    UI = require(script.Parent.ModulesInCore.UI)
end

return {
    GameConfig = GameConfig;
    Util = Util;
    Timer = Timer;
    OreList = OreList;

    UI = UI;
    Roact = Roact;

    Maid = Maid;

    Data = {
        SaveData = SaveData;
        Data = Data;
    };

    Assets = {
        Layers = ReplicatedStorage.Assets.Layers;
        Levels = ReplicatedStorage.Assets.Levels;
        Ores = ReplicatedStorage.Assets.Ores;
        Pickaxe = ReplicatedStorage.Assets.Pickaxe;
        Tycoon = ReplicatedStorage.Assets.Tycoon;
        UI = ReplicatedStorage.Assets.UI;
    };
}