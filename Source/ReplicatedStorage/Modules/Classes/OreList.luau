local OreList = {}
OreList.__index = OreList
OreList._Ores = {}

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
    return self
end

--[=[
Add an ore to the list with a given amount. Everything else will be filled out for you.
If a non-existent ore name is passed it will use stone instead!
]=]
function OreList:AddOre(OreName :string, Amount :number)
    -- TODO: Check that the ore isnt already in the list
    -- If it is then just add the amount to it and not add as a new ore

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
Delete the ore list
]=]
function OreList:Destroy()
    self._Ores = nil
end


return OreList
