local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Core = require(ReplicatedStorage.Game.Modules.Core)

local LightingController = Knit.CreateController { Name = "LightingController" }

function LightingController:CreateFromConfig(Config :Configuration)
    local Objects = Config:GetChildren()

    -- Apply settings to the the lighting's properties
    local PropertiesToChange = Config:GetAttributes()

    if PropertiesToChange then
        Core.Util:ApplyPropertiesFromTableAsync(Lighting, PropertiesToChange)
    end

    -- Destroy current lighting object and add the new ones
    for _, Object in pairs(Lighting:GetChildren()) do
        if string.sub(Object.Name, 1, 1) == "_" then continue end
        Object:Destroy()
    end

    for _, Object in pairs(Objects) do
        Object:Clone().Parent = Lighting
    end
end

return LightingController