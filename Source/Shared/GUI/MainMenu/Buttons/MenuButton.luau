local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Packages.Roact)
local Flipper = require(ReplicatedStorage.Packages.Flipper)

local Theme = require(script.Parent.Parent.Parent.Theme)

local MenuButton = Roact.Component:extend("MenuButton")

function MenuButton:init()
    local Text = "> "..self.props.Text :: string or "NO TEXT GIVEN"

    self:setState({
        Text = Text;
        HoveredText = "<b><u>"..Text.."</u></b>";
        Hovered = false;
    })

    self.Motor = Flipper.SingleMotor.new(0)
    local Binding, SetBinding = Roact.createBinding(self.Motor:getValue())
    self.Binding = Binding
    self.Motor:onStep(SetBinding)
end

function MenuButton:render()
    local LayoutOrder = self.props.LayoutOrder
    local Hovered = self.state.Hovered
    local Text = self.state.Text
    local HoveredText = self.state.HoveredText

    local Size = self.Binding:map(function(Value)
        return UDim2.fromScale(1, 0.1):Lerp(UDim2.fromScale(1, 0.11), Value)
    end)

    return Roact.createElement("Frame", {
        Size = Size;
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

                self:setState({
                    Hovered = true;
                })

                self.Motor:setGoal(Flipper.Spring.new(1, {
                    frequency = 5,
                    dampingRatio = 1
                }))
            end;

            [Roact.Event.MouseLeave] = function()
                self:setState({
                    Hovered = false;
                })

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

            Text = Hovered and HoveredText or Text;
            TextScaled = true;
            RichText = true;
            TextColor3 = Theme.TextColor;
            FontFace = Theme.Font;
            TextXAlignment = Enum.TextXAlignment.Left;
        }, {});
    })
end

return MenuButton