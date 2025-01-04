local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Knit = require(ReplicatedStorage.Packages.Knit)
local OctoTree = require(ReplicatedStorage.Packages["octo-tree"])
local Promise = require(ReplicatedStorage.Packages.Promise)

local NumberGenerator = Random.new()

local TeleportService
local LogService
local CaveService

local MineService = Knit.CreateService {
	Name = "MineService",
	Client = {},
}

local MineSpawn: BasePart = workspace.Game.MineSpawn
local OriginalMineSpawnPosition = MineSpawn.Position

local OresFolder = game.ReplicatedStorage.Assets.Ores
local TopLayerY = 0
local TopLayerCanGenerate = true
local Collapsing = false

local BlockSize = Core.GameConfig.Mine.BlockSize
local MineOctree = OctoTree.new()
local UsedPositions = {}
local SpawnableOresCache = {}
local OreWeightCahce = {}

-- Stores blocks that are being generated before it is added to used positions
local GenerationCache = {}

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

MineService.TopLayerPositions = {}
MineService.LowestDepth = 0

MineService.MineStats = {
	BlocksGenerated = 0,
	OresGenerated = 0,
}

-- [[ PRIVATE ]] --

local function CollapseMine(NewSeed: number?)
	if Collapsing then
		return
	end

	LogService:Log("Mine collapsing")
	Collapsing = true
	for _, Player in pairs(game.Players:GetPlayers()) do
		TeleportService:TeleportPlayerToSurface(Player)
	end

	MineSpawn.Position = OriginalMineSpawnPosition
	MineSpawn.Transparency = 0

	LogService:Log("Deleting all blocks in mine")
	for _, Part in ipairs(workspace.Game.Mine:GetChildren()) do
		Part:Destroy()
	end
	MineOctree:ClearAllNodes()

	-- Reset the random number generator so that there is a new seed
	NumberGenerator = Random.new(NewSeed)

	task.wait(1)

	LogService:Log("Generating top layer")
	TopLayerCanGenerate = true
	MineService:GenerateTopLayer()
	MineSpawn.Transparency = 1
end

local function KeyPosition(Vector: Vector3): string
	return Vector.X .. ";" .. Core.Util:RoundToxDP(Vector.Y, 3) .. ";" .. Vector.Z
end

local function ConvertYLevelToDepth(WorldY: number): number
	local Top = TopLayerY
	local CellSize = Core.GameConfig.Mine.BlockSize.Y
	return math.floor((Top - WorldY) / CellSize)
end

local function ConvertDepthToYLevel(Depth: number): number
	local Top = TopLayerY
	local CellSize = Core.GameConfig.Mine.BlockSize.Y
	return Top - (Depth * CellSize)
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

local function GetProbabilityForOreUsingCurve(Rarity: number, Curve: NumberSequence, NormalizedY: number): number
	local RawProbability = Core.Util:EvaluateNumberSequence(Curve, NormalizedY)
	return Rarity - (Rarity / RawProbability)
end

local function GetTotalWeightOfOres(Ores: { BasePart }?)
	if Ores == nil then
		Ores = Core.Assets.Ores:GetChildren()
	end

	if OreWeightCahce[Ores] then
		return OreWeightCahce[Ores]
	end

	local Weight = 0

	for _, Ore: BasePart in pairs(Ores) do
		local Rarity = Ore:GetAttribute("Rarity")
		Weight += Rarity
	end

	OreWeightCahce[Ores] = Weight
	return Weight
end

-- [[ PUBLIC ]] --

--[=[
Returns a copy of the CURRENT random number generator
]=]
function MineService:GetRandomObject(): Random
	return NumberGenerator:Clone()
end

--[=[
Snaps the given position to the grid
]=]
function MineService:SnapPositionToGrid(Position: Vector3): Vector3
	return Vector3.new(
		math.round(Position.X / BlockSize.X) * BlockSize.X,
		math.round(Position.Y / BlockSize.Y) * BlockSize.Y,
		math.round(Position.Z / BlockSize.Z) * BlockSize.Z
	)
end

--[=[
Converts the World Y Level passed into a depth value
]=]
function MineService:ConvertToDepth(YLevel: number): number
	return ConvertYLevelToDepth(YLevel)
end

--[=[
Convert any Y level number into a layer config. If no valid layer config is found then the default
layer is used.
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
Gets a table of the possible ores that can spawn at a given Y level
]=]
function MineService:GetSpawnableOres(YLevel: number, InCave: boolean)
	local SpawnableOres = {}
	local Depth = ConvertYLevelToDepth(YLevel)

	if SpawnableOresCache[YLevel] then
		return SpawnableOresCache[YLevel]
	end

	for _, Ore in pairs(OresFolder:GetChildren()) do
		if Ore:GetAttribute("CaveOnly") and not InCave then
			continue
		end
		if Ore:GetAttribute("NoCave") and InCave then
			continue
		end

		local SpawningRange = Ore:GetAttribute("SpawningRange")

		local MinY = SpawningRange.Min
		local MaxY = SpawningRange.Max

		if MinY <= Depth and Depth <= MaxY then
			table.insert(SpawnableOres, Ore)
		end
	end

	SpawnableOresCache[YLevel] = SpawnableOres

	return SpawnableOres
end

--[=[
Generate a random ore to use
THIS RETURN THE PART; DOES NOT PUT IT IN THE MINE
]=]
function MineService:GenerateRandomOre(YLevel: number, Cave: boolean): BasePart
	local SpawnableOres = self:GetSpawnableOres(YLevel, Cave)

	if #SpawnableOres == 0 then
		LogService:Warn("No possible ores that can spawn!")
		return false
	end

	local NormalizedY = math.clamp((YLevel - TopLayerY) / (self.LowestDepth - TopLayerY), 0, 1)

	local TotalOreWeight = GetTotalWeightOfOres(SpawnableOres)
	local RandomWeight = NumberGenerator:NextInteger(1, TotalOreWeight)
	local CurrentWeight = 0
	local GeneratedBlock = nil

	for _, Ore: BasePart in pairs(SpawnableOres) do
		local OreWeight = Ore:GetAttribute("Rarity")
		CurrentWeight += OreWeight
		if RandomWeight <= CurrentWeight then
			if Ore:GetAttribute("SpawningCurve") then
				local Curve: NumberSequence = Ore:GetAttribute("SpawningCurve")
				local Probability = GetProbabilityForOreUsingCurve(OreWeight, Curve, NormalizedY)
				local RandomNumber = NumberGenerator:NextInteger(1, Probability)

				if RandomNumber == 1 then
					GeneratedBlock = Ore
					break
				end
			else
				GeneratedBlock = Ore
				break
			end
		end
	end

	if GeneratedBlock then
		return true, GeneratedBlock
	end

	return false
end

--[=[
Generates a block at a given position, has a random chance to be an ore. If a block info is passed then that block will be generated
]=]
function MineService:GenerateBlockAtPosition(
	Position: Vector3,
	InCave: boolean | false,
	BlockInfo: Core.OreListItem?,
	Tint: Color3?
)
	if self:IsPositionAir(Position) then
		return
	end
	Position = self:SnapPositionToGrid(Position)

	if GenerationCache[KeyPosition(Position)] == 1 then
		return
	end
	if Position.Y > TopLayerY then
		return
	end

	GenerationCache[KeyPosition(Position)] = 1

	local RandomNumber = BlockInfo == nil and NumberGenerator:NextInteger(1, Core.GameConfig.Mine.ChanceToGenerateOre)
		or 0
	local StoneBlock = self:YLevelToLayer(Position.Y).Stone
	local BlockToGenerate = StoneBlock

	if RandomNumber == 1 and BlockInfo == nil then
		local Success, Ore = self:GenerateRandomOre(Position.Y, InCave)
		if Success then
			BlockToGenerate = Ore
			BlockToGenerate:AddTag("Mine/BlockType/Ore")
			self.MineStats.OresGenerated += 1
		else
			BlockToGenerate = StoneBlock
			BlockToGenerate:AddTag("Mine/BlockType/Stone")
			BlockToGenerate:AddTag("Mine/BlockType/OreFail")
		end
	end

	if BlockInfo then
		BlockToGenerate = BlockInfo.RealOre
		BlockToGenerate:SetAttribute("Health", BlockToGenerate:GetAttribute("MaxHealth"))
	end

	SetupStoneBlock(StoneBlock)
	local NewBlock: BasePart = BlockToGenerate:Clone()
	NewBlock.Parent = workspace.Game.Mine
	NewBlock.Position = Position
	NewBlock.Color = StoneBlock.Color
	NewBlock.Size = Core.GameConfig.Mine.BlockSize

	if Tint then
		NewBlock.Color = Core.Util:TintColor(NewBlock.Color, Tint)
	end

	self:AddAirPosition(Position)
	MineOctree:CreateNode(Position, NewBlock)
	self.MineStats.BlocksGenerated += 1
	GenerationCache[KeyPosition(Position)] = nil

	NewBlock:SetAttribute("CanMine", true)

	ReplicatedStorage.Player.Debug.Mine.BlocksGenerated.Value = self.MineStats.BlocksGenerated
	ReplicatedStorage.Player.Debug.Mine.OresGenerated.Value = self.MineStats.OresGenerated

	if Position.Y >= TopLayerY and table.find(self.TopLayerPositions, Position) then
		NewBlock:SetAttribute("CanMine", true)
		return NewBlock
	end

	local function DisableBlock()
		LogService:Warn("Making block unminable!")
		NewBlock = self:ReplaceBlockAtPosition(Position, StoneBlock)
		NewBlock.Color = Color3.fromRGB(27, 42, 53)
		NewBlock:SetAttribute("CanMine", false)
	end

	if Position.Y >= TopLayerY then
		DisableBlock()
	end

	local Depth = ConvertYLevelToDepth(Position.Y)
	if Depth > self.LowestDepth then
		DisableBlock()
	end

	return NewBlock
end

--[=[
Gets the block at a given position
]=]
function MineService:GetBlockAtPosition(Position: Vector3)
	local Nodes = MineOctree:GetNearest(Position, 6, 1)
	local Node = Nodes and Nodes[1]
	if not Node then
		return nil
	end

	local Block = Node.Object
	return Block
end

--[=[
Replaces a block at a given position
]=]
function MineService:ReplaceBlockAtPosition(Position: Vector3, NewBlock: BasePart): BasePart
	local Block = self:GetBlockAtPosition(Position)
	local Pos = Block.Position
	local Color = Block.BrickColor

	Block:Destroy()
	MineOctree:RemoveNode(MineOctree:FindFirstNode(Block))

	Block = NewBlock:Clone()
	Block.Parent = workspace.Game.Mine
	Block.Position = Pos
	Block.BrickColor = Color
	Block.Size = Core.GameConfig.Mine.BlockSize
	MineOctree:CreateNode(Pos, Block)
	Block:SetAttribute("CanMine", true)
	return Block
end

--[=[
Generates the top layer of the mine based of the mine spawn
]=]
function MineService:GenerateTopLayer()
	if not TopLayerCanGenerate then
		return
	end

	Collapsing = false
	TopLayerCanGenerate = false
	MineSpawn.Position = OriginalMineSpawnPosition
	MineSpawn.Transparency = 0
	MineSpawn.CanCollide = true
	TopLayerY = MineSpawn.Position.Y

	local BlocksToGenerateX = math.round(MineSpawn.Size.X / BlockSize.X)
	local BlocksToGenerateY = math.round(MineSpawn.Size.Z / BlockSize.Z)

	LogService:Log("Generating top layer (" .. (BlocksToGenerateX * BlocksToGenerateY) .. " blocks)")
	local TopLeftPosition = Vector3.new(
		MineSpawn.Position.X - ((MineSpawn.Size.X / 2) - (BlockSize.X / 2)),
		MineSpawn.Position.Y,
		MineSpawn.Position.Z - ((MineSpawn.Size.Z / 2) - (BlockSize.X / 2))
	)

	UsedPositions = {}
	self.TopLayerPositions = {}
	self.MineStats.BlocksGenerated = 0
	self.MineStats.OresGenerated = 0

	local function Generate(Y)
		return Promise.new(function(Resolve)
			for X = 1, BlocksToGenerateX, 1 do
				local Position = TopLeftPosition + Vector3.new((X - 1) * BlockSize.X, 0, (Y - 1) * BlockSize.Z)
				local AbovePos = Position + Vector3.new(0, BlockSize.Y, 0)

				table.insert(self.TopLayerPositions, Position)
				self:GenerateBlockAtPosition(Position)
				self:AddAirPosition(AbovePos)
			end
			Resolve()
		end)
	end

	local Promises = {}

	for Y = 1, BlocksToGenerateY, 1 do
		table.insert(Promises, Generate(Y))
	end

	Promise.all(Promises):await()

	MineSpawn.Position = MineSpawn.Position + Vector3.new(0, 50, 0)
	MineSpawn.Transparency = 1
	MineSpawn.CanCollide = false
	LogService:Log("Finished generating top layer")
end

--[=[
Generate a 3x3 room for people to teleport into to. Returns the position where players
can be teleported to
]=]
function MineService:GenerateRoomAtDepth(Depth: number): Vector3
	local YLevel = ConvertDepthToYLevel(Depth)
	local RandomXZ = NumberGenerator:NextInteger(-100, 100)
	local CenterPos = Vector3.new(RandomXZ, YLevel, RandomXZ)

	local YSize = Core.GameConfig.Mine.BlockSize.Y

	local AirPositions: { Vector3 } = {
		Vector3.new(0, YSize, 0),
		Vector3.new(0, -YSize, 0),

		Vector3.new(YSize, 0, 0),
		Vector3.new(-YSize, 0, 0),

		Vector3.new(0, 0, YSize),
		Vector3.new(0, 0, -YSize),
	}

	local CenterOffset = YSize * 2

	local Offsets = {
		--Floor
		Vector3.new(0, -CenterOffset, 0),
		Vector3.new(YSize, -CenterOffset, 0),
		Vector3.new(-YSize, -CenterOffset, 0),
		Vector3.new(0, -CenterOffset, YSize),
		Vector3.new(0, -CenterOffset, -YSize),
		Vector3.new(YSize, -CenterOffset, YSize),
		Vector3.new(-YSize, -CenterOffset, YSize),
		Vector3.new(YSize, -CenterOffset, -YSize),
		Vector3.new(-YSize, -CenterOffset, -YSize),

		--Roof
		Vector3.new(0, CenterOffset, 0),
		Vector3.new(YSize, CenterOffset, 0),
		Vector3.new(-YSize, CenterOffset, 0),
		Vector3.new(0, CenterOffset, YSize),
		Vector3.new(0, CenterOffset, -YSize),
		Vector3.new(YSize, CenterOffset, YSize),
		Vector3.new(-YSize, CenterOffset, YSize),
		Vector3.new(YSize, CenterOffset, -YSize),
		Vector3.new(-YSize, CenterOffset, -YSize),

		--Wall
		Vector3.new(CenterOffset, 0, 0),
		Vector3.new(CenterOffset, YSize, 0),
		Vector3.new(CenterOffset, -YSize, 0),
		Vector3.new(CenterOffset, 0, YSize),
		Vector3.new(CenterOffset, 0, -YSize),
		Vector3.new(CenterOffset, YSize, YSize),
		Vector3.new(CenterOffset, -YSize, YSize),
		Vector3.new(CenterOffset, YSize, -YSize),
		Vector3.new(CenterOffset, -YSize, -YSize),

		--Wall
		Vector3.new(-CenterOffset, 0, 0),
		Vector3.new(-CenterOffset, YSize, 0),
		Vector3.new(-CenterOffset, -YSize, 0),
		Vector3.new(-CenterOffset, 0, YSize),
		Vector3.new(-CenterOffset, 0, -YSize),
		Vector3.new(-CenterOffset, YSize, YSize),
		Vector3.new(-CenterOffset, -YSize, YSize),
		Vector3.new(-CenterOffset, YSize, -YSize),
		Vector3.new(-CenterOffset, -YSize, -YSize),

		--Wall
		Vector3.new(0, 0, CenterOffset),
		Vector3.new(0, YSize, CenterOffset),
		Vector3.new(0, -YSize, CenterOffset),
		Vector3.new(YSize, 0, CenterOffset),
		Vector3.new(-YSize, 0, CenterOffset),
		Vector3.new(YSize, YSize, CenterOffset),
		Vector3.new(-YSize, YSize, CenterOffset),
		Vector3.new(YSize, -YSize, CenterOffset),
		Vector3.new(-YSize, -YSize, CenterOffset),

		--Wall
		Vector3.new(0, 0, -CenterOffset),
		Vector3.new(0, YSize, -CenterOffset),
		Vector3.new(0, -YSize, -CenterOffset),
		Vector3.new(YSize, 0, -CenterOffset),
		Vector3.new(-YSize, 0, -CenterOffset),
		Vector3.new(YSize, YSize, -CenterOffset),
		Vector3.new(-YSize, YSize, -CenterOffset),
		Vector3.new(YSize, -YSize, -CenterOffset),
		Vector3.new(-YSize, -YSize, -CenterOffset),
	}

	for _, Offset in pairs(AirPositions) do
		local NewPos = CenterPos + Offset
		self:AddAirPosition(NewPos)
	end

	for _, Offset in pairs(Offsets) do
		local NewPos = CenterPos + Offset
		self:GenerateBlockAtPosition(NewPos)
	end

	return CenterPos
end

--[=[
Sets a position as "air" meaning nothing can generate there
]=]
function MineService:AddAirPosition(Position: Vector3)
	if self:IsPositionAir(Position) then
		return
	end
	Position = self:SnapPositionToGrid(Position)
	UsedPositions[KeyPosition(Position)] = 1
end

--[=[
Checks weather the position is air
]=]
function MineService:IsPositionAir(Position: Vector3): boolean
	Position = self:SnapPositionToGrid(Position)
	return UsedPositions[KeyPosition(Position)] and true or false
end

--[=[
Attempts to generate a geode from a mined block. "Attempts" because an ore can not generate geode
or the random chance can not work out you know
]=]
function MineService:AttemptToGenerateGeode(Ore: BasePart)
	local CanGenerate = Ore:GetAttribute("CanGenerateGeode") :: boolean
	local GenerationChance = Ore:GetAttribute("GeodeGenerationChance") :: number
	local SizeBounds = Ore:GetAttribute("GeodeRadiusSize") :: NumberRange

	if not CanGenerate then
		return
	end

	local RandomNumber = NumberGenerator:NextInteger(1, GenerationChance)
	if RandomNumber ~= 1 then
		return
	end

	local Radius = NumberGenerator:NextInteger(SizeBounds.Min, SizeBounds.Max)

	local Direction = NumberGenerator:NextInteger(1, 3)
	local Negative = NumberGenerator:NextInteger(1, 2)

	local Position = Ore.CFrame.Position
	local Offset
	local FinalPosition
	local Distance = (Radius * 2 + 6)

	if Direction == 1 then
		Offset = Vector3.new(Distance, 0, 0)
	elseif Direction == 2 then
		Offset = Vector3.new(0, Distance, 0)
	elseif Direction == 3 then
		Offset = Vector3.new(0, 0, Direction)
	end

	if Negative then
		FinalPosition = Position - Offset
	else
		FinalPosition = Position + Offset
	end

	if (FinalPosition.Y + Radius) > TopLayerY then
		FinalPosition = FinalPosition - Vector3.new(0, Radius * 2, 0)
	end

	CaveService:GenerateGeodeAsync(FinalPosition, Radius, Ore)
end

--[=[
Generates blocks around a block that was mined aswell as destroying the block
]=]
function MineService:BlockMined(Block: BasePart)
	if Block == nil then
		return
	end

	if self.MineStats.BlocksGenerated >= Core.GameConfig.Mine.BlocksToCollapse then
		CollapseMine()
		return
	end

	self:GenerateAroundBlockAsync(Block)
	local Node = MineOctree:FindFirstNode(Block)

	if Node then
		MineOctree:RemoveNode(Node)
	end

	self:AttemptToGenerateGeode(Block)
	Block:Destroy()
end

--[=[
Generate blocks around the passed part using offsets
]=]
function MineService:GenerateAroundBlockAsync(Block: BasePart)
	return Promise.new(function(Resolve)
		local Origin = Block.Position
		local Blocks = {}

		for _, Offset: Vector3 in pairs(BlockGenerationOffsets) do
			local NewBlock = self:GenerateBlockAtPosition(Origin + Offset)
			table.insert(Blocks, NewBlock)
		end

		Resolve(Blocks)
	end)
end

--[=[
Generate blocks around the passed position using offsets
]=]
function MineService:GenerateAroundPositionAsync(
	Origin: Vector3,
	InCave: boolean | true,
	BlockInfo: Core.OreListItem,
	Tint: Color3
)
	return Promise.new(function(Resolve)
		local Blocks = {}
		for _, Offset: Vector3 in pairs(BlockGenerationOffsets) do
			local Position = Origin + Offset
			local NewBlock = self:GenerateBlockAtPosition(Position, InCave, BlockInfo, Tint)
			self:AddAirPosition(Position)
			table.insert(Blocks, NewBlock)
		end
		Resolve(Blocks)
	end)
end

--[=[
Force the mine to collapse with an optional seed
]=]
function MineService:Collapse(NewSeed: number?)
	CollapseMine(NewSeed)
end

--[=[
Returns the closest block to a given position
]=]
function MineService:GetClosestBlock(Position: number, Radius: number)
	local Nodes = MineOctree:GetNearest(Position, Radius, 1)
	local Node = Nodes[1]
	return Node.Object or nil
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

--[[ KNIT ]]
--

function MineService:KnitInit()
	local LowestDepth = 0
	for _, Layer: Configuration in pairs(Core.Assets.Layers:GetChildren()) do
		local LayerDepthRange: NumberRange = Layer:GetAttribute("Depth")
		local LayerLowestDepth = LayerDepthRange.Max

		if LayerLowestDepth > LowestDepth then
			LowestDepth = LayerLowestDepth
		end
	end

	self.LowestDepth = LowestDepth
end

function MineService:KnitStart()
	LogService = Knit.GetService("LogService")
	TeleportService = Knit.GetService("TeleportService")
	CaveService = Knit.GetService("CaveService")

	for _, Object in pairs(ReplicatedStorage.Assets.Ores:GetChildren()) do
		if not Object:IsA("BasePart") then
			Object:Destroy()
		end
	end

	self:GenerateTopLayer()

	if workspace:FindFirstChild("Baseplate") then
		workspace:FindFirstChild("Baseplate"):Destroy()
	end
end

return MineService
