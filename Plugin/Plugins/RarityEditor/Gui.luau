local Roact = require(script.Parent.Parent.Parent.External.Roact)
local GuiUtil = require(script.Parent.Parent.Parent.Util.Gui)

-- [[ ORE FRAME GUI ]] --

local OreFrameComponent = Roact.Component:extend("OreFrame")

function OreFrameComponent:render()
    local OreDisplayName = self.props.DisplayName
    local OreName = self.props.Name
    local Rarity = self.props.Rarity
    local Weight = self.props.Weight

    return Roact.createElement("Frame", {
        Size = UDim2.fromScale(1, 0.1);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
    }, {
        DisplayName = Roact.createElement("TextLabel", {
            Size = UDim2.fromScale(0.5, 0.5);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;

            Text = OreDisplayName;
            TextScaled = true;
            TextColor3 = Color3.fromRGB(255, 255, 255);
            FontFace = Font.fromName("Montserrat", Enum.FontWeight.Bold);
            TextXAlignment = Enum.TextXAlignment.Right;
            TextYAlignment = Enum.TextYAlignment.Bottom;
        }, {});

        OreName = Roact.createElement("TextLabel", {
            Size = UDim2.fromScale(0.5, 0.3);
            Position = UDim2.fromScale(0, 0.5);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;

            Text = OreName;
            TextScaled = true;
            TextColor3 = Color3.fromRGB(155, 155, 155);
            FontFace = Font.fromName("Montserrat", Enum.FontWeight.Thin);
            TextXAlignment = Enum.TextXAlignment.Right;
            TextYAlignment = Enum.TextYAlignment.Top;
        }, {});

        RightSide = Roact.createElement("Frame", {
            Size = UDim2.fromScale(0.5, 1);
            Position = UDim2.fromScale(1, 0);
            AnchorPoint = Vector2.new(1, 0);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
        }, {
            Text = Roact.createElement("TextLabel", {
                Size = UDim2.new(0, 40, 0.3, 0);
                Position = UDim2.fromScale(0, 1);
                AnchorPoint = Vector2.new(0, 1);
                BackgroundTransparency = 1;

                Text = "     1 /";
                TextScaled = true;
                TextColor3 = Color3.fromRGB(155, 155, 155);
                FontFace = Font.fromName("Montserrat", Enum.FontWeight.Thin);
                TextXAlignment = Enum.TextXAlignment.Left;
                TextYAlignment = Enum.TextYAlignment.Bottom;
            }, {});

            Input = Roact.createElement("ImageLabel", {
                Size = UDim2.fromScale(0.4, 0.5);
                Position = UDim2.new(0, 45, 0.9, 0);
                AnchorPoint = Vector2.new(0, 1);
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
            }, {
                Border = GuiUtil.CreateBorderImage();
                Input = Roact.createElement("TextBox", {
                    Size = UDim2.fromScale(0.9, 0.9);
                    Position = UDim2.fromScale(0.5, 0.5);
                    AnchorPoint = Vector2.new(0.5, 0.5);
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;

                    ClearTextOnFocus = false;
                    PlaceholderText = "...";
                    Text = Rarity;
                    TextScaled = true;
                    PlaceholderColor3 = Color3.fromRGB(155, 155, 155);
                    TextColor3 = Color3.fromRGB(255, 255, 255);
                    FontFace = Font.fromName("Montserrat", Enum.FontWeight.Medium);
                }, {});

                Weight = Roact.createElement("TextLabel", {
                    Size = UDim2.fromScale(1, 0.4);
                    Position = UDim2.fromScale(0, 1);
                    BackgroundTransparency = 1;

                    Text = "Weight: "..Weight;
                    TextScaled = true;
                    TextColor3 = Color3.fromRGB(155, 155, 155);
                    FontFace = Font.fromName("Montserrat", Enum.FontWeight.Thin);
                    TextXAlignment = Enum.TextXAlignment.Center;
                    TextYAlignment = Enum.TextYAlignment.Top;
                }, {});
            })
        })
    })
end



-- [[ EDITOR GUI ]] --

local EditorGuiComponent = Roact.Component:extend("RarityEditor")

function EditorGuiComponent:render()
    return Roact.createElement("Frame", {
        Size = UDim2.fromScale(1, 1);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
    }, {
        Ores = Roact.createElement("ScrollingFrame", {
            Size = UDim2.fromScale(1, 0.9);
            ScrollBarThickness = 3;
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            AutomaticCanvasSize = Enum.AutomaticSize.Y;
            VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Left;
            VerticalScrollBarInset = Enum.ScrollBarInset.Always;
        }, {
            Roact.createElement("UIListLayout", {}, {});

            Roact.createElement(OreFrameComponent, {Name = "Name", DisplayName = "DisplayName", Rarity = 100, Weight = 30});
            Roact.createElement(OreFrameComponent, {Name = "Name", DisplayName = "DisplayName", Rarity = 100, Weight = 30});
            Roact.createElement(OreFrameComponent, {Name = "Name", DisplayName = "DisplayName", Rarity = 100, Weight = 30});
            Roact.createElement(OreFrameComponent, {Name = "Name", DisplayName = "DisplayName", Rarity = 100, Weight = 30});
        });

        Bottom = Roact.createElement("Frame", {
            Size = UDim2.fromScale(1, 0.1);
            Position = UDim2.fromScale(0, 1);
            AnchorPoint = Vector2.new(0, 1);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
        }, {
            Layout = Roact.createElement("UIListLayout", {
                Padding = UDim.new(0, 10);
                SortOrder = Enum.SortOrder.LayoutOrder;
                FillDirection = Enum.FillDirection.Horizontal;
                HorizontalAlignment = Enum.HorizontalAlignment.Center;
                VerticalAlignment = Enum.VerticalAlignment.Center;
            }, {});

            CommitButton = Roact.createElement("TextButton", {
                Size = UDim2.fromScale(0.3, 0.5);
                BackgroundColor3 = Color3.fromRGB(225, 56, 53);

                Text = "Commit";
                TextScaled = true;
                TextColor3 = Color3.fromRGB(255, 255, 255);
                FontFace = Font.fromName("Montserrat", Enum.FontWeight.Medium);
            }, {
                Corners = GuiUtil.CreateCorners(0.2);
            });

            RevertButton = Roact.createElement("TextButton", {
                Size = UDim2.fromScale(0.3, 0.5);
                BackgroundColor3 = Color3.fromRGB(46, 46, 46);

                Text = "Revert";
                TextScaled = true;
                TextColor3 = Color3.fromRGB(219, 219, 219);
                FontFace = Font.fromName("Montserrat", Enum.FontWeight.Medium);
            }, {
                Border = GuiUtil.CreateBorderImage();
            })
        })
    })
end

return EditorGuiComponent