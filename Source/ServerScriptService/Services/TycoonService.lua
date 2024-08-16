local Knit = require(game.ReplicatedStorage.Packages.Knit)

local TycoonAssets = game.ServerStorage.Assets.Tycoon
local Tycoons = workspace.Game.Tycoons

local TycoonService = Knit.CreateService{
    Name = "TycoonService";
    Client = {};
}

--[[ VARIABLES ]]--

local LogService
local DataService
local TeleportService

local TycoonsSpawn = workspace.Game:FindFirstChild("TycoonsSpawn")



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

    Player.CharacterAdded:Connect(function(Character)
        TeleportService:TeleportPlayerToPosition(Player, TeleportLocation)
    end)

    if Player.Character then
        TeleportService:TeleportPlayerToPosition(Player, TeleportLocation)
    end

    local DataFolder = DataService:GetPlayerDataFolder(Player)
    DataFolder.InTycoon.Value = true

    LogService:Log("Created "..Player.Name.."'s tycoon")
    return NewTycoon
end



--[[ CLIENT ]]--

--[=[
Allow the client to get player tycoon, not really needed but here if for some reason it is needed.
This function may later be removed but its here for now.
]=]
function TycoonService.Client:GetPlayerTycoon(Player :Player) :Model?
    LogService:Log(Player.Name.."asked for their tycoon model")
    return self:GetPlayerTycoon(Player)
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
    DataService = Knit.GetService("DataService")
    TeleportService = Knit.GetService("TeleportService")
end

return TycoonService