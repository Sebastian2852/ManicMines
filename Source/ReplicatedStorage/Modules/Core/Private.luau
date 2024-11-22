--[[
This is a module full of private stuff that the core module needs but doesn't need to be exposed
to any other scripts that use core.
]]


---[[[ TYPES ]]]---

--[[ DATA FOLDER ]]--
export type DataFolder_InventoryFolder = {
    Ores :Folder;
    InventoryCap :IntValue;
    InventoryItemCount :IntValue;
}

export type DataFolder_StorageFolder = {
    Ores :Folder;
    StorageCap :IntValue;
    StorageItemCount :IntValue;
}

export type DataFolder_PickaxesFolder = {
    Owned :Folder;
    Upgrades :Folder;
    Equipped :IntValue;
}

export type DataFolder_SettingsFolder = {
    GlobalShadows :BoolValue;
    RainbowEffect :BoolValue;
    MusicVolume :NumberValue;
}

export type DataFolder_StatsFolder = {
    BlocksMined :IntValue;
    DeepestMineLevel :IntValue;
    HoursPlayed :IntValue;
    TotalGoldEarned :IntValue;
    TotalXpEarned :IntValue;
}

export type DataFolder_TycoonFolder = {
    Upgrades :Folder;
}
---------------------------------------------------

return {}