local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)
local Core = require(ReplicatedStorage.Game.Modules.Core)

local LoadingController = Knit.CreateController {
    Name = "LoadingController"
}

local LoadingService

local Player = Knit.Player

-- [[ GUI ]] --

local LoadingScreen = Roact.Component:extend("LoadingScreen")

local LOADING_WHEEL_TRANSPARENCY_SEQUENCE = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1, 0);
    NumberSequenceKeypoint.new(0.5, 1, 0);
    NumberSequenceKeypoint.new(0.501, 0, 0);
    NumberSequenceKeypoint.new(1, 0, 0);
})

function LoadingScreen:init()
    self:setState({
        Rotation = 0;
        ActionText = "";
    })

    RunService.Heartbeat:Connect(function(DeltaTime)
        if not self.state.Visible then return end
        self:setState({
            Rotation = self.state.Rotation + (180 * DeltaTime);
        })

        if self.state.Rotation >= 180 then
            self:setState({
                Rotation = -180;
            })
        end
    end)

    LoadingService.UpdateActionText:Connect(function(Text)
        self:setState({
            ActionText = Text;
        })
    end)

    LoadingService.LoadingStarted:Connect(function()
        self:setState({
            Visible = true;
        })
        self:Fade(0, 0.5)
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
    end)

    LoadingService.LoadingEnded:Connect(function()
        self:Fade(1, 0.5)
        self:setState({
            Visible = false;
            ActionText = "";
        })
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
    end)
end

function LoadingScreen:Fade(Goal :number, Time :number)
    local Frame :Frame = self.FrameRef:getValue()
    if not Frame then return end

    local function HasProp(Object :Instance, Property :string) :boolean
        local Success = pcall(function()
            local Temp = Object[Property]
            return Temp
        end)
        return Success
    end

    local Tweens = {}

    table.insert(Tweens, TweenService:Create(Frame, TweenInfo.new(Time), {Transparency = Goal}))

    for _, Object :GuiBase in pairs(Frame:GetDescendants()) do
        if Object:IsA("UILayout") then continue end
        if Object:IsA("UIGradient") then continue end

        if HasProp(Object, "TextTransparency") then
            table.insert(Tweens, TweenService:Create(Object, TweenInfo.new(Time), {TextTransparency = Goal}))
            continue
        end

        if HasProp(Object, "ImageTransparency") then
            table.insert(Tweens, TweenService:Create(Object, TweenInfo.new(Time), {ImageTransparency = Goal}))
            continue
        end
    end

    for _, Tween in pairs(Tweens) do
        Tween:Play()
    end

    task.wait(Time)
end

function LoadingScreen:render()
    self.FrameRef = Roact.createRef()

    return Roact.createElement("ScreenGui", {
        IgnoreGuiInset = true;
        ClipToDeviceSafeArea = false;
        ResetOnSpawn = false;
        DisplayOrder = 100;
    }, {
        Main = self.state.Visible and Roact.createElement("Frame", {
            Size = UDim2.fromScale(1, 1);
            BackgroundColor3 = Core.UI.Theme.BackgroundColorDark;
            BorderSizePixel = 0;
            BackgroundTransparency = 1;

            [Roact.Ref] = self.FrameRef
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
                        Transparency = LOADING_WHEEL_TRANSPARENCY_SEQUENCE;
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

                        Text = self.state.ActionText or "";
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

function LoadingController:KnitStart()
    LoadingService = Knit.GetService("LoadingService")

    local LogService = Knit.GetService("LogService")

    local App = Roact.createElement(LoadingScreen)
    Roact.mount(App, Player.PlayerGui, "LoadingScreen")
    LogService:Log("Mounted loading screen component")
end

return LoadingController