local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)

local Ore = Roact.Component:extend("Ore")

local Theme = require(script.Parent.Parent.Parent.Parent.Theme)

function Ore:render()
    local OreName = self.props.OreName or "Unkown"
    local Amount = self.props.Amount or -1
    local Emblem = self.props.Emblem or Theme.Images.Missing
    local Background = self.props.Background or ColorSequence.new(Color3.new(1, 0, 0))

    return Roact.createElement("Frame", {
        Size = UDim2.fromScale(1, 1);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
    }, {
        Ore = Roact.createElement("Frame", {
            Size = UDim2.fromScale(1, 1);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
        }, {
            Background = Roact.createElement("Frame", {
                Size = UDim2.fromScale(1, 1);
                BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                BackgroundTransparency = 0.5;
                BorderSizePixel = 0;
            }, {
                Gradient = Roact.createElement("UIGradient", {
                    Color = Background;
                }, {});
            });

            Container = Roact.createElement("Frame", {
                Size = UDim2.fromScale(1, 1);
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                ZIndex = 2;
            }, {
                Layout = Roact.createElement("UIListLayout", {
                    Padding = UDim.new(0, 10);
                    FillDirection = Enum.FillDirection.Horizontal;
                    HorizontalFlex = Enum.UIFlexAlignment.Fill;
                    SortOrder = Enum.SortOrder.LayoutOrder;
                }, {});

                Emblem = Roact.createElement("ImageLabel", {
                    Size = UDim2.fromScale(1, 1);
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;
                    LayoutOrder = 1;

                    Image = Emblem;
                    ScaleType = Enum.ScaleType.Fit;
                }, {
                    AspectRatio = Roact.createElement("UIAspectRatioConstraint", {
                        AspectRatio = 1;
                        DominantAxis = Enum.DominantAxis.Height;
                        AspectType = Enum.AspectType.ScaleWithParentSize;
                    }, {});
                });

                Text = Roact.createElement("Frame", {
                    Size = UDim2.fromScale(1, 1);
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;
                    LayoutOrder = 2;
                }, {
                    Layout = Roact.createElement("UIListLayout", {
                        FillDirection = Enum.FillDirection.Vertical;
                        SortOrder = Enum.SortOrder.LayoutOrder;
                    }, {});

                    OreName = Roact.createElement("TextLabel", {
                        Size = UDim2.fromScale(1, 0.6);
                        BackgroundTransparency = 1;
                        BorderSizePixel = 0;
                        LayoutOrder = 1;

                        Text = OreName;
                        TextScaled = true;
                        TextXAlignment = Enum.TextXAlignment.Left;
                        TextYAlignment = Enum.TextYAlignment.Bottom;
                        TextColor3 = Theme.TextColor;
                        FontFace = Theme.Font;
                    }, {});

                    Amount = Roact.createElement("TextLabel", {
                        Size = UDim2.fromScale(1, 0.4);
                        BackgroundTransparency = 1;
                        BorderSizePixel = 0;
                        LayoutOrder = 2;

                        Text = Amount;
                        TextScaled = true;
                        TextXAlignment = Enum.TextXAlignment.Left;
                        TextYAlignment = Enum.TextYAlignment.Top;
                        TextColor3 = Theme.TextColor;
                        FontFace = Theme.Font;
                    }, {});
                });
            });
        });
    });
end

return Ore