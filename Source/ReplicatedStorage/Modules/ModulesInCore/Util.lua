local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = {}

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

function Util:ConvertOreToType(Ore :BasePart, Amount :number) :{Name :string, DisaplyName :string, Amount :number, Emblem :string, ActualOre :BasePart}
    local OreType = {
        Name = Ore.Name;
        DisaplyName = Ore:GetAttribute("DisplayName");
        Amount = Amount;
        Emblem = Ore:GetAttribute("EmblemImageID") or ReplicatedStorage.Assets.UI.NoTexture.Texture;
        ActualOre = Ore;
    }

    return OreType
end

function Util:GetOreByName(OreName :string) :BasePart
    if OreName == "Gold" then return end
    if OreName == "Stone" then
        return ReplicatedStorage.Assets.Stone
    end

    return ReplicatedStorage.Assets.Ores:FindFirstChild(OreName)
end

function Util:MakeOreUIFromType(Ore :{Name :string, DisaplyName :string, Amount :number, Emblem :string, ActualOre :BasePart})
    local UI = ReplicatedStorage.Assets.UI.OreFrame:Clone()
    UI.OreImage.Image = Ore.Emblem
    UI.OreAmount.Text = Ore.Amount
    UI.OreName.Text = Ore.DisaplyName
    local Color = Ore.ActualOre:GetAttribute("InventoryBackgroundColor")
    UI.UIGradient.Color = Color
    return UI
end

return Util