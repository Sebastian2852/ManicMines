-- TEST CODE FROM: https://roblox.github.io/roact/guide/hello-roact/

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Packages.Roact)

local app = Roact.createElement("ScreenGui", {}, {
    HelloWorld= Roact.createElement("TextLabel", {
        Size = UDim2.new(0, 400, 0, 300);
        Text = "Hello World from Roact";
    })
})

Roact.mount(app, Players.LocalPlayer.PlayerGui)