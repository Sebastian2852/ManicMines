local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Packages.Roact)
local Flipper = require(ReplicatedStorage.Packages.Flipper)

local Theme = require(script.Parent.Parent.Parent.Theme)

local SlotButton = Roact.Component:extend("SlotButton")

function SlotButton:init()
    local Text = self.props.Text :: string or "unknown"
    local BackgroundColor = self.props.Color or Color3.new(1, 0, 0)

    self:setState({
        Text = Text;
        Color = BackgroundColor;
    })

    self.Motor = Flipper.SingleMotor.new(0)
    local Binding, SetBinding = Roact.createBinding(self.Motor:getValue())
    self.Binding = Binding
    self.Motor:onStep(SetBinding)
end

function SlotButton:render()
    local LayoutOrder = self.props.LayoutOrder
    local Text = self.state.Text
    local Color = self.state.Color

    local Size = self.Binding:map(function(Value)
        return UDim2.fromScale(0.3, 0.7):lerp(UDim2.fromScale(0.35, 0.8), Value)
    end)

    return Roact.createElement("Frame", {
        Size = Size;
        BackgroundColor3 = Color;
        BorderSizePixel = 0;
        BackgroundTransparency = 0;
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

        Text = Roact.createElement("TextLabel", {
            Size = UDim2.fromScale(1, 1);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;

            Text = Text;
            TextScaled = true;
            TextColor3 = Theme.TextColor;
            FontFace = Theme.Font;
        }, {});

        Corners = Roact.createElement("UICorner", {
            CornerRadius = UDim.new(0, 4);
        }, {});
    })
end

return SlotButton