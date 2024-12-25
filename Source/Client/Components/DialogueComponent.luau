local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Component = require(ReplicatedStorage.Packages.Component)
local Trove = require(ReplicatedStorage.Packages.trove)

local Camera = Workspace.CurrentCamera
local OriginalCFrame = Camera.CFrame

local TweeningInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0)

-- [[ TYPES ]] --

type DialogueChoice = {
    Text :string;
    Index :number;
    CanLeave :boolean;
    LeaveText :string?;
    Choices :{[string] :DialogueChoice};
}

type InfoModule = {
    NpcName :string;
    InteractMessage :string;
    Dialogue :DialogueChoice;
}



-- [[ EXTENTIONS ]] --

local Extentions = {}
function Extentions.ShouldConstruct(ComponentInstance)
    local Object = ComponentInstance.Instance :: ModuleScript
    if not Object then return false end
    if not typeof(Object) == "Instance" then return false end
    if not Object:IsA("ModuleScript") then return false end
    return true
end



-- [[ COMPONENT ]] --

local DialogueComponent = Component.new({
    Tag = "Dialogue/Module/Config";
    Ancestors = { workspace };
    Extensions = { Extentions };
})

function DialogueComponent:Construct()
    self.Trove = Trove.new()
    self.NPC = self.Instance.Parent
    self.Info = require(self.Instance) :: InfoModule
    self.DialogueModule = require(Players.LocalPlayer.PlayerGui:WaitForChild("Dialogues"):WaitForChild("Main"):WaitForChild("DialoguesModule"))
    self.DialogueGUI = Players.LocalPlayer.PlayerGui:WaitForChild("Dialogues"):WaitForChild("DialogueFrame")

    self.CameraDialoguePart = self.Instance:FindFirstChildWhichIsA("BasePart") :: BasePart

    local VisibleChangeConnection = self.DialogueGUI:GetPropertyChangedSignal("Visible"):Connect(function()
        local Visible = self.DialogueGUI.Visible

        if not Visible then
            self:EndDialogue()
        end
    end)

    self.Trove:Add(VisibleChangeConnection)
end

function DialogueComponent:CreateContent()
    local Content = {
        InitialLayer = "Layer1";
        DialogueTitle = self.Info.NpcName;
        DialogueFrame = "DialogueFrame";
        ReplyFrame = "Reply";

        Settings = {
            Typewriter = true;
            TypewriterSpeed = 0.03;
            SpecialTypewriterSpeed = 0.5;
            TypewriterSound = nil;
            TypewriterSoundPitch = 1;
            TypewriterSoundRNGPitch = false;

            Autoscroll = 0;

            DialogueWalkSpeed = 0;

            CinematicBars = true;

            BackgroundSound = nil;
            BackgroundSoundVol = 0.1;

            DisableBackpack = true;
            DisableChat = false;
            DisableLeaderboard = false;

            ContinueButtonVisibleDuringReply = false;
            ContinueButtonVisibleDuringTypewriter = false;
            ContinueTextTransparency = 0.5;

            DialogueCam = nil;

            StopDialogueOnDeath = true;
            InteractWithDialogueWhendead = false;
        };
    }

    local function CreateLayer(Name :string, Info :DialogueChoice)
        local function CreateReplies(Choices :{DialogueChoice}, Leave :boolean)
            local Replies = {}
            if Choices then
                for ReplyName :string, ReplyInfo :DialogueChoice in pairs(Choices) do
                    CreateLayer(ReplyName, ReplyInfo)
                    table.insert(Replies, {
                        ReplyName = ReplyName;
                        ReplyText = ReplyName;
                        ReplyLayer = ReplyName;
                    })
                end
            end

            if Leave then
                table.insert(Replies, {
                    ReplyName = "LEAVE";
                    ReplyText = Info.LeaveText or "Leave";
                    ReplyLayer = nil;
                })
            end

            return Replies
        end

        local LayerReplies = CreateReplies(Info.Choices, Info.CanLeave)

        Content[Name] = {
            DialogueContent = {Info.Text};
            DialogueSounds = {};
            DialogueImage = "";
            LayerTitle = nil;
            Replies = LayerReplies;
        }
    end

    CreateLayer("Layer1", self.Info.Dialogue)

    return Content
end

function DialogueComponent:StartDialogue(ProximityPrompt)
    OriginalCFrame = Camera.CFrame
    Camera.CameraType = Enum.CameraType.Scriptable

    local CameraPart = ProximityPrompt:FindFirstChildWhichIsA("BasePart")
    local Tween = TweenService:Create(Camera, TweeningInfo, {CFrame = CameraPart.CFrame})
    Tween:Play()
end

function DialogueComponent:EndDialogue()
    local Tween = TweenService:Create(Camera, TweeningInfo, {CFrame = OriginalCFrame})
    Tween:Play()
    Tween.Completed:Wait()
    Camera.CameraType = Enum.CameraType.Custom
end

function DialogueComponent:Start()
    local ProximityPrompt = Instance.new("ProximityPrompt")
    ProximityPrompt.Name = "DialogueInteraction"
    ProximityPrompt.ObjectText = self.Info.NpcName
    ProximityPrompt.ActionText = self.Info.InteractMessage
    ProximityPrompt.RequiresLineOfSight = false
    ProximityPrompt.Parent = self.NPC

    self.CameraDialoguePart:Clone().Parent = ProximityPrompt
    self.ProximityPrompt = ProximityPrompt

    local TriggerConnection = ProximityPrompt.Triggered:Connect(function()
        self:StartDialogue(ProximityPrompt)
        self.DialogueModule.CreateDialogue({
            Content = self:CreateContent()
        })
    end)

    self.Trove:Add(TriggerConnection)
    self.Trove:Add(ProximityPrompt)
end

function DialogueComponent:Stop()
    self.Trove:Clean()
end

return DialogueComponent