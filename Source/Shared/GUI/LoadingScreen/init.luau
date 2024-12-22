local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)

local LoadingScreen = Roact.Component:extend("LoadingScreen")

local Theme = require(script.Parent.Theme)
local Text = require(script.Text)
local Spinner = require(script.Spinner)

function LoadingScreen:init()
    local LoadingService = Knit.GetService("LoadingService")

    self:setState({
        BigText = self.props.BigText or "";
        SmallText = self.props.SmallText or "";
    })

    LoadingService.UpdateActionText:Connect(function(New)
        self:setState({
            SmallText = New;
        })
    end)
end

function LoadingScreen:render()
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
            BorderSizePixel = 0;
            Active = true;
        }, {
            Container = Roact.createElement("Frame", {
                Size = UDim2.fromScale(1, 0.15);
                Position = UDim2.fromScale(1, 1);
                AnchorPoint = Vector2.new(1, 1);
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
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

                    Spinner = Roact.createElement(Spinner, {}, {});
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
                    }, {});
                });
            });
        })
    })
end

return LoadingScreen