local ReplicatedStorage = game.ReplicatedStorage

local Knit = require(ReplicatedStorage.Packages.Knit)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Core = require(ReplicatedStorage.Game.Modules.Core)

local NumberGenerator = Random.new()

local TeleportService
local LogService

local MineService = Knit.CreateService {
    Name = "MineService",
    Client = {},
}

local MineSpawn :BasePart = workspace.Game.MineSpawn
local OriginalMineSpawnPosition = MineSpawn.Position

local OresFolder = game.ReplicatedStorage.Assets.Ores
local TopLayerY = 0
local TopLayerCanGenerate = true

MineService.TopLayerPositions = {}
MineService.UsedPositions = {}

MineService.MineStats = {
    BlocksGenerated = 0;
    OresGenerated = 0;
}

-- [[ PRIVATE ]] --

local function CollapseMine()
    LogService:Log("Mine collapsing")
    for _, Player in pairs(game.Players:GetPlayers()) do
        TeleportService:TeleportPlayerToSurface(Player)
    end

    MineSpawn.Position = OriginalMineSpawnPosition
    MineSpawn.Transparency = 0

    LogService:Log("Deleting all blocks in mine")
    for _, Part in ipairs(workspace.Game.Mine:GetChildren()) do
        Part:Destroy()
    end

    task.wait(1)

    LogService:Log("Generating top layer")
    TopLayerCanGenerate = true
    MineService:GenerateTopLayer()
    MineSpawn.Transparency = 1
end

local function ConvertYLevelToDepth(WorldY :number) :number
    local Top = TopLayerY
    local CellSize = Core.GameConfig.Mine.BlockSize.Y
    return math.floor((Top - WorldY) / CellSize)
end

local function SetupStoneBlock(StoneBlock :BasePart)
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



-- [[ PUBLIC ]] --

--[=[
Convert any Y level number into a layer config. If no valid layer config is found then the default
layer is used.
]=]
function MineService:YLevelToLayer(YLevel :number) :Configuration
    local Depth = ConvertYLevelToDepth(YLevel)

    for _, LayerConfig in pairs(Core.Assets.Layers:GetChildren()) do
        local LayerDepth :NumberRange = LayerConfig:GetAttribute("Depth")
        if Depth >= LayerDepth.Min and Depth <= LayerDepth.Max then
            return LayerConfig
        end
    end

    return game.ReplicatedStorage.Assets.Layers.Default
end

--[=[
Gets a table of the possible ores that can spawn at a given Y level
]=]
function MineService:GetSpawnableOres(YLevel :number, InCave :boolean)
    local SpawnableOres = {}

    for _, Ore in pairs(OresFolder:GetChildren()) do
        if Ore:GetAttribute("CaveOnly") and not InCave then continue end
        local SpawningRange = Ore:GetAttribute("SpawningRange")

        if (SpawningRange.Min * 6) <= math.abs(YLevel) and (SpawningRange.Max * 6) - 1 >= math.abs(YLevel) then
            table.insert(SpawnableOres, Ore)
            continue
        end
    end

    return SpawnableOres
end

--[=[
Generate a random ore to use
THIS RETURN THE PART; DOES NOT PUT IT IN THE MINE
]=]
function MineService:GenerateRandomOre(YLevel :number, Cave :boolean) :BasePart
    local SpawnableOres = self:GetSpawnableOres(YLevel, Cave)
    local GeneratedBlock = nil

    if #SpawnableOres == 0 then
        LogService:Warn("No possible ores that can spawn!")
        return false
    end

    while GeneratedBlock == nil do
        for _, PossibleOre :BasePart in pairs(SpawnableOres) do
            local Rarity = PossibleOre:GetAttribute("Rarity")
            local Number = NumberGenerator:NextInteger(1, Rarity)

            if Number == 1 then
                GeneratedBlock = PossibleOre
                break
            end
        end
    end

    return true, GeneratedBlock
end

--[=[
Generates a position at a given position, has a random chance to be an ore
]=]
function MineService:GenerateBlockAtPosition(Position :Vector3)
    if table.find(self.UsedPositions, Position) then return end

    local RandomNumber = NumberGenerator:NextInteger(1, Core.GameConfig.Mine.ChanceToGenerateOre)
    local StoneBlock = self:YLevelToLayer(Position.Y).Stone
    local BlockToGenerate = StoneBlock

    if RandomNumber == 1 then
        local Success, Ore = self:GenerateRandomOre(Position.Y, false)
        if Success then
            BlockToGenerate = Ore
            LogService:Log("Generating ore:", BlockToGenerate:GetFullName())
            BlockToGenerate:AddTag("Mine/BlockType/Ore")
            self.MineStats.OresGenerated += 1
        else
            LogService:Warn("Generating stone")
            BlockToGenerate = StoneBlock
            BlockToGenerate:AddTag("Mine/BlockType/Stone")
        end
    end

    SetupStoneBlock(StoneBlock)
    local NewBlock :BasePart = BlockToGenerate:Clone()
    NewBlock.Parent = workspace.Game.Mine
    NewBlock.Position = Position
    NewBlock.Size = Core.GameConfig.Mine.BlockSize

    table.insert(self.UsedPositions, Position)
    self.MineStats.BlocksGenerated += 1

    NewBlock:SetAttribute("CanMine", true)

    if Position.Y >= TopLayerY and table.find(self.TopLayerPositions, Position) then
        NewBlock:SetAttribute("CanMine", true)
        return
    end

    if Position.Y >= TopLayerY then 
        NewBlock.Color = Color3.fromRGB(27, 42, 53)
        NewBlock:SetAttribute("CanMine", false)
    end
end

--[=[
Generates the top layer of the mine based of the mine spawn
]=]
function MineService:GenerateTopLayer()
    if not TopLayerCanGenerate then return end

    TopLayerCanGenerate = false
    MineSpawn.Position = OriginalMineSpawnPosition
    MineSpawn.Transparency = 0
    MineSpawn.CanCollide = true
    TopLayerY = MineSpawn.Position.Y

    local BlockSize = Core.GameConfig.Mine.BlockSize
    local BlocksToGenerateX = math.round(MineSpawn.Size.X / BlockSize.X)
    local BlocksToGenerateY = math.round(MineSpawn.Size.Z / BlockSize.Z)

    LogService:Log("Generating top layer ("..(BlocksToGenerateX * BlocksToGenerateY).." blocks)")
    local TopLeftPosition = Vector3.new(MineSpawn.Position.X - ((MineSpawn.Size.X / 2) - (BlockSize.X / 2)), MineSpawn.Position.Y, MineSpawn.Position.Z - ((MineSpawn.Size.Z / 2) - (BlockSize.X / 2)))

    MineSpawn.Position = OriginalMineSpawnPosition + Vector3.new(0, 0.01, 0)

    self.UsedPositions = {}
    self.TopLayerPositions = {}
    self.MineStats.BlocksGenerated = 0
    self.MineStats.OresGenerated = 0

    local function Generate(Y)
        return Promise.new(function(Resolve, Reject)
            for X = 1, BlocksToGenerateX, 1 do
                local Position = TopLeftPosition + Vector3.new((X - 1) * BlockSize.X, 0, (Y - 1) * BlockSize.Z)
                if table.find(self.UsedPositions, Position) then
                    Reject("Position is already used")
                end

                table.insert(self.TopLayerPositions, Position)
                self:GenerateBlockAtPosition(Position)
                local AbovePos = Position + Vector3.new(0, BlockSize.Y, 0)
                table.insert(self.UsedPositions, AbovePos)
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
Generates blocks around a block that was mined aswell as destroying the block
]=]
function MineService:BlockMined(Block :BasePart)
    if self.MineStats.BlocksGenerated >= Core.GameConfig.Mine.BlocksToCollapse then
        CollapseMine()
        return
    end

    local XOffset = Core.GameConfig.Mine.BlockSize.X
    local YOffset = Core.GameConfig.Mine.BlockSize.Y
    local ZOffset = Core.GameConfig.Mine.BlockSize.Z

    local PositionOffsets = {
        Vector3.new(XOffset, 0, 0);
        Vector3.new(-XOffset, 0, 0);

        Vector3.new(0, YOffset, 0);
        Vector3.new(0, -YOffset, 0);

        Vector3.new(0, 0, ZOffset);
        Vector3.new(0, 0, -ZOffset);
    }

    local OriginalPosition = Block.Position
    Block:Destroy()

    for _, Offset in pairs(PositionOffsets) do
        self:GenerateBlockAtPosition(OriginalPosition + Offset)
    end
end



-- [[ CLIENT ]] --

function MineService.Client:GetBlocksToCollapse()
    return Core.GameConfig.Mine.BlocksToCollapse
end

function MineService.Client:ConvertToDepth(_, YLevel :number)
    return ConvertYLevelToDepth(YLevel)
end

function MineService.Client:GetLayerConfig(_, YLevel :number) :Configuration
    return self.Server:YLevelToLayer(YLevel)
end



--[[ KNIT ]]--

function MineService:KnitStart()
    LogService = Knit.GetService("LogService")
    TeleportService = Knit.GetService("TeleportService")
    self:GenerateTopLayer()

    if workspace:FindFirstChild("Baseplate") then
        workspace:FindFirstChild("Baseplate"):Destroy()
    end
end



return MineService
