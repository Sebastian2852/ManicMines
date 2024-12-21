local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Packages.Roact)

local Theme = require(script.Parent.Theme)

local MainMenu = Roact.Component:extend("MainMenu")

local MenuButtons = require(script.Buttons)
local Title = require(script.Title)

function MainMenu:render()
    return Roact.createElement("ScreenGui", {
        ResetOnSpawn = false;
        ClipToDeviceSafeArea = false;
        SafeAreaCompatibility = Enum.SafeAreaCompatibility.None;
        ScreenInsets = Enum.ScreenInsets.None;
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
    }, {
        App = Roact.createElement("Frame", {
            Size = UDim2.fromScale(1, 1);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
        }, {
            Background = Roact.createElement("Frame", {
                Size = UDim2.fromScale(1, 1);
                BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                BorderSizePixel = 0;
            }, {
                Gradient = Roact.createElement("UIGradient", {
                    Color = ColorSequence.new(Theme.BackgroundColor);
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 0, 0);
                        NumberSequenceKeypoint.new(0.5, 1, 0);
                        NumberSequenceKeypoint.new(1, 1, 0);
                    });
                }, {});
            });

            Content = Roact.createElement("Frame", {
                Size = UDim2.fromScale(1, 1);
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                ZIndex = 2;
            }, {
                Left = Roact.createElement("Frame", {
                    Size = UDim2.fromScale(0.3, 1);
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;
                }, {
                    TitleContainer = Roact.createElement("Frame", {
                        Size = UDim2.fromScale(0.7, 0.15);
                        Position = UDim2.fromScale(0.5, 0.17);
                        AnchorPoint = Vector2.new(0.5, 0.5);
                        BackgroundTransparency = 1;
                        BorderSizePixel = 0;
                    }, {
                        Title = Roact.createElement(Title, {GameName = "Manic Mines", UpdateName = "Recode update"}, {});
                    });

                    ButtonsContainer = Roact.createElement("Frame", {
                        Size = UDim2.fromScale(0.7, 0.5);
                        Position = UDim2.fromScale(0.5, 0.4);
                        AnchorPoint = Vector2.new(0.5, 0);
                        BackgroundTransparency = 1;
                        BorderSizePixel = 0;
                    }, {
                        Buttons = Roact.createElement(MenuButtons);
                    });
                });
            });
        });
    })
end

return MainMenu