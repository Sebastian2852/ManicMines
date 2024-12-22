local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)
local Flipper = require(ReplicatedStorage.Packages.Flipper)

local LoadingScreen = Roact.Component:extend("LoadingScreen")

local Theme = require(script.Parent.Theme)
local Text = require(script.Text)
local Spinner = require(script.Spinner)
local Background = require(script.Background)

local function Lerp(Start :number, End :number, Time :number)
    return Start * (1 - Time) + End * Time
end

function LoadingScreen:init()
    local LoadingService = Knit.GetService("LoadingService")

    local PossibleImages = ReplicatedStorage.Assets.UI.LoadingScreenImages:GetChildren()
    local ImageID = nil

    if #PossibleImages >= 1 then
        local RandomImage = PossibleImages[math.random(1, #PossibleImages)] :: Decal
        ImageID = RandomImage.Texture
    end

    self:setState({
        BigText = self.props.BigText or "";
        SmallText = self.props.SmallText or "";
        ImageID = ImageID;
    })

    LoadingService.UpdateActionText:Connect(function(New)
        self:setState({
            SmallText = New;
        })
    end)

    self.Motor = Flipper.SingleMotor.new(0)
    local Binding, SetBinding = Roact.createBinding(self.Motor:getValue())
    self.Binding = Binding
    self.Motor:onStep(SetBinding)
end

function LoadingScreen:didMount()
    self.Motor:setGoal(Flipper.Spring.new(1, {
        frequency = 4,
        dampingRatio = 1
    }))
end

function LoadingScreen:willUnmount()
    self.Motor:setGoal(Flipper.Spring.new(0, {
        frequency = 5,
        dampingRatio = 1
    }))

    local Done = false

    self.Motor:onComplete(function()
        Done = true
    end)

    repeat
        task.wait(0.01)
    until Done
end

function LoadingScreen:render()
    local ImageID = self.state.ImageID
    local Transparency = self.Binding:map(function(Value)
        return Lerp(1, 0, Value)
    end)

    return Roact.createElement("ScreenGui", {
        DisplayOrder = 100;
        ResetOnSpawn = false;
        ClipToDeviceSafeArea = false;
        SafeAreaCompatibility = Enum.SafeAreaCompatibility.None;
        ScreenInsets = Enum.ScreenInsets.None;
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
    }, {
        App = Roact.createElement("Frame", {
            Size = UDim2.fromScale(1, 1);
            BackgroundColor3 = Theme.BackgroundColor;
            BackgroundTransparency = Transparency;
            BorderSizePixel = 0;
            Active = true;
        }, {
            Background = Roact.createElement("Frame", {
                Size = UDim2.fromScale(1, 1);
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
            }, {
                Background = Roact.createElement(Background, {
                    Image = ImageID;
                    Transparency = Transparency;
                }, {});
            });

            Container = Roact.createElement("Frame", {
                Size = UDim2.fromScale(1, 0.15);
                Position = UDim2.fromScale(1, 1);
                AnchorPoint = Vector2.new(1, 1);
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                ZIndex = 2;
            }, {
                Layout = Roact.createElement("UIListLayout", {
                    Padding = UDim.new(0, 20);
                    FillDirection = Enum.FillDirection.Horizontal;
                    HorizontalFlex = Enum.UIFlexAlignment.Fill;
                    VerticalAlignment = Enum.VerticalAlignment.Bottom;
                    SortOrder = Enum.SortOrder.LayoutOrder;
                }, {});

                Padding = Roact.createElement("UIPadding", {
                    PaddingBottom = UDim.new(0, 10);
                    PaddingLeft = UDim.new(0, 10);
                }, {});

                SpinnerContainer = Roact.createElement("Frame", {
                    Size = UDim2.fromScale(1, 1);
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;
                }, {
                    AspectRatio = Roact.createElement("UIAspectRatioConstraint", {
                        AspectRatio = 1;
                    }, {});

                    Spinner = Roact.createElement(Spinner, {
                        Transparency = Transparency;
                    }, {});
                });

                TextContainer = Roact.createElement("Frame", {
                    Size = UDim2.fromScale(1, 0.75);
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;
                    LayoutOrder = 2;
                }, {
                    Text = Roact.createElement(Text, {
                        BigText = self.state.BigText;
                        SmallText = self.state.SmallText;
                        Transparency = Transparency;
                    }, {});
                });
            });
        })
    })
end

return LoadingScreen