local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)

local HUDController = Knit.CreateController { Name = "HUDController" }

function HUDController:KnitStart()
    local LogService = Knit.GetService("LogService")
    local DataService = Knit.GetService("DataService")

    local HUD = require(ReplicatedStorage.Game.GUI.HUD)

    local App = Roact.createElement(HUD)
    Roact.mount(App, Knit.Player.PlayerGui, "HUD")
    LogService:Log("Mounted HUD component")
end

return HUDController