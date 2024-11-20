local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Component = require(ReplicatedStorage.Packages.Component)



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

-- Main component stuff
local RainbowEffectComponent = Component.new({
    Tag = "Component/Effect/Rainbow";
    Ancestors = { workspace };
    Extensions = Extensions;
})

function RainbowEffectComponent:Construct()
    self.Thread = nil
end

function RainbowEffectComponent:Start()
    local ComponentInstance = self.Instance ::Instance
    warn(ComponentInstance)

    local Thread = task.spawn(function()
        while true do
            for _, Color :Color3 in ipairs(Colors) do
                local Tween = TweenService:Create(ComponentInstance, TweeningInfo, CreatePropertyTableForTween(ComponentInstance, Color))
                Tween:Play()
                Tween.Completed:Wait()
            end
        end
    end)

    self.Thread = Thread
end

return RainbowEffectComponent