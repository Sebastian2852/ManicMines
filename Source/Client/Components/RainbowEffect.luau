local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Component = require(ReplicatedStorage.Packages.Component)
local Core = require(ReplicatedStorage.Game.Modules.Core)



-- [[ CONFIG ]] --

local ValidTypes = {
    "BasePart";
    "Decal";
    "Light";
}

local Colors = {
    Color3.fromRGB(255, 0, 0);
    Color3.fromRGB(255, 127, 0);
    Color3.fromRGB(255, 255, 0);
    Color3.fromRGB(0, 255, 0);
    Color3.fromRGB(0, 0, 255);
    Color3.fromRGB(75, 0, 130);
    Color3.fromRGB(148, 0, 211);
}

local TweeningInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0)



-- [[ FUNCTIONS ]] --

local function CreatePropertyTableForTween(Object :Instance, NewColor :Color3) : {[string] :Color3}
    if Object:IsA("Decal") then
        return {Color3 = NewColor}
    elseif Object:IsA("Light") or Object:IsA("BasePart") then
        return {Color = NewColor}
    end
end

local function GetColorOfInstance(Object :Instance) :Color3
    if Object:IsA("Decal") then
        return Object.Color3
    elseif Object:IsA("Light") or Object:IsA("BasePart") then
        return Object.Color
    end
end



-- [[ COMPONENT ]] --

-- Extention functions
local Extensions = {}
function Extensions.ShouldConstruct(ComponentClass)
    local ComponentInstance = ComponentClass.Instance

    local Valid = false
    for _, Type in pairs(ValidTypes) do
        Valid = type(ComponentInstance) == Type
        if Valid then break end
    end
    return Valid
end

local DataService
local DataFolder :Core.DataFolder

-- Main component stuff
local RainbowEffectComponent = Component.new({
    Tag = "Component/Effect/Rainbow";
    Ancestors = { workspace };
    Extensions = Extensions;
})

function RainbowEffectComponent:Construct()
    DataService = Knit.GetService("DataService")

    self.Thread = nil
    self.OriginalColor = Color3.new(1, 1, 1)
    self.Active = DataFolder ~= nil and DataFolder.Settings.RainbowEffect.Value or false

    DataService.DataLoaded:Connect(function(NewDataFolder :Core.DataFolder)
        DataFolder = NewDataFolder

        DataFolder.Settings.RainbowEffect:GetPropertyChangedSignal("Value"):Connect(function()
            self:SetActive(DataFolder.Settings.RainbowEffect.Value)
        end)

        self:SetActive(DataFolder.Settings.RainbowEffect.Value)
    end)
end

function RainbowEffectComponent:Start()
    local ComponentInstance = self.Instance :: Instance

    self.OriginalColor = GetColorOfInstance(ComponentInstance)

    local DoneTween = false

    local Thread = task.spawn(function()
        while true do
            if not self.Active then
                if not DoneTween then
                    DoneTween = true
                    local Tween = TweenService:Create(ComponentInstance, TweeningInfo, CreatePropertyTableForTween(ComponentInstance, self.OriginalColor))
                    Tween:Play()
                end
                task.wait(0.1)
                continue
            end
            DoneTween = false

            for _, Color :Color3 in ipairs(Colors) do
                local Tween = TweenService:Create(ComponentInstance, TweeningInfo, CreatePropertyTableForTween(ComponentInstance, Color))
                Tween:Play()
                Tween.Completed:Wait()
            end
        end
    end)

    self.Thread = Thread
end

function RainbowEffectComponent:SetActive(Active :boolean)
    self.Active = Active
end

function RainbowEffectComponent:Stop()
    local Thread = self.Thread
    local ComponentInstance = self.Instance
    local OriginalColor = self.OriginalColor

    if Thread then
        task.cancel(Thread)
    end

    if ComponentInstance then
        local Tween = TweenService:Create(ComponentInstance, TweeningInfo, CreatePropertyTableForTween(ComponentInstance, OriginalColor))
        Tween:Play()
    end
end

return RainbowEffectComponent