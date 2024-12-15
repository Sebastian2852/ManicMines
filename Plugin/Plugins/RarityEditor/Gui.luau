local ChangeHistoryService = game:GetService("ChangeHistoryService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(script.Parent.Parent.Parent.External.Roact)
local GuiUtil = require(script.Parent.Parent.Parent.Util.Gui)

local function GetDisplayWeight(Ore :BasePart, Ores :Folder) :number
    local DisplayWeight
    local Rarities = {}

    for _, LoopOre :BasePart in pairs(Ores:GetChildren()) do
        table.insert(Rarities, {LoopOre.Name, LoopOre:GetAttribute("Rarity")})
    end

    table.sort(Rarities, function(a, b)
        return a[2] < b[2]
    end)

    for i, v in pairs(Rarities) do
        if i == 1 then
            if v[1] == Ore.Name then
                DisplayWeight = v[2]
                break
            end
            continue
        end

        if v[1] == Ore.Name then
            DisplayWeight = Rarities[i][2] - Rarities[i - 1 >= 0 and i - 1 or i][2]
            break
        end
    end

    return DisplayWeight
end



-- [[ ORE FRAME GUI ]] --

local OreFrameComponent = Roact.Component:extend("OreFrame")

function OreFrameComponent:init()
    local Ore :BasePart = self.props.Ores[self.props.Name]

    local DisplayWeight = GetDisplayWeight(Ore, self.props.Ores)


    Ore:GetAttributeChangedSignal("Rarity"):Connect(function()
        local NewDisplayWeight = GetDisplayWeight(Ore, self.props.Ores)
        self:setState({
            Weight = Ore:GetAttribute("Rarity");
            DisplayWeight = NewDisplayWeight;
        })
    end)

    self:setState({
        DisplayName = self.props.DisplayName;
        Name = self.props.Name;
        Weight = self.props.Weight;
        DisplayWeight = DisplayWeight;
        Emblem = Ore:GetAttribute("EmblemImageID");
        OreImage = Ore:FindFirstChildWhichIsA("Decal");
    })
end

function OreFrameComponent:render()
    local OreDisplayName = self.state.DisplayName or "NO DISPLAY NAME"
    local OreName = self.state.Name or "NO NAME"
    local Weight = self.state.Weight or "NO WEIGHT"
    local DisplayWeight = self.state.DisplayWeight or "NO DISPLAY WEIGHT"
    local Emblem = self.state.Emblem or "http://www.roblox.com/asset/?id=925810526"
    local OreImage = self.state.OreImage and self.state.OreImage.Texture or "http://www.roblox.com/asset/?id=925810526"

    return Roact.createElement("Frame", {
        Size = UDim2.fromScale(1, 0.1);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
    }, {
        Emblem = Roact.createElement("Frame", {
            Size = UDim2.fromScale(0.8, 0.8);
            Position = UDim2.fromScale(0.05, 0.2);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
        }, {
            AspectRatio = Roact.createElement("UIAspectRatioConstraint", {}, {});
            Border = GuiUtil.CreateBorderImage();

            Image = Roact.createElement("ImageLabel", {
                Size = UDim2.fromScale(0.7, 0.7);
                Position = UDim2.fromScale(0.5, 0.05);
                AnchorPoint = Vector2.new(0.5, 0);
                SizeConstraint = Enum.SizeConstraint.RelativeYY;
                BackgroundTransparency = 1;
                BorderSizePixel = 0;

                Image = Emblem
            }, {});

            Text = Roact.createElement("TextLabel", {
                Size = UDim2.fromScale(1, 0.2);
                Position = UDim2.fromScale(1, 1);
                AnchorPoint = Vector2.new(1, 1);
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                ZIndex = 2;

                Text = "Emblem";
                TextScaled = true;
                TextColor3 = Color3.fromRGB(255, 255, 255);
                FontFace = Font.fromName("Montserrat", Enum.FontWeight.Thin);
                TextXAlignment = Enum.TextXAlignment.Center;
                TextYAlignment = Enum.TextYAlignment.Bottom;
            }, {})
        });

        OreImage = Roact.createElement("Frame", {
            Size = UDim2.fromScale(0.8, 0.8);
            Position = UDim2.fromScale(0.15, 0.2);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
        }, {
            AspectRatio = Roact.createElement("UIAspectRatioConstraint", {}, {});
            Border = GuiUtil.CreateBorderImage();

            Image = Roact.createElement("ImageLabel", {
                Size = UDim2.fromScale(0.7, 0.7);
                Position = UDim2.fromScale(0.5, 0.05);
                AnchorPoint = Vector2.new(0.5, 0);
                SizeConstraint = Enum.SizeConstraint.RelativeYY;
                BackgroundTransparency = 1;
                BorderSizePixel = 0;

                Image = OreImage
            }, {});

            Text = Roact.createElement("TextLabel", {
                Size = UDim2.fromScale(1, 0.2);
                Position = UDim2.fromScale(1, 1);
                AnchorPoint = Vector2.new(1, 1);
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                ZIndex = 2;

                Text = "Ore";
                TextScaled = true;
                TextColor3 = Color3.fromRGB(255, 255, 255);
                FontFace = Font.fromName("Montserrat", Enum.FontWeight.Thin);
                TextXAlignment = Enum.TextXAlignment.Center;
                TextYAlignment = Enum.TextYAlignment.Bottom;
            }, {})
        });

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
                    PlaceholderText = DisplayWeight;
                    Text = DisplayWeight;
                    TextScaled = true;
                    PlaceholderColor3 = Color3.fromRGB(155, 155, 155);
                    TextColor3 = Color3.fromRGB(255, 255, 255);
                    FontFace = Font.fromName("Montserrat", Enum.FontWeight.Medium);

                    [Roact.Event.FocusLost] = function(Object :TextBox)
                        local Text = Object.Text
                        local AsNumber = tonumber(Text)
                        if not AsNumber then
                            warn("Couldn't convert input to number")
                            return
                        end

                        for _, Ore in pairs(self.props.Ores:GetChildren()) do
                            if Ore.Name == self.state.Name then
                                Ore:SetAttribute("Rarity", AsNumber)
                                continue
                            end

                            Ore:SetAttribute("Rarity", Ore:GetAttribute("Rarity") + AsNumber)
                        end

                        ChangeHistoryService:SetWaypoint("Updated ore rarities")

                        self:setState({
                            Weight = AsNumber;
                            DisplayWeight = AsNumber;
                        })
                    end
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

function EditorGuiComponent:init()
    self:setState({
        Ores = ReplicatedStorage.Assets.Ores;
    })
end

function EditorGuiComponent:render()
    local FrameComponents = {}
    FrameComponents["Layout"] = Roact.createElement("UIListLayout", {}, {})
    if self.state.Ores ~= nil then
        for _, Ore in pairs(self.state.Ores:GetChildren()) do
            FrameComponents[Ore.Name] = Roact.createElement(OreFrameComponent, {Ores = self.state.Ores, Name = Ore.Name, DisplayName = Ore:GetAttribute("DisplayName"), Weight = Ore:GetAttribute("Rarity")})
        end
    end

    return Roact.createElement("Frame", {
        Size = UDim2.fromScale(1, 1);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
    }, {
        Ores = Roact.createElement("ScrollingFrame", {
            Size = UDim2.fromScale(1, 1);
            ScrollBarThickness = 3;
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            AutomaticCanvasSize = Enum.AutomaticSize.Y;
            VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Left;
            VerticalScrollBarInset = Enum.ScrollBarInset.Always;
        }, FrameComponents );
    })
end

return EditorGuiComponent