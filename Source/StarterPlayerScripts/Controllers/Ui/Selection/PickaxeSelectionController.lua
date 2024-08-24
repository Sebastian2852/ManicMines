local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local PickaxeSelectionController = Knit.CreateController { Name = "PickaxeSelectionController" }

local Player = Knit.Player
local PlayerFolder = ReplicatedStorage.Player

local TweenService = game:GetService("TweenService")
local PickaxeService

local MiningSelection = Player.PlayerGui.HUD.MiningSelection
local MiningSelection_Animating

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

        local TweeningInformation = TweenInfo.new(Pickaxe:GetAttribute("MiningHitDelay") / 2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false, 0)
        local Tween = TweenService:Create(MiningSelection.MiningProgressBar.Bar, TweeningInformation, {Size = UDim2.new(MiningProgress, 0, 1, 0)})

        repeat task.wait(0.01) until MiningSelection_Animating == false
        if not PlayerFolder.PickaxeSelection.Value then MiningSelection.Visible = false return end

        MiningSelection.OreName.Text = RealOre:GetAttribute("DisplayName")
        MiningSelection.OreName.TextColor3 = PlayerFolder.PickaxeSelection.Value:FindFirstChildWhichIsA("SelectionBox").Color3

        MiningSelection.MiningProgressBar.UIGradient.Color = RealOre:GetAttribute("MiningBarGradient")
        Tween:Play()

        MiningSelection.TimeToMine.Text = TimeToMine.."s - "..Percentage.."%"
        MiningSelection.TimeToMine.TextColor3 = RealOre:GetAttribute("SelectionColor")

        print("[UI MODULE] Updated mining selection:")
        print("[UI MODULE]     - Ore Name: "..OreName)
        print("[UI MODULE]     - Time To Mine: "..TimeToMine)
        print("[UI MODULE]     - Percentage Mined: "..Percentage)
    end)
end


--[[ KNIT ]]--

function PickaxeSelectionController:KnitStart()
    PickaxeService = Knit.GetService("PickaxeService")

    PickaxeService.UpdateMiningSelection:Connect(function(OreName :string, TimeToMine :number, Percentage :number, MiningProgress :number)
        PickaxeSelectionController:UpdateInfo(OreName, TimeToMine, Percentage, MiningProgress)
    end)
end

return PickaxeSelectionController
