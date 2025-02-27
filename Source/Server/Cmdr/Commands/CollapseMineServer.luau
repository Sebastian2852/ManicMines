local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

return function()
	local MineService = Knit.GetService("MineService")
	MineService:Collapse()
end
