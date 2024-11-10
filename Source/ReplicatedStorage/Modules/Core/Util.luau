local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = {}

local OreList = require(ReplicatedStorage.Game.Modules.Classes.OreList)
local Promise = require(ReplicatedStorage.Packages.Promise)

--[=[
Convertes a given number into a string, good for use in UI.
For example  
```
print(Util:ConvertNumberToString(1750))
```  
```
1.7k
```
]=]
function Util:ConvertNumberToString(Number :number) :string
    assert(type(Number) == "number", "NAN passed for 'Number'")

    if Number >= 1_000_000_000_000 then
        return string.format("%.1fT", Number / 1_000_000_000_000)
    elseif Number >= 1_000_000_000 then
        return string.format("%.1fB", Number / 1_000_000_000)
    elseif Number >= 1_000_000 then
        return string.format("%.1fM", Number / 1_000_000)
    elseif Number >= 1_000 then
        return string.format("%.1fK", Number / 1_000)
    else
        return tostring(Number)
    end
end

--[=[
Rounds a number to 'x' decemal places.
For exmaple:  
```
Util:RoundToxDP(25.129384, 1)
```
```
25.1
```
]=]
function Util:RoundToxDP(Number :number, X :number) :number
    assert(type(Number) == "number", "NAN passed for 'Number'")
    assert(type(X) == "number", "NAN passed for 'x'")
    return tonumber(string.format("%."..(X).."f", Number))
end

--[=[
Converts a unix time into a time ago string. Example:
```
local TimeNow = os.Time()
task.wait(5)
print(Uti:TimeAgo(TimeNow))
```
```
5 seconds ago
```
]=]
function Util:TimeAgo(Time :number) :string
    assert(type(Time) == "number", "NAN passed for 'Time'")
    local Final = "N/A"
    if Time < 60 then
        Final = Time .. " seconds ago"
    elseif Time < 3600 then
        Final = math.floor(Time / 60) .. " minutes ago"
    elseif Time < 86400 then
        Final = math.floor(Time / 3600) .. " hours ago"
    else
        Final = math.floor(Time / 86400) .. " days ago"
    end

    return Final
end

--[=[
Takes in an objects and outputs a string to use for logging. E.g if you pass a part called "John"
you will get "John (Part)" back
]=]
function Util:LogObjectString(Object :any) :string
    return Object.Name.." ("..Object.ClassName..")"
end

--[=[
Create an ore list from a folder
]=]
function Util:CreateOreListFromFolder(Folder :Folder)
    warn("!!! USING OUTDATED FUNCTION !!!")
    local NewList = OreList.New()

    for _, Object :ValueBase in pairs(Folder:GetChildren()) do
        if not Object:IsA("ValueBase") then continue end

        if Object.Name == "Gold" then
            NewList:AddGold(Object.Name)
            continue
        end

        NewList:AddOre(Object.Name, Object.Value)
    end

    return NewList
end

--[=[
Returns the ore as a base part from the ores folder
]=]
function Util:GetOreByName(OreName :string) :BasePart
    if OreName == "Gold" then return end
    if OreName == "Stone" then
        return ReplicatedStorage.Assets.Stone
    end

    return ReplicatedStorage.Assets.Ores:FindFirstChild(OreName)
end

--[=[
Convert an ore to a type. This is a function just to keep stuff working and **will
be deleted soon!**
]=]
function Util:ConvertOreToType(Ore :BasePart, Amount :number) :{Name :string, DisaplyName :string, Amount :number, Emblem :string, ActualOre :BasePart}
    local ScriptCallingFunction :string = debug.info(5, "s") or "unkown"
    warn("USING OUTDATED FUNCTION!!! "..ScriptCallingFunction)

    local OreType = {
        Name = Ore.Name;
        DisaplyName = Ore:GetAttribute("DisplayName");
        Amount = Amount;
        Emblem = Ore:GetAttribute("EmblemImageID") or ReplicatedStorage.Assets.UI.NoTexture.Texture;
        ActualOre = Ore;
    }

    return OreType
end

--[=[
Returns the value at the given time in the given number sequence
]=]
function Util:EvaluateNumberSequence(Sequence :NumberSequence, Time :number)
    local Keypoints = Sequence.Keypoints

    if Time <= Keypoints[1].Time then
        return Keypoints[1].Value
    elseif Time >= Keypoints[# Keypoints].Time then
        return Keypoints[# Keypoints].Value
    end

    for i = 1, #Keypoints - 1 do
        local Current = Keypoints[i]
        local Next = Keypoints[i + 1]

        if Time >= Current.Time and Time <= Next.Time then
            local Alpha = (Time - Current.Time) / (Next.Time - Current.Time)
            return Current.Value + (Next.Value - Current.Value) * Alpha
        end
    end
end

--[=[
Takes in an object and a table and tries to apply the values to the properties based on the key
so if you put in a part and a table which looks like this {Size = Vector3.new(6, 6, 6)}
This will change the part's size
]=]
function Util:ApplyPropertiesFromTable<T>(Object :T, Properties :{[string] :any})
    for Key, Value in pairs(Properties) do
        local Success = pcall(function()
            Object[Key] = Value
        end)

        if not Success then
            warn("Object: "..Util:LogObjectString(Object).." doesnt not have the property: "..Key)
        end
    end
end

--[=[
Does the same thing as `ApplyPropertiesFromTable` but does it async  
Returns a promise
]=]
function Util:ApplyPropertiesFromTableAsync<T>(Object :T, Properties :{[string] :any})
    return Promise.new(function(Resolve)
        Util:ApplyPropertiesFromTable(Object, Properties)
        Resolve()
    end)
end

return Util