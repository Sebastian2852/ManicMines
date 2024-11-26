local ChangeHistoryService = game:GetService("ChangeHistoryService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Promise = require(ReplicatedStorage.Packages.Promise)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Profiler = require(ReplicatedStorage.Game.Modules.Profiler)
local Core = require(ReplicatedStorage.Game.Modules.Core)

local CaveService = Knit.CreateService {
    Name = "CaveService",
    Client = {},
}

local MineService

@native
local function GetAirPositions(Center :Vector3, Radius :number, BlockSize :number) :{Vector3}
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

function CaveService:GenerateSphereAsync(Center :Vector3, Radius :number)
    return Promise.new(function(Resolve)
        local BlockSize = Core.GameConfig.Mine.BlockSize.X
        local Positions = GetAirPositions(Center, Radius, BlockSize)

        for _, Pos in pairs(Positions) do
            MineService:AddAirPosition(Pos)
        end

        for i, Pos in pairs(Positions) do
            MineService:GenerateAroundPositionAsync(Pos, true)
        end
        Resolve()
    end)
end

function CaveService:GenerateCave(Origin :Vector3)
    
end

function CaveService:KnitStart()
    MineService = Knit.GetService("MineService")

    task.wait(5)
    self:GenerateSphereAsync(Vector3.new(0, -60, 0), 30)
end

return CaveService