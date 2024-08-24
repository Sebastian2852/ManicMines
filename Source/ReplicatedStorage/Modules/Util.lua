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

function Util:RoundToxDP(Number :number, X :number) :number
    assert(type(Number) == "number", "NAN passed for 'Number'")
    assert(type(X) == "number", "NAN passed for 'x'")
    return tonumber(string.format("%."..(X).."f", Number))
end

return Util