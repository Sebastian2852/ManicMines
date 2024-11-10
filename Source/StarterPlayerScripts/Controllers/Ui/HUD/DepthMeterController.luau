local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)

local Core = require(ReplicatedStorage.Game.Modules.Core)

local DepthMeterController = Knit.CreateController { Name = "DepthMeterController" }

local DepthMeterComponent = Roact.Component:extend("DepthMeter")
local Player = Knit.Player

local function ConvertToDepth(Y :number)
    local Top = workspace.Game.MineSpawn.Position.Y
    local CellSize = Core.GameConfig.Mine.BlockSize.Y
    return math.floor((Top - Y) / CellSize) - math.floor(50 / 6)
end

function DepthMeterComponent:init()
    self:setState({
        Position = Vector3.new(0, 0, 0);
        Show = false
    })

    RunService:BindToRenderStep("CharacterPosition", Enum.RenderPriority.Input.Value, function()
        local Character = Player.Character
        if not Character then
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
    local Y = ConvertToDepth(Position.Y)
    local Z = math.floor(Position.Z)

    return X..", "..Y..", "..Z
end

function DepthMeterComponent:render()
    return Roact.createElement("ScreenGui", {}, {
        Meter = self.state.Show and Roact.createElement("TextLabel", {
            Size = UDim2.fromScale(1, 1);
            Position = Core.UI.Position.Center;
            AnchorPoint = Core.UI.AnchorPoint.Center;

            BackgroundTransparency = 1;

            Text = self:GetPositionText();
            TextColor3 = Core.UI.Theme.TextColor3;
            FontFace = Core.UI.Theme.TextFont;
            TextScaled = true;
        }, {})
    })
end

function DepthMeterController:KnitStart()
    local App = Roact.createElement(DepthMeterComponent)
    Roact.mount(App, Player.PlayerGui, "DepthMeter")
end

return DepthMeterController