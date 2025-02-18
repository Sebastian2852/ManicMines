local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Profiler = require(ReplicatedStorage.Game.Modules.Profiler)
local Promise = require(ReplicatedStorage.Packages.Promise)

local MineService = Knit.CreateService({
	Name = "MineService",
	Client = {},

	MineStats = {
		BlocksGenerated = 0,
	},
})

local Collapsing = false
local BlockSize = Core.GameConfig.Mine.BlockSize
local UsedPositions = {}
local TopLayerPositions = {}

local NumberGenerator = Random.new()

local function KeyVector(Vector: Vector3)
	return `{Vector.X};{Vector.Y};{Vector.Z}`
end

function MineService:AddAirPosition(Position: Vector3)
	UsedPositions[KeyVector(Position)] = true
end

function MineService:IsPositionAir(Position: Vector3)
	return UsedPositions[KeyVector(Position)] == true
end

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

function MineService:SnapPositionToGrid(Position: Vector3): Vector3
	return Vector3.new(
		math.round(Position.X / BlockSize.X) * BlockSize.X,
		math.round(Position.Y / BlockSize.Y) * BlockSize.Y,
		math.round(Position.Z / BlockSize.Z) * BlockSize.Z
	)
end

local MineSpawn = Workspace.Game.MineSpawn
local OriginalMineSpawnPosition = MineService:SnapPositionToGrid(MineSpawn.CFrame.Position)
local HiddenMineSpawnPosition = MineService:SnapPositionToGrid(OriginalMineSpawnPosition + Vector3.new(0, 50, 0))
local TopLayerY = OriginalMineSpawnPosition.Y

local function ConvertYLevelToDepth(WorldY: number): number
	local Top = TopLayerY
	local CellSize = Core.GameConfig.Mine.BlockSize.Y
	return math.floor((Top - WorldY) / CellSize)
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

		if Ore:GetAttribute("CaveOnly") and InCave then
			table.insert(SpawnableOres, Ore)
			continue
		end

		if Ore:GetAttribute("NoCave") and not InCave then
			table.insert(SpawnableOres, Ore)
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

local function PickRandomOre(Depth: number, InCave: boolean)
	local Ores = GetSpawnableOres(Depth, InCave)

	local function GetRemainingOres(OresLeft: { BasePart })
		for i, Ore: Part in pairs(OresLeft) do
			local RandomNumber = NumberGenerator:NextInteger(1, Ore:GetAttribute("Rarity"))
			if RandomNumber ~= 1 then
				table.remove(OresLeft, i)
			end
		end
		return OresLeft
	end

	if #Ores > 1 then
		repeat
			Ores = GetRemainingOres(Ores)
		until #Ores == 1
	end

	if #Ores == 1 then
		local Ore = Ores[1]
		local RandomNumber = NumberGenerator:NextInteger(1, Ore:GetAttribute("Rarity") or 1)
		if RandomNumber == 1 then
			return Ore
		end
	end

	return Core.Assets.Stone
end

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
				local Position = TopLeftPosition + Vector3.new((X - 1) * BlockSize.X, 0, (Y - 1) * BlockSize.Z)
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

function MineService:Collapse()
	if Collapsing then
		return
	end
	Collapsing = true
	ShowMineSpawn()
	Workspace.Game.Mine:ClearAllChildren()
	NumberGenerator = Random.new()

	task.wait(1)

	self:GenerateTopLayer()
	Collapsing = false
end

function MineService:GetRandomObject()
	return NumberGenerator:Clone()
end

function MineService:GenerateAtPositionAsync(Position: Vector3, InCave: boolean)
	return Promise.new(function(Resolve)
		if self:IsPositionAir(Position) then
			Resolve()
			return
		end

		if Position.Y > TopLayerY then
			Resolve()
			return
		end

		self:AddAirPosition(Position)

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
		Block:PivotTo(CFrame.new(Position))
		Block.Parent = Workspace.Game.Mine
		Block.Anchored = true
		self.MineStats.BlocksGenerated += 1

		if Position.Y == TopLayerY and not (TopLayerPositions[KeyVector(Position)] == true) then
			Block.Color = Core.Util:TintColor(Block.Color, Color3.new(0, 0, 0))
			Resolve(Block)
			return
		end

		Block:SetAttribute("CanMine", true)
		Resolve(Block)
	end)
end

function MineService:GenerateAroundBlockAsync(Block: BasePart)
	return Promise.new(function(Resolve)
		local Origin = Block.Position
		local Blocks = {}

		local Gens = {}

		for _, Offset: Vector3 in pairs(BlockGenerationOffsets) do
			table.insert(
				Gens,
				self:GenerateAtPositionAsync(Origin + Offset):andThen(function(NewBlock)
					table.insert(Blocks, NewBlock)
				end)
			)
		end

		Promise.all(Gens):await()
		Resolve(Blocks)
	end)
end

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

function MineService:BlockMined(Block: BasePart)
	if Block == nil then
		return
	end

	if self.MineStats.BlocksGenerated >= Core.GameConfig.Mine.BlocksToCollapse then
		self:Collapse()
		return
	end

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
	local function SetMaxHealthAttrib(Ore: BasePart)
		Ore:SetAttribute("MaxHealth", Ore:GetAttribute("Health"))
	end

	SetMaxHealthAttrib(Core.Assets.Stone)
	for _, v in pairs(Core.Assets.Ores:GetChildren()) do
		SetMaxHealthAttrib(v)
	end

	self:GenerateTopLayer()
	self:GenerateAtPositionAsync(Vector3.new(0, 0, 0))

	local Timer = Profiler.Timer.new("RandomOre")
	local Ore = PickRandomOre()
	Timer:Stop()

	print(Ore)
end

return MineService
