local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Core = require(ReplicatedStorage.Game.Modules.Core)
local Roact = require(ReplicatedStorage.Packages.Roact)

local StorageController = Knit.CreateController { Name = "StorageController" }

local StorageComponent = Roact.Component:extend("StorageComponent")
local LogService
local TycoonUpgradeService

function StorageComponent:init()
    self:setState({
        Enabled = true
    })

    TycoonUpgradeService.OpenStorage:Connect(function()
        self:Enable()
    end)
end

function StorageComponent:Enable()
    self:setState({
        Enabled = true
    })
end

function StorageComponent:render()
    return Roact.createElement("ScreenGui", {}, {
        Main = self.state.Enabled and Roact.createElement("Frame", {
            Size = UDim2.fromScale(0.5, 0.5);
            Position = Core.UI.Position.Center;
            AnchorPoint = Core.UI.AnchorPoint.Center;

            BackgroundColor3 = Core.UI.Theme.BackgroundColor;
            BackgroundTransparency = Core.UI.Theme.BackgroundColorTransparency;
        }, {
            Title = Roact.createElement("TextLabel", {
                Size = UDim2.fromScale(1, 0.1);
                AnchorPoint = Core.UI.AnchorPoint.TopCenter;
                Position = Core.UI.Position.TopCenter;

                Text = "Storage";
                TextScaled = true;
                BackgroundTransparency = 1;
                TextStrokeTransparency = 0;

                FontFace = Core.UI.Theme.TextFont;
                TextColor3 = Core.UI.Theme.TextColor3;
            }, {});

            CloseButton = Roact.createElement("TextButton", {
                Size = UDim2.fromScale(0.035, 0.035);
                SizeConstraint = Enum.SizeConstraint.RelativeXX;
                Position = UDim2.fromScale(0, -0.1);
                AnchorPoint = Core.UI.AnchorPoint.TopLeft;

                Text = "X";
                TextScaled = true;
                BorderSizePixel = 0;
                FontFace = Core.UI.Theme.TextFont;

                BackgroundColor3 = Core.UI.Color.Red;
                TextColor3 = Core.UI.Color.White;

                [Core.Roact.Event.Activated] = function()
                    self:setState({
                        Enabled = false
                    })
                end
            }, {});

            Main = Roact.createElement("Frame", {
                Size = UDim2.fromScale(1, 0.9);
                Position = UDim2.fromScale(0.5, 0.1);
                AnchorPoint = Core.UI.AnchorPoint.TopCenter;
                BackgroundTransparency = 1;
            }, {
                Inventory = Roact.createElement("Frame", {
                    Size = UDim2.fromScale(0.5, 1);
                    AnchorPoint = Vector2.new(0, 0.5);
                    Position = UDim2.fromScale(0, 0.5);

                    BackgroundTransparency = 1;
                }, {
                    Title = Roact.createElement("TextLabel", {
                        Size = UDim2.fromScale(1, 0.1);
                        AnchorPoint = Core.UI.AnchorPoint.TopCenter;
                        Position = Core.UI.Position.TopCenter;

                        Text = "Inventory";
                        TextXAlignment = Enum.TextXAlignment.Left;
                        TextScaled = true;
                        BackgroundTransparency = 1;
                        TextStrokeTransparency = 0;

                        FontFace = Core.UI.Theme.TextFont;
                        TextColor3 = Core.UI.Theme.TextColor3;
                    }, {});

                    Ores = Roact.createElement("ScrollingFrame", {
                        Size = UDim2.fromScale(1, 0.9);
                        Position = UDim2.fromScale(0, 1);
                        AnchorPoint = Core.UI.AnchorPoint.BottomLeft;

                        BackgroundTransparency = 1;
                        BorderSizePixel = 0;
                        ScrollBarThickness = 5;
                        VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Left;
                        ScrollBarImageColor3 = Core.UI.Color.White;
                    }, {})
                });

                Storage = Roact.createElement("Frame", {
                    Size = UDim2.fromScale(0.5, 1);
                    AnchorPoint = Vector2.new(1, 0.5);
                    Position = UDim2.fromScale(1, 0.5);

                    BackgroundTransparency = 1;
                }, {
                    Title = Roact.createElement("TextLabel", {
                        Size = UDim2.fromScale(1, 0.1);
                        AnchorPoint = Core.UI.AnchorPoint.TopCenter;
                        Position = Core.UI.Position.TopCenter;

                        Text = "Storage";
                        TextXAlignment = Enum.TextXAlignment.Right;
                        TextScaled = true;
                        BackgroundTransparency = 1;
                        TextStrokeTransparency = 0;

                        FontFace = Core.UI.Theme.TextFont;
                        TextColor3 = Core.UI.Theme.TextColor3;
                    }, {});

                    Ores = Roact.createElement("ScrollingFrame", {
                        Size = UDim2.fromScale(1, 0.9);
                        Position = UDim2.fromScale(0, 1);
                        AnchorPoint = Core.UI.AnchorPoint.BottomLeft;

                        BackgroundTransparency = 1;
                        BorderSizePixel = 0;
                        ScrollBarThickness = 5;
                        VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right;
                        ScrollBarImageColor3 = Core.UI.Color.White;
                    }, {})
                })
            })
        })
    })
end

function StorageController:KnitStart()
    LogService = Knit.GetService("LogService")
    TycoonUpgradeService = Knit.GetService("TycoonUpgradeService")

    local App = Roact.createElement(StorageComponent)
    Roact.mount(App, Knit.Player.PlayerGui, "Storage")
    LogService:Log("Mounted storage GUI component")
end

return StorageController
