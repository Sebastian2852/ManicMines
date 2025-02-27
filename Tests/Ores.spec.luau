local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NeededAttribs = {
	AmountDroppedWhenMined = "number",
	CaveMultiplier = "number",
	CaveOnly = "boolean",
	CoinValue = "number",
	DisplayName = "string",
	EmblemCost = "number",
	EmblemImageID = "string",
	Health = "number",
	InventoryBackgroundColor = "ColorSequence",
	MiningBarGradient = "ColorSequence",
	NoCave = "boolean",
	Rarity = "number",
	SelectionColor = "Color3",
	SpawningCurve = "NumberSequence",
	SpawningRange = "NumberRange",
	XP = "number",
	CanGenerateGeode = "boolean",
	GeodeColorTint = "Color3",
	GeodeGenerationChance = "number",
}

return function()
	describe("Ores are setup correctly", function()
		for _, Ore in pairs(ReplicatedStorage.Assets.Ores:GetChildren()) do
			it(Ore.Name, function()
				for Key, Value in pairs(NeededAttribs) do
					expect(Ore).to.be.ok()
					expect(Ore:GetAttribute(Key)).to.be.ok()
					expect(typeof(Ore:GetAttribute(Key))).to.be.equal(Value)
				end
			end)
		end
	end)
end
