local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)
local Core = require(ReplicatedStorage.Game.Modules.Core)

local Buttons = Roact.Component:extend("Buttons")

local Theme = require(script.Parent.Parent.Theme)
local AnimatedButton = require(script.AnimatedButton)

local TeleportService

function Buttons:init()
    local DataService = Knit.GetService("DataService")
    TeleportService = Knit.GetService("TeleportService")

    DataService:GetPlayerDataFolder():andThen(function(DataFolder :Core.DataFolder)
        local InTycoon = DataFolder.InTycoon

        InTycoon:GetPropertyChangedSignal("Value"):Connect(function()
            self:setState({
                InTycoon = InTycoon.Value;
            })
        end)

        self:setState({
            InTycoon = InTycoon.Value;
        })
    end)
end

function Buttons:render()
    local InTycoon = self.state.InTycoon or false

    return Roact.createElement("Frame", {
        Size = UDim2.fromScale(1, 1);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
    }, {
        Layout = Roact.createElement("UIListLayout", {
            Padding = UDim.new(0, 15);
            SortOrder = Enum.SortOrder.LayoutOrder;
            FillDirection = Enum.FillDirection.Horizontal;
            HorizontalAlignment = Enum.HorizontalAlignment.Left;
            VerticalAlignment = Enum.VerticalAlignment.Bottom;
        }, {});

        SurfaceButton = Roact.createElement("Frame", {
            Size = UDim2.fromScale(1, 1);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            LayoutOrder = 1;
        }, {
            AspectRatio = Roact.createElement("UIAspectRatioConstraint", {
                AspectRatio = 1;
                AspectType = Enum.AspectType.FitWithinMaxSize;
                DominantAxis = Enum.DominantAxis.Height;
            }, {});

            Button = Roact.createElement(AnimatedButton, {
                Background = Theme.Images.SurfaceButton;
                Icon = "";
                OnClick = function()
                    TeleportService:TeleportToSurface()
                end;
            }, {});
        });

        TycoonTeleport = not InTycoon and Roact.createElement("Frame", {
            Size = UDim2.fromScale(1, 1);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            LayoutOrder = 2;
        }, {
            AspectRatio = Roact.createElement("UIAspectRatioConstraint", {
                AspectRatio = 1;
                AspectType = Enum.AspectType.FitWithinMaxSize;
                DominantAxis = Enum.DominantAxis.Height;
            }, {});

            Button = Roact.createElement(AnimatedButton, {
                Background = Theme.Images.TycoonTeleportButton;
                Icon = "";
                OnClick = function()
                    TeleportService:TeleportToTycoon()
                end;
            }, {});
        });
    });
end

return Buttons