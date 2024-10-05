local OreList = {}
OreList.__index = OreList
OreList._Ores = {}
OreList._Gold = 0

--[=[
Override the tostring() function to return the object as a nice string in the format:  
`Amount DisplayName (Name);`  
`15 Test Ore (TestOre); 25 Stone (Stone)`
]=]
function OreList.__tostring(OreListObject)
    local Text = ""
    for _, OreData in pairs(OreListObject._Ores) do
        Text = Text.." "..OreData.Amount.." "..OreData.DisplayName.."("..OreData.Name..");"
    end
    return Text
end

local function GetOreByName(Name :string) :BasePart
    local FoundOre = nil
    FoundOre = game.ReplicatedStorage.Assets.Ores:FindFirstChild(Name)
    if FoundOre == nil then FoundOre = game.ReplicatedStorage.Assets.Stone end
    return FoundOre
end


--[=[
Create a new blank ore list
]=]
function OreList.New()
    local self = setmetatable({}, OreList)
    self._Gold = 0
    self._Ores = {}
    return self
end

--[=[
Add an ore to the list with a given amount. Everything else will be filled out for you.
If a non-existent ore name is passed it will use stone instead!
]=]
function OreList:AddOre(OreName :string, Amount :number)
    if self._Ores[OreName] then
        self._Ores[OreName].Amount += Amount
        return
    end

    local RealOre = GetOreByName(OreName)
    local OreData = {}
    OreData.Name = RealOre.Name
    OreData.Amount = Amount
    OreData.DisplayName = RealOre:GetAttribute("DisplayName")
    OreData.Emblem = RealOre:GetAttribute("EmblemImageID")
    OreData.RealOre = RealOre
    self._Ores[OreName] = OreData
end

--[=[
Delete an ore from the list. If result is below `zero`, zero will be used. If you pass `-1` for amount
the ore will be removed from the list!
]=]
function OreList:RemoveOre(OreName :string, Amount :number)
    if not self._Ores[OreName] then warn("There is no "..OreName.." in the ore list") return end
    local OreData = self._Ores[OreName]
    local AmountInList = OreData.Amount
    local NewAmount = AmountInList - Amount

    if NewAmount < 0 then NewAmount = 0 end

    if Amount == -1 then
        self._Ores[OreName] = nil
        return
    end

    self._Ores[OreName].Amount = NewAmount
end

--[=[
Adds gold to the ore list
]=]
function OreList:AddGold(Amount :number)
    self._Gold += Amount
end

--[=[
Removes gold from the ore list, if is below 0 then it is set to 0
]=]
function OreList:RemoveGold(Amount :number)
    self._Gold -= Amount
    if self._Gold < 0 then
        self._Gold = 0
    end
end

--[=[
a function to convert the ore list into a valid thing for using in a for
loop

```
for OreName, OreData in pairs(OreList:LoopList()) do
    print(OreName, OreData)
end
]=]
function OreList:LoopList()
    local List = {}

    for OreName, OreData in pairs(self._Ores) do
        List[OreName] = OreData
    end

    List["Gold"] = {Name = "Gold", Amount = self._Gold, DisplayName = "Gold"}

    return List
end

--[=[
Delete the ore list
]=]
function OreList:Destroy()
    self._Ores = nil
end


return OreList
