local ReplicatedStorage = game.ReplicatedStorage
local Knit = require(ReplicatedStorage.Packages.Knit)
local Util = require(ReplicatedStorage.Game.Modules.Util)
local Core = require(ReplicatedStorage.Game.Modules.Core)

local AssetsFolder = ReplicatedStorage.Assets.UI.MainMenu
local PlayerGUI = Knit.Player.PlayerGui


local MainMenuController = Knit.CreateController { Name = "MainMenuController" }

--[[ VARIABLES ]]--

local DataService
local TextFilteringService
local FadeController
local LogService

local Blur :BlurEffect
local MainScreenGui :ScreenGui
local MainFrame :Frame
local SlotFrameTemplate :Frame

local TitleScreen :Frame
local NewSlotFrame :Frame
local CreditsFrame :Frame
local SlotSelectionFrame :Frame



--[[ INTERNAL ]]--

local SlotCreation_CurrentName = ""
local SlotCreation_CurrentSlotID = 0

local function IsNameValidLength(Name :string) :boolean
    local MaxCharacters = Core.GameConfig.Tycoon.MaxNameCharacters

    if #Name > MaxCharacters then return false end
    return true
end

local function PickRandomTycoonName() :string
    local RandomNames = Core.GameConfig.Tycoon.RandomName

    local RandomAdjective = RandomNames.Adjectives[math.random(1, #RandomNames.Adjectives)]
    local RandomNoun = RandomNames.Nouns[math.random(1, #RandomNames.Nouns)]
    local Prefix = RandomNames.Prefix
    local Name = Prefix.." "..RandomAdjective.." "..RandomNoun

    if IsNameValidLength(Name) then return Name end

    -- Probs not the best but it works
    repeat
        RandomAdjective = RandomNames.Adjectives[math.random(1, #RandomNames.Adjectives)]
        RandomNoun = RandomNames.Nouns[math.random(1, #RandomNames.Nouns)]
        Prefix = RandomNames.Prefix
        Name = Prefix.." "..RandomAdjective.." "..RandomNoun
    until IsNameValidLength(Name)

    return Name
end

local function SetTycoonName(Name :string)
    TextFilteringService:FilterTextFromUserToEveryone(Name):andThen(function(Text)
        SlotCreation_CurrentName = Text
        NewSlotFrame.NameInput.Input.Text = Text
        NewSlotFrame.NameInput.Input.PlaceholderText = Text
        NewSlotFrame.Title.Text = "New Slot - "..Text
        LogService:Log("Set tycoon name:", Text)
    end)
end

local function BeginSlotCreation(SlotID :number)
    LogService:Log("Starting slot creation")
    SetTycoonName(PickRandomTycoonName())
    SlotCreation_CurrentSlotID = SlotID
    TitleScreen.Visible = false
    SlotSelectionFrame.Visible = false
    NewSlotFrame.Visible = true
end

local function SetupNewSlotFrame()
    NewSlotFrame.NameInput.SubmitButton.MouseButton1Click:Connect(function()
        SetTycoonName(NewSlotFrame.NameInput.Input.Text)
    end)
    LogService:Log("Setup slot creation")
end



--[[ FUNCTIONS ]]--

function MainMenuController:DisableAllUI()
    LogService:Log("Disabling all UI")
    MainScreenGui.Enabled = true
    PlayerGUI.HUD.Enabled = false
    PlayerGUI.Inventory.Enabled = false
    --PlayerGUI.Selection.Enabled = false
end

function MainMenuController:EnableAllUI()
    LogService:Log("Enabling all UI")
    MainScreenGui:Destroy()
    Blur:Destroy()
    LogService:Log("Destroyed main menu and blur")
    PlayerGUI.HUD.Enabled = true
    PlayerGUI.Inventory.Enabled = true
    --PlayerGUI.Selection.Enabled = true
end

function MainMenuController:CreateSlotFrame(SlotInfo)
    LogService:Log("Creating slot frame")
    local New = SlotFrameTemplate:Clone()

    New.Parent = SlotSelectionFrame.Slots
    New.Name = SlotInfo.SlotID
    New.LayoutOrder = SlotInfo.SlotID
    LogService:Log("    - ID:", SlotInfo.SlotID)
    LogService:Log("    - Used:", SlotInfo.Used)

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
        New:AddTag("_UsedSlot")

        New.Actions.PlayButton.MouseButton1Click:Connect(function()
            FadeController:FadeGameplayOut(true)
            DataService:LoadData(New.Name)
            local InTycoon = false
            self:EnableAllUI()
            SlotSelectionFrame.Visible = false
            local DataFolder = DataService:GetPlayerDataFolder():andThen(function(DataFolder)
                repeat
                    task.wait(1)
                until DataFolder.InTycoon.Value
                InTycoon = true
            end)

            repeat
                task.wait(1)
            until InTycoon
            FadeController:FadeGameplayIn(false)
        end)

        LogService:Log("    - Setup play button")
    else
        New.TycoonName.Text = "Empty Slot"
        New.Info.Visible = false
        New.Actions.DeleteButton.Visible = false
        New.Actions.PlayButton.Text = "Create Slot"
        New:AddTag("_NewSlot")

        New.Actions.PlayButton.MouseButton1Click:Connect(function()
            BeginSlotCreation(New.Name)
        end)
        LogService:Log("    - Setup setup slot button")
    end
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
    TextFilteringService = Knit.GetService("TextFilteringService")
    FadeController = Knit.GetController("FadeController")

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

    TitleScreen.LeftSide.Buttons.PlayButton.MouseButton1Click:Connect(function()
        MainFrame.Credits.Visible = false
        SlotSelectionFrame.Visible = not SlotSelectionFrame.Visible
    end)

    TitleScreen.LeftSide.Buttons.CreditsButton.MouseButton1Click:Connect(function()
        MainFrame.Credits.Visible = not MainFrame.Credits.Visible
        SlotSelectionFrame.Visible = false
    end)

    TitleScreen.LeftSide.Buttons.QuitButton.MouseButton1Click:Connect(function()
        Knit.Player:Kick("Left the game!")
    end)

    self:CreateSlotFrames()
end

function MainMenuController:KnitInit()
    LogService = Knit.GetService("LogService")

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
    LogService:Log("Created blur")

    SetupNewSlotFrame()
end


return MainMenuController
