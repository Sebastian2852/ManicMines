local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(game.ReplicatedStorage.Packages.Knit)

local HUDGUI = Knit.Player.PlayerGui:WaitForChild("HUD")
local InventoryGUI = Knit.Player.PlayerGui:WaitForChild("Inventory")

local HUDController = Knit.CreateController {
    Name = "HUDController"
}

local Core = require(ReplicatedStorage.Game.Modules.Core)

local DataService

--[[ PUBLIC ]]--

function HUDController:UpdateGold(GoldAmount :number)
    HUDGUI.Gold.Amount.Text = tostring(GoldAmount)
end

function HUDController:UpdateInventoryOre(OreName :string, OreAmount :number)
    local RealOre = Core.Util:GetOreByName(OreName)
    local OreAsType = Core.Util:ConvertOreToType(RealOre, OreAmount)
    
    local Frame = InventoryGUI.Inventory.Inventory:FindFirstChild(OreName)
    if not Frame and OreAmount > 0 then
        local NewFrame = Core.Util:MakeOreUIFromType(OreAsType)
        NewFrame.Parent = InventoryGUI.Inventory.Inventory
        NewFrame.Name = OreName
    elseif Frame and OreAmount <= 0 then
        Frame:Destroy()
    elseif Frame and OreAmount > 0 then
        Frame.OreAmount.Text = OreAmount
    end
end


--[[ KNIT ]]--

function HUDController:KnitStart()
    DataService = Knit.GetService("DataService")
    local PlayerDataFolder :Core.DataFolder = ReplicatedStorage.PlayerData:WaitForChild(tostring(Knit.Player.UserId))

    PlayerDataFolder.Gold:GetPropertyChangedSignal("Value"):Connect(function()
        self:UpdateGold(PlayerDataFolder.Gold.Value)
    end)

    for _, Ore :IntValue in pairs(PlayerDataFolder.Inventory.Ores:GetChildren()) do
        Ore:GetPropertyChangedSignal("Value"):Connect(function()
            self:UpdateInventoryOre(Ore.Name, Ore.Value)
        end)

        self:UpdateInventoryOre(Ore.Name, Ore.Value)
    end

   self:UpdateGold(PlayerDataFolder.Gold.Value)
end


return HUDController
