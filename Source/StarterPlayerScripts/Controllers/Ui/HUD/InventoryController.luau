local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Core = require(ReplicatedStorage.Game.Modules.Core)
local Roact = require(ReplicatedStorage.Packages.Roact)
local Enums = require(ReplicatedStorage.Game.Modules.Enums)

local InventoryController = Knit.CreateController { Name = "InventoryController" }

local LogService
local DataService
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
        StyleToUse = Enums.OreFrameStyle.Normal;
        OreList = {};
        Capacity = 0;
        Amount = 0;
    })

    for _, OreDataValue :IntValue in pairs(DataFolder:WaitForChild("Inventory"):WaitForChild("Ores"):GetChildren()) do
        OreDataValue:GetPropertyChangedSignal("Value"):Connect(function()
            self:UpdateInventory(0, 0, CreateInventoryOreList())
        end)
    end

    self:UpdateInventory(0, 0, CreateInventoryOreList())

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

--[=[
IDEA:
On mobile the inventory is hidden by default, when the use wants to see the inventroy they press a button and the invetory opens
covering 1/3 of their screen on the right. When they press anywhere else the GUI hides and button reappears.
]=]

function InventoryComponent:render()
    LogService:Log("Rendering inventory")
    local Components = Core.UI:CreateOreFrames(self.state.OreList, self.state.StyleToUse, UDim2.fromScale(1, 0.1))
    Components["Layout"] = Core.Roact.createElement("UIListLayout", {}, {})

    return Roact.createElement("ScreenGui", {
        ResetOnSpawn = false
    }, {
        Container = Roact.createElement("Frame", {
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
                Size = UDim2.fromScale(0.75, 0.2);
                Position = Core.UI.Position.TopRight;
                AnchorPoint = Core.UI.AnchorPoint.TopRight;

                BackgroundTransparency = 1;
            }, {});

            InventoryContainer = Roact.createElement("Frame", {
                Size = UDim2.fromScale(1, 0.8);
                Position = Core.UI.Position.BottomRight;
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

                Capacity = Roact.createElement("TextLabel", {
                    Size = UDim2.fromScale(0.4, 0.1);
                    Position = Core.UI.Position.Bottomleft;
                    AnchorPoint = Core.UI.AnchorPoint.BottomLeft;
                    BackgroundTransparency = 1;

                    Text = "0 / 70";
                    TextScaled = true;
                    TextStrokeTransparency = 0;
                    TextYAlignment = Enum.TextYAlignment.Bottom;
                    TextXAlignment = Enum.TextXAlignment.Right;
                    TextColor3 = Core.UI.Theme.TextColor3;
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

    DataService.DataLoaded:Connect(function(LoadedDataFolder :Core.DataFolder)
        DataFolder = LoadedDataFolder

        local App = Core.Roact.createElement(InventoryComponent)
        Roact.mount(App, Knit.Player.PlayerGui, "Inventory")
        LogService:Log("Mounted inventory component")
    end)
end

return InventoryController
