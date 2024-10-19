local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Core = require(ReplicatedStorage.Game.Modules.Core)

local MineEffects = Knit.CreateController { Name = "MineEffects" }

local LogService
local LightingController

function MineEffects:EnteredLayer(LayerName :string)
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
end

return MineEffects
