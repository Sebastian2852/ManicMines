local Gui = {}

local Roact = require(script.Parent.External.Roact)
local Tree :Roact.Tree = nil

-- [[ GUI ]] --

local PluginGui = Roact.Component:extend("ManicMinesPlugin")

function PluginGui:render()
    print("Rendering GUI")
    return Roact.createElement("Frame", {
        Size = UDim2.fromScale(1, 1);
        BackgroundTransparency = 1;
    }, {
        Roact.createElement("TextLabel", {
            Size = UDim2.fromScale(1, 1);
            Text = "EPIC MANIC MINES PLUGIN";
        }, {})
    })
end



-- [[ PUBLIC ]] --

function Gui:CreateGui(MountPlace :Instance)
    print("Creating GUI")
    if Tree ~= nil then return end

    local App = Roact.createElement(PluginGui)
    Tree = Roact.mount(App, MountPlace, "Plugin")
end

function Gui:DestroyGui()
    print("Destroying GUI")
    if Tree == nil then return end
    Roact.unmount(Tree)
end

return Gui