local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)

local Text = Roact.PureComponent:extend("Text")

local Theme = require(script.Parent.Parent.Theme)

function Text:render()
    local Transparency = self.props.Transparency or 0
    local BigText = self.props.BigText
    local SmallText = self.props.SmallText

    return Roact.createElement("Frame", {
        Size = UDim2.fromScale(1, 1);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
    }, {
        Layout = Roact.createElement("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
        }, {});

        BigText = Roact.createElement("TextLabel", {
            Size = UDim2.fromScale(1, 0.6);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;

            Text = BigText;
            TextTransparency = Transparency;
            TextScaled = true;
            TextXAlignment = Enum.TextXAlignment.Left;
            TextColor3 = Theme.TextColor;
            FontFace = Theme.Font;
        }, {});

        SmallText = Roact.createElement("TextLabel", {
            Size = UDim2.fromScale(1, 0.4);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;

            Text = SmallText;
            TextTransparency = Transparency;
            TextScaled = true;
            TextXAlignment = Enum.TextXAlignment.Left;
            TextColor3 = Theme.TextColor;
            FontFace = Theme.Font;
        }, {});
    })
end

return Text