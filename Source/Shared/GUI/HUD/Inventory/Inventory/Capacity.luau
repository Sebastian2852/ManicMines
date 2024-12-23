local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)

local Capacity = Roact.Component:extend("Capacity")

local Theme = require(script.Parent.Parent.Parent.Parent.Theme)

function Capacity:render()
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

            Text = "0";
            TextScaled = true;
            TextXAlignment = Enum.TextXAlignment.Left;
            TextColor3 = Theme.TextColor;
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
            TextColor3 = Theme.TextColor;
            FontFace = Theme.Font;
        }, {});

        Max = Roact.createElement("TextLabel", {
            Size = UDim2.fromScale(0.45, 1);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            LayoutOrder = 3;

            Text = "70";
            TextScaled = true;
            TextXAlignment = Enum.TextXAlignment.Right;
            TextColor3 = Theme.TextColor;
            FontFace = Theme.Font;
        }, {});
    });
end

return Capacity