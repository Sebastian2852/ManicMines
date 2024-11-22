local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)
local Core = require(ReplicatedStorage.Game.Modules.Core)

return function(HeadingText :string, LayoutOrder :number)
    return Roact.createElement("TextLabel", {
        Size = UDim2.fromScale(0.9, 0.135);
        Position = UDim2.fromScale(0.5, 0);
        AnchorPoint = Vector2.new(0.5, 0.5);

        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        LayoutOrder = LayoutOrder;

        Text = HeadingText;
        TextScaled = true;

        FontFace = Core.UI.Theme.TextFont;
        TextColor3 = Core.UI.Theme.TextColor3;
    }, {})
end