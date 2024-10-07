-- TEST CODE FROM: https://roblox.github.io/roact/guide/hello-roact/

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)
local Core = require(ReplicatedStorage.Game.Modules.Core)

local app = Roact.createElement("ScreenGui", {}, {
    HelloWorld= Roact.createElement("TextLabel", {
        Size = UDim2.fromScale(0.5, 0.5);
        AnchorPoint = Vector2.new(0.5, 0.5);
        Position = UDim2.fromScale(0.5, 0.5);
        Text = "Hello World from Roact";
        TextScaled = true;

        FontFace = Core.UI.Theme.TextFont;
        TextColor3 = Core.UI.Theme.TextColor3;
        TextStrokeTransparency = Core.UI.Theme.TextStrokeTransparency;
        BackgroundColor3 = Core.UI.Theme.BackgroundColor;
        BackgroundTransparency = Core.UI.Theme.BackgroundColorTransparency;
    })
})

Roact.mount(app, Players.LocalPlayer.PlayerGui)