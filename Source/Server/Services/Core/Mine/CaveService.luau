local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Promise = require(ReplicatedStorage.Packages.Promise)

local CaveService = Knit.CreateService({
	Name = "CaveService",
	Client = {},
})

local MineService
local LogService

local BlockSize = Core.GameConfig.Mine.BlockSize

-- [[ PRIVATE ]] --

local function GetSphereAirPositions(Center: Vector3, Radius: number): { Vector3 }
	local Positions = {}

	for X = -Radius, Radius, BlockSize.X do
		for Y = -Radius, Radius, BlockSize.Y do
			for Z = -Radius, Radius, BlockSize.Z do
				local Offset = Vector3.new(X, Y, Z)
				local Position = Center + Offset
				if Offset.Magnitude <= Radius then
					table.insert(Positions, Position)
				end
			end
		end
	end

	return Positions
end

local function GetToalWeightOfCaves(Caves: { Configuration }?)
	if Caves == nil then
		Caves = Core.Assets.Caves.Random:GetChildren()
	end

	local Weight = 0

	for _, Cave: Configuration in pairs(Caves) do
		local Rarity = Cave:GetAttribute("Rarity")
		Weight += Rarity
	end

	return Weight
end

-- [[ PUBLIC ]] --

--[=[
Generate a geode around the center with a given radius for the given ore
]=]
function CaveService:GenerateGeodeAsync(Center: Vector3, Radius: number, Ore: BasePart)
	LogService:Log("Generating geode")
	return Promise.new(function(Resolve)
		local Positions = GetSphereAirPositions(Center, Radius)

		LogService:Log("Generated air positions")

		local OreData = Core.OreList.CreateOreData(Ore)

		for _, Position: Vector3 in pairs(Positions) do
			MineService:AddAirPosition(Position)
		end

		LogService:Log("Generating blocks")

		local Blocks: { BasePart } = {}
		local BlockGen = {}

		for _, Position: Vector3 in pairs(Positions) do
			local GenPromise = MineService
				:GenerateAroundPositionAsync(Position, true, OreData, Ore:GetAttribute("GeodeColorTint"))
				:andThen(function(Generated: { BasePart })
					for _, v in pairs(Generated) do
						table.insert(Blocks, v)
					end
				end)
			table.insert(BlockGen, GenPromise)
		end

		Promise.all(BlockGen):andThen(function()
			LogService:Log("changing brightness of lights")
			for _, Block in pairs(Blocks) do
				local Light = Block:FindFirstChildWhichIsA("Light")
				if Light then
					Light.Brightness = Light.Brightness / 2
				end
			end

			LogService:Log("Generated geode")
			Resolve()
		end)
	end)
end

--[=[
Do not use this function, instead use "GenerateRandomCaveAsync"
]=]
function CaveService:GenerateCaveAsync(
	Center: Vector3,
	Size: number,
	NoiseResolution: Vector3,
	NoiseResolutionOffset: Vector3,
	NoiseThreshold: number
	-- Tint: Color3?
)
	return Promise.new(function(Resolve)
		if Size % 2 == 0 then
			Size += 1
		end

		Size = Size / 2
		Center = MineService:SnapPositionToGrid(Center)

		local Gens = {}
		local function GenZ(X, Y)
			return Promise.new(function(ResolveGen)
				for Z = -Size, Size, BlockSize.Z do
					RunService.Heartbeat:Wait()

					local Offset = Vector3.new(X, Y, Z)
					local Position = Center + Offset

					if X == -Size or X + BlockSize.X > Size then
						MineService:GenerateAtPositionAsync(Position, true)
						continue
					end

					if Y == -Size or Y + BlockSize.Y > Size then
						MineService:GenerateAtPositionAsync(Position, true)
						continue
					end

					if Z == -Size or Z + BlockSize.Z > Size then
						MineService:GenerateAtPositionAsync(Position, true)
						continue
					end

					local Noise = math.noise(
						X / NoiseResolution.X + NoiseResolutionOffset.X,
						Y / NoiseResolution.Y + NoiseResolutionOffset.Y,
						Z / NoiseResolution.Z + NoiseResolutionOffset.Z
					)

					if Noise < NoiseThreshold then
						MineService:GenerateAtPositionAsync(Position, true)
					end

					MineService:AddAirPosition(Position)
				end
				ResolveGen()
			end)
		end

		for X = -Size, Size, BlockSize.X do
			for Y = -Size, Size, BlockSize.Y do
				table.insert(Gens, GenZ(X, Y))
			end
		end

		Promise.all(Gens):await()
		Resolve()
	end)
end

--[=[
Returns a table of configs of valid cave configs at the given depth
]=]
function CaveService:GetSpawnableCaves(Depth: number): { Configuration }
	local SpawnableCaves = {}

	for _, CaveConfig: Configuration in pairs(Core.Assets.Caves.Random:GetChildren()) do
		local SpawningRange = CaveConfig:GetAttribute("DepthRange")

		local MinY = SpawningRange.Min
		local MaxY = SpawningRange.Max

		if MinY <= Depth and Depth <= MaxY then
			table.insert(SpawnableCaves, CaveConfig)
		end
	end

	return SpawnableCaves
end

--[=[
Picks a random cave from the caves given based on weight
]=]
function CaveService:PickRandomCaveConfig(Caves: { Configuration }): Configuration
	local NumberGenerator: Random = MineService:GetRandomObject()
	local TotalWeight = GetToalWeightOfCaves(Caves)
	local RandomWeight = NumberGenerator:NextInteger(1, TotalWeight)
	local CurrentWeight = 0

	for _, Cave: Configuration in pairs(Caves) do
		local CaveWeight = Cave:GetAttribute("Rarity")
		CurrentWeight += CaveWeight
		if RandomWeight <= CurrentWeight then
			return Cave
		end
	end
end

--[=[
Generates a cave from the given config at the given position
]=]
function CaveService:GenerateCaveFromConfigAsync(CaveConfig: Configuration, Position: Vector3)
	LogService:Log("Generating cave from config: " .. CaveConfig.Name)
	local NumberGenerator: Random = MineService:GetRandomObject()

	local SizeRange = CaveConfig:GetAttribute("Size")
	local MinSize = SizeRange.Min
	local MaxSize = SizeRange.Max
	local Size = NumberGenerator:NextInteger(MinSize, MaxSize)

	local NoiseResolution = CaveConfig:GetAttribute("NoiseResolution")
	local NoiseResolutionOffset = CaveConfig:GetAttribute("NoiseResolutionOffset")
	local NoiseThreshold = CaveConfig:GetAttribute("NoiseThreshold")
	local Tint = CaveConfig:GetAttribute("Tint")

	return self:GenerateCaveAsync(Position, Size, NoiseResolution, NoiseResolutionOffset, NoiseThreshold, Tint)
end

--[=[
Generates a random cave from a random config at the given position
]=]
function CaveService:GenerateRandomCave(Position: Vector3)
	LogService:Log("Generating new cave")
	Position = MineService:SnapPositionToGrid(Position)

	local Depth = MineService:ConvertToDepth(Position.Y)
	local PossibleCaves = self:GetSpawnableCaves(Depth)
	local RandomCave = self:PickRandomCaveConfig(PossibleCaves)
	if not RandomCave then
		LogService:Warn("No possible caves can spawn")
		return
	end

	self:GenerateCaveFromConfigAsync(RandomCave, Position)
end

-- [[ KNIT ]] --

function CaveService:KnitStart()
	MineService = Knit.GetService("MineService")
	LogService = Knit.GetService("LogService")

	task.wait(5)

	local Generated = 0

	for _, CaveConfig: Configuration in pairs(Core.Assets.Caves.Random:GetChildren()) do
		if CaveConfig:GetAttribute("TestMode") == false then
			continue
		end
		Generated += 1
		LogService:Log("Generateing test cave: " .. CaveConfig.Name)
		self:GenerateCaveFromConfigAsync(CaveConfig, Vector3.new(500 * Generated, -500, 0)):await()
	end
end

return CaveService
