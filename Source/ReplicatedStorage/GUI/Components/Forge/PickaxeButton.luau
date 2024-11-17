local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Packages.Roact)
local Core = require(ReplicatedStorage.Game.Modules.Core)

local Component = Roact.Component:extend("ForgeButton")

local function CreateOutline(Owned :boolean, Locked :boolean)
    local Color = Core.UI.Color.Red

    if Owned then
        Color = Core.UI.Theme.OpenButtonColor
    elseif not Owned and not Locked then
        Color = Core.UI.Theme.PrimaryButtonColor
    end

    return Roact.createElement("UIStroke", {
        Thickness = 3;
        Color = Color;
    }, {})
end

function Component:render()
    local ShouldShowName = self.props.Owned or (not self.props.Owned and not self.props.Locked)

    return Roact.createElement("Frame", {
        Size = UDim2.fromScale(0.15, 0.35);
        BackgroundColor3 = Core.UI.Color.White;
        BorderSizePixel = 0;
        LayoutOrder = tonumber(self.props.PickaxeConfig.Name)
    }, {
        Name = ShouldShowName and Roact.createElement("TextLabel", {
            Size = UDim2.fromScale(1, 0.15);
            BorderSizePixel = 0;
            BackgroundTransparency = 1;
            ZIndex = 3;

            Text = "<u>"..self.props.Name.."</u>";
            TextScaled = true;
            RichText = true;
            TextStrokeTransparency = 0;
            TextXAlignment = Enum.TextXAlignment.Left;
            TextColor3 = Core.UI.Theme.TextColor3;
            FontFace = Core.UI.Theme.TextFont;
        }, {});

        Icon = Roact.createElement("ImageLabel", {
            Size = UDim2.fromScale(1, 1);
            Position = UDim2.fromScale(0.5, 0.5);
            AnchorPoint = Core.UI.AnchorPoint.Center;
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            ZIndex = 2;

            Image = self.props.Icon;
            ScaleType = Enum.ScaleType.Fit;
            ImageColor3 = not self.props.Locked and Core.UI.Color.White or Core.UI.Color.Black;
        }, {});

        Gradient = Roact.createElement("UIGradient", {
            Color = self.props.Owned and self.props.Gradient or ColorSequence.new(Core.UI.Theme.BackgroundColorDark);
        }, {});

        Corners = Roact.createElement("UICorner", {
            CornerRadius = UDim.new(0.1, 0)
        }, {});

        AspectRatio = Roact.createElement("UIAspectRatioConstraint", {
            AspectRatio = 0.984;
            AspectType = Enum.AspectType.FitWithinMaxSize;
            DominantAxis = Enum.DominantAxis.Width;
        }, {});

        Button = not self.props.Locked and Roact.createElement("TextButton", {
            Size = UDim2.fromScale(1, 1);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            ZIndex = 10;

            Text = "";

            [Roact.Event.MouseButton1Click] = self.props.OnClick and self.props.OnClick or function()
                warn("Missing on click function for pickaxe: "..self.props.PickaxeConfig.Name)
            end;
        }, {});

        Lock = self.props.Locked and Roact.createElement("ImageLabel", {
            Size = UDim2.fromScale(0.85, 0.85);
            Position = Core.UI.Position.Center;
            AnchorPoint = Core.UI.AnchorPoint.Center;
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            ZIndex = 10;

            Image = Core.UI.Images.Lock;
            ImageTransparency = 0.5;
        }, {});

        Outline = CreateOutline(self.props.Owned, self.props.Locked)
    })
end

return function(PickaxeConfig :boolean, Owned :boolean, Locked :boolean, OnClick :() -> ())
    local Icon :string = PickaxeConfig:GetAttribute("Icon")
    local Gradient :ColorSequence = PickaxeConfig:GetAttribute("ButtonGradient")
    local Name :string = PickaxeConfig:GetAttribute("Name")

    if Owned and Locked then
        Locked = false
    end

    local Button = Roact.createElement(Component, {
        Name = Name;
        Icon = Icon;
        Gradient = Gradient;
        PickaxeConfig = PickaxeConfig;
        Owned = Owned;
        Locked = Locked;
        OnClick = OnClick;
    })
    return Button
end