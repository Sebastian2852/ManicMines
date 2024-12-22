local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)

local Inventory = Roact.Component:extend("Inventory")

local Level = require(script.Level)

function Inventory:render()
    return Roact.createElement("Frame", {
        Size = UDim2.fromScale(1, 1);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
    }, {
        Layout = Roact.createElement("UIListLayout", {
            Padding = UDim.new(0, 10);
            SortOrder = Enum.SortOrder.LayoutOrder;
            FillDirection = Enum.FillDirection.Vertical;
        }, {});

        Padding = Roact.createElement("UIPadding", {
            PaddingBottom = UDim.new(0, 10);
        }, {});

        LevelContainer = Roact.createElement("Frame", {
            Size = UDim2.fromScale(1, 0.15);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            LayoutOrder = 1;
        }, {
            Level = Roact.createElement(Level, {}, {});
        });

        Main = Roact.createElement("Frame", {
            Size = UDim2.fromScale(1, 0.85);
            BackgroundColor3 = Color3.new(1, 0, 0);
            BackgroundTransparency = 0.5;
            BorderSizePixel = 0;
            LayoutOrder = 2;
        }, {});
    });
end

return Inventory