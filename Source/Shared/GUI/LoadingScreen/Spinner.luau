local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)
local Flipper = require(ReplicatedStorage.Packages.Flipper)

local Spinner = Roact.Component:extend("Spinner")

local Theme = require(script.Parent.Parent.Theme)

local LOADING_WHEEL_TRANSPARENCY_SEQUENCE = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1, 0);
    NumberSequenceKeypoint.new(0.5, 1, 0);
    NumberSequenceKeypoint.new(0.501, 0, 0);
    NumberSequenceKeypoint.new(1, 0, 0);
})

local function Lerp(Start :number, End :number, Time :number)
    return Start * (1 - Time) + End * Time
end

function Spinner:init()
    self.Motor = Flipper.SingleMotor.new(0)
    local Binding, SetBinding = Roact.createBinding(self.Motor:getValue())
    self.Binding = Binding
    self.Motor:onStep(SetBinding)

    self.CurrentAnimGoal = 1
end

function Spinner:Animate()
    if self.CurrentAnimGoal == 1 then
        self.CurrentAnimGoal = 0
    else
        self.CurrentAnimGoal = 1
    end

    self.Motor:setGoal(Flipper.Linear.new(self.CurrentAnimGoal, {
        velocity = 1;
    }))
end

function Spinner:didMount()
    self:Animate()

    self.Motor:onComplete(function()
        self:Animate()
    end)
end

function Spinner:render()
    local Transparency = self.props.Transparency or 0
    local Rotation = self.Binding:map(function(Value)
        return self.CurrentAnimGoal == 0 and Lerp(180, -180, Value) or Lerp(-180, 180, Value)
    end)

    return Roact.createElement("Frame", {
        Size = UDim2.fromScale(1, 1);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
    }, {
        SpinnerImage = Roact.createElement("ImageLabel", {
            Size = UDim2.fromScale(1, 1);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;

            Image = Theme.Images.LoadingWheel;
            ImageTransparency = Transparency;
            ScaleType = Enum.ScaleType.Fit;
        }, {
            TransparencyGradient = Roact.createElement("UIGradient", {
                Transparency = LOADING_WHEEL_TRANSPARENCY_SEQUENCE;
                Rotation = Rotation;
            }, {});
        });
    });
end

return Spinner