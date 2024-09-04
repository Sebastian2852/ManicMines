local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local PickaxeSelectionController = Knit.CreateController { Name = "PickaxeSelectionController" }

local Player = Knit.Player
local PlayerFolder = ReplicatedStorage.Player

local TweenService = game:GetService("TweenService")
local PickaxeService

local MiningSelection = Player.PlayerGui.HUD.MiningSelection

function PickaxeSelectionController:UpdateInfo(OreName :string, TimeToMine :number, Percentage :number, MiningProgress :number)
    PickaxeService:GetPickaxe():andThen(function(Pickaxe)
        if not PlayerFolder.PickaxeSelection.Value then MiningSelection.Visible = false return end

        local RealOre = game.ReplicatedStorage.Ores:FindFirstChild(OreName)
        if OreName == "Stone" then RealOre = game.ReplicatedStorage.Stone end
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
        MiningSelection.MiningProgressBar.Size = UDim2.new(MiningProgress, 0, 1, 0)

        MiningSelection.TimeToMine.Text = TimeToMine.."s - "..Percentage.."%"
        MiningSelection.TimeToMine.TextColor3 = RealOre:GetAttribute("SelectionColor")

        print("[UI MODULE] Updated mining selection:")
        print("[UI MODULE]     - Ore Name: "..OreName)
        print("[UI MODULE]     - Time To Mine: "..TimeToMine)
        print("[UI MODULE]     - Percentage Mined: "..Percentage)
    end)
end

PlayerFolder.PickaxeSelection:GetPropertyChangedSignal("Value"):Connect(function()
    local ObjectToMine = PlayerFolder.PickaxeSelection
    local Health = ObjectToMine
    PickaxeSelectionController:UpdateInfo(ObjectToMine.Name, self:CalculateTimeToMine(Player, Health), math.ceil((1 - (Health / ObjectToMine:GetAttribute("MaxHealth"))) * 100), (Health / ObjectToMine:GetAttribute("MaxHealth")))
end)

--[[ KNIT ]]--

function PickaxeSelectionController:KnitStart()
    PickaxeService = Knit.GetService("PickaxeService")

    PickaxeService.UpdateMiningSelection:Connect(function(OreName :string, TimeToMine :number, Percentage :number, MiningProgress :number)
        PickaxeSelectionController:UpdateInfo(OreName, TimeToMine, Percentage, MiningProgress)
    end)
end

return PickaxeSelectionController
