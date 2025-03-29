local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Logger = require(ReplicatedStorage.Game.Modules.Logger)

local TeleportService = Knit.CreateService({
	Name = "TeleportService",
	Client = {},
})

local TycoonService
local DataService
local LoadingService
local MineService

local NamesToAvoid = {
	"HumanoidRootPart",
}

--[[ PRIVATE ]]
--

--[=[
Takes in a duration and a model to fade out
]=]
local function FadeCharacterOut(Duration: number, Character: Model)
	local TweeningInfo = TweenInfo.new(Duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false, 0)
	local Tweens: { Tween } = {}

	for _, Thing: BasePart in pairs(Character:GetDescendants()) do
		if not Thing:IsA("BasePart") then
			continue
		end
		if table.find(NamesToAvoid, Thing.Name) then
			continue
		end
		if Thing:FindFirstAncestorWhichIsA("Tool") then
			continue
		end
		local Tween = TweenService:Create(Thing, TweeningInfo, { Transparency = 1 })
		table.insert(Tweens, Tween)
	end

	for _, Tween in pairs(Tweens) do
		Tween:Play()
	end
end

--[=[
Takes in a duration and a model to fade in
]=]
local function FadeCharacterIn(Duration: number, Character: Model)
	local TweeningInfo = TweenInfo.new(Duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false, 0)
	local Tweens: { Tween } = {}

	for _, Thing: BasePart in pairs(Character:GetDescendants()) do
		if not Thing:IsA("BasePart") then
			continue
		end
		if table.find(NamesToAvoid, Thing.Name) then
			continue
		end
		if Thing:FindFirstAncestorWhichIsA("Tool") then
			continue
		end
		local Tween = TweenService:Create(Thing, TweeningInfo, { Transparency = 0 })
		table.insert(Tweens, Tween)
	end

	for _, Tween in pairs(Tweens) do
		Tween:Play()
	end
end

--[[ PUBLIC ]]
--

--[=[
Teleports a player's character to the given position. If the player doesnt have a character
the function waits until a character is present
]=]
function TeleportService:TeleportPlayerToPosition(Player: Player, Position: Vector3, WithLoadingScreen: boolean?)
	Logger:Log("Teleporting", Player.Name, "to", tostring(Position))
	local Character = Player.Character
	if not Character then
		Logger:Log("Waiting for player's character")
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
function TeleportService:TeleportPlayertoPart(Player: Player, Part: BasePart, WithLoadingScreen: boolean?)
	self:TeleportPlayerToPosition(Player, Part.CFrame.Position, WithLoadingScreen)
end

--[=[
Teleports a player to a given tycoon's spawn. If no tycoon is passed the player is teleported to their own
tycoon.
]=]
function TeleportService:TeleportPlayerToTycoon(Player: Player, TycoonPlayer: Player?, WithLoadingScreen: boolean?)
	Logger:Log("Teleporting", Player.Name, "to their player")
	local DataFolder = DataService:GetPlayerDataFolder(Player)
	local TeleportLocation

	if TycoonPlayer then
		local PlayerTycoon = TycoonService:GetPlayerTycoon(TycoonPlayer)
		local TycoonSpawn: BasePart = PlayerTycoon.Main.Spawn
		TeleportLocation = TycoonSpawn.Position + Vector3.new(0, 5, 0)
	else
		local PlayerTycoon = TycoonService:GetPlayerTycoon(Player)
		local TycoonSpawn: BasePart = PlayerTycoon.Main.Spawn
		TeleportLocation = TycoonSpawn.Position + Vector3.new(0, 5, 0)
	end

	DataFolder.InTycoon.Value = true
	self:TeleportPlayerToPosition(Player, TeleportLocation, WithLoadingScreen)
end

--[=[
Teleport the given player to the surface of the mine
]=]
function TeleportService:TeleportPlayerToSurface(Player: Player)
	local DataFolder = DataService:GetPlayerDataFolder(Player)
	self:TeleportPlayerToPosition(Player, workspace.Game.Teleports.Surface.Position, true)
	DataFolder.InTycoon.Value = false
end

function TeleportService:TeleportToDepth(Player: Player, Depth: number)
	local Pos = MineService:GenerateRoomAtDepth(Depth)
	self:TeleportPlayerToPosition(Player, Pos, true)
end

-- [[ CLIENT ]] --

--[=[
Teleport the current player to the surface
]=]
function TeleportService.Client:TeleportToSurface(Player: Player)
	task.spawn(function()
		task.wait(1)
		local DataFolder = DataService:GetPlayerDataFolder(Player) :: Core.DataFolder

		if DataFolder.TutorialStage.Value == 1 then
			DataFolder.TutorialStage.Value = 2
		end

		if DataFolder.TutorialStage.Value == 6 then
			DataFolder.TutorialStage.Value = 7
		end
	end)
	self.Server:TeleportPlayerToSurface(Player)
end

function TeleportService.Client:TeleportToTycoon(Player: Player)
	task.spawn(function()
		task.wait(1)
		local DataFolder = DataService:GetPlayerDataFolder(Player) :: Core.DataFolder
		if DataFolder.TutorialStage.Value == 3 then
			DataFolder.TutorialStage.Value = 4
		end
	end)
	self.Server:TeleportPlayerToTycoon(Player, nil, true)
end

--[[ KNIT ]]
--

function TeleportService:KnitStart()
	TycoonService = Knit.GetService("TycoonService")
	DataService = Knit.GetService("DataService")
	LoadingService = Knit.GetService("LoadingService")
	MineService = Knit.GetService("MineService")
end

return TeleportService
