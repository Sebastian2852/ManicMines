local Data = {}
Data.__index = Data

--[=[
Create a new data object with a name and some data
]=]
function Data.New(Name :string, Data :{any})
    local self = setmetatable({}, Data)
    self.Name = Name
    self.Data = Data
    return self
end

--[=[
Replace any stored data inside the object with given `NewData`
]=]
function Data:Update(NewData :{any})
    self.Data = NewData
end

--[=[
Delete the data object
]=]
function Data:Discard()
    self.Name = nil
    self.Data = nil
end


return Data
