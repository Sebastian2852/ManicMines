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
    local AnimationID = "rbxassetid://120997683811787"
    Animation = Instance.new("Animation")
    Animation.AnimationId = AnimationID
    Animation.Parent = script
end

function MineEffects:KnitStart()
    LogService               = Knit.GetService("LogService")
    LightingController       = Knit.GetController("LightingController")
    MineService              = Knit.GetService("MineService")
    PlayerDisplayService     = Knit.GetService("PlayerDisplayService")
    DataService              = Knit.GetService("DataService")

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

    local AnimationTrack = Animator:LoadAnimation(Animation)
    AnimationTrack.Looped = true
    AnimationTrack.Priority = Enum.AnimationPriority.Action
    LogService:Log("Set animation track")

    RunService:BindToRenderStep("MiningAnimation", Enum.RenderPriority.Input.Value, function()
        if not AnimationTrack then return end

        DataService:GetPlayerDataFolder():andThen(function(DataFolder : Core.DataFolder)
            local Mining = DataFolder.ServerMining.Value
            if Mining == WasMining then return end
            WasMining = Mining

            if Mining then
                if not AnimationTrack.IsPlaying then
                    AnimationTrack:Play(0.1, 1, 1)
                end
            else
                if AnimationTrack.IsPlaying then
                    AnimationTrack:Stop(0.1)
                end
            end
        end)
    end)
end

return MineEffects