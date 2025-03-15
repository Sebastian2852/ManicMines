local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Profiler = require(ReplicatedStorage.Game.Modules.Profiler)
local Promise = require(ReplicatedStorage.Packages.Promise)

local CaveService = Knit.CreateService({
	Name = "CaveService",
	Client = {},
})

local MineService
local LogService

local BlockSize = Core.GameConfig.Mine.BlockSize

local NumberGenerator = Random.new()

-- [[ PUBLIC ]] --

function CaveService:GetModelByName(Name: string)
	return ReplicatedStorage.Assets.Caves.CaveDecorModels:FindFirstChild(Name)
end

function CaveService:PlaceCaveDecor(OriginalModel: Model, InitialPosition: Vector3)
	local Model = OriginalModel:Clone()
	local Hitbox = Model:FindFirstChild("Hitbox") :: Part
	if not Hitbox then
		warn(Model:GetFullName(), "Has no hitbox")
		return
	end

	Model.Parent = workspace
	Model.PrimaryPart = Hitbox
	Hitbox.Size = Hitbox.Size - Vector3.new(1, 0, 1)
	Model:PivotTo(CFrame.new(InitialPosition))

	local ModelCFrame = Hitbox.CFrame
	local ModelSize = Hitbox.Size

	local CornerOffsets = {
		Vector3.new(-ModelSize.X / 2, -ModelSize.Y / 2, -ModelSize.Z / 2),
		Vector3.new(ModelSize.X / 2, -ModelSize.Y / 2, -ModelSize.Z / 2),
		Vector3.new(-ModelSize.X / 2, -ModelSize.Y / 2, ModelSize.Z / 2),
		Vector3.new(ModelSize.X / 2, -ModelSize.Y / 2, ModelSize.Z / 2),
	}

	local CornerCFrames = {}

	for _, Offset: Vector3 in pairs(CornerOffsets) do
		table.insert(CornerCFrames, ModelCFrame * CFrame.new(Offset))
	end

	local Hits = 0
	local HitPositions = {}

	for _, CornerCFrame: CFrame in pairs(CornerCFrames) do
		local RayOrigin = CornerCFrame.Position
		local RayDirection = Vector3.new(0, -7, 0)
		local RaycastParams = RaycastParams.new()
		RaycastParams.FilterDescendantsInstances = { game.Workspace.Game.Mine }
		RaycastParams.FilterType = Enum.RaycastFilterType.Include

		local RaycastResult = workspace:Raycast(RayOrigin, RayDirection, RaycastParams)

		if RaycastResult then
			Hits += 1
			table.insert(HitPositions, RaycastResult.Position)
		end
	end

	if Hits ~= 4 then
		Model:Destroy()
		return
	end

	local HitY = HitPositions[1].Y

	for _, Position: Vector3 in pairs(HitPositions) do
		if Position.Y ~= HitY then
			Model:Destroy()
			return
		end
	end

	local NewCFrame = ModelCFrame - Vector3.new(0, (ModelCFrame.Position.Y - HitY) - (ModelSize.Y / 2), 0)
	Model:PivotTo(NewCFrame)

	local Params = OverlapParams.new()
	Params.FilterDescendantsInstances = { Model }
	Params.FilterType = Enum.RaycastFilterType.Exclude
	local Parts = workspace:GetPartsInPart(Hitbox, Params)

	for _, Part: BasePart in pairs(Parts) do
		if Part.CFrame.Position.Y < NewCFrame.Position.Y then
			Model:Destroy()
			return
		end
	end

	return Model
end

--[=[
Do not use this function, instead use "GenerateRandomCaveAsync"
]=]
function CaveService:GenerateCaveAsync(
	Center: Vector3,
	Size: number,
	NoiseResolution: Vector3,
	NoiseResolutionOffset: Vector3,
	NoiseThreshold: number,
	HasDecor: boolean,
	DecorFolder: Folder,
	DecorSpawnChance: number,
	Tint: Color3?
)
	return Promise.new(function(Resolve)
		if Size % 2 == 0 then
			Size += 1
		end

		Size = (Size / 2) * BlockSize.X
		local Gens = {}
		local NoiseCache = {}
		local CaveMap = {}

		local DecorPositions = {}

		local function GetNoise(X, Y, Z)
			local Key = string.format("%d_%d_%d", X, Y, Z)
			if NoiseCache[Key] then
				return NoiseCache[Key]
			end

			local Noise = math.noise(
				X / NoiseResolution.X + NoiseResolutionOffset.X,
				Y / NoiseResolution.Y + NoiseResolutionOffset.Y,
				Z / NoiseResolution.Z + NoiseResolutionOffset.Z
			)

			NoiseCache[Key] = Noise
			return Noise
		end

		-- Precompute cave structure
		for X = -Size, Size, BlockSize.X do
			for Y = -Size, Size, BlockSize.Y do
				for Z = -Size, Size, BlockSize.Z do
					local NoiseValue = GetNoise(X, Y, Z)
					CaveMap[X .. "," .. Y .. "," .. Z] = NoiseValue < NoiseThreshold
				end
			end
		end

		local function IsSurfaceBlock(X, Y, Z)
			if not CaveMap[X .. "," .. Y .. "," .. Z] then
				return false
			end

			local Offsets = {
				Vector3.new(BlockSize.X, 0, 0),
				Vector3.new(-BlockSize.X, 0, 0),
				Vector3.new(0, BlockSize.Y, 0),
				Vector3.new(0, -BlockSize.Y, 0),
				Vector3.new(0, 0, BlockSize.Z),
				Vector3.new(0, 0, -BlockSize.Z),
			}

			for _, Offset in Offsets do
				local NeighborKey = (X + Offset.X) .. "," .. (Y + Offset.Y) .. "," .. (Z + Offset.Z)
				if not CaveMap[NeighborKey] then
					return true
				end
			end

			return true
		end

		local function GenerateBlock(Position, ForceGenerate)
			MineService:GenerateAtPositionAsync(Position, ForceGenerate)
				:andThen(function(Block)
					if Block and Tint ~= nil and Tint ~= Color3.new(1, 1, 1) then
						Block.Color = Core.Util:TintColor(Block.Color, Tint)
					end
				end)
				:await()
		end

		local function GenZ(X, Y)
			return Promise.new(function(ResolveGen)
				for Z = -Size, Size, BlockSize.Z do
					RunService.Heartbeat:Wait()

					local Offset = Vector3.new(X, Y, Z)
					local Position = Center + Offset

					if MineService:IsPositionAir(Position) then
						continue
					end

					-- Generate outer shell
					if
						X == -Size
						or X + BlockSize.X > Size
						or Y == -Size
						or Y + BlockSize.Y > Size
						or Z == -Size
						or Z + BlockSize.Z > Size
					then
						GenerateBlock(Position, true)
						continue
					end

					-- Generate only surface blocks inside the cave
					if IsSurfaceBlock(X, Y, Z) then
						GenerateBlock(Position, false)
						MineService:AddAirPosition(Position)
					else
						if HasDecor then
							local Chance = math.random(1, DecorSpawnChance)
							if Chance == 1 then
								table.insert(DecorPositions, Position)
							end
						end
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

		local DecorValues = DecorFolder:GetChildren() :: { IntValue }

		for i, Position in pairs(DecorPositions) do
			local RandomDecorIndex = math.random(1, #DecorValues)
			local RandomValue = DecorValues[RandomDecorIndex]

			if math.random(1, RandomValue.Value) == 1 then
				local PlacedModel = self:PlaceCaveDecor(
					self:GetModelByName(RandomValue.Name),
					MineService:SnapPositionToGrid(Position)
				) :: Model?

				if PlacedModel then
					for _, Object: Part in pairs(PlacedModel:GetDescendants()) do
						if Object:HasTag("Mine/LayerColor") then
							local Y = Object.CFrame.Position.Y
							local Layer = MineService:YLevelToLayer(Y)
							Object.Color = Layer.Stone.Color
							Object.Color = Object.Color:Lerp(
								Layer:GetAttribute("BlockColorOffset"),
								NumberGenerator:NextNumber(0, Layer:GetAttribute("BlockColorOffsetLerp"))
							)
							Object.Color = Core.Util:TintColor(Object.Color, Tint)
							Object.Material = Layer.Stone.Material
							Object.MaterialVariant = Layer.Stone.MaterialVariant
						end
					end

					PlacedModel:PivotTo(
						PlacedModel.PrimaryPart.CFrame
							* CFrame.Angles(0, math.rad(NumberGenerator:NextInteger(0, 360)), 0)
					)
				end
			end

			if i % 30 == 0 then
				RunService.Heartbeat:Wait()
			end
		end

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
	NumberGenerator = MineService:GetRandomObject()

	local SizeRange = CaveConfig:GetAttribute("Size")
	local MinSize = SizeRange.Min
	local MaxSize = SizeRange.Max
	local Size = NumberGenerator:NextInteger(MinSize, MaxSize)

	local NoiseResolution = CaveConfig:GetAttribute("NoiseResolution")
	local NoiseResolutionOffset = CaveConfig:GetAttribute("NoiseResolutionOffset")
	local NoiseThreshold = CaveConfig:GetAttribute("NoiseThreshold")
	local Tint = CaveConfig:GetAttribute("Tint")

	return self:GenerateCaveAsync(
		Position,
		Size,
		NoiseResolution,
		NoiseResolutionOffset,
		NoiseThreshold,
		CaveConfig:GetAttribute("HasDecor"),
		CaveConfig.Decor,
		CaveConfig:GetAttribute("DecorSpawnChance"),
		Tint
	)
end

--[=[
Generates a random cave from a random config at the given position
]=]
function CaveService:GenerateRandomCave(Position: Vector3)
	LogService:Log("Generating new cave")

	Position = MineService:SnapPositionToGrid(Position)
	local Depth = MineService:YLevelToDepth(Position.Y)
	local RandomCaveConfig = self:GetRandomConfig(Depth)

	if RandomCaveConfig then
		self:GenerateCaveFromConfigAsync(
			RandomCaveConfig,
			Position - Vector3.new(0, RandomCaveConfig:GetAttribute("Size").Max, 0)
		)
	end
end

-- [[ KNIT ]] --

function CaveService:KnitStart()
	MineService = Knit.GetService("MineService")
	LogService = Knit.GetService("LogService")

	MineService.OnBlockMined:Connect(function(_, Position: Vector3)
		NumberGenerator = MineService:GetRandomObject() :: Random
		local RandomNumber = NumberGenerator:NextInteger(1, Core.GameConfig.Mine.ChanceToGenerateCave)

		if RandomNumber ~= 1 then
			return
		end

		local NewPosition = Position - Vector3.new(0, 60, 0)
		self:GenerateRandomCave(NewPosition)
	end)

	if _G.DEBUG then
		task.wait(5)
		local Generated = 0

		for _, CaveConfig: Configuration in pairs(Core.Assets.Caves.Random:GetChildren()) do
			if CaveConfig:GetAttribute("TestMode") == false then
				continue
			end
			Generated += 1
			LogService:Log("Generateing test cave: " .. CaveConfig.Name)
			local Timer = Profiler.Timer.new("CaveGen")
			self:GenerateCaveFromConfigAsync(CaveConfig, Vector3.new(500 * Generated, -500, 0)):await()
			Timer:Stop()
		end
	end
end

return CaveService
