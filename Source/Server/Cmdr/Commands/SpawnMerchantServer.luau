local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

return function()
	local MysteryMerchantService = Knit.GetService("MysteryMerchantService")

	local IsSpawned = MysteryMerchantService:IsMerchantSpawned()
	if IsSpawned then
		return "Failed; Mystery Merchant is already spawned"
	end

	MysteryMerchantService:Spawn()
	return "Spawned mystery merchant"
end
