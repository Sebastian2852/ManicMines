local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Core = require(ReplicatedStorage.Game.Modules.Core)



local MainMenuController = Knit.CreateController { Name = "MainMenuController" }


local AssetsFolder = ReplicatedStorage.Assets.UI.MainMenu
local PlayerGUI = Knit.Player.PlayerGui

local DataService
local TextFilteringService
local LoadingService
local LogService

local Blur :BlurEffect
local MainScreenGui :ScreenGui
local MainFrame :Frame
local SlotFrameTemplate :Frame

local TitleScreen :Frame
local NewSlotFrame :Frame
local SlotSelectionFrame :Frame



--[[ PRIVATE ]]--

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
    LogService:Log("Starting slot creation for slot "..tostring(SlotID))
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

    NewSlotFrame.Actions.CancelButton.MouseButton1Click:Connect(function()
        NewSlotFrame.Visible = false
        TitleScreen.Visible = true
        SlotSelectionFrame.Visible = true
    end)

    NewSlotFrame.Actions.CreateButton.MouseButton1Click:Connect(function()
        local SlotInfo :Core.SaveSlotSettings = {
            Name = SlotCreation_CurrentName;
            Tutorial = false;
        }

        DataService:NewSlot(SlotCreation_CurrentSlotID, SlotInfo)
        LoadingService:StartLoading()
        local InTycoon = false
        MainMenuController:EnableAllUI()
        SlotSelectionFrame.Visible = false
        DataService:GetPlayerDataFolder():andThen(function(DataFolder)
            repeat
                task.wait(1)
            until DataFolder.InTycoon.Value
            InTycoon = true
        end)

        repeat
            task.wait(1)
        until InTycoon
        LoadingService:EndLoading()
    end)

    NewSlotFrame.NameInput.RandomiseName.MouseButton1Click:Connect(function()
        SetTycoonName(PickRandomTycoonName())
    end)

    LogService:Log("Setup slot creation")
end



--[[ PUBLIC ]]--

function MainMenuController:DisableAllUI()
    LogService:Log("Disabling all UI")
    MainScreenGui.Enabled = true
    PlayerGUI.HUD.Enabled = false
    PlayerGUI.Inventory.Enabled = false
end

function MainMenuController:EnableAllUI()
    LogService:Log("Enabling all UI")
    MainScreenGui:Destroy()
    Blur:Destroy()
    LogService:Log("Destroyed main menu and blur")
    PlayerGUI.HUD.Enabled = true
    PlayerGUI.Inventory.Enabled = true
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
        New.TycoonName.Text = tostring(SlotInfo.TycoonName)
        New.Info.GoldAmount.TextLabel.Text = Core.Util:ConvertNumberToString(SlotInfo.Gold or 0)

        local TimeNow = os.time()
        local TimeDifference = TimeNow - (SlotInfo.LastPlayed or 0)
        local TimeText = Core.Util:TimeAgo(TimeDifference)

        New.Info.LastPlayed.TextLabel.Text = TimeText
        New:AddTag("_UsedSlot")

        New.Actions.PlayButton.MouseButton1Click:Connect(function()
            LoadingService:StartLoading()
            DataService:LoadData(tonumber(New.Name))
            local InTycoon = false
            self:EnableAllUI()
            SlotSelectionFrame.Visible = false
            DataService:GetPlayerDataFolder():andThen(function(DataFolder)
                repeat
                    task.wait(1)
                until DataFolder.InTycoon.Value
                InTycoon = true
            end)

            repeat
                task.wait(1)
            until InTycoon
            LoadingService:EndLoading()
        end)

        LogService:Log("    - Setup play button")

        New.Actions.DeleteButton.MouseButton1Click:Connect(function()
            New.SlotDelete.Visible = not New.SlotDelete.Visible
        end)

        New.SlotDelete.Delete.MouseButton1Click:Connect(function()
            for _, SlotFrame :Frame in pairs(SlotSelectionFrame.Slots:GetChildren()) do
                if SlotFrame:IsA("Frame") then SlotFrame:Destroy() end
            end

            SlotSelectionFrame.Slots.LoadingText.Visible = true
            DataService:DeleteSlot(tonumber(New.Name))
            SlotSelectionFrame.Slots.LoadingText.Text = "Loading ."
            task.wait(0.25)
            SlotSelectionFrame.Slots.LoadingText.Text = "Loading .."
            task.wait(0.25)
            SlotSelectionFrame.Slots.LoadingText.Text = "Loading ..."
            task.wait(0.25)
            SlotSelectionFrame.Slots.LoadingText.Visible = false

            self:CreateSlotFrames()
        end)

        New.SlotDelete.Cancel.MouseButton1Click:Connect(function()
            New.SlotDelete.Visible = false
        end)

        LogService:Log("    - Setup delete button")
    else
        New.TycoonName.Text = "Empty Slot"
        New.Info.Visible = false
        New.Actions.DeleteButton.Visible = false
        New.Actions.PlayButton.Text = "Create Slot"
        New:AddTag("_NewSlot")

        New.Actions.PlayButton.MouseButton1Click:Connect(function()
            BeginSlotCreation(tonumber(New.Name))
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

function MainMenuController:KnitInit()
    LogService = Knit.GetService("LogService")

    SlotFrameTemplate = AssetsFolder.SaveSlot

    MainScreenGui = AssetsFolder.MainMenu:Clone()
    MainScreenGui.Parent = Knit.Player.PlayerGui

    MainFrame = MainScreenGui.Main
    TitleScreen = MainFrame.TitleScreen
    NewSlotFrame = MainFrame.CreateNewSlot
    SlotSelectionFrame = MainFrame.SlotSelector

    Blur = Instance.new("BlurEffect")
    Blur.Size = 10
    Blur.Parent = game.Lighting
    Blur.Name = "_MainMenuBlur"
    LogService:Log("Created blur")

    SetupNewSlotFrame()
end

function MainMenuController:KnitStart()
    DataService = Knit.GetService("DataService")
    TextFilteringService = Knit.GetService("TextFilteringService")
    LoadingService = Knit.GetService("LoadingService")

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

return MainMenuController