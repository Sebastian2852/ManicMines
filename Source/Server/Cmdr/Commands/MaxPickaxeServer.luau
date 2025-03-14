local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

return function(Context, Player: Player?)
	if Player == nil then
		Player = Context.Executor
	end

	local PickaxeService = Knit.GetService("PickaxeService")

	local Pickaxe: Tool? = PickaxeService:GetPlayerPickaxe(Player)

	if Pickaxe == nil then
		return "Failed; Player does not have a pickaxe"
	end

	Pickaxe:SetAttribute("Damage", math.huge)
	Pickaxe:SetAttribute("Delay", 0)
	Pickaxe:SetAttribute("Range", math.huge)
	return `Maxed {Player.DisplayName}'s pickaxe`
end
