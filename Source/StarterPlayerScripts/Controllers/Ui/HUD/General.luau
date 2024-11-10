local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)

local Core = require(ReplicatedStorage.Game.Modules.Core)

local GeneralController = Knit.CreateController { Name = "GeneralController" }

local TeleportService
local DataService
local LogService

local GeneralComponent = Roact.Component:extend("General")
local Player = Knit.Player

function GeneralComponent:render()
    return Roact.createElement("ScreenGui", {}, {
        SurfaceButton = Roact.createElement("ImageButton", {
            Size = UDim2.fromScale(0.04, 0.08);
            Position = UDim2.fromScale(0.06, 0.98);
            AnchorPoint = Core.UI.AnchorPoint.BottomLeft;
            BackgroundTransparency = 1;

            BorderSizePixel = 0;
            Image = "rbxassetid://16847077275";
            ImageTransparency = 0.5;

            [Roact.Event.Activated] = function()
                LogService:Log("Surface button pressed")
                TeleportService:TeleportToSurface()
            end
        }, {})
    })
end

function GeneralController:KnitStart()
    TeleportService = Knit.GetService("TeleportService")
    DataService = Knit.GetService("DataService")
    LogService = Knit.GetService("LogService")

    DataService:GetPlayerDataFolder():andThen(function(Return)
        repeat
            task.wait(0.1)
        until Return.DataLoaded.Value

        local App = Core.Roact.createElement(GeneralComponent)
        Core.Roact.mount(App, Knit.Player.PlayerGui, "HUD")
        LogService:Log("Mounted 'general HUD' component")
    end)
end

return GeneralController