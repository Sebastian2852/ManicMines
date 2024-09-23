local Data = {}
Data.__index = Data


function Data.New(Name :string, Data :{any})
    local self = setmetatable({}, Data)
    self.Name = Name
    self.Data = Data
    return self
end

function Data:Update(NewData :{any})
    self.Data = NewData
end

function Data:Destroy()
    self.Name = nil
    self.Data = nil
end


return Data
