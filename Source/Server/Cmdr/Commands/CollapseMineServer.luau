local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

return function(_, Seed: number?)
	local MineService = Knit.GetService("MineService")
	MineService:Collapse(Seed)
end
