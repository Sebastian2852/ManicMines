local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)

local LevelDisplay = Roact.Component:extend("LevelDisplay")

local Theme = require(script.Parent.Parent.Parent.Theme)

function LevelDisplay:render()
    return Roact.createElement("Frame", {
        Size = UDim2.fromScale(1, 1);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
    }, {
        Layout = Roact.createElement("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
        }, {});

        TextArea = Roact.createElement("Frame", {
            Size = UDim2.fromScale(1, 0.8);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
        }, {
            Layout = Roact.createElement("UIListLayout", {
                FillDirection = Enum.FillDirection.Vertical;
                SortOrder = Enum.SortOrder.LayoutOrder;
            }, {});

            TopText = Roact.createElement("TextLabel", {
                Size = UDim2.fromScale(1, 0.5);
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                LayoutOrder = 1;

                Text = "TopText";
                TextScaled = true;
                TextXAlignment = Enum.TextXAlignment.Right;
                TextColor3 = Theme.TextColor;
                FontFace = Theme.Font;
            }, {});

            BottomText = Roact.createElement("Frame", {
                Size = UDim2.fromScale(1, 0.5);
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                LayoutOrder = 2;
            }, {
                Layout = Roact.createElement("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal;
                    SortOrder = Enum.SortOrder.LayoutOrder;
                }, {});

                CurrentXp = Roact.createElement("TextLabel", {
                    Size = UDim2.fromScale(0.45, 1);
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;
                    LayoutOrder = 1;

                    Text = "0";
                    TextScaled = true;
                    TextXAlignment = Enum.TextXAlignment.Left;
                    TextColor3 = Theme.TextColor;
                    FontFace = Theme.Font;
                }, {});

                Slash = Roact.createElement("TextLabel", {
                    Size = UDim2.fromScale(0.1, 1);
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;
                    LayoutOrder = 2;

                    Text = "/";
                    TextScaled = true;
                    TextXAlignment = Enum.TextXAlignment.Center;
                    TextColor3 = Theme.TextColor;
                    FontFace = Theme.Font;
                }, {});

                NeededXp = Roact.createElement("TextLabel", {
                    Size = UDim2.fromScale(0.45, 1);
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;
                    LayoutOrder = 3;

                    Text = "100";
                    TextScaled = true;
                    TextXAlignment = Enum.TextXAlignment.Right;
                    TextColor3 = Theme.TextColor;
                    FontFace = Theme.Font;
                }, {});
            });
        });

        BarArea = Roact.createElement("Frame", {
            Size = UDim2.fromScale(1, 0.2);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            LayoutOrder = 2;
        }, {
            BarBackground = Roact.createElement("Frame", {
                Size = UDim2.fromScale(1, 0.6);
                Position = UDim2.fromScale(0.5, 0.5);
                AnchorPoint = Vector2.new(0.5, 0.5);
                BackgroundColor3 = Theme.BackgroundColor;
                BorderSizePixel = 0;
            }, {
                Outline = Roact.createElement("UIStroke", {
                    Thickness = 3;
                    Color = Color3.new(0, 0, 0);
                }, {});

                Bar = Roact.createElement("Frame", {
                    Size = UDim2.fromScale(0.5, 1);
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                    BorderSizePixel = 0;
                }, {});
            });
        });
    });
end

return LevelDisplay