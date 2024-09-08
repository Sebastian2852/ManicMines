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

return Util