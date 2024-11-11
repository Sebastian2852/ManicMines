local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Core = require(ReplicatedStorage.Game.Modules.Core)

local Random = Random.new()
local LastInputType = "None"

local InventoryController = Knit.CreateController { Name = "InventoryController" }

local LogService
local DataService
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
        StyleToUse = Core.UI.OreFrameStyle.Normal;
        OreList = {};
        Capacity = 0;
        Amount = 0;
    })

    for _, OreDataValue :IntValue in pairs(DataFolder:WaitForChild("Inventory"):WaitForChild("Ores"):GetChildren()) do
        OreDataValue:GetPropertyChangedSignal("Value"):Connect(function()
            self:UpdateInventory(0, 0, CreateInventoryOreList())
        end)
    end

    UserInputService.InputBegan:Connect(function()
        local InputType = UserInputService:GetLastInputType()

        -- Long ass if statment to check all the possible PC input types
        -- Thanks roblox for not making any simple way to check device :D
        if InputType == Enum.UserInputType.Keyboard or InputType == Enum.UserInputType.MouseMovement or InputType == Enum.UserInputType.MouseButton1 or InputType == Enum.UserInputType.MouseButton2 or InputType == Enum.UserInputType.MouseButton3 then
            if LastInputType == "PC" then return end
            self:setState(function(PreviousState :{any})
                PreviousState.StyleToUse = Core.UI.OreFrameStyle.PcInventory
                return PreviousState
            end)
            LastInputType = "PC"
        else
            if LastInputType == "Mobile" then return end
            self:setState(function(PreviousState :{any})
                PreviousState.StyleToUse = Core.UI.OreFrameStyle.Normal
                return PreviousState
            end)
            LastInputType = "Mobile"
        end
    end)
end

function InventoryComponent:render()
    LogService:Log("Rendering inventory")
    local Components = Core.UI:CreateOreFrames(self.state.OreList, self.state.StyleToUse, UDim2.fromScale(1, 0.1))
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

        repeat
            task.wait(0.1)
        until DataFolder.DataLoaded.Value

        local App = Core.Roact.createElement(InventoryComponent)
        Core.Roact.mount(App, Knit.Player.PlayerGui, "Inventory")
        LogService:Log("Mounted Inventory component")
    end)

end

return InventoryController
