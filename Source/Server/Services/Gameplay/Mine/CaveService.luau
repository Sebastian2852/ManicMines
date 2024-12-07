local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Promise = require(ReplicatedStorage.Packages.Promise)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Core = require(ReplicatedStorage.Game.Modules.Core)

local CaveService = Knit.CreateService {
    Name = "CaveService",
    Client = {},
}

local MineService
local LogService

local BlockSize = Core.GameConfig.Mine.BlockSize

-- [[ PRIVATE ]] --

local function GetSphereAirPositions(Center :Vector3, Radius :number) :{Vector3}
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



-- [[ PUBLIC ]] --

--[=[
Generate a geode around the center with a given radius for the given ore
]=]
function CaveService:GenerateGeodeAsync(Center :Vector3, Radius :number, Ore :BasePart)
    LogService:Log("Generating geode")
    return Promise.new(function(Resolve)
        local Positions = GetSphereAirPositions(Center, Radius)

        LogService:Log("Generated air positions")

        local OreData = Core.OreList.CreateOreData(Ore)

        for _, Position :Vector3 in pairs(Positions) do
            MineService:AddAirPosition(Position)
        end

        LogService:Log("Generating blocks")

        local Blocks :{BasePart} = {}
        local BlockGen = {}

        for _, Position :Vector3 in pairs(Positions) do
            local GenPromise = MineService:GenerateAroundPositionAsync(Position, true, OreData, Ore:GetAttribute("GeodeColorTint")):andThen(function(Generated :{BasePart})
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
Generate a random cave at a given position with a given size
]=]
function CaveService:GenerateCaveAsync(Center :Vector3, Size :number)
    return Promise.new(function(Resolve)
        Size = Size / 2

        local Blocks = 0
        local Airs = 0

        local Gens = {}
        local function GenZ(X, Y)
            return Promise.new(function(ResolveGen)
                for Z = -Size, Size, BlockSize.Z do
                    RunService.Heartbeat:Wait()

                    local Offset = Vector3.new(X, Y, Z)
                    local Position = Center + Offset

                    if X == -Size or X + BlockSize.X > Size then
                        MineService:GenerateBlockAtPosition(Position, true, nil, nil)
                        continue
                    end

                    if Y == -Size or Y + BlockSize.Y > Size then
                        MineService:GenerateBlockAtPosition(Position, true, nil, nil)
                        continue
                    end

                    if Z == -Size or Z + BlockSize.Z > Size then
                        MineService:GenerateBlockAtPosition(Position, true, nil, nil)
                        continue
                    end

                    local Noise = math.noise(X / 28, Y / 16, Z / 28)

                    if Noise < 0.001 then
                        MineService:GenerateBlockAtPosition(Position, true, nil, nil)
                        Blocks += 1
                    end

                    MineService:AddAirPosition(Position)
                    Airs += 1
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



-- [[ KNIT ]] --

function CaveService:KnitStart()
    MineService = Knit.GetService("MineService")
    LogService = Knit.GetService("LogService")
end

return CaveService