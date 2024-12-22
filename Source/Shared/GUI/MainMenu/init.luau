local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)
local Flipper = require(ReplicatedStorage.Packages.Flipper)

local Theme = require(script.Parent.Theme)

local MainMenu = Roact.Component:extend("MainMenu")

local MenuButtons = require(script.Buttons)
local CreditsMenu = require(script.CreditsMenu)
local SlotSelector = require(script.SlotSelector)
local Title = require(script.Title)

function MainMenu:init()
    self:setState({
        ShowCredits = false;
        ShowPlay = false;
    })

    self.Motor = Flipper.SingleMotor.new(0)
    local Binding, SetBinding = Roact.createBinding(self.Motor:getValue())
    self.Binding = Binding
    self.Motor:onStep(SetBinding)
end

function MainMenu:didMount()
    task.wait(1)
    self.Motor:setGoal(Flipper.Spring.new(1, {
        frequency = 5,
        dampingRatio = 1
    }))
end

function MainMenu:render()
    local ShowCredits = self.state.ShowCredits
    local ShowPlay = self.state.ShowPlay

    local Position = self.Binding:map(function(Value)
        return UDim2.fromScale(-0.3, 0):Lerp(UDim2.fromScale(0, 0), Value)
    end)

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
                Position = Position;
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
                    Position = Position;
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
                        Buttons = Roact.createElement(MenuButtons, {
                            OnClickCredits = function()
                                self.Motor:setGoal(Flipper.Spring.new(0, {
                                    frequency = 5,
                                    dampingRatio = 1
                                }))

                                task.wait(0.3)

                                self:setState({
                                    ShowCredits = not self.state.ShowCredits;
                                })
                            end;

                            OnClickPlay = function()
                                self.Motor:setGoal(Flipper.Spring.new(0, {
                                    frequency = 5,
                                    dampingRatio = 1
                                }))

                                task.wait(0.3)

                                self:setState({
                                    ShowPlay = not self.state.ShowPlay;
                                })
                            end;
                        }, {});
                    });
                });
            });

            Container = Roact.createElement("Frame", {
                Size = UDim2.fromScale(0.5, 0.5);
                Position = UDim2.fromScale(0.5, 0.5);
                AnchorPoint = Vector2.new(0.5, 0.5);
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                ZIndex = 2;
            }, {
                Credits = ShowCredits and Roact.createElement(CreditsMenu, {
                    OnClick = function()
                        self.Motor:setGoal(Flipper.Spring.new(1, {
                            frequency = 5,
                            dampingRatio = 1
                        }))

                        task.wait(0.2)

                        self:setState({
                            ShowCredits = false;
                        })
                    end;
                });

                SlotSelector = ShowPlay and Roact.createElement(SlotSelector, {
                    OnClick = function()
                        self.Motor:setGoal(Flipper.Spring.new(1, {
                            frequency = 5,
                            dampingRatio = 1
                        }))

                        task.wait(0.2)

                        self:setState({
                            ShowPlay = false;
                        })
                    end;
                });
            });
        });
    })
end

return MainMenu