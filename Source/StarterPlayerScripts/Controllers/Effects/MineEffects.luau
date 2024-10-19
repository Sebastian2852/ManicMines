local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Core = require(ReplicatedStorage.Game.Modules.Core)

local MineEffects = Knit.CreateController { Name = "MineEffects" }

local MineService
local LogService
local LightingController

local PreviousLayer = ""

function MineEffects:Layer(LayerName :string)
    LogService:Log("Appling layer effects for: "..LayerName)
    if not Core.Assets.Layers:FindFirstChild(LayerName) then
        LogService:Warn("Invalid layer name: "..LayerName)
        return
    end

    local LayerConfig :Configuration = Core.Assets.Layers:FindFirstChild(LayerName)
    local LightingConfig = LayerConfig:FindFirstChild("Lighting")

    if LightingConfig then
        LogService:Log("Appling lighting effects")
        LightingController:CreateFromConfig(LightingConfig)
    end
end

function MineEffects:KnitStart()
    LogService = Knit.GetService("LogService")
    LightingController = Knit.GetController("LightingController")
    MineService = Knit.GetService("MineService")

    RunService:BindToRenderStep("CharacterPositionInfo", Enum.RenderPriority.Input.Value + 1, function()
        local Character = Knit.Player.Character
        if not Character then return end

        local X = math.floor(Character.PrimaryPart.CFrame.Position.X)
        local Y = math.floor(Character.PrimaryPart.CFrame.Position.Y)
        local Z = math.floor(Character.PrimaryPart.CFrame.Position.Z)
        local Position = Vector3.new(X, Y, Z)

        MineService:GetLayerConfig(Position.Y):andThen(function(Config :Configuration)
            if PreviousLayer == Config.Name then return end

            MineEffects:Layer(Config.Name)
            PreviousLayer = Config.Name
        end)

    end)
end

return MineEffects