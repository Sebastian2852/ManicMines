local ReplicatedStorage = game.ReplicatedStorage
local Knit = require(ReplicatedStorage.Packages.Knit)

local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")

local Player :Player = game.Players.LocalPlayer
local Mouse :Mouse = Player:GetMouse()

repeat
    task.wait(0.1)
until script.Parent:IsA("Tool")

local Tool :Tool = script.Parent
local PickaxeService = Knit.GetService("PickaxeService")

local PlayerFolder = game.ReplicatedStorage.Player
local PlayerDataFolder = game.ReplicatedStorage.PlayerData:WaitForChild(Player.UserId)

local Equipped = false
local Selecting = false

local Outline = nil
local Active = false

local MouseDown = false
local Automining = false

local LatestPosition = {}
LatestPosition.X = 0
LatestPosition.Y = 0

local function Activate()
    if not PlayerFolder.PickaxeSelection.Value then return end

    if PlayerDataFolder.Inventory["InventoryItemCount"].Value + PlayerFolder.PickaxeSelection.Value:GetAttribute("AmountDroppedWhenMined") >= PlayerDataFolder.Inventory["InventoryCap"].Value then print("Not enough space") return end
    if not PlayerFolder.PickaxeSelection.Value:GetAttribute("CanMine") then return end
    if PlayerFolder.PickaxeSelection.Value:GetAttribute("BeingMined") then return end

    if not Active then
        Active = true
        PickaxeService:StartMining(PlayerFolder.PickaxeSelection.Value)
        while Active do
            PickaxeService:StartMining(PlayerFolder.PickaxeSelection.Value)
            if PlayerFolder.PickaxeSelection.Value == nil then
                break
            end
            task.wait(0.1)
        end
    end
end

local function Deactivate()
    if Automining then return end
    PickaxeService:StopMining()
    Active = false
end

local function AddOutline(Object :BasePart)
    if Outline ~= nil then 
        Outline:Destroy() 
    end

    if not Object:GetAttribute("CanMine") then return end

    local New = ReplicatedStorage.Assets.Pickaxe.PickaxeSelection:Clone()
    New.Name = "Outline"
    New.Visible = true
    New.Adornee = Object
    New.Parent = Object
    New.Color3 = Object:GetAttribute("SelectionColor")

    if PlayerDataFolder.Inventory["InventoryItemCount"].Value + Object:GetAttribute("AmountDroppedWhenMined") > PlayerDataFolder.Inventory["InventoryCap"].Value then 
        New.Color3 = Color3.new(1, 0, 0)
    end

    if Object:GetAttribute("BeingMined") then
        New.Color3 = Color3.new(1, 0, 0)
     end
    Outline = New
end

local function SetTarget(Object :BasePart)
    if Object == PlayerFolder.PickaxeSelection.Value then return end
    if not Object:IsDescendantOf(workspace.Game.Mine) then return end

    AddOutline(Object)
end

local function CanReach(OreBlock :BasePart)
    local Distance = (Player.Character.PrimaryPart.Position - OreBlock.Position).Magnitude
    local Range = Tool:GetAttribute("MiningRange")

    if Distance > Range then
        return false
    end

    return true
end

local function DeselectOre()
    if Outline then 
        Outline:Destroy() 
    end
    Selecting = false
    PlayerFolder.PickaxeSelection.Value = nil
    Deactivate()
end

local function SelectOre(Ore :BasePart)
    if not Ore or not Ore.Parent then return end
    if not Ore:GetAttribute("CanMine") then
        Deactivate()
        DeselectOre()
        return
    end

    if Ore.Parent == workspace.Game.Mine and CanReach(Ore) then
        Selecting = true
        SetTarget(Ore)
        PlayerFolder.PickaxeSelection.Value = Ore
    elseif Ore and Ore.Parent:IsA("Model") then
        SetTarget(Ore.Parent)
        PlayerFolder.PickaxeSelection.Value = Ore.Parent
        Selecting = true
    elseif not UserInputService.TouchEnabled then
        Deactivate()
        DeselectOre()
    end

end

local function GetOreFromRayCast(X, Y)
    if not X or not Y then warn("No X or Y") return end

    local Camera = workspace.CurrentCamera
    local CameraRay = Camera:ScreenPointToRay(X, Y)

    local RaycastParamaters = RaycastParams.new()
    RaycastParamaters.FilterDescendantsInstances = {workspace.Game.Players:GetDescendants()}
    RaycastParamaters.FilterType = Enum.RaycastFilterType.Exclude

    local RayCastResult = workspace:Raycast(CameraRay.Origin, CameraRay.Direction * 100, RaycastParamaters)
    local Ore = nil

    if RayCastResult then
        Ore = RayCastResult.Instance
    end

    if Ore == nil then return nil end
    if not CanReach(Ore) then return nil end
    if Ore.Parent ~= game.Workspace.Game.Mine then return nil end

    return Ore
end

Mouse.Move:Connect(function()
    LatestPosition.X = Mouse.X
    LatestPosition.Y = Mouse.Y
end)

UserInputService.TouchTap:Connect(function(TouchPos, Proccessed)
    if Proccessed then return end
    LatestPosition.X = TouchPos[1].X
    LatestPosition.Y = TouchPos[1].Y
end)

RunService.Heartbeat:Connect(function()
    if not Equipped then return end
    local Ore = GetOreFromRayCast(LatestPosition.X, LatestPosition.Y)

    if Ore then
        SelectOre(Ore)

        if MouseDown or Automining then
            Activate()
        else
            Deactivate()
        end
    else
        DeselectOre()
        Deactivate()
    end
end)

Tool.Equipped:Connect(function()
    Equipped = true
end)

Tool.Unequipped:Connect(function()
    Equipped = false
    DeselectOre()
    Deactivate()
end)

Tool.Activated:Connect(function()
    Activate()
end)

UserInputService.TouchStarted:Connect(function(Touch, Processed)
    if Processed then return end
    MouseDown = true
    Activate()
end)

UserInputService.TouchEnded:Connect(function(Touch, Processed)
    if Processed then return end
    MouseDown = false
    Deactivate()
end)

Mouse.Button1Down:Connect(function()
    MouseDown = true
end)

Mouse.Button1Up:Connect(function()
    MouseDown = false
end)

UserInputService.InputBegan:Connect(function(Input, Processed)
    if Input.KeyCode == Enum.KeyCode.R and not Processed then
        Automining = not Automining
        Processed = true
    end
end)

Player.Character:FindFirstChildWhichIsA("Humanoid").Died:Connect(function()
    DeselectOre()
    Deactivate()
end)

--while true do
--    if PlayerDataFolder.ServerMining.Value then
--        PlayerController.Mouse:SetCursorImage(Tool:GetAttribute("CursorUpImage"))
--        task.wait(Tool:GetAttribute("CursorAnimationFPS"))
--        PlayerController.Mouse:SetCursorImage(Tool:GetAttribute("CursorDownImage"))
--        task.wait(Tool:GetAttribute("CursorAnimationFPS"))
--    else
--        PlayerController.Mouse:ResetCursorImage()
--    end
--    
--    if Selecting and not Outline.Parent:GetAttribute("BeingMined") then
--        PlayerController.Mouse:SetCursorImage(Tool:GetAttribute("CantMineImage"))
--    end
--    
--    if not Selecting then
--        PlayerController.Mouse:ResetCursorImage()
--    end
--    
--    task.wait(0.01)
--end