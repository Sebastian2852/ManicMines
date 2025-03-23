local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Profiler = require(ReplicatedStorage.Game.Modules.Profiler)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Signal = require(ReplicatedStorage.Packages.Signal)

-- Seperated into a different module as to not clutter this service
local OreAnnouncer = require(ServerScriptService.Game.Modules.OreAnnouncer)

local MineService = Knit.CreateService({
	Name = "MineService",
	Client = {},

	OnBlockMined = Signal.new(),

	MineStats = {
		BlocksGenerated = 0,
	},
})

local TeleportService
local PlayerStatsService
local MessageService

local Collapsing = false
local BlockSize = Core.GameConfig.Mine.BlockSize
local UsedPositions = {}
local TopLayerPositions = {}

local NumberGenerator = Random.new()

-- Offsets used to generate blocks
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
local BottomLayerDepth

-- Convert a world Y position into a depth
local function ConvertYLevelToDepth(WorldY: number): number
	local Top = TopLayerY
	local CellSize = Core.GameConfig.Mine.BlockSize.Y
	return math.floor((Top - WorldY) / CellSize)
end

-- Turn a vector into a string key for `UsedPositions` table
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

-- FIXME: Possible applies attribs twice? (need to look into)
-- Takes a stone block and applies it's attributes to the normal stone block
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

-- Returns the spawnable ores based on the given settings
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

-- (tbh this probs doesnt even calculate it right but whatever it works)
-- Returns the rarity of an ore based off a spawning curve
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

--[[
Picks a random ore from the ores that can spawn with the given settings
Since rarities are converted to weigths this is split into a different function to
stop the generate block function being too long and unreadable.
]]
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
			-- Calculate a final random number to decide whether to actually generate the ore
			local Number = NumberGenerator:NextInteger(1, v:GetAttribute("Rarity"))
			if Number == 1 then
				Ore = v
				break
			end
		end
	end

	-- Return the ore or stone if no ore was picked
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

	-- Calculate the blocks to generate on each axis by taking sizes and dividing by block sizes
	-- This in theory would allow blocks to be any shape but right now other parts of the game
	-- expect blocks to be perfect squares.
	local BlocksToGenerateX = math.round(MineSpawn.Size.X / BlockSize.X)
	local BlocksToGenerateY = math.round(MineSpawn.Size.Z / BlockSize.Z)

	local TopLeftPosition = Vector3.new(
		OriginalMineSpawnPosition.X - ((MineSpawn.Size.X / 2) - (BlockSize.X / 2)),
		OriginalMineSpawnPosition.Y,
		OriginalMineSpawnPosition.Z - ((MineSpawn.Size.Z / 2) - (BlockSize.X / 2))
	)

	UsedPositions = {}
	TopLayerPositions = {}

	-- Seperated into a different function for more readable multithreading
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
	-- Start a promise for each "strip" of blocks that need to generate
	-- This is the fastest way to generate after testing
	for Y = 1, BlocksToGenerateY, 1 do
		table.insert(Promises, Generate(Y))
	end
	Timer:Stop()

	-- Await for all the threads to finish generating blocks and then hiding the mine spawn to allow players to mine
	-- A wait is added to purposly delay to hiding the mine spawn as per request of project lead
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

	-- Teleport players to the surface if they are not in their tycoon (they are most likley in the mine)
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
	NumberGenerator = Random.new() -- Create a new seed for different generation of blocks

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

	-- Random number to see if the block should attempt to generate an ore or stone
	local RandomNumber = NumberGenerator:NextInteger(1, Core.GameConfig.Mine.ChanceToGenerateOre)
	local Block: BasePart = nil
	local Stone = Layer.Stone

	if RandomNumber == 1 then
		local Ore = PickRandomOre(ConvertYLevelToDepth(Position.Y), InCave)

		-- We turn stone into the ore instead of cloning the ore
		-- Since each layer has different stone color and/or material
		local NewOre = Stone:Clone() :: BasePart
		NewOre.Name = Ore.Name
		NewOre:ClearAllChildren()

		-- Apply the attributes from the ore to the stone block
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
		-- Take the same steps but instead with stone, so the normal stone gets turned into layer stone
		-- Instead of stone getting turned into ore
		Stone = Stone:Clone()
		SetupStoneBlock(Stone)
		Block = Stone
	end

	Block.Size = BlockSize
	-- Lerp the stone's color based on the layer's settings to give stone some color variation
	-- Instead of all of it looking the same
	Block.Color = Block.Color:Lerp(
		Layer:GetAttribute("BlockColorOffset"),
		NumberGenerator:NextNumber(0, Layer:GetAttribute("BlockColorOffsetLerp"))
	)
	Block:PivotTo(CFrame.new(Position))
	Block.Parent = Workspace.Game.Mine
	Block.Anchored = true
	-- Set the depth attribute so that the client can easily calculate depth-based things like turning point without doing any maths or events
	Block:SetAttribute("Depth", self:YLevelToDepth(Block.CFrame.Position.Y))
	self.MineStats.BlocksGenerated += 1
	self:UpdateMiningConditions()

	-- If the block is on the very top of the mine and it is not a top layer block then its made unminble to stop players
	-- Mining outside of the map or too high
	if Position.Y == TopLayerY and not (TopLayerPositions[KeyVector(Position)] == true) then
		Block.Color = Core.Util:TintColor(Block.Color, Color3.new(0, 0, 0))
		return Block
	end

	-- If the block is at the very bottom of the mine then its made unminable to stop players mining below the
	-- Created layers causing for some visual bugs as well as ore gen breaking
	local Depth = self:YLevelToDepth(Position.Y)
	if Depth >= BottomLayerDepth then
		Block.Color = Core.Util:TintColor(Block.Color, Color3.new(0, 0, 0))
		return Block
	end

	-- Block is ready to be mined
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
function MineService:BlockMined(Block: BasePart, PlayerWhoMined: Player?)
	if Block == nil then
		return
	end

	if self.MineStats.BlocksGenerated >= Core.GameConfig.Mine.BlocksToCollapse then
		self:Collapse()
		return
	end

	self.OnBlockMined:Fire(Block, Block.CFrame.Position)

	-- A promise is started since the block has a module which can take time to execute
	-- and so to not block the thread it is ran in a promise
	Promise.new(function(Resolve)
		local Module = Block:FindFirstChildWhichIsA("ModuleScript")
		if not Module then
			Resolve(true)
			return
		end

		-- The module expected to return if the player who mined it should actually get it in their inventory
		-- In the future this return should probably be checked and should be ran in a pcall
		local ShouldDrop = require(Module)(self, PlayerWhoMined)

		Resolve(ShouldDrop)
	end):andThen(function(ShouldDrop)
		local ShouldAnnounce = Block:GetAttribute("AnnounceOnMined")

		-- Some rare ores are sent in chat once mined
		-- TODO: Make this send to every server
		if ShouldAnnounce then
			-- Done in task.spawn since this sends to a discord webhook which takes time
			task.spawn(function()
				MessageService:SendMessage({
					Message = `{PlayerWhoMined.DisplayName} (@{PlayerWhoMined.Name}) mined {Block:GetAttribute(
						"DisplayName"
					)} which is 1 in {Block:GetAttribute("Rarity")}`,
					Prefix = "Ore Announcer",
					HasPrefix = false,
					MessageColor = Block:GetAttribute("SelectionColor"),
				})

				OreAnnouncer:AnnounceOreMined(
					PlayerWhoMined,
					Block:GetAttribute("DisplayName"),
					Block:GetAttribute("SelectionColor"),
					Block:GetAttribute("Rarity")
				)
			end)
		end

		-- Generate blocks around the block that is being mined in case it hasnt already
		self:GenerateAroundBlockAsync(Block):andThen(function()
			if PlayerWhoMined and ShouldDrop then
				PlayerStatsService:MinedOre(
					PlayerWhoMined,
					Core.OreList.CreateFromOre(Block.Name, Block:GetAttribute("AmountDroppedWhenMined"))
				)

				-- Advance the tutroial if the player is on a certain part of the tutorial
				local DataFolder = ReplicatedStorage.PlayerData:FindFirstChild(PlayerWhoMined.UserId) :: Core.DataFolder
				if DataFolder.TutorialStage.Value == 2 then
					DataFolder.TutorialStage.Value = 3
				end
			end
			Block:Destroy()
		end)
	end)
end

--[[
Expose the `ConvertYLevelToDepth` local function
]]
function MineService:YLevelToDepth(YLevel: number)
	return ConvertYLevelToDepth(YLevel)
end

-- [[ CLIENT ]] --

--[[
Returns the amount of blocks needed to collapse
(this should not be used and will be removed)
]]
function MineService.Client:GetBlocksToCollapse()
	return Core.GameConfig.Mine.BlocksToCollapse
end

--[[
Converts a WorldY to a depth
(this should not be used and will be removed)
]]
function MineService.Client:ConvertToDepth(_, YLevel: number)
	return ConvertYLevelToDepth(YLevel)
end

--[[
Returns the layer config for the given world Y
(shouldnt really be used but needs to be here for now)
]]
function MineService.Client:GetLayerConfig(_, YLevel: number): Configuration
	return self.Server:YLevelToLayer(YLevel)
end

-- [[ KNIT ]] --

function MineService:KnitStart()
	TeleportService = Knit.GetService("TeleportService")
	PlayerStatsService = Knit.GetService("PlayerStatsService")
	MessageService = Knit.GetService("MessageService")

	OriginalMineSpawnPosition = MineService:SnapPositionToGrid(MineSpawn.CFrame.Position)
	HiddenMineSpawnPosition = MineService:SnapPositionToGrid(OriginalMineSpawnPosition + Vector3.new(0, 50, 0))

	TopLayerY = OriginalMineSpawnPosition.Y
	BottomLayerDepth = 0

	-- Calculate the bottom depth of the mine
	for _, Layer in pairs(ReplicatedStorage.Assets.Layers:GetChildren()) do
		local Depth = Layer:GetAttribute("Depth").Max

		if Depth > BottomLayerDepth then
			BottomLayerDepth = Depth
		end
	end

	local function SetMaxHealthAttrib(Ore: BasePart)
		Ore:SetAttribute("MaxHealth", Ore:GetAttribute("Health"))
	end

	-- Set a needed `MaxHealth` attribute for every ore type + stone automatically instead of having to
	-- manually set it
	SetMaxHealthAttrib(Core.Assets.Stone)
	for _, v in pairs(Core.Assets.Ores:GetChildren()) do
		SetMaxHealthAttrib(v)
	end

	self:GenerateTopLayer()
	self:GenerateAtPositionAsync(Vector3.new(0, 0, 0))
end

return MineService
