local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--[=[
THIS SYSTEM NEEDS TO BE REWORKED

Currently it does everything at the start of the game. That is fine until we conisder things like other players. If you were to invite someone they could use your
upgrades as their own, which shouldn't happen.

The way it is setup right now it is impossible to do the above nor pass anything like "TycoonOwner" or "Level". So rather than doing everything at the start we should do it
by getting the tycoon service to tell us when a new upgrade has been made and then check if anything has a matching tag then set it up right then and there.
]=]

local Knit = require(ReplicatedStorage.Packages.Knit)
local Promise = require(ReplicatedStorage.Packages.Promise)

local Core = require(ReplicatedStorage.Game.Modules.Core)

local TycoonUpgradeService = Knit.CreateService {
    Name = "TycoonUpgradeService";
    Client = {
        OpenStorage = Knit.CreateSignal();
    };
}

local TycoonService
local DataService
local LogService

--[=[
Setup a hitbox in a way so that all of the hitboxes look the same
]=]
function TycoonUpgradeService:SetupHitbox(Hitbox :BasePart)
    return Promise.new(function(Resolve)
        Hitbox.CanCollide = false
        Hitbox.Anchored = true
        Hitbox.Transparency = 0.5
        Hitbox:AddTag("Tycoon/Upgrades/Hitbox")
        Resolve()
    end)
end

--[=[
Add a GUI to a hitbox with the given level config
]=]
function TycoonUpgradeService:AddUIToHitbox(Hitbox :BasePart, LevelConfig :Configuration)
    return Promise.new(function(Resolve)
        local FoundGui = Hitbox:FindFirstAncestorWhichIsA("BillboardGui")
        if FoundGui then
            FoundGui:Destroy()
        end

        local Gui = Instance.new("BillboardGui")
        Gui.Size = UDim2.fromScale(10, 3)
        Gui.StudsOffset = Vector3.new(0, 9.5, 0)
        Gui.LightInfluence = 0
        Gui.MaxDistance = 100
        Gui.Brightness = 1

        local Main = Instance.new("Frame")
        Main.Name = "Main"
        Main.Size = UDim2.fromScale(1, 1)
        Main.BackgroundTransparency = 1
        Main.Parent = Gui

        local UpgradeName = Instance.new("TextLabel")
        UpgradeName.Name = "UpgradeName"
        UpgradeName.Size = UDim2.fromScale(1, 0.6)
        UpgradeName.Position = Core.UI.Position.TopLeft
        UpgradeName.AnchorPoint = Core.UI.AnchorPoint.TopLeft
        UpgradeName.BackgroundTransparency = 1
        UpgradeName.Text = LevelConfig.Parent:GetAttribute("UpgradeName")
        UpgradeName.TextColor3 = Core.UI.Color.White
        UpgradeName.FontFace = Core.UI.Theme.TextFont
        UpgradeName.TextScaled = true
        UpgradeName.TextStrokeTransparency = 0
        UpgradeName.Parent = Main

        local UpgradeNameColor = Instance.new("UIGradient")
        UpgradeNameColor.Name = "Color"
        UpgradeNameColor.Color = LevelConfig.Parent:GetAttribute("UpgradeNameColor") or Core.UI.Theme.TextColor3
        UpgradeNameColor.Parent = UpgradeName

        local UpgradeLevel = Instance.new("TextLabel")
        UpgradeLevel.Name = "UpgradeLevel"
        UpgradeLevel.Size = UDim2.fromScale(1, 0.4)
        UpgradeLevel.Position = Core.UI.Position.Bottomleft
        UpgradeLevel.AnchorPoint = Core.UI.AnchorPoint.BottomLeft
        UpgradeLevel.BackgroundTransparency = 1
        UpgradeLevel.Text = "Level "..LevelConfig.Name
        UpgradeLevel.TextColor3 = Core.UI.Color.White
        UpgradeLevel.FontFace = Core.UI.Theme.TextFont
        UpgradeLevel.TextScaled = true
        UpgradeLevel.TextStrokeTransparency = 0
        UpgradeLevel.Parent = Main

        local UpgradeLevelColor = Instance.new("UIGradient")
        UpgradeLevelColor.Name = "Color"
        UpgradeLevelColor.Color = LevelConfig:GetAttribute("LevelColor") or Core.UI.Theme.TextColor3
        UpgradeLevelColor.Parent = UpgradeLevel

        Gui.Parent = Hitbox
        Resolve()
    end)
end

function TycoonUpgradeService:AddClickDetectorToHitbox(HitBox :BasePart)
    return Promise.new(function()
        local NewClickDetector = Instance.new("ClickDetector")
        NewClickDetector.Name = "_SelectionClickDetector"
        NewClickDetector.Parent = HitBox
        NewClickDetector.MaxActivationDistance = Core.GameConfig.Tycoon.UpgradeSelectionDistance

        NewClickDetector.MouseClick:Connect(function(Player)
            TycoonService.Client.SelectUpgrade:Fire(Player, HitBox.Name) -- Event should probably be moved to this service
        end)
    end)
end

function TycoonUpgradeService:AddModelToHitbox(Hitbox :BasePart, LevelConfig :Configuration)
    return Promise.new(function(Resolve, Reject)
        local Model = LevelConfig:FindFirstChildWhichIsA("Model")
        if not Model then
            Reject("Cannot get model")
        end

        local CurrentModel = Hitbox:FindFirstChildWhichIsA("Model")
        if CurrentModel then
            CurrentModel:Destroy()
        end

        local NewModel = Model:Clone()
        NewModel:PivotTo(Hitbox.CFrame)
        NewModel.Parent = Hitbox
        Resolve()
    end)
end

--[=[
This function add the model to the tycoon, sets up the hitbox (if needed) and adds the GUI to the hitbox
]=]
function TycoonUpgradeService:AddUpgradeToTycoonAsync(Player :Player, UpgradeName :string, Tycoon :Model)
    LogService:Log("Adding upgrade", UpgradeName, "to", tostring(Player.UserId).."'s", "tycoon")
    return Promise.new(function(Resolve, Reject)
        assert(Player:IsDescendantOf(Players), "Player is not a valid player")
        assert(Tycoon:IsDescendantOf(workspace.Game.Tycoons), "Tycoon must be a tycoon in workspace")

        local PlayerData :Core.DataFolder = DataService:GetPlayerDataFolder(Player)

        local DataValue = PlayerData.Tycoon.Upgrades:FindFirstChild(UpgradeName)
        local TycoonHitbox = Tycoon.Main.Upgrades:FindFirstChild(UpgradeName)
        local UpgradeConfig = Core.Assets.Tycoon.Upgrades:FindFirstChild(UpgradeName)
        local LevelConfig = UpgradeConfig:FindFirstChild(tostring(DataValue.Value))

        if not UpgradeConfig then
            LogService:Error("Unkown upgrade:", UpgradeName)
        end

        if not DataValue then
            LogService:Error("Cannot find data value for upgrade:", UpgradeName)
        end

        if not TycoonHitbox then
            LogService:Error("Cannot find tycoon hitbox for upgrade: ", UpgradeName)
        end

        local Tasks = {}

        table.insert(Tasks, self:SetupHitbox(TycoonHitbox))
        table.insert(Tasks, self:AddUIToHitbox(TycoonHitbox, LevelConfig))
        table.insert(Tasks, self:AddModelToHitbox(TycoonHitbox, LevelConfig))
        table.insert(Tasks, self:AddClickDetectorToHitbox(TycoonHitbox))

        local Success = Promise.all(Tasks):await()
        if Success then
            Resolve()
        else
            Reject("a task(s) failed")
        end
    end)
end

-- [[ KNIT ]] --

function TycoonUpgradeService:KnitStart()
    DataService = Knit.GetService("DataService")
    LogService = Knit.GetService("LogService")
    TycoonService = Knit.GetService("TycoonService")
end

return TycoonUpgradeService