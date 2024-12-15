local Roact = require(script.Parent.Parent.External.Roact)

local Gui = {}

function Gui.CreateCorners(Radius :number) :Roact.Element
    return Roact.createElement("UICorner", {
        CornerRadius = UDim.new(Radius, 0)
    }, {})
end

function Gui.CreateBorderImage() :Roact.Element
    return Roact.createElement("ImageLabel", {
        Size = UDim2.fromScale(1, 1);
        BackgroundTransparency = 1;

        Image = "rbxassetid://5981360137";
        ImageColor3 = Color3.fromRGB(83, 83, 83);
        ScaleType = Enum.ScaleType.Slice;
        SliceCenter = Rect.new(Vector2.new(10, 10), Vector2.new(10, 10));
        SliceScale = 0.5;
    }, {})
end

return Gui