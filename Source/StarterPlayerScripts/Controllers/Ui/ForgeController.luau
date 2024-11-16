local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)
local Core = require(ReplicatedStorage.Game.Modules.Core)

local CreateForgeButton = require(ReplicatedStorage.Game.GUI.Components.Forge.PickaxeButton)
local CreatOreLikeFrame = require(ReplicatedStorage.Game.GUI.Components.General.OrelikeFrame)

local ForgeController = Knit.CreateController { Name = "ForgeController" }

-- [[ GUI ]] --

local ForgeComponent = Roact.Component:extend("Forge")

function ForgeComponent:init()
    self:setState({
        PickaxeSelected = false;
        SelectedConfig = nil;
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

                Test = CreateForgeButton(Core.Assets.Pickaxe.Pickaxes["0"], true, false, function()
                    self:setState({
                        PickaxeSelected = true;
                        SelectedConfig = Core.Assets.Pickaxe.Pickaxes["0"];
                    })
                end);

                Test2 = CreateForgeButton(Core.Assets.Pickaxe.Pickaxes["0"], false, false, function()
                    self:setState({
                        PickaxeSelected = true;
                        SelectedConfig = Core.Assets.Pickaxe.Pickaxes["0"];
                    })
                end);

                Test3 = CreateForgeButton(Core.Assets.Pickaxe.Pickaxes["0"], false, true, function()
                    self:setState({
                        PickaxeSelected = true;
                        SelectedConfig = Core.Assets.Pickaxe.Pickaxes["0"];
                    })
                end);
            });
        })
    })
end

function ForgeComponent:RenderWithInfo()
    local SelectedConfig :Configuration = self.state.SelectedConfig
    local Pickaxe :Tool = SelectedConfig:FindFirstChildWhichIsA("Tool")

    local Name :string = SelectedConfig:GetAttribute("Name")
    local Description :string = SelectedConfig:GetAttribute("Description")
    local Delay = Pickaxe:GetAttribute("Delay")
    local Power = Pickaxe:GetAttribute("Damage")
    local Range = Pickaxe:GetAttribute("Range")

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

                Test = CreateForgeButton(Core.Assets.Pickaxe.Pickaxes["0"], true, false, function()
                    self:setState({
                        PickaxeSelected = true;
                        SelectedConfig = Core.Assets.Pickaxe.Pickaxes["0"];
                    })
                end);

                Test2 = CreateForgeButton(Core.Assets.Pickaxe.Pickaxes["0"], false, false, function()
                    self:setState({
                        PickaxeSelected = true;
                        SelectedConfig = Core.Assets.Pickaxe.Pickaxes["0"];
                    })
                end);

                Test3 = CreateForgeButton(Core.Assets.Pickaxe.Pickaxes["0"], false, true, function()
                    self:setState({
                        PickaxeSelected = true;
                        SelectedConfig = Core.Assets.Pickaxe.Pickaxes["0"];
                    })
                end);
            });

            Info = Roact.createElement("Frame", {
                Size = UDim2.fromScale(0.4, 1);
                Position = UDim2.fromScale(0.6, 0);
                BackgroundColor3 = Core.UI.Theme.BackgroundColorDark;
                BorderSizePixel = 0;
            }, {
                Deselect = Roact.createElement("TextButton", {
                    Size = UDim2.fromScale(1, 0.05);
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;
                    LayoutOrder = 1;

                    Text = "<u>Back</u>";
                    RichText = true;
                    TextScaled = true;
                    TextXAlignment = Enum.TextXAlignment.Left;
                    TextColor3 = Core.UI.Theme.TextColor3;
                    FontFace = Core.UI.Theme.TextFont;

                    [Roact.Event.MouseButton1Click] = function()
                        self:setState({
                            PickaxeSelected = false;
                            SelectedConfig = nil;
                        })
                    end;
                }, {});

                Name = Roact.createElement("TextLabel", {
                    Size = UDim2.fromScale(1, 0.1);
                    Position = UDim2.fromScale(0, 0.06);
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;
                    LayoutOrder = 2;

                    Text = "<u>"..Name.."</u>";
                    RichText = true;
                    TextScaled = true;
                    FontFace = Core.UI.Theme.TextFont;
                    TextColor3 = Core.UI.Theme.TextColor3;
                }, {});

                Description = Roact.createElement("TextLabel", {
                    Size = UDim2.fromScale(1, 0.1);
                    Position = UDim2.fromScale(0, 0.16);
                    LayoutOrder = 3;
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;

                    Text = Description;
                    RichText = true;
                    TextScaled = true;
                    TextYAlignment = Enum.TextYAlignment.Top;
                    FontFace = Core.UI.Theme.TextFont;
                    TextColor3 = Core.UI.Theme.TextColorDisabled;
                }, {
                    TextSize = Roact.createElement("UITextSizeConstraint", {
                        MaxTextSize = 25;
                        MinTextSize = 14;
                    }, {})
                });

                Stats = Roact.createElement("Frame", {
                    Size = UDim2.fromScale(1, 0.3);
                    Position = UDim2.fromScale(0, 0.25);
                    BackgroundTransparency = 1;
                    LayoutOrder = 4;
                }, {
                    Layout = Roact.createElement("UIListLayout", {
                        SortOrder = Enum.SortOrder.Name;
                    }, {});
                    Delay = CreatOreLikeFrame(Core.UI.Images.Missing, "Delay", tostring(Delay), ColorSequence.new(Color3.fromRGB(0, 0, 0)), UDim2.fromScale(1, 0.3), UDim2.fromScale(0, 0));
                    Power = CreatOreLikeFrame(Core.UI.Images.Missing, "Power", tostring(Power), ColorSequence.new(Color3.fromRGB(0, 0, 0)), UDim2.fromScale(1, 0.3), UDim2.fromScale(0, 0));
                    Range = CreatOreLikeFrame(Core.UI.Images.Missing, "Range", tostring(Range), ColorSequence.new(Color3.fromRGB(0, 0, 0)), UDim2.fromScale(1, 0.3), UDim2.fromScale(0, 0));
                });

                Requirments = Roact.createElement("ScrollingFrame", {
                    Size = UDim2.fromScale(1, 0.25);
                    Position = UDim2.fromScale(0, 0.55);
                    LayoutOrder = 5;
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;

                    CanvasSize = UDim2.fromScale(1, 1);
                    ScrollBarThickness = 5;
                    ScrollBarImageColor3 = Core.UI.Color.White;
                    ScrollingDirection = Enum.ScrollingDirection.Y;
                }, {
                    Roact.createElement("UIListLayout", {
                        SortOrder = Enum.SortOrder.LayoutOrder;
                    }, {});

                    CreatOreLikeFrame(Core.UI.Images.Missing, "Test", 15, ColorSequence.new(Color3.fromRGB(255, 0, 0)), UDim2.fromScale(1, 0.1), UDim2.fromScale(0, 0));
                    CreatOreLikeFrame(Core.UI.Images.Missing, "Test1", 15, ColorSequence.new(Color3.fromRGB(255, 0, 0)), UDim2.fromScale(1, 0.1), UDim2.fromScale(0, 0));
                    CreatOreLikeFrame(Core.UI.Images.Missing, "Test2", 15, ColorSequence.new(Color3.fromRGB(255, 0, 0)), UDim2.fromScale(1, 0.1), UDim2.fromScale(0, 0));
                    CreatOreLikeFrame(Core.UI.Images.Missing, "Test3", 15, ColorSequence.new(Color3.fromRGB(255, 0, 0)), UDim2.fromScale(1, 0.1), UDim2.fromScale(0, 0));
                    CreatOreLikeFrame(Core.UI.Images.Missing, "Test4", 15, ColorSequence.new(Color3.fromRGB(255, 0, 0)), UDim2.fromScale(1, 0.1), UDim2.fromScale(0, 0));
                    CreatOreLikeFrame(Core.UI.Images.Missing, "Test5", 15, ColorSequence.new(Color3.fromRGB(255, 0, 0)), UDim2.fromScale(1, 0.1), UDim2.fromScale(0, 0));
                });

                Action = Roact.createElement("TextButton", {
                    Size = UDim2.fromScale(0.8, 0.1);
                    Position = UDim2.fromScale(0.5, 0.95);
                    AnchorPoint = Core.UI.AnchorPoint.BottomCenter;
                    BackgroundColor3 = Core.UI.Theme.PrimaryButtonColor;
                    LayoutOrder = 5;

                    Text = "Equip";
                    TextScaled = true;
                    FontFace = Core.UI.Theme.TextFont;
                    TextColor3 = Core.UI.Theme.TextColor3;
                }, {
                    Corners = Roact.createElement("UICorner", {
                        CornerRadius = UDim.new(0.1, 0)
                    }, {});
                })
            })
        })
    })
end

function ForgeComponent:render()
    local PickaxeSelected = self.state.PickaxeSelected
    return PickaxeSelected and self:RenderWithInfo() or self:RenderFullSelector()
end



-- [[ KNIT ]] --

function ForgeController:KnitStart()
    local Mounted = false
    UserInputService.InputBegan:Connect(function(Input, Processed)
        if Processed then return end
        if Mounted then return end
        if Input.KeyCode ~= Enum.KeyCode.Z then return end
        Mounted = true

        local App = Roact.createElement(ForgeComponent, {
            Pickaxes = Core.Assets.Pickaxe.Pickaxes:GetChildren()
        })
        Roact.mount(App, Knit.Player.PlayerGui, "Forge")
    end)
end


return ForgeController