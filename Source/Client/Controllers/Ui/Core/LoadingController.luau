local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)

local LoadingController = Knit.CreateController {
    Name = "LoadingController"
}

local LoadingService
local LogService
local HotbarController

local LoadingScreen
local Tree
local Player = Knit.Player

-- [[ PUBLIC ]] --

function LoadingController:ShowGui(BigText :string?, SmallText :string?)
    UserInputService.MouseIconEnabled = false
    HotbarController:DisableHotbar()
    local App = Roact.createElement(LoadingScreen, {
        BigText = BigText;
        SmallText = SmallText;
    }, {})
    Tree = Roact.mount(App, Player.PlayerGui, "LoadingScreen")
    LogService:Log("Mounted loading screen")
end

function LoadingController:HideGui()
    UserInputService.MouseIconEnabled = true
    HotbarController:EnableHotbar()
    if Tree then
        Roact.unmount(Tree)
        LogService:Log("Unmounted loading screen")
    end
end



--[[ KNIT ]]--

function LoadingController:KnitStart()
    LoadingService = Knit.GetService("LoadingService")
    LogService = Knit.GetService("LogService")
    HotbarController = Knit.GetController("HotbarController")
    LoadingScreen = require(ReplicatedStorage.Game.GUI.LoadingScreen)

    LoadingService.LoadingStarted:Connect(function()
        self:ShowGui("Loading")
    end)

    LoadingService.LoadingEnded:Connect(function()
        self:HideGui()
    end)
end

return LoadingController