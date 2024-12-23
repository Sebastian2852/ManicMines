local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)
local Core = require(ReplicatedStorage.Game.Modules.Core)

local Inventory = Roact.Component:extend("Inventory")

local Ore = require(script.Ore)

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
        local RealOre = OreName ~= "Stone" and Core.Assets.Ores:FindFirstChild(OreName) :: BasePart or Core.Assets.Stone

        local DisplayName = RealOre:GetAttribute("DisplayName")
        local Emblem = RealOre:GetAttribute("EmblemImageID")
        local Background = RealOre:GetAttribute("InventoryBackgroundColor")

        OreFames[OreName] = Roact.createElement(Ore, {
            OreName = DisplayName;
            Amount = Amount;
            Emblem = Emblem;
            Background = Background;
        }, {});
    end

    return Roact.createElement("Frame", {
        Size = UDim2.fromScale(1, 1);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
    }, {
        Container = Roact.createElement("Frame", {
            Size = UDim2.fromScale(1, 0.1);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
        }, OreFames );
    });
end

return Inventory