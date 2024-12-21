local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Packages.Roact)

local MenuButtons = Roact.Component:extend("MenuButtons")

local MenuButton = require(script.MenuButton)

function MenuButtons:render()
    return Roact.createElement("Frame", {
        Size = UDim2.fromScale(1, 1);
        Position = UDim2.fromScale(0, 0);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
    }, {
        Layout = Roact.createElement("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder;
            HorizontalAlignment = Enum.HorizontalAlignment.Center;
            VerticalAlignment = Enum.VerticalAlignment.Center;
        }, {});

        TestButton = Roact.createElement(MenuButton, {
            LayoutOrder = 1;
            Text = "Test";
        });

        TestButtons = Roact.createElement(MenuButton, {
            LayoutOrder = 2;
            Text = "Test2";
        });
    });
end

return MenuButtons