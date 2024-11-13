local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)

local Core = require(ReplicatedStorage.Game.Modules.Core)

local GeneralController = Knit.CreateController { Name = "GeneralController" }

local TeleportService
local DataService
local LogService

local DataFolder :Core.DataFolder

local GeneralComponent = Roact.Component:extend("General")

function GeneralComponent:init()
    DataFolder.Gold:GetPropertyChangedSignal("Value"):Connect(function()
        self:setState({
            Gold = tostring(DataFolder.Gold.Value)
        })
    end)

    self:setState({
        Gold = tostring(DataFolder.Gold.Value)
    })
end

function GeneralComponent:render()
    return Roact.createElement("ScreenGui", {
        ResetOnSpawn = false;
    }, {
        Gold = Roact.createElement("Frame", {
            Size = UDim2.fromScale(0.1, 0.05);
            Position = Core.UI.Position.LeftCenter;
            AnchorPoint = Core.UI.AnchorPoint.LeftCenter;

            BackgroundTransparency = 1;
            BorderSizePixel = 0;
        }, {
            Layout = Roact.createElement("UIListLayout", {
                FillDirection = Enum.FillDirection.Horizontal;
                HorizontalFlex = Enum.UIFlexAlignment.Fill;
            }, {});

            Icon = Roact.createElement("ImageLabel", {
                Size = UDim2.fromScale(1, 1);
                SizeConstraint = Enum.SizeConstraint.RelativeYY;
                BackgroundTransparency = 1;
                BorderSizePixel = 0;

                Image = Core.UI.Images.Missing;
                ScaleType = Enum.ScaleType.Fit;
            }, {});

            Text = Roact.createElement("TextLabel", {
                Size = UDim2.fromScale(0.9, 1);
                BackgroundTransparency = 1;
                BorderSizePixel = 0;

                Text = " "..self.state.Gold;
                FontFace = Core.UI.Theme.TextFont;
                TextColor3 = Core.UI.Theme.TextColor3;
                TextScaled = true;
                TextXAlignment = Enum.TextXAlignment.Left;
            }, {})
        });

        SurfaceButton = Roact.createElement("ImageButton", {
            Size = UDim2.fromScale(0.04, 0.08);
            Position = UDim2.fromScale(0.06, 0.98);
            AnchorPoint = Core.UI.AnchorPoint.BottomLeft;
            BackgroundTransparency = 1;
            BorderSizePixel = 0;

            Image = "rbxassetid://119967532396729";

            [Roact.Event.Activated] = function()
                LogService:Log("Surface button pressed")
                TeleportService:TeleportToSurface()
            end
        }, {
            AspectRatio = Roact.createElement("UIAspectRatioConstraint", {
                AspectRatio = 1;
            }, {})
        })
    })
end

function GeneralController:KnitStart()
    TeleportService = Knit.GetService("TeleportService")
    DataService = Knit.GetService("DataService")
    LogService = Knit.GetService("LogService")

    DataService.DataLoaded:Connect(function(LoadedDataFolder :Core.DataFolder)
        DataFolder = LoadedDataFolder

        local App = Core.Roact.createElement(GeneralComponent)
        Core.Roact.mount(App, Knit.Player.PlayerGui, "HUD")
        LogService:Log("Mounted 'general HUD' component")
    end)
end

return GeneralController