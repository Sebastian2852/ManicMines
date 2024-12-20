local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local TeleportService = Knit.CreateService {
    Name = "TeleportService",
    Client = {},
}

local LogService
local TycoonService
local DataService
local LoadingService

local NamesToAvoid = {
    "HumanoidRootPart";
}


--[[ PRIVATE ]]--

--[=[
Takes in a duration and a model to fade out
]=]
local function FadeCharacterOut(Duration :number, Character :Model)
    local TweeningInfo = TweenInfo.new(Duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false, 0)
    local Tweens :{Tween} = {}

    for _, Thing :BasePart in pairs(Character:GetDescendants()) do
        if not Thing:IsA("BasePart") then continue end
        if table.find(NamesToAvoid, Thing.Name) then continue end
        local Tween = TweenService:Create(Thing, TweeningInfo, {Transparency = 1})
        table.insert(Tweens, Tween)
    end

    for _, Tween in pairs(Tweens) do
        Tween:Play()
    end
end

--[=[
Takes in a duration and a model to fade in
]=]
local function FadeCharacterIn(Duration :number, Character :Model)
    local TweeningInfo = TweenInfo.new(Duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false, 0)
    local Tweens :{Tween} = {}

    for _, Thing :BasePart in pairs(Character:GetDescendants()) do
        if not Thing:IsA("BasePart") then continue end
        if table.find(NamesToAvoid, Thing.Name) then continue end
        local Tween = TweenService:Create(Thing, TweeningInfo, {Transparency = 0})
        table.insert(Tweens, Tween)
    end

    for _, Tween in pairs(Tweens) do
        Tween:Play()
    end
end



--[[ PUBLIC ]]--

--[=[
Teleports a player's character to the given position. If the player doesnt have a character
the function waits until a character is present
]=]
function TeleportService:TeleportPlayerToPosition(Player :Player, Position :Vector3, WithLoadingScreen :boolean?)
    LogService:Log("Teleporting", Player.Name, "to", tostring(Position))
    local Character = Player.Character
    if not Character then
        LogService:Log("Waiting for player's character")
        repeat
            Character = Player.Character
            task.wait(0.1)
        until Character
    end

    if WithLoadingScreen then
        LoadingService:StartLoading(Player)
        LoadingService:UpdateActionText(Player, "Teleporting")
    end
    FadeCharacterOut(1, Character)
    task.wait(1)
    Player:RequestStreamAroundAsync(Position, 5)
    Character:PivotTo(CFrame.new(Position))
    task.wait(1)
    FadeCharacterIn(1, Character)
    if WithLoadingScreen then
        task.wait(1)
        LoadingService:EndLoading(Player)
    end
end

--[=[
Teleports a player's character to the given part's potiion. If the player doesnt have a character
the function waits until a character is present
]=]
function TeleportService:TeleportPlayertoPart(Player :Player, Part :BasePart, WithLoadingScreen :boolean?)
    self:TeleportPlayerToPosition(Player, Part.CFrame.Position, WithLoadingScreen)
end

--[=[
Teleports a player to a given tycoon's spawn. If no tycoon is passed the player is teleported to their own
tycoon.
]=]
function TeleportService:TeleportPlayerToTycoon(Player :Player, Tycoon :Model?, WithLoadingScreen :boolean?)
    LogService:Log("Teleporting", Player.Name, "to their player")
    local DataFolder = DataService:GetPlayerDataFolder(Player)
    local TeleportLocation

    if Tycoon then
        local TycoonSpawn :BasePart = Tycoon.Main.Spawn
        TeleportLocation = TycoonSpawn.Position + Vector3.new(0, 5, 0)
    else
        local PlayerTycoon = TycoonService:GetPlayerTycoon(Player)
        local TycoonSpawn :BasePart = PlayerTycoon.Main.Spawn
        TeleportLocation = TycoonSpawn.Position + Vector3.new(0, 5, 0)
    end

    DataFolder.InTycoon.Value = true
    self:TeleportPlayerToPosition(Player, TeleportLocation, WithLoadingScreen)
end

--[=[
Teleport the given player to the surface of the mine
]=]
function TeleportService:TeleportPlayerToSurface(Player :Player)
    local DataFolder = DataService:GetPlayerDataFolder(Player)
    self:TeleportPlayerToPosition(Player, workspace.Game.Teleports.Surface.Position, true)
    DataFolder.InTycoon.Value = false
end

-- [[ CLIENT ]] --

--[=[
Teleport the current player to the surface
]=]
function TeleportService.Client:TeleportToSurface(Player :Player)
    self.Server:TeleportPlayerToSurface(Player)
end

function TeleportService.Client:TeleportToTycoon(Player :Player)
    self.Server:TeleportPlayerToTycoon(Player, nil, true)
end



--[[ KNIT ]]--

function TeleportService:KnitStart()
    LogService = Knit.GetService("LogService")
    TycoonService = Knit.GetService("TycoonService")
    DataService = Knit.GetService("DataService")
    LoadingService = Knit.GetService("LoadingService")
end

return TeleportService
