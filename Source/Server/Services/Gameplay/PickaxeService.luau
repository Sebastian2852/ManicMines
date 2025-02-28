local ReplicatedStorage = game.ReplicatedStorage

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Promise = require(ReplicatedStorage.Packages.Promise)

local PlayerStatsService
local DataService
local MineService
local LogService

local PickaxeAssetFolder = game.ReplicatedStorage.Assets.Pickaxe
local Pickaxes = PickaxeAssetFolder.Pickaxes

local PickaxeService = Knit.CreateService({
	Name = "PickaxeService",
	Client = {
		UpdateMiningSelection = Knit.CreateSignal(),
		UpdateMiningPower = Knit.CreateSignal(),
		UpdateOptimalDepth = Knit.CreateSignal(),
		PlayHitSound = Knit.CreateSignal(),
		PlayBreakSound = Knit.CreateSignal(),
	},
})

PickaxeService.Mining = {}

--[[ PUBLIC ]]
--

--[=[
Calculates the time to mine based on the health passed
]=]
function PickaxeService:CalculateTimeToMine(Player: Player, Health: number): number
	local Pickaxe: Instance = self:GetPlayerPickaxe(Player)

	local HitsNeeded = math.ceil(Health / Pickaxe:GetAttribute("Damage"))
	local TimePerHit = Pickaxe:GetAttribute("Delay")
	local TotalTime = HitsNeeded * TimePerHit
	return Core.Util:RoundToxDP(TotalTime, 1)
end

--[=[
Calculates the mining power for the given player
]=]
function PickaxeService:CalculateMiningPower(Player: Player, SendToPlayer: boolean?): number
	local Pickaxe = self:GetPlayerPickaxe(Player)
	local DataFolder = DataService:GetPlayerDataFolder(Player) :: Core.DataFolder
	if not Pickaxe then
		return -1
	end

	local Damage = Pickaxe:GetAttribute("Damage") :: number or 0
	local Delay = Pickaxe:GetAttribute("Delay") :: number or 0
	local Range = Pickaxe:GetAttribute("Range") :: number or 0

	local Upgrade = DataFolder.Tycoon.Upgrades:FindFirstChild("ResearchAndDevelopment").Value
	local UpgradeMultiplier = (Upgrade or 0) * 1.2

	local MiningPower = math.floor((Damage * Delay * Range) * (UpgradeMultiplier == 0 and 1 or UpgradeMultiplier) * 10)

	SendToPlayer = SendToPlayer == nil and false or SendToPlayer
	if SendToPlayer then
		self.Client.UpdateMiningPower:Fire(Player, MiningPower)
	end

	return MiningPower
end

--[=[
Get the player's optimal depth
]=]
function PickaxeService:GetOptimalDepth(Player: Player, SendToPlayer: boolean?): number
	local DataFolder = DataService:GetPlayerDataFolder(Player) :: Core.DataFolder
	local UpgradeValue = DataFolder.Tycoon.Upgrades:FindFirstChild("DataAndAnalysis").Value
	local LevelConfig: Configuration =
		Core.Assets.Tycoon.Upgrades:FindFirstChild("DataAndAnalysis"):FindFirstChild(tostring(UpgradeValue))
	local OptimalDepth = LevelConfig:FindFirstChild("OptimalDepth").Value

	SendToPlayer = SendToPlayer == nil and false or SendToPlayer

	if SendToPlayer then
		self.Client.UpdateOptimalDepth:Fire(Player, OptimalDepth)
	end

	return OptimalDepth
end

--[=[
Check if the player can actually mine the block they want to
]=]
function PickaxeService:VerifyIfCanMine(Player: Player, Character: Model, ObjectToMine: BasePart): boolean
	local Pickaxe: Instance = self:GetPlayerPickaxe(Player)
	if not Pickaxe then
		return false
	end
	if not ObjectToMine then
		return false
	end

	local Distance: number = (Character.PrimaryPart.Position - ObjectToMine.Position).Magnitude

	if Distance > Pickaxe:GetAttribute("Range") then
		return false
	end
	if not ObjectToMine:GetAttribute("CanMine") then
		return false
	end

	return true
end

--[=[
Returns true/false depending on if the player has a pickaxe tool
]=]
function PickaxeService:DoesPlayerHavePickaxe(Player: Player): boolean
	for _, Tool in pairs(Player.Backpack:GetChildren()) do
		if Tool:HasTag("Pickaxe") and Tool:IsA("Tool") then
			return true
		end
	end

	if Player.Character then
		for _, Tool in pairs(Player.Character:GetChildren()) do
			if Tool:HasTag("Pickaxe") and Tool:IsA("Tool") then
				return true
			end
		end
	end

	return false
end

--[=[
Returns the player's pickaxe tool
]=]
function PickaxeService:GetPlayerPickaxe(Player: Player): Tool?
	for _, Tool in pairs(Player.Backpack:GetChildren()) do
		if Tool:HasTag("Pickaxe") and Tool:IsA("Tool") then
			return Tool
		end
	end

	if Player.Character then
		for _, Tool in pairs(Player.Character:GetChildren()) do
			if Tool:HasTag("Pickaxe") and Tool:IsA("Tool") then
				return Tool
			end
		end
	end

	return nil
end

--[=[
Remove the current pickaxe the player has in their inventory or from their
character if they have it equipped
]=]
function PickaxeService:RemovePickaxeFromPlayer(Player: Player)
	if not self:DoesPlayerHavePickaxe(Player) then
		return
	end

	LogService:Log("Removing " .. Player.Name .. "'s pickaxe")

	for _, Tool: Tool in pairs(Player.Backpack:GetChildren()) do
		if not Tool:IsA("Tool") then
			continue
		end
		if not Tool:HasTag("Pickaxe") then
			continue
		end
		Tool:Destroy()
		break
	end

	if Player.Character then
		for _, Tool in pairs(Player.Character:GetChildren()) do
			if not Tool:IsA("Tool") then
				continue
			end
			if not Tool:HasTag("Pickaxe") then
				continue
			end
			Tool:Destroy()
			break
		end
	end
end

--[=[
Give the player thier currently equipped pickaxe
]=]
function PickaxeService:GivePickaxeToPlayer(Player: Player)
	LogService:Log("Giving " .. Player.Name .. " a pickaxe")
	repeat
		task.wait(1)
	until Player.Character

	if self:DoesPlayerHavePickaxe(Player) then
		self:RemovePickaxeFromPlayer(Player)
	end

	local DataFolder = DataService:GetPlayerDataFolder(Player)
	LogService:Assert(DataFolder, "No data folder")

	local CurrentPickaxeID: number = DataFolder.Pickaxes.Equipped.Value
	local CurrentPickaxeConfig: Configuration = Pickaxes:FindFirstChild(CurrentPickaxeID)
	LogService:Assert(CurrentPickaxeConfig, "No pickaxe config")

	local Pickaxe: Tool = CurrentPickaxeConfig:FindFirstChildWhichIsA("Tool")
	local NewPickaxe: Tool = Pickaxe:Clone()
	local NewScript: LocalScript = ReplicatedStorage.Game.Scripts.Pickaxe:Clone()
	NewPickaxe.Parent = Player.Backpack
	NewScript.Parent = NewPickaxe
	NewPickaxe:AddTag("Pickaxe")

	self:CalculateMiningPower(Player, true)
	self:GetOptimalDepth(Player, true)
end

--[=[
Makes the given player start mining the given block
]=]
function PickaxeService:StartMining(Player: Player, ObjectToMine: BasePart)
	if ObjectToMine == nil then
		return
	end

	if not self.Mining[Player.UserId] then
		LogService:Warn("Player should have an entry in mining table?")
		self.Mining[Player.UserId] = { Mining = false, Object = nil, Cooldown = false }
	end

	if self.Mining[Player.UserId].Cooldown then
		return
	end
	if self.Mining[Player.UserId].Mining then
		return
	end

	local DataFolder = DataService:GetPlayerDataFolder(Player)
	if not DataFolder then
		return
	end

	if
		DataFolder.Inventory.InventoryItemCount.Value + ObjectToMine:GetAttribute("AmountDroppedWhenMined")
		> DataFolder.Inventory.InventoryCap.Value
	then
		return
	end

	local Character = Player.Character
	local Pickaxe = self:GetPlayerPickaxe(Player)

	if not Character then
		return
	end
	if not self:VerifyIfCanMine(Player, Character, ObjectToMine) then
		print("Cant mine")
		return
	end

	DataFolder.ServerMining.Value = true
	self.Mining[Player.UserId].Mining = true
	self.Mining[Player.UserId].Object = ObjectToMine

	ObjectToMine:SetAttribute("MinedBy", Player.UserId)
	ObjectToMine:SetAttribute("BeingMined", true)

	LogService:Log(Player.Name .. " started mining")

	local OptimalDepth = self:GetOptimalDepth(Player)

	local OreList = Core.OreList.New()
	OreList:AddOre(ObjectToMine.Name, ObjectToMine:GetAttribute("AmountDroppedWhenMined"))
	MineService:GenerateAroundBlockAsync(ObjectToMine)
	while self.Mining[Player.UserId].Mining and self:VerifyIfCanMine(Player, Character, ObjectToMine) do
		local Health = ObjectToMine:GetAttribute("Health")
		local MaxHealth = ObjectToMine:GetAttribute("MaxHealth")
		local Damage = Pickaxe:GetAttribute("Damage")
		local Delay = Pickaxe:GetAttribute("Delay")
		local IsDestroyed = ObjectToMine == nil or ObjectToMine:GetAttribute("_BROKEN", true)

		if IsDestroyed then
			return
		end

		if Health <= 0 then
			self.Client.PlayBreakSound:FireAll(ObjectToMine)
			self:StopMining(Player)
			task.wait(Delay)
			MineService:BlockMined(ObjectToMine)
			PlayerStatsService:MinedOre(Player, OreList)
			break
		end

		local Depth = MineService:YLevelToDepth(ObjectToMine.CFrame.Position.Y)

		if Depth >= OptimalDepth then
			Health -= (Damage / 2) / Depth
		else
			Health -= Damage
		end

		ObjectToMine:SetAttribute("Health", Health)
		self.Client.UpdateMiningSelection:Fire(
			Player,
			ObjectToMine.Name,
			self:CalculateTimeToMine(Player, Health),
			math.ceil((1 - (Health / MaxHealth)) * 100),
			(Health / MaxHealth)
		)

		if Health <= 0 then
			self.Client.PlayBreakSound:FireAll(ObjectToMine)
			self:StopMining(Player)
			task.wait(Delay)
			MineService:BlockMined(ObjectToMine)
			PlayerStatsService:MinedOre(Player, OreList)
			task.wait(Delay / 2)
			break
		end

		task.wait(Delay)
	end

	OreList:Destroy()
end

--[=[
Makes the player stop mining the given block
]=]
function PickaxeService:StopMining(Player: Player)
	return Promise.new(function(Resolve, Reject)
		if not self.Mining[Player.UserId] then
			self.Mining[Player.UserId] = { Mining = false, Object = nil, Cooldown = false }
			Reject(Player.Name .. " has no entry in the table")
		end

		if not self.Mining[Player.UserId].Mining then
			return
		end

		local DataFolder = DataService:GetPlayerDataFolder(Player)
		if not DataFolder then
			return
		end

		if self.Mining[Player.UserId].Object ~= nil then
			self.Mining[Player.UserId].Object:SetAttribute("MinedBy", 0)
			self.Mining[Player.UserId].Object:SetAttribute("BeingMined", false)
		end

		local Pickaxe = self:GetPlayerPickaxe(Player)
		LogService:Log(Player.Name .. " stopped mining")

		self.Mining[Player.UserId].Cooldown = true
		DataFolder.ServerMining.Value = false
		self.Mining[Player.UserId].Mining = false
		self.Mining[Player.UserId].Object = nil

		task.wait(Pickaxe:GetAttribute("Delay") * 2)
		self.Mining[Player.UserId].Cooldown = false

		Resolve()
	end)
end

--[=[
returns true/false if the player owns the given pickaxe
]=]
function PickaxeService:DoesPlayerOwnPickaxe(Player: Player, Pickaxe: Configuration): boolean
	local DataFolder: Core.DataFolder = DataService:GetPlayerDataFolder(Player)
	local DataValue = DataFolder.Pickaxes.Owned:FindFirstChild(Pickaxe.Name)
	if not DataValue then
		return false
	end
	return DataValue.Value
end

--[=[
Attempts to equip the given pickaxe for the given player. Returns true/false if it was actually equipped
]=]
function PickaxeService:EquipPickaxe(Player: Player, Pickaxe: Configuration): boolean
	if not self:DoesPlayerOwnPickaxe(Player, Pickaxe) then
		return false
	end
	local DataFolder: Core.DataFolder = DataService:GetPlayerDataFolder(Player)
	DataFolder.Pickaxes.Equipped.Value = tonumber(Pickaxe.Name)
	self:GivePickaxeToPlayer(Player)
	return true
end

--[=[
Returns the config of the currently equipped pickaxe for the given player
]=]
function PickaxeService:GetEquippedPickaxeConfig(Player: Player): Configuration
	local DataFolder: Core.DataFolder = DataService:GetPlayerDataFolder(Player)
	local Equipped = DataFolder.Pickaxes.Equipped
	local Config = Core.Assets.Pickaxe.Pickaxes:FindFirstChild(Equipped.Value)
	return Config
end

--[[ CLIENT ]]
--

--[=[
Get the players pickaxe
]=]
function PickaxeService.Client:GetPickaxe(Player: Player)
	return self.Server:GetPlayerPickaxe(Player)
end

--[=[
Makes the player start mining a given block
]=]
function PickaxeService.Client:StartMining(Player: Player, ObjectToMine: BasePart)
	self.Server:StartMining(Player, ObjectToMine)
end

--[=[
Stops the player from mining aswell as starting their cooldown
]=]
function PickaxeService.Client:StopMining(Player: Player)
	self.Server:StopMining(Player)
end

--[=[
returns the time it will take to mine a block with the given health
]=]
function PickaxeService.Client:CalculateTimeToMine(Player: Player, Health: number)
	return self.Server:CalculateTimeToMine(Player, Health)
end

--[=[
Equips the given pickaxe. Returns true false if it was actually equipped
]=]
function PickaxeService.Client:EquipPickaxe(Player: Player, Pickaxe: Configuration)
	return self.Server:EquipPickaxe(Player, Pickaxe)
end

--[=[
Attempts to buy the given pickaxe config
]=]
function PickaxeService.Client:BuyPickaxe(Player: Player, PickaxeConfig: Configuration): boolean
	local Costs = PickaxeConfig:FindFirstChild("Ores")
	local DataFolder: Core.DataFolder = DataService:GetPlayerDataFolder(Player)

	local Success = Costs and false or true
	if Costs then
		Success = DataService:HandleCosts(Player, Core.OreList.CreateFromFolder(Costs))
	end

	if Success then
		DataFolder.Pickaxes.Owned:FindFirstChild(PickaxeConfig.Name).Value = true
		self.Server:EquipPickaxe(Player, PickaxeConfig)
	end
	return Success
end

function PickaxeService.Client:GetMiningPower(Player: Player): number
	return self.Server:CalculateMiningPower(Player, false)
end

function PickaxeService.Client:GetOptimalDepth(Player: Player): number
	return self.Server:GetOptimalDepth(Player, false)
end

--[[ KNIT ]]
--

function PickaxeService:KnitInit()
	LogService = Knit.GetService("LogService")

	LogService:Log("Setting up pickaxes")
	for _, PickaxeConfig: Configuration in pairs(Core.Assets.Pickaxe.Pickaxes:GetChildren()) do
		LogService:Log("Setting up pickaxe: " .. PickaxeConfig:GetFullName())
		local PickaxeTool = PickaxeConfig:FindFirstChildWhichIsA("Tool")
		if not PickaxeTool then
			LogService:Warn("Pickaxe config has no pickaxe tool: " .. PickaxeConfig:GetFullName())
			continue
		end

		PickaxeTool.CanBeDropped = false
		PickaxeTool:SetAttribute("Range", PickaxeTool:GetAttribute("Range") * Core.GameConfig.Mine.BlockSize.X)

		LogService:Log("    - Setting up pickaxe: " .. PickaxeTool:GetFullName())
		local Handle = PickaxeTool:FindFirstChild("Handle")
		if not Handle then
			LogService:Warn("Pickaxe tool has no handle?: " .. PickaxeTool:GetFullName())
			continue
		end

		for _, Weld: Weld in pairs(PickaxeTool:GetDescendants()) do
			if Weld:IsA("Weld") then
				LogService:Log("    - Destroyed weld: " .. Weld:GetFullName())
				Weld:Destroy()
			end

			if Weld:IsA("WeldConstraint") then
				LogService:Log("    - Destroyed weld: " .. Weld:GetFullName())
				Weld:Destroy()
			end
		end

		for _, Part: BasePart in pairs(PickaxeTool:GetDescendants()) do
			if Part.Name == "Handle" then
				continue
			end
			if not Part:IsA("BasePart") then
				continue
			end

			local Weld = Instance.new("WeldConstraint")
			Weld.Name = Part.Name .. " -> " .. Handle.Name
			Weld.Part0 = Part
			Weld.Part1 = Handle
			Weld.Parent = Handle
			LogService:Log("    - Welded pickaxe parts:", Part.Name .. " -> " .. Handle.Name)
		end

		for _, Part: BasePart in pairs(PickaxeTool:GetDescendants()) do
			if not Part:IsA("BasePart") then
				continue
			end

			Part.Anchored = false
			Part.CanCollide = false
			LogService:Log("    - Setup pickaxe part: " .. Part.Name)
		end
	end
end

function PickaxeService:KnitStart()
	DataService = Knit.GetService("DataService")
	MineService = Knit.GetService("MineService")
	PlayerStatsService = Knit.GetService("PlayerStatsService")

	game.Players.PlayerAdded:Connect(function(Player)
		self.Mining[Player.UserId] = { Mining = false, Object = nil, Cooldown = false }

		Player.CharacterAdded:Connect(function(Character: Model)
			Character.Parent = workspace.Game.Players
		end)
	end)

	game.Players.PlayerRemoving:Connect(function(Player)
		if self.Mining[Player.UserId] then
			self.Mining[Player.UserId] = nil
		end
	end)

	self.Client.PlayHitSound:Connect(function(_, Block)
		self.Client.PlayHitSound:FireAll(Block)
	end)
end

return PickaxeService
