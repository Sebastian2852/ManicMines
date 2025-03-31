local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("CmdrClient"):WaitForChild("Shared"):WaitForChild("Util"))

local OreNames = {}

for _, Ore: Part in pairs(ReplicatedStorage.Assets.Ores:GetChildren()) do
	table.insert(OreNames, Ore.Name)
end

return function(Cmdr)
	local OreType = {
		Transform = function(Text)
			local FindText = Util.MakeFuzzyFinder(OreNames)
			return FindText(Text)
		end,

		Validate = function(Ores)
			return #Ores > 0, "No ore with that name could be found."
		end,

		Autocomplete = function(Ores)
			return Ores
		end,

		Parse = function(Ores)
			return Ores[1]
		end,
	}

	Cmdr:RegisterType("ore", OreType)
end
