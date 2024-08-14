local ReplicatedStorage = game.ReplicatedStorage
local Knit = require(ReplicatedStorage.Packages.Knit)
local Util = require(ReplicatedStorage.Shared.Modules.Util)

local AssetsFolder = ReplicatedStorage.Assets.UI.MainMenu
local PlayerGUI = Knit.Player.PlayerGui

local DataService

local MainMenuController = Knit.CreateController { Name = "MainMenuController" }

local Blur :BlurEffect
local MainScreenGui :ScreenGui
local MainFrame :Frame
local SlotFrameTemplate :Frame

local TitleScreen :Frame
local NewSlotFrame :Frame
local CreditsFrame :Frame
local SlotSelectionFrame :Frame

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

function MainMenuController:CreateSlotFrame(SlotInfo)
    local New = SlotFrameTemplate:Clone()

    if SlotInfo.Used then
        New.TycoonName.Text = SlotInfo.TycoonName
        New.Info.GoldAmount.TextLabel.Text = Util:ConvertNumberToString(SlotInfo.Gold or 0)

        local TimeNow = os.time()
        local TimeDifference = TimeNow - SlotInfo.LastPlayed
        local TimeText = "N/A"

        if TimeDifference < 60 then
            TimeText = TimeDifference .. " seconds ago"
        elseif TimeDifference < 3600 then
            TimeText = math.floor(TimeDifference / 60) .. " minutes ago"
        elseif TimeDifference < 86400 then
            TimeText = math.floor(TimeDifference / 3600) .. " hours ago"
        else
            TimeText = math.floor(TimeDifference / 86400) .. " days ago"
        end

        New.Info.LastPlayed.TextLabel.Text = TimeText
        New:AddTag("UsedSlot")
    else
        New.TycoonName.Text = "Empty Slot"
        New.Info.Visible = false
        New.Actions.DeleteButton.Visible = false
        New.Actions.PlayButton.Text = "Create Slot"
        New:AddTag("NewSlot")
    end

    New.Parent = SlotSelectionFrame.Slots
    New.Name = SlotInfo.SlotID
    New.LayoutOrder = SlotInfo.SlotID
end

function MainMenuController:CreateSlotFrames()
    DataService:GetSlotsInfo():andThen(function(SlotsInfo)
        for _, SlotFrame :Frame in pairs(SlotSelectionFrame.Slots:GetChildren()) do
            if SlotFrame:IsA("Frame") then SlotFrame:Destroy() end
        end

        for _, Slot in pairs(SlotsInfo) do
            self:CreateSlotFrame(Slot)
        end
    end)
end

--[[ KNIT ]]--

function MainMenuController:KnitStart()
    DataService = Knit.GetService("DataService")
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

    self:CreateSlotFrames()
end

function MainMenuController:KnitInit()
    SlotFrameTemplate = AssetsFolder.SaveSlot

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
