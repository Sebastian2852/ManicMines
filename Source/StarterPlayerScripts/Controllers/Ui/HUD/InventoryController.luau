local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Core = require(ReplicatedStorage.Game.Modules.Core)
local Roact = require(ReplicatedStorage.Packages.Roact)

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

    self:UpdateInventory(0, 0, CreateInventoryOreList())

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

    return Roact.createElement("ScreenGui", {}, {
        Container = Roact.createElement("Frame", {
            Size = UDim2.fromScale(0.22, 0.6);
            Position = Core.UI.Position.BottomRight;
            AnchorPoint = Core.UI.AnchorPoint.BottomRight;

            BackgroundTransparency = 1;
        }, {
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
                        CanvasSize = UDim2.fromScale(1, 1)
                    }, Components)
                })
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
