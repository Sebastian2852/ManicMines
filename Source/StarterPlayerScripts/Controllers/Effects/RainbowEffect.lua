local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Core = require(ReplicatedStorage.Game.Modules.Core)

local RainbowController = Knit.CreateController {
    Name = "RainbowController",
}

local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")

local DataService
local LogService

local RainbowTag = "_RainbowGlow"

RainbowController.Colors = {
    Color3.fromRGB(255, 0, 0);
    Color3.fromRGB(255, 127, 0);
    Color3.fromRGB(255, 255, 0);
    Color3.fromRGB(0, 255, 0);
    Color3.fromRGB(0, 0, 255);
    Color3.fromRGB(75, 0, 130);
    Color3.fromRGB(148, 0, 211);
}

RainbowController.ValidTypes = {
    "Decal";
    "Light";
}

local ActiveEffects = {}

--[=[
Creates a TweenService:Create() info table for the object given.
]=]
local function CreateInfoPropertyTable(Object :Decal|Light, NewColor :Color3) :{[string]: any}
    if Object:IsA("Decal") then
        return {Color3 = NewColor}
    elseif Object:IsA("Light") then
        return {Color = NewColor}
    end
end

--[=[
Checks if an object is a valid object that can be made rainbow
]=]
local function IsValidObject(Object :any) :boolean
    for _, Type in ipairs(RainbowController.ValidTypes) do
        if Object:IsA(Type) then
            return true
        end
    end

    LogService:Warn("Invalid object: ("..Object.Name..") is a "..Object.ClassName.." expected: Decal, Light")
    return false
end

local function StartEffects()
    local Tagged = CollectionService:GetTagged(RainbowTag)
    local TweeningInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0)

    for _, Object in pairs(Tagged) do
        if not IsValidObject(Object) then continue end

        local Thread = task.spawn(function()
            while true do
                for _, Color :Color3 in ipairs(RainbowController.Colors) do
                    local Tween = TweenService:Create(Object, TweeningInfo, CreateInfoPropertyTable(Object, Color))
                    Tween:Play()
                    Tween.Completed:Wait()
                end
            end
        end)

        table.insert(ActiveEffects, Thread)
    end
end

local function StopEffects()
    for _, Thread in pairs(ActiveEffects) do
        task.cancel(Thread)
    end

    local Tagged = CollectionService:GetTagged(RainbowTag)
    local TweeningInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0)
    for _, Object in pairs(Tagged) do
        if not IsValidObject(Object) then continue end
        local Tween = TweenService:Create(Object, TweeningInfo, CreateInfoPropertyTable(Object, Color3.fromRGB(500, 500, 500)))
        Tween:Play()
    end
end

function RainbowController:KnitStart()
    DataService = Knit.GetService("DataService")
    LogService = Knit.GetService("LogService")

    DataService:GetPlayerDataFolder():andThen(function(PlayerDataFolder :Core.DataFolder)
        repeat task.wait(1) until PlayerDataFolder:FindFirstChild("DataLoaded")
        repeat task.wait(1) until PlayerDataFolder:FindFirstChild("DataLoaded").Value
        print(PlayerDataFolder:GetDescendants())
        PlayerDataFolder.Settings.RainbowEffect:GetPropertyChangedSignal("Value"):Connect(function()
            if PlayerDataFolder.Settings.RainbowEffect.Value then
                StartEffects()
            else
                StopEffects()
            end
        end)

        if PlayerDataFolder.Settings.RainbowEffect then
            StartEffects()
        else
            StopEffects()
        end
    end)
end

return RainbowController
