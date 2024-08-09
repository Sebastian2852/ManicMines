local ReplicatedStorage = game.ReplicatedStorage

local Knit = require(ReplicatedStorage.Packages.Knit)
local DataService

local PickaxeAssetFolder = game.ReplicatedStorage.Assets.Pickaxe
local Pickaxes = PickaxeAssetFolder.Pickaxes

local PickaxeService = Knit.CreateService {
    Name = "PickaxeService",
    Client = {},
}

function PickaxeService:RemovePlayerPickaxe(Player :Player)
    for _, Tool in pairs(Player.Backpack:GetChildren()) do
        if Tool:HasTag("Pickaxe") and Tool:IsA("Tool") then
            Tool:Destroy()
        end
    end

    if Player.Character then
        for _, Tool in pairs(Player.Character:GetChildren()) do
            if Tool:HasTag("Pickaxe") and Tool:IsA("Tool") then
                Tool:Destroy()
            end
        end
    end
end

function PickaxeService:GivePickaxeToPlayer(Player :Player)
    repeat
        task.wait(1)
    until Player.Character

    local DataFolder = DataService:GetPlayerDataFolder(Player)
    assert(DataFolder, "No data folder")

    local CurrentPickaxeID = DataFolder.Equipped.Pickaxe.Value
    local CurrentPickaxeConfig = Pickaxes:FindFirstChild(CurrentPickaxeID)
    assert(CurrentPickaxeConfig, "No pickaxe config")

    local Pickaxe = CurrentPickaxeConfig:FindFirstChildWhichIsA("Tool")
    local NewPickaxe = Pickaxe:Clone()
    local NewScript = ReplicatedStorage.Shared.Scripts.Pickaxe:Clone()
    NewPickaxe.Parent = Player.Backpack
    NewScript.Parent = NewPickaxe
end

--[[ KNIT ]]--

function PickaxeService:KnitStart()
    DataService = Knit.GetService("DataService")
end

return PickaxeService
