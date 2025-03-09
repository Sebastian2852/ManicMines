local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Knit = require(ReplicatedStorage.Packages.Knit)

local MineEffects = Knit.CreateController({ Name = "MineEffects" })

local LightingController
local MusicController
local PickaxeService
local AudioEngine
local MineService
local LogService

local PreviousLayer = ""
local Animation
local LastBelowOptimalDepth = true
local CurrentlyTweening = false

-- [[ PUBLIC ]] --

MineEffects.CurrentLayer = nil

function MineEffects:Layer(LayerName: string)
	LogService:Log("Appling layer effects for: " .. LayerName)
	if not Core.Assets.Layers:FindFirstChild(LayerName) then
		LogService:Warn("Invalid layer name: " .. LayerName)
		return
	end

	local LayerConfig: Configuration = Core.Assets.Layers:FindFirstChild(LayerName)
	MusicController:PlayMusicForLayer(LayerConfig)

	local LightingConfig = LayerConfig:FindFirstChild("Lighting")
	if LightingConfig then
		LogService:Log("Appling lighting effects")
		LightingController:CreateFromConfig(LightingConfig)
	end

	self.CurrentLayer = LayerConfig
end

-- [[ KNIT ]] --

function MineEffects:KnitInit()
	local AnimationID = "rbxassetid://16827661763"
	Animation = Instance.new("Animation")
	Animation.AnimationId = AnimationID
	Animation.Parent = script
end

function MineEffects:KnitStart()
	AudioEngine = Knit.GetController("AudioEngine")
	LightingController = Knit.GetController("LightingController")
	MusicController = Knit.GetController("MusicController")
	LogService = Knit.GetService("LogService")
	MineService = Knit.GetService("MineService")
	PickaxeService = Knit.GetService("PickaxeService")

	task.spawn(function()
		while true do
			local Character = Knit.Player.Character
			if not Character or not Character:FindFirstChild("HumanoidRootPart") then
				continue
			end

			local RootPart = Character:FindFirstChild("HumanoidRootPart")
			local X = math.floor(RootPart.CFrame.Position.X)
			local Y = math.floor(RootPart.CFrame.Position.Y)
			local Z = math.floor(RootPart.CFrame.Position.Z)
			local Position = Vector3.new(X, Y, Z)

			local _, Config = MineService:GetLayerConfig(Position.Y):await()
			if PreviousLayer ~= Config.Name then
				MineEffects:Layer(Config.Name)
				PreviousLayer = Config.Name
			end

			local _, Depth = MineService:ConvertToDepth(Position.Y):await()
			ReplicatedStorage.Player.Depth.Value = Depth

			local _, OptimalDepth = PickaxeService:GetOptimalDepth():await()
			local BelowOptimalDepth = Depth >= OptimalDepth

			if BelowOptimalDepth ~= LastBelowOptimalDepth then
				LastBelowOptimalDepth = BelowOptimalDepth
				ReplicatedStorage.Player.BelowOptimalDepth.Value = BelowOptimalDepth
			end

			if CurrentlyTweening then
				continue
			end

			CurrentlyTweening = true
			local DepthDifference = Depth - OptimalDepth
			ReplicatedStorage.Player.DepthDifference.Value = DepthDifference
			local TargetFOV = BelowOptimalDepth and math.clamp(70 - DepthDifference, 60, 70) or 70
			if workspace.CurrentCamera.FieldOfView == TargetFOV then
				CurrentlyTweening = false
				continue
			end

			local Tween = TweenService:Create(
				workspace.CurrentCamera,
				TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false, 0),
				{ FieldOfView = TargetFOV }
			)

			Tween:Play()
			Tween.Completed:Connect(function()
				CurrentlyTweening = false
			end)
		end
	end)

	local Player = Knit.Player
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local Humanoid = Character:WaitForChild("Humanoid")
	-- This is deprecated and should probably be changed
	-- but i cba rn :)
	local AnimationTrack = Humanoid:LoadAnimation(Animation)

	Player.CharacterAdded:Connect(function(NewCharacter)
		Character = NewCharacter
		Humanoid = Character:WaitForChild("Humanoid")
		AnimationTrack = Humanoid:LoadAnimation(Animation)
	end)

	AnimationTrack:GetMarkerReachedSignal("HitSound"):Connect(function()
		local Block = ReplicatedStorage.Player.PickaxeSelection.Value
		PickaxeService.PlayHitSound:Fire(Block)
	end)

	ReplicatedStorage.Player.PickaxeActive:GetPropertyChangedSignal("Value"):Connect(function()
		local Mining = ReplicatedStorage.Player.PickaxeActive.Value
		PickaxeService:GetPickaxe():andThen(function(Pickaxe: Tool)
			AnimationTrack:AdjustSpeed((Pickaxe:GetAttribute("Delay") / 2) or 1)

			if Mining then
				AnimationTrack:Play(0.1, 1)
			else
				AnimationTrack:Stop(0.1)
				task.wait(3)
			end
		end)
	end)

	PickaxeService.PlayHitSound:Connect(function(Block)
		if Block == nil then
			return
		end
		local HitSoundConfig = AudioEngine:CreateFromSound(
			Block:FindFirstChild("HitSound") or Core.Assets.Sounds.HitSound,
			true,
			Block.Position
		) -- We play at position because the block my be destroyed while sound is playing
		AudioEngine:PlaySound(HitSoundConfig)
	end)

	PickaxeService.PlayBreakSound:Connect(function(Block)
		if Block == nil then
			return
		end
		local BreakSoundConfig = AudioEngine:CreateFromSound(
			Block:FindFirstChild("BreakSound") or Core.Assets.Sounds.BreakSound,
			true,
			Block.Position
		) -- We play at position because the block my be destroyed while sound is playing
		AudioEngine:PlaySound(BreakSoundConfig)
	end)
end

return MineEffects
