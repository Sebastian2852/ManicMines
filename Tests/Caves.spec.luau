local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NeededAttribs = {
    DepthRange = "NumberRange";
    NoiseResolution = "Vector3";
    NoiseResolutionOffset = "Vector3";
    NoiseThreshold = "number";
    Size = "NumberRange";
    Rarity = "number";
    TestMode = "boolean";
    Tint = "Color3";
}

return function()
    describe("Random caves are setup correctly", function()
        for _, Cave in pairs(ReplicatedStorage.Assets.Caves.Random:GetChildren()) do
            it(Cave.Name, function()
                for Key, Value in pairs(NeededAttribs) do
                    expect(Cave).to.be.ok()
                    expect(Cave:GetAttribute(Key)).to.be.ok()
                    expect(typeof(Cave:GetAttribute(Key))).to.be.equal(Value)
                end
            end)
        end
    end)
end