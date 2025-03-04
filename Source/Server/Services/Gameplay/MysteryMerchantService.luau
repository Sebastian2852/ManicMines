local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Knit = require(ReplicatedStorage.Packages.Knit)

local Config = Core.GameConfig.MysteryMerchant

local NumberGenerator = Random.new()

local MysteryMerchantService = Knit.CreateService({
	Name = "MysteryMerchantService",
	Client = {},

	Trades = {
		Buy = {},
		Sell = {},
	},
})

-- [[ PUBLIC ]] --

function MysteryMerchantService:GenerateTrades()
	local BuyTrades = {}
	local BuyTradesToGenerate = NumberGenerator:NextInteger(Config.MerchantBuyTrades.Min, Config.MerchantBuyTrades.Max)

	local PossibleBuyOres = ReplicatedStorage.Assets.Ores:GetChildren() :: { Part }

	for i, Ore in pairs(PossibleBuyOres) do
		local CanBuy = Ore:GetAttribute("MysteryMerchantCanBuy")
		if not CanBuy then
			table.remove(PossibleBuyOres, i)
		end
	end

	for _ = 1, BuyTradesToGenerate, 1 do
		local OreIndex = NumberGenerator:NextInteger(1, #PossibleBuyOres)
		local Ore = PossibleBuyOres[OreIndex]
		table.remove(PossibleBuyOres, OreIndex)

		local CoinValue = Ore:GetAttribute("CoinValue")
		local BuyPrice = CoinValue * 0.75
		BuyTrades[Ore.Name] = BuyPrice
	end

	self.Trades = {
		Buy = BuyTrades,
		Sell = {},
	}
end

-- [[ CLIENT ]] --

function MysteryMerchantService.Client:GetTrades()
	return self.Trades
end

-- [[ KNIT ]] --

function MysteryMerchantService:KnitStart()
	self:GenerateTrades()
	print(self.Trades)
end

return MysteryMerchantService
