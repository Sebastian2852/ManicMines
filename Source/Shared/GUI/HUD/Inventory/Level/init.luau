local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)
local Flipper = require(ReplicatedStorage.Packages.Flipper)
local Core = require(ReplicatedStorage.Game.Modules.Core)

local LevelDisplay = Roact.Component:extend("LevelDisplay")

local Theme = require(script.Parent.Parent.Parent.Theme)
local XpDiff = require(script.XpDiff)

function LevelDisplay:init()
    local DataService = Knit.GetService("DataService")

    DataService:GetPlayerDataFolder():andThen(function(DataFolder :Core.DataFolder)
        local Xp = DataFolder.XP
        local Level = DataFolder.Level

        self.XpConnection = Xp:GetPropertyChangedSignal("Value"):Connect(function()
            self:UpdateXp(Xp.Value)
        end)

        self.LevelConnection = Level:GetPropertyChangedSignal("Value"):Connect(function()
            self:UpdateLevel(Level.Value)
        end)

        self:UpdateXp(Xp.Value)
        self:UpdateLevel(Level.Value)
    end)

    self.Motor = Flipper.SingleMotor.new(0)
    local Binding, SetBinding = Roact.createBinding(self.Motor:getValue())
    self.Binding = Binding
    self.Motor:onStep(SetBinding)

    self.TextMotor = Flipper.SingleMotor.new(0)
    local TextBinding, TextSetBinding = Roact.createBinding(self.Motor:getValue())
    self.TextBinding = TextBinding
    self.TextMotor:onStep(TextSetBinding)

    self:setState({
        Xp = 0;
        XpNeeded = 0;
        XpChange = 0;
        ShowChange = false;
    })
end

function LevelDisplay:UpdateXp(Xp :number)
    local NeededXp = self.state.XpNeeded or 100
    local LastXp = self.state.LastXp or 0
    local XpChange = Xp - LastXp
    local ShowChange = XpChange > 1

    self.Motor:setGoal(Flipper.Spring.new(Xp / NeededXp, {
        frequency = 4;
        dampingRatio = 1;
    }))

    self:setState({
        LastXp = Xp;
        XpChange = XpChange;
        ShowChange = ShowChange;
    })

    if ShowChange then
        task.wait(0.61)

        self.TextMotor:setGoal(Flipper.Spring.new(1, {
            frequency = 4;
            dampingRatio = 1;
        }))
    end


    self:setState({
        ShowChange = false;
        Xp = Xp;
    })

    if ShowChange then
        task.wait(0.15)

        self.TextMotor:setGoal(Flipper.Spring.new(0, {
            frequency = 4;
            dampingRatio = 1;
        }))
    end
end

function LevelDisplay:UpdateLevel(Level :number)
    local CurrentLevel = Level
    local CurrentLevelConfig = Core.Assets.Levels:FindFirstChild(tostring(CurrentLevel))
    local NextLevelConfig = Core.Assets.Levels:FindFirstChild(tostring(CurrentLevel + 1))

    local LevelName = CurrentLevelConfig:GetAttribute("LevelName") :: string
    local LevelColor = CurrentLevelConfig:GetAttribute("LevelColor") :: Color3
    local BarGradient = CurrentLevelConfig:GetAttribute("LevelXpBarColor") :: ColorSequence
    local XpNeeded = NextLevelConfig and NextLevelConfig:GetAttribute("XpNeeded") or 0

    self:setState({
        LevelName = LevelName;
        LevelColor = LevelColor;
        BarGradient = BarGradient;
        XpNeeded = XpNeeded;
    })
end

function LevelDisplay:willUnmount()
    if self.XpConnection then
        self.XpConnection:Disconnect()
    end

    if self.LevelConnection then
        self.LevelConnection:Disconnect()
    end
end

function LevelDisplay:render()
    local Xp = self.state.Xp or -1
    local XpNeeded = self.state.XpNeeded or -1
    local XpChange = self.state.XpChange or 0
    local ShowXpChange = self.state.ShowChange or false
    local LevelName = self.state.LevelName or "UNKOWN"
    local LevelColor = self.state.LevelColor or Color3.new(1, 0, 0)
    local BarGradient = self.state.BarGradient or ColorSequence.new(Color3.new(1, 0, 0))

    local BarSize = self.Binding:map(function(Value)
        return UDim2.fromScale(0, 1):Lerp(UDim2.fromScale(1, 1), Value)
    end)

    local TextPosition = self.TextBinding:map(function(Value)
        return UDim2.fromScale(0.5, 0.5):Lerp(UDim2.fromScale(0.5, 1), Value)
    end)

    return Roact.createElement("Frame", {
        Size = UDim2.fromScale(1, 1);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
    }, {
        Layout = Roact.createElement("UIListLayout", {
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
        }, {});

        TextArea = Roact.createElement("Frame", {
            Size = UDim2.fromScale(1, 0.8);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
        }, {
            Layout = Roact.createElement("UIListLayout", {
                FillDirection = Enum.FillDirection.Vertical;
                SortOrder = Enum.SortOrder.LayoutOrder;
            }, {});

            TopText = Roact.createElement("TextLabel", {
                Size = UDim2.fromScale(1, 0.5);
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                LayoutOrder = 1;

                Text = LevelName;
                TextScaled = true;
                TextXAlignment = Enum.TextXAlignment.Right;
                TextColor3 = LevelColor;
                FontFace = Theme.Font;
            }, {});

            BottomText = Roact.createElement("Frame", {
                Size = UDim2.fromScale(1, 0.5);
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                LayoutOrder = 2;
            }, {
                Layout = Roact.createElement("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal;
                    SortOrder = Enum.SortOrder.LayoutOrder;
                }, {});

                CurrentXpContainer = Roact.createElement("Frame", {
                    Size = UDim2.fromScale(0.45, 1);
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0
                }, {
                    CurrentXp = Roact.createElement("TextLabel", {
                        Size = UDim2.fromScale(1, 1);
                        Position = TextPosition;
                        AnchorPoint = Vector2.new(0.5, 0.5);
                        BackgroundTransparency = 1;
                        BorderSizePixel = 0;
                        LayoutOrder = 1;

                        Text = Xp;
                        TextScaled = true;
                        TextXAlignment = Enum.TextXAlignment.Left;
                        TextColor3 = Theme.TextColor;
                        FontFace = Theme.Font;
                    }, {
                        ShowXpChange and Roact.createElement(XpDiff, {
                            Amount = XpChange;
                        }, {})
                    });
                });

                Slash = Roact.createElement("TextLabel", {
                    Size = UDim2.fromScale(0.1, 1);
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;
                    LayoutOrder = 2;

                    Text = "/";
                    TextScaled = true;
                    TextXAlignment = Enum.TextXAlignment.Center;
                    TextColor3 = Theme.TextColor;
                    FontFace = Theme.Font;
                }, {});

                NeededXp = Roact.createElement("TextLabel", {
                    Size = UDim2.fromScale(0.45, 1);
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;
                    LayoutOrder = 3;

                    Text = XpNeeded;
                    TextScaled = true;
                    TextXAlignment = Enum.TextXAlignment.Right;
                    TextColor3 = Theme.TextColor;
                    FontFace = Theme.Font;
                }, {});
            });
        });

        BarArea = Roact.createElement("Frame", {
            Size = UDim2.fromScale(1, 0.2);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            LayoutOrder = 2;
        }, {
            BarBackground = Roact.createElement("Frame", {
                Size = UDim2.fromScale(1, 0.6);
                Position = UDim2.fromScale(0.5, 0.5);
                AnchorPoint = Vector2.new(0.5, 0.5);
                BackgroundColor3 = Theme.BackgroundColor;
                BorderSizePixel = 0;
            }, {
                Outline = Roact.createElement("UIStroke", {
                    Thickness = 3;
                    Color = Color3.new(0, 0, 0);
                }, {});

                Bar = Roact.createElement("Frame", {
                    Size = BarSize;
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255);
                    BorderSizePixel = 0;
                }, {
                    Gradient = Roact.createElement("UIGradient", {
                        Color = BarGradient;
                    }, {});
                });
            });
        });
    });
end

return LevelDisplay