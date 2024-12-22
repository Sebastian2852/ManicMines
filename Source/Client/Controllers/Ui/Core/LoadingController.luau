local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)

local LoadingController = Knit.CreateController {
    Name = "LoadingController"
}

local LoadingService

local Player = Knit.Player

--[[ KNIT ]]--

function LoadingController:KnitStart()
    LoadingService = Knit.GetService("LoadingService")
    local LogService = Knit.GetService("LogService")

    local LoadingScreen = require(ReplicatedStorage.Game.GUI.LoadingScreen)
    local App = Roact.createElement(LoadingScreen, {
        BigText = "Big boi text";
        SmallText = "Small boi text";
    }, {})
    Roact.mount(App, Player.PlayerGui, "LoadingScreen")
    LogService:Log("Mounted loading screen component")
end

return LoadingController