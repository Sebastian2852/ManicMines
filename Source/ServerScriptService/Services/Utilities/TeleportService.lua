local ReplicatedStorage = game.ReplicatedStorage

local Knit = require(ReplicatedStorage.Packages.Knit)

local TeleportService = Knit.CreateService {
    Name = "TeleportService",
    Client = {
        TeleportStarted = Knit.CreateSignal(); -- Starts a fade out
        TeleportFinished = Knit.CreateSignal(); -- Starts fading in
    },
}

--[[ VARIABLES ]]--
local TweenService = game:GetService("TweenService")

--[=[
A list of all the names to avoid while fading a character in or out
]=]
local NamesToAvoid = {
    "HumanoidRootPart";
}



--[[ INTERNAL ]]--

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

    task.wait(Duration)
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

    task.wait(Duration)
end



--[[ PUBLIC ]]--

--[=[
Teleports a player's character to the given position. If the player doesnt have a character
the function waits until a character is present
]=]
function TeleportService:TeleportPlayerToPosition(Player :Player, Position :Vector3)
    local Character = Player.Character
    if not Character then
        repeat
            Character = Player.Character
            task.wait(0.1)
        until Character
    end

    self.Client.TeleportStarted:Fire(Player)
    FadeCharacterOut(5, Character)
    Character:PivotTo(CFrame.new(Position))
    FadeCharacterIn(5, Character)
    self.Client.TeleportFinished:Fire(Player)
end

--[=[
Teleports a player's character to the given part's potiion. If the player doesnt have a character
the function waits until a character is present
]=]
function TeleportService:TeleportPlayertoPart(Player :Player, Part :BasePart)
    self:TeleportPlayerToPosition(Player, Part.CFrame.Position)
end


return TeleportService