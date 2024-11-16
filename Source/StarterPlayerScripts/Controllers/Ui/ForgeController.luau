local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)
local Core = require(ReplicatedStorage.Game.Modules.Core)

local CreateForgeButton = require(ReplicatedStorage.Game.GUI.Components.Forge.PickaxeButton)

local ForgeController = Knit.CreateController { Name = "ForgeController" }

-- [[ GUI ]] --

local ForgeComponent = Roact.Component:extend("Forge")

function ForgeComponent:init()
    self:setState({
        PickaxeSelected = false;
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

                Test = CreateForgeButton(Core.Assets.Pickaxe.Pickaxes["0"], true, function()
                    self:setState({
                        PickaxeSelected = true;
                    })
                end);
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

                Test = CreateForgeButton(Core.Assets.Pickaxe.Pickaxes["0"], true, function()
                    self:setState({
                        PickaxeSelected = true;
                    })
                end);
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