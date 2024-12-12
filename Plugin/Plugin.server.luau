local Gui = require(script.Parent.Gui)

local Toolbar = plugin:CreateToolbar("Manic Mines")
local Main = Toolbar:CreateButton("Dev", "Manic mines development plugin", "rbxassetid://74012825822948")
Main.ClickableWhenViewportHidden = false

local DockWidgetInfo = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Left, false, false, 300, 800, 250, 750)
local PluginWidget = plugin:CreateDockWidgetPluginGui("Manic Mines Dev", DockWidgetInfo)
PluginWidget.Title = "Manic Mines Development Plugin"
local Open = false

Main.Click:Connect(function()
    print("Clicked button")
    if Open then
        Gui:DestroyGui()
        Open = false
        PluginWidget.Enabled = false
    else
        PluginWidget.Enabled = true
        Open = true
        Gui:CreateGui(PluginWidget)
    end
end)