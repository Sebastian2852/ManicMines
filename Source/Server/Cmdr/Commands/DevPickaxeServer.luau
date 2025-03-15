local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

return function(Context)
	local PickaxeService = Knit.GetService("PickaxeService")
	local Player: Player = Context.Executor

	PickaxeService:RemovePickaxeFromPlayer(Player)

	local Pickaxe: Tool = ReplicatedStorage.Assets.Pickaxe.DevPickaxe
	local NewPickaxe: Tool = Pickaxe:Clone()
	local NewScript: LocalScript = ReplicatedStorage.Game.Scripts.Pickaxe:Clone()
	NewPickaxe.Parent = Player.Backpack
	NewScript.Parent = NewPickaxe
	NewPickaxe:AddTag("Pickaxe")

	return "DevPick"
end
