local RarityEditor = {}

local Roact = require(script.Parent.Parent.External.Roact)

function RarityEditor:CreatePluginButton(plugin :Plugin, Toolbar :PluginToolbar) :PluginToolbarButton
    local MyButton = Toolbar:CreateButton("Rarity Editor", "Edit rarity of all ores at once!", "rbxassetid://74012825822948")
    local DockWidgetInfo = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, false, 800, 800, 800, 800)
    local Widget = plugin:CreateDockWidgetPluginGui("RarityEditor", DockWidgetInfo)
    Widget.Title = "Manic Mines: Rarity Editor"

    local EditorGuiComponent = require(script.Gui)
    local Gui = Roact.createElement(EditorGuiComponent, {}, {})
    local Tree = Roact.mount(Gui, Widget, "Editor")

    MyButton.Click:Connect(function()
        Widget.Enabled = not Widget.Enabled
    end)

    plugin.Unloading:Connect(function()
        Roact.unmount(Tree)
    end)

    return MyButton
end

return RarityEditor