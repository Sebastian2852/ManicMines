local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local LoadingController = Knit.CreateController {
    Name = "LoadingController"
}

local LoadingService
local LogService

local Player = Knit.Player
local FadeFrame :Frame = nil
local FadeTweenInfo :TweenInfo = nil

--[[ PRIVATE ]]--

local function FadeGuiIn(Animated :boolean, AwaitFinish :boolean)
    if Animated then
        local Fade = TweenService:Create(FadeFrame, FadeTweenInfo, {BackgroundTransparency = 0})
        Fade:Play()

        if AwaitFinish then 
            Fade.Completed:Wait() 
        end
    else
        FadeFrame.BackgroundTransparency = 0
    end
end

local function FadeGuiOut(Animated :boolean, AwaitFinish :boolean)
    if Animated then
        local Fade = TweenService:Create(FadeFrame, FadeTweenInfo, {BackgroundTransparency = 1})
        Fade:Play()

        if AwaitFinish then 
            Fade.Completed:Wait()
        end
    else
        FadeFrame.BackgroundTransparency = 1
    end
end



--[[ PUBLIC ]]--

--[=[
Fades in a black GUI to cover the whole screen and any UI
if await for finish is true then the script will not return
until the fade has finished
]=]
function LoadingController:FadeGameplayOut(AwaitFinish :boolean)
    LogService:Log("Fading gameplay out")
    FadeGuiIn(true, AwaitFinish)
end

--[=[
Fades out the GUI if await for finish is true then the script
will not return until the fade has finished
]=]
function LoadingController:FadeGameplayIn(AwaitFinish :boolean)
    LogService:Log("Fading gameplay in")
    FadeGuiOut(true, AwaitFinish)
end

--[=[
Puts the black gui on the screen with no fade/animation
]=]
function LoadingController:HideGameplay()
    LogService:Log("Hiding gameplay")
    FadeGuiIn(false, false)
end

--[=[
gets rid of the black gui on the screen with no fade/animation
]=]
function LoadingController:ShowGameplay()
    LogService:Log("Showing gameplay")
    FadeGuiOut(false, false)
end



--[[ KNIT ]]--

function LoadingController:KnitInit()
    local NewScreenGui = Instance.new("ScreenGui")
    NewScreenGui.Parent = Player.PlayerGui
    NewScreenGui.Name = "FadeGui"
    NewScreenGui.IgnoreGuiInset = true
    NewScreenGui.ClipToDeviceSafeArea = false
    NewScreenGui.ResetOnSpawn = false
    NewScreenGui.DisplayOrder = 100

    local NewFrame = Instance.new("Frame")
    NewFrame.Parent = NewScreenGui
    NewFrame.Name = "Fade"
    NewFrame.Size = UDim2.fromScale(1, 1)
    NewFrame.BackgroundTransparency = 1
    NewFrame.BackgroundColor3 = Color3.new(0, 0, 0)

    FadeFrame = NewFrame
    FadeTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false, 0)
end

function LoadingController:KnitStart()
    LoadingService = Knit.GetService("LoadingService")
    LogService = Knit.GetService("LogService")

    LoadingService.LoadingStarted:Connect(function()
        LoadingController:FadeGameplayOut(false)
    end)

    LoadingService.LoadingEnded:Connect(function()
        LoadingController:FadeGameplayIn(false)
    end)
end

return LoadingController