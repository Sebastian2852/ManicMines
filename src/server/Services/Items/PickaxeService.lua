local ReplicatedStorage = game.ReplicatedStorage

local Knit = require(ReplicatedStorage.Packages.Knit)
local DataService

local PickaxeAssetFolder = game.ReplicatedStorage.Assets.Pickaxe
local Pickaxes = PickaxeAssetFolder.Pickaxes

local PickaxeService = Knit.CreateService {
    Name = "PickaxeService",
    Client = {},
}



--[[
Returns true/false depending on if the player has a pickaxe tool
]]--
function PickaxeService:DoesPlayerHavePickaxe(Player :Player) :boolean
    for _, Tool in pairs(Player.Backpack:GetChildren()) do
        if Tool:HasTag("Pickaxe") and Tool:IsA("Tool") then
            return true
        end
    end

    if Player.Character then
        for _, Tool in pairs(Player.Character:GetChildren()) do
            if Tool:HasTag("Pickaxe") and Tool:IsA("Tool") then
                return true
            end
        end
    end

    return false
end

--[[
Remove the current pickaxe the player has in their inventory or from their
character if they have it equipped
]]--
function PickaxeService:RemovePickaxeFromPlayer(Player :Player)
    if not self:DoesPlayerHavePickaxe(Player) then return end

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

--[[
Give the player thier currently equipped pickaxe
]]--
function PickaxeService:GivePickaxeToPlayer(Player :Player)
    repeat
        task.wait(1)
    until Player.Character

    if self:DoesPlayerHavePickaxe(Player) then
        self:RemovePickaxeFromPlayer(Player)
    end

    local DataFolder = DataService:GetPlayerDataFolder(Player)
    assert(DataFolder, "No data folder")

    local CurrentPickaxeID = DataFolder.Pickaxes.Equipped.Value
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
