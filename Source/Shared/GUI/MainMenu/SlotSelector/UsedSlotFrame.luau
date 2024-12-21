local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)

local UsedSlotFrame = Roact.Component:extend("UsedSlotFrame")

local Theme = require(script.Parent.Parent.Parent.Theme)

function UsedSlotFrame:render()
    return Roact.createElement("Frame", {
        Size = UDim2.fromScale(1, 0.3);
        BackgroundTransparency = 0.5;
        BorderSizePixel = 0;
    }, {
        Label = Roact.createElement("TextLabel", {
            Size = UDim2.fromScale(1, 1);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;

            Text = "UsedSlotFrame";
            TextScaled = true;
            TextXAlignment = Enum.TextXAlignment.Center;
            TextColor3 = Theme.TextColor;
            FontFace = Theme.Font;
        }, {})
    })
end

return UsedSlotFrame