local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)

local HUD = Roact.Component:extend("HUD")

local Inventory = require(script.Inventory)

function HUD:render()
    return Roact.createElement("ScreenGui", {
        ResetOnSpawn = false;
    }, {
        App = Roact.createElement("Frame", {
            Size = UDim2.fromScale(1, 1);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
        }, {
            Inventory = Roact.createElement("Frame", {
                Size = UDim2.fromScale(1, 1);
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
            }, {
                Container = Roact.createElement("Frame", {
                    Size = UDim2.fromScale(0.14, 0.6);
                    Position = UDim2.fromScale(1, 1);
                    AnchorPoint = Vector2.new(1, 1);
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;
                }, {
                    Inventory = Roact.createElement(Inventory, {}, {});
                });
            });
        });
    });
end

return HUD