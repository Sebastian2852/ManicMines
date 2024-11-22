local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("CmdrClient"):WaitForChild("Shared"):WaitForChild("Util"))

local GuiNames = {
    "Forge";
    "Storage";
}

return function (Cmdr)
    local GuiType = {
        Transform = function (Text)
            local FindText = Util.MakeFuzzyFinder(GuiNames)
            return FindText(Text)
        end;

        Validate = function (Guis)
            return #Guis > 0, "No GUI with that name could be found."
        end;

        Autocomplete = function (Guis)
            return Guis
        end;

        Parse = function (Guis)
            return Guis[1]
        end;
    }

    Cmdr:RegisterType("gui", GuiType)
end