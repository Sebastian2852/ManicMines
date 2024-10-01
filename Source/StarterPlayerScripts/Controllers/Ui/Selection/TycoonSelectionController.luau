local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Core = require(ReplicatedStorage.Game.Modules.Core)

local TycoonSelectionController = Knit.CreateController{ 
    Name = "TycoonSelectionController"
}

local TycoonService
local LogService
local DataService

local Assets = ReplicatedStorage.Assets
local TycoonAssets = Assets.Tycoon

local SelectionOutline :SelectionBox = TycoonAssets.UpgradeSelection
local CurrentlySelecting = false
local CurrentOutline = nil
local Selection = nil

local Player = Knit.Player
local Mouse = Player:GetMouse()
local TycoonSelection :Frame = Player.PlayerGui.HUD.TycoonSelection



-- [[ PRIVATE ]]--

local function CanBeUpgraded(UpgradeName :string)
    local CanUpgrade = false
    CanUpgrade = DataService:GetPlayerDataFolder(Player):andThen(function(PlayerData :Core.DataFolder)
        local DataValue = PlayerData.Tycoon.Upgrades:FindFirstChild(UpgradeName)
        if not DataValue then LogService:Warn("Invalid upgrade name passed; Can't find data for upgrade:", UpgradeName) return false end

        local UpgradeConfig = Core.Assets.Tycoon.Upgrades:FindFirstChild(UpgradeName)
        if not UpgradeConfig then LogService:Warn("Invalid upgrade name:", UpgradeName) return false end

        if UpgradeConfig:FindFirstChild(tostring(DataValue.Value + 1)) then return true end
        return false
    end)

    return CanUpgrade
end

local function OreListDataToUI(OreData :{Name :string, DisplayName :string, Amount :number, Emblem :string, RealOre :BasePart}) :Frame
    local NewFrame = Core.Assets.UI.OreFrame:Clone()
    NewFrame.OreName.Text = OreData.DisplayName
    NewFrame.OreAmount.Text = OreData.Amount
    NewFrame.OreImage.Image = OreData.Emblem or Core.Assets.UI.NoTexture.Texture
    return NewFrame
end

-- [[ PUBLIC ]]--

--[=[
Deselects the currently selected hitbox by destroying the outline it was given
]=]
function TycoonSelectionController:Deselect()
    if not CurrentlySelecting then return end
    LogService:Log("Deselecting upgrade hitbox")
    if CurrentOutline then CurrentOutline:Destroy() end
    if Selection ~= nil then Selection = nil end
    TycoonSelection.Visible = false
    CurrentlySelecting = false
end

--[=[
Updates the GUI to match the new information passed. Call before showing the UI to avoid incorrect data
]=]
function TycoonSelectionController:UpdateUiInfo(UpgradeName :string, UpgradeDescription :string, NextConfig :Configuration)
    TycoonSelection.Title.Text = UpgradeName
    TycoonSelection.Description.Text = UpgradeDescription

    for _, Child :GuiBase in pairs(TycoonSelection.UpgradePanel.CostItems:GetChildren()) do
        if Child:IsA("UIListLayout") then continue end
        Child:Destroy()
    end

    local CostList = self:CreateCostOreList(NextConfig)
    for OreName, OreData in pairs(CostList:LoopList()) do
        local NewUI = OreListDataToUI(OreData)
        NewUI.Parent = TycoonSelection.UpgradePanel.CostItems
    end

    TycoonSelection.UpgradePanel.UpgradeButton.Visible = CanBeUpgraded(UpgradeName)
    print(CanBeUpgraded(UpgradeName), TycoonSelection.UpgradePanel.UpgradeButton.Visible)
end

--[=[
Selectes a given hitbox by giving it an outline, if anything is already selected it will
automatically deslect it
]=]
function TycoonSelectionController:SelectHitbox(Hitbox)
    LogService:Log("Selecting upgrade hitbox")
    if CurrentlySelecting then self:Deselect() end
    if Selection ~= nil then self:Deselect() end

    TycoonSelection.Visible = true
    local New = SelectionOutline:Clone()
    New.Parent = Hitbox
    New.Adornee = Hitbox
    New.Name = "Selection"

    CurrentOutline = New
    Selection = Hitbox
    CurrentlySelecting = true
    LogService:Log("Selected upgrade hitbox: "..Hitbox.Name)
end

--[=[
Takes in an upgrade config and returns the cost for the upgrade as a OreList or nil
if there is no config passed or no cost folder in the config
]=]
function TycoonSelectionController:CreateCostOreList(UpgradeConfig :Configuration)
    if UpgradeConfig == nil then return nil end
    if not UpgradeConfig:FindFirstChild("Cost") then return nil end
    return Core.Util:CreateOreListFromFolder(UpgradeConfig:FindFirstChild("Cost"))
end



-- [[ KNIT ]]--

function TycoonSelectionController:KnitStart()
    TycoonService   = Knit.GetService("TycoonService")
    LogService      = Knit.GetService("LogService")
    DataService     = Knit.GetService("DataService")

    TycoonService.SelectUpgrade:Connect(function(UpgradeName :string, UpgradeConfig :Configuration, ModelConfig :Configuration, Hitbox :BasePart, Model :Model, NextConfig :Configuration)
        self:UpdateUiInfo(UpgradeName, UpgradeConfig:GetAttribute("Description"), NextConfig)
        self:SelectHitbox(Hitbox)
    end)

    TycoonSelection.CloseButton.MouseButton1Click:Connect(function()
        self:Deselect()
    end)

    TycoonSelection.UpgradePanel.UpgradeButton.MouseButton1Click:Connect(function()
        if not CurrentlySelecting then return end
        TycoonService:Upgrade(Selection.Name)
        self:Deselect()
    end)
end

return TycoonSelectionController
