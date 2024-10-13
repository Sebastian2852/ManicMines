local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Core = require(ReplicatedStorage.Game.Modules.Core)

local Random = Random.new()

local InventoryController = Knit.CreateController { Name = "InventoryController" }

local DataService
local LogService
local DataFolder :Core.DataFolder

-- [[ UI ]]--

local InventoryComponent = Core.Roact.Component:extend("InventoryComponent")

function InventoryComponent:init()
    local Ores = {}

    for _, RealOre in pairs(Core.Assets.Ores:GetChildren()) do
        local DisplayName = RealOre:GetAttribute("DisplayName") or "error getting display name for ore: "..RealOre.Name
        Ores[DisplayName] = 0
    end

    self:setState({
        OreList = {};
        Capacity = 0;
        Amount = 0;
    })

    task.spawn(function()
        local TestList = Core.OreList.New()
        TestList:AddOre("Stone", 15)
        self:UpdateInventory(Random:NextInteger(0, 100), Random:NextInteger(0, 100), TestList)

        while task.wait(5) do
            local NewList = Core.OreList.New()
            NewList:AddOre("Stone", Random:NextInteger(0, 50))
            self:UpdateInventory(Random:NextInteger(0, 100), Random:NextInteger(0, 100), NewList)
        end
    end)
end

function InventoryComponent:render()
    LogService:Log("Rendering inventory")
    local Components = Core.UI:CreateOreFrames(self.state.OreList, Core.UI.OreFrameStyle.PcInventory, UDim2.fromScale(1, 0.1))
    Components["Layout"] = Core.Roact.createElement("UIListLayout", {}, {})


    return Core.Roact.createElement("ScreenGui", {}, {
        Inventory = Core.Roact.createElement("Frame", {
            Size = UDim2.fromScale(0.22, 0.55);
            AnchorPoint = Core.UI.AnchorPoint.BottomRight;
            Position = Core.UI.Position.BottomRight;
            BackgroundTransparency = 1;
        }, {
            Layout = Core.Roact.createElement("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal;
                SortOrder = Enum.SortOrder.LayoutOrder;

                HorizontalAlignment = Enum.HorizontalAlignment.Right;
                VerticalAlignment = Enum.VerticalAlignment.Bottom;

                HorizontalFlex = Enum.UIFlexAlignment.Fill;
                VerticalFlex = Enum.UIFlexAlignment.None;
            }, {});

            MainInventoryFrame = Core.Roact.createElement("Frame", {
                Size = UDim2.fromScale(0.6, 1);
                Position = Core.UI.Position.BottomRight;
                AnchorPoint = Core.UI.AnchorPoint.BottomRight;
                LayoutOrder = 2;

                BackgroundColor3 = Core.UI.Theme.BackgroundColor;
                BackgroundTransparency = Core.UI.Theme.BackgroundColorTransparency;
            }, {
                AspectRatio = Core.Roact.createElement("UIAspectRatioConstraint", {
                    AspectRatio = 0.5;
                    AspectType = Enum.AspectType.FitWithinMaxSize;
                    DominantAxis = Enum.DominantAxis.Height;
                }, {});

                Ores = Core.Roact.createElement("ScrollingFrame", {
                    Size = UDim2.fromScale(1, 1);
                    Position = Core.UI.Position.Center;
                    AnchorPoint = Core.UI.AnchorPoint.Center;
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;
                    ScrollBarThickness = 5;
                    ScrollBarImageColor3 = Core.UI.Color.White;
                    AutomaticCanvasSize = Enum.AutomaticSize.Y;
                }, Components)
            });

            Information = Core.Roact.createElement("Frame", {
                Size = UDim2.fromScale(0.3, 0.15);
                BackgroundTransparency = 1;
                LayoutOrder = 1;
            }, {
                Layout = Core.Roact.createElement("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder;
                    HorizontalAlignment = Enum.HorizontalAlignment.Right;
                }, {});

                CloseButton = Core.Roact.createElement("TextButton", {
                    Size = UDim2.fromScale(0.5, 0.5);
                    LayoutOrder = 1;
                    SizeConstraint = Enum.SizeConstraint.RelativeYY;

                    Text = ">";
                    TextScaled = true;
                    TextStrokeTransparency = 0;

                    BackgroundColor3 = Core.UI.Color.Black;
                    BackgroundTransparency = Core.UI.Theme.BackgroundColorTransparency;
                    TextColor3 = Core.UI.Theme.TextColor3;
                    FontFace = Core.UI.Theme.TextFont;
                }, {
                    Circle = Core.Roact.createElement("UICorner", {
                        CornerRadius = UDim.new(1, 0)
                    }, {})
                });

                Capacity = Core.Roact.createElement("TextLabel", {
                    Size = UDim2.fromScale(1, 0.5);
                    LayoutOrder = 2;
                    BackgroundTransparency = 1;

                    Text = self.state.Amount.." / "..self.state.Capacity;
                    TextScaled = true;
                    TextStrokeTransparency = 0;
                    TextXAlignment = Enum.TextXAlignment.Right;

                    FontFace = Core.UI.Theme.TextFont;
                    TextColor3 = Core.UI.Theme.TextColor3;
                }, {})
            });
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
    DataService:GetPlayerDataFolder():andThen(function(Return)
        DataFolder = Return
    end)

    local App = Core.Roact.createElement(InventoryComponent)
    Core.Roact.mount(App, Knit.Player.PlayerGui, "Inventory")
    LogService:Log("Mounted Inventory component")
end

return InventoryController
