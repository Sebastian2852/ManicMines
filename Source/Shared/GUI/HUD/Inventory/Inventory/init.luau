local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)
local Core = require(ReplicatedStorage.Game.Modules.Core)

local Inventory = Roact.Component:extend("Inventory")

local Ore = require(script.Ore)
local Capacity = require(script.Capacity)

function Inventory:init()
    local DataService = Knit.GetService("DataService")

    DataService:GetPlayerDataFolder():andThen(function(DataFolder :Core.DataFolder)
        for _, OreValue :IntValue in pairs(DataFolder.Inventory.Ores:GetChildren()) do
            OreValue:GetPropertyChangedSignal("Value"):Connect(function()
                self:setState(function(PreviousState)
                    PreviousState.Ores[OreValue.Name] = OreValue.Value
                    return PreviousState
                end)
            end)
        end
    end)

    self:setState({
        Ores = {}
    })
end

function Inventory:render()
    local Ores = self.state.Ores or {}

    local OreFames = {}
    OreFames["Layout"] = Roact.createElement("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical;
        SortOrder = Enum.SortOrder.Name;
    }, {});

    for OreName :string, Amount :number in pairs(Ores) do
        if Amount == 0 then continue end
        local RealOre = OreName ~= "Stone" and Core.Assets.Ores:FindFirstChild(OreName) :: BasePart or Core.Assets.Stone

        local DisplayName = RealOre:GetAttribute("DisplayName")
        local Emblem = RealOre:GetAttribute("EmblemImageID")
        local Background = RealOre:GetAttribute("InventoryBackgroundColor")

        OreFames[OreName] = Roact.createElement("Frame", {
            Size = UDim2.fromScale(1, 0.1);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
        }, {
            Roact.createElement(Ore, {
                OreName = DisplayName;
                Amount = Amount;
                Emblem = Emblem;
                Background = Background;
            }, {});
        })
    end

    return Roact.createElement("Frame", {
        Size = UDim2.fromScale(1, 1);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
    }, {
        OresContainer = Roact.createElement("ScrollingFrame", {
            Size = UDim2.fromScale(1, 1);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;

            ScrollBarThickness = 5;
            AutomaticCanvasSize = Enum.AutomaticSize.Y;
            ScrollingDirection = Enum.ScrollingDirection.Y;
            VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right;
            VerticalScrollBarInset = Enum.ScrollBarInset.Always;
        }, OreFames );

        CapacityContainer = Roact.createElement("Frame", {
            Size = UDim2.fromScale(0.8, 0.1);
            Position = UDim2.new(0, -10, 1, 0);
            AnchorPoint = Vector2.new(1, 1);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
        }, {
            Cap = Roact.createElement(Capacity, {}, {});
        });
    });
end

return Inventory