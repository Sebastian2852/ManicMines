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

-- [[ PUBLIC ]] --

--[=[
Do not use this function, instead use "GenerateRandomCaveAsync"
]=]
function CaveService:GenerateCaveAsync(
	Center: Vector3,
	Size: number,
	NoiseResolution: Vector3,
	NoiseResolutionOffset: Vector3,
	NoiseThreshold: number,
	Tint: Color3?
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
						MineService:GenerateAtPositionAsync(Position, true):andThen(function(Block)
							if Block then
								Block.Color = Core.Util:TintColor(Block.Color, Tint)
							end
						end)
						continue
					end

					if Y == -Size or Y + BlockSize.Y > Size then
						MineService:GenerateAtPositionAsync(Position, true):andThen(function(Block)
							if Block then
								Block.Color = Core.Util:TintColor(Block.Color, Tint)
							end
						end)
						continue
					end

					if Z == -Size or Z + BlockSize.Z > Size then
						MineService:GenerateAtPositionAsync(Position, true):andThen(function(Block)
							if Block then
								Block.Color = Core.Util:TintColor(Block.Color, Tint)
							end
						end)
						continue
					end

					local Noise = math.noise(
						X / NoiseResolution.X + NoiseResolutionOffset.X,
						Y / NoiseResolution.Y + NoiseResolutionOffset.Y,
						Z / NoiseResolution.Z + NoiseResolutionOffset.Z
					)

					if Noise < NoiseThreshold then
						MineService:GenerateAtPositionAsync(Position, true):andThen(function(Block)
							if Block then
								Block.Color = Core.Util:TintColor(Block.Color, Tint)
							end
						end)
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

function CaveService:GetRandomConfig(Depth: number): Configuration
	local PossibleCaves = self:GetSpawnableCaves(Depth)
	local NumberGenerator = MineService:GetRandomObject()

	local function GetRemainingCaves(CavesLeft: { BasePart })
		for i, Cave: Configuration in pairs(CavesLeft) do
			local RandomNumber = NumberGenerator:NextInteger(1, Cave:GetAttribute("Rarity"))
			if RandomNumber ~= 1 then
				table.remove(CavesLeft, i)
			end
		end
		return CavesLeft
	end

	if #PossibleCaves > 1 then
		repeat
			PossibleCaves = GetRemainingCaves(PossibleCaves)
		until #PossibleCaves == 1
	end

	if #PossibleCaves == 1 then
		local Cave = PossibleCaves[1]
		local RandomNumber = NumberGenerator:NextInteger(1, Cave:GetAttribute("Rarity") or 1)
		if RandomNumber == 1 then
			return Cave
		end
	end

	return nil
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
	local RandomCaveConfig = self:GetRandomConfig(Depth)

	if RandomCaveConfig then
		self:GenerateCaveFromConfigAsync(RandomCaveConfig, Position)
	end
end

-- [[ KNIT ]] --

function CaveService:KnitStart()
	MineService = Knit.GetService("MineService")
	LogService = Knit.GetService("LogService")

	if _G.DEBUG then
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
end

return CaveService
