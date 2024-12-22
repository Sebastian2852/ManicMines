local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)
local Flipper = require(ReplicatedStorage.Packages.Flipper)

local NameTextBox = Roact.Component:extend("NameTextBox")

local Theme = require(script.Parent.Parent.Parent.Parent.Theme)
local MainMenuController

function NameTextBox:init()
    MainMenuController = Knit.GetController("MainMenuController")

    self.Motor = Flipper.SingleMotor.new(0)
    local Binding, SetBinding = Roact.createBinding(self.Motor:getValue())
    self.Binding = Binding
    self.Motor:onStep(SetBinding)
end

function NameTextBox:render()
    local Size = self.Binding:map(function(Value)
        return UDim2.fromScale(1, 1):Lerp(UDim2.fromScale(1, 1.1), Value)
    end)

    return Roact.createElement("Frame", {
        Size = UDim2.fromScale(1, 1);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
    }, {
        Input = Roact.createElement("TextBox", {
            Size = Size;
            Position = UDim2.fromScale(0.5, 0.5);
            AnchorPoint = Vector2.new(0.5, 0.5);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;

            Text = self.props.Text or "";
            PlaceholderText = "Tycoon Name";
            TextScaled = true;
            ClearTextOnFocus = false;
            TextColor3 = Theme.TextColor;
            PlaceholderColor3 = Theme.TextDisabledColor;
            FontFace = Theme.Font;

            [Roact.Event.Focused] = function()
                self.Motor:setGoal(Flipper.Spring.new(1, {
                    frequency = 10,
                    dampingRatio = 1
                }))
            end;

            [Roact.Event.FocusLost] = function(Object :TextBox)
                self.Motor:setGoal(Flipper.Spring.new(0, {
                    frequency = 10,
                    dampingRatio = 1
                }))

                Object.Text = MainMenuController:FilterName(Object.Text)

                if self.props.TextChanged then
                    self.props.TextChanged(Object.Text)
                end
            end;
        }, {});
    })
end

return NameTextBox