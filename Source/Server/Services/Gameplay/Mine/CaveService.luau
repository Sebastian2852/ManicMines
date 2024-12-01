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

local DebugFolder

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

local function CreateDebugBoundingBox(CenterPosition :Vector3, Size :Vector3)
    return Promise.new(function(Resolve)
        local DebugPart = Instance.new("Part")
        DebugPart.Size = Size
        DebugPart.CFrame = CFrame.new(CenterPosition)
        DebugPart.Transparency = 1
        DebugPart.CanCollide = false
        DebugPart.Anchored = true
        DebugPart.Parent = DebugFolder

        local SelectionBox = Instance.new("SelectionBox")
        SelectionBox.Adornee = DebugPart
        SelectionBox.Parent = DebugPart
        SelectionBox.Color3 = Core.UI.Color.Red
        SelectionBox.SurfaceTransparency = 1
        SelectionBox.LineThickness = 0.05
        Resolve()
    end)
end

local function CreateDebugPoint(Position :Vector3, Color :Color3)
    return Promise.new(function(Resolve)
        local DebugPart = Instance.new("Part")
        DebugPart.CFrame = CFrame.new(Position)
        DebugPart.Color = Color
        DebugPart.Size = Vector3.new(0.5, 0.5, 0.5)
        DebugPart.Material = Enum.Material.Neon
        DebugPart.Shape = Enum.PartType.Ball
        DebugPart.Transparency = 0
        DebugPart.CanCollide = false
        DebugPart.Anchored = true
        DebugPart.Parent = DebugFolder
    end)
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

function CaveService:GenerateCaveAsync(Center :Vector3, Size :number)
    local SizeVector = Vector3.new(Size, Size, Size)
    CreateDebugBoundingBox(Center, SizeVector)
    CreateDebugPoint(Center, Color3.fromRGB(255, 0, 255))

    local Air = {}

    Size = Size / 2
    for X = -Size, Size, BlockSize.X do
        for Y = -Size, Size, BlockSize.Y do
            for Z = -Size, Size, BlockSize.Z do
                local Offset = Vector3.new(X, Y, Z)
                local Position = Center + Offset
                local Noise = math.noise(X / 28, Y / 16, Z / 28)
                if Noise < 0.001 then
                    MineService:GenerateBlockAtPosition(Position, true, nil, nil)
                    continue
                end
                MineService:AddAirPosition(Position)
                table.insert(Air, Position)
                RunService.Heartbeat:Wait()
            end
        end
    end

    for _, AirPosition :Vector3 in pairs(Air) do
        MineService:GenerateAroundPositionAsync(AirPosition, true, nil, nil)
    end
end

-- [[ KNIT ]] --

function CaveService:KnitInit()
    local CreatedDebugFolder = Instance.new("Folder")
    CreatedDebugFolder.Name = "Cave-Debug"
    CreatedDebugFolder.Parent = workspace
    DebugFolder = CreatedDebugFolder
end

function CaveService:KnitStart()
    MineService = Knit.GetService("MineService")
    LogService = Knit.GetService("LogService")
end

return CaveService