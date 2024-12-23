local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)
local Flipper = require(ReplicatedStorage.Packages.Flipper)

local XpDiff = Roact.Component:extend("XpDiff")

local Theme = require(script.Parent.Parent.Parent.Parent.Theme)

function XpDiff:init()
    self.Motor = Flipper.SingleMotor.new(0)
    local Binding, SetBinding = Roact.createBinding(self.Motor:getValue())
    self.Binding = Binding
    self.Motor:onStep(SetBinding)

    self.Done = false
end

function XpDiff:didMount()
    self.Motor:setGoal(Flipper.Spring.new(1, {
        frequency = 4;
        dampingRatio = 1;
    }))

    self.Motor:onComplete(function()
        self.Motor:setGoal(Flipper.Spring.new(0, {
            frequency = 6;
            dampingRatio = 0.5;
        }))

        self.Motor:onComplete(function()
            self.Done = true
        end)
    end)
end

function XpDiff:render()
    local Amount = self.props.Amount
    local TextColor = self.props.Color or Theme.TextColor

    local Position = self.Binding:map(function(Value)
        return UDim2.fromScale(0.5, 0.5):Lerp(UDim2.fromScale(0.5, -1.5), Value)
    end)

    if self.Done then
        return Roact.createElement("Frame", {
            Visible = false;
        }, {});
    end

    return Roact.createElement("Frame", {
        Size = UDim2.fromScale(1, 1);
        Position = Position;
        AnchorPoint = Vector2.new(0.5, 0.5);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
    }, {
        Text = Roact.createElement("TextLabel", {
            Size = UDim2.fromScale(1, 1);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;

            Text = "+ "..Amount;
            TextStrokeTransparency = 0;
            TextScaled = true;
            TextXAlignment = Enum.TextXAlignment.Left;
            TextYAlignment = Enum.TextYAlignment.Bottom;
            TextColor3 = TextColor;
            FontFace = Theme.Font;
        }, {});
    });
end

return XpDiff