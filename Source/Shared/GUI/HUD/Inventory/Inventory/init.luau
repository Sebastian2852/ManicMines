local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)

local Inventory = Roact.Component:extend("Inventory")

local Ore = require(script.Ore)

function Inventory:render()
    return Roact.createElement("Frame", {
        Size = UDim2.fromScale(1, 1);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
    }, {
        Container = Roact.createElement("Frame", {
            Size = UDim2.fromScale(1, 0.1);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
        }, {
            TestOre = Roact.createElement(Ore, {
                OreName = "Test Ore";
                Amount = 15;
            }, {});
        });
    });
end

return Inventory