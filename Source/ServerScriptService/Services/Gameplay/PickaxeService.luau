local ReplicatedStorage = game.ReplicatedStorage

local Knit = require(ReplicatedStorage.Packages.Knit)
local Core = require(ReplicatedStorage.Game.Modules.Core)

local PlayerStatsService
local DataService
local MineService
local LogService

local PickaxeAssetFolder = game.ReplicatedStorage.Assets.Pickaxe
local Pickaxes = PickaxeAssetFolder.Pickaxes

local PickaxeService = Knit.CreateService {
    Name = "PickaxeService",
    Client = {
        UpdateMiningSelection = Knit.CreateSignal();
    },
}

PickaxeService.Mining = {}

--[[ PUBLIC ]]--

--[=[
Calculates the time to mine based on the health passed
]=]
function PickaxeService:CalculateTimeToMine(Player :Player, Health :number) :number
    local Pickaxe :Instance = PickaxeService:GetPlayerPickaxe(Player)

    local HitsNeeded = math.ceil(Health / Pickaxe:GetAttribute("Damage"))
    local TimePerHit = Pickaxe:GetAttribute("Delay")
    local TotalTime = HitsNeeded * TimePerHit
    return Core.Util:RoundToxDP(TotalTime, 1)
end

--[=[
Check if the player can actually mine the block they want to
]=]
function PickaxeService:VerifyIfCanMine(Player :Player, Character :Model, ObjectToMine :BasePart) :boolean
    local Pickaxe :Instance = PickaxeService:GetPlayerPickaxe(Player)
    if not Pickaxe then return false end
    if not ObjectToMine then return false end

    local Distance :number = (Character.PrimaryPart.Position - ObjectToMine.Position).Magnitude

    if Distance > Pickaxe:GetAttribute("Range") then return false end
    if not ObjectToMine:GetAttribute("CanMine") then return false end

    return true
end

--[=[
Returns true/false depending on if the player has a pickaxe tool
]=]
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

--[=[
Returns the player's pickaxe tool
]=]
function PickaxeService:GetPlayerPickaxe(Player :Player) :Tool?
    for _, Tool in pairs(Player.Backpack:GetChildren()) do
        if Tool:HasTag("Pickaxe") and Tool:IsA("Tool") then
            return Tool
        end
    end

    if Player.Character then
        for _, Tool in pairs(Player.Character:GetChildren()) do
            if Tool:HasTag("Pickaxe") and Tool:IsA("Tool") then
                return Tool
            end
        end
    end

    return nil
end

--[=[
Remove the current pickaxe the player has in their inventory or from their
character if they have it equipped
]=]
function PickaxeService:RemovePickaxeFromPlayer(Player :Player)
    if not PickaxeService:DoesPlayerHavePickaxe(Player) then return end

    LogService:Log("Removing "..Player.Name.."'s pickaxe")

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

--[=[
Give the player thier currently equipped pickaxe
]=]
function PickaxeService:GivePickaxeToPlayer(Player :Player)
    LogService:Log("Giving "..Player.Name.." a pickaxe")
    repeat
        task.wait(1)
    until Player.Character

    if PickaxeService:DoesPlayerHavePickaxe(Player) then
        PickaxeService:RemovePickaxeFromPlayer(Player)
    end

    local DataFolder = DataService:GetPlayerDataFolder(Player)
    LogService:Assert(DataFolder, "No data folder")

    local CurrentPickaxeID :number = DataFolder.Pickaxes.Equipped.Value
    local CurrentPickaxeConfig :Configuration = Pickaxes:FindFirstChild(CurrentPickaxeID)
    LogService:Assert(CurrentPickaxeConfig, "No pickaxe config")

    local Pickaxe :Tool = CurrentPickaxeConfig:FindFirstChildWhichIsA("Tool")
    local NewPickaxe :Tool = Pickaxe:Clone()
    local NewScript :LocalScript = ReplicatedStorage.Game.Scripts.Pickaxe:Clone()
    NewPickaxe.Parent = Player.Backpack
    NewScript.Parent = NewPickaxe
    NewPickaxe:AddTag("Pickaxe")
end

function PickaxeService:StartMining(Player :Player, ObjectToMine :BasePart)
    if ObjectToMine == nil then return end

    if not PickaxeService.Mining[Player.UserId] then
        LogService:Warn("Player should have an entry in mining table?")
        PickaxeService.Mining[Player.UserId] = {Mining = false, Object = nil, Cooldown = false}
    end

    if PickaxeService.Mining[Player.UserId].Cooldown then return end
    if PickaxeService.Mining[Player.UserId].Mining then return end

    local DataFolder = DataService:GetPlayerDataFolder(Player)
    if not DataFolder then return end

    if DataFolder.Inventory.InventoryItemCount.Value + ObjectToMine:GetAttribute("AmountDroppedWhenMined") > DataFolder.Inventory.InventoryCap.Value then return end

    local Character = Player.Character
    local Pickaxe = PickaxeService:GetPlayerPickaxe(Player)

    if not Character then return end
    if not PickaxeService:VerifyIfCanMine(Player, Character, ObjectToMine) then
        print("Cant mine")
        return
    end

    DataFolder.ServerMining.Value = true
    PickaxeService.Mining[Player.UserId].Mining = true
    PickaxeService.Mining[Player.UserId].Object = ObjectToMine

    ObjectToMine:SetAttribute("MinedBy", Player.UserId)
    ObjectToMine:SetAttribute("BeingMined", true)

    LogService:Log(Player.Name.." started mining")

    local OreList = Core.OreList.New()
    OreList:AddOre(ObjectToMine.Name, ObjectToMine:GetAttribute("AmountDroppedWhenMined"))
    MineService:GenerateAroundBlockAsync(ObjectToMine)
    while PickaxeService.Mining[Player.UserId].Mining and PickaxeService:VerifyIfCanMine(Player, Character, ObjectToMine) do
        local Health :number = ObjectToMine:GetAttribute("Health")

        if Health <= 0 then
            PickaxeService:StopMining(Player)
            MineService:BlockMined(ObjectToMine)
            PlayerStatsService:MinedOre(Player, OreList)
            break
        end

        Health -= Pickaxe:GetAttribute("Damage")
        ObjectToMine:SetAttribute("Health", Health)
        PickaxeService.Client.UpdateMiningSelection:Fire(Player, ObjectToMine.Name, self:CalculateTimeToMine(Player, Health), math.ceil((1 - (Health / ObjectToMine:GetAttribute("MaxHealth"))) * 100), (Health / ObjectToMine:GetAttribute("MaxHealth")))

        if Health <= 0 then
            PickaxeService:StopMining(Player)
            MineService:BlockMined(ObjectToMine)
            PlayerStatsService:MinedOre(Player, OreList)
            task.wait(Pickaxe:GetAttribute("Delay") / 2)
            break
        end

        task.wait(Pickaxe:GetAttribute("Delay"))
    end

    OreList:Destroy()
end

function PickaxeService:StopMining(Player :Player)
    if not PickaxeService.Mining[Player.UserId] then
        PickaxeService.Mining[Player.UserId] = {Mining = false, Object = nil, Cooldown = false}
    end

    if not PickaxeService.Mining[Player.UserId].Mining then return end

    local DataFolder = DataService:GetPlayerDataFolder(Player)
    if not DataFolder then return end

    if PickaxeService.Mining[Player.UserId].Object ~= nil then
        PickaxeService.Mining[Player.UserId].Object:SetAttribute("MinedBy", 0)
        PickaxeService.Mining[Player.UserId].Object:SetAttribute("BeingMined", false)
    end

    local Pickaxe = PickaxeService:GetPlayerPickaxe(Player)
    LogService:Log(Player.Name.." stopped mining")

    DataFolder.ServerMining.Value = false
    PickaxeService.Mining[Player.UserId].Mining = false
    PickaxeService.Mining[Player.UserId].Object = nil

    PickaxeService.Mining[Player.UserId].Cooldown = true
    task.spawn(function()
        task.wait(Pickaxe:GetAttribute("MiningCooldown"))
        PickaxeService.Mining[Player.UserId].Cooldown = false
    end)
end



--[[ CLIENT ]]--

--[=[
Get the players pickaxe
]=]
function PickaxeService.Client:GetPickaxe(Player :Player)
    return PickaxeService:GetPlayerPickaxe(Player)
end

--[=[
Makes the player start mining a given block
]=]
function PickaxeService.Client:StartMining(Player :Player, ObjectToMine :BasePart)
    PickaxeService:StartMining(Player, ObjectToMine)
end

--[=[
Stops the player from mining aswell as starting their cooldown
]=]
function PickaxeService.Client:StopMining(Player :Player)
    PickaxeService:StopMining(Player)
end

function PickaxeService.Client:CalculateTimeToMine(Player :Player, Health :number)
    return PickaxeService:CalculateTimeToMine(Player, Health)
end



--[[ KNIT ]]--

function PickaxeService:KnitStart()
    DataService = Knit.GetService("DataService")
    MineService = Knit.GetService("MineService")
    PlayerStatsService = Knit.GetService("PlayerStatsService")
    LogService = Knit.GetService("LogService")

    game.Players.PlayerAdded:Connect(function(Player)
        PickaxeService.Mining[Player.UserId] = {Mining = false, Object = nil, Cooldown = false}

        Player.CharacterAdded:Connect(function(Character :Model)
            Character.Parent = workspace.Game.Players
        end)
    end)

    game.Players.PlayerRemoving:Connect(function(Player)
        if PickaxeService.Mining[Player.UserId] then
            PickaxeService.Mining[Player.UserId] = nil
        end
    end)
end

return PickaxeService
