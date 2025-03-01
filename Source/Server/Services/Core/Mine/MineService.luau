local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Profiler = require(ReplicatedStorage.Game.Modules.Profiler)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Signal = require(ReplicatedStorage.Packages.Signal)

local MineService = Knit.CreateService({
	Name = "MineService",
	Client = {},

	OnBlockMined = Signal.new(),

	MineStats = {
		BlocksGenerated = 0,
	},
})

local TeleportService

local Collapsing = false
local BlockSize = Core.GameConfig.Mine.BlockSize
local UsedPositions = {}
local TopLayerPositions = {}

local NumberGenerator = Random.new()

local BlockGenerationOffsets = {
	-- Direct neighbors
	Vector3.new(BlockSize.X, 0, 0),
	Vector3.new(-BlockSize.X, 0, 0),
	Vector3.new(0, BlockSize.Y, 0),
	Vector3.new(0, -BlockSize.Y, 0),
	Vector3.new(0, 0, BlockSize.Z),
	Vector3.new(0, 0, -BlockSize.Z),

	-- Diagonal neighbors (XY plane)
	Vector3.new(BlockSize.X, BlockSize.Y, 0),
	Vector3.new(-BlockSize.X, BlockSize.Y, 0),
	Vector3.new(BlockSize.X, -BlockSize.Y, 0),
	Vector3.new(-BlockSize.X, -BlockSize.Y, 0),

	-- Diagonal neighbors (XZ plane)
	Vector3.new(BlockSize.X, 0, BlockSize.Z),
	Vector3.new(-BlockSize.X, 0, BlockSize.Z),
	Vector3.new(BlockSize.X, 0, -BlockSize.Z),
	Vector3.new(-BlockSize.X, 0, -BlockSize.Z),

	-- Diagonal neighbors (YZ plane)
	Vector3.new(0, BlockSize.Y, BlockSize.Z),
	Vector3.new(0, -BlockSize.Y, BlockSize.Z),
	Vector3.new(0, BlockSize.Y, -BlockSize.Z),
	Vector3.new(0, -BlockSize.Y, -BlockSize.Z),

	-- Corner neighbors
	Vector3.new(BlockSize.X, BlockSize.Y, BlockSize.Z),
	Vector3.new(-BlockSize.X, BlockSize.Y, BlockSize.Z),
	Vector3.new(BlockSize.X, -BlockSize.Y, BlockSize.Z),
	Vector3.new(-BlockSize.X, -BlockSize.Y, BlockSize.Z),
	Vector3.new(BlockSize.X, BlockSize.Y, -BlockSize.Z),
	Vector3.new(-BlockSize.X, BlockSize.Y, -BlockSize.Z),
	Vector3.new(BlockSize.X, -BlockSize.Y, -BlockSize.Z),
	Vector3.new(-BlockSize.X, -BlockSize.Y, -BlockSize.Z),
}

local MineSpawn = Workspace.Game.MineSpawn
local OriginalMineSpawnPosition
local HiddenMineSpawnPosition
local TopLayerY

local function ConvertYLevelToDepth(WorldY: number): number
	local Top = TopLayerY
	local CellSize = Core.GameConfig.Mine.BlockSize.Y
	return math.floor((Top - WorldY) / CellSize)
end

local function KeyVector(Vector: Vector3)
	return `{Vector.X};{Vector.Y};{Vector.Z}`
end

local function HideMineSpawn()
	MineSpawn:PivotTo(CFrame.new(HiddenMineSpawnPosition))
	MineSpawn.Transparency = 1
	MineSpawn.CanCollide = false
end

local function ShowMineSpawn()
	MineSpawn:PivotTo(CFrame.new(OriginalMineSpawnPosition))
	MineSpawn.Transparency = 0
	MineSpawn.CanCollide = true
end

local function SetupStoneBlock(StoneBlock: BasePart)
	local NormalStone = Core.Assets.Stone
	local Attribs = StoneBlock:GetAttributes()

	for Key, _ in pairs(StoneBlock:GetAttributes()) do
		StoneBlock:SetAttribute(Key, nil)
	end

	for Key, Value in pairs(NormalStone:GetAttributes()) do
		StoneBlock:SetAttribute(Key, Value)
	end

	for Key, Value in pairs(Attribs) do
		StoneBlock:SetAttribute(Key, Value)
	end
end

local function GetSpawnableOres(Depth: number, InCave: boolean)
	local Ores = Core.Assets.Ores:GetChildren()
	local SpawnableOres = {}

	for _, Ore: Part in ipairs(Ores) do
		local SpawningRange = Ore:GetAttribute("SpawningRange")

		local MinY = SpawningRange.Min
		local MaxY = SpawningRange.Max

		if Ore:GetAttribute("CaveOnly") and not InCave then
			continue
		end

		if Ore:GetAttribute("NoCave") and InCave then
			continue
		end

		if (Depth or math.huge) >= (MinY or -math.huge) and (Depth or math.huge) <= (MaxY or -math.huge) then
			table.insert(SpawnableOres, Ore)
			continue
		end
	end

	if #SpawnableOres == 0 then
		warn("No ores that can spawn")
		return { Core.Assets.Stone }
	end

	return SpawnableOres
end

local function GetRarityFromCurve(
	OreSpawningRange: NumberRange,
	NormalRarity: number,
	Depth: number,
	Curve: NumberSequence
)
	local NormalDepth = (Depth - OreSpawningRange.Min) / (OreSpawningRange.Max - OreSpawningRange.Min)
	local Rarity = Core.Util:EvaluateNumberSequence(Curve, NormalDepth)

	local AdjustedRarity = 0

	if Rarity <= 0 then
		AdjustedRarity = math.huge
	elseif Rarity >= 1 then
		AdjustedRarity = 1
	else
		local x = 1 - (Rarity * 2)
		AdjustedRarity = NormalRarity ^ x
	end

	return AdjustedRarity
end

local function PickRandomOre(Depth: number, InCave: boolean)
	local Ores = GetSpawnableOres(Depth, InCave)
	local TotalWeight = 0

	for _, v in pairs(Ores) do
		TotalWeight += GetRarityFromCurve(
			v:GetAttribute("SpawningRange"),
			v:GetAttribute("Rarity"),
			Depth,
			v:GetAttribute("SpawningCurve")
		)
	end

	local RandomWeight = NumberGenerator:NextInteger(1, TotalWeight)
	local CurrentWeight = 0
	local Ore = nil

	for _, v in pairs(Ores) do
		CurrentWeight += GetRarityFromCurve(
			v:GetAttribute("SpawningRange"),
			v:GetAttribute("Rarity"),
			Depth,
			v:GetAttribute("SpawningCurve")
		)
		if RandomWeight <= CurrentWeight then
			local Number = NumberGenerator:NextInteger(1, v:GetAttribute("Rarity"))
			if Number == 1 then
				Ore = v
				break
			end
		end
	end

	return Ore and Ore or Core.Assets.Stone
end

function MineService:UpdateMiningConditions()
	local Generated = self.MineStats.BlocksGenerated
	local BlocksToCollapse = Core.GameConfig.Mine.BlocksToCollapse
	local Percentage = (Generated / BlocksToCollapse) * 100
	ReplicatedStorage.Player.MiningConditions.Value = Percentage
end

-- [[ PUBLIC ]] --

--[=[
Add a position to the UsedPositions table
]=]
function MineService:AddAirPosition(Position: Vector3)
	Position = self:SnapPositionToGrid(Position)
	UsedPositions[KeyVector(Position)] = true
end

--[=[
Returns if the given position is in the UsedPositions table
]=]
function MineService:IsPositionAir(Position: Vector3)
	Position = self:SnapPositionToGrid(Position)
	return UsedPositions[KeyVector(Position)] == true
end

--[=[
Returns the current NumberGenerator that the mine is using
to generate random numbers
]=]
function MineService:GetRandomObject()
	return NumberGenerator:Clone()
end

--[=[
Snaps the given position to the mine's grid
]=]
function MineService:SnapPositionToGrid(Position: Vector3): Vector3
	return Vector3.new(
		math.floor(Position.X / BlockSize.X + 0.5) * BlockSize.X,
		math.floor(Position.Y / BlockSize.Y + 0.5) * BlockSize.Y,
		math.floor(Position.Z / BlockSize.Z + 0.5) * BlockSize.Z
	)
end

--[=[
Generates the top layer of the mine
]=]
function MineService:GenerateTopLayer()
	ShowMineSpawn()

	local BlocksToGenerateX = math.round(MineSpawn.Size.X / BlockSize.X)
	local BlocksToGenerateY = math.round(MineSpawn.Size.Z / BlockSize.Z)

	local TopLeftPosition = Vector3.new(
		OriginalMineSpawnPosition.X - ((MineSpawn.Size.X / 2) - (BlockSize.X / 2)),
		OriginalMineSpawnPosition.Y,
		OriginalMineSpawnPosition.Z - ((MineSpawn.Size.Z / 2) - (BlockSize.X / 2))
	)

	UsedPositions = {}
	TopLayerPositions = {}

	local function Generate(Y)
		return Promise.new(function(Resolve)
			for X = 1, BlocksToGenerateX, 1 do
				local Position = self:SnapPositionToGrid(
					TopLeftPosition + Vector3.new((X - 1) * BlockSize.X, 0, (Y - 1) * BlockSize.Z)
				)
				local AbovePos = Position + Vector3.new(0, BlockSize.Y, 0)

				TopLayerPositions[KeyVector(Position)] = true
				self:AddAirPosition(AbovePos)
				self:GenerateAtPositionAsync(Position)
			end
			Resolve()
		end)
	end

	local Promises = {}

	local Timer = Profiler.Timer.new("TopLayerGen")
	for Y = 1, BlocksToGenerateY, 1 do
		table.insert(Promises, Generate(Y))
	end
	Timer:Stop()

	Promise.all(Promises):andThen(function()
		task.wait(1)
		HideMineSpawn()
	end)
end

--[=[
Reset the mine seed
Clear all mine blocks
Generate new top layer
]=]
function MineService:Collapse()
	if Collapsing then
		return
	end
	Collapsing = true
	ShowMineSpawn()

	for _, DataFolder: Core.DataFolder in pairs(ReplicatedStorage.PlayerData:GetChildren()) do
		if DataFolder.Name == "Template" then
			continue
		end

		local Player = game.Players:GetPlayerByUserId(tonumber(DataFolder.Name))

		if not DataFolder.InTycoon.Value then
			TeleportService:TeleportPlayerToSurface(Player)
		end
	end

	Workspace.Game.Mine:ClearAllChildren()
	self.MineStats.BlocksGenerated = 0
	NumberGenerator = Random.new()

	task.wait(1)

	self:GenerateTopLayer()
	Collapsing = false
end

--[=[
Generates a random block at the given position
Returns a promise
]=]
function MineService:GenerateAtPositionAsync(Position: Vector3, InCave: boolean)
	return Promise.new(function(Resolve)
		local GeneratedBlock = self:GenerateAtPosition(Position, InCave)
		Resolve(GeneratedBlock)
	end)
end

--[=[
Generate a random block at the given position
]=]
function MineService:GenerateAtPosition(Position: Vector3, InCave: boolean)
	Position = self:SnapPositionToGrid(Position)
	if self:IsPositionAir(Position) then
		return
	end

	if Position.Y > TopLayerY then
		return
	end

	self:AddAirPosition(Position)

	local Layer = self:YLevelToLayer(Position.Y)

	local RandomNumber = NumberGenerator:NextInteger(1, Core.GameConfig.Mine.ChanceToGenerateOre)
	local Block: BasePart = nil
	local Stone = self:YLevelToLayer(Position.Y).Stone

	if RandomNumber == 1 then
		local Ore = PickRandomOre(ConvertYLevelToDepth(Position.Y), InCave)

		local NewOre = Stone:Clone() :: BasePart
		NewOre.Name = Ore.Name
		NewOre:ClearAllChildren()

		local AttribsToSet = Ore:GetAttributes()

		for Key, Value in pairs(AttribsToSet) do
			NewOre:SetAttribute(Key, Value)
		end

		for _, v in pairs(Ore:GetChildren()) do
			v:Clone().Parent = NewOre
		end

		Block = NewOre
	end

	if Block == nil then
		Stone = Stone:Clone()
		SetupStoneBlock(Stone)
		Block = Stone
	end

	Block.Size = Vector3.new(6, 6, 6)
	Block.Color = Block.Color:Lerp(
		Layer:GetAttribute("BlockColorOffset"),
		NumberGenerator:NextNumber(0, Layer:GetAttribute("BlockColorOffsetLerp"))
	)
	Block:PivotTo(CFrame.new(Position))
	Block.Parent = Workspace.Game.Mine
	Block.Anchored = true
	self.MineStats.BlocksGenerated += 1
	self:UpdateMiningConditions()

	if Position.Y == TopLayerY and not (TopLayerPositions[KeyVector(Position)] == true) then
		Block.Color = Core.Util:TintColor(Block.Color, Color3.new(0, 0, 0))
		return Block
	end

	Block:SetAttribute("CanMine", true)
	return Block
end

--[=[
Generates blocks all around the given block
Returns a promise
]=]
function MineService:GenerateAroundBlockAsync(Block: BasePart)
	return Promise.new(function(Resolve)
		local Origin = Block.Position
		local Blocks = {}

		for _, Offset: Vector3 in pairs(BlockGenerationOffsets) do
			local NewBlock = self:GenerateAtPosition(Origin + Offset)
			table.insert(Blocks, NewBlock)
		end

		Resolve(Blocks)
	end)
end

--[=[
Converts the given YLevel into a layer configuration
]=]
function MineService:YLevelToLayer(YLevel: number): Configuration
	local Depth = ConvertYLevelToDepth(YLevel)

	for _, LayerConfig in pairs(Core.Assets.Layers:GetChildren()) do
		local LayerDepth: NumberRange = LayerConfig:GetAttribute("Depth")
		if Depth >= LayerDepth.Min and Depth <= LayerDepth.Max then
			return LayerConfig
		end
	end

	return game.ReplicatedStorage.Assets.Layers.Surface
end

--[=[
If the mine needs to collapse it does then returns otherwise
Checks if the given block has a module to run and runs it in a seperate thread
Generates blocks around the given block
Destroys the given block
]=]
function MineService:BlockMined(Block: BasePart)
	if Block == nil then
		return
	end

	if self.MineStats.BlocksGenerated >= Core.GameConfig.Mine.BlocksToCollapse then
		self:Collapse()
		return
	end

	self.OnBlockMined:Fire(Block, Block.CFrame.Position)

	Promise.new(function(Resolve)
		local Module = Block:FindFirstChildWhichIsA("ModuleScript")
		if not Module then
			Resolve()
			return
		end

		local Success = require(Module)

		if not Success then
			warn("Block code FAILED")
		end

		Resolve(Success)
	end):andThen(function()
		self:GenerateAroundBlockAsync(Block):andThen(function()
			Block:Destroy()
		end)
	end)
end

function MineService:YLevelToDepth(YLevel: number)
	return ConvertYLevelToDepth(YLevel)
end

-- [[ CLIENT ]] --

function MineService.Client:GetBlocksToCollapse()
	return Core.GameConfig.Mine.BlocksToCollapse
end

function MineService.Client:ConvertToDepth(_, YLevel: number)
	return ConvertYLevelToDepth(YLevel)
end

function MineService.Client:GetLayerConfig(_, YLevel: number): Configuration
	return self.Server:YLevelToLayer(YLevel)
end

-- [[ KNIT ]] --

function MineService:KnitStart()
	TeleportService = Knit.GetService("TeleportService")

	OriginalMineSpawnPosition = MineService:SnapPositionToGrid(MineSpawn.CFrame.Position)
	HiddenMineSpawnPosition = MineService:SnapPositionToGrid(OriginalMineSpawnPosition + Vector3.new(0, 50, 0))
	TopLayerY = OriginalMineSpawnPosition.Y

	local function SetMaxHealthAttrib(Ore: BasePart)
		Ore:SetAttribute("MaxHealth", Ore:GetAttribute("Health"))
	end

	SetMaxHealthAttrib(Core.Assets.Stone)
	for _, v in pairs(Core.Assets.Ores:GetChildren()) do
		SetMaxHealthAttrib(v)
	end

	self:GenerateTopLayer()
	self:GenerateAtPositionAsync(Vector3.new(0, 0, 0))
end

return MineService
