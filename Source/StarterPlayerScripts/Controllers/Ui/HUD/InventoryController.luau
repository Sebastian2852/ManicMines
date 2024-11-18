local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Core = require(ReplicatedStorage.Game.Modules.Core)
local Roact = require(ReplicatedStorage.Packages.Roact)
local Enums = require(ReplicatedStorage.Game.Modules.Enums)

local InventoryController = Knit.CreateController { Name = "InventoryController" }

local LogService
local DataService
local UIService
local DeviceController
local DataFolder :Core.DataFolder

-- [[ PRIVATE ]]--

local function CreateInventoryOreList()
    local NewList = Core.OreList.New()

    for _, OreDataValue :IntValue in pairs(DataFolder.Inventory.Ores:GetChildren()) do
        if OreDataValue.Value == 0 then continue end
        NewList:AddOre(OreDataValue.Name, OreDataValue.Value)
    end

    return NewList
end



-- [[ UI ]]--

local InventoryComponent = Core.Roact.Component:extend("InventoryComponent")

function InventoryComponent:init()
    self:setState({
        Hidden = false;
        Collapsed = false;
        StyleToUse = Enums.OreFrameStyle.Normal;
        OreList = {};
        Capacity = 0;
        Amount = 0;

        Xp = 0;
        XpNeeded = 0;
        LevelName = "no level";
        LevelNameColor = Core.UI.Color.White;
        LevelBarColor = ColorSequence.new(Core.UI.Color.White);
    })

    for _, OreDataValue :IntValue in pairs(DataFolder:WaitForChild("Inventory"):WaitForChild("Ores"):GetChildren()) do
        OreDataValue:GetPropertyChangedSignal("Value"):Connect(function()
            self:UpdateInventory(DataFolder.Inventory.InventoryItemCount.Value, DataFolder.Inventory.InventoryCap.Value, CreateInventoryOreList())
        end)
    end

    DataFolder.XP:GetPropertyChangedSignal("Value"):Connect(function()
        self:UpdateLevel()
    end)

    self:UpdateInventory(DataFolder.Inventory.InventoryItemCount.Value, DataFolder.Inventory.InventoryCap.Value, CreateInventoryOreList())
    self:UpdateLevel()

    DeviceController.DeviceChanged:Connect(function(NewDeviceType :Enums.Enum)
        if NewDeviceType == Enums.DeviceType.PC then
            self:setState(function(PreviousState :{any})
                PreviousState.StyleToUse = Enums.OreFrameStyle.PC
                return PreviousState
            end)
        elseif NewDeviceType == Enums.DeviceType.Mobile then
            self:setState(function(PreviousState :{any})
                PreviousState.StyleToUse = Enums.OreFrameStyle.Normal
                return PreviousState
            end)
        end
    end)

    UIService.Inventory:Connect(function(New :boolean)
        self:setState({
            Hidden = not New;
        })
    end)

    local DeviceType = DeviceController:GetDeviceType()
    if DeviceType == Enums.DeviceType.PC then
        self:setState(function(PreviousState :{any})
            PreviousState.StyleToUse = Enums.OreFrameStyle.PC
            return PreviousState
        end)
    elseif DeviceType == Enums.DeviceType.Mobile then
        self:setState(function(PreviousState :{any})
            PreviousState.StyleToUse = Enums.OreFrameStyle.Normal
            return PreviousState
        end)
    end
end

function InventoryComponent:UpdateLevel()
    local NewXP = DataFolder.XP.Value
    local CurrentLevel = DataFolder.Level.Value

    local CurrentLevelConfig = Core.Assets.Levels:FindFirstChild(tostring(CurrentLevel))
    local NextLevelConfig = Core.Assets.Levels:FindFirstChild(tostring(CurrentLevel + 1))

    local XpNeeded = 0

    if NextLevelConfig then
        XpNeeded = NextLevelConfig:GetAttribute("XpNeeded")
    end

    self:setState({
        Xp = NewXP;
        XpNeeded = XpNeeded;
        LevelName = CurrentLevelConfig:GetAttribute("LevelName");
        LevelNameColor = CurrentLevelConfig:GetAttribute("LevelColor");
        LevelBarColor = CurrentLevelConfig:GetAttribute("LevelXpBarColor");
    })
end

--[=[
IDEA:
On mobile the inventory is hidden by default, when the use wants to see the inventroy they press a button and the invetory opens
covering 1/3 of their screen on the right. When they press anywhere else the GUI hides and button reappears.
]=]

function InventoryComponent:render()
    LogService:Log("Rendering inventory")
    local Components = Core.UI:CreateOreFrames(self.state.OreList, self.state.StyleToUse, UDim2.fromScale(1, 0.1))
    Components["Layout"] = Core.Roact.createElement("UIListLayout", {}, {})

    local Amount = self.state.Amount
    local Capacity = self.state.Capacity
    local Collapsed = self.state.Collapsed

    local FullPercentToGoRed = 0.85
    local Time = math.clamp((Amount / Capacity - FullPercentToGoRed) / (1 - FullPercentToGoRed), 0, 1)

    local Red = 1
    local Green = 1 - Time
    local Blue = 1 - Time
    local Color = Color3.new(Red, Green, Blue)

    local Xp = self.state.Xp
    local XpNeeded = self.state.XpNeeded
    local LevelName = self.state.LevelName

    local LevelColor = self.state.LevelNameColor
    local XpBarColor = self.state.LevelBarColor

    local LevelProgress = math.clamp(Xp / XpNeeded, 0, 1);

    return Roact.createElement("ScreenGui", {
        ResetOnSpawn = false
    }, {
        Container = not self.state.Hidden and Roact.createElement("Frame", {
            Size = UDim2.fromScale(0.22, 0.6);
            Position = Core.UI.Position.BottomRight;
            AnchorPoint = Core.UI.AnchorPoint.BottomRight;

            BackgroundTransparency = 1;
        }, {
            AspectRatio = Roact.createElement("UIAspectRatioConstraint", {
                AspectRatio = 0.72;
                AspectType = Enum.AspectType.ScaleWithParentSize;
                DominantAxis = Enum.DominantAxis.Height;
            }, {});

            LevelContainer = Roact.createElement("Frame", {
                Size = UDim2.fromScale(0.6, 0.2);
                Position = Collapsed and UDim2.fromScale(1, 0.7) or Core.UI.Position.TopRight;
                AnchorPoint = Core.UI.AnchorPoint.TopRight;

                BackgroundTransparency = 1;
            }, {
                ProgressBar = Roact.createElement("Frame", {
                    Size = UDim2.fromScale(1, 0.1);
                    Position = UDim2.fromScale(0.5, 0.95);
                    BorderSizePixel = 0;
                    AnchorPoint = Core.UI.AnchorPoint.BottomCenter;
                    BackgroundColor3 = Core.UI.Theme.BackgroundColorDark;
                }, {
                    Stroke = Roact.createElement("UIStroke", {
                        ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
                        LineJoinMode = Enum.LineJoinMode.Round;
                        Color = Core.UI.Color.Black;
                        Thickness = 2;
                    }, {});

                    Bar = Roact.createElement("Frame", {
                        Size = UDim2.fromScale(LevelProgress, 1);
                        BorderSizePixel = 0;
                        BackgroundColor3 = Core.UI.Color.White;
                    }, {
                        Gradient = Roact.createElement("UIGradient", {
                            Color = XpBarColor;
                        }, {})
                    })
                });

                Xp = Roact.createElement("TextLabel", {
                    Size = UDim2.fromScale(1, 0.15);
                    Position = UDim2.fromScale(0.5, 0.83);
                    AnchorPoint = Core.UI.AnchorPoint.BottomCenter;
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;

                    Text = XpNeeded ~= nil and tostring(Xp).." / "..tostring(XpNeeded) or tostring(Xp);
                    TextScaled = true;
                    TextStrokeTransparency = 0;
                    TextXAlignment = Enum.TextXAlignment.Right;
                    TextColor3 = Core.UI.Theme.TextColor3;
                    FontFace = Core.UI.Theme.TextFont;
                }, {});

                Level = Roact.createElement("TextLabel", {
                    Size = UDim2.fromScale(1, 0.35);
                    Position = UDim2.fromScale(0.5, 0.65);
                    AnchorPoint = Core.UI.AnchorPoint.BottomCenter;
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;

                    Text = LevelName;
                    TextScaled = true;
                    TextStrokeTransparency = 0;
                    TextXAlignment = Enum.TextXAlignment.Right;
                    TextColor3 = LevelColor;
                    FontFace = Core.UI.Theme.TextFont;
                }, {});
            });

            InventoryContainer = Roact.createElement("Frame", {
                Size = UDim2.fromScale(1, 0.8);
                Position = Collapsed and UDim2.fromScale(1.6, 1) or Core.UI.Position.BottomRight;
                AnchorPoint = Core.UI.AnchorPoint.BottomRight;

                BackgroundTransparency = 1;
            }, {
                Inventory = Roact.createElement("Frame", {
                    Size = UDim2.fromScale(0.6, 1);
                    Position = Core.UI.Position.TopRight;
                    AnchorPoint = Core.UI.AnchorPoint.TopRight;

                    BackgroundColor3 = Core.UI.Theme.BackgroundColorPrimary;
                    BorderSizePixel = 0;
                }, {
                    Ores = Roact.createElement("ScrollingFrame", {
                        Size = UDim2.fromScale(1, 1);
                        BackgroundTransparency = 1;
                        BorderSizePixel = 0;

                        ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255);
                        ScrollBarThickness = 5;
                        VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right;
                        VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar;
                        AutomaticCanvasSize = Enum.AutomaticSize.Y;
                        ScrollingDirection = Enum.ScrollingDirection.Y;
                        CanvasSize = UDim2.fromScale(1, 1);
                    }, Components)
                });

                CollapseButton = Roact.createElement("TextButton", {
                    Size = UDim2.fromScale(0.1, 0.1);
                    Position = Collapsed and UDim2.fromScale(0.4, 0.7) or UDim2.fromScale(0.4, 0.9);
                    AnchorPoint = Core.UI.AnchorPoint.BottomRight;
                    SizeConstraint = Enum.SizeConstraint.RelativeXX;
                    BackgroundColor3 = Collapsed and Core.UI.Theme.OpenButtonColor or Core.UI.Theme.CloseButtonColor;
                    BorderSizePixel = 0;

                    Text = Collapsed and "<" or ">";
                    TextScaled = true;
                    TextColor3 = Core.UI.Theme.TextColor3;
                    FontFace = Core.UI.Theme.TextFont;

                    [Roact.Event.MouseButton1Click] = function()
                        self:setState(function(CurrentState)
                            return {
                                Collapsed = not CurrentState.Collapsed
                            }
                        end)
                    end;
                }, {
                    Corners = Roact.createElement("UICorner", {
                        CornerRadius = UDim.new(1, 0)
                    }, {});
                });

                Capacity = Roact.createElement("TextLabel", {
                    Size = UDim2.fromScale(0.4, 0.1);
                    Position = Core.UI.Position.Bottomleft;
                    AnchorPoint = Core.UI.AnchorPoint.BottomLeft;
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;

                    Text = tostring(Amount).." / "..tostring(Capacity);
                    TextScaled = true;
                    TextStrokeTransparency = 0;
                    TextYAlignment = Enum.TextYAlignment.Bottom;
                    TextXAlignment = Enum.TextXAlignment.Right;
                    TextColor3 = Color;
                    FontFace = Core.UI.Theme.TextFont;
                }, {})
            })
        })
    })
end

function InventoryComponent:UpdateInventory(NewAmount :number, NewCapacity :number, NewOreList)
    LogService:Log("Updating inventory info")
    if self.state.OreList.Destroy then
        self.state.OreList:Destroy()
    end

    self:setState({
        OreList = NewOreList;
        Capacity = NewCapacity;
        Amount = NewAmount;
    })
end



-- [[ KNIT ]] --

function InventoryController:KnitStart()
    DataService = Knit.GetService("DataService")
    LogService = Knit.GetService("LogService")
    DeviceController = Knit.GetController("DeviceController")
    UIService = Knit.GetService("UIService")

    DataService.DataLoaded:Connect(function(LoadedDataFolder :Core.DataFolder)
        DataFolder = LoadedDataFolder

        local App = Core.Roact.createElement(InventoryComponent)
        Roact.mount(App, Knit.Player.PlayerGui, "Inventory")
        LogService:Log("Mounted inventory component")
    end)
end

return InventoryController
