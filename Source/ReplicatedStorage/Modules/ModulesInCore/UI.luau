-- This module describes how UI should look by default, as well as functions for creating common components. Having it all in this one module
-- will make it easier to edit all the ui at once.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UI = {}

local Roact = require(ReplicatedStorage.Packages.Roact)
local EnumList = require(ReplicatedStorage.Packages.EnumList)

UI.Theme = {
    BackgroundColor = Color3.new(0, 0, 0);
    BackgroundColorTransparency = 0.5;

    TextColor3 = Color3.new(1, 1, 1);
    TextFont = Font.fromEnum(Enum.Font.Highway);
    TextStrokeTransparency = 0;

    TextColorDisabled = Color3.new(0.278431, 0.278431, 0.278431);
}

UI.OreFrameStyle = EnumList.new("OreFrameStyle", {
    "PcInventory";
    "Normal";
})

function UI:CreateOreFrame(OreList, Style :EnumList.EnumItem, Size :UDim2, Position :UDim2)
    for OreName :string, OreData in pairs(OreList:LoopList()) do

        if Style.Value == 1 then
            return Roact.createElement("Frame", {
                Size = Size;
                Position = Position;
                AnchorPoint = Vector2.new(0.5, 0.5);

                BackgroundTransparency = 0.5; -- Maybe make this a param since it can depend on the UI how transparent it should be
                BorderSizePixel = 0;
            }, {
                Gradient = Roact.createElement("UIGradient", {
                    Color = OreData.RealOre:GetAttribute("InventoryBackgroundColor");
                }, {});

                Layout = Roact.createElement("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal;
                    SortOrder = Enum.SortOrder.LayoutOrder;
                    Wraps = false;
                    Padding = UDim.new(0.01, 0);

                    HorizontalAlignment = Enum.HorizontalAlignment.Left;
                    VerticalAlignment = Enum.VerticalAlignment.Center;
                    ItemLineAlignment = Enum.ItemLineAlignment.Center;

                    VerticalFlex = Enum.UIFlexAlignment.None;
                    HorizontalFlex = Enum.UIFlexAlignment.Fill;
                }, {});

                OreImage = Roact.createElement("ImageLabel", {
                    Size = UDim2.fromScale(0.1, 1);
                    BackgroundTransparency = 1;
                    LayoutOrder = 1;

                    Image = OreData.Emblem;
                    ScaleType = Enum.ScaleType.Fit;
                }, {
                    AspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint", {
                        AspectRatio = 1;
                        AspectType = Enum.AspectType.ScaleWithParentSize;
                        DominantAxis = Enum.DominantAxis.Height;
                    }, {})
                });

                Details = Roact.createElement("Frame", {
                    Size = UDim2.fromScale(1, 1);
                    BackgroundTransparency = 1;
                    LayoutOrder = 2;
                }, {
                    Layout = Roact.createElement("UIListLayout", {
                        SortOrder = Enum.SortOrder.LayoutOrder;
                        Wraps = false;
                        FillDirection = Enum.FillDirection.Vertical;

                        HorizontalFlex = Enum.UIFlexAlignment.None;
                        VerticalFlex = Enum.UIFlexAlignment.None;

                        HorizontalAlignment = Enum.HorizontalAlignment.Left;
                        ItemLineAlignment = Enum.ItemLineAlignment.Automatic;
                        VerticalAlignment = Enum.VerticalAlignment.Top;
                    }, {});

                    OreName = Roact.createElement("TextLabel", {
                        BackgroundTransparency = 1;
                        Size = UDim2.fromScale(1, 0.6);

                        Text = OreName;
                        FontFace = UI.Theme.TextFont;
                        TextStrokeTransparency = 0;
                        TextScaled = true;

                        TextXAlignment = Enum.TextXAlignment.Left;
                        TextYAlignment = Enum.TextYAlignment.Bottom;

                        TextColor3 = UI.Theme.TextColor3;
                    }, {});

                    OreAmount = Roact.createElement("TextLabel", {
                        Size = UDim2.fromScale(1, 0.4);
                        BackgroundTransparency = 1;

                        Text = tostring(OreData.Amount);
                        FontFace = UI.Theme.TextFont;
                        TextStrokeTransparency = 0;
                        TextScaled = true;

                        TextXAlignment = Enum.TextXAlignment.Left;
                        TextYAlignment = Enum.TextYAlignment.Top;

                        TextColor3 = UI.Theme.TextColor3;
                    }, {});
                })
            })
        else -- No other styles so its fine to assume anything else means the normal style
            return Roact.createElement("Frame", {
                Size = Size;
                Position = Position;
                AnchorPoint = Vector2.new(0.5, 0.5);

                BackgroundTransparency = 0.5; -- Maybe make this a param since it can depend on the UI how transparent it should be
                BorderSizePixel = 0;
            }, {
                Gradient = Roact.createElement("UIGradient", {
                    Color = OreData.RealOre:GetAttribute("InventoryBackgroundColor");
                }, {});

                Layout = Roact.createElement("UIListLayout", {
                    Padding = UDim.new(0.01, 0);
                    FillDirection = Enum.FillDirection.Horizontal;
                    SortOrder = Enum.SortOrder.LayoutOrder;

                    HorizontalAlignment = Enum.HorizontalAlignment.Left;
                    ItemLineAlignment = Enum.ItemLineAlignment.Automatic;
                    VerticalAlignment = Enum.VerticalAlignment.Center;

                    HorizontalFlex = Enum.UIFlexAlignment.Fill;
                    VerticalFlex = Enum.UIFlexAlignment.None;
                }, {});

                OreImage = Roact.createElement("ImageLabel", {
                    Size = UDim2.fromScale(0.1, 1);
                    BackgroundTransparency = 1;
                    LayoutOrder = 1;

                    Image = OreData.Emblem;
                    ScaleType = Enum.ScaleType.Fit;
                }, {
                    AspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint", {
                        AspectRatio = 1;
                        AspectType = Enum.AspectType.ScaleWithParentSize;
                        DominantAxis = Enum.DominantAxis.Height;
                    }, {})
                });

                Details = Roact.createElement("Frame", {
                    BackgroundTransparency = 1;
                    Size = UDim2.fromScale(1, 1);
                    LayoutOrder = 2;
                }, {
                    Layout = Roact.createElement("UIListLayout", {
                        Padding = UDim.new(0, 0);
                        FillDirection = Enum.FillDirection.Horizontal;
                        SortOrder = Enum.SortOrder.LayoutOrder;

                        HorizontalAlignment = Enum.HorizontalAlignment.Center;
                        ItemLineAlignment = Enum.ItemLineAlignment.Automatic;
                        VerticalAlignment = Enum.VerticalAlignment.Center;

                        HorizontalFlex = Enum.UIFlexAlignment.Fill;
                        VerticalFlex = Enum.UIFlexAlignment.Fill;
                    }, {});

                    OreName = Roact.createElement("TextLabel", {
                        BackgroundTransparency = 1;
                        Size = UDim2.fromScale(0.6, 1);
                        LayoutOrder = 1;

                        Text = OreName;
                        FontFace = UI.Theme.TextFont;
                        TextStrokeTransparency = 0;
                        TextScaled = true;

                        TextXAlignment = Enum.TextXAlignment.Left;

                        TextColor3 = UI.Theme.TextColor3;
                    }, {});

                    OreAmount = Roact.createElement("TextLabel", {
                        BackgroundTransparency = 1;
                        Size = UDim2.fromScale(0.22, 1);
                        LayoutOrder = 2;

                        Text = tostring(OreData.Amount);
                        FontFace = UI.Theme.TextFont;
                        TextStrokeTransparency = 0;
                        TextScaled = true;

                        TextXAlignment = Enum.TextXAlignment.Right;

                        TextColor3 = UI.Theme.TextColor3;
                    }, {});
                })
            })
        end
    end
end

return UI