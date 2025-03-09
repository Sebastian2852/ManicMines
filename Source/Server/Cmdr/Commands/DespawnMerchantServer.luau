local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

return function()
	local MysteryMerchantService = Knit.GetService("MysteryMerchantService")

	local IsSpawned = MysteryMerchantService:IsMerchantSpawned()
	if not IsSpawned then
		return "Failed; Mystery Merchant is not spawned"
	end

	MysteryMerchantService:DeSpawn()
	return "Despawned mystery merchant"
end
