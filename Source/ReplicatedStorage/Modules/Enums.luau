local HttpService = game:GetService("HttpService")
local Enums = {}

export type Enum = string

local function CreateEnumValue() :Enum
    return HttpService:GenerateGUID(false)
end

Enums.DeviceType = {
    Unkown = CreateEnumValue(); -- Used as a blank, when device has not been discovered

    Mobile = CreateEnumValue();
    PC = CreateEnumValue();
    Console = CreateEnumValue();
}

Enums.OreFrameStyle = {
    Normal = CreateEnumValue();
    PC = CreateEnumValue();
}

Enums.CostInclude = {
    Inventory = CreateEnumValue();
    Storage = CreateEnumValue();
    Both = CreateEnumValue();
}

Enums.UiListType = {
    ByName = CreateEnumValue();
    ByLayoutOrder = CreateEnumValue();
}

Enums.StorageOreFrameType = {
    Inventory = CreateEnumValue();
    Storage = CreateEnumValue();
}

table.freeze(Enums)
return Enums