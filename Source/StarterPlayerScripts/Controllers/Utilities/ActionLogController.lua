local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local ActionLogController = Knit.CreateController { Name = "ActionLogController" }

local LogService

--[[ PRIVATE ]]--

local function NewLog(Color :Color3, Parent :Frame, ...)
    local Messages = {...}
    local Text = ""

    for _, msg in pairs(Messages) do
        Text = Text.." "..tostring(msg)
    end

    local New = Instance.new("TextLabel")
    New.Text = Text
    New.TextColor3 = Color
    New.BackgroundTransparency = 1
    New.Size = UDim2.new(1, 0, 0.05, 0)
    New.TextSize = 16
    New.TextXAlignment = Enum.TextXAlignment.Left
    New.Parent = Parent

    task.wait(5)
    New:Destroy()
end



--[[ KNIT ]]--

function ActionLogController:KnitInit()
    local NewGUI = Instance.new("ScreenGui")
    NewGUI.Name = "_ActionLog"
    NewGUI.Parent = Knit.Player.PlayerGui
    NewGUI.DisplayOrder = 100
    NewGUI.IgnoreGuiInset = true

    local Frame = Instance.new("Frame")
    Frame.Name = "_MainFrame"
    Frame.Size = UDim2.new(0.3, 0, 1, 0)
    Frame.BackgroundTransparency = 1
    Frame.Parent = NewGUI

    local UiListLayout = Instance.new("UIListLayout")
    UiListLayout.Parent = Frame
    UiListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom

    LogService = Knit.GetService("LogService")
    LogService.ActionLog:Connect(function(Color :Color3, ...)
        local Args = {...}
        NewLog(Color, Frame, table.unpack(Args))
    end)
end


return ActionLogController
