local Knit = require(game.ReplicatedStorage.Packages.Knit)

local TycoonAssets = game.ServerStorage.Assets.Tycoon
local Tycoons = workspace.Game.Tycoons

local TycoonService = Knit.CreateService{
    Name = "TycoonService";
    Client = {};
}

local LogService = nil

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

    local TycoonSpawn :BasePart = NewTycoon.Main.Spawn

    Player.CharacterAdded:Connect(function(Character)
        Character:PivotTo(CFrame.new(TycoonSpawn.Position + Vector3.new(0, 5, 0)))
    end)

    if Player.Character then
        Player.Character:PivotTo(CFrame.new(TycoonSpawn.Position + Vector3.new(0, 5, 0)))
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
    LogService:Log(Player.Name.."asked for their tycoon model")
    return self:GetPlayerTycoon(Player)
end



--[[ KNIT ]]--

--[=[
Setup the module, for now it creates the tycoon for the player. Later when data stuff is up and running
This will be removed and the data service will handle creating the player's tycoon.
]=]
function TycoonService:KnitStart()
    LogService = Knit.GetService("LogService")

    game.Players.PlayerAdded:Connect(function(Player)
        self:CreateTycoonForPlayer(Player)
    end)
end

return TycoonService