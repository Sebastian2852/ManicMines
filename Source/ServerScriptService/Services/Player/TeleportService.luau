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
function TeleportService:TeleportPlayerToPosition(Player :Player, Position :Vector3)
    LogService:Log("Teleporting", Player.Name, "to", tostring(Position))
    local Character = Player.Character
    if not Character then
        LogService:Log("Waiting for player's character")
        repeat
            Character = Player.Character
            task.wait(0.1)
        until Character
    end

    LoadingService:StartLoading(Player)
    FadeCharacterOut(1, Character)
    task.wait(1)
    Character:PivotTo(CFrame.new(Position))
    task.wait(1)
    FadeCharacterIn(1, Character)
    LoadingService:EndLoading(Player)
end

--[=[
Teleports a player's character to the given part's potiion. If the player doesnt have a character
the function waits until a character is present
]=]
function TeleportService:TeleportPlayertoPart(Player :Player, Part :BasePart)
    self:TeleportPlayerToPosition(Player, Part.CFrame.Position)
end

--[=[
Teleports a player to a given tycoon's spawn. If no tycoon is passed the player is teleported to their own
tycoon.
]=]
function TeleportService:TeleportPlayerToTycoon(Player :Player, Tycoon :Model?)
    LogService:Log("Teleporting", Player.Name, "to their player")
    local DataFolder = DataService:GetPlayerDataFolder(Player)
    local TeleportLocation

    if Tycoon then
        local TycoonSpawn :BasePart = Tycoon.Main.Spawn
        TeleportLocation = TycoonSpawn.Position + Vector3.new(0, 5, 0)
        DataFolder.InTycoon.Value = true
    else
        local PlayerTycoon = TycoonService:GetPlayerTycoon(Player)
        local TycoonSpawn :BasePart = PlayerTycoon.Main.Spawn
        TeleportLocation = TycoonSpawn.Position + Vector3.new(0, 5, 0)
        DataFolder.InTycoon.Value = true
    end

    self:TeleportPlayerToPosition(Player, TeleportLocation)
end

--[=[
Teleport the given player to the surface of the mine
]=]
function TeleportService:TeleportPlayerToSurface(Player :Player)
    self:TeleportPlayerToPosition(Player, workspace.Game.Teleports.Surface.Position)
end



--[[ KNIT ]]--

function TeleportService:KnitStart()
    LogService = Knit.GetService("LogService")
    TycoonService = Knit.GetService("TycoonService")
    DataService = Knit.GetService("DataService")
    LoadingService = Knit.GetService("LoadingService")
end

return TeleportService
