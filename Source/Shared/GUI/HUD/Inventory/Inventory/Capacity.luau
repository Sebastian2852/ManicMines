local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)
local Flipper = require(ReplicatedStorage.Packages.Flipper)
local Core = require(ReplicatedStorage.Game.Modules.Core)

local Capacity = Roact.Component:extend("Capacity")

local Theme = require(script.Parent.Parent.Parent.Parent.Theme)

function Capacity:init()
    local DataService = Knit.GetService("DataService")

    DataService:GetPlayerDataFolder():andThen(function(DataFolder :Core.DataFolder)
        local InventoryItemCount = DataFolder.Inventory.InventoryItemCount
        local InventoryCap = DataFolder.Inventory.InventoryCap

        self.ItemCountConnection = InventoryItemCount:GetPropertyChangedSignal("Value"):Connect(function()
            self:setState({
                ItemCount = InventoryItemCount.Value;
            })
        end)

        self.CapacityConnection = InventoryCap:GetPropertyChangedSignal("Value"):Connect(function()
            self:setState({
                Cap = InventoryCap.Value;
            })
        end)

        self:setState({
            ItemCount = InventoryItemCount.Value;
            Cap = InventoryCap.Value;
        })
    end)

    self.Motor = Flipper.SingleMotor.new(0)
    local Binding, SetBinding = Roact.createBinding(self.Motor:getValue())
    self.Binding = Binding
    self.Motor:onStep(SetBinding)
end

function Capacity:willUnmount()
    if self.CapacityConnection then
        self.CapacityConnection:Disconnect()
    end

    if self.ItemCountConnection then
        self.ItemCountConnection:Disconnect()
    end
end

function Capacity:render()
    local Cap = self.state.Cap or 0
    local Count = self.state.ItemCount or 0

    local Alpha = math.clamp((Count / Cap - 0.85) / (1 - 0.85), 0, 1)
    local Color = Color3.new(1, 1, 1):Lerp(Color3.new(1, 0, 0), Alpha)

    return Roact.createElement("Frame", {
        Size = UDim2.fromScale(1, 1);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
    }, {
        Layout = Roact.createElement("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal;
            SortOrder = Enum.SortOrder.LayoutOrder;
        }, {});

        Current = Roact.createElement("TextLabel", {
            Size = UDim2.fromScale(0.45, 1);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            LayoutOrder = 1;

            Text = Count;
            TextScaled = true;
            TextXAlignment = Enum.TextXAlignment.Left;
            TextColor3 = Color;
            FontFace = Theme.Font;
        }, {});

        Slash = Roact.createElement("TextLabel", {
            Size = UDim2.fromScale(0.1, 1);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            LayoutOrder = 2;

            Text = "/";
            TextScaled = true;
            TextXAlignment = Enum.TextXAlignment.Center;
            TextColor3 = Color;
            FontFace = Theme.Font;
        }, {});

        Max = Roact.createElement("TextLabel", {
            Size = UDim2.fromScale(0.45, 1);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            LayoutOrder = 3;

            Text = Cap;
            TextScaled = true;
            TextXAlignment = Enum.TextXAlignment.Right;
            TextColor3 = Color;
            FontFace = Theme.Font;
        }, {});
    });
end

return Capacity