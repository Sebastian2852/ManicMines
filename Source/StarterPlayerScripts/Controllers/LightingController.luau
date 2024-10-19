local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Core = require(ReplicatedStorage.Game.Modules.Core)

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

function LightingController:KnitStart()
    for i = 1, 5, 1 do
        print(i)
        task.wait(1)
    end
    self:CreateFromConfig(script.Parent:FindFirstChildWhichIsA("Configuration"))
end

return LightingController
