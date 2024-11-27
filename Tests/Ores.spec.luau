local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NeededAttribs = {
    AmountDroppedWhenMined = "number";
    CaveMultiplier = "number";
    CaveOnly = "boolean";
    CoinValue = "number";
    DisplayName = "string";
    EmblemCost = "number";
    EmblemImageID = "string";
    Health = "number";
    InventoryBackgroundColor = "ColorSequence";
    MaxHealth = "number";
    MiningBarGradient = "ColorSequence";
    NoCave = "boolean";
    Rarity = "number";
    SelectionColor = "Color3";
    SpawningCurve = "NumberSequence";
    SpawningRange = "NumberRange";
    XP = "number";
    CanGenerateGeode = "boolean";
    GeodeColorTint = "color3";
    GeodeGenerationChance = "NumberRange";
}

return function()
    describe("Ores are setup correctly", function()
        for _, Ore in pairs(ReplicatedStorage.Assets.Ores:GetChildren()) do
            it(Ore.Name, function()
                local Ok = true
                for Key, Value in pairs(NeededAttribs) do
                    if typeof(Ore:GetAttribute(Key)) ~= Value then
                        warn(Key.." was wrong for ore: "..Ore.Name)
                        Ok = false
                        break
                    end
                end
                expect(Ok).to.equal(true)
            end)
        end
    end)
end