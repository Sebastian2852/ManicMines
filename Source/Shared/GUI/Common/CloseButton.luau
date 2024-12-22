local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Packages.Roact)

local CloseButton = Roact.PureComponent:extend("CloseButton")

local Theme = require(script.Parent.Parent.Theme)

function CloseButton:render()
    return Roact.createElement("TextButton", {
        Size = UDim2.fromScale(0.1, 0.09);
        Position = UDim2.fromScale(0.994, 0.012);
        AnchorPoint = Vector2.new(1, 0);
        BackgroundColor3 = Theme.BackgroundColorRed;
        BorderSizePixel = 0;

        Text = "X";
        TextScaled = true;
        TextColor3 = Theme.TextColor;
        FontFace = Theme.Font;

        [Roact.Event.MouseButton1Click] = function()
            Theme.PlaySound(Theme.RawAudio.ButtonClick)

            if self.props.OnClick then
                self.props.OnClick()
            end
        end;

        [Roact.Event.MouseEnter] = function()
            Theme.PlaySound(Theme.RawAudio.ButtonHover, true)
        end;
    }, {
        Corners = Roact.createElement("UICorner", {
            CornerRadius = UDim.new(0, 5);
        });

        AspectRatio = Roact.createElement("UIAspectRatioConstraint", {
            AspectRatio = 1;
        });
    })
end

return CloseButton