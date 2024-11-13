local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

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
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
    end)

    LoadingService.LoadingEnded:Connect(function()
        self:setState({
            Visible = false;
            ActionText = "";
        })
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
    end)
end

function LoadingScreen:render()
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