local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

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

local MessageService
local DataService
local PlayerStatsService

local NPC = ServerStorage.MysteryMerchant.NPC

type TradeInfo = {
	ID: number,
	Ore: string,
	Amount: number,
	Cost: number,
}

-- [[ PUBLIC ]] --

function MysteryMerchantService:GetTradeByTradeID(TradeID: number, Type: string)
	local Trades = self.Trades[Type]

	for i, Trade in pairs(Trades) do
		local ID = Trade.ID
		if ID == TradeID then
			return i, Trade
		end
	end
end

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

	for i = 1, BuyTradesToGenerate, 1 do
		local OreIndex = NumberGenerator:NextInteger(1, #PossibleBuyOres)
		local Ore = PossibleBuyOres[OreIndex]
		local Amount = math.random(Config.TradeCostAmountRange.Min, Config.TradeCostAmountRange.Max)
		table.remove(PossibleBuyOres, OreIndex)

		local CoinValue = Ore:GetAttribute("CoinValue")
		local BuyPrice = math.round(CoinValue * 0.75) * Amount
		BuyTrades[i] = { ID = i, Ore = Ore.Name, Cost = BuyPrice, Amount = Amount }
	end

	local SellTrades = {}
	local SellTradesToGenerate =
		NumberGenerator:NextInteger(Config.MerchantSellTrades.Min, Config.MerchantSellTrades.Max)

	local PossibleSellOres = ReplicatedStorage.Assets.Ores:GetChildren() :: { Part }

	for i, Ore in pairs(PossibleSellOres) do
		local CanBuy = Ore:GetAttribute("MysteryMerchantCanSell")
		if not CanBuy then
			table.remove(PossibleSellOres, i)
		end
	end

	for i = 1, SellTradesToGenerate, 1 do
		local OreIndex = NumberGenerator:NextInteger(1, #PossibleSellOres)
		local Ore = PossibleSellOres[OreIndex]
		local Amount = math.random(Config.TradeCostAmountRange.Min, Config.TradeCostAmountRange.Max)
		table.remove(PossibleSellOres, OreIndex)

		local CoinValue = Ore:GetAttribute("CoinValue")
		local SellPrice = math.round(CoinValue * 1.5) * Amount
		SellTrades[i] = { ID = i, Ore = Ore.Name, Cost = SellPrice, Amount = Amount }
	end

	self.Trades = {
		Buy = BuyTrades,
		Sell = SellTrades,
	}
end

function MysteryMerchantService:PickRandomSpawn()
	local Spawns = ServerStorage.MysteryMerchant.Spawns:GetChildren()
	return Spawns[NumberGenerator:NextInteger(1, #Spawns)].CFrame
end

function MysteryMerchantService:Spawn()
	local SpawnCFrame = self:PickRandomSpawn() :: CFrame
	NPC.Parent = workspace

	if not NPC:HasTag("MysteryMerchant/OpenGUI") then
		NPC:AddTag("MysteryMerchant/OpenGUI")
	end

	NPC:PivotTo(SpawnCFrame)
	MessageService:SendMessage({
		Message = "Mystery Merchant has spawned somewhere on the map",
		Prefix = "Mystery Merchant",
		HasPrefix = false,
		MessageColor = Color3.new(1, 1, 1),
	})
end

function MysteryMerchantService:DeSpawn()
	NPC:PivotTo(CFrame.new(0, 0, 0))
	NPC.Parent = ServerStorage.MysteryMerchant
	MessageService:SendMessage({
		Message = "The Mystery Merchant is gone",
		Prefix = "",
		HasPrefix = false,
		MessageColor = Color3.new(1, 1, 1),
	})
end

-- [[ CLIENT ]] --

function MysteryMerchantService.Client:GetTrades()
	return self.Server.Trades
end

function MysteryMerchantService.Client:BuyTrade(Player: Player, TradeID: number)
	local _, Trade: TradeInfo = self.Server:GetTradeByTradeID(TradeID, "Sell")

	local CostOreList = Core.OreList.New()
	CostOreList:AddGold(Trade.Cost)

	local RewardList = Core.OreList.New()
	RewardList:AddOre(Trade.Ore, Trade.Amount)

	local Success = DataService:HandleCosts(Player, CostOreList)
	if Success then
		PlayerStatsService:GiveOres(Player, RewardList)
	end
end

function MysteryMerchantService.Client:SellTrade(Player: Player, TradeID: number)
	local _, Trade: TradeInfo = self.Server:GetTradeByTradeID(TradeID, "Buy")

	local CostOreList = Core.OreList.New()
	CostOreList:AddOre(Trade.Ore, Trade.Amount)

	local RewardList = Core.OreList.New()
	RewardList:AddGold(Trade.Cost)

	local Success = DataService:HandleCosts(Player, CostOreList)
	if Success then
		PlayerStatsService:GiveOres(Player, RewardList)
	end
end

-- [[ KNIT ]] --

function MysteryMerchantService:KnitStart()
	MessageService = Knit.GetService("MessageService")
	DataService = Knit.GetService("DataService")
	PlayerStatsService = Knit.GetService("PlayerStatsService")

	task.spawn(function()
		while true do
			self:DeSpawn()

			local IdleTime = NumberGenerator:NextInteger(Config.MerchantIdleLength.Min, Config.MerchantIdleLength.Max)
			task.wait(IdleTime)

			self:GenerateTrades()
			self:Spawn()

			local LivingTime =
				NumberGenerator:NextInteger(Config.MerchantLivingLength.Min, Config.MerchantLivingLength.Max)
			task.wait(LivingTime)
		end
	end)
end

return MysteryMerchantService
