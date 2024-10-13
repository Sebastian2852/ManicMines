local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Knit = require(ReplicatedStorage.Packages.Knit)

local PickaxeSelectionController = Knit.CreateController { Name = "PickaxeSelectionController" }

local Player = Knit.Player
local PlayerFolder = ReplicatedStorage.Player

local PickaxeService

local MiningSelection = Player.PlayerGui.HUD.MiningSelection

-- [[ PUBLIC ]] --

function PickaxeSelectionController:UpdateInfo(OreName :string, TimeToMine :number, Percentage :number, MiningProgress :number)
    if not PlayerFolder.PickaxeSelection.Value then
        MiningSelection.Visible = false
        return
    end

    local RealOre = ReplicatedStorage.Assets.Ores:FindFirstChild(OreName)
    if OreName == "Stone" then
        RealOre = ReplicatedStorage.Assets.Stone
    end
    if not RealOre then
        MiningSelection.TimeToMine.Text = ""
        MiningSelection.OreName.Text = OreName
        MiningSelection.OreName.TextColor3 = Color3.new(1, 0, 0)
        return
    end

    MiningSelection.Visible = true
    MiningSelection.OreName.Text = RealOre:GetAttribute("DisplayName")
    MiningSelection.OreName.TextColor3 = PlayerFolder.PickaxeSelection.Value:FindFirstChildWhichIsA("SelectionBox").Color3

    MiningSelection.MiningProgressBar.UIGradient.Color = RealOre:GetAttribute("MiningBarGradient")
    MiningSelection.MiningProgressBar.Bar.Size = UDim2.new(MiningProgress, 0, 1, 0)

    MiningSelection.TimeToMine.Text = TimeToMine.."s - "..Percentage.."%"
    MiningSelection.TimeToMine.TextColor3 = RealOre:GetAttribute("SelectionColor")
end

PlayerFolder.PickaxeSelection:GetPropertyChangedSignal("Value"):Connect(function()
    local ObjectToMine :BasePart = PlayerFolder.PickaxeSelection.Value

    if not ObjectToMine or not ObjectToMine:IsDescendantOf(Workspace.Game.Mine) or not ObjectToMine:IsA("BasePart") then
        MiningSelection.Visible = false
        return
    end

    MiningSelection.Visible = true
    local Health = ObjectToMine:GetAttribute("Health")
    PickaxeService:CalculateTimeToMine(Health):andThen(function(TimeToMine)
        PickaxeSelectionController:UpdateInfo(ObjectToMine.Name, TimeToMine, math.ceil((1 - (Health / ObjectToMine:GetAttribute("MaxHealth"))) * 100), (Health / ObjectToMine:GetAttribute("MaxHealth")))
    end)
end)



--[[ KNIT ]]--

function PickaxeSelectionController:KnitStart()
    PickaxeService = Knit.GetService("PickaxeService")

    PickaxeService.UpdateMiningSelection:Connect(function(OreName :string, TimeToMine :number, Percentage :number, MiningProgress :number)
        PickaxeSelectionController:UpdateInfo(OreName, TimeToMine, Percentage, MiningProgress)
    end)
end

return PickaxeSelectionController
