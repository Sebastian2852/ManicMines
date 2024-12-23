local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)

local Currency = Roact.Component:extend("Currency")

local Theme = require(script.Parent.Parent.Theme)
local Amount = require(script.Currency)

function Currency:render()
    return Roact.createElement("Frame", {
        Size = UDim2.fromScale(1, 1);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
    }, {
        Layout = Roact.createElement("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder;
            FillDirection = Enum.FillDirection.Vertical;
            HorizontalAlignment = Enum.HorizontalAlignment.Left;
            VerticalAlignment = Enum.VerticalAlignment.Bottom;
        }, {});

        GoldContainer = Roact.createElement("Frame", {
            Size = UDim2.fromScale(1, 0.15);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
        }, {
            Gold = Roact.createElement(Amount, {
                Currency = "Gold";
                Image = Theme.Images.Gold;
            }, {});
        });
    });
end

return Currency