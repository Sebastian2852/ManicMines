local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)
local Core = require(ReplicatedStorage.Game.Modules.Core)

local MainMenuController = Knit.CreateController { Name = "MainMenuController" }

local DataService
local LogService
local TextFilteringService
local HotbarController

local Blur
local MainMenuTree

-- [[ PUBLIC ]] --

function MainMenuController:PickRandomName() :string
    local Name = Core.GameConfig.Tycoon.RandomName.Prefix

    local Adjectives = Core.GameConfig.Tycoon.RandomName.Adjectives
    local Nouns = Core.GameConfig.Tycoon.RandomName.Nouns

    local RandomAdjective = Adjectives[math.random(1, #Adjectives)]
    local RandomNoun = Nouns[math.random(1, #Nouns)]

    Name = Name.." "..RandomAdjective.." "..RandomNoun
    return Name
end

function MainMenuController:FilterName(Name :string) :string
    local Result = nil

    TextFilteringService:FilterTextFromUserToEveryone(Name):andThen(function(FilterResult)
        Result = FilterResult
    end)

    repeat
        task.wait(0.01)
    until Result ~= nil

    return Result
end

function MainMenuController:DeleteSlot(SlotNumber :number)
    DataService:DeleteSlot(SlotNumber):await()
end

function MainMenuController:LoadSlot(SlotNumber :number)
    DataService:LoadData(SlotNumber)
    self:Close()
end

function MainMenuController:CreateSlotSettings(Name :string) :Core.SaveSlotSettings
    local Settings :Core.SaveSlotSettings = {}

    Settings.Name = Name
    Settings.Tutorial = false

    return Settings
end

function MainMenuController:CreateSlot(SlotNumber :number, SlotSettings :Core.SaveSlotSettings)
    DataService:NewSlot(SlotNumber, SlotSettings)
    self:Close()
end

function MainMenuController:Close()
    if Blur then
        Blur:Destroy()
    end

    if MainMenuTree then
        Roact.unmount(MainMenuTree)
    end

    LogService:Log("Closed main menu")
end



-- [[ KNIT ]] --

function MainMenuController:KnitStart()
    DataService = Knit.GetService("DataService")
    TextFilteringService = Knit.GetService("TextFilteringService")
    LogService = Knit.GetService("LogService")
    HotbarController = Knit.GetController("HotbarController")

    local LightingController = Knit.GetController("LightingController")

    local MainMenu = require(ReplicatedStorage.Game.GUI.MainMenu)
    local App = Roact.createElement(MainMenu)
    MainMenuTree = Roact.mount(App, Knit.Player.PlayerGui, "MainMenu")
    LogService:Log("Mounted main menu")

    Blur = Instance.new("BlurEffect")
    Blur.Name = "MainMenuBlur"
    Blur.Size = 15
    Blur.Enabled = true

    HotbarController:DisableHotbar(false)
    Blur = LightingController:AddPersistentObject(Blur)
end

return MainMenuController