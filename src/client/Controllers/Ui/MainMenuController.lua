local ReplicatedStorage = game.ReplicatedStorage
local Knit = require(ReplicatedStorage.Packages.Knit)

local AssetsFolder = ReplicatedStorage.Assets.UI.MainMenu
local PlayerGUI = Knit.Player.PlayerGui

local MainMenuController = Knit.CreateController { Name = "MainMenuController" }

local Blur
local MainScreenGui
local MainFrame

local TitleScreen
local NewSlotFrame
local CreditsFrame
local SlotSelectionFrame

function MainMenuController:DisableAllUI()
    PlayerGUI.HUD.Enabled = false
    PlayerGUI.Inventory.Enabled = false
    --PlayerGUI.Selection.Enabled = false
end

function MainMenuController:EnableAllUI()
    PlayerGUI.HUD.Enabled = true
    PlayerGUI.Inventory.Enabled = true
    --PlayerGUI.Selection.Enabled = true
end

function MainMenuController:CreateSlotFrames()
    
end

--[[ KNIT ]]--

function MainMenuController:KnitStart()
    self:DisableAllUI()

    for _, Button :TextButton in pairs(TitleScreen.LeftSide.Buttons:GetChildren()) do
        if not Button:IsA("TextButton") then continue end

        local OriginalText = Button.Text
        local BoldText = "<b>"..Button.Text.."</b>"

        Button.MouseEnter:Connect(function()
            Button.Text = BoldText
        end)

        Button.MouseLeave:Connect(function()
            Button.Text = OriginalText
        end)
    end
end

function MainMenuController:KnitInit()
    MainScreenGui = AssetsFolder.MainMenu:Clone()
    MainScreenGui.Parent = Knit.Player.PlayerGui

    MainFrame = MainScreenGui.Main
    TitleScreen = MainFrame.TitleScreen
    NewSlotFrame = MainFrame.CreateNewSlot
    CreditsFrame = MainFrame.Credits
    SlotSelectionFrame = MainFrame.SlotSelector

    Blur = Instance.new("BlurEffect")
    Blur.Size = 10
    Blur.Parent = game.Lighting
    Blur.Name = "_MainMenuBlur"
end


return MainMenuController
