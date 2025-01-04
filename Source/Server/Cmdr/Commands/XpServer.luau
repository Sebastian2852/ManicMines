local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

return function(_, Player: Player, Amount: number)
	local PlayerStatsService = Knit.GetService("PlayerStatsService")
	PlayerStatsService:AwardXP(Player, Amount)
	return "Gave " .. Player.Name .. " " .. tostring(Amount) .. " XP"
end
