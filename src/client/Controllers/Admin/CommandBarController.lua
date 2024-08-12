local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game.ReplicatedStorage
local Knit = require(ReplicatedStorage.Packages.Knit)

local AdminService

local CommandBarController = Knit.CreateController { Name = "CommandBarController" }

--[[ INTERNAL ]]

local function CreateCommandBarUI()
    local CommandBarScreenGui = Instance.new("ScreenGui")
    CommandBarScreenGui.Name = "CommandBar"
    CommandBarScreenGui.IgnoreGuiInset = true
    CommandBarScreenGui.ResetOnSpawn = false
    CommandBarScreenGui.DisplayOrder = 150
    CommandBarScreenGui.Parent = Knit.Player.PlayerGui

    local InputBox = Instance.new("TextBox")
    InputBox.ClearTextOnFocus = false
    InputBox.AnchorPoint = Vector2.new(0.5, 0.5)
    InputBox.Position = UDim2.fromScale(0.5, 0.5)
    InputBox.Size = UDim2.fromScale(1, 0.025)
    InputBox.PlaceholderText = "Enter command here"
    InputBox.Text = ""
    InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    InputBox.BackgroundColor3 = Color3.new(0, 0, 0)
    InputBox.BackgroundTransparency = 0.2
    InputBox.Parent = CommandBarScreenGui

    CommandBarScreenGui.Enabled = false

    InputBox.FocusLost:Connect(function(EnterPressed, InputThatCausedFocusLoss)
        if not EnterPressed then return end

    end)

    UserInputService.InputBegan:Connect(function(Input, ProcessedEvent)
        if ProcessedEvent then return end
        if Input.KeyCode == Enum.KeyCode.Quote then
            CommandBarScreenGui.Enabled = not CommandBarScreenGui.Enabled
        end
    end)
end

--[[ KNIT ]]--

function CommandBarController:KnitInit()
   AdminService = Knit.GetService("AdminService")

   AdminService:IsPlayerAdmin():andThen(function(IsAdmin :boolean)
        if not IsAdmin then return end
        CreateCommandBarUI()
   end)
end


return CommandBarController
