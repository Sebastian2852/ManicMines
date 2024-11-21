local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)
local Core = require(ReplicatedStorage.Game.Modules.Core)
local Enums = require(ReplicatedStorage.Game.Modules.Enums)

local CreateBasicListLayout = require(ReplicatedStorage.Game.GUI.Components.General.BasicListLayout)
local CreateOreFrame = require(ReplicatedStorage.Game.GUI.Components.Storage.StorageOreFrame)

local StorageController = Knit.CreateController { Name = "StorageController" }

local StorageComponent = Roact.Component:extend("StorageComponent")
local TycoonUpgradeService
local DataService
local LogService

local DataFolder :Core.DataFolder

local function GetInventoryAsOreList() :Core.OreList
    local OreList = Core.OreList.CreateFromFolder(DataFolder.Inventory.Ores)
    return OreList
end

local function GetStorageAsOreList() :Core.OreList
    local OreList = Core.OreList.CreateFromFolder(DataFolder.Storage.Ores)
    return OreList
end

function StorageComponent:init()
    self:setState({
        Enabled = true;
    })

    TycoonUpgradeService.OpenStorage:Connect(function()
        self:setState({
            Enabled = true;
        })
    end)
end

function StorageComponent:render()
    LogService:Log("Rendering storage component")
    local InventoryFrames = Core.UI:CreateOreFrames(GetInventoryAsOreList(), Enums.OreFrameStyle.Normal, UDim2.fromScale(1, 0.05))
    InventoryFrames["Layout"] = CreateBasicListLayout(Enums.UiListType.ByName)

    local StorageFrames = Core.UI:CreateOreFrames(GetStorageAsOreList(), Enums.OreFrameStyle.Normal, UDim2.fromScale(1, 0.05))
    StorageFrames["Layout"] = CreateBasicListLayout(Enums.UiListType.ByName)

    return Roact.createElement("ScreenGui", {
        ResetOnSpawn = false;
    }, {
        Main = self.state.Enabled and Roact.createElement("Frame", {
            Size = UDim2.fromScale(0.5, 0.5);
            Position = Core.UI.Position.Center;
            AnchorPoint = Core.UI.AnchorPoint.Center;
            BorderSizePixel = 0;
            BackgroundColor3 = Core.UI.Theme.BackgroundColorPrimary;
        }, {
            Title = Roact.createElement("TextLabel", {
                Size = UDim2.fromScale(1, 0.1);
                AnchorPoint = Core.UI.AnchorPoint.TopCenter;
                Position = Core.UI.Position.TopCenter;

                Text = "Storage";
                TextScaled = true;
                BackgroundTransparency = 1;
                FontFace = Core.UI.Theme.TextFont;
                TextColor3 = Core.UI.Theme.TextColor3;
            }, {});

            CloseButton = Roact.createElement("TextButton", {
                Size = UDim2.fromScale(0.138, 0.06);
                Position = UDim2.fromScale(0, -0.07);
                BackgroundColor3 = Core.UI.Theme.CloseButtonColor;
                BorderSizePixel = 0;
                Modal = true;

                Text = "Close";
                TextScaled = true;
                TextColor3 = Core.UI.Color.White;
                FontFace = Core.UI.Theme.TextFont;

                [Roact.Event.MouseButton1Click] = function()
                    self:setState({
                        Enabled = false
                    })
                end;
            }, {
                Corners = Roact.createElement("UICorner", {
                    CornerRadius = UDim.new(0.2, 0)
                }, {})
            });

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
                    }, InventoryFrames )
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
                    }, StorageFrames )
                })
            })
        })
    })
end

function StorageController:KnitStart()
    TycoonUpgradeService = Knit.GetService("TycoonUpgradeService")
    DataService = Knit.GetService("DataService")
    LogService = Knit.GetService("LogService")

    DataService.DataLoaded:Connect(function(Data :Core.DataFolder)
        DataFolder = Data
        local App = Roact.createElement(StorageComponent)
        Roact.mount(App, Knit.Player.PlayerGui, "Storage")
        LogService:Log("Mounted storage component")
    end)
end

return StorageController
