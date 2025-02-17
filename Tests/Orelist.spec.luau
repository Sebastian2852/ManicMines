local ReplicatedStorage = game:GetService("ReplicatedStorage")
return function()
	local Orelist = require(ReplicatedStorage.Game.Modules.Classes.OreList)

	describe("Creating ore lists", function()
		it("Create blank ore list", function()
			local OreList = Orelist.New()
			expect(OreList).to.be.ok()
			expect(OreList).to.be.a("table")
			expect(Orelist.IsOreList(OreList)).to.equal(true)
		end)

		it("Create ore list from folder", function() end)
	end)

	describe("Misc", function()
		it("Can check ore lists", function()
			local RealOreList = Orelist.New()
			local FakeOreList = {}
			local FakeWithClassname = {
				ClassName = "OreList",
			}

			expect(Orelist.IsOreList(RealOreList)).to.equal(true)
			expect(Orelist.IsOreList(FakeOreList)).to.equal(false)
			expect(Orelist.IsOreList(FakeWithClassname)).to.equal(false)
		end)
	end)
end
