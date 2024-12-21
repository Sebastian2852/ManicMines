local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Packages.Roact);

local Theme = require(script.Parent.Parent.Parent.Theme)

local MenuButton = Roact.Component:extend("MenuButton")

function MenuButton:init()
    local Text = "> "..self.props.Text :: string or "NO TEXT GIVEN"

    self:setState({
        Text = Text;
        HoveredText = "<b><u>"..Text.."</u></b>";
        Hovered = false;
    })
end

function MenuButton:render()
    local LayoutOrder = self.props.LayoutOrder
    local Hovered = self.state.Hovered
    local Text = self.state.Text
    local HoveredText = self.state.HoveredText

    return Roact.createElement("Frame", {
        Size = UDim2.fromScale(1, 0.1);
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
                self:setState({
                    Hovered = true;
                })
            end;

            [Roact.Event.MouseLeave] = function()
                self:setState({
                    Hovered = false;
                })
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