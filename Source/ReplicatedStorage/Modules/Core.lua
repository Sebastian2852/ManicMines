--[[
This module is basically the core of the game since it is required by most scripts and gives access to some core settings and functions
that without the whole game would break down. They are all in this one module so that you can have 1 `require(core)` instead of a million
different requires for all the module.

Since most of the scripts require all of the modules anyway this is easier.
]]

--[=[
An ore list is used in places like awarding the player with a set of ores
]=]--
export type OreListItem = {
    Name :string;
    Amount :number;
}
export type OreList = {OreListItem}

--[=[
Used for setting tables, contains every setting.
]=]
export type Settings = {
    GlobalShadows :boolean;
}

local GameConfig = require(script.Parent.GameConfig)
local Util = require(script.Parent.Util)

return {
    GameConfig = GameConfig;
    Util = Util;
}