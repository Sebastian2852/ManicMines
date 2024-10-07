-- This module describes how UI should look by default, as well as functions for creating common components. Having it all in this one module
-- will make it easier to edit all the ui at once.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UI = {}

local Roact = require(ReplicatedStorage.Packages.Roact)

UI.Theme = {
    BackgroundColor = Color3.new(0, 0, 0);
    BackgroundColorTransparency = 0.5;

    TextColor3 = Color3.new(1, 1, 1);
    TextFont = Font.fromEnum(Enum.Font.Highway);
    TextStrokeTransparency = 0;

    TextColorDisabled = Color3.new(0.278431, 0.278431, 0.278431);
}

--[=[
Rerender a given component
]=]
function UI:Rerender(Component :Roact.Component)
    Component:setState(function(Previous)
        return { Refresh = not Previous.Refresh }
    end)
end

return UI