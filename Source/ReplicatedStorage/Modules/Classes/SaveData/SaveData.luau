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
Override the `tostring` function to print out all data within the object in a format:
`SaveKey == SaveData;`
]=]
function SaveData.__tostring(SaveDataObject)
    local ReturnString = ""

    for Name :string, Data :{any} in pairs(SaveDataObject._Data) do
        local DataStoreKey = tostring(SaveDataObject._UserID).."-"..Name
        local DataStoreSaveData :string

        local Success, ErrorMessage = pcall(function()
            DataStoreSaveData = HttpService:JSONEncode(Data)
        end)

        if not Success then warn("Failed to JSONEncode: "..ErrorMessage) ReturnString = ReturnString.."; (FAILED)" return end
        ReturnString = ReturnString.."; "..DataStoreKey.." == "..DataStoreSaveData
    end

    return ReturnString
end

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
Also automatically discards the data after its added
]=]
function SaveData:AddData(Data :DataCopy)
    self._Data[Data.Name] = Data.Data
end

--[=[
Save the stored data to the given DataStore
]=]
function SaveData:Save(DataStore :DataStore)
    for Name :string, Data :{any} in pairs(self._Data) do
        local DataStoreKey = tostring(self._UserID).."-"..Name
        local DataStoreSaveData :string

        local Success, ErrorMessage = pcall(function()
            DataStoreSaveData = HttpService:JSONEncode(Data)
        end)

        if not Success then warn("Failed to JSONEncode: "..ErrorMessage) return end

        local Success, ErrorMessage = pcall(function()
            DataStore:SetAsync(DataStoreKey, DataStoreSaveData)
        end)

        if not Success then warn("Failed to set to datastore: "..ErrorMessage) return end
    end
end

--[=[
Loads data stored in the given DataStore based on the names of the
data in the object
]=]
function SaveData:Load(DataStore :DataStore)
    for Name :string, Data :{any} in pairs(self._Data) do
        local DataStoreKey = tostring(self._UserID).."-"..Name
        local DataStoreSaveData :string

        local Success, ErrorMessage = pcall(function()
            DataStoreSaveData = DataStore:GetAsync(DataStoreKey)
        end)

        if not Success then warn("Failed to set to datastore: "..ErrorMessage) return end

        local Success, ErrorMessage = pcall(function()
            DataStoreSaveData = HttpService:JSONDecode(DataStoreSaveData)
        end)

        if not Success then warn("Failed to JSONDecode: "..ErrorMessage) return end
        self._Data[Name] = DataStoreSaveData
    end
end

--[=[
Get the stored data by name
]=]
function SaveData:GetDataByName(Name :string) :{any}?
    return self._Data[Name]
end

--[=[
Delete any data stored in the save data object itself
]=]
function SaveData:Discard()
    self._Data = nil
    self._UserID = nil
end


return SaveData
