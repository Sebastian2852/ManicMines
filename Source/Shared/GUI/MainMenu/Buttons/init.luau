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

        PlayButton = Roact.createElement(MenuButton, {
            LayoutOrder = 1;
            Text = "Play";
            OnClick = function()
                self.props.OnClickPlay()
            end;
        });

        Credits = Roact.createElement(MenuButton, {
            LayoutOrder = 2;
            Text = "Credits";
            OnClick = function()
                self.props.OnClickCredits()
            end;
        });
    });
end

return MenuButtons