local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)
local Flipper = require(ReplicatedStorage.Packages.Flipper)

local SlotSelector = Roact.Component:extend("SlotSelector")

local Theme = require(script.Parent.Parent.Theme)
local CloseButton = require(ReplicatedStorage.Game.GUI.Common.CloseButton)

function SlotSelector:init()
    self.Motor = Flipper.SingleMotor.new(0)
    local Binding, SetBinding = Roact.createBinding(self.Motor:getValue())
    self.Binding = Binding
    self.Motor:onStep(SetBinding)
end

function SlotSelector:didMount()
    self.Motor:setGoal(Flipper.Spring.new(1, {
        frequency = 5,
        dampingRatio = 1
    }))
end

function SlotSelector:render()
    return Roact.createElement("Frame", {
        Size = UDim2.fromScale(1, 1);
        Position = self.Binding:map(function(Value)
            return UDim2.fromScale(0, -1.5):lerp(UDim2.fromScale(0, 0), Value)
        end);
        BackgroundColor3 = Theme.BackgroundColor;
        BackgroundTransparency = 0.5;
        BorderSizePixel = 0;
    }, {
        CloseButton = Roact.createElement(CloseButton, {
            OnClick = function()
                self.Motor:setGoal(Flipper.Spring.new(0, {
                    frequency = 5,
                    dampingRatio = 1
                }))

                task.wait(0.2)

                self.props.OnClick()
            end
        });
    })
end

return SlotSelector