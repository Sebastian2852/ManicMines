local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)
local Core = require(ReplicatedStorage.Game.Modules.Core)

local ForgeController = Knit.CreateController { Name = "ForgeController" }

-- [[ GUI ]] --

local ForgeComponent = Roact.Component:extend("Forge")

function ForgeComponent:init()
    self:setState({
        PickaxeSelected = false;
    })
end

function ForgeComponent:CreatePickaxeButton(PickaxeConfig :Configuration, Owned :boolean)
    local Pickaxe :Tool = PickaxeConfig:FindFirstChildWhichIsA("Tool")

    local Icon :string = PickaxeConfig:GetAttribute("Icon")
    local Gradient :ColorSequence = PickaxeConfig:GetAttribute("ButtonGradient")
    local Name :string = PickaxeConfig:GetAttribute("Name")

    return Roact.createElement("Frame", {
        Size = UDim2.fromScale(0.15, 0.35);
        BackgroundColor3 = Core.UI.Color.White;
        BorderSizePixel = 0;
        LayoutOrder = tonumber(PickaxeConfig.Name)
    }, {
        Name = Roact.createElement("TextLabel", {
            Size = UDim2.fromScale(1, 0.15);
            BorderSizePixel = 0;
            BackgroundTransparency = 1;

            Text = "<u>"..Name.."</u>";
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

            Image = Icon;
            ScaleType = Enum.ScaleType.Fit;
        }, {});

        Gradient = Roact.createElement("UIGradient", {
            Color = Gradient;
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

            [Roact.Event.MouseButton1Click] = function()
                print("Open info for pickaxe")
                self:setState({
                    PickaxeSelected = true;
                })
            end;
        }, {})
    })
end

function ForgeComponent:RenderFullSelector()
    return Roact.createElement("ScreenGui", {
        ResetOnSpawn = false;
    }, {
        Main = Roact.createElement("Frame", {
            Size = UDim2.fromScale(0.5, 0.5);
            Position = Core.UI.Position.Center;
            AnchorPoint = Core.UI.AnchorPoint.Center;

            BackgroundColor3 = Core.UI.Theme.BackgroundColorPrimary;
            BorderSizePixel = 0;
        }, {
            Title = Roact.createElement("TextLabel", {
                Size = UDim2.fromScale(1, 0.1);
                BackgroundTransparency = 1;
                BorderSizePixel = 0;

                Text = "Forge";
                TextScaled = true;
                TextXAlignment = Enum.TextXAlignment.Left;
                TextColor3 = Core.UI.Theme.TextColor3;
                FontFace = Core.UI.Theme.TextFont;
            }, {});

            Pickaxes = Roact.createElement("ScrollingFrame", {
                Size = UDim2.fromScale(1, 0.9);
                Position = UDim2.fromScale(0, 0.1);
                BackgroundTransparency = 1;
                BorderSizePixel = 0;

                AutomaticCanvasSize = Enum.AutomaticSize.Y;
                ScrollBarImageColor3 = Color3.new(1, 1, 1);
                ScrollingDirection = Enum.ScrollingDirection.Y;
                ScrollBarThickness = 5;
                VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Left;
                VerticalScrollBarInset = Enum.ScrollBarInset.Always;
            }, {
                Layout = Roact.createElement("UIListLayout", {
                    Padding = UDim.new(0.05);
                    SortOrder = Enum.SortOrder.LayoutOrder;
                    FillDirection = Enum.FillDirection.Horizontal;
                    Wraps = true;

                    HorizontalFlex = Enum.UIFlexAlignment.SpaceEvenly;
                    VerticalFlex = Enum.UIFlexAlignment.SpaceEvenly;
                }, {});

                Test = self:CreatePickaxeButton(Core.Assets.Pickaxe.Pickaxes["0"], true);
                Test2 = self:CreatePickaxeButton(Core.Assets.Pickaxe.Pickaxes["0"], true);
                Test3 = self:CreatePickaxeButton(Core.Assets.Pickaxe.Pickaxes["0"], true);
                Test4 = self:CreatePickaxeButton(Core.Assets.Pickaxe.Pickaxes["0"], true);
            });
        })
    })
end

function ForgeComponent:RenderWithInfo()
    return Roact.createElement("ScreenGui", {
        ResetOnSpawn = false;
    }, {
        Main = Roact.createElement("Frame", {
            Size = UDim2.fromScale(0.5, 0.5);
            Position = Core.UI.Position.Center;
            AnchorPoint = Core.UI.AnchorPoint.Center;

            BackgroundColor3 = Core.UI.Theme.BackgroundColorPrimary;
            BorderSizePixel = 0;
        }, {
            Title = Roact.createElement("TextLabel", {
                Size = UDim2.fromScale(1, 0.1);
                BackgroundTransparency = 1;
                BorderSizePixel = 0;

                Text = "Forge";
                TextScaled = true;
                TextXAlignment = Enum.TextXAlignment.Left;
                TextColor3 = Core.UI.Theme.TextColor3;
                FontFace = Core.UI.Theme.TextFont;
            }, {});

            Pickaxes = Roact.createElement("ScrollingFrame", {
                Size = UDim2.fromScale(0.6, 0.9);
                Position = UDim2.fromScale(0, 0.1);
                BackgroundTransparency = 1;
                BorderSizePixel = 0;

                AutomaticCanvasSize = Enum.AutomaticSize.Y;
                ScrollBarImageColor3 = Color3.new(1, 1, 1);
                ScrollingDirection = Enum.ScrollingDirection.Y;
                ScrollBarThickness = 5;
                VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Left;
                VerticalScrollBarInset = Enum.ScrollBarInset.Always;
            }, {
                Layout = Roact.createElement("UIListLayout", {
                    Padding = UDim.new(0.05);
                    SortOrder = Enum.SortOrder.LayoutOrder;
                    FillDirection = Enum.FillDirection.Horizontal;
                    Wraps = true;

                    HorizontalFlex = Enum.UIFlexAlignment.SpaceEvenly;
                    VerticalFlex = Enum.UIFlexAlignment.SpaceEvenly;
                }, {});

                Test = self:CreatePickaxeButton(Core.Assets.Pickaxe.Pickaxes["0"], true);
                Test2 = self:CreatePickaxeButton(Core.Assets.Pickaxe.Pickaxes["0"], true);
                Test3 = self:CreatePickaxeButton(Core.Assets.Pickaxe.Pickaxes["0"], true);
                Test4 = self:CreatePickaxeButton(Core.Assets.Pickaxe.Pickaxes["0"], true);
            });

            Info = Roact.createElement("Frame", {
                Size = UDim2.fromScale(0.4, 1);
                Position = UDim2.fromScale(0.6, 0);
                BackgroundColor3 = Core.UI.Theme.BackgroundColorDark;
                BorderSizePixel = 0;
            }, {})
        })
    })
end

function ForgeComponent:render()
    local PickaxeSelected = self.state.PickaxeSelected
    return PickaxeSelected and self:RenderWithInfo() or self:RenderFullSelector()
end



-- [[ KNIT ]] --

function ForgeController:KnitStart()
    UserInputService.InputBegan:Connect(function(Input, Processed)
        if Processed then return end
        if Input.KeyCode ~= Enum.KeyCode.Z then return end

        local App = Roact.createElement(ForgeComponent, {
            Pickaxes = Core.Assets.Pickaxe.Pickaxes:GetChildren()
        })
        Roact.mount(App, Knit.Player.PlayerGui, "Forge")
    end)
end


return ForgeController