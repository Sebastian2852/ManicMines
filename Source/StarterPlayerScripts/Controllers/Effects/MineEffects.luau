local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Core = require(ReplicatedStorage.Game.Modules.Core)

local MineEffects = Knit.CreateController { Name = "MineEffects" }

local MineService
local LogService
local LightingController
local PlayerDisplayService
local DataService
local PickaxeService
local AudioEngine

local PreviousLayer = ""
local Animation

function MineEffects:Layer(LayerName :string)
    LogService:Log("Appling layer effects for: "..LayerName)
    if not Core.Assets.Layers:FindFirstChild(LayerName) then
        LogService:Warn("Invalid layer name: "..LayerName)
        return
    end

    local LayerConfig :Configuration = Core.Assets.Layers:FindFirstChild(LayerName)
    local LightingConfig = LayerConfig:FindFirstChild("Lighting")

    if LightingConfig then
        LogService:Log("Appling lighting effects")
        LightingController:CreateFromConfig(LightingConfig)
    end
end



-- [[ KNIT ]] --

function MineEffects:KnitInit()
    local AnimationID = "rbxassetid://16827661763"
    Animation = Instance.new("Animation")
    Animation.AnimationId = AnimationID
    Animation.Parent = script
end

function MineEffects:KnitStart()
    AudioEngine              = Knit.GetController("AudioEngine")
    LightingController       = Knit.GetController("LightingController")
    LogService               = Knit.GetService("LogService")
    MineService              = Knit.GetService("MineService")
    PlayerDisplayService     = Knit.GetService("PlayerDisplayService")
    DataService              = Knit.GetService("DataService")
    PickaxeService           = Knit.GetService("PickaxeService")

    RunService:BindToRenderStep("CharacterPositionInfo", Enum.RenderPriority.Input.Value + 1, function()
        local Character = Knit.Player.Character
        if not Character or not Character:FindFirstChild("HumanoidRootPart") then return end

        local X = math.floor(Character:FindFirstChild("HumanoidRootPart").CFrame.Position.X)
        local Y = math.floor(Character:FindFirstChild("HumanoidRootPart").CFrame.Position.Y)
        local Z = math.floor(Character:FindFirstChild("HumanoidRootPart").CFrame.Position.Z)
        local Position = Vector3.new(X, Y, Z)

        MineService:GetLayerConfig(Position.Y):andThen(function(Config :Configuration)
            if PreviousLayer == Config.Name then return end

            MineEffects:Layer(Config.Name)
            PreviousLayer = Config.Name
        end)

        MineService:ConvertToDepth(Position.Y):andThen(function(Depth :number)
            ReplicatedStorage.Player.Depth.Value = Depth
        end)
    end)

    PlayerDisplayService.GiveHeadlight:Connect(function(Character)
        local Light = Core.Assets.Misc.HeadLight:Clone()
        Light.Parent = Character:WaitForChild("Head")
    end)

    local WasMining = false

    local Character = Knit.Player.Character or Knit.Player.CharacterAdded:Wait()
    local Humanoid = Character:WaitForChild("Humanoid")
    local Animator = Humanoid:WaitForChild("Animator")

    local AnimationTrack :AnimationTrack = Animator:LoadAnimation(Animation)
    AnimationTrack.Looped = false
    AnimationTrack.Priority = Enum.AnimationPriority.Action
    LogService:Log("Set animation track:", AnimationTrack)

    AnimationTrack:GetMarkerReachedSignal("HitSound"):Connect(function()
        LogService:Log("Reached sound marker")

        local Sound :Core.Sound = AudioEngine:CreateBlankSound()
        Sound.SoundID = "rbxassetid://156951885"

        local Config :Core.SoundConfig = AudioEngine:CreateBlankConfig()
        Config.Looped = false
        Config.Pitch = 1
        Config.Positional = false
        Config.Volume = 1
        Config.Speed = 0.5
        Sound.Config = Config

        AudioEngine:PlaySound(Sound)
    end)

    RunService:BindToRenderStep("MiningAnimation", Enum.RenderPriority.Input.Value, function()
        if not AnimationTrack then
            LogService:Warn("No animation!!")
            return
        end

        DataService:GetPlayerDataFolder():andThen(function(DataFolder : Core.DataFolder)
            local Mining = DataFolder.ServerMining.Value
            if Mining == WasMining then return end
            PickaxeService:GetPickaxe():andThen(function(Pickaxe :Tool)
                --local HitSpeed = Pickaxe:GetAttribute("MiningCooldown") or 1
                --local AnimationLength = AnimationTrack.Length

                local AnimationSpeed = 1
                AnimationTrack:AdjustSpeed(AnimationSpeed)

                WasMining = Mining

                while Mining do
                    if not AnimationTrack.IsPlaying then
                        AnimationTrack:Play(0.1, 1)
                    end
                    task.wait(AnimationSpeed)
                end
            end)

            if not Mining and AnimationTrack.IsPlaying then
                AnimationTrack:Stop(0.1)
            end
        end)
    end)
end

return MineEffects