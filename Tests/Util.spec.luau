local ReplicatedStorage = game:GetService("ReplicatedStorage")

return function()
    local Util = require(ReplicatedStorage.Game.Modules.ModulesInCore.Util)

    describe("ConvertNumberToString", function()
        it("Returns number if no conversion needed", function()
            local Returned = Util:ConvertNumberToString(7)
            expect(Returned).to.equal("7")
        end)

        it("Converts to thousands", function()
            local Returned = Util:ConvertNumberToString(1000)
            expect(Returned).to.equal("1.0K")
        end)

        it("Converts to millions", function()
            local Returned = Util:ConvertNumberToString(1000000)
            expect(Returned).to.equal("1.0M")
        end)

        it("Converts to billions", function()
            local Returned = Util:ConvertNumberToString(1000000000)
            expect(Returned).to.equal("1.0B")
        end)

        it("Converts to trillions", function()
            local Returned = Util:ConvertNumberToString(1000000000000)
            expect(Returned).to.equal("1.0T")
        end)
    end)
    
    describe("Round to X D.P.", function()
        it("Can round to 0 D.P.", function()
            local Returned = Util:RoundToxDP(25.129384, 0)
            expect(Returned).to.equal(25)
        end)

        it("Can round to 1 D.P.", function()
            local Returned = Util:RoundToxDP(25.129384, 1)
            expect(Returned).to.equal(25.1)
        end)
    end)

    describe("LogObjectString", function()
        it("Creates proper strings", function()
            local TestPart = Instance.new("Part")
            TestPart.Name = "John"
            TestPart.Parent = workspace
            local LogObjectString = Util:LogObjectString(TestPart)
            TestPart:Destroy()
            expect(LogObjectString).to.equal("John (Part)")
        end)
    end)

    describe("GetOreByName", function()
        it("Returns the correct stone", function()
            local ReturnedObject = Util:GetOreByName("Stone")
            expect(ReturnedObject:GetFullName()).to.equal(ReplicatedStorage.Assets.Stone:GetFullName())
        end)

        it("Can return created ores", function()
            local OreToUse :BasePart = ReplicatedStorage.Assets.Ores:GetChildren()[math.random(1, #ReplicatedStorage.Assets.Ores:GetChildren())]
            local ReturnedObject = Util:GetOreByName(OreToUse.Name)
            expect(ReturnedObject:GetFullName()).to.equal(OreToUse:GetFullName())
        end)
    end)
end