local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)
local Flipper = require(ReplicatedStorage.Packages.Flipper)

local Inventory = Roact.Component:extend("Inventory")

local Theme = require(script.Parent.Parent.Theme)
local Level = require(script.Level)
local InventoryComponent = require(script.Inventory)

function Inventory:init()
    self.Motor = Flipper.SingleMotor.new(0)
    local Binding, SetBinding = Roact.createBinding(self.Motor:getValue())
    self.Binding = Binding
    self.Motor:onStep(SetBinding)

    self:setState({
        Closed = false;
    })
end

function Inventory:Show()
    self:setState({
        Closed = false;
    })

    self.Motor:setGoal(Flipper.Spring.new(0, {
        frequency = 4;
        dampingRatio = 1;
    }))
end

function Inventory:Hide()
    self:setState({
        Closed = true;
    })

    self.Motor:setGoal(Flipper.Spring.new(1, {
        frequency = 4;
        dampingRatio = 1;
    }))
end

function Inventory:render()
    local Closed = self.state.Closed
    local CloseButtonText = Closed and "<" or ">"
    local ButtonColor = Closed and Theme.BackgroundColorGreen or Theme.BackgroundColorRed

    local LevelContainerPosition = self.Binding:map(function(Value)
        return UDim2.fromOffset(0, -10):Lerp(UDim2.fromScale(0, 0.75), Value)
    end)

    local InventoryContainerPosition = self.Binding:map(function(Value)
        return UDim2.fromScale(1, 1):Lerp(UDim2.fromScale(2, 1), Value)
    end)

    local CloseButtonPosition = self.Binding:map(function(Value)
        return UDim2.fromScale(-0.1, 0.9):Lerp(UDim2.fromScale(0.9, 0.75), Value)
    end)

    return Roact.createElement("Frame", {
        Size = UDim2.fromScale(1, 1);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
    }, {
        LevelContainer = Roact.createElement("Frame", {
            Size = UDim2.fromScale(1, 0.15);
            Position = LevelContainerPosition;
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            LayoutOrder = 1;
        }, {
            Level = Roact.createElement(Level, {}, {});
        });

        Container = Roact.createElement("Frame", {
            Size = UDim2.fromScale(1, 0.85);
            Position = InventoryContainerPosition;
            AnchorPoint = Vector2.new(1, 1);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            LayoutOrder = 2;
        }, {
            Background = Roact.createElement("Frame", {
                Size = UDim2.fromScale(1, 1);
                BackgroundTransparency = 0.5;
                BackgroundColor3 = Theme.BackgroundColor;
                ZIndex = 0;
            }, {});

            Inventory = Roact.createElement(InventoryComponent, {}, {})
        });

        CloseButton = Roact.createElement("TextButton", {
            Size = UDim2.fromScale(0.1, 0.1);
            Position = CloseButtonPosition;
            AnchorPoint = Vector2.new(0.5, 1);
            BackgroundColor3 = ButtonColor;
            BorderSizePixel = 0;

            Text = CloseButtonText;
            TextScaled = true;
            TextColor3 = Theme.TextColor;
            FontFace = Theme.Font;

            [Roact.Event.MouseButton1Click] = function()
                if Closed then
                    self:Show()
                else
                    self:Hide()
                end
            end
        }, {
            AspectRatio = Roact.createElement("UIAspectRatioConstraint", {
                AspectRatio = 1;
                AspectType = Enum.AspectType.ScaleWithParentSize;
                DominantAxis = Enum.DominantAxis.Height;
            }, {});

            Corners = Roact.createElement("UICorner", {
                CornerRadius = UDim.new(1, 0);
            }, {})
        });
    });
end

return Inventory