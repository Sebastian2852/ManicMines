-- A type to describe how a 'data' object looks like
type DataCopy = {
    Name :string;
    Data :{any};
}

local HttpService = game:GetService("HttpService")

local SaveData = {}
SaveData.__index = SaveData

SaveData._UserID = 0
SaveData._Data = {}

--[=[
Create a new blank save data object, optinal data can be passed in a table to automatically be added
]=]
function SaveData.New(UserID :number, Data :{DataCopy}?)
    assert(type(UserID) == "number", "User ID must be a number")
    local self = setmetatable({}, SaveData)

    self._UserID = UserID

    if Data then
        for _, DataToAdd in pairs(Data) do
            self._Data[DataToAdd.Name] = DataToAdd.Data
        end
    end

    return self
end

--[=[
Adds the data into the save data, ready to be processed when Load() or Save() is called
]=]
function SaveData:AddData(Data :DataCopy)
    self._Data[Data.Name] = Data.Data
end

function SaveData:Save(DataStore :DataStore)
    for Name :string, Data :{any} in pairs(self._Data) do
        local DataStoreKey = tostring(self._UserID).."-"..Name
        local DataStoreSaveData :string

        local Success, ErrorMessage = pcall(function()
            DataStoreSaveData = HttpService:JSONEncode(Data)
        end)

        if not Success then warn("Failed to JSONEncode: "..ErrorMessage) return end

        local Success, ErrorMessage = pcall(function()
            --DataStore:SetAsync(DataStoreKey, DataStoreSaveData)
            print(DataStoreKey, DataStoreSaveData)
        end)

        if not Success then warn("Failed to set to datastore: "..ErrorMessage) return end
    end
end

--[=[
Delete any data stored in the save data object itself
]=]
function SaveData:Discard()
    self._Data = nil
    self._UserID = nil
end


return SaveData
