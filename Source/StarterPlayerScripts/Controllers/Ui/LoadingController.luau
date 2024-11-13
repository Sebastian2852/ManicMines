local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)
local Core = require(ReplicatedStorage.Game.Modules.Core)

local LoadingController = Knit.CreateController {
    Name = "LoadingController"
}

local LoadingService
local LogService

local Player = Knit.Player
local FadeFrame :Frame = nil
local FadeTweenInfo :TweenInfo = nil

--[[ PRIVATE ]]--

local function PlayTweens(Tweens :{Tween})
    for _, Tween in pairs(Tweens) do
        Tween:Play()
    end
end

local function FadeGuiIn(Animated :boolean, AwaitFinish :boolean)
    FadeFrame.Action.Text = ""

    if Animated then
        local Fades = {
            TweenService:Create(FadeFrame, FadeTweenInfo, {BackgroundTransparency = 0});
            TweenService:Create(FadeFrame.Action, FadeTweenInfo, {TextTransparency = 0});
        }
        PlayTweens(Fades)

        if AwaitFinish then
            Fades[1].Completed:Wait()
        end
    else
        FadeFrame.BackgroundTransparency = 0
        FadeFrame.Action.TextTransparency = 0
    end
end

local function FadeGuiOut(Animated :boolean, AwaitFinish :boolean)
    if Animated then
        local Fades = {
            TweenService:Create(FadeFrame, FadeTweenInfo, {BackgroundTransparency = 1});
            TweenService:Create(FadeFrame.Action, FadeTweenInfo, {TextTransparency = 1});
        }
        PlayTweens(Fades)

        if AwaitFinish then
            Fades[1].Completed:Wait()
        end
    else
        FadeFrame.BackgroundTransparency = 1
        FadeFrame.Action.TextTransparency = 1
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
Tell the user what is currently being done
]=]
function LoadingController:SetActionText(NewText :string)
    FadeFrame.Action.Text = NewText
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


-- [[ GUI ]] --

local LoadingScreen = Roact.Component:extend("LoadingScreen")

function LoadingScreen:init()
    self:setState({
        Rotation = 0
    })

    RunService.Heartbeat:Connect(function(DeltaTime)
        self:setState({
            Rotation = self.state.Rotation + (60 * DeltaTime)
        })

        if self.state.Rotation >= 180 then
            self:setState({
                Rotation = -180
            })
        end
    end)
end

function LoadingScreen:render()
    return Roact.createElement("ScreenGui", {
        IgnoreGuiInset = true;
        ClipToDeviceSafeArea = false;
        ResetOnSpawn = false;
        DisplayOrder = 100;
    }, {
        Main = Roact.createElement("Frame", {
            Size = UDim2.fromScale(1, 1);
            BackgroundColor3 = Core.UI.Theme.BackgroundColorDark;
            BorderSizePixel = 0;
        }, {
            Details = Roact.createElement("Frame", {
                Size = UDim2.fromScale(0.375, 0.15);
                Position = UDim2.fromScale(0.005, 1);
                AnchorPoint = Core.UI.AnchorPoint.BottomLeft;

                BackgroundTransparency = 1;
            }, {
                Layout = Roact.createElement("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal;
                    SortOrder = Enum.SortOrder.LayoutOrder;

                    VerticalAlignment = Enum.VerticalAlignment.Center;
                    Padding = UDim.new(0.05, 0)
                }, {});

                LoadingWheel = Roact.createElement("ImageLabel", {
                    Size = UDim2.fromScale(0.7, 0.7);
                    LayoutOrder = 1;
                    BackgroundTransparency = 1;

                    Image = Core.UI.Images.LoadingWheel;
                }, {
                    AspectRatio = Roact.createElement("UIAspectRatioConstraint", {}, {});
                    Gradient = Roact.createElement("UIGradient", {
                        Rotation = self.state.Rotation;
                        Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 1, 0);
                            NumberSequenceKeypoint.new(0.5, 1, 0);
                            NumberSequenceKeypoint.new(0.501, 0, 0);
                            NumberSequenceKeypoint.new(1, 0, 0);
                        });
                    }, {})
                });

                Text = Roact.createElement("Frame", {
                    Size = UDim2.fromScale(1, 1);
                    LayoutOrder = 2;
                    BackgroundTransparency = 1;
                }, {
                    Layout = Roact.createElement("UIListLayout", {
                        SortOrder = Enum.SortOrder.LayoutOrder;
                    }, {});

                    Title = Roact.createElement("TextLabel", {
                        Size = UDim2.fromScale(1, 0.6);
                        BackgroundTransparency = 1;
                        LayoutOrder = 1;

                        Text = "Loading";
                        TextScaled = true;
                        FontFace = Core.UI.Theme.TextFont;
                        TextColor3 = Core.UI.Theme.TextColor3;
                        TextXAlignment = Enum.TextXAlignment.Left;
                    }, {});

                    Text = Roact.createElement("TextLabel", {
                        Size = UDim2.fromScale(1, 0.4);
                        BackgroundTransparency = 1;
                        LayoutOrder = 2;

                        Text = "Text";
                        TextScaled = true;
                        FontFace = Core.UI.Theme.TextFont;
                        TextColor3 = Core.UI.Theme.TextColor3;
                        TextXAlignment = Enum.TextXAlignment.Left;
                    }, {});
                })
            })
        })
    })
end


--[[ KNIT ]]--

function LoadingController:KnitInit()
    local NewScreenGui = Instance.new("ScreenGui")
    NewScreenGui.Name = "FadeGui"
    NewScreenGui.IgnoreGuiInset = true
    NewScreenGui.ClipToDeviceSafeArea = false
    NewScreenGui.ResetOnSpawn = false
    NewScreenGui.DisplayOrder = 100
    NewScreenGui.Parent = Player.PlayerGui

    local NewFrame = Instance.new("Frame")
    NewFrame.Name = "Main"
    NewFrame.Size = UDim2.fromScale(1, 1)
    NewFrame.BackgroundTransparency = 1
    NewFrame.BackgroundColor3 = Core.UI.Theme.BackgroundColorDark
    NewFrame.Parent = NewScreenGui

    local Action = Instance.new("TextLabel")
    Action.Parent = NewFrame
    Action.Name = "Action"
    Action.Size = UDim2.fromScale(1, 1)
    Action.BackgroundTransparency = 1
    Action.TextScaled = true
    Action.Text = ""
    Action.TextColor3 = Color3.new(1, 1, 1)

    FadeFrame = NewFrame
    FadeTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false, 0)
end

function LoadingController:KnitStart()
    LoadingService = Knit.GetService("LoadingService")
    LogService = Knit.GetService("LogService")

    LoadingService.LoadingStarted:Connect(function()
        self:FadeGameplayOut(false)
    end)

    LoadingService.LoadingEnded:Connect(function()
        self:FadeGameplayIn(false)
    end)

    LoadingService.UpdateActionText:Connect(function(Text)
        self:SetActionText(Text)
    end)

    local App = Roact.createElement(LoadingScreen)
    Roact.mount(App, Player.PlayerGui, "LoadingScreen")
end

return LoadingController