local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Packages.Roact)
local Core = require(ReplicatedStorage.Game.Modules.Core)

local Component = Roact.Component:extend("ForgeButton")

function Component:render()
    return Roact.createElement("Frame", {
        Size = UDim2.fromScale(0.15, 0.35);
        BackgroundColor3 = Core.UI.Color.White;
        BorderSizePixel = 0;
        LayoutOrder = tonumber(self.props.PickaxeConfig.Name)
    }, {
        Name = Roact.createElement("TextLabel", {
            Size = UDim2.fromScale(1, 0.15);
            BorderSizePixel = 0;
            BackgroundTransparency = 1;

            Text = "<u>"..self.props.Name.."</u>";
            TextScaled = true;
            RichText = true;
            TextXAlignment = Enum.TextXAlignment.Left;
            TextColor3 = Core.UI.Theme.TextColor3;
            FontFace = Core.UI.Theme.TextFont;
        }, {});

        Icon = Roact.createElement("ImageLabel", {
            Size = UDim2.fromScale(0.9, 0.85);
            Position = UDim2.fromScale(0.5, 0.55);
            AnchorPoint = Core.UI.AnchorPoint.Center;
            BackgroundTransparency = 1;
            BorderSizePixel = 0;

            Image = self.props.Icon;
            ScaleType = Enum.ScaleType.Fit;
        }, {});

        Gradient = Roact.createElement("UIGradient", {
            Color = self.props.Gradient;
        }, {});

        Corners = Roact.createElement("UICorner", {
            CornerRadius = UDim.new(0.1, 0)
        }, {});

        AspectRatio = Roact.createElement("UIAspectRatioConstraint", {
            AspectRatio = 0.984;
            AspectType = Enum.AspectType.FitWithinMaxSize;
            DominantAxis = Enum.DominantAxis.Width;
        }, {});

        Button = Roact.createElement("TextButton", {
            Size = UDim2.fromScale(1, 1);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            Text = "";

            [Roact.Event.MouseButton1Click] = self.props.OnClick and self.props.OnClick or function()
                warn("Missing on click function for pickaxe: "..self.props.PickaxeConfig.Name)
            end;
        }, {})
    })
end

return function (PickaxeConfig :boolean, Owned :boolean, OnClick :() -> ())
    local Pickaxe :Tool = PickaxeConfig:FindFirstChildWhichIsA("Tool")

    local Icon :string = PickaxeConfig:GetAttribute("Icon")
    local Gradient :ColorSequence = PickaxeConfig:GetAttribute("ButtonGradient")
    local Name :string = PickaxeConfig:GetAttribute("Name")

    local Button = Roact.createElement(Component, {
        Name = Name;
        Icon = Icon;
        Gradient = Gradient;
        PickaxeConfig = PickaxeConfig;
        OnClick = OnClick;
    })
    return Button
end