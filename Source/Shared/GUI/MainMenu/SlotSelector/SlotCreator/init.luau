local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)

local SlotCreator = Roact.Component:extend("SlotCreator")

local Theme = require(script.Parent.Parent.Parent.Theme)
local RandomButton = require(script.RandomButton)
local NameTextBox = require(script.NameTextBox)

local MainMenuController

function SlotCreator:init()
    MainMenuController = Knit.GetController("MainMenuController")
end

function SlotCreator:render()
    local SlotID = self.props.SlotID
    local SlotName = self.state.SlotName

    return Roact.createElement("Frame", {
        Size = UDim2.fromScale(1, 1);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
    }, {
        Layout = Roact.createElement("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical;
            HorizontalAlignment = Enum.HorizontalAlignment.Center;
            VerticalAlignment = Enum.VerticalAlignment.Top;
            SortOrder = Enum.SortOrder.LayoutOrder;
        }, {});

        TopBar = Roact.createElement("Frame", {
            Size = UDim2.fromScale(1, 0.1);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            LayoutOrder = 1;
        }, {
            Layout = Roact.createElement("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal;
                HorizontalAlignment = Enum.HorizontalAlignment.Left;
                VerticalAlignment = Enum.VerticalAlignment.Center;
                SortOrder = Enum.SortOrder.LayoutOrder;
            }, {});

            Padding = Roact.createElement("UIPadding", {
                PaddingLeft = UDim.new(0.01, 0);
            });

            BackButton = Roact.createElement("TextButton", {
                Size = UDim2.fromScale(0.1, 0.5);
                BackgroundColor3 = Theme.BackgroundColorRed;
                BorderSizePixel = 0;
                LayoutOrder = 1;

                Text = "Back";
                TextScaled = true;
                TextColor3 = Theme.TextColor;
                FontFace = Theme.Font;

                [Roact.Event.MouseButton1Click] = function()
                    self.props.OnClose()
                end;
            }, {
                Corners = Roact.createElement("UICorner", {
                    CornerRadius = UDim.new(0, 4);
                });
            });

            Title = Roact.createElement("TextLabel", {
                Size = UDim2.fromScale(0.75, 0.7);
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                LayoutOrder = 2;

                Text = "Create Slot";
                TextScaled = true;
                TextColor3 = Theme.TextColor;
                FontFace = Theme.Font;
            }, {});
        });

        Name = Roact.createElement("Frame", {
            Size = UDim2.fromScale(1, 0.3);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            LayoutOrder = 2;
        }, {
            Title = Roact.createElement("TextLabel", {
                Size = UDim2.fromScale(1, 0.2);
                BackgroundTransparency = 1;
                BorderSizePixel = 0;

                Text = "Tycoon Name";
                TextScaled = true;
                TextColor3 = Theme.TextColor;
                FontFace = Theme.Font;
            }, {});

            NameInput = Roact.createElement("Frame", {
                Size = UDim2.fromScale(0.7, 0.3);
                Position = UDim2.fromScale(0.5, 0.5);
                AnchorPoint = Vector2.new(0.5, 0.5);
                BackgroundTransparency = 0.7;
                BackgroundColor3 = Theme.BackgroundColor;
                BorderSizePixel = 0;
            }, {
                Layout = Roact.createElement("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal;
                    HorizontalAlignment = Enum.HorizontalAlignment.Center;
                    VerticalAlignment = Enum.VerticalAlignment.Center;
                    SortOrder = Enum.SortOrder.LayoutOrder;
                    HorizontalFlex = Enum.UIFlexAlignment.Fill;
                }, {});

                Corners = Roact.createElement("UICorner", {
                    CornerRadius = UDim.new(0, 4);
                });

                Container = Roact.createElement("Frame", {
                    Size = UDim2.fromScale(1, 0.8);
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;
                    LayoutOrder = 1;
                }, {
                    Input = Roact.createElement(NameTextBox, {
                        TextChanged = function(NewText)
                            self:setState({
                                SlotName = NewText
                            })
                        end;
                    });
                });

                RandomButton = Roact.createElement(RandomButton, {
                    LayoutOrder = 2;
                }, {});
            });
        });

        Padding = Roact.createElement("Frame", {
            Size = UDim2.fromScale(1, 0.5);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            LayoutOrder = 3;
        }, {});

        BottomBar = Roact.createElement("Frame", {
            Size = UDim2.fromScale(1, 0.1);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            LayoutOrder = 4;
        }, {
            Layout = Roact.createElement("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal;
                HorizontalAlignment = Enum.HorizontalAlignment.Center;
                VerticalAlignment = Enum.VerticalAlignment.Center;
                SortOrder = Enum.SortOrder.LayoutOrder;
            }, {});

            CreateButton = Roact.createElement("TextButton", {
                Size = UDim2.fromScale(0.3, 0.7);
                BackgroundColor3 = Theme.BackgroundColorGreen;
                BorderSizePixel = 0;
                LayoutOrder = 1;

                Text = "Create";
                TextScaled = true;
                TextColor3 = Theme.TextColor;
                FontFace = Theme.Font;

                [Roact.Event.MouseButton1Click] = function()
                    local SlotSettings = MainMenuController:CreateSlotSettings(SlotName)
                    MainMenuController:CreateSlot(SlotID, SlotSettings)
                end;
            }, {
                Corners = Roact.createElement("UICorner", {
                    CornerRadius = UDim.new(0, 4);
                });
            });
        });
    })
end

return SlotCreator