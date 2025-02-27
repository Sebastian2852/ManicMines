local OreList = {}
OreList.__index = OreList

--[=[
These types are forwarded to Core module. So these should only really be used in this module. Everything else should use the types in core
rather than these.
]=]

--[=[
Describes an item in the ore list table. Or as refered to in most parts of the game "OreData"
]=]
export type OreListItem = {
	Name: string,
	DisplayName: string,
	Amount: number,
	Emblem: string,
	RealOre: Part,
}

--[=[
The type for this whole class
]=]
export type OreList = {
	New: () -> OreList,
	CreateFromOre: () -> OreList,
	CreateFromFolder: () -> OreList,
	IsOreList: () -> boolean,

	AddOre: (self: OreList, OreName: string, Amount: number) -> nil,
	RemoveOre: (self: OreList, OreName: string, Amount: number) -> nil,

	AddGold: (self: OreList, Amount: number) -> nil,
	RemoveGold: (self: OreList, Amount: number) -> nil,

	LoopList: (self: OreList) -> { OreListItem },
	Destroy: (self: OreList) -> nil,
}

--[=[
Override the tostring() function to return the object as a nice string in the format:  
`Amount DisplayName (Name);`  
`15 Test Ore (TestOre); 25 Stone (Stone)`
]=]
function OreList.__tostring(OreListObject: OreList)
	local Text = ""
	for _, OreData in pairs(OreListObject._Ores) do
		Text = Text
			.. " "
			.. tostring(OreData.Amount)
			.. " "
			.. tostring(OreData.DisplayName)
			.. " ("
			.. tostring(OreData.Name)
			.. ");"
	end
	return Text
end

local function GetOreByName(Name: string): BasePart
	local FoundOre = nil
	FoundOre = game.ReplicatedStorage.Assets.Ores:FindFirstChild(Name)

	if FoundOre == nil then
		FoundOre = game.ReplicatedStorage.Assets.Stone
	end
	return FoundOre
end

--[=[
Create a new blank ore list
]=]
function OreList.New(): OreList
	local self = setmetatable({}, OreList)
	self.ClassName = "OreList"
	self._Gold = 0
	self._Ores = {}
	return self
end

--[=[
Create an ore list with 1 ore
]=]
function OreList.CreateFromOre(OreName: string, Amount: number): OreList
	local self = OreList.New()
	self:AddOre(OreName, Amount)
	return self
end

function OreList.CreateOreData(Ore: string | BasePart, Amount: number?): OreListItem
	if type(Ore) == "string" then
		Ore = GetOreByName(Ore)
	end

	local OreData = {}
	OreData.Name = Ore.Name
	OreData.Amount = Amount or 1
	OreData.DisplayName = Ore:GetAttribute("DisplayName")
	OreData.Emblem = Ore:GetAttribute("EmblemImageID")
	OreData.RealOre = Ore
	return OreData
end

--[=[
Create an ore list from a given folder
]=]
function OreList.CreateFromFolder(Folder: Folder): OreList
	local self = OreList.New()

	for _, Object: ValueBase in pairs(Folder:GetChildren()) do
		if not Object:IsA("ValueBase") then
			continue
		end
		if Object.Value <= 0 then
			continue
		end

		if Object.Name == "GoldCoins" then
			self:AddGold(Object.Name)
			continue
		end

		self:AddOre(Object.Name, Object.Value)
	end

	return self
end

--[=[
Check if an object is an OreList object
]=]
function OreList.IsOreList(Object: any): boolean
	if Object == nil then
		return false
	end
	if Object.ClassName ~= "OreList" then
		return false
	end
	if not Object._Ores then
		return false
	end
	if not Object._Gold then
		return false
	end

	return true
end

--[=[
Add an ore to the list with a given amount. Everything else will be filled out for you.
If a non-existent ore name is passed it will use stone instead!
]=]
function OreList:AddOre(OreName: string, Amount: number)
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
function OreList:RemoveOre(OreName: string, Amount: number)
	if not self._Ores[OreName] then
		warn("There is no " .. OreName .. " in the ore list")
		return
	end

	local OreData = self._Ores[OreName]
	local AmountInList = OreData.Amount
	local NewAmount = AmountInList - Amount

	if NewAmount < 0 then
		NewAmount = 0
	end

	if Amount == -1 then
		self._Ores[OreName] = nil
		return
	end

	self._Ores[OreName].Amount = NewAmount
end

--[=[
Adds gold to the ore list
]=]
function OreList:AddGold(Amount: number)
	self._Gold += Amount
end

--[=[
Removes gold from the ore list, if is below 0 then it is set to 0
]=]
function OreList:RemoveGold(Amount: number)
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
function OreList:LoopList(): { OreListItem }
	local List = self._Ores
	if self._Gold > 0 then
		List["GoldCoins"] = { Name = "GoldCoins", Amount = self._Gold, DisplayName = "Gold" }
	end
	return List
end

--[=[
Delete the ore list
]=]
function OreList:Destroy()
	self._Ores = nil
	self._Gold = nil
end

return OreList
