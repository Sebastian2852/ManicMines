local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Packages.Promise)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Core = require(ReplicatedStorage.Game.Modules.Core)

local CaveService = Knit.CreateService {
    Name = "CaveService",
    Client = {},
}

local MineService
local LogService

local function GetSphereAirPositions(Center :Vector3, Radius :number, BlockSize :number) :{Vector3}
    local Positions = {}

    for X = -Radius, Radius, BlockSize do
        for Y = -Radius, Radius, BlockSize do
            for Z = -Radius, Radius, BlockSize do
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

function CaveService:GenerateGeodeAsync(Center :Vector3, Radius :number, Ore :BasePart)
    LogService:Log("Generating geode")
    return Promise.new(function(Resolve)
        local BlockSize = Core.GameConfig.Mine.BlockSize.X
        local Positions = GetSphereAirPositions(Center, Radius, BlockSize)

        LogService:Log("Generated air positions")

        local OreData = Core.OreList.CreateOreData(Ore)

        for _, Position :Vector3 in pairs(Positions) do
            MineService:AddAirPosition(Position)
        end

        LogService:Log("Generating blocks")

        for _, Position :Vector3 in pairs(Positions) do
            MineService:GenerateAroundPositionAsync(Position, true, OreData, Ore:GetAttribute("GeodeColorTint"))
        end

        LogService:Log("Generated geode")

        Resolve()
    end)
end

function CaveService:KnitStart()
    MineService = Knit.GetService("MineService")
    LogService = Knit.GetService("LogService")
end

return CaveService