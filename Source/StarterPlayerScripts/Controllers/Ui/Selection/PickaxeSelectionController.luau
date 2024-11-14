local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)
local Core = require(ReplicatedStorage.Game.Modules.Core)

local PickaxeSelectionController = Knit.CreateController { Name = "PickaxeSelectionController" }

local PlayerFolder = ReplicatedStorage.Player

local PickaxeService
local LogService

-- [[ GUI ]] --

local PickaxeSelectionComponent = Roact.Component:extend("PickaxeSelection")

function PickaxeSelectionComponent:init()
    self:setState({
        Show = false;
        OreName = "No ore name?";
        TimeToMine = "No ttm string?";
        MiningProgress = 0;
    })

    PickaxeService.UpdateMiningSelection:Connect(function(OreName :string, TimeToMine :number, Percentage :number, MiningProgress :number)
        local RealOre = Core.Util:GetOreByName(OreName)
        if not RealOre then return end

        self:setState({
            Show = true;
            Ore = RealOre;
            OreName = RealOre:GetAttribute("DisplayName");
            TimeToMine = TimeToMine.."s - "..Percentage.."%";
            MiningProgress = MiningProgress;
        })
    end)

    PlayerFolder.PickaxeSelection:GetPropertyChangedSignal("Value"):Connect(function()
        local ObjectToMine :BasePart = PlayerFolder.PickaxeSelection.Value

        if not ObjectToMine or not ObjectToMine:IsDescendantOf(Workspace.Game.Mine) or not ObjectToMine:IsA("BasePart") then
            self:setState({
                Show = false;
            })
            return
        end

        local RealOre = Core.Util:GetOreByName(ObjectToMine.Name)
        if not RealOre then return end

        local Health = ObjectToMine:GetAttribute("Health")
        local MaxHealth = ObjectToMine:GetAttribute("MaxHealth")
        local Percentage = math.ceil((1 - (Health / MaxHealth)) * 100)
        PickaxeService:CalculateTimeToMine(Health):andThen(function(TimeToMine)
            self:setState({
                Show = true;
                Ore = RealOre;
                OreName = ObjectToMine:GetAttribute("DisplayName");
                TimeToMine = TimeToMine.."s - "..Percentage.."%";
                MiningProgress = (Health / MaxHealth);
            })
        end)
    end)
end

function PickaxeSelectionComponent:render()
    return Roact.createElement("ScreenGui", {
        ResetOnSpawn = false;
    }, {
        Container = self.state.Show and Roact.createElement("Frame", {
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

                Text = self.state.OreName or "No ore name?";
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

                Text = self.state.TimeToMine or "No ttm string?";
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
                    Color = self.state.Ore:GetAttribute("MiningBarGradient");
                }, {});

                Stroke = Roact.createElement("UIStroke", {
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
                    Color = Core.UI.Color.Black;
                    Thickness = 2;
                }, {});

                Bar = Roact.createElement("Frame", {
                    Size = UDim2.fromScale(self.state.MiningProgress, 1);
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

    local App = Roact.createElement(PickaxeSelectionComponent)
    Roact.mount(App, Knit.Player.PlayerGui, "PickaxeSelection")
    LogService:Log("Mounted pickaxe selection GUI")
end

return PickaxeSelectionController
