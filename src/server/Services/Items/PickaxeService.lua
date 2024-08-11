local ReplicatedStorage = game.ReplicatedStorage

local Knit = require(ReplicatedStorage.Packages.Knit)

local DataService
local MineService

local PickaxeAssetFolder = game.ReplicatedStorage.Assets.Pickaxe
local Pickaxes = PickaxeAssetFolder.Pickaxes

local PickaxeService = Knit.CreateService {
    Name = "PickaxeService",
    Client = {},
}

PickaxeService.Mining = {}

function PickaxeService:VerifyIfCanMine(Player :Player, Character :Model, ObjectToMine :BasePart) :boolean
    local Pickaxe :Instance = self:GetPlayerPickaxe(Player)
    if not Pickaxe then return false end
    if not ObjectToMine then return false end

    local Distance :number = (Character.PrimaryPart.Position - ObjectToMine.Position).Magnitude

    if Distance > Pickaxe:GetAttribute("MiningRange") then return false end

    return true
end

function PickaxeService.Client:StartMining(Player :Player, ObjectToMine :BasePart)
    if not self.Mining[Player.UserId] then
        self.Mining[Player.UserId] = {Mining = false, Object = nil, Cooldown = false}
    end

    if self.Mining[Player.UserId].Cooldown then return end
    if self.Mining[Player.UserId].Mining then return end
    if not ObjectToMine:GetAttribute("CanMine") then return end

    local DataFolder = DataService:GetPlayerDataFolder(Player)
    if not ObjectToMine then return end
    if not DataFolder then return end

    if DataFolder.Inventory.InventoryItemCount.Value + ObjectToMine:GetAttribute("AmountDroppedWhenMined") > DataFolder.Inventory.InventoryCap.Value then return end

    local Character = Player.Character
    local Pickaxe = self:GetPlayerPickaxe(Player)

    if not Character then return end
    if not self:VerifyIfCanMine(Player, Character, ObjectToMine) then return end

    DataFolder.ServerMining.Value = true
    self.Mining[Player.UserId].Mining = true
    self.Mining[Player.UserId].Object = ObjectToMine

    ObjectToMine:SetAttribute("MinedBy", Player.UserId)
    ObjectToMine:SetAttribute("BeingMined", true)

    while self.Mining[Player.UserId].Mining and self:VerifyIfCanMine(Player, Character, ObjectToMine) do
        local Health :number = ObjectToMine:GetAttribute("Health")

        if Health <= 0 then
            self:StopMining(Player)
            MineService:BlockMined(Player, ObjectToMine)
            --DataModule:MinedOre(ObjectToMine.Name, ObjectToMine:GetAttribute("AmountDroppedWhenMined"), Player)
            --DataModule:RecalculateInventoryItems(Player)
            --Events.Client.UpdateInventory:FireClient(Player)
            break
        end

        Health -= Pickaxe:GetAttribute("HitDamage")
        ObjectToMine:SetAttribute("Health", Health)
        --Events.Client.UpdateMiningSelection:FireClient(Player, ObjectToMine.Name, DataModule:CalculateTimeToMine(Player, Health), math.ceil((1 - (Health / ObjectToMine:GetAttribute("MaxHealth"))) * 100), (Health / ObjectToMine:GetAttribute("MaxHealth")))

        if Health <= 0 then
            self:StopMining(Player)
            MineService:BlockMined(Player, ObjectToMine)
            task.wait(Pickaxe:GetAttribute("MiningHitDelay") / 2)
            --DataModule:MinedOre(ObjectToMine.Name, ObjectToMine:GetAttribute("AmountDroppedWhenMined"), Player)
            --DataModule:RecalculateInventoryItems(Player)
            --Events.Client.UpdateInventory:FireClient(Player)
            break
        end

        task.wait(Pickaxe:GetAttribute("MiningHitDelay"))
    end
end

function PickaxeService.Client:StopMining(Player :Player)
    if not self.Mining[Player.UserId] then
        self.Mining[Player.UserId] = {Mining = false, Object = nil, Cooldown = false}
    end

    if not self.Mining[Player.UserId].Mining then return end

    local DataFolder = DataService:GetPlayerDataFolder(Player)
    if not DataFolder then return end

    if self.Mining[Player.UserId].Object ~= nil then
        self.Mining[Player.UserId].Object:SetAttribute("MinedBy", 0)
        self.Mining[Player.UserId].Object:SetAttribute("BeingMined", false)
    end

    local Pickaxe = self:GetPlayerPickaxe(Player)

    DataFolder.ServerMining.Value = false
    self.Mining[Player.UserId].Mining = false
    self.Mining[Player.UserId].Object = nil

    self.Mining[Player.UserId].Cooldown = true
    task.spawn(function()
        task.wait(Pickaxe:GetAttribute("MiningCooldown"))
        self.Mining[Player.UserId].Cooldown = false
    end)
end

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
Returns the player's pickaxe tool
]]--
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
    MineService = Knit.GetService("MineService")

    game.Players.PlayerAdded:Connect(function(Player)
        self.Mining[Player.UserId] = {Mining = false, Object = nil, Cooldown = false}

        Player.CharacterAdded:Connect(function(Character :Model)
            Character.Parent = workspace.Game.Players
        end)
    end)

    game.Players.PlayerRemoving:Connect(function(Player)
        if self.Mining[Player.UserId] then
            self.Mining[Player.UserId] = nil
        end
    end)
end

return PickaxeService
