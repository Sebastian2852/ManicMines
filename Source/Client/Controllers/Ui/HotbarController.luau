local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local NeoHotbar = require(ReplicatedStorage.Packages.NeoHotbar)

local HotbarController = Knit.CreateController { Name = "HotbarController" }

local SpringTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)

local DEFAULT_POSITION = UDim2.new(0.5, 0, 1, -8)
local HIDDEN_POSITION = UDim2.new(0.5, 0, 1.1, 0)

-- [[ PUBLIC ]] --

--[=[
Only intented for internal use
]=]
function HotbarController:_AnimateHotbar(Goal :UDim2)
    local Tween = TweenService:Create(self.MainFrame, SpringTweenInfo, {Position = Goal})
    Tween:Play()
    return Tween
end

--[=[
Makes the hotbar invisible
]=]
function HotbarController:DisableHotbar(Animated :boolean?)
    if Animated == nil then
        Animated = true
    end

    if Animated then
        self:_AnimateHotbar(HIDDEN_POSITION)
    else
        self.MainFrame.Position = HIDDEN_POSITION
    end
end

--[=[
Makes the hotbar visible
]=]
function HotbarController:EnableHotbar(Animated :boolean?)
    if Animated == nil then
        Animated = true
    end

    if Animated then
        self:_AnimateHotbar(DEFAULT_POSITION)
    else
        self.MainFrame.Position = DEFAULT_POSITION
    end
end

--[=[
Allows tooltips to show up
]=]
function HotbarController:EnableTooltips()
    NeoHotbar:SetToolTipsEnabled(true)
end

--[=[
Stops tooltips from showing
]=]
function HotbarController:DisableTooltips()
    NeoHotbar:SetToolTipsEnabled(true)
end



-- [[ KNIT ]] --

function HotbarController:KnitStart()
    NeoHotbar:Start()
    self.GUI = Knit.Player.PlayerGui:FindFirstChild("NeoHotbar") :: ScreenGui
    self.MainFrame = self.GUI:FindFirstChildWhichIsA("Frame")
end

return HotbarController