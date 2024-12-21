local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)
local Flipper = require(ReplicatedStorage.Packages.Flipper)

local DeleteSlot = Roact.Component:extend("DeleteSlot")

local MainMenuController

local Theme = require(script.Parent.Parent.Parent.Parent.Theme)

function DeleteSlot:init()
    MainMenuController = Knit.GetController("MainMenuController")

    self.Motor = Flipper.SingleMotor.new(0)
    local Binding, SetBinding = Roact.createBinding(self.Motor:getValue())
    self.Binding = Binding
    self.Motor:onStep(SetBinding)
end

function DeleteSlot:didMount()
    self.Motor:setGoal(Flipper.Spring.new(1, {
        frequency = 5,
        dampingRatio = 1
    }))
end

function DeleteSlot:willUnmount()
    self.Motor:setGoal(Flipper.Spring.new(0, {
        frequency = 5,
        dampingRatio = 1
    }))

    local Done = false

    self.Motor:onComplete(function()
        Done = true
    end)

    repeat
        task.wait(0.1)
    until Done
end

function DeleteSlot:render()
    local Size = self.Binding:map(function(Value)
        return UDim2.fromScale(0, 0):lerp(UDim2.fromScale(1, 1), Value)
    end)

    return Roact.createElement("Frame", {
        Size = Size;
        Position = UDim2.fromScale(0.5, 0.5);
        AnchorPoint = Vector2.new(0.5, 0.5);
        BackgroundColor3 = Theme.BackgroundColor;
        BackgroundTransparency = 0.5;
        BorderSizePixel = 0;
    }, {
        Layout = Roact.createElement("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical;
            HorizontalAlignment = Enum.HorizontalAlignment.Center;
            VerticalAlignment = Enum.VerticalAlignment.Center;
            SortOrder = Enum.SortOrder.LayoutOrder;
        }, {});

        Label = Roact.createElement("TextLabel", {
            Size = UDim2.fromScale(1, 0.5);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            LayoutOrder = 1;

            Text = "Delete slot?";
            TextScaled = true;
            TextXAlignment = Enum.TextXAlignment.Center;
            TextColor3 = Theme.TextColor;
            FontFace = Theme.Font;
        }, {});

        Buttons = Roact.createElement("Frame", {
            Size = UDim2.fromScale(1, 0.5);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            LayoutOrder = 2;
        }, {
            Layout = Roact.createElement("UIListLayout", {
                Padding = UDim.new(0, 10);
                FillDirection = Enum.FillDirection.Horizontal;
                HorizontalAlignment = Enum.HorizontalAlignment.Center;
                VerticalAlignment = Enum.VerticalAlignment.Center;
                SortOrder = Enum.SortOrder.LayoutOrder;
            }, {});

            Yes = Roact.createElement("TextButton", {
                Size = UDim2.fromScale(0.3, 0.7);
                BackgroundColor3 = Theme.BackgroundColorRed;
                BorderSizePixel = 0;
                LayoutOrder = 1;

                Text = "Yes";
                TextScaled = true;
                TextColor3 = Theme.TextColor;
                FontFace = Theme.Font;

                [Roact.Event.MouseButton1Click] = function()
                    MainMenuController:DeleteSlot(self.props.SlotID)
                    self.props.OnDelete()
                    self.props.OnClose()
                end;
            }, {
                Corners = Roact.createElement("UICorner", {
                    CornerRadius = UDim.new(0, 4);
                }, {});
            });

            No = Roact.createElement("TextButton", {
                Size = UDim2.fromScale(0.3, 0.7);
                BackgroundColor3 = Theme.BackgroundColorGreen;
                BorderSizePixel = 0;
                LayoutOrder = 2;

                Text = "No";
                TextScaled = true;
                TextColor3 = Theme.TextColor;
                FontFace = Theme.Font;

                [Roact.Event.MouseButton1Click] = function()
                    self.Motor:setGoal(Flipper.Spring.new(0, {
                        frequency = 5,
                        dampingRatio = 1
                    }))

                    task.wait(0.2)
                    self.props.OnClose()
                end;
            }, {
                Corners = Roact.createElement("UICorner", {
                    CornerRadius = UDim.new(0, 4);
                }, {});
            });
        });
    })
end

return DeleteSlot