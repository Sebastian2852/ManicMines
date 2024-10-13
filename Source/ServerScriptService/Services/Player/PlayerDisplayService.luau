local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Core = require(ReplicatedStorage.Game.Modules.Core)

local PlayerDisplayService = Knit.CreateService {
    Name = "PlayerDisplayService",
    Client = {},
}

local DataService
local LogService

local OverheadGUI = ReplicatedStorage.Assets.UI.Billboards.OverheadGUI

local function GiveChracterGUI(Character :Model, DisplayName :string, Username :string, LevelName :string, LevelColor :Color3, ExtraTag :string?)
    local NewGUI :BillboardGui = OverheadGUI:Clone()
    NewGUI.Main.DisplayName.Text = DisplayName
    NewGUI.Main.Username.Text = Username
    NewGUI.Main.LevelName.Text = LevelName
    NewGUI.Main.LevelName.TextColor3 = LevelColor
    NewGUI.PlayerToHideFrom = game.Players:GetPlayerFromCharacter(Character)

    if ExtraTag ~= nil and type(ExtraTag) == "string" then
        -- TEMP
        -- Later on add a text label for the extra tag
        NewGUI.Main.Username.Text = Username.."; "..ExtraTag
    end

    NewGUI.Parent = Character:WaitForChild("Head")
end

function PlayerDisplayService:GivePlayerOverheadGUI(Player :Player, ExtraTag :string?)
    LogService:Log("Giving "..Player.Name.." an overhead GUI")
    local DisplayName = Player.DisplayName
    local Username = "(@"..Player.Name..")"
    local LevelName = ""

    local DataFolder :Core.DataFolder = DataService:GetPlayerDataFolder(Player)
    if DataFolder == nil then
        LogService:Warn("Player doesnt have a data folder")
        return
    end

    local LevelConfigNumber = DataFolder.Level.Value
    local LevelConfig = ReplicatedStorage.Assets.Levels:FindFirstChild(LevelConfigNumber)
    if not LevelConfig then
        LogService:Warn("Invalid level number ("..LevelConfigNumber..")")
        return
    end
    LevelName = LevelConfig:GetAttribute("LevelName")

    GiveChracterGUI(Player.Character, DisplayName, Username, LevelName, LevelConfig:GetAttribute("LevelColor"), ExtraTag)
end

function PlayerDisplayService:KnitStart()
    DataService = Knit.GetService("DataService")
    LogService  = Knit.GetService("LogService")
end


return PlayerDisplayService
