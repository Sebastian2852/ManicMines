local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)

local Core = require(ReplicatedStorage.Game.Modules.Core)

local DepthMeterController = Knit.CreateController { Name = "DepthMeterController" }

local DepthMeterComponent = Roact.Component:extend("DepthMeter")
local Player = Knit.Player

function DepthMeterComponent:init()
    self:setState({
        Position = Vector3.new(0, 0, 0);
        Show = false
    })

    RunService:BindToRenderStep("CharacterPosition", Enum.RenderPriority.Input.Value, function()
        local Character = Player.Character
        if not Character or ReplicatedStorage.Player.Depth.Value <= 0 then
            self:setState({
                Position = Vector3.zero;
                Show = false;
            })
            return
        end

        self:setState({
            Position = Character.PrimaryPart.Position;
            Show = true;
        })
    end)
end

function DepthMeterComponent:GetPositionText() :string
    local Position = self.state.Position
    local X = math.floor(Position.X)
    local Y = ReplicatedStorage.Player.Depth.Value
    local Z = math.floor(Position.Z)

    return X..", "..Y.."m, "..Z
end

function DepthMeterComponent:render()
    return Roact.createElement("ScreenGui", {
        IgnoreGuiInset = true;
        ResetOnSpawn = false;
    }, {
        Meter = self.state.Show and Roact.createElement("TextLabel", {
            Size = UDim2.fromScale(0.3, 0.05);
            Position = Core.UI.Position.TopCenter;
            AnchorPoint = Core.UI.AnchorPoint.TopCenter;

            BackgroundTransparency = 1;

            Text = self:GetPositionText();
            TextStrokeTransparency = 0;
            TextScaled = true;
            TextColor3 = Core.UI.Theme.TextColor3;
            FontFace = Core.UI.Theme.TextFont;
        }, {})
    })
end

function DepthMeterController:KnitStart()
    local LogService = Knit.GetService("LogService")
    local DataService = Knit.GetService("DataService")

    DataService.DataLoaded:Connect(function()
        local App = Roact.createElement(DepthMeterComponent)
        Roact.mount(App, Player.PlayerGui, "DepthMeter")
        LogService:Log("Mounted depth meter component")
    end)
end

return DepthMeterController