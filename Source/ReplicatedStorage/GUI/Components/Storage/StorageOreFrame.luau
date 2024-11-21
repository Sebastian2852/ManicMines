local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Enums = require(ReplicatedStorage.Game.Modules.Enums)
local Roact = require(ReplicatedStorage.Packages.Roact)

local InventoryOreFrame = Roact.Component:extend("InventoryOreFrame")

function InventoryOreFrame:render()
    local Ore = self.props.Ore :: BasePart
    local Amount = self.props.Amount :: number

    local Gradient = Ore:GetAttribute("InventoryBackgroundColor")
    local Icon = Ore:GetAttribute("EmblemImageID")
    local Name = Ore:GetAttribute("DisplayName")

    return Roact.createElement("Frame", {
        Size = UDim2.fromScale(1, 0.05);
        AnchorPoint = Vector2.new(0.5, 0.5);
        BackgroundTransparency = 0.5;
        BorderSizePixel = 0;
    }, {
        Gradient = Roact.createElement("UIGradient", {
            Color = Gradient;
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

            Image = Icon;
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

                Text = Name;
                FontFace = Core.UI.Theme.TextFont;
                TextStrokeTransparency = 0;
                TextScaled = true;

                TextXAlignment = Enum.TextXAlignment.Left;

                TextColor3 = Core.UI.Theme.TextColor3;
            }, {});

            OreAmount = Roact.createElement("TextLabel", {
                BackgroundTransparency = 1;
                Size = UDim2.fromScale(0.22, 1);
                LayoutOrder = 2;

                Text = tostring(Amount);
                FontFace = Core.UI.Theme.TextFont;
                TextStrokeTransparency = 0;
                TextScaled = true;

                TextXAlignment = Enum.TextXAlignment.Right;

                TextColor3 = Core.UI.Theme.TextColor3;
            }, {});
        })
    })
end


local StorageOreFrame = Roact.Component:extend("StorageOreFrame")

function StorageOreFrame:render()
    local Ore = self.props.Ore :: BasePart
    local Amount = self.props.Amount :: number

    local Gradient = Ore:GetAttribute("InventoryBackgroundColor")
    local Icon = Ore:GetAttribute("EmblemImageID")
    local Name = Ore:GetAttribute("DisplayName")

    return Roact.createElement("Frame", {
        Size = UDim2.fromScale(1, 0.05);
        AnchorPoint = Vector2.new(0.5, 0.5);
        BackgroundTransparency = 0.5;
        BorderSizePixel = 0;
    }, {
        Gradient = Roact.createElement("UIGradient", {
            Color = Gradient;
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
            LayoutOrder = 2;

            Image = Icon;
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
            LayoutOrder = 1;
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
                LayoutOrder = 2;

                Text = Name;
                FontFace = Core.UI.Theme.TextFont;
                TextStrokeTransparency = 0;
                TextScaled = true;

                TextXAlignment = Enum.TextXAlignment.Right;

                TextColor3 = Core.UI.Theme.TextColor3;
            }, {});

            OreAmount = Roact.createElement("TextLabel", {
                BackgroundTransparency = 1;
                Size = UDim2.fromScale(0.22, 1);
                LayoutOrder = 1;

                Text = tostring(Amount);
                FontFace = Core.UI.Theme.TextFont;
                TextStrokeTransparency = 0;
                TextScaled = true;

                TextXAlignment = Enum.TextXAlignment.Left;

                TextColor3 = Core.UI.Theme.TextColor3;
            }, {});
        })
    })
end

return function(Type :Enums.Enum, OreName :string, Amount :number) :Roact.Element
    local Ore = Core.Util:GetOreByName(OreName)
    if not Ore then
        warn("No ore with name: "..tostring(OreName).."; using stone instead")
    end

    if Type == Enums.StorageOreFrameType.Inventory then
        return Roact.createElement(InventoryOreFrame, {Amount = Amount, Ore = Ore ~= nil and Ore or Core.Assets.Stone})
    elseif Type == Enums.StorageOreFrameType.Storage then
        return Roact.createElement(StorageOreFrame, {Amount = Amount, Ore = Ore ~= nil and Ore or Core.Assets.Stone})
    end
end