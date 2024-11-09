local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local LightingController = Knit.CreateController { Name = "LightingController" }

function LightingController:CreateFromConfig(Config :Configuration)
    local Objects = Config:GetChildren()

    for _, Object in pairs(Lighting:GetChildren()) do
        if string.sub(Object.Name, 1, 1) == "_" then continue end
        Object:Destroy()
    end

    for _, Object in pairs(Objects) do
        Object:Clone().Parent = Lighting
    end
end

function LightingController:KnitInit()
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0
    Lighting.ExposureCompensation = 1
    Lighting.Ambient = Color3.fromRGB(76, 76, 76)
end

return LightingController
