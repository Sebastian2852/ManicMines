local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Core = require(ReplicatedStorage.Game.Modules.Core)

local TycoonAssets = ReplicatedStorage.Assets.Tycoon
local Tycoons = workspace.Game.Tycoons


local TycoonService = Knit.CreateService{
    Name = "TycoonService";
    Client = {
        SelectUpgrade = Knit.CreateSignal()
    };
}

local LogService
local DataService
local TeleportService
local AdminService

local TycoonsSpawn = workspace.Game:FindFirstChild("TycoonsSpawn")

--[[ PRIVATE ]]--

local function CreateUpgradeModelUI(UpgradeModelConfig :Configuration) :BillboardGui
    local UpgradeName = UpgradeModelConfig.Parent:GetAttribute("UpgradeName")
    local UpgradeNameColor = UpgradeModelConfig.Parent:GetAttribute("UpgradeNameColor")

    local Level = UpgradeModelConfig.Name
    local LevelColor = UpgradeModelConfig:GetAttribute("LevelColor")

    local NewUI = ReplicatedStorage.Assets.UI.Tycoon.Upgrade:Clone()
    NewUI.Main.UpgradeLevel.UIGradient.Color = LevelColor
    NewUI.Main.UpgradeName.UIGradient.Color = UpgradeNameColor

    NewUI.Main.UpgradeName.Text = UpgradeName
    NewUI.Main.UpgradeLevel.Text = Level
    return NewUI
end

local function AddUpgradeModels(DataFolder :Core.DataFolder, Tycoon :Model)
    local RawUpgradesFolder = TycoonAssets.Upgrades
    local TycoonUpgradesFolder = Tycoon.Main.Upgrades
    local DataFolderUpgradesFolder = DataFolder.Tycoon.Upgrades

    for _, UpgradeHitbox :BasePart in pairs(TycoonUpgradesFolder:GetChildren()) do
        -- Setup upgrade hitbox
        UpgradeHitbox.CanCollide = false
        UpgradeHitbox.Anchored = true
        UpgradeHitbox:AddTag("_UpgradeHitbox")

        local DataValue = DataFolderUpgradesFolder:FindFirstChild(UpgradeHitbox.Name)
        local UpgradeConfig :Configuration = RawUpgradesFolder:FindFirstChild(UpgradeHitbox.Name)

        if not DataValue then LogService:Warn("No data value for upgrade: "..UpgradeHitbox.Name) continue end
        if not DataValue then LogService:Warn("No upgrade config for upgrade: "..UpgradeHitbox.Name) continue end

        local ModelConfig = UpgradeConfig:FindFirstChild(DataValue.Value)
        if not ModelConfig then LogService:Warn("No upgrade level config for upgrade "..UpgradeHitbox.Name.." level "..DataValue.Value) continue end

        local UpgradeModel = ModelConfig:FindFirstChildWhichIsA("Model")
        if not UpgradeModel then LogService:Warn("No upgrade model for upgrade "..UpgradeHitbox.Name.." level "..DataValue.Value) continue end

        local CurrentModel = UpgradeHitbox:FindFirstChildWhichIsA("Model")
        if CurrentModel then CurrentModel:Destroy() end

        local Model :Model = UpgradeModel:Clone()
        Model.Parent = UpgradeHitbox
        Model:PivotTo(UpgradeHitbox.CFrame)

        local UI = CreateUpgradeModelUI(UpgradeModel.Parent)
        UI.Parent = Model
        UI.Adornee = Model
        UI.StudsOffset = Vector3.new(0, (UpgradeHitbox.Size.Y / 2) + 2, 0)

        LogService:Log("Added upgrade model "..UpgradeHitbox.Name.." level "..DataValue.Value)

        local NewClickDetector = Instance.new("ClickDetector")
        NewClickDetector.Name = "_SelectionClickDetector"
        NewClickDetector.Parent = UpgradeHitbox
        NewClickDetector.MaxActivationDistance = Core.GameConfig.Tycoon.UpgradeSelectionDistance

        local NextConfig = UpgradeConfig:FindFirstChild(DataValue.Value + 1)
        NewClickDetector.MouseClick:Connect(function(Player)
            TycoonService.Client.SelectUpgrade:Fire(Player, UpgradeHitbox.Name, UpgradeConfig, ModelConfig, UpgradeHitbox, Model, NextConfig)
        end)
    end
end

local function CanBeUpgraded(Player :Player, UpgradeName :string)
    local PlayerData :Core.DataFolder = DataService:GetPlayerDataFolder(Player)

    local DataValue = PlayerData.Tycoon.Upgrades:FindFirstChild(UpgradeName)
    if not DataValue then LogService:Warn("Invalid upgrade name passed; Can't find data for upgrade:", UpgradeName) return end

    local UpgradeConfig = Core.Assets.Tycoon.Upgrades:FindFirstChild(UpgradeName)
    if not UpgradeConfig then LogService:Warn("Invalid upgrade name:", UpgradeName) return end

    if UpgradeConfig:FindFirstChild(tostring(DataValue.Value + 1)) then return true end
    return false
end



--[[ PUBLIC ]]--

--[=[
Returns true/false if the player has a tycoon.
]=]
function TycoonService:DoesPlayerHaveTycoon(Player :Player) :boolean
    local UserId = Player.UserId

    local FoundTycoon = Tycoons:FindFirstChild(tostring(UserId))
    if FoundTycoon then return true end

    return false
end

--[=[
Returns the player's tycoon model if the player has one, otherwise returning nothing.
]=]
function TycoonService:GetPlayerTycoon(Player :Player) :Model?
    local UserId = Player.UserId

    local FoundTycoon = Tycoons:FindFirstChild(tostring(UserId))
    if FoundTycoon then return FoundTycoon end

    LogService:Warn("Couldnt find "..Player.Name.."'s tycoon")
    return nil
end

--[=[
Create a tycoon for the player and put it in workspace. Then setup an event so when the player
spawns they get teleported to their tycoon spawn instead of the SpawnLocation.
]=]
function TycoonService:CreateTycoonForPlayer(Player :Player) :Model
    LogService:Assert(not self:DoesPlayerHaveTycoon(Player), "Player already has tycoon?")

    local NewTycoon = TycoonAssets.TycoonModel:Clone()
    NewTycoon.Name = Player.UserId
    NewTycoon.Parent = Tycoons
    NewTycoon:PivotTo(CFrame.new(TycoonsSpawn.Position + Vector3.new(500 * (#Tycoons:GetChildren() - 1), 0, 0)))

    local TycoonSpawn :BasePart = NewTycoon.Main.Spawn
    local TeleportLocation = TycoonSpawn.Position + Vector3.new(0, 5, 0)
    local DataFolder = DataService:GetPlayerDataFolder(Player)

    Player.CharacterAdded:Connect(function(Character)
        TeleportService:TeleportPlayerToTycoon(Player, NewTycoon)
    end)

    AddUpgradeModels(DataFolder, NewTycoon)
    if Player.Character then
        TeleportService:TeleportPlayerToTycoon(Player, NewTycoon)
    end


    LogService:Log("Created "..Player.Name.."'s tycoon")
    return NewTycoon
end



--[[ CLIENT ]]--

--[=[
Allow the client to get player tycoon, not really needed but here if for some reason it is needed.
This function may later be removed but its here for now.
]=]
function TycoonService.Client:GetPlayerTycoon(Player :Player) :Model?
    return self.Server:GetPlayerTycoon(Player)
end

--[=[
Tell the server to upgrade a given upgrade.
]=]
function TycoonService.Client:Upgrade(Player :Player, UpgradeName :string)
    if not CanBeUpgraded(Player, UpgradeName) then return end

    local PlayerData :Core.DataFolder = DataService:GetPlayerDataFolder(Player)
    local Tycoon = self.Server:GetPlayerTycoon(Player)

    local DataValue = PlayerData.Tycoon.Upgrades:FindFirstChild(UpgradeName)
    if not DataValue then LogService:Warn("Invalid upgrade name passed; Can't find data for upgrade:", UpgradeName) return end

    DataValue.Value += 1
    AddUpgradeModels(PlayerData, Tycoon)
end

function TycoonService.Client:SetUpgradeValue(Setter :Player, Player :Player, UpgradeName :string, Value :number)
    if not AdminService:IsPlayerAdmin(Setter) then LogService:Warn("User is not an admin!") return end
    if not AdminService:GetAdminPermissions(Setter).EditTycoonUpgrades then return end

    local PlayerData :Core.DataFolder = DataService:GetPlayerDataFolder(Player)
    local Tycoon = self:GetPlayerTycoon(Player)

    local UpgradeValue = PlayerData.Tycoon.Upgrades:FindFirstChild(UpgradeName)
    if not UpgradeValue then LogService:Warn("Invalid upgrade name passed") return end
    UpgradeValue.Value = Value

    AddUpgradeModels(PlayerData, Tycoon)
end

function TycoonService.Client:SetTycoonName(Setter :Player, Player :Player, Name :string)
    if not AdminService:IsPlayerAdmin(Setter) then LogService:Warn("User is not an admin!") return end
    if not AdminService:GetAdminPermissions(Setter).EditTycoonName then return end

    local PlayerData :Core.DataFolder = DataService:GetPlayerDataFolder(Player)
    PlayerData.Tycoon.TycoonName.Value = Name
end


--[[ KNIT ]]--

--[=[
Some checks to make sure the game is ready for tycoons
]=]
function TycoonService:KnitInit()
    LogService = Knit.GetService("LogService")

    if not TycoonsSpawn then
        LogService:Warn("No tycoon spawn found, defaulting to 0,0,0")
        local New = Instance.new("Part")
        New.Name = "TycoonsSpawn"
        New.Position = Vector3.new(0, 0, 0)
        New.Anchored = true
        New.Parent = workspace.Game
        TycoonsSpawn = New
    end
end

function TycoonService:KnitStart()
    DataService        = Knit.GetService("DataService")
    TeleportService    = Knit.GetService("TeleportService")
    AdminService       = Knit.GetService("AdminService")
end

return TycoonService