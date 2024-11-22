local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)
local Core = require(ReplicatedStorage.Game.Modules.Core)

local PickaxeSelectionController = Knit.CreateController { Name = "PickaxeSelectionController" }

local PlayerFolder = ReplicatedStorage.Player

local PickaxeService
local LogService

-- [[ PRIVATE ]] --

local function CalculateTimeToMine(Health)
    local Pickaxe :Instance = Knit.Player.Character:FindFirstChild("Pickaxe")

    local HitsNeeded = math.ceil(Health / Pickaxe:GetAttribute("Damage"))
    local TimePerHit = Pickaxe:GetAttribute("Delay")
    local TotalTime = HitsNeeded * TimePerHit
    return Core.Util:RoundToxDP(TotalTime, 1)
end


-- [[ GUI ]] --

local PickaxeSelectionComponent = Roact.Component:extend("PickaxeSelection")

function PickaxeSelectionComponent:init()
    local PropsOre = self.props.Ore
    local PropsOreName = self.props.Name
    local PropsTimeToMine = self.props.TimeToMine.."s - "..self.props.PercentageMined.."%"
    local PropsProgress = self.props.MiningProgress

    self:setState({
        Ore = PropsOre;
        OreName = PropsOreName;
        TimeToMine = PropsTimeToMine;
        MiningProgress = PropsProgress;
    })

    self.UpdateConnection = PickaxeService.UpdateMiningSelection:Connect(function(OreName :string, TimeToMine :number, Percentage :number, MiningProgress :number)
        local RealOre = Core.Util:GetOreByName(OreName)
        if not RealOre then return end

        self:setState({
            Ore = RealOre;
            OreName = RealOre:GetAttribute("DisplayName");
            TimeToMine = TimeToMine.."s - "..Percentage.."%";
            MiningProgress = MiningProgress;
        })
    end)
end

function PickaxeSelectionComponent:willUnmount()
    local UpdateConnection = self.UpdateConnection ::RBXScriptConnection

    if UpdateConnection then
        UpdateConnection:Disconnect()
    end
end

function PickaxeSelectionComponent:render()
    LogService:Log("Rendering pickaxe selection GUI")
    local Ore = self.state.Ore
    local OreName = self.state.OreName
    local TimeToMine = self.state.TimeToMine
    local MiningProgress = self.state.MiningProgress

    return Roact.createElement("ScreenGui", {
        ResetOnSpawn = false;
    }, {
        Container = Roact.createElement("Frame", {
            Size = UDim2.fromScale(0.244, 0.128);
            Position = UDim2.fromScale(0.5, 0.717);
            AnchorPoint = Vector2.new(0.5, 0);

            BorderSizePixel = 0;
            BackgroundTransparency = 1;
        }, {
            AspectRatio = Roact.createElement("UIAspectRatioConstraint", {
                AspectRatio = 4.46;
                AspectType = Enum.AspectType.FitWithinMaxSize;
                DominantAxis = Enum.DominantAxis.Width;
            }, {});

            OreName = Roact.createElement("TextLabel", {
                Size = UDim2.fromScale(0.871, 0.309);
                Position = UDim2.fromScale(0.072, 0.368);
                BackgroundTransparency = 1;
                BorderSizePixel = 0;

                Text = OreName or "No ore name?";
                TextScaled = true;
                TextStrokeTransparency = 0;
                TextColor3 = PlayerFolder.PickaxeSelection.Value:FindFirstChildWhichIsA("SelectionBox").Color3;
                FontFace = Core.UI.Theme.TextFont;
            }, {});

            TimeToMine = Roact.createElement("TextLabel", {
                Size = UDim2.fromScale(0.871, 0.222);
                Position = UDim2.fromScale(0.073, 0.168);
                BackgroundTransparency = 1;
                BorderSizePixel = 0;

                Text = TimeToMine or "No ttm string?";
                TextScaled = true;
                TextStrokeTransparency = 0;
                TextColor3 = PlayerFolder.PickaxeSelection.Value:FindFirstChildWhichIsA("SelectionBox").Color3;
                FontFace = Core.UI.Theme.TextFont;
            }, {});

            MiningProgressBar = Roact.createElement("Frame", {
                Size = UDim2.fromScale(0.9, 0.2);
                Position = UDim2.fromScale(0.047, 0.671);
                BackgroundColor3 = Core.UI.Color.White;
                BorderSizePixel = 0;
            }, {
                Gradient = Roact.createElement("UIGradient", {
                    Color = Ore:GetAttribute("MiningBarGradient");
                }, {});

                Stroke = Roact.createElement("UIStroke", {
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
                    Color = Core.UI.Color.Black;
                    Thickness = 2;
                }, {});

                Bar = Roact.createElement("Frame", {
                    Size = UDim2.fromScale(MiningProgress, 1);
                    Position = Core.UI.Position.TopRight;
                    AnchorPoint = Core.UI.AnchorPoint.TopRight;

                    BackgroundColor3 = Core.UI.Color.Black;
                    BorderSizePixel = 0;
                }, {})
            })
        })
    })
end

--[[ KNIT ]]--

function PickaxeSelectionController:KnitStart()
    PickaxeService = Knit.GetService("PickaxeService")
    LogService = Knit.GetService("LogService")

    local App
    local GUI

    PlayerFolder.PickaxeSelection:GetPropertyChangedSignal("Value"):Connect(function()
        if GUI then
            Roact.unmount(GUI)
        end

        local ObjectToMine = PlayerFolder.PickaxeSelection.Value
        if ObjectToMine == nil then return end

        local DisplayName = ObjectToMine:GetAttribute("DisplayName")
        local Health = ObjectToMine:GetAttribute("Health")
        local MaxHealth = ObjectToMine:GetAttribute("MaxHealth")
        local PercentageMined = math.ceil((1 - (Health / MaxHealth)) * 100)
        local MiningProgress = (Health / MaxHealth)
        local TimeToMine = CalculateTimeToMine(Health)

        App = Roact.createElement(PickaxeSelectionComponent, {
            Name = DisplayName;
            Health = Health;
            MaxHealth = MaxHealth;
            PercentageMined = PercentageMined;
            MiningProgress = MiningProgress;
            TimeToMine = TimeToMine;
            Ore = ObjectToMine
        })
        GUI = Roact.mount(App, Knit.Player.PlayerGui, "PickaxeSelection")
        LogService:Log("Mounted pickaxe selection GUI")
    end)
end

return PickaxeSelectionController
