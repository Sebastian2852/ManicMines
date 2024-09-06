local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local RainbowService = Knit.CreateService {
    Name = "RainbowService",
    Client = {},
}

local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")

local RainbowTag = "_RainbowGlow"

RainbowService.Colors = {
    Color3.fromRGB(255, 0, 0);
    Color3.fromRGB(255, 127, 0);
    Color3.fromRGB(255, 255, 0);
    Color3.fromRGB(0, 255, 0);
    Color3.fromRGB(0, 0, 255);
    Color3.fromRGB(75, 0, 130);
    Color3.fromRGB(148, 0, 211);
}

local function CreateInfoPropertyTable(Object :Decal|Light, NewColor :Color3) :{[string]: any}
    if Object:IsA("Decal") then
        return {Color3 = NewColor}
    elseif Object:IsA("Light") then
        return {Color = NewColor}
    end
end

function RainbowService:KnitStart()
    local Tagged = CollectionService:GetTagged(RainbowTag)
    local TweeningInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0)

    for _, Object in pairs(Tagged) do
        task.spawn(function()
            while true do
                for _, Color :Color3 in ipairs(self.Colors) do
                    local Tween = TweenService:Create(Object, TweeningInfo, CreateInfoPropertyTable(Object, Color))
                    Tween:Play()
                    Tween.Completed:Wait()
                end
            end
        end)
    end
end

return RainbowService
