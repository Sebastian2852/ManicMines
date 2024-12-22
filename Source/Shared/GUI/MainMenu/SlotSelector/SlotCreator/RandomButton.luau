local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Packages.Roact)
local Flipper = require(ReplicatedStorage.Packages.Flipper)

local Theme = require(script.Parent.Parent.Parent.Parent.Theme)

local RandomButton = Roact.Component:extend("RandomButton")

function RandomButton:init()
    self.Motor = Flipper.SingleMotor.new(0)
    local Binding, SetBinding = Roact.createBinding(self.Motor:getValue())
    self.Binding = Binding
    self.Motor:onStep(SetBinding)
end

function RandomButton:render()
    local LayoutOrder = self.props.LayoutOrder

    local Size = self.Binding:map(function(Value)
        return UDim2.fromScale(0.8, 0.8):Lerp(UDim2.fromScale(1, 1), Value)
    end)

    return Roact.createElement("Frame", {
        Size = UDim2.fromScale(0.9, 0.9);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        LayoutOrder = LayoutOrder;
    }, {
        ClickArea = Roact.createElement("TextButton", {
            Size = UDim2.fromScale(1, 1);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;

            TextTransparency = 1;

            [Roact.Event.MouseEnter] = function()
                Theme.PlaySound(Theme.RawAudio.ButtonHover, true)

                self.Motor:setGoal(Flipper.Spring.new(1, {
                    frequency = 5,
                    dampingRatio = 1
                }))
            end;

            [Roact.Event.MouseLeave] = function()
                self.Motor:setGoal(Flipper.Spring.new(0, {
                    frequency = 4,
                    dampingRatio = 0.75
                }))
            end;

            [Roact.Event.MouseButton1Click] = function()
                Theme.PlaySound(Theme.RawAudio.ButtonClick)

                if self.props.OnClick then
                    self.props.OnClick()
                end
            end;
        }, {});

        Image = Roact.createElement("ImageLabel", {
            Size = Size;
            Position = UDim2.fromScale(0.5, 0.5);
            AnchorPoint = Vector2.new(0.5, 0.5);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;

            Image = Theme.Images.RandomizeButton;
            ScaleType = Enum.ScaleType.Fit;
        }, {});

        Corners = Roact.createElement("UICorner", {
            CornerRadius = UDim.new(0, 4);
        }, {});

        AspectRatio = Roact.createElement("UIAspectRatioConstraint", {
            AspectRatio = 1;
        }, {});
    })
end

return RandomButton