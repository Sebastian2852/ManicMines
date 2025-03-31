local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Knit = require(ReplicatedStorage.Packages.Knit)

return function(_, Player: Player, OreName: string)
	local Character = Player.Character
	if not Character then
		return "Player doesnt have a character!"
	end
	local MineService = Knit.GetService("MineService")
	local Ore = Core.Util:GetOreByName(OreName)
	local Stone = Core.Assets.Stone

	if not Ore then
		return "Couldnt find ore"
	end

	local ClosestBlock: Part = MineService:GetBlockClosestToPosition(Character.PrimaryPart.Position)
	if ClosestBlock == nil then
		return "Couldn't get closest block"
	end

	local Position = ClosestBlock.CFrame.Position
	local Depth = ClosestBlock:GetAttribute("Depth")

	MineService:BlockMined(ClosestBlock)

	local NewOre = Stone:Clone() :: BasePart
	NewOre.Name = Ore.Name
	NewOre.Parent = workspace.Game.Mine
	NewOre.CFrame = CFrame.new(Position)
	NewOre.Size = Core.GameConfig.Mine.BlockSize
	NewOre:ClearAllChildren()

	local AttribsToSet = Ore:GetAttributes()

	for Key, Value in pairs(AttribsToSet) do
		NewOre:SetAttribute(Key, Value)
	end

	for _, v in pairs(Ore:GetChildren()) do
		v:Clone().Parent = NewOre
	end

	NewOre:SetAttribute("CanMine", true)
	NewOre:SetAttribute("Depth", Depth)
	return "Swapped"
end
