local ReplicatedStorage = game:GetService("ReplicatedStorage")
return function()
    local Util = require(ReplicatedStorage.Game.Modules.ModulesInCore.Util)

    describe("ConvertNumberToString", function()
        it("Returns number if no conversion needed", function()
            local Returned = Util:ConvertNumberToString(7)
            expect(Returned:match("7")).to.be.ok()
        end)

        it("Converts to thousands", function()
            local Returned = Util:ConvertNumberToString(1000)
            expect(Returned:match("1.0K")).to.be.ok()
        end)

        it("Converts to millions", function()
            local Returned = Util:ConvertNumberToString(1000000)
            expect(Returned:match("1.0M")).to.be.ok()
        end)

        it("Converts to billions", function()
            local Returned = Util:ConvertNumberToString(1000000000)
            expect(Returned:match("1.0B")).to.be.ok()
        end)

        it("Converts to trillions", function()
            local Returned = Util:ConvertNumberToString(1000000000000)
            expect(Returned:match("1.0T")).to.be.ok()
        end)
    end)
    
    describe("Round to X D.P.", function()
        it("Can round to 0 D.P.", function()
            local Returned = Util:RoundToxDP(25.129384, 0)
            expect(Returned == 25)
        end)

        it("Can round to 1 D.P.", function()
            local Returned = Util:RoundToxDP(25.129384, 1)
            expect(Returned == 25.1)
        end)
    end)
end