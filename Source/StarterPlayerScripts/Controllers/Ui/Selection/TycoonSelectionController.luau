local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Core = require(ReplicatedStorage.Game.Modules.Core)

local TycoonSelectionController = Knit.CreateController{ 
    Name = "TycoonSelectionController"
}

local TycoonService
local LogService

local Assets = ReplicatedStorage.Assets
local TycoonAssets = Assets.Tycoon

local SelectionOutline :SelectionBox = TycoonAssets.UpgradeSelection
local CurrentlySelecting = false
local CurrentOutline = nil
local Selection = nil

local Player = Knit.Player
local Mouse = Player:GetMouse()
local MiningSelection = Player.PlayerGui.HUD.MiningSelection



-- [[ PRIVATE ]]--

--[=[
Shoots a ray from the mouse positions given and checks if it hit a
tycoon upgrade hitbox part
]=]
local function DidClickedHitbox(MouseX, MouseY) :boolean
    if not MouseX or not MouseY then warn("No X or Y") return end

    local Camera = workspace.CurrentCamera
    local CameraRay = Camera:ScreenPointToRay(MouseX, MouseY)

    local RaycastParamaters = RaycastParams.new()
    RaycastParamaters.FilterDescendantsInstances = {workspace.Game.Players:GetDescendants()}
    RaycastParamaters.FilterType = Enum.RaycastFilterType.Exclude

    local RayCastResult = workspace:Raycast(CameraRay.Origin, CameraRay.Direction * Core.GameConfig.Tycoon.UpgradeSelectionDistance, RaycastParamaters)

    if RayCastResult then
        local HitObject = RayCastResult.Instance
        if HitObject:HasTag("_UpgradeHitbox") then
            return true
        end
    end

    return false
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
    CurrentlySelecting = false
end

--[=[
Selectes a given hitbox by giving it an outline, if anything is already selected it will
automatically deslect it
]=]
function TycoonSelectionController:SelectHitbox(Hitbox)
    LogService:Log("Selecting upgrade hitbox")
    if CurrentlySelecting then self:Deselect() end
    if Selection ~= nil then self:Deselect() end

    local New = SelectionOutline:Clone()
    New.Parent = Hitbox
    New.Adornee = Hitbox
    New.Name = "Selection"

    CurrentOutline = New
    Selection = Hitbox
    CurrentlySelecting = true
    LogService:Log("Selected upgrade hitbox: "..Hitbox.Name)
end



-- [[ KNIT ]]--

function TycoonSelectionController:KnitStart()
    TycoonService = Knit.GetService("TycoonService")
    LogService = Knit.GetService("LogService")

    TycoonService.SelectUpgrade:Connect(function(UpgradeName :string, UpgradeConfig :Configuration, Hitbox :BasePart, Model :Model)
        self:SelectHitbox(Hitbox)
    end)

    Mouse.Button1Down:Connect(function()
        local MouseX = Mouse.X
        local MouseY = Mouse.Y

        if not DidClickedHitbox(MouseX, MouseY) then
            self:Deselect()
        end
    end)
end

return TycoonSelectionController
